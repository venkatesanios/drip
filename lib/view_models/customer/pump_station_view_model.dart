import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../services/mqtt_service.dart';
import '../../utils/constants.dart';
import '../../utils/snack_bar.dart';

class PumpStationViewModel extends ChangeNotifier {

  late MqttPayloadProvider payloadProvider;

  List<WaterSource> mvWaterSource;
  final List<FilterSite> mvFilterSite;
  final List<FertilizerSite> mvFertilizerSite;
  final List<IrrigationLineData>? mvIrrLineData;
  final String mvCurrentLineName;

  int grandTotal = 0;
  late List<WaterSource> sortedWaterSources = [];
  final ValueNotifier<int> popoverUpdateNotifier = ValueNotifier<int>(0);

  List<dynamic> _previousRelayStatus = [];
  List<dynamic> _previousPumpStatus = [];
  List<dynamic> _previousFilterStatus = [];
  List<dynamic> _previousFertilizerStatus = [];

  static const excludedReasons = [
    '3', '4', '5', '6', '21', '22', '23', '24',
    '25', '26', '27', '28', '29', '30', '31'
  ];

  PumpStationViewModel(context, this.mvWaterSource, this.mvFilterSite, this.mvFertilizerSite, this.mvIrrLineData, this.mvCurrentLineName) {
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    displaySite();
  }

  bool shouldUpdate(List<dynamic> newRelayStatus, List<dynamic> pumpPayload,
      List<dynamic> filterPayload, List<dynamic> fertilizerPayload) {
    if (!listEquals(_previousRelayStatus, newRelayStatus)
    ||!listEquals(_previousPumpStatus, pumpPayload) ||
        !listEquals(_previousFilterStatus, filterPayload) ||
        !listEquals(_previousFertilizerStatus, fertilizerPayload) ) {
      _previousRelayStatus = List.from(newRelayStatus);
      _previousPumpStatus = List.from(pumpPayload);
      _previousFilterStatus = List.from(filterPayload);
      _previousFertilizerStatus = List.from(fertilizerPayload);
      return true;
    }
    return false;
  }

  void displaySite(){
    int totalWaterSources = mvWaterSource.length;
    int totalOutletPumps = mvWaterSource.fold(0, (sum, source) => sum + source.outletPump.length);

    int totalFilters = mvFilterSite.fold(0, (sum, site) => sum + (site.filters.length ?? 0));
    int totalPressureIn = mvFilterSite.fold(0, (sum, site) => sum + (site.pressureIn!=null ? 1 : 0));
    int totalPressureOut = mvFilterSite.fold(0, (sum, site) => sum + (site.pressureOut!=null ? 1 : 0));

    int totalBoosterPump = mvFertilizerSite.fold(0, (sum, site) => sum + (site.boosterPump.length ?? 0));
    int totalChannels = mvFertilizerSite.fold(0, (sum, site) => sum + (site.channel.length ?? 0));
    int totalAgitators = mvFertilizerSite.fold(0, (sum, site) => sum + (site.agitator.length ?? 0));

    grandTotal = totalWaterSources + totalOutletPumps +
        totalFilters + totalPressureIn + totalPressureOut +
        totalBoosterPump + totalChannels + totalAgitators;

    sortedWaterSources = [...mvWaterSource]
      ..sort((a, b) {
        bool aHasOutlet = a.outletPump.isNotEmpty;
        bool bHasOutlet = b.outletPump.isNotEmpty;

        bool aHasInlet = a.inletPump.isNotEmpty;
        bool bHasInlet = b.inletPump.isNotEmpty;

        if (aHasOutlet && !aHasInlet && (!bHasOutlet || bHasInlet)) return -1;
        if (bHasOutlet && !bHasInlet && (!aHasOutlet || aHasInlet)) return 1;

        return 0;
      });

    notifyListeners();
  }


  void updateOutputStatus(List<String> outputStatusPayload, List<String> pumpPayload,
      List<String> filterPayload, List<String> fertilizerPayload){

    List<String> pumpStatus = outputStatusPayload
        .where((item) => item.startsWith('5.')).toList();
    updatePumpStatus(mvWaterSource, pumpStatus, pumpPayload);

    List<String> valvePayload = outputStatusPayload
        .where((item) => item.startsWith('13.')).toList();
    updateValveStatus(mvIrrLineData!, valvePayload);

    List<String> filterStatus = outputStatusPayload
        .where((item) => item.startsWith('11.')).toList();
    updateFilterStatus(mvFilterSite, filterStatus, filterPayload);

    List<String> boosterStatus = outputStatusPayload
        .where((item) => item.startsWith('7.')).toList();
    updateBoosterStatus(mvFertilizerSite, boosterStatus);

    List<String> frtChannelStatus = outputStatusPayload
        .where((item) => item.startsWith('10.')).toList();
    updateFertilizerChannelStatus(mvFertilizerSite, frtChannelStatus, fertilizerPayload);


    notifyListeners();
  }


  void updatePumpStatus(List<WaterSource> waterSource, List<dynamic> filteredPumpStatus, List<dynamic> pumpStatusList) {

    for (var source in waterSource) {
      for (var pump in source.outletPump) {

        var matchedEntry = pumpStatusList.firstWhere(
              (entry) => entry.split(',')[0] == pump.sNo.toString(),
          orElse: () => '',
        );

        if (matchedEntry.isNotEmpty) {
          List<String> statusData = matchedEntry.split(',');
          if (statusData.length >= 8) {
            pump.reason = statusData[1];
            pump.setValue = statusData[2];
            pump.actualValue = statusData[3];
            pump.phase = statusData[4];
            pump.voltage = statusData[5];
            pump.current = statusData[6];
            pump.onDelayLeft = statusData[7];
          }
        } else {
          print("Serial Number ${pump.sNo} not found in pumpStatusList");
        }

        int? status = getStatus(filteredPumpStatus, pump.sNo);
        if (status != null) {
          pump.status = status;
        } else {
          print("Serial Number ${pump.sNo} not found");
        }
      }
    }
  }

