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
          border: const TableBorder(

            top: BorderSide(color: Color(0xFFDFE0E1), width: 1),
            bottom: BorderSide(color: Color(0xFFDFE0E1), width: 1),
            left: BorderSide(color: Color(0xFFDFE0E1), width: 1),
            right: BorderSide(color: Color(0xFFDFE0E1), width: 1),
          ),
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 1020,
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


  Widget getDropdown(int index, String field, String initialValue) {
    Color actionColor = getColorForAction(initialValue); // Get dynamic color

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 110),
        child: DropdownButtonFormField<String>(
          value: actionOptions.contains(initialValue) ? initialValue : actionOptions.last,
          items: actionOptions.map((String value) {
            Color itemColor = getColorForAction(value); // Get color for each item

            return DropdownMenuItem<String>(
              value: value,
              child: SizedBox(
                width: 110,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 12.29,
                      height: 12.29,
                      decoration: BoxDecoration(
                        color: itemColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: itemColor,
                      ),
                    ),
                  ],
                ),
              ),
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
          icon: const SizedBox.shrink(),
          decoration: InputDecoration(
            filled: true,
            fillColor: actionColor.withOpacity(0.2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: actionColor,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: actionColor,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: actionColor,
                width: 2,
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Color getColorForAction(String value) {
    if (value == "No delay") {
      return const Color(0xFF6A6A6A);
    } else if (value == "Open before") {
      return const Color(0xFF006FD6);
    } else {
      return const Color(0xFF14AD5B);
    }
  }
}

