import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_table_2/data_table_2.dart';
import 'modal_in_constant.dart';

class MoistureSensorConstant extends StatefulWidget {
  MoistureSensorConstant({super.key, required this.moistureSensors});
  List<MoistureSensor> moistureSensors;

  @override
  State<MoistureSensorConstant> createState() => _MoistureSensorConstantState();
}

class _MoistureSensorConstantState extends State<MoistureSensorConstant> {
  Map<String, String> selectedDropdownValues = {};
  Map<String, String> textFieldValues = {};
  Map<String, TextEditingController> textFieldControllers = {};

  @override
  void dispose() {
    for (var controller in textFieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 800,
              border: TableBorder.all(color: Colors.brown),
              headingRowColor: MaterialStateProperty.all(const Color(0xFFFDFDFD)),

              columns: const [
                DataColumn(label: Text('Sensor')),
                DataColumn(label: Text('High Low')),
                DataColumn(label: Text('Units')),
                DataColumn(label: Text('Base')),
                DataColumn(label: Text('Minimum')),
                DataColumn(label: Text('Maximum')),
              ],
              rows: widget.moistureSensors.asMap().entries.map((entry) {
                int index = entry.key;
                MoistureSensor sensor = entry.value;

                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      return index.isEven ? const Color(0xFFF6F6F6) : const Color(0xFFFDFDFD);
                    },
                  ),
                  cells: [
                    DataCell(Text(sensor.name,style: const TextStyle(color: Color(0xFF005B8D)))),
                    DataCell(getDropdown(sensor.objectIds, 'highLow', ['-','Primary', 'Secondary'])),
                    DataCell(getDropdown(sensor.objectIds, 'units', ['Bar', 'dS/m'])),
                    DataCell(getDropdown(sensor.objectIds, 'base', ['Current', 'Voltage'])),
                    DataCell(getTextField(sensor.objectIds, 'min')),
                    DataCell(getTextField(sensor.objectIds, 'max')),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget getDropdown(int sensorId, String category, List<String> options) {
    String key = '${sensorId}_$category';
    selectedDropdownValues.putIfAbsent(key, () => options.first);

    return DropdownButtonFormField<String>(
      value: selectedDropdownValues[key],
      items: options.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
      onChanged: (value) {
        setState(() {
          selectedDropdownValues[key] = value!;
        });
      },
    );
  }

  Widget getTextField(int sensorId, String category) {
    String key = '${sensorId}_$category';
    textFieldControllers.putIfAbsent(
      key,
          () => TextEditingController(text: textFieldValues[key] ?? "0.0"),
    );

    return TextField(
      controller: textFieldControllers[key],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      onChanged: (value) {
        setState(() {
          textFieldValues[key] = value.isEmpty ? "0.0" : value;
        });
      },
    );
  }
}
