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
          border: const TableBorder(
            top: BorderSide(color: Color(0xFFDFE0E1), width: 1),
            bottom: BorderSide(color: Color(0xFFDFE0E1), width: 1),
            left: BorderSide(color: Color(0xFFDFE0E1), width: 1),
            right: BorderSide(color: Color(0xFFDFE0E1), width: 1),
          ),
          headingRowColor: MaterialStateProperty.all(const Color(0xFFFDFDFD)),
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 1200,
          columns: const [
            DataColumn(label: Center(child: Text('Irrigation Line',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)))),
            DataColumn(label: Center(child: Text('Low Flow Delay',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)))),
            DataColumn(label: Center(child: Text('High Flow Delay',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)))),
            DataColumn(label: Center(child: Text('Low Flow Action',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)))),
            DataColumn(label: Center(child: Text('High Flow Action',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,)))),
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
    Color actionColor = getColorForAction(initialValue); // Get dynamic color

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 55),
        child: DropdownButtonFormField<String>(
          value: actionOptions.contains(initialValue) ? initialValue : actionOptions.last,
          items: actionOptions.map((String value) {
            Color itemColor = getColorForAction(value); // Get color for each item

            return DropdownMenuItem<String>(
              value: value,
              child: SizedBox(
                width: 80,
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
                    const SizedBox(width: 6),
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
                if (field == "lowFlowAction") {
                  widget.irrigationLines[index].lowFlowAction = value;
                } else if (field == "highFlowAction") {
                  widget.irrigationLines[index].highFlowAction = value;
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
    if (value == "Do Next") {
      return const Color(0xFF006FD6);
    } else if (value == "Wait") {
      return const Color(0xFFE97B17);
    } else {
      return const Color(0xFFE53292);
    }
  }
}