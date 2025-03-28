import 'package:flutter/cupertino.dart';
import 'package:oro_drip_irrigation/views/customer/home_sub_classes/current_program.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import 'home_sub_classes/next_schedule.dart';
import 'home_sub_classes/pump_station.dart';
import 'home_sub_classes/scheduled_program.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key, required this.customerId});
  final int customerId;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CustomerScreenControllerViewModel>(context);

    List<FilterSite> filteredFilterSite = [];

    final waterSources = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.waterSource;
    final allFilterSite = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.filterSite;
    final fertilizerSite = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.fertilizerSite;
    final lineData = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData;
    final scheduledProgram = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].programList;

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
          PumpStation(
            waterSource: waterSources,
            irrLineData: lineData,
            filterSite: filteredFilterSite,
            fertilizerSite: fertilizerSite,
            currentLineName: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[viewModel.lIndex].name,
            deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,
          ),
          CurrentProgram(scheduledPrograms: scheduledProgram, deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,),
          NextSchedule(scheduledPrograms: scheduledProgram),
          scheduledProgram.isNotEmpty? ScheduledProgram(userId: customerId, scheduledPrograms: scheduledProgram,
            masterInx: viewModel.mIndex, deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,):
          const SizedBox(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
