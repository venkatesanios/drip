import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'modal_in_constant.dart';

class PumpPage extends StatefulWidget {
  final List<Pump> pump;

  const PumpPage({super.key, required this.pump});

  @override
  State<PumpPage> createState() => _PumpPageState();
}

class _PumpPageState extends State<PumpPage> {
  late List<TextEditingController> pumpStationControllers;
  late List<TextEditingController> controlGemControllers;
  double defaultSize = 120;

  @override
  void initState() {
    super.initState();
    pumpStationControllers =
        List.generate(widget.pump.length, (index) => TextEditingController());
    controlGemControllers =
        List.generate(widget.pump.length, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in pumpStationControllers) {
      controller.dispose();
    }
    for (var controller in controlGemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50, bottom: 20, left: 50, right: 50),

        child: DataTable2(
          border: const TableBorder(
          top: BorderSide(color: Color(0xFFDFE0E1), width: 1),
          bottom: BorderSide(color: Color(0xFFDFE0E1), width: 1),
          left: BorderSide(color: Color(0xFFDFE0E1), width: 1),
          right: BorderSide(color: Color(0xFFDFE0E1), width: 1),
        ),
          columnSpacing: 12,
          headingRowColor: MaterialStateProperty.all(const Color(0xFFFDFDFD)),
         minWidth: 1020,
          columns: const [
            DataColumn(
              label: Align(
                alignment: Alignment.center,
                child: Text(
                  'Pump Name',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            DataColumn(
              label: Align(
                alignment: Alignment.center,
                child: Text(
                  'Pump Station',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
            DataColumn(
              label: Align(
                alignment: Alignment.center,
                child: Text(
                  'Control Gem',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),
          ],

          rows: List.generate(widget.pump.length, (index) {
            return DataRow(
              color: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return index.isEven ? Color(0xFFF6F6F6) : Color(0xFFFDFDFD) ; // Alternating row colors
                },
              ),
              cells: [
                DataCell(
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.pump[index].name ?? 'N/A',
                      style: const TextStyle(color: Color(0xFF005B8D)),
                    ),
                  ),
                ),
                DataCell(
                  Align(
                    alignment: Alignment.center,
                    child: Checkbox(
                      value: widget.pump[index].pumpStation,
            side: const BorderSide(color: Color(0xFF939398), width: 2), // Border color
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)),
                      onChanged: (bool? value) {
                        setState(() {
                          widget.pump[index].pumpStation = value ?? false;
                        });
                      },
                    ),
                  ),
                ),
                DataCell(
                  Align(
                    alignment: Alignment.center,
                    child: Checkbox(
                      value: widget.pump[index].controlGem,
                      side: const BorderSide(color: Color(0xFF939398), width: 2), // Border color
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onChanged: (bool? value) {
                        setState(() {
                          widget.pump[index].controlGem = value ?? false;
                        });
                      },
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
