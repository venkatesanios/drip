import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
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
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          border: TableBorder.all(),
          headingRowColor: MaterialStateProperty.all(const Color(0xFFFDFDFD)), // White header row
          columns: const [
            DataColumn(
              label: Center(
                child: Text(
                  'Main Valve',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            DataColumn(
              label: Center(
                child: Text(
                  'Mode',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            DataColumn(
              label: Center(
                child: Text(
                  'Delay',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],

          rows: widget.mainValves.map((mainValve) {
            int index = widget.mainValves.indexOf(mainValve);
            return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    return index.isEven ? const Color(0xFFF6F6F6) : Color(0xFFFDFDFD) ; // Alternating row colors
                  },
                ),
                cells: [
                  DataCell(Center(child: Text(mainValve.name,style: const TextStyle(color: Color(0xFF005B8D)),))),
                  DataCell(Center(child: getDropdown(index, "mode", mainValve.mode))),
                  DataCell(Center(child: getTimePicker(index, "delay", parseTime(mainValve.delay).toDouble()))),
                ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget getDropdown(int index, String field, String initialValue) {
    return Center(
      child: DropdownButtonFormField<String>(
        value: actionOptions.contains(initialValue) ? initialValue : actionOptions.first,
        items: actionOptions.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, textAlign: TextAlign.center),
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
      ),
    );
  }

  Widget getTimePicker(int index, String field, double? initialSeconds) {
    return Center(
      child: CustomTimePicker(
        index: index,
        initialMinutes: (initialSeconds ?? 0.0) / 60,
        onTimeSelected: (int hours, int minutes, int seconds) {
          setState(() {
            widget.mainValves[index].delay = "${hours.toString().padLeft(2, '0')}:"
                "${minutes.toString().padLeft(2, '0')}:"
                "${seconds.toString().padLeft(2, '0')}";
          });
        },
      ),
    );
  }
}
