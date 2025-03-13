import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

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
  late LinkedScrollControllerGroup _controllers;
  late ScrollController _verticalScroll;
  late ScrollController _horizontalScroll;
  double defaultSize = 120;

  Map<int, SensorData> sensorDataMap = {};

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _verticalScroll = _controllers.addAndGet();
    _horizontalScroll = ScrollController();

    for (var sensor in widget.levelSensor) {
      sensorDataMap[sensor.sensorId] = SensorData();
    }

    print("Level Sensors: ${widget.levelSensor}");
    print("Total Level Sensors: ${widget.levelSensor.length}");
  }


  @override
  void dispose() {
    _verticalScroll.dispose();
    _horizontalScroll.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _horizontalScroll,
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSensorColumn(),
                buildDataTable(),
              ],
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
          controller: _verticalScroll, // Fixed issue here
          child: Column(
            children: widget.levelSensor.map((sensor) {
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
        // Header Row
        SizedBox(
          width: 900,
          height: 50,
          child: SingleChildScrollView(
            controller: _horizontalScroll,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                getCell(width: 120, title: 'High Low'),
                getCell(width: 120, title: 'Units'),
                getCell(width: 120, title: 'Base'),
                getCell(width: 120, title: 'Minimum'),
                getCell(width: 120, title: 'Maximum'),
                getCell(width: 120, title: 'Height(m)'),
              ],
            ),
          ),
        ),
        SizedBox(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _verticalScroll,
              scrollDirection: Axis.vertical,
              child: Column(
                children: widget.levelSensor.isNotEmpty
                    ? widget.levelSensor.map((sensor) {
                  return SizedBox(
                    width: 900,
                    child: Row(
                      children: [
                        getDropdown(sensor.sensorId),
                        getDropdown(sensor.sensorId),
                        getDropdown(sensor.sensorId),
                        getTextField(sensor.sensorId),
                        getTextField(sensor.sensorId),
                        getTextField(sensor.sensorId),
                      ],
                    ),
                  );
                }).toList()
                    : [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("No Sensors Available",
                        style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
            ),
          ),
        ),

      ],
    );
  }


  Widget getDropdown(int sensorId) {
    return Container(
      margin: const EdgeInsets.all(1),
      width: 119,
      height: 50,
      alignment: Alignment.center,
      child: DropdownButtonFormField<String>(
        value: sensorDataMap[sensorId]?.dropdownValue ?? 'Option 1',
        items: ['Option 1', 'Option 2', 'Option 3']
            .map((value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        ))
            .toList(),
        onChanged: (value) {
          setState(() {
            sensorDataMap[sensorId]?.dropdownValue = value!;
          });
        },
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
    );
  }

  Widget getTextField(int sensorId) {
    return Container(
      margin: const EdgeInsets.all(1),
      width: 119,
      height: 50,
      alignment: Alignment.center,
      child: TextField(
        controller: sensorDataMap[sensorId]?.controller ?? TextEditingController(),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        onChanged: (value) {
          setState(() {
            sensorDataMap[sensorId]?.textValue = value.isNotEmpty ? value : '0';
            sensorDataMap[sensorId]?.controller.text =
                sensorDataMap[sensorId]?.textValue ?? '';
          });
        },
      ),
    );
  }

  Widget getCell({required double width, required String title}) {
    return Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.blue.shade100,
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
class SensorData {
  String dropdownValue;
  String textValue;
  TextEditingController controller;

  SensorData({
    this.dropdownValue = 'Option 1',
    this.textValue = '',
  }) : controller = TextEditingController(text: textValue);
}
