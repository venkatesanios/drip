import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/customer/home_sub_classes/current_program.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import 'home_sub_classes/next_schedule.dart';
import 'home_sub_classes/pump_station.dart';
import 'home_sub_classes/scheduled_program.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key, required this.customerId, required this.controllerId});
  final int customerId, controllerId;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CustomerScreenControllerViewModel>(context);

    List<FilterSite> filteredFilterSite = [];
    List<FertilizerSite> filteredFertilizerSite = [];
    List<WaterSource> filteredWaterSource = [];

    final allWaterSources = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.waterSource;
    final allFilterSite = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.filterSite;
    final allFertilizerSite = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.fertilizerSite;
    final lineData = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData;
    final scheduledProgram = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].programList;

    var onRefresh = Provider.of<MqttPayloadProvider>(context).onRefresh;

    if(viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].name=='All irrigation line'){
      filteredWaterSource = allWaterSources;
      filteredFilterSite = allFilterSite;
      filteredFertilizerSite = allFertilizerSite;
    }else{
      final filteredLineData = viewModel.mySiteList.data[viewModel.sIndex]
          .master[viewModel.mIndex].config.lineData
          .where((line) => line.name == viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].name)
          .toList();

      filteredWaterSource = allWaterSources;

      /*filteredWaterSource = allWaterSources.where((ws) {
        if (ws.inletPump.isNotEmpty && ws.outletPump.isNotEmpty) {
          return ws.outletPump.any((op) =>
              filteredLineData[0].irrigationPump.any((ip) => ip.sNo == op.sNo));
        }
        return false;
      }).toList();*/


      filteredFilterSite = viewModel.mySiteList.data[viewModel.sIndex]
          .master[viewModel.mIndex].config.filterSite
          .where((filterSite) => filterSite.sNo == filteredLineData[0].cFilterSNo)
          .toList();

      filteredFertilizerSite = viewModel.mySiteList.data[viewModel.sIndex]
          .master[viewModel.mIndex].config.fertilizerSite
          .where((fertilizerSite) => fertilizerSite.sNo == filteredLineData[0].cFertilizerSNo)
          .toList();
    }

    if(viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].sNo==0)
    {
      print('Line Name :${viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].name}');
    }else{
      print('Line Name :${viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].name}');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,  // Change this as per need
        mainAxisAlignment: MainAxisAlignment.start,    // Adjust alignment
        children: [
          onRefresh ? displayLinearProgressIndicator() : const SizedBox(),
          if (!kIsWeb)
            CurrentProgram(
              scheduledPrograms: scheduledProgram,
              deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,
              customerId: customerId,
              controllerId: controllerId,
              currentLineSNo: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].sNo,
            ),
          PumpStation(
            key: ValueKey(filteredFilterSite.map((e) => e.sNo).join(',')),
            waterSource: filteredWaterSource,
            irrLineData: lineData,
            filterSite: filteredFilterSite,
            fertilizerSite: filteredFertilizerSite,
            currentLineName: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].name,
            deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,
            customerId: customerId,
            controllerId: controllerId,
          ),
          if (kIsWeb)
            CurrentProgram(
              scheduledPrograms: scheduledProgram,
              deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,
              customerId: customerId,
              controllerId: controllerId,
              currentLineSNo: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].sNo,
            ),
          NextSchedule(scheduledPrograms: scheduledProgram),
          if (kIsWeb && scheduledProgram.isNotEmpty)
            ScheduledProgram(
              userId: customerId,
              scheduledPrograms: scheduledProgram,
              controllerId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].controllerId,
              deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,
              customerId: customerId,
              currentLineSNo: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].sNo,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget displayLinearProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 3, right: 3),
      child: LinearProgressIndicator(
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        backgroundColor: Colors.grey[200],
        minHeight: 4,
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }
}
