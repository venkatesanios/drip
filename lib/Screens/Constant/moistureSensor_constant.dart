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
  final List<String> highLowOptions = ['-', 'Primary', 'Secondary'];
  final List<String> unitOptions = ['Bar', 'dS/m'];
  final List<String> baseOptions = ['Current', 'Voltage'];

  late List<TextEditingController> minControllers;
  late List<TextEditingController> maxControllers;

  @override
  void initState() {
    super.initState();
    minControllers = List.generate(widget.moistureSensors.length,
            (index) => TextEditingController(text: widget.moistureSensors[index].min.toString()));
    maxControllers = List.generate(widget.moistureSensors.length,
            (index) => TextEditingController(text: widget.moistureSensors[index].max.toString()));
  }

  @override
  void dispose() {
    for (var controller in minControllers) {
      controller.dispose();
    }
    for (var controller in maxControllers) {
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
            child: DataTable2(
              border: const TableBorder(
                top: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                bottom: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                left: BorderSide(color: Color(0xFFDFE0E1), width: 1),
                right: BorderSide(color: Color(0xFFDFE0E1), width: 1),
              ),
              columnSpacing: 12,
              minWidth: 1020,
              headingRowColor: MaterialStateProperty.all(const Color(0xFFFDFDFD)),
              columns: const [
                DataColumn(label: Text('Sensor',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                DataColumn(label: Text('High Low',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                DataColumn(label: Text('Units',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                DataColumn(label: Text('Base',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                DataColumn(label: Text('Minimum',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
                DataColumn(label: Text('Maximum',style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,))),
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
                    DataCell(Text(sensor.name, style: const TextStyle(color: Color(0xFF005B8D)))),
                    DataCell(getDropdown(index, 'highLow', sensor.highLow, highLowOptions,)),
                    DataCell(getDropdown(index, 'units', sensor.units, unitOptions)),
                    DataCell(getDropdown(index, 'base', sensor.base, baseOptions)),
                    DataCell(getTextField(index, 'min')),
                    DataCell(getTextField(index, 'max')),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget getTextField(int index, String field) {
    return SizedBox(
      width: 50,
      child: TextField(
        textAlign: TextAlign.center,
        controller: field == 'min' ? minControllers[index] : maxControllers[index],
        keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          setState(() {
            if (field == 'min') {
              widget.moistureSensors[index].min = value.isNotEmpty ? double.parse(value) : 0.0;
            } else {
              widget.moistureSensors[index].max = value.isNotEmpty ? double.parse(value) : 0.0;
            }
          });
        },
      ),
    );
  }

  Widget getDropdown(int index, String field, String initialValue, List<String> options) {
    return SizedBox(
      width: 120, // Adjust the width as needed
      child: DropdownButtonFormField<String>(
        value: options.contains(initialValue) ? initialValue : options.first,
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.normal)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              if (field == "highLow") {
                widget.moistureSensors[index].highLow = value;
              } else if (field == "units") {
                widget.moistureSensors[index].units = value;
              } else if (field == "base") {
                widget.moistureSensors[index].base = value;
              }
            });
          }
        },
        decoration: const InputDecoration(border: InputBorder.none),
        icon: const SizedBox.shrink(),
      ),
    );
  }
}
