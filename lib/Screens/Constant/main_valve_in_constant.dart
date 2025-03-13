import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'constant_tableChart/customTimepicker_in_const.dart';
import 'modal_in_constant.dart';

class MainValveInConstant extends StatefulWidget {
  final List<MainValve> mainValves;
  final List<IrrigationLine> irrigationLines;

  const MainValveInConstant({super.key, required this.mainValves, required this.irrigationLines});

  @override
  State<MainValveInConstant> createState() => _MainValveInConstantState();
}

class _MainValveInConstantState extends State<MainValveInConstant> {
  List<String> actionOptions = ['No delay', 'Open before', 'Open after'];

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
        child: widget.mainValves.isEmpty
            ? const Text("No main valves available", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
            : Padding(
          padding: const EdgeInsets.all(26.0),
          child:DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 1000,
            headingRowHeight: 40,
            headingRowColor: WidgetStateProperty.all(Colors.teal.shade300),
            border: TableBorder.all(),
            columns: [
              DataColumn(label: Text(widget.mainValves[0].objectName)),
              DataColumn(label: Text("Mode")),
              DataColumn(label: Text("Delay")),
            ],
            rows: List.generate(widget.mainValves.length, (index) {
              final mainValve = widget.mainValves[index];

              return DataRow(cells: [
                DataCell(Text(mainValve.name)),
                DataCell(getDropdown(index, "mode", mainValve.mode)),
                DataCell(getTimePicker(index, "delay", parseTime(mainValve.delay).toDouble())),
              ]);
            }),
          ),
        ),
      ),
    );
  }

  Widget getDropdown(int index, String field, String initialValue) {
    return DropdownButtonFormField<String>(
      value: actionOptions.contains(initialValue) ? initialValue : actionOptions.first,
      items: actionOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            if (field == "mode") {
              widget.mainValves[index].mode = value;
            }
          });
        }
      },
    );
  }

  Widget getTimePicker(int index, String field, double? initialMinutes) {
    return CustomTimePicker(
      index: index,
      initialMinutes: initialMinutes ?? 0.0,
      onTimeSelected: (int hours, int minutes, int seconds) {
        setState(() {
          double newValue = (hours * 60 + minutes).toDouble();
          if (field == "lowFlowDelay") {
            widget.irrigationLines[index].lowFlowDelay = newValue as String;
          } else if (field == "highFlowDelay") {
            widget.irrigationLines[index].highFlowDelay = newValue as String;
          }
        });
      },
    );
  }
}
