import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'constant_tableChart/customTimepicker_in_const.dart';
import 'modal_in_constant.dart';

class IrrigationLineInConstant extends StatefulWidget {
  final List<IrrigationLine> irrigationLines;

  const IrrigationLineInConstant({super.key, required this.irrigationLines});

  @override
  State<IrrigationLineInConstant> createState() => _IrrigationLineInConstantState();
}

class _IrrigationLineInConstantState extends State<IrrigationLineInConstant> {
  List<String> actionOptions = ['Ignore', 'Do Next', 'Wait'];

  int parseTime(String time) {
    List<String> parts = time.split(":");
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
        child: DataTable2(
          border: TableBorder.all(),
          headingRowColor: MaterialStateProperty.all(const Color(0xFFFDFDFD)),
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          columns: const [
            DataColumn(label: Center(child: Text('Irrigation Line'))),
            DataColumn(label: Center(child: Text('Low Flow Delay'))),
            DataColumn(label: Center(child: Text('High Flow Delay'))),
            DataColumn(label: Center(child: Text('Low Flow Action'))),
            DataColumn(label: Center(child: Text('High Flow Action'))),
          ],

          rows: List.generate(widget.irrigationLines.length, (index) {
            var line = widget.irrigationLines[index];
            return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    return index.isEven ? Color(0xFFF6F6F6) : Color(0xFFFDFDFD) ; // Alternating row colors
                  },
                ),
                cells: [
              DataCell(Center(child: Text(line.name,style: const TextStyle(color: Color(0xFF005B8D)),))), // Center text
              DataCell(Center(child: getTimePicker(index, "lowFlowDelay", parseTime(line.lowFlowDelay).toDouble()))), // Center widget
              DataCell(Center(child: getTimePicker(index, "highFlowDelay", parseTime(line.highFlowDelay).toDouble()))),
              DataCell(Center(child: getDropdown(index, "lowFlowAction", line.lowFlowAction ?? 'Ignore'))),
              DataCell(Center(child: getDropdown(index, "highFlowAction", line.highFlowAction ?? 'Ignore'))),
            ]);
          }),

        ),
      ),
    );
  }

  Widget getTimePicker(int index, String field, double? initialSeconds) {
    return Center(
      child: CustomTimePicker(
        index: index,
        initialMinutes: initialSeconds ?? 0.0,
        onTimeSelected: (int hours, int minutes, int seconds) {
          setState(() {
            String newValue = "${hours.toString().padLeft(2, '0')}:"
                "${minutes.toString().padLeft(2, '0')}:"
                "${seconds.toString().padLeft(2, '0')}";

            if (field == "lowFlowDelay") {
              widget.irrigationLines[index].lowFlowDelay = newValue;
            } else if (field == "highFlowDelay") {
              widget.irrigationLines[index].highFlowDelay = newValue;
            }
          });
        },
      ),
    );
  }

  Widget getDropdown(int index, String field, String initialValue) {
    return Center(
      child: DropdownButtonFormField<String>(
        value: actionOptions.contains(initialValue) ? initialValue : actionOptions.last,
        items: actionOptions.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              if (field == "lowFlowAction") {
                widget.irrigationLines[index].lowFlowAction = value;
              } else if (field == "highFlowAction") {
                widget.irrigationLines[index].highFlowAction = value;
              }
            });
          }
        },
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

}