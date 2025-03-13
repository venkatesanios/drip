import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';

import 'ConstantPageProvider/changeNotifier_constantProvider.dart';
import 'constant_tableChart/customTimepicker_in_const.dart';
import 'modal_in_constant.dart';

class CriticalAlarmInConstant extends StatefulWidget {
  final List<Alarm> alarm;

  const CriticalAlarmInConstant({super.key, required this.alarm});

  @override
  State<CriticalAlarmInConstant> createState() =>
      _CriticalAlarmInConstantState();
}

class _CriticalAlarmInConstantState extends State<CriticalAlarmInConstant> {
  late List<TextEditingController> thresholdControllers;
  late LinkedScrollControllerGroup _controllers;
  late ScrollController _horizontalController;
  late ScrollController _verticalController;

  final List<String> sensorOptions = [
    "Do Nothing",
    "Stop Irrigation",
    "Stop Fertilisation",
    "Skip Irrigation"
  ];

  List<String> onStatus = [];

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _horizontalController = _controllers.addAndGet();
    _verticalController = ScrollController();

    onStatus = List.generate(widget.alarm.length, (index) => 'Yes');

    var provider = Provider.of<ConstantProvider>(context, listen: false);

    if (provider.overAllAlarm.isEmpty) {
      for (int i = 0; i < widget.alarm.length; i++) {
        provider.overAllAlarm.add(AlarmNew.fromMap({
          'name': widget.alarm[i].name,
          'scanTime': '00:00:00',
          'AlarmOnStatus': 'No ',
          'Reset After irrigation': 'Do Nothing',
          'Auto Reset Duration': '00:00:00',
          'Threshold': '100',
          'unit': widget.alarm[i].unit,
          'type': 'Normal',
        }));
        provider.overAllAlarm.add(AlarmNew.fromMap({
          'name': widget.alarm[i].name,
          'scanTime': '00:00:00',
          'AlarmOnStatus': 'No',
          'Reset After irrigation': 'Do Nothing',
          'Auto Reset Duration': '00:00:00',
          'Threshold': '100',
          'unit': widget.alarm[i].unit,
          'type': 'Critical',
        }));
      }
    }

