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
import '../../../utils/my_function.dart';

/// Shows every sensor attached to a valve (moisture, soil temperature,
/// input pressure, lateral pressure) in one scrollable popover, each with
/// its own gauge + chart, and a chip selector when a section has more
/// than one sensor.
class ValveSensorsPopover extends StatefulWidget {
  final ValveModel valve;
  final int customerId, controllerId;

  /// Optional: 'moisture' | 'soilTemp' | 'inputPressure' | 'lateralPressure'
  /// Pass this when the user tapped a specific badge, so the popover
  /// opens already scrolled to that section.
  final String? initialSection;

  const ValveSensorsPopover({
    super.key,
    required this.valve,
    required this.customerId,
    required this.controllerId,
    this.initialSection,
  });

  @override
  State<ValveSensorsPopover> createState() => _ValveSensorsPopoverState();
}

class _ValveSensorsPopoverState extends State<ValveSensorsPopover> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _moistureKey = GlobalKey();
  final GlobalKey _soilTempKey = GlobalKey();
  final GlobalKey _inputPressureKey = GlobalKey();
  final GlobalKey _lateralPressureKey = GlobalKey();

  DateTime selectedDate = DateTime.now();
  List<SensorHourlyDataModel> sensors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSensorData(selectedDate, selectedDate).then((_) {
      if (widget.initialSection != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSection(widget.initialSection!));
      }
    });
  }

  void _scrollToSection(String section) {
    GlobalKey? key;
    switch (section) {
      case 'moisture':
        key = _moistureKey;
        break;
      case 'soilTemp':
        key = _soilTempKey;
        break;
      case 'inputPressure':
        key = _inputPressureKey;
        break;
      case 'lateralPressure':
        key = _lateralPressureKey;
        break;
    }
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valve = widget.valve;

    final hasMoisture = valve.moistureSensors.isNotEmpty;
    final hasSoilTemp = valve.soilTemperature.isNotEmpty;
    final hasInputPressure = valve.inputPressure.isNotEmpty;
    final hasLateralPressure = valve.lateralPressure.isNotEmpty;

    if (!hasMoisture && !hasSoilTemp && !hasInputPressure && !hasLateralPressure) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('No sensors available for this valve'),
        ),
      );
    }

    if (isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                valve.name,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            if (hasMoisture)
              _SensorSection(
                key: _moistureKey,
                title: 'Moisture',
                sensors: valve.moistureSensors,
                unitParam: 'Moisture Sensor',
                sensorData: sensors,
                gaugeMax: 200,
                gaugeType: _GaugeType.moisture,
              ),
            if (hasSoilTemp)
              _SensorSection(
                key: _soilTempKey,
                title: 'Soil Temperature',
                sensors: valve.soilTemperature,
                unitParam: 'Temperature',
                sensorData: sensors,
                gaugeMax: 60,
                gaugeType: _GaugeType.temperature,
              ),
            if (hasInputPressure)
              _SensorSection(
                key: _inputPressureKey,
                title: 'Input Pressure',
                sensors: valve.inputPressure,
                unitParam: 'Pressure Sensor',
                sensorData: sensors,
                gaugeMax: 50,
                gaugeType: _GaugeType.pressure,
              ),
            if (hasLateralPressure)
              _SensorSection(
                key: _lateralPressureKey,
                title: 'Lateral Pressure',
                sensors: valve.lateralPressure,
                unitParam: 'Pressure Sensor',
                sensorData: sensors,
                gaugeMax: 50,
                gaugeType: _GaugeType.pressure,
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> fetchSensorData(DateTime fromDate, DateTime toDate) async {
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
              if (key == 'date') return;
              if (value is String && value.isNotEmpty) {
                final entries = value.split(';');
                hourlyDataMap[key] = entries.map((entry) => SensorHourlyData.fromCsv(entry, key, dateStr)).toList();
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

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Widget buildCommonCalendar(BuildContext context, VoidCallback onChanged) {
    return TableCalendar(
      focusedDay: selectedDate,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      calendarFormat: CalendarFormat.week,
      availableCalendarFormats: const {CalendarFormat.week: 'Week'},
      selectedDayPredicate: (day) => _isSameDate(day, selectedDate),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() => selectedDate = selectedDay);
        setState(() => isLoading = true);
        fetchSensorData(selectedDate, selectedDate).then((_) => onChanged());
      },
      enabledDayPredicate: (day) => !day.isAfter(DateTime.now()),
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(color: Theme.of(context).primaryColorLight, shape: BoxShape.circle),
        todayDecoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
        selectedTextStyle: const TextStyle(color: Colors.white),
        todayTextStyle: const TextStyle(color: Colors.black),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

enum _GaugeType { moisture, temperature, pressure }

/// One section of the popover: a title, an optional chip selector when
/// there's more than one sensor of this type, a live gauge, and a chart.
///
/// Works generically across MoistureSensor / SoilTemperature / PressureSensor
/// models as long as each exposes `.sNo`, `.name`, and `.value`.
class _SensorSection extends StatefulWidget {
  final String title;
  final List<dynamic> sensors;
  final String unitParam;
  final List<SensorHourlyDataModel> sensorData;
  final double gaugeMax;
  final _GaugeType gaugeType;

  const _SensorSection({
    super.key,
    required this.title,
    required this.sensors,
    required this.unitParam,
    required this.sensorData,
    required this.gaugeMax,
    required this.gaugeType,
  });

  @override
  State<_SensorSection> createState() => _SensorSectionState();
}

class _SensorSectionState extends State<_SensorSection> {
  late String selectedSNo;

  @override
  void initState() {
    super.initState();
    selectedSNo = widget.sensors.first.sNo.toString();
  }

  Color _colorFor(double value) {
    switch (widget.gaugeType) {
      case _GaugeType.pressure:
        if (value <= 10) return Colors.red;
        if (value <= 20) return Colors.orange;
        return Colors.green;
      case _GaugeType.moisture:
      case _GaugeType.temperature:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic selected = widget.sensors.first;
    for (final s in widget.sensors) {
      if (s.sNo.toString() == selectedSNo) {
        selected = s;
        break;
      }
    }

    // Live MQTT update for the currently selected sensor in this section.
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getSensorUpdatedValve(selected.sNo.toString()),
      builder: (_, status, __) {
        final statusParts = status?.split(',') ?? [];
        if (statusParts.length > 1) {
          selected.value = statusParts[1];
        }

        final chartData = _getSensorDataById(selected.sNo.toString(), widget.sensorData);
        final numericValue = double.tryParse(selected.value.toString()) ?? 0.0;
        final gaugeColor = _colorFor(numericValue);

        final series = <CartesianSeries<dynamic, String>>[
          LineSeries<SensorHourlyData, String>(
            dataSource: chartData,
            xValueMapper: (data, _) => data.hour,
            yValueMapper: (data, _) => double.tryParse(data.value.toString()) ?? 0.0,
            markerSettings: const MarkerSettings(isVisible: true),
            color: Colors.blueAccent,
            name: selected.name,
          ),
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 10, bottom: 6),
                child: Text(
                  widget.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ),

              // Chip selector — only when this valve has more than one
              // sensor of this type. This is what fixes the "always
              // shows sensor #1" problem.
              if (widget.sensors.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: widget.sensors.map<Widget>((s) {
                      final isSelected = s.sNo.toString() == selectedSNo;
                      return ChoiceChip(
                        label: Text(
                          s.name,
                          style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87),
                        ),
                        selected: isSelected,
                        selectedColor: Theme.of(context).primaryColor,
                        onSelected: (_) => setState(() => selectedSNo = s.sNo.toString()),
                      );
                    }).toList(),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
                child: Text(
                  selected.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
                          maximum: widget.gaugeMax,
                          pointers: <GaugePointer>[
                            NeedlePointer(value: numericValue, needleEndWidth: 3, needleColor: Colors.black54),
                          ],
                          showFirstLabel: false,
                          axisLabelStyle: const GaugeTextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                          annotations: [
                            GaugeAnnotation(
                              widget: Text(
                                MyFunction().getUnitByParameter(context, widget.unitParam, selected.value.toString()) ?? '',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: gaugeColor),
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
                    child: Container(width: 1, height: 110, color: Colors.black12),
                  ),
                  SizedBox(
                    width: 415,
                    height: 132,
                    child: (context.findAncestorStateOfType<_ValveSensorsPopoverState>())
                        ?.buildCommonCalendar(context, () => setState(() {})),
                  ),
                ],
              ),
              SizedBox(
                width: 550,
                height: 175,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    title: AxisTitle(text: selected.name, textStyle: const TextStyle(fontSize: 12)),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: series,
                ),
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  List<SensorHourlyData> _getSensorDataById(String sensorId, List<SensorHourlyDataModel> sensorData) {
    final result = <SensorHourlyData>[];
    for (final model in sensorData) {
      model.data.forEach((hour, sensorList) {
        result.addAll(sensorList.where((sensor) => sensor.sensorId == sensorId));
      });
    }
    return result;
  }
}