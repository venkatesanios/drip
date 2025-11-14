import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../models/customer/sensor_hourly_data_model.dart';
import '../../../models/customer/site_model.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/my_function.dart';
import 'float_switch_popover.dart';

class ValveWidgetMobile extends StatefulWidget {
  final ValveModel valve;
  final int customerId, controllerId, modelId;

  const ValveWidgetMobile({
    super.key,
    required this.valve,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
  });

  @override
  State<ValveWidgetMobile> createState() => _ValveWidgetMobileState();
}

class _ValveWidgetMobileState extends State<ValveWidgetMobile> {
  final Map<String, List<SensorHourlyData>> _sensorCache = {};

  final Set<String> _loadingSensors = {};

  @override
  Widget build(BuildContext context) {
    final valve = widget.valve;

    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getValveOnOffStatus(
        [...AppConstants.ecoGemModelList].contains(widget.modelId)
            ? double.parse(valve.sNo.toString()).toStringAsFixed(3)
            : valve.sNo.toString(),
      ),
      builder: (_, status, __) {
        final statusParts = status?.split(',') ?? [];
        if (statusParts.isNotEmpty) {
          valve.status = int.tryParse(statusParts[1]) ?? valve.status;
        }

        final bool hasMoisture = valve.moistureSensors.isNotEmpty;
        final bool hasWaterSource = valve.waterSources.isNotEmpty;

        return hasWaterSource
            ? _buildWithSource(valve, hasMoisture)
            : _buildWithoutSource(valve, hasMoisture);
      },
    );
  }


  Widget _buildWithSource(ValveModel valve, bool hasMoisture) {
    return SizedBox(
      width: 140,
      height: 60,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 70, height: 60, child: _buildValveIcon(valve, hasMoisture)),
          SizedBox(width: 70, height: 60, child: _buildWaterSource(valve)),
        ],
      ),
    );
  }

  Widget _buildWithoutSource(ValveModel valve, bool hasMoisture) {
    return SizedBox(width: 70, height: 60, child: _buildValveIcon(valve, hasMoisture));
  }

  Widget _buildValveIcon(ValveModel valve, bool hasMoisture) {
    final Color valveColor = _valveColor(valve.status);

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                'assets/png/m_valve_grey.png',
                color: valveColor,
              ),
            ),
            Text(
              valve.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
        if (hasMoisture) _buildMoistureButton(valve),
      ],
    );
  }

  Color _valveColor(int status) {
    if (status == 0) return Colors.grey;
    if (status == 1) return Colors.green;
    if (status == 2) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMoistureButton(ValveModel valve) {
    final sensor = valve.moistureSensors.first;
    final sensorId = sensor.sNo.toString();

    return Positioned(
      top: 12,
      left: 40,
      child: TextButton(
        onPressed: () async {
          if (!_sensorCache.containsKey(sensorId) && !_loadingSensors.contains(sensorId)) {
            _loadingSensors.add(sensorId);
            try {
              final all = await fetchSensorData();
              final list = getSensorDataById(sensorId, all);
              _sensorCache[sensorId] = list;
            } catch (e) {
              debugPrint('Error fetching sensor data for $sensorId: $e');
              _sensorCache[sensorId] = []; // avoid retry flood
            } finally {
              _loadingSensors.remove(sensorId);
            }
          }

          final sensorDataList = _sensorCache[sensorId] ?? [];

          _showMoisturePopover(context, valve, sensorDataList);
        },
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          minimumSize: WidgetStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: CircleAvatar(
          radius: 15,
          backgroundColor: _getMoistureColor(valve.moistureSensors
              .map((s) => {'name': s.name, 'value': s.value}).toList()),
          child: Image.asset('assets/png/moisture_sensor.png', width: 25, height: 25),
        ),
      ),
    );
  }

  void _showMoisturePopover(BuildContext context, ValveModel valve, List<SensorHourlyData> sensorDataList) {
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
        name: valve.moistureSensors[0].name,
      ),
    ];

    showPopover(
      context: context,
      bodyBuilder: (context) {
        return Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                SizedBox(width: 100, height: 100, child: _buildRadialGauge(valve)),
                Padding(padding: const EdgeInsets.only(left: 8, right: 8), child: Container(width: 1, height: 110, color: Colors.black12)),
                _buildCalendar(),
              ],
            ),
            SizedBox(
              width: 550,
              height: 175,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(text: valve.moistureSensors[0].name, textStyle: const TextStyle(fontSize: 12)),
                  majorGridLines: const MajorGridLines(width: 0),
                  axisLine: const AxisLine(width: 0),
                  labelStyle: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
                primaryYAxis: const NumericAxis(
                  labelStyle: TextStyle(fontSize: 11, color: Colors.black54),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: series,
              ),
            )
          ],
        );
      },
      direction: PopoverDirection.bottom,
      width: 550,
      height: 310,
      arrowHeight: 15,
      arrowWidth: 30,
      barrierColor: Colors.black54,
      arrowDyOffset: -40,
    );
  }

  Widget _buildRadialGauge(ValveModel valve) {
    double needleValue = 0.0;
    try {
      needleValue = double.parse(valve.moistureSensors[0].value.toString());
    } catch (_) {
      needleValue = 0.0;
    }

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 200,
          pointers: <GaugePointer>[
            NeedlePointer(value: needleValue, needleEndWidth: 3, needleColor: Colors.black54),
            const RangePointer(
              value: 200.0,
              width: 0.30,
              sizeUnit: GaugeSizeUnit.factor,
              color: Color(0xFF494CA2),
              animationDuration: 1000,
              gradient: SweepGradient(
                colors: <Color>[Colors.tealAccent, Colors.orangeAccent, Colors.redAccent, Colors.redAccent],
                stops: <double>[0.15, 0.50, 0.70, 1.00],
              ),
              enableAnimation: true,
            ),
          ],
          showFirstLabel: false,
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Text(valve.moistureSensors[0].value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              angle: 90,
              positionFactor: 0.8,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildCalendar() {
    return SizedBox(
      width: 415,
      height: 132,
      child: TableCalendar(
        focusedDay: DateTime.now(),
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        calendarFormat: CalendarFormat.week,
        availableCalendarFormats: const {CalendarFormat.week: 'Week'},
        onDaySelected: (selectedDay, focusedDay) {
          // keep original debug print
          debugPrint("Selected: $selectedDay");
        },
      ),
    );
  }

  Widget _buildWaterSource(ValveModel valve) {

    final source = valve.waterSources[0];
    final bool hasLevel = source.level.isNotEmpty;
    final bool hasFloatSwitch = source.floatSwitches.isNotEmpty;

    final ValueNotifier<int> popoverUpdateNotifier = ValueNotifier<int>(0);

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 45, height: 30, child: AppConstants.getAsset('source', 0, 'After Valve')),
            Text(
              source.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.black54),
            ),
          ],
        ),
        if (hasLevel) ...[
          _buildLevelIndicator(source, 1),
          _buildLevelIndicator(source, 2),
        ],

        if (hasFloatSwitch) FloatSwitchPopover(source: source,
            popoverUpdateNotifier: popoverUpdateNotifier, isMobile: true),
      ],
    );
  }

  Widget _buildLevelIndicator(dynamic source, int index) {
    final double top = index == 1 ? 1.0 : 17.0;
    final double left = index == 2 ? 35.0 : 2.0;

    return Positioned(
      top: top,
      left: left,
      right: 2,
      child: Consumer<MqttPayloadProvider>(
        builder: (_, provider, __) {
          final sensorUpdate = provider.getSensorUpdatedValve(source.level[0].sNo.toString());
          final statusParts = sensorUpdate?.split(',') ?? [];

          if (statusParts.length > index) {
            source.level.first.value = statusParts[index];
          }

          final text = index == 1
              ? (MyFunction().getUnitByParameter(context, 'Level Sensor', source.level.first.value.toString()) ?? '')
              : '${source.level.first.value}%';

          return Container(
            height: 17,
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(index == 1 ? 2 : 3),
              border: Border.all(color: Colors.grey, width: 0.5),
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }


  Color _getMoistureColor(List<Map<String, dynamic>> sensors) {
    if (sensors.isEmpty) return Colors.grey;

    final values = sensors.map((ms) => double.tryParse((ms['value'] ?? '0').toString()) ?? 0.0).toList();

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
        "userId": widget.customerId,
        "controllerId": widget.controllerId,
        "fromDate": date,
        "toDate": date,
      };

      final response = await Repository(HttpService()).fetchSensorHourlyData(body);
      if (response.statusCode == 200) {
        debugPrint(response.body);
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          sensors = (jsonData['data'] as List).map((item) {
            final dateStr = item['date'] ?? '';
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

            return SensorHourlyDataModel(date: item['date'], data: hourlyDataMap);
          }).toList();
        }
      }
    } catch (error) {
      debugPrint('Error fetching sensor hourly data: $error');
    }

    return sensors;
  }

  List<SensorHourlyData> getSensorDataById(String sensorId, List<SensorHourlyDataModel> sensorData) {
    final result = <SensorHourlyData>[];
    for (final model in sensorData) {
      model.data.forEach((hour, sensorList) {
        result.addAll(sensorList.where((sensor) => sensor.sensorId == sensorId));
      });
    }
    return result;
  }
}