
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_card.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_helper.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_json_model.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_live_model.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../services/mqtt_service.dart';
import '../../../utils/environment.dart';

class WeatherDashboardPage extends StatefulWidget {
  const WeatherDashboardPage({
    Key? key,
    required this.userId,
    required this.controllerId,
    required this.deviceID,
  }) : super(key: key);

  final int userId;
  final int controllerId;
  final String deviceID;

  @override
  State<WeatherDashboardPage> createState() =>
      _WeatherDashboardPageState();
}

class _WeatherDashboardPageState extends State<WeatherDashboardPage> {
  late WeatherJsonModel weatherModel;

  List<WeatherLiveUIModel> uiData = [];
  List<DeviceList> devices = [];

  DeviceList? selectedDevice;
  bool loading = true;
  final MqttService manager = MqttService();

  @override
  void initState() {
    super.initState();
    WeatherLiveRequest();
    fetchWeatherJson();
  }

  /// 🔹 MQTT REQUEST
  void WeatherLiveRequest() {
    String payLoadFinal = jsonEncode({
      "5000":
      {"5001": ""},

    });
    manager.topicToPublishAndItsMessage(
        payLoadFinal, '${Environment.mqttPublishTopic}/${widget.deviceID}');
print('payLoadFinal:$payLoadFinal');

  }

  void fetchWeatherJson() async {
    print("call fetchweather json");
     try
    {
      final Repository repository = Repository(HttpService());
      var getUserDetails = await repository.getweather({
        "userId": widget.userId ,
        "controllerId": widget.controllerId
      });

      final jsonData = jsonDecode(getUserDetails.body);
      print('jsonData  fetch device  ${jsonData['data']['deviceList']}');
      print('jsonData  fetch irrigationLine ${jsonData['data']['irrigationLine']}');
      if (jsonData['code'] == 200) {
        setState(() {
          weatherModel = WeatherJsonModel.fromJson(jsonData);
           devices = weatherModel.data.deviceList;
          selectedDevice ??= devices.first;
          uiData = parseWeatherLive(
            weatherModel,
            selectedDevice!.serialNumber,
          );
          // uiData = parseFullWeatherLive(cMValue: cMValue, deviceList: deviceList, configObject: configObject, irrigationLine: irrigationLine);
          devices = weatherModel.data.deviceList;
          selectedDevice ??= devices.first;
        });
      }
    } catch (e, stackTrace) {
      print(' trace overAll getData  => ${stackTrace}');
    }
     setState(() => loading = false);
  }

  /// 🔹 APP BAR WITH DEVICE SELECTION
  PreferredSizeWidget _appBar() {
    return AppBar(
      leading: const BackButton(),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const SizedBox(height: 4),
          if (devices.isNotEmpty)
            DropdownButtonHideUnderline(
              child: DropdownButton<DeviceList>(
                value: devices.contains(selectedDevice) ? selectedDevice : null,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                items: devices.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text(d.deviceName,
                        style: const TextStyle(fontSize: 13,color: Colors.red),),
                  );
                }).toList(),
                onChanged: (device) {
                  if (device == null) return;
                  setState(() {
                    selectedDevice = device;
                    loading = true;
                  });
                  fetchWeatherJson();
                },
              ),
            ),
        ],
      ),
      actions:  [
        IconButton( onPressed: () {
          setState(() {
            print('click icon');
            WeatherLiveRequest();
             Future.delayed(
              const Duration(seconds: 40),
            );
            fetchWeatherJson();
           });
        }, icon: Icon(Icons.refresh),),
        SizedBox(width: 12),
      ],
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'Moisture Sensor':
        return Icons.grass;
      case 'Temperature Sensor':
        return Icons.thermostat;
      case 'Soil Temperature Sensor':
        return Icons.terrain;
      case 'Wind Speed Sensor':
        return Icons.air;
      case 'Wind Direction Sensor':
        return Icons.navigation;
      case 'LUX Sensor':
        return Icons.wb_sunny;
      case 'Rain Fall Sensor':
        return Icons.umbrella;
      default:
        return Icons.sensors;
    }
  }
  String unit(String title) {
    title = title.toLowerCase(); // make matching case-insensitive

    if (title.contains('moisture')) {
      return 'CB';
    } else if (title.contains('temperature')) {
      return '°C';
    } else if (title.contains('atmosphere pressure')) {
      return 'kPa';
    } else if (title.contains('leaf')) {
      return '%';
    } else if (title.contains('humidity')) {
      return '%';
    } else if (title.contains('co2')) {
      return 'ppm';
    } else if (title.contains('ldr')) {
      return 'Lu';
    } else if (title.contains('lux')) {
      return 'Lu';
    } else if (title.contains('wind direction')) {
      return 'CB';
    } else if (title.contains('rain fall')) {
      return 'mm';
    } else if (title.contains('wind speed')) {
      return 'km/h';
    } else {
      return ''; // default if unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    print("call weather page");
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _appBar(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : uiData.isEmpty
          ? const Center(child: Text("No weather data"))
          : Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: uiData.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (_, i) => WeatherCard(
              title: uiData[i].objectName,
              value: uiData[i].value,
              unit: unit(uiData[i].sensorType) ,
              errstatus: uiData[i].errorCode,
              icon: _icon(uiData[i].sensorType) ,
              minval:uiData[i].minValue,
              maxval:uiData[i].maxValue,
              otherval: uiData[i].otherValue,),
        ),
      ),
    );
  }
}

