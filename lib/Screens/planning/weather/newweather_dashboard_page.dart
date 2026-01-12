

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
 import 'package:oro_drip_irrigation/Screens/planning/weather/weather_helper.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_left_side_card.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_sensor_tile.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../services/mqtt_service.dart';
import '../../../utils/environment.dart';
 import 'weather_json_model.dart';
import 'weather_live_model.dart';
 import 'weather_wind_card.dart';
import 'weather_co2_card.dart';
import 'weather_rainfall_card.dart';

class WeatherDashboardPage extends StatefulWidget {
  const WeatherDashboardPage({
    super.key,
    required this.userId,
    required this.controllerId,
    required this.deviceID,
  });

  final int userId;
  final int controllerId;
  final String deviceID;

  @override
  State<WeatherDashboardPage> createState() => _WeatherDashboardPageState();
}

class _WeatherDashboardPageState extends State<WeatherDashboardPage> {
  late WeatherJsonModel weatherModel;

  final MqttService manager = MqttService();

  List<WeatherLiveUIModel> uiData = [];
  List<DeviceList> devices = [];
  DeviceList? selectedDevice;
  int? selectedSerialNumber;

  bool loading = true;

  @override
  void initState() {
    super.initState();
     print("call _ initstate");
    _weatherLiveRequest();
    _fetchWeatherJson();
  }



  void _refreshWeather() async {
    setState(() => loading = true);
    _weatherLiveRequest();
    // ⏳ Give device time to respond
    await Future.delayed(const Duration(seconds: 2));
    await _fetchWeatherJson();
  }

  void _weatherLiveRequest() {
    print("Call _weatherLiveRequest");
    final payload = jsonEncode({
      "5000": {"5001": ""}
    });
    manager.topicToPublishAndItsMessage(
      payload,
      '${Environment.mqttPublishTopic}/${widget.deviceID}',
    );
  }

  Future<void> _fetchWeatherJson() async {
    print("Call _fetchWeatherJson");
    try {
      final repository = Repository(HttpService());

      final response = await repository.getweather({
        "userId": widget.userId,
        "controllerId": widget.controllerId,
      });

      final jsonData = jsonDecode(response.body);

      if (jsonData['code'] == 200) {
        weatherModel = WeatherJsonModel.fromJson(jsonData);
        devices = weatherModel.data.deviceList;
        selectedDevice ??= devices.first;
         selectedSerialNumber ??= devices.first.serialNumber;

        uiData = parseWeatherLive(
          weatherModel,
          selectedSerialNumber!,
        );
        setState(() {
        });
      }
    } catch (e) {
      debugPrint("Weather fetch error: $e");
    }
    setState(() => loading = false);
  }

  WeatherLiveUIModel? _findSensor(String key) {
    try {
      final searchKey = key.toLowerCase();

      for (final sensor in uiData) {
        if (sensor.sensorType.toLowerCase() == searchKey) {
          return sensor;
        }
      }

    } catch (_) {
      return null;
    }
  }

  IconData _icon(String type) {
    type = type.toLowerCase();
    if (type.contains('moisture')) return Icons.grass;
    if (type.contains('temperature')) return Icons.thermostat;
    if (type.contains('wind')) return Icons.air;
    if (type.contains('rain')) return Icons.umbrella;
    if (type.contains('lux')) return Icons.wb_sunny;
    if (type.contains('co2')) return Icons.cloud;
    return Icons.sensors;
  }

  String unit(String type) {
    type = type.toLowerCase();
    if (type.contains('moisture')) return 'CB';
    if (type.contains('temperature')) return '°C';
    if (type.contains('humidity')) return '%';
    if (type.contains('co2')) return 'ppm';
    if (type.contains('lux')) return 'Lu';
    if (type.contains('wind speed')) return 'km/h';
    if (type.contains('rain')) return 'mm';
    return '';
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      title: devices.isEmpty
          ? const Text("Weather")
          : DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: devices.any((d) => d.serialNumber == selectedSerialNumber)
              ? selectedSerialNumber
              : null,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18,color: Colors.white,),
          dropdownColor: Colors.teal.shade900,
          items: devices.map((d) {
            return DropdownMenuItem<int>(
              value: d.serialNumber,
              child: Text(
                d.deviceName,
                style: const TextStyle(fontSize: 13,color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (serial) {
            if (serial == null) return;

            setState(() {
              selectedSerialNumber = serial;
              loading = true;
            });

            _fetchWeatherJson();
          },
        ),
      ),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            setState(() => loading = true);
            _weatherLiveRequest();
            _fetchWeatherJson();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final windSpeed = _findSensor('wind speed');
    final windDirection = _findSensor('wind direction');
    final co2 = _findSensor('co2');
    final rain = _findSensor('rain');
    final temp = _findSensor('Temperature Sensor');
    final hummitituy = _findSensor('Humidity Sensor');

    final gridSensors = uiData.where((e) {
      final t = e.sensorType.toLowerCase();
      return !t.contains('wind') &&
          !t.contains('co2') &&
          !t.contains('rain');
    }).toList();

    final dt = DateTimeHelper.fromApi(
      date: weatherModel.data.weatherLive.cD,
      time: weatherModel.data.weatherLive.cT,
    );
    final formattedtime = DateTimeHelper.formatDateTime(dt);
     return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _appBar(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          :  Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child:  gridSensors.isNotEmpty ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LeftWeatherPanel(city: "Coimbatore",date: formattedtime,  wind: windSpeed?.value ?? "0", temp: temp?.value ?? "0", humidity: hummitituy?.value ?? "0"),
              SizedBox(width: 16),
              Expanded(child: RightDashboardPanel(gridSensors: gridSensors, windSpeed: windSpeed, windDirection: windDirection, co2: co2, rain: rain, iconResolver: _icon, unitResolver: unit)),
            ],
          ) : Center(child: Text("Weather data is currently unavailable. Please check the sensor connection or try again later.")),
        ),
      ),
    );
  }
}