    thresholdControllers = List.generate(
      provider.overAllAlarm.length,
          (index) => TextEditingController(
        text: provider.overAllAlarm[index].threshold,
      ),
    );
  }


  @override
  void dispose() {
    for (var controller in thresholdControllers) {
      controller.dispose();
    }
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var overAllAlarm =
        Provider
            .of<ConstantProvider>(context, listen: false)
            .overAllAlarm;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Scrollbar(
            controller: _verticalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _verticalController,
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        _dataCell(const Text(
                            'Alarm Type', style: TextStyle(fontWeight: FontWeight
                            .bold))),
                        _dataCell(const Text(
                            'Scan Time', style: TextStyle(fontWeight: FontWeight
                            .bold))),
                        _dataCell(const Text('Alarm On Status',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                        _dataCell(const Text('Reset After Irrigation',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                        _dataCell(const Text('Auto Reset Duration',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                        _dataCell(const Text(
                            'Threshold', style: TextStyle(fontWeight: FontWeight
                            .bold))),
                        _dataCell(
                            const Text('Units', style: TextStyle(fontWeight: FontWeight
                                .bold))),
                      ],
                    ),
                    // Data Rows
                    ...overAllAlarm.map((alarm) {
                      int index = overAllAlarm.indexOf(alarm);
                      return Row(
                        children: [
                          _dataCell(Text(
                            alarm.name,
                            style: TextStyle(color: alarm.type == 'Normal'
                                ? Colors.blue
                                : Colors.red),
                          )),
                          _dataCell(
                              getTimePicker(index, "scanTime", null, alarm)),
                          _dataCell(
                            PopupMenuButton<String>(
                              onSelected: (String selectedValue) {
                                final provider = Provider.of<ConstantProvider>(
                                    context, listen: false);
                                provider.overAllAlarm[index]
                                    .resetAfterIrrigation = selectedValue;
                                sourceOnChange(selectedValue, index);
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  'Do Nothing',
                                  'Stop Irrigation',
                                  'Stop Fertigation',
                                  'Skip Irrigation'
                                ]
                                    .map((String value) =>
                                    PopupMenuItem<String>(
                                      value: value,
                                      height: 30,
                                      child: Text(value,
                                          style: const TextStyle(fontSize: 17)),
                                    ))
                                    .toList();
                              },
                              child: Center(
                                child: Text(
                                  alarm.resetAfterIrrigation,
                                  style: const TextStyle(
                                    decorationColor: Colors.black54,
                                    decorationThickness: 1.0,
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _dataCell(
                            PopupMenuButton<String>(
                              onSelected: (String selectedValue) {
                                final provider = Provider.of<ConstantProvider>(
                                    context, listen: false);
                                provider.overAllAlarm[index].alarmOnStatus =
                                    selectedValue;
                                sourceOnChange(selectedValue, index);
                              },
                              itemBuilder: (BuildContext context) {
                                return ['Yes', 'No']
                                    .map((String value) =>
                                    PopupMenuItem<String>(
                                      value: value,
                                      height: 30,
                                      child: Text(
                                          value, style: TextStyle(fontSize: 17)),
                                    ))
                                    .toList();
                              },
                              child: Center(
                                child: Text(
                                  alarm.alarmOnStatus,
                                  style: const TextStyle(
                                    decorationColor: Colors.black54,
                                    decorationThickness: 1.0,
                                    fontSize: 17,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _dataCell(getTimePicker(
                              index, "autoResetDuration", null, alarm)),
                          _dataCell(editableTableCell(index, "threshold", alarm)),
                          _dataCell(Text(
                            alarm.unit,
                            style: TextStyle(color: alarm.type == 'Normal'
                                ? Colors.black87
                                : Colors.red),
                          )),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
    Widget _dataCell(Widget child) => Container(
      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
      color: Colors.white,
      width: 130,
      height: 50,
      alignment: Alignment.center,
      child: child,
    );


  Widget getTimePicker(int index, String field, double? initialSeconds, AlarmNew alarm) {
    final provider = Provider.of<ConstantProvider>(context, listen: false);

    return CustomTimePicker(
      index: index,
      initialMinutes: _convertTimeToMinutes(
          field == "scanTime"
              ? provider.overAllAlarm[index].scanTime
              : provider.overAllAlarm[index].autoResetDuration
      ),
      onTimeSelected: (int hours, int minutes, int seconds) {
        String selectedValue = "${hours.toString().padLeft(2, '0')}:"
            "${minutes.toString().padLeft(2, '0')}:"
            "${seconds.toString().padLeft(2, '0')}";

        print("🟡 Updating $field to $selectedValue");

        provider.updateTime(index, field, selectedValue);

        setState(() {});  // Force UI to refresh
      },
    );
  }

  double _convertTimeToMinutes(String time) {
    List<String> parts = time.split(':');

    if (parts.length != 3) return 0.0; // Prevent invalid format issues

    int hours = int.tryParse(parts[0]) ?? 0;
    int minutes = int.tryParse(parts[1]) ?? 0;
    int seconds = int.tryParse(parts[2]) ?? 0;

    return (hours * 60) + minutes + (seconds / 60);
  }


  Widget editableTableCell(int index, String field, AlarmNew alarm) {
    final provider = Provider.of<ConstantProvider>(context, listen: false);

    return SizedBox(
      width: 100,
      height: 50,
      child: TextField(
        controller: thresholdControllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          setState(() {
            alarm.threshold = value;
            provider.overAllAlarm[index].threshold = value;
          });
        },
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }

  void sourceOnChange(String source, int index) {
    setState(() {
      onStatus[index] = source;
    });
  }
}
