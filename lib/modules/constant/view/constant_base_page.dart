import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/modules/constant/model/constant_menu_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/constant_setting_type_Model.dart';
import 'package:oro_drip_irrigation/modules/constant/state_management/constant_provider.dart';
import 'package:oro_drip_irrigation/modules/constant/view/ec_ph_in_constant.dart';
import 'package:oro_drip_irrigation/modules/constant/view/fertilizer_site_in_constant.dart';
import 'package:oro_drip_irrigation/modules/constant/view/global_alarm_in_constant.dart';
import 'package:oro_drip_irrigation/modules/constant/view/main_valve_in_constant.dart';
import 'package:oro_drip_irrigation/modules/constant/view/normal_critical_alarm_in_constant.dart';
import 'package:oro_drip_irrigation/modules/constant/view/pump_in_constant.dart';
import 'package:oro_drip_irrigation/modules/constant/view/valve_in_constant.dart';
import 'package:oro_drip_irrigation/modules/constant/view/water_meter_in_constant.dart';
import 'package:oro_drip_irrigation/modules/constant/widget/arrow_tab.dart';
import 'package:oro_drip_irrigation/modules/constant/widget/custom_check_box.dart';
import 'package:oro_drip_irrigation/modules/constant/widget/custom_pop_up_button.dart';
import 'package:oro_drip_irrigation/modules/constant/widget/custom_switch.dart';
import 'package:oro_drip_irrigation/modules/constant/widget/custom_text_form_field.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/overall_use.dart';
import 'channel_in_constant.dart';
import 'general_in_constant.dart';
import 'level_in_constant.dart';
import 'moisture_in_constant.dart';

class ConstantBasePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ConstantBasePage({super.key, required this.userData});

  @override
  State<ConstantBasePage> createState() => _ConstantBasePageState();
}

class _ConstantBasePageState extends State<ConstantBasePage> with SingleTickerProviderStateMixin{
  late TabController tabController;
  late Future<int> constantResponse;
  late ConstantProvider constPvd;
  late OverAllUse overAllPvd;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    constPvd = Provider.of<ConstantProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    constantResponse = getData();

  }

  Future<int> getData()async{
    await Future.delayed(const Duration(seconds: 1));
    constPvd.updateConstant();
    setState(() {
      tabController = TabController(length: constPvd.listOfConstantMenuModel.length, vsync: this);
    });
    return 200;
  }

  @override
  Widget build(BuildContext context) {
    constPvd = Provider.of<ConstantProvider>(context, listen: true);
    overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    return FutureBuilder<int>(
        future: constantResponse,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading state
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Error state
          } else if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.02),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 20,
                    children: [
                      getTabs(),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                            children: getTabBarView()
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Text('No data'); // Shouldn't reach here normally
          }
        }
    );
  }

  List<Widget> getTabBarView(){
    return List.generate(tabController.length, (index){
      if(constPvd.listOfConstantMenuModel[index].dealerDefinitionId == 82){
        return GeneralInConstant(constPvd: constPvd, overAllPvd: overAllPvd,);
      }else if(constPvd.listOfConstantMenuModel[index].dealerDefinitionId == 83){
        return PumpInConstant(constPvd: constPvd, overAllPvd: overAllPvd,);
      }else if(constPvd.listOfConstantMenuModel[index].dealerDefinitionId == 85){
        return MainValveInConstant(constPvd: constPvd, overAllPvd: overAllPvd,);
      }else if(constPvd.listOfConstantMenuModel[index].dealerDefinitionId == 86){
        return ValveInConstant(constPvd: constPvd, overAllPvd: overAllPvd,);
      }else if(constPvd.listOfConstantMenuModel[index].dealerDefinitionId == 87){
        return WaterMeterInConstant(constPvd: constPvd, overAllPvd: overAllPvd,);
      }else if(constPvd.listOfConstantMenuModel[index].dealerDefinitionId == 88){
        return FertilizerSiteInConstant(constPvd: constPvd, overAllPvd: overAllPvd,);
      }else if(constPvd.listOfConstantMenuModel[index].dealerDefinitionId == 89){
        return ChannelInConstant(constPvd: constPvd, overAllPvd: overAllPvd,);
      }else if(constPvd.listOfConstantMenuModel[index].dealerDefinitionId == 90){
        return EcPhInConstant(constPvd: constPvd, overAllPvd: overAllPvd,);
      }else if(constPvd.listOfConstantMenuModel[index].dealerDefinitionId == 91){
        return MoistureInConstant(constPvd: constPvd, overAllPvd: overAllPvd,);
      }else if(constPvd.listOfConstantMenuModel[index].dealerDefinitionId == 92){
        return LevelInConstant(constPvd: constPvd, overAllPvd: overAllPvd,);
      }else if(constPvd.listOfConstantMenuModel[index].dealerDefinitionId == 93){
        return NormalCriticalInConstant(constPvd: constPvd, overAllPvd: overAllPvd,);
      }else if(constPvd.listOfConstantMenuModel[index].dealerDefinitionId == 94){
        return GlobalAlarmInConstant(constPvd: constPvd, overAllPvd: overAllPvd,);
      }else{
        return Text(constPvd.listOfConstantMenuModel[index].parameter);
      }
    });
  }

  Widget getTabs(){
    return TabBar(
      overlayColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return Colors.transparent; // Color when tab is hovered (Web/Desktop)
        }
        return null; // Default behavior (no overlay)
      }),
      tabAlignment: TabAlignment.start,
      dividerHeight: 0,
      labelPadding: const EdgeInsets.all(0),
      isScrollable: true,
      indicator: const BoxDecoration(),
      controller: tabController,
      tabs: List.generate(constPvd.listOfConstantMenuModel.length, (index){
        return Tab(
            child: AnimatedBuilder(
                animation: constPvd.listOfConstantMenuModel[index].arrowTabState,
                builder: (context, child){
                  return ArrowTab(
                      index: index,
                      title: constPvd.listOfConstantMenuModel[index].parameter,
                      arrowTabState: constPvd.listOfConstantMenuModel[index].arrowTabState.value
                  );
                }
            ),
        );
      }),
      onTap: (value){
        constPvd.listOfConstantMenuModel[value].arrowTabState.value = ArrowTabState.onProgress;
        if(value > tabController.previousIndex){
          for(var i = 0; i< value;i++){
            constPvd.listOfConstantMenuModel[i].arrowTabState.value = ArrowTabState.complete;
          }
        }else{
          for(var i = constPvd.listOfConstantMenuModel.length - 1; i > value;i--){
            constPvd.listOfConstantMenuModel[i].arrowTabState.value = ArrowTabState.inComplete;
          }
        }
      },
    );
  }
}
