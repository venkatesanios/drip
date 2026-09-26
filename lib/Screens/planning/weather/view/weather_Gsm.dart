import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../services/mqtt_service.dart';
import '../../../../utils/environment.dart';
import '../weather_report_page.dart';
import '../widgets/info_box.dart';
import '../widgets/sensor_chip.dart';
import '../widgets/sensor_chipGsm.dart';
import '../widgets/sun_time_card.dart';
import '../widgets/time_of_day_icon_new.dart';

class WeatherGsm extends StatefulWidget {
  const WeatherGsm({
    super.key,
    required this.customerId,
     required this.controllerId,
    required this.deviceID,
     required this.jsondata,
  });

  final int customerId, controllerId;
  final String deviceID;
  final Map<String, dynamic> jsondata;

  @override
  State<WeatherGsm> createState() => _WeatherGsmState();
}

class _WeatherGsmState extends State<WeatherGsm> {
  final MqttService manager = MqttService();
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }
  @override
  void dispose() {
     _autoRefreshTimer?.cancel();
    super.dispose();
  }
  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        Request();

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      /// 🔹 SAMPLE JSON (your data)
      final json = widget.jsondata;

      /// 🔹 Get raw
      final raw = json['weatherLive']?['cM']?['7901']?.toString() ?? '';

      /// 🔹 Parse
      final parsed = parseLive5101(raw);

      /// 🔹 Convert map
      final liveMap = mapBySNo(parsed);

      /// 🔹 Config parse
      final configList = (json['configObject'] as List)
          .map((e) => ConfigObject.fromJson(e))
          .toList();

      /// 🔹 Merge
      final sensorList = buildSensorList(
        configs: configList,
        liveMap: liveMap,
      );

      String getByName(String name) {
        try {
          final sensor = sensorList.firstWhere(
                (e) => e.name.toLowerCase().contains(name.toLowerCase()),
          );
          return sensor.value.toString();
        } catch (e) {
          return '-';
        }
      }
      final hummitysensor = getByName("Humidity Sensor");
      final tempsensor = getByName("Temperature Sensor");
      final windsensor = getByName("Wind Speed Sensor");

      return kIsWeb ? _buildWideLayout(sensorList,
          "${json['weatherLive']?['cT']}-${json['weatherLive']?['cD']}",
          tempsensor, windsensor, hummitysensor,
          "${json['weatherLive']?['cT']}") : _buildNarrowLayout(sensorList,
          "${json['weatherLive']?['cT']}-${json['weatherLive']?['cD']}",
          tempsensor, windsensor, hummitysensor,
          "${json['weatherLive']?['cT']}");
    }
    catch (e, stack) {
      debugPrint("ERROR: $e");
      debugPrint("STACK: $stack");

      return Scaffold(
        body: Center(
          child: Text(
            "Something went wrong\n$e\n$stack",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          ),
        ),
      );
    }
   }
  Request() {
    String payLoadFinal = jsonEncode({
      "5000":
      {"5001": ""},
    });
    manager.topicToPublishAndItsMessage(
        payLoadFinal, '${Environment.mqttPublishTopic}/${widget.deviceID}');
    setState(() {

    });
  }


Widget _buildWideLayout(
     device,
    String formattedDT,
    String tempText,
    String windText,
    String humidityText,
    String time,
    )
{
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: 320,
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon:  const Icon(Icons.refresh),
                    onPressed: () {
                      Request();
                     },
                  ),
                  Text("Get Live Data")
                ],
              ),
              _weatherSummaryCard(
                formattedDT,
                tempText,
                windText,
                humidityText,
                time,
              ),
              const SizedBox(height: 16),
              sunCard(),
            ],
          ),
        ),
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: () async {
             // Wait a little to show the indicator
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Builder(
                    builder: (context) {
                      final orderedSensors = [
                        ...device.where((s) =>
                        !s.name.contains('Co2') &&
                            !s.name.contains('Rain Fall') &&
                            !s.name.contains('Wind Direction')
                        ),
                        ...device.where((s) =>
                        s.name.contains('Co2') ||
                            s.name.contains('Rain Fall') ||
                            s.name.contains('Wind Direction')
                        ),
                      ];

                       return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: orderedSensors.map<Widget>((s) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SensorHourlyReportPage(
                                    deviceSrNo: '${1}',
                                    sensorSrNo: s.sNo.toString(),
                                    sensorName: s.name,
                                    userId: '${widget.customerId}',
                                    controllerId: '${widget.controllerId}',
                                    unit: unit(s.name),
                                  ),
                                ),
                              );
                            },
                            child: SensorChipGsm(
                              device: s,
                              isNarrow: false,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        ))
    ],
  );
}

  Widget _buildNarrowLayout(
      device,
      String formattedDT,
      String tempText,
      String windText,
      String humidityText,
      String time,

      )
  {
    return   ListView(
      padding: const EdgeInsets.all(8),
      children: [

        _weatherSummaryCard(
          formattedDT,
          tempText,
          windText,
          humidityText,
          time,
        ),
        const SizedBox(height: 16),
        sunCard(),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: device.map<Widget>((s) {
                return GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SensorHourlyReportPage(
                          deviceSrNo: '${1}',
                          sensorSrNo: s.sNo.toString(), sensorName: s.name, userId: '${widget.customerId}', controllerId: "${widget.controllerId}" ,unit:unit(s.name),
                        ),
                      ),
                    );
                  },
                  child: SensorChipGsm(
                    device: s,
                    isNarrow: true,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],

    );
  }
  String unit(String type) {
    type = type.toLowerCase();
    if (type.contains('moisture')) return 'CB';
    if (type.contains('temperature')) return '°C';
    if (type.contains('humidity')) return '%';
    if (type.contains('co2')) return 'ppm';
    if (type.contains('direction')) return '°';
    if (type.contains('wind')) return 'km/h';
    if (type.contains('rain')) return 'mm';
    if (type.contains('lux')) return 'Lu';
    if (type.contains('ldr')) return 'Ω';
    if (type.contains('leaf')) return '%';
    return '';
  }

