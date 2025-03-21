import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_table_2/data_table_2.dart';

import 'modal_in_constant.dart';

class WatermeterInConstant extends StatefulWidget {
  final List<WaterMeters> waterMeter;

  const WatermeterInConstant({
    super.key,
    required this.waterMeter,
  });

  @override
  State<WatermeterInConstant> createState() => _WatermeterInConstantState();
}

class _WatermeterInConstantState extends State<WatermeterInConstant> {
  late List<TextEditingController> ratioControllers;

  @override
  void initState() {
    super.initState();
    ratioControllers = widget.waterMeter
        .map((meter) => TextEditingController(text: meter.ratio.toString()))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in ratioControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50, bottom: 20, left: 80, right: 80),

        child: DataTable2(
          border: const TableBorder(
            top: BorderSide(color: Color(0xFFDFE0E1), width: 1),
            bottom: BorderSide(color: Color(0xFFDFE0E1), width: 1),
            left: BorderSide(color: Color(0xFFDFE0E1), width: 1),
            right: BorderSide(color: Color(0xFFDFE0E1), width: 1),
          ),
          columnSpacing: 12,
          minWidth: 1020,
          headingRowHeight: 50,
          dataRowHeight: 50,
          headingRowColor: MaterialStateProperty.all(const Color(0xFFFDFDFD)),
          columns: const [
            DataColumn(
              label: Center(
                child: Text(
                  "Water Meters",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            DataColumn(
              label: Center(
                child: Text(
                  "Ratio (I/pulse)",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],
          rows: List<DataRow>.generate(
            widget.waterMeter.length,
                (index) {
              final meter = widget.waterMeter[index];
              return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                    return index.isEven ? Color(0xFFF6F6F6) : Color(0xFFFDFDFD) ; // Alternating row colors
                  },
                ),
                cells: [
                  DataCell(
                    Center(
                      child: Text(meter.name, style: const TextStyle(color: Color(0xFF005B8D)),
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: TextField(
                        controller: ratioControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(border: InputBorder.none),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
