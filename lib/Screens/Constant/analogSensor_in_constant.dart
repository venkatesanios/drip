import 'package:flutter/material.dart';

class AnalogSensorInConstant extends StatefulWidget {
  final List<AnalogSensor> analogSensors; // Corrected data type

  const AnalogSensorInConstant({
    Key? key,
    required this.analogSensors,
  }) : super(key: key);

  @override
  State<AnalogSensorInConstant> createState() => _AnalogSensorInConstantState();
}

class _AnalogSensorInConstantState extends State<AnalogSensorInConstant> {
  final ScrollController _horizontalScroll = ScrollController();
  late List<TextEditingController> nominalFlowControllers;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    nominalFlowControllers = List.generate(widget.analogSensors.length, (index) {
      return TextEditingController(
        text: widget.analogSensors[index].nominalFlow.toString(),
      );
    });
  }

  @override
  void dispose() {
    for (var controller in nominalFlowControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _horizontalScroll,
          child: buildTable(),
        ),
      ),
    );
  }

  Widget buildTable() {
    return DataTable(
      headingRowColor: MaterialStateProperty.all(const Color(0xffD3EBEE)),
      headingTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      border: TableBorder.all(color: Colors.grey, width: 0.5),
      columns: const [
        DataColumn(label: Text("Analog Sensor Name", style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: widget.analogSensors.asMap().entries.map((entry) {
        final int index = entry.key;
        final AnalogSensor sensor = entry.value;

        return DataRow(cells: [
          DataCell(Text(sensor.name)),
          DataCell(getTextField(index)),
        ]);
      }).toList(),
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
            widget.analogSensors[index].nominalFlow = double.tryParse(value) ?? 0.0;
          });
        },
      ),
    );
  }
}

// Example Model for AnalogSensor
class AnalogSensor {
  String name;
  double nominalFlow;

  AnalogSensor({required this.name, required this.nominalFlow});
}
