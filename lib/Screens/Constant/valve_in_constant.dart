import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'constant_tableChart/customTimepicker_in_const.dart';
import 'modal_in_constant.dart';

class ValveInConstant extends StatefulWidget {
  const ValveInConstant({super.key, required this.valves, required this.irrigationLines});

  final List<Valve> valves;
  final List<IrrigationLine> irrigationLines;

  @override
  State<ValveInConstant> createState() => _ValveInConstantState();
}

class _ValveInConstantState extends State<ValveInConstant> {
  final ScrollController _horizontalScroll = ScrollController();
  late List<TextEditingController> nominalFlowControllers;
  late List<double> fillUpDelays;

  @override
  void initState() {
    super.initState();
    nominalFlowControllers = List.generate(widget.valves.length, (index) {
      return TextEditingController(
        text: widget.valves[index].nominalFlow.toString(),
      );
    });

    fillUpDelays = widget.valves
        .map((valve) => parseTime(valve.fillUpDelay))
        .map((seconds) => seconds.toDouble())
        .toList();
  }

  @override
  void dispose() {
    for (var controller in nominalFlowControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  int parseTime(String time) {
    List<String> parts = time.split(":");
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    return (hours * 3600) + (minutes * 60) + seconds;
  }

  String formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0,left: 20,right: 20),
        child: Center(
          child:DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 600,
            headingRowHeight: 40,
            headingRowColor: WidgetStateProperty.all(Colors.teal.shade300),
            border: TableBorder.all(),
            columns: const [
              DataColumn(label: Text("Valve Name")),
              DataColumn(label: Text("Nominal Flow (I/hr)")),
              DataColumn(label: Text("Fill Up Delay")),
            ],
            rows: widget.valves.asMap().entries.map((entry) {
              final int index = entry.key;
              final Valve valve = entry.value;

              return DataRow(cells: [
                DataCell(Text(valve.name)),
                DataCell(getTextField(index)),
                DataCell(getTimePicker(index)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget getTextField(int index) {
    return SizedBox(
      width: 80,
      child: TextField(
        controller: nominalFlowControllers[index],
        keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onChanged: (value) {
          setState(() {
            widget.valves[index].nominalFlow = value.isNotEmpty ? value : "0";
          });
        },
      ),
    );
  }

  Widget getTimePicker(int index) {
    return CustomTimePicker(
      index: index,
      initialMinutes: fillUpDelays[index],
      onTimeSelected: (int hours, int minutes, int seconds) {
        setState(() {
          int totalSeconds = hours * 3600 + minutes * 60 + seconds;
          fillUpDelays[index] = totalSeconds.toDouble();
          widget.valves[index].fillUpDelay = formatTime(totalSeconds);
        });
      },
    );
  }
}
