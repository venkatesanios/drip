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
  late List<TextEditingController> minControllers;
  late List<TextEditingController> maxControllers;
  late List<TextEditingController> heightControllers;

  final List<String> highLowOptions = ['-', 'Primary', 'Secondary'];
  final List<String> unitOptions = ['Bar', 'dS/m'];
  final List<String> baseOptions = ['Current', 'Voltage'];
  @override
  void initState() {
    super.initState();

    minControllers = widget.levelSensor.map((sensor) => TextEditingController(text: sensor.min.toString())).toList();
    maxControllers = widget.levelSensor.map((sensor) => TextEditingController(text: sensor.max.toString())).toList();
    heightControllers = widget.levelSensor.map((sensor) => TextEditingController(text: sensor.height.toString())).toList();
  }

  @override
  void dispose() {
    for (var controller in minControllers) {
      controller.dispose();
    }
    for (var controller in maxControllers) {
      controller.dispose();
    }
    for (var controller in heightControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
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
              DataCell(getDropdown(index, 'highLow', sensor.highLow, highLowOptions)),
              DataCell(getDropdown(index, 'units', sensor.units, unitOptions)),
              DataCell(getDropdown(index, 'base', sensor.base, baseOptions)),
              DataCell(getTextField(index, 'min')),
              DataCell(getTextField(index, 'max')),
              DataCell(getTextField(index, 'height')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget getTextField(int index, String field) {
    TextEditingController controller;
    if (field == 'min') {
      controller = minControllers[index];
    } else if (field == 'max') {
      controller = maxControllers[index];
    } else {
      controller = heightControllers[index];
    }

    return TextField(
      textAlign: TextAlign.center,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      onChanged: (value) {
        setState(() {
          double parsedValue = value.isNotEmpty ? double.parse(value) : 0.0;

          if (field == 'min') {
            widget.levelSensor[index].min = parsedValue;
          } else if (field == 'max') {
            widget.levelSensor[index].max = parsedValue;
          } else if (field == 'height') {
            widget.levelSensor[index].height = parsedValue;
          }
        });
      },
    );
  }

  Widget getDropdown(int index, String field, String initialValue, List<String> options) {
    return DropdownButtonFormField<String>(
      value: options.contains(initialValue) ? initialValue : options.first,
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            if (field == "highLow") {
              widget.levelSensor[index].highLow = value;
            } else if (field == "units") {
              widget.levelSensor[index].units = value;
            } else if (field == "base") {
              widget.levelSensor[index].base = value;
            }
          });
        }
      },
      decoration: const InputDecoration(border: InputBorder.none),
    );
  }
}
