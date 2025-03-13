import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'modal_in_constant.dart';

class MoistureSensorConstant extends StatefulWidget {
  MoistureSensorConstant({super.key, required this.moistureSensors});
  List<MoistureSensor> moistureSensors;

  @override
  State<MoistureSensorConstant> createState() => _MoistureSensorConstantState();
}

class _MoistureSensorConstantState extends State<MoistureSensorConstant> {
  late LinkedScrollControllerGroup _scrollableVertical;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollableHorizontal;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  double defaultSize = 120;

  Map<String, String> selectedDropdownValues = {};
  Map<String, String> textFieldValues = {};

  @override
  void initState() {
    super.initState();
    _scrollableVertical = LinkedScrollControllerGroup();
    _verticalScroll1 = _scrollableVertical.addAndGet();
    _verticalScroll2 = _scrollableVertical.addAndGet();
    _scrollableHorizontal = LinkedScrollControllerGroup();
    _horizontalScroll1 = _scrollableHorizontal.addAndGet();
    _horizontalScroll2 = _scrollableHorizontal.addAndGet();
  }

  @override
  void dispose() {
    _verticalScroll1.dispose();
    _verticalScroll2.dispose();
    _horizontalScroll1.dispose();
    _horizontalScroll2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 50,),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSensorColumn(),
                  buildDataTable(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSensorColumn() {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(color: Color(0xff96CED5)),
          padding: const EdgeInsets.only(left: 8),
          width: defaultSize,
          height: 50,
          alignment: Alignment.center,
          child: const Text('Sensor',
              style: TextStyle(color: Color(0xff30555A), fontSize: 13)),
        ),
        SingleChildScrollView(
          controller: _verticalScroll1,
          child: Column(
            children: widget.moistureSensors.map((sensor) {
              return Container(
                margin: const EdgeInsets.only(bottom: 1),
                decoration: const BoxDecoration(color: Colors.white),
                padding: const EdgeInsets.only(left: 8),
                width: defaultSize,
                height: 50,
                alignment: Alignment.center,
                child: Text(sensor.name,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildDataTable() {
    return Column(
      children: [
        SizedBox(
          width: 800,
          height: 50,
          child: SingleChildScrollView(
            controller: _horizontalScroll1,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                getCell(width: 122, title: 'High Low'),
                getCell(width: 121, title: 'Units'),
                getCell(width: 121, title: 'Base'),
                getCell(width: 121, title: 'Minimum'),
                getCell(width: 121, title: 'Maximum'),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 800,
          child: SingleChildScrollView(
            controller: _horizontalScroll2,
            scrollDirection: Axis.horizontal,
            child: Scrollbar(
              thumbVisibility: true,
              controller: _verticalScroll2,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: _verticalScroll2,
                child: Column(
                  children: widget.moistureSensors.map((sensor) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        getDropdown(sensor.objectIds,['Primary','Secondary']),
                        getDropdown(sensor.objectIds,['Bar', 'dS/m']),
                        getDropdown(sensor.objectIds, ['Current', 'Voltage']),
                        getTextField(sensor.objectIds),
                        getTextField(sensor.objectIds),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget getDropdown(int sensorId, List<String> options) {
    // Ensure the selected value is set and valid
    selectedDropdownValues.putIfAbsent(sensorId.toString(), () {
      return options.isNotEmpty ? options.first : ""; // Ensure non-nullable return
    });

    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
      color: Colors.white,
      width: 120,
      height: 50,
      alignment: Alignment.center,
      child: DropdownButtonFormField<String>(
        value: options.contains(selectedDropdownValues[sensorId.toString()])
            ? selectedDropdownValues[sensorId.toString()]
            : (options.isNotEmpty ? options.first : ""),
        items: options
            .map((value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedDropdownValues[sensorId.toString()] = value!;
          });
        },
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    );
  }



  Widget getCell({required double width, required String title}) {
    return Container(
      width: width,
      height: 50,
      alignment: Alignment.center,
      color: const Color(0xff96CED5), // Light blue header
      child: Text(
        title,
        style: const TextStyle(color: Color(0xff30555A), fontWeight: FontWeight.bold),
      ),
    );
  }


  Widget getTextField(int sensorId) {
    TextEditingController controller = TextEditingController(
      text: textFieldValues[sensorId.toString()] ?? "0.0",
    );

    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
      color: Colors.white,
      width: 120,
      height: 50,
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))], // Allows only numbers and decimals
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onChanged: (value) {
          setState(() {
            textFieldValues[sensorId.toString()] = value.isEmpty ? "0.0" : value;
          });
        },
      ),
    );
  }
}
