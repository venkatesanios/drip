import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
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
  late List<TextEditingController> nominalFlowControllers;
  late List<double> fillUpDelays;

  @override
  void initState() {
    super.initState();
    nominalFlowControllers = List.generate(widget.valves.length, (index) {
      return TextEditingController(text: widget.valves[index].nominalFlow.toString());
    });

    fillUpDelays = widget.valves
        .map((valve) => parseTime(valve.fillUpDelay).toDouble())
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
        padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
        child: DataTable2(
          columnSpacing: 12,
          minWidth: 600,
          border: TableBorder.all(),
          headingRowColor: MaterialStateProperty.all(const Color(0xFFFDFDFD)),

          columns: const [
            DataColumn(label: Center(child: Text('Valve Name'))),
            DataColumn(label: Center(child: Text('Nominal Flow (I/hr)'))),
            DataColumn(label: Center(child: Text('Fill Up Delay'))),
          ],
          rows: List.generate(widget.valves.length, (index) {
            return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    return index.isEven ? Color(0xFFF6F6F6) : Color(0xFFFDFDFD) ; // Alternating row colors
                  },
                ),
                cells: [
              DataCell(Center(child: Text(widget.valves[index].name,style: const TextStyle(color: Color(0xFF005B8D)),))),
              DataCell(Center(child: getTextField(index))),
              DataCell(Center(child: getTimePicker(index))),
            ]);
          }),
        ),
      ),
    );
  }

  Widget getTextField(int index) {
    return TextField(
      textAlign: TextAlign.center,
      controller: nominalFlowControllers[index],
      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
      onChanged: (value) {
        setState(() {
          widget.valves[index].nominalFlow = value.isNotEmpty ? value : "0";
        });
      },
    );
  }

  Widget getTimePicker(int index) {
    return CustomTimePicker(
      index: index,
      initialMinutes: fillUpDelays[index] / 60,
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
