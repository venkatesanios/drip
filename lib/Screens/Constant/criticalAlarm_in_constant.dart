import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    onStatus = List.generate(widget.alarm.length, (index) => 'Yes');

    var provider = Provider.of<ConstantProvider>(context, listen: false);

    if (provider.overAllAlarm.isEmpty) {
      for (int i = 0; i < widget.alarm.length; i++) {
        provider.overAllAlarm.add(AlarmNew.fromMap({
          'name': widget.alarm[i].name,
          'scanTime': '00:00:00',
          'AlarmOnStatus': 'Yes',
          'Reset After irrigation': 'Do Nothing',
          'Auto Reset Duration': '00:00:00',
          'Threshold': '0',
          'unit': widget.alarm[i].unit,
          'type': 'Normal',
        }));
        provider.overAllAlarm.add(AlarmNew.fromMap({
          'name': widget.alarm[i].name,
          'scanTime': '00:00:00',
          'AlarmOnStatus': 'Yes',
          'Reset After irrigation': 'Do Nothing',
          'Auto Reset Duration': '00:00:00',
          'Threshold': '0',
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var overAllAlarm =
        Provider.of<ConstantProvider>(context, listen: false).overAllAlarm;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 20, left: 20, right: 20),
        child: DataTable2(
    border: const TableBorder(
    top: BorderSide(color: Color(0xFFDFE0E1), width: 1),
    bottom: BorderSide(color: Color(0xFFDFE0E1), width: 1),
    left: BorderSide(color: Color(0xFFDFE0E1), width: 1),
    right: BorderSide(color: Color(0xFFDFE0E1), width: 1),
    ),
          columnSpacing: 12,
          minWidth: 1020,
          headingRowHeight: 60,
          headingRowColor: MaterialStateProperty.all(const Color(0xFFFDFDFD)),
          columns: const [
            DataColumn2(label: Text('Alarm Type',style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal,)), size: ColumnSize.M),
            DataColumn2(label: Text('Scan Time',style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal,)), size: ColumnSize.S),
            DataColumn(label: Text('Alarm On Status',style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal,))),
            DataColumn(label: Text('Reset After Irrigation',style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal,))),
            DataColumn(label: Text('Auto Reset Duration',style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal,))),
            DataColumn(label: Text('Threshold',style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal,))),
            DataColumn(label: Text('Units',style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal,))),
          ],
          rows: List<DataRow>.generate(overAllAlarm.length, (index) {
            var alarm = overAllAlarm[index];
            return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    return index.isEven ? Color(0xFFF6F6F6) : Color(0xFFFDFDFD) ; // Alternating row colors
                  },
                ),

                cells: [
              DataCell(Text(
                alarm.name,
                style: TextStyle(color: alarm.type == 'Normal' ? Colors.green : Colors.red),
              )),
              DataCell(getTimePicker(index, "scanTime", null, alarm),),
              DataCell(
                PopupMenuButton<String>(
                  onSelected: (String selectedValue) {
                    final provider = Provider.of<ConstantProvider>(context, listen: false);
                    provider.overAllAlarm[index].resetAfterIrrigation = selectedValue;
                    sourceOnChange(selectedValue, index);
                  },
                  itemBuilder: (BuildContext context) {
                    return ['Do Nothing', 'Stop Irrigation', 'Stop Fertigation', 'Skip Irrigation']
                        .map((String value) => PopupMenuItem<String>(
                      value: value,
                      height: 30,
                      child: Row(
                        children: [
                          Container(
                            width: 12.29,
                            height: 12.29,
                            decoration: BoxDecoration(
                              color: getActionColor(value),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(value, style: const TextStyle(fontSize: 17)),
                        ],
                      ),
                    ))
                        .toList();
                  },
                  icon: null,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          overAllAlarm[index].resetAfterIrrigation,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                            decorationThickness: 1.0,
                            fontSize: 17,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12.29,
                          height: 12.29,
                          decoration: BoxDecoration(
                            color: getActionColor(overAllAlarm[index].resetAfterIrrigation),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              DataCell(
                PopupMenuButton<String>(
                  onSelected: (String selectedValue) {

                    final provider = Provider.of<ConstantProvider>(context, listen: false);
                    provider.overAllAlarm[index].alarmOnStatus = selectedValue;

                    sourceOnChange(selectedValue, index);

                  },
                  itemBuilder: (BuildContext context) {
                    return ['Yes', 'No']
                        .map((String value) => PopupMenuItem<String>(
                      value: value,
                      height: 30,
                      child: Text(value, style: TextStyle(fontSize: 17),),
                    )).toList();
                  },
                  icon: null,
                  child: Center(
                    child: Text(
                      overAllAlarm[index].alarmOnStatus,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.black,
                        decorationThickness: 1.0,
                        fontSize: 17,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
              DataCell(getTimePicker(index, "autoResetDuration", null, alarm),),
              DataCell(editableTableCell(index, "threshold", alarm)),
              DataCell(Text(
                alarm.unit,
                style: TextStyle(color: alarm.type == 'Normal' ? Colors.green : Colors.red),
              )),
            ]);
          }),
        ),
      ),
    );
  }

  Widget getTimePicker(int index, String field, double? initialSeconds, AlarmNew alarm) {
    final provider = Provider.of<ConstantProvider>(context, listen: false);

    return CustomTimePicker(
      index: index,
      initialMinutes: _convertTimeToMinutes(
          field == "scanTime" ? provider.overAllAlarm[index].scanTime : provider.overAllAlarm[index].autoResetDuration
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
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          setState(() {
            alarm.threshold = value;
            provider.overAllAlarm[index].threshold = value;
          });
        },
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
      ),
    );
  }

  void sourceOnChange(String source, int index) {
    setState(() {
      onStatus[index] = source;
    });
  }
  Color getActionColor(String value) {
    switch (value) {
      case "Do Nothing":
        return const Color(0xFF006FD6);
      case "Stop Irrigation":
        return const Color(0xFFF5F900);
      case "Stop Fertigation":
        return const Color(0xFFE01313);
      case "Skip Irrigation":
        return const Color(0xFF006FD6);
      default:
        return Colors.black54;
    }
  }


}
