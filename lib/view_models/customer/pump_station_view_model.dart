import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
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

  static const excludedReasons = [
    '3', '4', '5', '6', '21', '22', '23', '24',
    '25', '26', '27', '28', '29', '30', '31'
  ];

  PumpStationViewModel(context, this.mvWaterSource, this.mvFilterSite, this.mvFertilizerSite, this.mvIrrLineData, this.mvCurrentLineName) {
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    displaySite();
  }

  bool shouldUpdate(List<dynamic> newRelayStatus, List<dynamic> pumpPayload) {
    if (!listEquals(_previousRelayStatus, newRelayStatus)
    ||!listEquals(_previousPumpStatus, pumpPayload)) {
      _previousRelayStatus = List.from(newRelayStatus);
      _previousPumpStatus = List.from(pumpPayload);
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


  void updateOutputStatus(List<String> outputStatusPayload, List<String> pumpPayload){
    print(outputStatusPayload);

    //payloadProvider.outputStatusPayload.clear();

    List<String> filteredPumpStatus = outputStatusPayload
        .where((item) => item.startsWith('5.')).toList();
    updatePumpStatus(mvWaterSource, filteredPumpStatus, pumpPayload);

    List<String> filteredValveStatus = outputStatusPayload
        .where((item) => item.startsWith('13.')).toList();
    updateValveStatus(mvIrrLineData!, filteredValveStatus);

    List<String> filteredFilterStatus = outputStatusPayload
        .where((item) => item.startsWith('11.')).toList();
    updateFilterStatus(mvFilterSite, filteredFilterStatus);

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
            pump.status = int.tryParse(statusData[1]) ?? 0;
            pump.reason = statusData[2];
            pump.setValue = statusData[3];
            pump.actualValue = statusData[4];
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

  void updateFilterStatus(List<FilterSite> mvFilterSite, List<dynamic> filterStatus) {
    for (var filters in mvFilterSite) {
      for (var filter in filters.filters) {
        int? status = getStatus(filterStatus, filter.sNo);
        if (status != null) {
          filter.status = status;
        } else {
          print("Serial Number ${filter.sNo} not found");
        }
      }
    }
  }

  void updateValveStatus(List<IrrigationLineData> lineData, List<dynamic> filteredValveStatus) {

    for (var line in lineData) {
      for (var vl in line.valves) {
        int? status = getStatus(filteredValveStatus, vl.sNo);
        if (status != null) {
          vl.status = status;
        } else {
          print("Serial Number ${vl.sNo} not found");
        }
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

  void resetPump(context, String deviceId, double pumpSno) {

    String payload = '$pumpSno,1';
    String payLoadFinal = jsonEncode({
      "6300": {"6301": payload}
    });
    MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
    //sentUserOperationToServer('${pump.swName ?? pump.name} Reset Manually', payLoadFinal);
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

}