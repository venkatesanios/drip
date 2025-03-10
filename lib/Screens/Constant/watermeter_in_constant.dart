import 'package:flutter/material.dart';

import 'modal_in_constant.dart';

class WatermeterInConstant extends StatefulWidget {
  final List<WaterMeter> waterMeter;
  final List<IrrigationLine> irrigationLines;
  final List<Pump> pump;

  const WatermeterInConstant({super.key, required this.waterMeter, required this.irrigationLines, required this.pump});

  @override
  State<WatermeterInConstant> createState() => _WatermeterInConstantState();
}

class _WatermeterInConstantState extends State<WatermeterInConstant> {
  final ScrollController _horizontalScroll = ScrollController();
  final ScrollController _verticalScroll = ScrollController();

  late List<TextEditingController> ratioControllers;

  @override
  void initState() {
    super.initState();
    print("WaterMeter List Length: ${widget.waterMeter.length}");
    ratioControllers = List.generate(widget.waterMeter.length, (index) {
      return TextEditingController(
          text: widget.waterMeter[index].ratio?.toString() ?? '0');
    });
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
      body: widget.waterMeter.isEmpty
          ? const Center(
        child: Text(
          "No water meter available",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Scrollbar(
          controller: _horizontalScroll, // Attach the correct controller
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _horizontalScroll, // Assign the same controller
            child: Scrollbar(
              controller: _verticalScroll, // Add vertical Scrollbar
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: _verticalScroll,
                child: buildTable(),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget buildTable() {
    return DataTable(
      border: TableBorder.all(color: Colors.grey, width: 0.5),
      columns: [
        buildHeaderColumn(widget.waterMeter.isNotEmpty
            ? widget.waterMeter[0].objectName ?? "Water Meters"
            : "Water Meters"),
        buildHeaderColumn("Ratio (I/pulse)"),
      ],
      rows: List.generate(widget.waterMeter.length, (index) {
        final meter = widget.waterMeter[index];

        return DataRow(cells: [
          DataCell(Text(meter.name)),
          DataCell(editableTableCell(ratioControllers[index])),
        ]);
      }),
    );
  }

  DataColumn buildHeaderColumn(String title) {
    return DataColumn(
      label: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: const Color(0xffD3EBEE),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  Widget editableTableCell(TextEditingController controller) {
    return Container(
      width: 130,
      height: 50,
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}