Widget _weatherSummaryCard(
    String formattedDT,
    String tempText,
    String windText,
    String humidityText,
    String time,
    ) {
  return Container(
    width: 320,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(CupertinoIcons.location_solid),
            SizedBox(width: 6),
            Text("Coimbatore"),
          ],
        ),
        const SizedBox(height: 12),
        Text(formattedDT),
        const SizedBox(height: 16),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$tempText °C",
                    style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Feel Like $tempText °C"),
              ],
            ),
            const SizedBox(width: 30),
            TimeOfDayIconNew(time: time),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: InfoBox(CupertinoIcons.wind, "Wind", windText)),
            const SizedBox(width: 12),
            Expanded(child: InfoBox(CupertinoIcons.drop_fill, "Humidity", humidityText)),
          ],
        ),
      ],
    ),
  );
}

Widget sunCard() {
  return const Row(
    children: [
      Expanded(child: SunTimeCard("Sunrise", "6:10 AM", 'assets/Images/sunrise.png')),
      SizedBox(width: 12),
      Expanded(child: SunTimeCard("Sunset", "6:45 PM", 'assets/Images/sunset.png')),
    ],
  );
}
}

class LiveSensorValue {
  final double sNo;
  final double value;
  final int status;
  final double min;
  final double max;

  LiveSensorValue({
    required this.sNo,
    required this.value,
    required this.status,
    required this.min,
    required this.max,
  });
}

class ConfigObject {
  final double sNo;
  final String name;
  final int objectId;

  ConfigObject({
    required this.sNo,
    required this.name,
    required this.objectId,
  });

  factory ConfigObject.fromJson(Map<String, dynamic> json) {
    return ConfigObject(
      sNo: (json['sNo'] as num?)?.toDouble() ?? 0,
      name: json['name'] ?? '',
      objectId: json['objectId'] ?? 0,
    );
  }
}

class SensorDisplayModel {
  final String name;
  final double sNo;
  final double value;
  final int status;
  final double min;
  final double max;
  final int objectId;

  SensorDisplayModel({
    required this.name,
    required this.sNo,
    required this.value,
    required this.status,
    required this.min,
    required this.max,
    required this.objectId,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "sNo": sNo,
      "value": value,
      "status": status,
      "min": min,
      "max": max,
      "objectId": objectId,
    };
  }
}

Map<int, List<LiveSensorValue>> parseLive5101(String raw) {
  final result = <int, List<LiveSensorValue>>{};

  if (raw.isEmpty || !raw.contains(':')) return result;

  final split = raw.split(':');

  final header = split[0].split(',');
  final serial = int.tryParse(header[0]) ?? 0;

  final sensorPart = split[1];

  final sensors = <LiveSensorValue>[];

  for (final block in sensorPart.split('_')) {
    final f = block.split(',');

    if (f.length < 5) continue;

    sensors.add(
      LiveSensorValue(
        sNo: double.tryParse(f[0]) ?? 0,
        value: double.tryParse(f[1]) ?? 0,
        status: int.tryParse(f[2]) ?? 0,
        min: double.tryParse(f[3]) ?? 0,
        max: double.tryParse(f[4]) ?? 0,
      ),
    );
  }

  result[serial] = sensors;

  return result;
}

Map<double, LiveSensorValue> mapBySNo(
    Map<int, List<LiveSensorValue>> liveData)
{
  final map = <double, LiveSensorValue>{};
  for (final sensors in liveData.values) {
    for (final s in sensors) {
      map[s.sNo] = s;
    }
  }
  return map;
}

List<SensorDisplayModel> buildSensorList({
  required List<ConfigObject> configs,
  required Map<double, LiveSensorValue> liveMap,
}) {
  return configs.map((config) {
    final live = liveMap[config.sNo];

    return SensorDisplayModel(
      name: config.name,
      sNo: config.sNo,
      value: live?.value ?? 0,
      status: live?.status ?? 0,
      min: live?.min ?? 0,
      max: live?.max ?? 0,
      objectId: config.objectId,
    );
  }).toList();
}

Color getStatusColor(int status) {
  if (status == 255) return Colors.green;
  return Colors.red;
}

