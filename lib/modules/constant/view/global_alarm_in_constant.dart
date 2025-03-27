import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/constant/state_management/constant_provider.dart';
import 'package:oro_drip_irrigation/modules/constant/widget/custom_switch.dart';
import 'package:oro_drip_irrigation/modules/constant/widget/custom_text_form_field.dart';
import 'package:oro_drip_irrigation/modules/constant/widget/find_suitable_widget.dart';
import 'package:oro_drip_irrigation/modules/irrigation_report/model/general_parameter_model.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../../StateManagement/overall_use.dart';
import '../../../Widgets/HoursMinutesSeconds.dart';
import '../model/constant_setting_model.dart';


class GlobalAlarmInConstant extends StatefulWidget {
  final ConstantProvider constPvd;
  final OverAllUse overAllPvd;
  const GlobalAlarmInConstant({super.key, required this.constPvd, required this.overAllPvd});

  @override
  State<GlobalAlarmInConstant> createState() => _GlobalAlarmInConstantState();
}

class _GlobalAlarmInConstantState extends State<GlobalAlarmInConstant> {
  ValueNotifier<int> hoveredSno = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ResponsiveGridList(
        horizontalGridMargin: 0,
        verticalGridSpacing: 20,
        horizontalGridSpacing: 30,
        verticalGridMargin: 20,
        minItemWidth: 300,
        shrinkWrap: true,
        listViewBuilderOptions: ListViewBuilderOptions(
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: widget.constPvd.globalAlarm.map((globalSetting){
          return AnimatedBuilder(
              animation: hoveredSno,
              builder: (context, child){
                return MouseRegion(
                  onEnter: (_){
                    hoveredSno.value = globalSetting.sNo;
                  },
                  onExit: (_){
                    hoveredSno.value = 0;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: hoveredSno.value == globalSetting.sNo
                                  ? Theme.of(context).primaryColorLight.withOpacity(0.8)
                                  : const Color(0xff000040).withOpacity(0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 4)
                          )
                        ]
                    ),
                    child: ListTile(
                      title: Text(globalSetting.title, style: Theme.of(context).textTheme.labelLarge,),
                      trailing: SizedBox(
                        width: 80,
                        child: FindSuitableWidget(
                          constantSettingModel: globalSetting,
                          onUpdate: (value){
                            setState(() {
                              globalSetting.value.value = value;
                            });
                          },
                          onOk: (){
                            setState(() {
                              globalSetting.value.value = widget.overAllPvd.getTime();
                            });
                            Navigator.pop(context);
                          },
                          popUpItemModelList: [],
                        ),
                      ),
                    ),
                  ),
                );
              }
          );
        }).toList(),
      ),
    );
  }
}
