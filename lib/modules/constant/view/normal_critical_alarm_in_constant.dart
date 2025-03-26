import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/constant/model/alarm_in_constant_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/constant_setting_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/constant_setting_type_Model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/ec_ph_in_constant_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/object_in_constant_model.dart';

import '../../../StateManagement/overall_use.dart';
import '../state_management/constant_provider.dart';
import '../widget/find_suitable_widget.dart';

class NormalCriticalInConstant extends StatefulWidget {
  final ConstantProvider constPvd;
  final OverAllUse overAllPvd;
  const NormalCriticalInConstant({super.key, required this.constPvd, required this.overAllPvd});

  @override
  State<NormalCriticalInConstant> createState() => _NormalCriticalInConstantState();
}

class _NormalCriticalInConstantState extends State<NormalCriticalInConstant> {
  double cellWidth = 150;
  int selectedIrrigationLine = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double minWidth = (cellWidth * 1) + (widget.constPvd.defaultNormalCriticalAlarmSetting.length * cellWidth) + 50;
    Color borderColor = const Color(0xffE1E2E3);
    return DataTable2(
      border: TableBorder(
        top: BorderSide(color: borderColor, width: 1),
        bottom: BorderSide(color: borderColor, width: 1),
        left: BorderSide(color: borderColor, width: 1),
        right: BorderSide(color: borderColor, width: 1),
      ),
      minWidth: minWidth,
      fixedLeftColumns: minWidth < screenWidth ? 0 : 1,
      columns: [
        DataColumn2(
            headingRowAlignment: MainAxisAlignment.center,
            fixedWidth: cellWidth,
            label: Text('Alarm', style: Theme.of(context).textTheme.labelLarge,textAlign: TextAlign.center, softWrap: true)
        ),
        ...widget.constPvd.defaultNormalCriticalAlarmSetting.map((defaultSetting) {
          return DataColumn2(
              headingRowAlignment: MainAxisAlignment.center,
              fixedWidth: cellWidth,
              label: Text(defaultSetting.title, style: Theme.of(context).textTheme.labelLarge,textAlign: TextAlign.center, softWrap: true,)
          );
        }),
      ],
      rows: List.generate(widget.constPvd.normalCriticalAlarm[selectedIrrigationLine].normal.length, (row){
        AlarmInConstantModel normalAlarm = widget.constPvd.normalCriticalAlarm[selectedIrrigationLine].normal[row];
        AlarmInConstantModel criticalAlarm = widget.constPvd.normalCriticalAlarm[selectedIrrigationLine].critical[row];
        return DataRow2(
            specificRowHeight: 100,
            color: WidgetStatePropertyAll(
              row.isOdd ? Colors.white : const Color(0xffF8F8F8),
            ),
            cells: [
              DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(child: Text(normalAlarm.title, textAlign: TextAlign.center, style: TextStyle(color: Colors.orange.shade500),)),
                      Center(child: Text(normalAlarm.title, textAlign: TextAlign.center, style: TextStyle(color: Colors.red.shade500),)),
                    ],
                  )
              ),
              ...List.generate(widget.constPvd.defaultNormalCriticalAlarmSetting.length, (index){
                return DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 40,
                          width: cellWidth,
                          child: FindSuitableWidget(
                            constantSettingModel: normalAlarm.setting[index],
                            onUpdate: (value){
                              setState(() {
                                normalAlarm.setting[index].value = value;
                              });
                            },
                            onOk: (){
                              setState(() {
                                normalAlarm.setting[index].value = widget.overAllPvd.getTime();
                              });
                              Navigator.pop(context);
                            },
                            popUpItemModelList: normalAlarm.setting[index].sNo == 2 ? widget.constPvd.alarmOnStatus : widget.constPvd.resetAfterIrrigation,
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          width: cellWidth,
                          child: FindSuitableWidget(
                            constantSettingModel: criticalAlarm.setting[index],
                            onUpdate: (value){
                              setState(() {
                                criticalAlarm.setting[index].value = value;
                              });
                            },
                            onOk: (){
                              setState(() {
                                criticalAlarm.setting[index].value = widget.overAllPvd.getTime();
                              });
                              Navigator.pop(context);
                            },
                            popUpItemModelList: criticalAlarm.setting[index].sNo == 2 ? widget.constPvd.alarmOnStatus : widget.constPvd.resetAfterIrrigation,
                          ),
                        ),
                      ],
                    )
                );
              })
            ]
        );
      })
      // rows: List.generate(widget.constPvd.ecPh.length, (row){
      //   NormalCriticalInConstant Model fertilizerSite = widget.constPvd.ecPh[row];
      //   return DataRow2(
      //       specificRowHeight: fertilizerSite.setting.length == 2 ? 100 : null,
      //       color: WidgetStatePropertyAll(
      //         row.isOdd ? Colors.white : const Color(0xffF8F8F8),
      //       ),
      //       cells: [
      //         DataCell(
      //             Center(child: Text(fertilizerSite.name.toString(), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).primaryColorLight),))
      //         ),
      //         DataCell(
      //             Column(
      //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //               children: [
      //                 if(fertilizerSite.ecPopup.isNotEmpty)
      //                   Center(child: Text('Ec Sensor', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).primaryColorLight),)),
      //                 if(fertilizerSite.phPopup.isNotEmpty)
      //                   Center(child: Text('Ph Sensor', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).primaryColorLight),)),
      //               ],
      //             )
      //         ),
      //         ...List.generate(widget.constPvd.defaultEcPhSetting.length, (index){
      //           return DataCell(
      //               Column(
      //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                 children: [
      //                   SizedBox(
      //                     height: 40,
      //                     width: cellWidth,
      //                     child: FindSuitableWidget(
      //                       constantSettingModel: fertilizerSite.setting[0][index],
      //                       onUpdate: (value){
      //                         setState(() {
      //                           fertilizerSite.setting[0][index].value = value;
      //                         });
      //                       },
      //                       onOk: (){
      //                         setState(() {
      //                           fertilizerSite.setting[0][index].value = widget.overAllPvd.getTime();
      //                         });
      //                         Navigator.pop(context);
      //                       },
      //                       popUpItemModelList: fertilizerSite.ecPopup,
      //                     ),
      //                   ),
      //                   if(fertilizerSite.setting.length > 1)
      //                     SizedBox(
      //                       width: cellWidth,
      //                       height: 40,
      //                       child: FindSuitableWidget(
      //                         constantSettingModel: fertilizerSite.setting[1][index],
      //                         onUpdate: (value){
      //                           setState(() {
      //                             fertilizerSite.setting[1][index].value = value;
      //                           });
      //                         },
      //                         onOk: (){
      //                           setState(() {
      //                             fertilizerSite.setting[1][index].value = widget.overAllPvd.getTime();
      //                           });
      //                           Navigator.pop(context);
      //                         },
      //                         popUpItemModelList: fertilizerSite.phPopup,
      //                       ),
      //                     ),
      //                 ],
      //               )
      //           );
      //         })
      //       ]
      //   );
      // }),

    );

  }
}
