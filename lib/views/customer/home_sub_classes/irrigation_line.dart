import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/utils/my_function.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../Models/customer/sensor_hourly_data_model.dart';
import '../../../Models/customer/site_model.dart';
import '../../../utils/constants.dart';
import '../../../view_models/customer/irrigation_line_view_model.dart';

class DisplayIrrigationLine extends StatelessWidget {
  final List<IrrigationLineData>? lineData;
  final double pumpStationWith;
  final String currentLineName;
  final List<SensorHourlyDataModel> sensorsHourlyLog;

  const DisplayIrrigationLine({super.key, required this.lineData, required this.pumpStationWith, required this.currentLineName, required this.sensorsHourlyLog});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - pumpStationWith;

    return ChangeNotifierProvider(
      create: (_) => IrrigationLineViewModel(context, lineData, screenWidth),
      child: Consumer<IrrigationLineViewModel>(
        builder: (context, viewModel, _) {

          final List<Widget> valveWidgets = [
            for (var line in lineData!)
              if (currentLineName == 'All irrigation line' || line.name == currentLineName) ...[
                ...line.prsSwitch.map((psw) => SensorWidget(
                  sensor: psw,
                  sensorType: 'Pressure Switch',
                  imagePath: 'assets/png/pressure_switch.png',
                  sensorData: sensorsHourlyLog,
                )),
                ...line.pressureIn.map((psw) => SensorWidget(
                  sensor: psw,
                  sensorType: 'Pressure Sensor',
                  imagePath: 'assets/png/pressure_sensor.png',
                  sensorData: sensorsHourlyLog,
                )),
                ...line.waterMeter.map((wm) => SensorWidget(
                  sensor: wm,
                  sensorType: 'Water Meter',
                  imagePath: 'assets/png/water_meter.png',
                  sensorData: sensorsHourlyLog,
                )),
                ...line.valves.map((vl) => ValveWidget(
                  vl: vl,
                  status: vl.status,
                  userId: 0,
                  controllerId: 0,
                  moistureSensor: vl.moistureSensor!,
                )),
              ],
          ];

          int crossAxisCount = (screenWidth / 105).floor().clamp(1, double.infinity).toInt();
          int rowCount = (valveWidgets.length / crossAxisCount).ceil();
          double itemHeight = 75;
          double gridHeight = rowCount * (itemHeight + 5);


          return SizedBox(
            width: screenWidth,
            height: gridHeight+10,
            child: Column(
              children: [
                const Divider(height: 0, color: Colors.black12,),
                const Divider(height: 9, color: Colors.black12,),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.20,
                      mainAxisSpacing: 0.0,
                      crossAxisSpacing: 0.0,
                    ),
                    itemCount: valveWidgets.length,
                    itemBuilder: (context, index) {
                      return valveWidgets[index];
                    },
                  ),
                ),
              ],
            ),
          );

        },
      ),
    );
  }

  Widget buildValveWidget(String vName, int vStatus, bool isLastInRow, bool isLastItem) {
    return Stack(
      children: [
        SizedBox(
          width: 100,
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 10,
                child: VerticalDivider(thickness: 1, color: Colors.grey.shade400),
              ),
              SizedBox(
                width: 35,
                height: 35,
                child: AppConstants.getAsset('valve', vStatus, ''),
              ),
              const SizedBox(height: 4),
              Text(
                vName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SensorWidget extends StatelessWidget {
  final SensorModel sensor;
  final String sensorType;
  final String imagePath;
  final List<SensorHourlyDataModel> sensorData;

  const SensorWidget({
    super.key,
    required this.sensor,
    required this.sensorType,
    required this.imagePath,
    required this.sensorData,
  });

  @override
  Widget build(BuildContext context) {

    if(sensorType != 'Pressure Switch'){
      return Container(
        width: 150,
        margin: const EdgeInsets.only(left: 4, right: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 10,
              height: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  VerticalDivider(width: 0),
                  SizedBox(width: 4),
                  VerticalDivider(width: 0),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                width: 150,
                height: 17,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    MyFunction().getUnitByParameter(context, sensorType, sensor.value.toString()) ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {

                showPopover(
                  context: context,
                  bodyBuilder: (context) {
                    final sensorDataList = getSensorDataById(sensor.sNo.toString());

                    List<CartesianSeries<dynamic, String>> series = [
                      LineSeries<SensorHourlyData, String>(
                        dataSource: sensorDataList,
                        xValueMapper: (SensorHourlyData data, _) => data.hour,
                        yValueMapper: (SensorHourlyData data, _) {
                          try {
                            return double.parse(data.value);
                          } catch (_) {
                            return 0.0;
                          }
                        },
                        markerSettings: const MarkerSettings(isVisible: true),
                        dataLabelSettings: const DataLabelSettings(isVisible: false),
                        color: Colors.blueAccent,
                        name: sensor.name ?? 'Sensor',
                      ),
                    ];

                    return Row(
                      children: [
                        SizedBox(
                          width: 450,
                          height: 175,
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(
                              title: AxisTitle(
                                text: sensorType == 'Moisture Sensor'
                                    ? '${sensor.name}($sensorType) - Hours'
                                    : '${sensor.name} - Hours',
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              majorGridLines: const MajorGridLines(width: 0),
                              axisLine: const AxisLine(width: 0),
                              labelStyle: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            primaryYAxis: NumericAxis(
                              labelStyle: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: series,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: SfRadialGauge(
                            axes: <RadialAxis>[
                              RadialAxis(
                                minimum: 0,
                                maximum: sensorType=='Moisture Sensor'?200:sensorType=='Pressure Sensor'?12:100,
                                pointers: <GaugePointer>[
                                  NeedlePointer(
                                      value: double.parse(sensor.value),
                                      needleEndWidth: 3, needleColor: Colors.black54),
                                  RangePointer(
                                    value: sensorType=='Moisture Sensor'?200.0:100.0,
                                    width: 0.30,
                                    sizeUnit: GaugeSizeUnit.factor,
                                    color: const Color(0xFF494CA2),
                                    animationDuration: 1000,
                                    gradient: SweepGradient(
                                      colors: sensorType == "Water Meter" ? <Color>[
                                        Colors.teal.shade300,
                                        Colors.teal.shade400,
                                        Colors.teal.shade500,
                                        Colors.teal.shade600
                                      ]:
                                      <Color>[
                                        Colors.tealAccent,
                                        Colors.orangeAccent,
                                        Colors.redAccent,
                                        Colors.redAccent
                                      ],
                                      stops: const <double>[0.15, 0.50, 0.70, 1.00],
                                    ),
                                    enableAnimation: true,
                                  ),
                                ],
                                showFirstLabel: false,
                                annotations: <GaugeAnnotation>[
                                  GaugeAnnotation(
                                    widget: Text(
                                      sensor.value,
                                      style: const TextStyle(
                                          fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                    angle: 90,
                                    positionFactor: 0.8,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  onPop: () => print('Popover was popped!'),
                  direction: PopoverDirection.bottom,
                  width: 550,
                  height: 175,
                  arrowHeight: 15,
                  arrowWidth: 30,
                  barrierColor: Colors.black54,
                  arrowDyOffset: -20,
                );
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                minimumSize: WidgetStateProperty.all(Size.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: Image.asset(
                imagePath,
                width: 35,
                height: 35,
              ),
            ),
            Text(
              sensor.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
      );
    }
    return Container(
      width: 150,
      margin: const EdgeInsets.only(left: 4, right: 4),
      child: Column(
        children: [
          SizedBox(
            width: 150,
            height: 50,
            child: Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 32),
                  child: SizedBox(
                    width: 10,
                    height: 17,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        VerticalDivider(width: 0),
                        SizedBox(width: 3),
                        VerticalDivider(width: 0),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 30,
                  child: Image.asset(
                    imagePath,
                    width: 35,
                    height: 35,
                  ),
                ),
                Positioned(
                  top: 3,
                  left: 43,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.black45,
                    child: CircleAvatar(radius: 6, backgroundColor:sensor.value == '1'? Colors.redAccent:Colors.lightGreenAccent,),
                  ),
                ),
              ],
            ),
          ),
          Text(
            sensor.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          )
        ],
      ),
    );
  }

  String extractNumber(String input) {
    RegExp regex = RegExp(r'\d+\.?\d*');
    Match? match = regex.firstMatch(input);
    return match?.group(0) ?? '';
  }

  List<SensorHourlyData> getSensorDataById(String sensorId) {
    List<SensorHourlyData> result = [];

    for (final model in sensorData) {
      model.data.forEach((hour, sensorList) {
        for (final sensor in sensorList) {
          if (sensor.sensorId == sensorId) {
            result.add(sensor);
          }
        }
      });
    }

    return result;
  }


}

class ValveWidget extends StatelessWidget {
  final Valve vl;
  final int status, userId, controllerId;
  final List<MoistureSensorModel> moistureSensor;
  //final Map<String, List<SensorHourlyData>> sensorData;
  const ValveWidget({super.key, required this.vl, required this.status, required this.userId, required this.controllerId, required this.moistureSensor});

  @override
  Widget build(BuildContext context) {
    bool hasMoisture = moistureSensor.isNotEmpty;
    return Stack(
      children: [
        Container(
          width: 100,
          //color: Colors.grey,
          margin: const EdgeInsets.only(left: 2, right: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 150,
                height: 15,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VerticalDivider(width: 0),
                    SizedBox(width: 4),
                    VerticalDivider(width: 0),
                  ],
                ),
              ),
              Image.asset(
                width: 35,
                height: 35,
                status == 0
                    ? 'assets/png/valve_gray.png'
                    : status == 1
                    ? 'assets/png/valve_green.png'
                    : status == 2
                    ? 'assets/png/valve_orange.png'
                    : 'assets/png/valve_red.png',
              ),
              const SizedBox(height: 4),
              Text(
                vl.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
        if (hasMoisture)
          Positioned(
            top: 2,
            right: 15,
            child: TextButton(
              onPressed: () {
                showPopover(
                  context: context,
                  bodyBuilder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: moistureSensor.map((ms) {

                        return Container();

                        /*Map<String, dynamic> jsonData = jsonDecode(jsonEncode(sensorData));
                        Map<String, List<Map<String, dynamic>>> filteredData = {};

                        jsonData.forEach((key, value) {
                          var filteredList = (value as List)
                              .where((item) => item['sNo']==ms.sNo)
                              .toList();
                          if (filteredList.isNotEmpty) {
                            filteredData[key] = List<Map<String, dynamic>>.from(filteredList);
                          }
                        });

                        return Row(
                          children: [
                            SizedBox(
                              width: 450,
                              height: 175,
                              child: buildLineChart(context, filteredData, 'Moisture Sensor', ms.name, ms.moistureType!),
                            ),
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: SfRadialGauge(
                                axes: <RadialAxis>[
                                  RadialAxis(
                                    minimum: 0,
                                    maximum: 200,
                                    pointers: <GaugePointer>[
                                      NeedlePointer(
                                          value: double.parse(ms.value),
                                          needleEndWidth: 3, needleColor: Colors.black54),
                                      RangePointer(
                                        value: 200.0,
                                        width: 0.30,
                                        sizeUnit: GaugeSizeUnit.factor,
                                        color: const Color(0xFF494CA2),
                                        animationDuration: 1000,
                                        gradient: const SweepGradient(
                                          colors: <Color>[
                                            Colors.greenAccent,
                                            Colors.orangeAccent,
                                            Colors.redAccent,
                                            Colors.redAccent
                                          ],
                                          stops: <double>[0.15, 0.50, 0.70, 1.00],
                                        ),
                                        enableAnimation: true,
                                      ),
                                    ],
                                    showFirstLabel: false,
                                    annotations: <GaugeAnnotation>[
                                      GaugeAnnotation(
                                        widget: Text(
                                          '${ms.value} CB',
                                          style: const TextStyle(
                                              fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                        angle: 90,
                                        positionFactor: 0.8,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );*/
                      }).toList(),
                    );
                  },
                  onPop: () => print('Popover was popped!'),
                  direction: PopoverDirection.bottom,
                  width: 550,
                  height: moistureSensor.length * 175,
                  arrowHeight: 15,
                  arrowWidth: 30,
                  barrierColor: Colors.black54,
                  arrowDxOffset: 20,
                  arrowDyOffset: -43,
                );
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                minimumSize: WidgetStateProperty.all(Size.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: _getMoistureColor(moistureSensor
                    .map((sensor) => {'name': 'sensor.valveSNo', 'value': '0'})
                    .toList()),
                child: Image.asset(
                  'assets/png/moisture_sensor.png',
                  width: 25,
                  height: 25,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getMoistureColor(List<Map<String, dynamic>> sensors) {
    if (sensors.isEmpty) return Colors.grey;

    final values = sensors
        .map((ms) => double.tryParse(ms['value'] ?? '0') ?? 0.0)
        .toList();

    final averageValue = values.reduce((a, b) => a + b) / values.length;

    if (averageValue < 20) {
      return Colors.green.shade200;
    } else if (averageValue <= 60) {
      return Colors.orange.shade200;
    } else {
      return Colors.red.shade200;
    }
  }
}
