import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';

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

  PumpStationViewModel(context, this.mvWaterSource, this.mvFilterSite, this.mvFertilizerSite, this.mvIrrLineData, this.mvCurrentLineName) {
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
  }

  bool shouldUpdate(List<dynamic> newRelayStatus) {
    if (!listEquals(_previousRelayStatus, newRelayStatus)) {
      _previousRelayStatus = List.from(newRelayStatus);
      return true;
    }
    return false;
  }


  void updateOutputStatus(List<String> outputStatusPayload){
    print(outputStatusPayload);

    //payloadProvider.outputStatusPayload.clear();

    List<String> filteredPumpStatus = outputStatusPayload
        .where((item) => item.startsWith('5.')).toList();
    updatePumpStatus(mvWaterSource, filteredPumpStatus);

    List<String> filteredValveStatus = outputStatusPayload
        .where((item) => item.startsWith('13.')).toList();
    updateValveStatus(mvIrrLineData!, filteredValveStatus);

    List<String> filteredFilterStatus = outputStatusPayload
        .where((item) => item.startsWith('11.')).toList();
    updateFilterStatus(mvFilterSite, filteredFilterStatus);

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

  void updatePumpStatus(List<WaterSource> waterSource, List<dynamic> filteredPumpStatus) {
    for (var source in waterSource) {
      for (var pump in source.outletPump) {
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


}