  void updateFilterStatus(List<FilterSite> mvFilterSite, List<dynamic> filterStatus, List<dynamic> filterPayload) {

    for (var filterSite in mvFilterSite) {

      var matchedEntry = filterPayload.firstWhere(
            (entry) => entry.split(',')[0] == filterSite.sNo.toString(),
        orElse: () => '',
      );

      if (matchedEntry.isNotEmpty) {
        List<String> filterData = matchedEntry.split(',');
        if(filterData[1]!='0' && filterData[1]!='-1' && filterData[1]!='-2'){
          filterSite.filters[int.parse(filterData[1])-1].onDelayLeft = filterData[2];
        }

        if(filterData[1]!='0' && filterData[1]!='-1' && filterData[1]!='-2'){
          int? status = getStatus(filterStatus, filterSite.filters[int.parse(filterData[1])-1].sNo);
          if (status != null) {
            filterSite.filters[int.parse(filterData[1])-1].status = status;
          } else {
            print("Serial Number ${filterSite.filters[int.parse(filterData[1])-1].sNo} not found");
          }
        }else{
          if(filterData[1]=='0'){
            for (var filter in filterSite.filters) {
              filter.status = 0;
              filter.onDelayLeft = '00:00:00';
            }
          }

          //filterSite.filters[int.parse(filterData[1])-1].status = 0;
          //filterSite.filters[int.parse(filterData[1])-1].onDelayLeft = '00:00:00';
        }

      }
    }
  }

  void updateFertilizerChannelStatus(List<FertilizerSite> mvFertilizerSite,
      List<dynamic> fertilizerStatus, List<dynamic> fertilizerPayload) {

    for (var fertilizer in mvFertilizerSite) {
      for (var channel in fertilizer.channel) {

        var matchedEntry = fertilizerPayload.firstWhere(
              (entry) => entry.split(',')[0] == channel.sNo.toString(),
          orElse: () => '',
        );

        if (matchedEntry.isNotEmpty) {
          List<String> statusData = matchedEntry.split(',');

          channel.frtMethod = statusData[1];
          channel.duration = statusData[2];
          channel.completedDrQ = statusData[3];
          channel.onTime = statusData[4];
          channel.offTime = statusData[5];
          channel.flowRateLpH = statusData[6];

        } else {
          print("Serial Number ${channel.sNo} not found in pumpStatusList");
        }

        int? status = getStatus(fertilizerStatus, channel.sNo);
        if (status != null) {
          channel.status = status;
        } else {
          print("Serial Number ${channel.sNo} not found");
        }
      }
    }
  }

  void updateValveStatus(List<IrrigationLineData> lineData, List<dynamic> valveStatus) {

    for (var line in lineData) {
      for (var vl in line.valves) {
        int? status = getStatus(valveStatus, vl.sNo);
        if (status != null) {
          vl.status = status;
        } else {
          print("Serial Number ${vl.sNo} not found");
        }
      }
    }
  }

  void updateBoosterStatus(List<FertilizerSite> fertilizerSite, List<dynamic> boosterStatus) {
    for (var fertilizer in fertilizerSite) {
      int? status = getStatus(boosterStatus, fertilizer.boosterPump[0].sNo);
      if (status != null) {
        fertilizer.boosterPump[0].status = status;
      } else {
        print("Serial Number ${fertilizer.boosterPump[0].sNo} not found");
      }
    }
  }

  int? getStatus(List<dynamic> outputOnOffLiveMessage, double serialNumber) {

    for (int i = 0; i < outputOnOffLiveMessage.length; i++) {
      List<String> parts = outputOnOffLiveMessage[i].split(',');
      double? serial = double.tryParse(parts[0]);

      if (serial != null && serial == serialNumber) {
        return int.parse(parts[1]);
      }
    }
    return null;
  }

  bool isTimeFormat(String value) {
    final timeRegExp = RegExp(r'^([0-1]?\d|2[0-3]):[0-5]\d:[0-5]\d$');
    return timeRegExp.hasMatch(value);
  }

  String getContentByCode(int code) {
    return PumpReasonCode.fromCode(code).content;
  }

  void resetPump(context, String deviceId, double pumpSno, String pumpName, int customerId, int controllerId, int userId) {

    String payload = '$pumpSno,1';
    String payLoadFinal = jsonEncode({
      "6300": {"6301": payload}
    });
    MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
    sentUserOperationToServer('$pumpName Reset Manually', payLoadFinal, customerId, controllerId, userId);
    GlobalSnackBar.show(context, 'Reset comment sent successfully', 200);
    Navigator.pop(context);

    /*if(getPermissionStatusBySNo(context, 4)){
      String payload = '$pumpSno,1';
      String payLoadFinal = jsonEncode({
        "6300": {"6301": payload}
      });
      MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
      //sentUserOperationToServer('${pump.swName ?? pump.name} Reset Manually', payLoadFinal);
      GlobalSnackBar.show(context, 'Reset comment sent successfully', 400);
      Navigator.pop(context);
    }else{
      Navigator.pop(context);
      GlobalSnackBar.show(context, 'Permission denied', 400);
    }*/


  }

  void sentUserOperationToServer(String msg, String data, int customerId, int controllerId, int userId) async
  {
    Map<String, Object> body = {"userId": customerId, "controllerId": controllerId, "messageStatus": msg, "hardware": jsonDecode(data), "createUser": userId};
    final response = await Repository(HttpService()).createUserSentAndReceivedMessageManually(body);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

}