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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 1000,
            headingRowHeight: 40,
            headingRowColor: WidgetStateProperty.all(Colors.teal.shade300),
            border: TableBorder.all(),
            columns: const [
              DataColumn(label: Text("Irrigation Line")),
              DataColumn(label: Text("Low Flow Delay")),
              DataColumn(label: Text("High Flow Delay")),
              DataColumn(label: Text("Low Flow Action")),
              DataColumn(label: Text("High Flow Action")),
            ],
            rows: List.generate(widget.irrigationLines.length, (index) {
              final irrigationLine = widget.irrigationLines[index];

              return DataRow(cells: [
                DataCell(Text(irrigationLine.name)),
                DataCell(getTimePicker(index, "lowFlowDelay", parseTime(irrigationLine.lowFlowDelay).toDouble())),
                DataCell(getTimePicker(index, "highFlowDelay", parseTime(irrigationLine.highFlowDelay).toDouble())),
                DataCell(getDropdown(index, "lowFlowAction", irrigationLine.lowFlowAction ?? 'Ignore')),
                DataCell(getDropdown(index, "highFlowAction", irrigationLine.highFlowAction ?? 'Ignore')),
              ]);
            }),
          ),
        ),
      ),
    );
  }

  Widget getTimePicker(int index, String field, double? initialSeconds) {
    return CustomTimePicker(
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
    );
  }

  Widget getDropdown(int index, String field, String initialValue) {
    return DropdownButtonFormField<String>(
      value: actionOptions.contains(initialValue) ? initialValue : actionOptions.last,
      items: actionOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
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
    );
  }
}
