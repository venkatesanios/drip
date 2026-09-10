import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../models/customer/sensor_hourly_data_model.dart';
import '../../../models/customer/site_model.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';

class PressureSensorPopover extends StatefulWidget {
  final ValveModel valve;
  final int customerId;
  final int controllerId;
  final String sensorType; // 'input' or 'lateral' — decides which list to open with

  const PressureSensorPopover({
    super.key,
    required this.valve,
    required this.customerId,
    required this.controllerId,
    this.sensorType = 'input',
  });

  @override
  State<PressureSensorPopover> createState() => _PressureSensorPopoverState();
}

class _PressureSensorPopoverState extends State<PressureSensorPopover> {
  final ScrollController _scrollController = ScrollController();
  DateTime selectedDate = DateTime.now();
  List<SensorHourlyDataModel> sensors = [];

  // Currently selected sensor's sNo (as String) for display
  String? selectedSensorSNo;

  List<PressureSensor> get _pressureList => widget.sensorType == 'lateral'
      ? widget.valve.lateralPressure
      : widget.valve.inputPressure;

  @override
  void initState() {
    super.initState();

    if (_pressureList.isNotEmpty) {
      selectedSensorSNo = _pressureList.first.sNo.toString();
    }

    fetchSensorData(selectedDate, selectedDate);
  }

  Color _getColorForPressure(double value) {
    if (value <= 10) {
      return Colors.red;
    } else if (value <= 20) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  PressureSensor? get _selectedSensor {
    if (_pressureList.isEmpty) return null;
    return _pressureList.firstWhere(
          (s) => s.sNo.toString() == selectedSensorSNo,
      orElse: () => _pressureList.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pressureList = _pressureList;

    if (pressureList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No Pressure Sensor Available'),
        ),
      );
    }

    final sensor = _selectedSensor!;

    final sensorDataList = getSensorDataById(
      sensor.sNo.toString(),
      sensors,
    );

    final List<CartesianSeries<dynamic, String>> series = [
      LineSeries<SensorHourlyData, String>(
        dataSource: sensorDataList,
        xValueMapper: (data, _) => data.hour,
        yValueMapper: (data, _) {
          return double.tryParse(data.value.toString()) ?? 0.0;
        },
        markerSettings: const MarkerSettings(isVisible: true),
        color: Colors.blueAccent,
        name: sensor.name,
      ),
    ];

    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getSensorUpdatedValve(sensor.sNo.toString()),
      builder: (_, status, __) {
        final statusParts = status?.split(',') ?? [];
        if (statusParts.length > 1) {
          sensor.value = statusParts[1];
        }

        final double pressureValue = double.tryParse(sensor.value.toString()) ?? 0.0;
        final Color gaugeColor = _getColorForPressure(pressureValue);

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 10, bottom: 6),
                  child: Text(
                    widget.sensorType == 'lateral' ? 'Lateral Pressure' : 'Input Pressure',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),

                // Sensor selector chips — only shown if more than one sensor in this list
                if (pressureList.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: pressureList.map((s) {
                        final isSelected = s.sNo.toString() == selectedSensorSNo;
                        return ChoiceChip(
                          label: Text(
                            s.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Theme.of(context).primaryColor,
                          onSelected: (_) {
                            setState(() {
                              selectedSensorSNo = s.sNo.toString();
                            });
                            fetchSensorData(selectedDate, selectedDate);
                          },
                        );
                      }).toList(),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 10, bottom: 6),
                  child: Text(
                    sensor.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: SfRadialGauge(
                        axes: [
                          RadialAxis(
                            minimum: 0,
                            maximum: 50,
                            ranges: [
                              GaugeRange(
                                startValue: 0,
                                endValue: 10,
                                color: Colors.red,
                                startWidth: 0.30,
                                endWidth: 0.30,
                                sizeUnit: GaugeSizeUnit.factor,
                              ),
                              GaugeRange(
                                startValue: 10,
                                endValue: 20,
                                color: Colors.orange,
                                startWidth: 0.30,
                                endWidth: 0.30,
                                sizeUnit: GaugeSizeUnit.factor,
                              ),
                              GaugeRange(
                                startValue: 20,
                                endValue: 50,
                                color: Colors.green,
                                startWidth: 0.30,
                                endWidth: 0.30,
                                sizeUnit: GaugeSizeUnit.factor,
                              ),
                            ],
                            pointers: [
                              NeedlePointer(
                                value: pressureValue,
                                needleEndWidth: 3,
                                needleColor: Colors.black54,
                              ),
                            ],
                            showFirstLabel: false,
                            axisLabelStyle: const GaugeTextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            annotations: [
                              GaugeAnnotation(
                                widget: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      sensor.value.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: gaugeColor,
                                      ),
                                    ),
                                    const Text(
                                      'bar',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                angle: 90,
                                positionFactor: 0.8,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 1,
                        height: 110,
                        color: Colors.black12,
                      ),
                    ),
                    SizedBox(
                      width: 415,
                      height: 132,
                      child: buildCommonCalendar(context),
                    ),
                  ],
                ),
                SizedBox(
                  width: 550,
                  height: 175,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                        text: sensor.name,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: series,
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCommonCalendar(BuildContext context) {
    return TableCalendar(
      focusedDay: selectedDate,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      calendarFormat: CalendarFormat.week,
      availableCalendarFormats: const {
        CalendarFormat.week: 'Week',
      },
      selectedDayPredicate: (day) {
        return isSameDate(day, selectedDate);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          selectedDate = selectedDay;
        });
        fetchSensorData(selectedDate, selectedDate);
      },
      enabledDayPredicate: (day) {
        return !day.isAfter(DateTime.now());
      },
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(color: Colors.white),
        todayTextStyle: const TextStyle(color: Colors.black),
      ),
    );
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<List<SensorHourlyDataModel>> fetchSensorData(DateTime fromDate, DateTime toDate) async {
    try {
      final from = DateFormat('yyyy-MM-dd').format(fromDate);
      final to = DateFormat('yyyy-MM-dd').format(toDate);
      final body = {
        "userId": widget.customerId,
        "controllerId": widget.controllerId,
        "fromDate": from,
        "toDate": to,
      };
      final response = await Repository(HttpService()).fetchSensorHourlyData(body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          sensors = (jsonData['data'] as List).map((item) {
            final dateStr = item['date'];
            final Map<String, List<SensorHourlyData>> hourlyDataMap = {};
            item.forEach((key, value) {
              if (key == 'date') {
                return;
              }
              if (value is String && value.isNotEmpty) {
                final entries = value.split(';');
                hourlyDataMap[key] = entries
                    .map((entry) => SensorHourlyData.fromCsv(entry, key, dateStr))
                    .toList();
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
      debugPrint('Error fetching pressure sensor hourly data: $error');
    }
    if (mounted) {
      setState(() {});
    }
    return sensors;
  }

  List<SensorHourlyData> getSensorDataById(
      String sensorId,
      List<SensorHourlyDataModel> sensorData,
      ) {
    final result = <SensorHourlyData>[];
    for (final model in sensorData) {
      model.data.forEach((hour, sensorList) {
        result.addAll(sensorList.where((sensor) => sensor.sensorId == sensorId));
      });
    }
    return result;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}