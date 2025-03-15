import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_table_2/data_table_2.dart';

import 'modal_in_constant.dart';

class LevelSensorInConstant extends StatefulWidget {
  final List<LevelSensor> levelSensor;
  final List<WaterSource> waterSource;

  const LevelSensorInConstant({
    super.key,
    required this.levelSensor,
    required this.waterSource,
  });

  @override
  State<LevelSensorInConstant> createState() => _LevelSensorInConstantState();
}

class _LevelSensorInConstantState extends State<LevelSensorInConstant> {
  Map<int, SensorData> sensorDataMap = {};
  Map<String, String> selectedDropdownValues = {};

  @override
  void initState() {
    super.initState();
    for (var sensor in widget.levelSensor) {
      sensorDataMap[sensor.sensorId] = SensorData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:50, left: 20, right: 20),
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 900,
        border: TableBorder.all(color: Colors.brown),
        headingRowColor: MaterialStateProperty.all(const Color(0xFFFDFDFD)),

        columns: const [
          DataColumn(label: Text('Sensor')),
          DataColumn(label: Text('High Low')),
          DataColumn(label: Text('Units')),
          DataColumn(label: Text('Base')),
          DataColumn(label: Text('Minimum')),
          DataColumn(label: Text('Maximum')),
          DataColumn(label: Text('Height (m)')),
        ],
        rows: widget.levelSensor.asMap().entries.map((entry) {
          int index = entry.key;
          LevelSensor sensor = entry.value;

          return DataRow(
            color: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                return index.isEven ? const Color(0xFFF6F6F6) : const Color(0xFFFDFDFD);
              },
            ),
            cells: [
              DataCell(Text(sensor.name, style: const TextStyle(color: Color(0xFF005B8D)))),
              DataCell(getDropdown(sensor.sensorId, ['-','Primary', 'Secondary'])),
              DataCell(getDropdown(sensor.sensorId, ['Bar', 'dS/m'])),
              DataCell(getDropdown(sensor.sensorId, ['Current', 'Voltage'])),
              DataCell(getTextField(sensor.sensorId, 'min')),
              DataCell(getTextField(sensor.sensorId, 'max')),
              DataCell(getTextField(sensor.sensorId, 'height')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget getDropdown(int sensorId, List<String> options) {
    selectedDropdownValues.putIfAbsent(sensorId.toString(), () => options.first);

    return DropdownButtonFormField<String>(
      value: options.contains(selectedDropdownValues[sensorId.toString()])
          ? selectedDropdownValues[sensorId.toString()]
          : options.first,
      items: options.map((value) => DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      )).toList(),
      onChanged: (value) {
        setState(() {
          selectedDropdownValues[sensorId.toString()] = value!;
        });
      },
    );
  }

  Widget getTextField(int sensorId, String fieldType) {
    final sensorData = sensorDataMap[sensorId]!;
    TextEditingController controller;

    switch (fieldType) {
      case 'min':
        controller = sensorData.minController;
        break;
      case 'max':
        controller = sensorData.maxController;
        break;
      case 'height':
        controller = sensorData.heightController;
        break;
      default:
        controller = TextEditingController();
    }

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
    );
  }
}

class SensorData {
  final TextEditingController minController;
  final TextEditingController maxController;
  final TextEditingController heightController;

  SensorData()
      : minController = TextEditingController(text: "0.0"),
        maxController = TextEditingController(text: "0.0"),
        heightController = TextEditingController(text: "0.0");
}
