import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

import '../../../../StateManagement/mqtt_payload_provider.dart';
import '../../../../models/customer/sensor_hourly_data_model.dart';
import '../../../../models/customer/site_model.dart';
import '../../../../repository/repository.dart';
import '../../../../services/http_service.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/my_function.dart';
import '../../../customer/widgets/float_switch_popover.dart';
import '../../../customer/widgets/moisture_sensor_popover.dart';

class ValveWidget extends StatelessWidget {
  final ValveModel valve;
  final int customerId, controllerId, modelId;
  final bool isLastValve;
  const ValveWidget({super.key, required this.valve, required this.customerId,
    required this.controllerId, required this.isLastValve, required this.modelId});

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getValveOnOffStatus([...AppConstants.ecoGemModelList].contains(modelId) ?
      double.parse(valve.sNo.toString()).toStringAsFixed(3): valve.sNo.toString()),
      builder: (_, status, __) {


        final statusParts = status?.split(',') ?? [];
        if(statusParts.isNotEmpty){
          valve.status = int.parse(statusParts[1]);
        }

        bool hasMoisture = valve.moistureSensors.isNotEmpty;
        bool hasWaterSource = valve.waterSources.isNotEmpty;
        final ValueNotifier<int> popoverUpdateNotifier = ValueNotifier<int>(0);


        return hasWaterSource ? SizedBox(
          width: 140,
          height: 100,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: AppConstants.getAsset('valve_cws', valve.status, ''),
                        ),
                        Text(
                          valve.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ),
                    if (hasMoisture)
                      Positioned(
                        top: 20,
                        left: 33,
                        child: TextButton(
                          onPressed: () async {
                            final sensors = await fetchSensorData();

                            showPopover(
                              context: context,
                              bodyBuilder: (context) {
                                return MoistureSensorPopover(valve: valve, sensors: sensors);
                              },
                              direction: PopoverDirection.bottom,
                              width: 580,
                              height: 700,
                              arrowHeight: 15,
                              arrowWidth: 30,
                              barrierColor: Colors.black54,
                              arrowDyOffset: -40,
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
                            backgroundColor: _getMoistureColor(
                              valve.moistureSensors
                                  .map((sensor) => {'name': sensor.name, 'value': sensor.value})
                                  .toList(),
                            ),
                            child: Image.asset(
                              'assets/png/moisture_sensor.png',
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 70,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: AppConstants.getAsset('source', 0, 'After Valve'),
                        ),
                        Text(
                          valve.waterSources[0].name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ),
                    if (valve.waterSources[0].level.isNotEmpty) ...[
                      Positioned(
                        top: 20,
                        left: 2,
                        right: 2,
                        child: Consumer<MqttPayloadProvider>(
                          builder: (_, provider, __) {
                            final sensorUpdate = provider.getSensorUpdatedValve(valve.waterSources[0].level[0].sNo.toString());
                            final statusParts = sensorUpdate?.split(',') ?? [];

                            if (statusParts.length > 1) {
                              valve.waterSources[0].level.first.value = statusParts[1];
                            }

                            return Container(
                              height: 17,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: Colors.grey, width: 0.5),
                              ),
                              child: Center(
                                child: Text(
                                  MyFunction().getUnitByParameter(context, 'Level Sensor', valve.waterSources[0].level.first.value.toString()) ?? '',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 43,
                        left: 18,
                        right: 18,
                        child: Consumer<MqttPayloadProvider>(
                          builder: (_, provider, __) {
                            final sensorUpdate = provider.getSensorUpdatedValve(valve.waterSources[0].level[0].sNo.toString());
                            final statusParts = sensorUpdate?.split(',') ?? [];

                            if (statusParts.length > 2) {
                              valve.waterSources[0].level.first.value = statusParts[2];
                            }

                            return Container(
                              height: 17,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey, width: 0.5),
                              ),
                              child: Center(
                                child: Text(
                                  '${valve.waterSources[0].level.first.value}%',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );

                          },
                        ),
                      ),
                    ],

                    if (valve.waterSources.isNotEmpty) FloatSwitchPopover(source: valve.waterSources[0],
                        popoverUpdateNotifier: popoverUpdateNotifier, isMobile: false),
                  ],
                ),
              )
            ],
          ),
        ):
        SizedBox(
          width: 70,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: AppConstants.getAsset(isLastValve? 'valve_lj' : 'valve', valve.status, ''),
                  ),
                  Text(
                    valve.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
              if (hasMoisture)
                Positioned(
                  top: 20,
                  left: 33,
                  child: TextButton(
                    onPressed: () async {
                      final sensors = await fetchSensorData();

                      showPopover(
                        context: context,
                        bodyBuilder: (context) {
                          return MoistureSensorPopover(valve: valve, sensors: sensors);
                        },
                        direction: PopoverDirection.bottom,
                        width: 580,
                        height: 340,
                        arrowHeight: 15,
                        arrowWidth: 30,
                        barrierColor: Colors.black54,
                        arrowDyOffset: -40,
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
                      backgroundColor: _getMoistureColor(
                        valve.moistureSensors
                            .map((sensor) => {'name': sensor.name, 'value': sensor.value})
                            .toList(),
                      ),
                      child: Image.asset(
                        'assets/png/moisture_sensor.png',
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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

  Future<List<SensorHourlyDataModel>> fetchSensorData() async {
    List<SensorHourlyDataModel> sensors = [];

    try {
      DateTime selectedDate = DateTime.now();
      String date = DateFormat('yyyy-MM-dd').format(selectedDate);

      Map<String, Object> body = {
        "userId": customerId,
        "controllerId": controllerId,
        "fromDate": date,
        "toDate": date,
      };

      final response = await Repository(HttpService()).fetchSensorHourlyData(body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          sensors = (jsonData['data'] as List).map((item) {
            final dateStr = item['date'];
            final Map<String, List<SensorHourlyData>> hourlyDataMap = {};

            item.forEach((key, value) {
              if (key == 'date') return;
              if (value is String && value.isNotEmpty) {
                final entries = value.split(';');
                hourlyDataMap[key] = entries.map((entry) {
                  return SensorHourlyData.fromCsv(entry, key, dateStr);
                }).toList();
              } else {
                hourlyDataMap[key] = [];
              }
            });

            return SensorHourlyDataModel(
              date: item['date'],
              data: hourlyDataMap,
            );
          }).toList();
        }
      }
    } catch (error) {
      debugPrint('Error fetching sensor hourly data: $error');
    }

    return sensors;
  }
}