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
  int? selectedIrrigationIndex;
  List<Valve> filteredValves = [];

  @override
  void initState() {
    super.initState();

    selectedIrrigationIndex = widget.irrigationLines.isNotEmpty ? 0 : null;

    if (widget.irrigationLines.isNotEmpty) {
      for (int i = 0; i < widget.irrigationLines.length; i++) {
        print("Irrigation Line ${i + 1} Valve Count: ${widget.irrigationLines[i].valves.length}");
      }
    } else {
      print("No irrigation lines available.");
    }

    if (selectedIrrigationIndex != null) {
      filterValves();
    }
  }



  void filterValves() {
    if (selectedIrrigationIndex == null) return;

    setState(() {
      // Get the selected irrigation line's valve list
      filteredValves = widget.irrigationLines[selectedIrrigationIndex!].valves;

      // Reset controllers with the new filtered valves
      nominalFlowControllers = List.generate(filteredValves.length, (index) {
        return TextEditingController(text: filteredValves[index].nominalFlow.toString());
      });

      fillUpDelays = filteredValves
          .map((valve) => parseTime(valve.fillUpDelay).toDouble())
          .toList();
    });
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
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.irrigationLines.length,
                itemBuilder: (context, index) {
                  bool isSelected = index == selectedIrrigationIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIrrigationIndex = index;
                        filterValves();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          widget.irrigationLines[index].name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Data Table for Valves
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                  rows: List.generate(filteredValves.length, (index) {
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          return index.isEven ? const Color(0xFFF6F6F6) : const Color(0xFFFDFDFD);
                        },
                      ),
                      cells: [
                        DataCell(Center(
                          child: Text(
                            filteredValves[index].name,
                            style: const TextStyle(color: Color(0xFF005B8D)),
                          ),
                        )),
                        DataCell(Center(child: getTextField(index))),
                        DataCell(Center(child: getTimePicker(index))),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
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
          filteredValves[index].nominalFlow = value.isNotEmpty ? value : "0";
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
          filteredValves[index].fillUpDelay = formatTime(totalSeconds);
        });
      },
    );
  }
}
