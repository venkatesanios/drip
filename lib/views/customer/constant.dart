import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../Models/customer/constant_model.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../view_models/customer/constant_view_model.dart';

class Constant extends StatelessWidget {
  const Constant(
      {super.key,
      required this.customerId,
      required this.controllerId,
      required this.userId});

  final int customerId, controllerId, userId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ConstantViewModel(Repository(HttpService()))
        ..getConstantData(customerId, controllerId),
      child: Consumer<ConstantViewModel>(
        builder: (context, vm, _) {
          return vm.isLoading
              ? Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 2 - 95,
                      right: MediaQuery.of(context).size.width / 2 - 95),
                  child: const LoadingIndicator(
                    indicatorType: Indicator.ballPulse,
                    strokeWidth: 100,
                  ),
                )
              : Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 10, bottom: 10),
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                vm.filteredMenu.asMap().entries.map((entry) {
                              int index = entry.key;
                              ConstantMenu filteredItem = entry.value;
                              return GestureDetector(
                                onTap: () {
                                  vm.menuOnChange(index);
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        entry.value.isSelected
                                            ? const Color(0xFF005B8D)
                                            : const Color(0xFFFFFFFF),
                                        BlendMode.srcIn,
                                      ),
                                      child: SvgPicture.asset(
                                        'assets/svg_images/white_arrow.svg',
                                        width: 250,
                                        height: 35,
                                      ),
                                    ),
                                    Positioned(
                                      child: Text(
                                        filteredItem.parameter,
                                        style: TextStyle(
                                          color: entry.value.isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: IndexedStack(
                            index: vm.filteredMenu
                                .indexWhere(
                                  (item) => item.isSelected == true,
                                )
                                .clamp(0, vm.filteredMenu.length - 1),
                            children: [
                              ...vm.filteredMenu.map((item) {
                                switch (item.parameter) {
                                  case "General":
                                    return GridView.builder(
                                      itemCount: vm.userConstant.constant
                                          .generalMenu.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            MediaQuery.sizeOf(context).width >
                                                    1350
                                                ? 3
                                                : 2,
                                        crossAxisSpacing: 16.0,
                                        mainAxisSpacing: 16.0,
                                        childAspectRatio:
                                            MediaQuery.sizeOf(context).width >
                                                    1350
                                                ? MediaQuery.sizeOf(context)
                                                        .width /
                                                    250
                                                : MediaQuery.sizeOf(context)
                                                        .width /
                                                    750,
                                      ),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Card(
                                          color: Colors.white,
                                          elevation: 1,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 10),
                                            child: ListTile(
                                              title: Text(vm
                                                  .userConstant
                                                  .constant
                                                  .generalMenu[index]
                                                  .title),
                                              trailing: vm
                                                          .userConstant
                                                          .constant
                                                          .generalMenu[index]
                                                          .widgetTypeId ==
                                                      1
                                                  ? SizedBox(
                                                      width: 75,
                                                      child: TextField(
                                                        controller:
                                                            vm.txtEdControllers[
                                                                index],
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          hintText: "value",
                                                        ),
                                                        onChanged: (value) {
                                                          vm.updateGeneralValve(
                                                              index,
                                                              value,
                                                              'general');
                                                        },
                                                      ),
                                                    )
                                                  : vm
                                                              .userConstant
                                                              .constant
                                                              .generalMenu[
                                                                  index]
                                                              .widgetTypeId ==
                                                          2
                                                      ? Transform.scale(
                                                          scale: 0.8,
                                                          child: Tooltip(
                                                            message: vm.userConstant.constant.generalMenu[index].value
                                                                ? 'Disable': 'Enable',
                                                            child: Switch(
                                                              hoverColor: Theme.of(context).primaryColor,
                                                              activeColor: Theme.of(context).primaryColorLight,
                                                              value: vm.userConstant.constant.generalMenu[index].value,
                                                              onChanged:
                                                                  (value) {
                                                                vm.updateGeneralSwitch(index,
                                                                    !(vm.userConstant.constant.generalMenu[index].value as bool));
                                                              },
                                                            ),
                                                          ),
                                                        )
                                                      : TextButton(
                                                          onPressed: () {
                                                            vm.showDurationInputDialog(
                                                                context,
                                                                vm.userConstant.constant.generalMenu[index].value, index, 'general');
                                                          },
                                                          child: Text(vm.userConstant.constant.generalMenu[index].value)),
                                            ),
                                          ),
                                        );
                                      },
                                    );

                                  case "Valve":
                                    return vm.userConstant.constant.valveList!.isNotEmpty
                                        ? DataTable2(
                                            border: const TableBorder(
                                              top: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                                              bottom: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                                              left: BorderSide(
                                                  color: Color(0xFFDFE0E1),
                                                  width: 1),
                                              right: BorderSide(
                                                  color: Color(0xFFDFE0E1),
                                                  width: 1),
                                            ),
                                            columnSpacing: 12,
                                            minWidth: 1020,
                                            dataRowHeight: 45.0,
                                            headingRowHeight: 40,
                                            headingRowColor:
                                                WidgetStateProperty.all(
                                                    const Color(0xFFFDFDFD)),
                                            columns: const [
                                              DataColumn(
                                                  label: Center(child: Text('Valve Name'))),
                                              DataColumn(label: Center(child: Text('Nominal Flow (I/hr)'))),
                                              DataColumn(label: Center(child: Text('Fill Up Delay'))),
                                            ],
                                            rows: List.generate(
                                                vm.userConstant.constant.valveList!.length, (index) {
                                              return DataRow(
                                                color: WidgetStateProperty
                                                    .resolveWith<Color?>(
                                                  (Set<WidgetState> states) {
                                                    return index.isEven
                                                        ? const Color(0xFFF6F6F6) : const Color(0xFFFDFDFD);
                                                  },
                                                ),
                                                cells: [
                                                  DataCell(Center(
                                                    child: Text(
                                                      vm.userConstant.constant.valveList![index].name,
                                                      style: const TextStyle(
                                                          color: Color(0xFF005B8D)),
                                                    ),
                                                  )),
                                                  DataCell(Center(child: SizedBox(
                                                    width: 100,
                                                    child: TextField(
                                                      controller: vm.txtEdControllersNF[index],
                                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly
                                                      ],
                                                      keyboardType: TextInputType.number,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                      decoration: const InputDecoration(
                                                              border: InputBorder.none,
                                                              hintText: "Enter value",
                                                              hintStyle: TextStyle(color: Colors.grey)),
                                                      onChanged: (value) {
                                                        vm.updateGeneralValve(index, value, 'value');
                                                      },
                                                    ),
                                                  ))),

                                                  DataCell(Center(
                                                      child: TextButton(
                                                          onPressed: () {
                                                            vm.showDurationInputDialog(
                                                                context,
                                                                vm.userConstant.constant.valveList![index].pickerVal, index, 'valve');
                                                            },
                                                          child: Text(vm.userConstant.constant.valveList![index].pickerVal)))),
                                                ],
                                              );
                                            }),
                                          )
                                        : const Center(
                                            child: Text("Valve Data not available"));

                                  case "Pump":
                                    return vm.userConstant.constant.pumpList!.isNotEmpty
                                        ? DataTable2(
                                            border: const TableBorder(
                                              top: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                                              bottom: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                                              left: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                                              right: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                                            ),
                                            columnSpacing: 12,
                                            minWidth: 1020,
                                            dataRowHeight: 45.0,
                                            headingRowHeight: 40,
                                            headingRowColor:
                                                WidgetStateProperty.all(const Color(0xFFFDFDFD)),
                                            columns: const [
                                              DataColumn(
                                                  label: Center(child: Text('Pump Name'))),
                                              DataColumn(label: Center(child: Text('Pump Station'))),
                                              DataColumn(label: Center(child: Text('Control Gem'))),
                                            ],
                                            rows: List.generate(
                                                vm.userConstant.constant.pumpList!.length, (index) {
                                              return DataRow(
                                                color: WidgetStateProperty
                                                    .resolveWith<Color?>((Set<WidgetState> states) {
                                                    return index.isEven ? const Color(0xFFF6F6F6) : const Color(0xFFFDFDFD);
                                                  },
                                                ),
                                                cells: [
                                                  DataCell(Center(
                                                    child: Text(
                                                      vm.userConstant.constant.pumpList![index].name,
                                                      style: const TextStyle(color: Color(0xFF005B8D)),
                                                    ),
                                                  )),
                                                  DataCell(Center(
                                                    child: Checkbox(
                                                      value: vm.userConstant.constant.pumpList![index].pumpStation,
                                                      onChanged: (bool? value) {
                                                        vm.pumpStationOnChange(index, value!);
                                                      },
                                                    ),
                                                  )),
                                                  DataCell(Center(
                                                    child: Checkbox(
                                                      value: vm.userConstant.constant.pumpList![index].controlGem,
                                                      onChanged: (bool? value) {
                                                        vm.controlGemOnChange(index, value!);
                                                      },
                                                    ),
                                                  )),
                                                ],
                                              );
                                            }),
                                          )
                                        : const Center(
                                            child: Text("Pump Data not available"));
                                  case "Main Valve":
                                    return vm.userConstant.constant.mainValveList!.isNotEmpty
                                        ? DataTable2(
                                            border: const TableBorder(
                                              top: BorderSide(
                                                  color: Color(0xFFDFE0E1),
                                                  width: 1),
                                              bottom: BorderSide(
                                                  color: Color(0xFFDFE0E1),
                                                  width: 1),
                                              left: BorderSide(
                                                  color: Color(0xFFDFE0E1),
                                                  width: 1),
                                              right: BorderSide(
                                                  color: Color(0xFFDFE0E1),
                                                  width: 1),
                                            ),
                                            columnSpacing: 12,
                                            horizontalMargin: 12,
                                            minWidth: 1020,
                                            headingRowColor:
                                                MaterialStateProperty.all(
                                                    const Color(0xFFFDFDFD)),
                                            // White header row
                                            columns: const [
                                              DataColumn(
                                                label: Center(
                                                  child: Text('Main Valve', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),),),
                                              DataColumn(
                                                label: Center(child: Text('Mode', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),),),
                                              DataColumn(
                                                label: Center(child: Text('Delay', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),),),
                                            ],

                                            rows: List.generate(
                                                vm.userConstant.constant.mainValveList!.length, (index) {
                                              return DataRow(
                                                  color: WidgetStateProperty
                                                      .resolveWith<Color?>(
                                                    (Set<WidgetState>states) {
                                                      return index.isEven ? const Color(0xFFF6F6F6) : const Color(0xFFFDFDFD); // Alternating row colors
                                                    },
                                                  ),
                                                  cells: [
                                                    DataCell(Center(child: Text(
                                                          vm.userConstant.constant.mainValveList![index].name,
                                                      style: const TextStyle(
                                                          color: Color(0xFF005B8D)),))),
                                                    DataCell(Center(
                                                        child: TextButton(
                                                            onPressed: () {
                                                              vm.showDurationInputDialog(
                                                                  context, vm.userConstant.constant.mainValveList![index].pickerVal, index, 'mainValve');
                                                            },
                                                            child: Text(vm.userConstant.constant.mainValveList![index].pickerVal)))),
                                                    DataCell(
                                                      Center(
                                                          child: PopupMenuButton<String>(
                                                            onSelected: (String selectedValue) {
                                                               vm.delay(index, selectedValue);
                                                            },
                                                            itemBuilder: (BuildContext context) {
                                                              return ['Do Nothing', 'Stop Irrigation', 'Stop Fertigation', 'Skip Irrigation']
                                                                  .map((String value) => PopupMenuItem<String>(
                                                                value: value,
                                                                height: 30,
                                                                child: Row(
                                                                  children: [
                                                                    const SizedBox(width: 8),
                                                                    Text(value, style: const TextStyle(fontSize: 17)),
                                                                  ],
                                                                ),
                                                              ))
                                                                  .toList();
                                                            },
                                                            child: Text(
                                                              vm.userConstant.constant.mainValveList![index].delay,
                                                              style: const TextStyle(fontSize: 16, color: Colors.black),
                                                            ),
                                                          )

                                                      ),
                                                    )

                                                  ]);
                                            }).toList(),
                                          )
                                        : const Center(
                                            child: Text(
                                                "Main Valve Data not available"));


                                  case "Irrigation Line":
                                    return vm.userConstant.constant.irrigationLineList!.isNotEmpty
                                 ? DataTable2(
                                border: const TableBorder(
                                top: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                                bottom: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                                left: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                                right: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                                ),
                                headingRowColor: MaterialStateProperty.all(const Color(0xFFFDFDFD)),
                                columnSpacing: 12,
                                horizontalMargin: 12,
                                minWidth: 1020,
                                columns: const [
                                DataColumn(label: Center(child: Text('Irrigation Line',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)))),
                                DataColumn(label: Center(child: Text('Low Flow Delay',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)))),
                                DataColumn(label: Center(child: Text('High Flow Delay',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)))),
                                DataColumn(label: Center(child: Text('Low Flow Action',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)))),
                                DataColumn(label: Center(child: Text('High Flow Action',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)))),
                                ],

                                      rows: List.generate(  vm.userConstant.constant.irrigationLineList!.length, (index) {
                                return DataRow(
                                color: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                return index.isEven ? const Color(0xFFF6F6F6) : const Color(0xFFFDFDFD) ; // Alternating row colors
                                },
                                ),
                                cells: [
                                DataCell(Center(child: Text( vm.userConstant.constant.irrigationLineList![index].name,style: const TextStyle(color: Color(0xFF005B8D)),))), // Center text
                                  DataCell(Center(
                                        child: TextButton(
                                        onPressed: () {
                                        vm.showDurationInputDialog(
                                        context, vm.userConstant.constant.irrigationLineList![index].pickerVal, index, 'irrigateLine');
                                        },
                                        child: Text(vm.userConstant.constant.irrigationLineList![index].pickerVal)))),
                                  // Center widget
                                  DataCell(Center(
                                      child: TextButton(
                                          onPressed: () {
                                            vm.showDurationInputDialog(
                                                context, vm.userConstant.constant.irrigationLineList![index].pickerVal, index, 'irrigateLine');
                                          },
                                          child: Text(vm.userConstant.constant.irrigationLineList![index].pickerVal)))),
                                  DataCell(
                                    Center(
                                        child: PopupMenuButton<String>(
                                          onSelected: (String selectedValue) {
                                            vm.lowFlowAction(index, selectedValue);
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return ['Ignore', 'Do Next', 'Wait']
                                                .map((String value) => PopupMenuItem<String>(
                                              value: value,
                                              height: 30,
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 8),
                                                  Text(value, style: const TextStyle(fontSize: 17)),
                                                ],
                                              ),
                                            ))
                                                .toList();
                                          },
                                          child: Text(
                                            vm.userConstant.constant.irrigationLineList![index].lowFlowAction,
                                            style: const TextStyle(fontSize: 16, color: Colors.black),
                                          ),
                                        )

                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                        child: PopupMenuButton<String>(
                                          onSelected: (String selectedValue) {
                                            vm.highFlowAction(index, selectedValue);
                                          },
                                          itemBuilder: (BuildContext context) {
                                            return ['Ignore', 'Do Next', 'Wait']
                                                .map((String value) => PopupMenuItem<String>(
                                              value: value,
                                              height: 30,
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 8),
                                                  Text(value, style: const TextStyle(fontSize: 17)),
                                                ],
                                              ),
                                            ))
                                                .toList();
                                          },
                                          child: Text(
                                            vm.userConstant.constant.irrigationLineList![index].highFlowAction,
                                            style: const TextStyle(fontSize: 16, color: Colors.black),
                                          ),
                                        )

                                    ),
                                  )
                                ]);
                                }),
                                    )  : const Center(child: Text("Irrigation Line Data not available"));

                                /*
                            case "Main Valve":
                              return widget.mainValves.isNotEmpty
                                  ? MainValveInConstant(
                                mainValves: widget.mainValves,
                                irrigationLines: widget.irrigationLines,
                              )
                                  : const Center(child: Text("Main Valve Data not available"));


                            case "Water Meter":
                              return widget.waterMeter.isNotEmpty
                                  ? WatermeterInConstant(waterMeter: widget.waterMeter)
                                  : const Center(child: Text("Water Meter Data not available"));

                            case "Fertilizer":
                              return widget.fertilizerSite.isNotEmpty
                                  ? FertilizerInConstant(
                                fertilizerSite: widget.fertilizerSite,
                                channels: widget.channels,
                              )
                                  : const Center(child: Text("Fertilizer Data not available"));

                            case "EC/PH":
                              return widget.ec.isNotEmpty && widget.ph.isNotEmpty
                                  ? EcPhInConstant(
                                ec: widget.ec,
                                ph: widget.ph,
                                fertilizerSite: widget.fertilizerSite,
                                controlSensors: widget.controlSensors,
                              )
                                  : const Center(child: Text("EC/PH Data not available"));

                            case "Critical Alarm":
                              return widget.alarm.isNotEmpty
                                  ? CriticalAlarmInConstant(alarm: widget.alarm)
                                  : const Center(child: Text("Critical Alarm Data not available"));

                            case "Global Alarm":
                              return widget.alarm.isNotEmpty
                                  ? GlobalAlarmInConstant(alarm: widget.alarm)
                                  : const Center(child: Text("Global Alarm Data not available"));

                            case "Moisture Sensor":
                              return widget.moistureSensors.isNotEmpty
                                  ? MoistureSensorConstant(moistureSensors: widget.moistureSensors)
                                  : const Center(child: Text("Moisture Sensor Data not available"));

                            case "Level Sensor":
                              return widget.levelSensor.isNotEmpty
                                  ? LevelSensorInConstant(
                                levelSensor: widget.levelSensor,
                                waterSource: widget.waterSource,
                              )
                                  : const Center(child: Text("Level Sensor Data not available"));

                            case "Finish":
                              return  FinishInConstant(
                                pumps: widget.pump,
                                valves: widget.valves,
                                ec: widget.ec,
                                ph: widget.ph,
                                fertilizerSite: widget.fertilizerSite,
                                controlSensors: widget.controlSensors,
                                irrigationLines: widget.irrigationLines,
                                mainValves: widget.mainValves,
                                generalUpdated: widget.generalUpdated,
                                alarm: widget.alarm,
                                controllerId: widget.controllerId,
                                userId: widget.userId,
                                levelSensor: widget.levelSensor,
                                moistureSensors: widget.moistureSensors,
                                waterMeter: widget.waterMeter,
                              );*/

                                  default:
                                    return Center(
                                        child: Text(
                                            "${item.parameter} Data not available"));
                                }
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  floatingActionButton: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MaterialButton(
                        color: Colors.green,
                        textColor: Colors.white,
                        onPressed: () {
                          vm.saveConstantData(context, customerId, controllerId, userId);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

}