class LeftWeatherPanel extends StatelessWidget {
  final String city;
   final String date;
   final String wind;
  final String temp;
  final String humidity;

  const LeftWeatherPanel({
    super.key,
    required this.city,
     required this.date,
     required this.wind,
    required this.temp,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Column(
        children: [
          weatherCardLeft(
            city: city,
             date: "$date",
            temperature: "$temp °C", // optional if you add temp sensor later
            feelsLike: temp,
            weatherIcon: Icons.wb_sunny,
            wind: "$wind km/h",
            humidity: "$humidity %",
          ),
          const SizedBox(height: 16),
          sunCard(),
        ],
      ),
    );
  }
}

class RightDashboardPanel extends StatelessWidget {
  final List<WeatherLiveUIModel> gridSensors;
  final WeatherLiveUIModel? windSpeed;
  final WeatherLiveUIModel? windDirection;
  final WeatherLiveUIModel? co2;
  final WeatherLiveUIModel? rain;
  final IconData Function(String) iconResolver;
  final String Function(String) unitResolver;

  const RightDashboardPanel({
    super.key,
    required this.gridSensors,
    required this.windSpeed,
    required this.windDirection,
    required this.co2,
    required this.rain,
    required this.iconResolver,
    required this.unitResolver,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// SENSOR GRID
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: gridSensors.map((e) {
            return SizedBox(
              width: 280,
              height: 180,
              child: SensorTile(
                data: e,
                icon: iconResolver(e.sensorType),
                unit: unitResolver(e.sensorType),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        /// SPECIAL CARDS
        gridSensors.isNotEmpty
            ? Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 300,
              height: 180,
              child: WindCard(
                windSpeed: windSpeed != null
                    ? "${windSpeed!.value} ${unitResolver(windSpeed!.sensorType)}"
                    : "--",
                gusts: "--",
                directionText: windDirection != null
                    ? "${windDirection!.value}°"
                    : "--",
                directionAngle: windDirection != null
                    ? double.tryParse(windDirection!.value) ?? 0
                    : 0,
              ),
            ),
            SizedBox(
              width: 250,
              height: 180,
              child: CO2Card(
                co2Value: int.tryParse(co2?.value ?? '0') ?? 0,
                message:
                (int.tryParse(co2?.value ?? '0') ?? 0) < 800
                    ? "Air quality is great!\nPerfect for outdoor activities."
                    : "High CO₂ detected.\nVentilation advised.",
              ),
            ),
            SizedBox(
              width: 250,
              height: 180,
              child: RainfallCard(
                rainfallValue: rain != null
                    ? "${rain!.value} ${unitResolver(rain!.sensorType)}"
                    : "--",
                forecastText: "Rain sensor reading",
                description: rain != null &&
                    double.tryParse(rain!.value) != null &&
                    double.parse(rain!.value) > 0
                    ? "Light rain detected."
                    : "No rainfall detected.",
              ),
            ),
          ],
        )
            : const Center(child: Text("No Weather Data")),
      ],
    );
  }
}


class DateTimeHelper {
  /// Combines API date + time into DateTime
  static DateTime fromApi({
    required DateTime date,
    required String time,
  }) {
    final d = date.toIso8601String().split('T').first;
    return DateTime.parse('$d $time');
  }

  /// Format: Jan 12 2026, 09:53:13 AM
  static String formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';

    return "${months[dt.month - 1]} "
        "${dt.day.toString().padLeft(2, '0')} "
        "${dt.year}, "
        "${hour12.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}:"
        "${dt.second.toString().padLeft(2, '0')} "
        "$amPm";
  }
}
