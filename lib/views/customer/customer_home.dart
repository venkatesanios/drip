import 'package:flutter/cupertino.dart';
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

    final waterSources = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.waterSource;
    final allFilterSite = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.filterSite;
    final fertilizerSite = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.fertilizerSite;
    final lineData = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData;
    final scheduledProgram = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].programList;

    var liveSync = Provider.of<MqttPayloadProvider>(context).liveSync;

    if(viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].name=='All irrigation line'){
      filteredFilterSite = allFilterSite;
    }else{
      final filteredLineData = viewModel.mySiteList.data[viewModel.sIndex]
          .master[viewModel.mIndex].config.lineData
          .where((line) => line.name == viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].name)
          .toList();

      filteredFilterSite = viewModel.mySiteList.data[viewModel.sIndex]
          .master[viewModel.mIndex].config.filterSite
          .where((filterSite) => filterSite.sNo == filteredLineData[0].centralFiltration)
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
        children: [
          liveSync? displayLinearProgressIndicator(): const SizedBox(),
          PumpStation(
            waterSource: waterSources,
            irrLineData: lineData,
            filterSite: filteredFilterSite,
            fertilizerSite: fertilizerSite,
            currentLineName: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].name,
            deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId, customerId: customerId, controllerId: controllerId,
          ),
          CurrentProgram(scheduledPrograms: scheduledProgram, deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId, customerId: customerId, controllerId: controllerId,),
          NextSchedule(scheduledPrograms: scheduledProgram),
          scheduledProgram.isNotEmpty? ScheduledProgram(userId: customerId, scheduledPrograms: scheduledProgram,
            controllerId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].controllerId, deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId, customerId: customerId,):
          const SizedBox(),
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
