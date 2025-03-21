import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/http_service.dart';
import 'ConstantPageProvider/changeNotifier_constantProvider.dart';
import 'home_page_constant.dart';
import 'modal_in_constant.dart';

class ConstantInConfig extends StatefulWidget {
  final int userId, controllerId, customerId;
  final String deviceId;

  const ConstantInConfig({super.key, required this.userId, required this.controllerId, required this.customerId, required this.deviceId});
  @override
  _ConstantInConfigState createState() => _ConstantInConfigState();
}
class _ConstantInConfigState extends State<ConstantInConfig> {
  late HttpService httpService;
  Future<Map<String, dynamic>>? futureData;
  late ConstantDataModel constantJsonData;
  bool init = false;

  @override
  void initState() {
    super.initState();
    init = true;
    httpService = HttpService();
    futureData = fetchData();
  }

  Future<Map<String, dynamic>> fetchData() async {
    try {
      final response = await httpService.postRequest("/user/constant/get", {
        "userId": widget.userId,
        "controllerId": widget.controllerId,
      });

      if (response.statusCode == 200) {
        final dynamic decodedJson = json.decode(response.body);
        print('Controller ID: ${widget.controllerId}');
        print('User ID: ${widget.userId}');
        print(response.body);

        if (decodedJson is Map<String, dynamic>) {
          if (decodedJson.containsKey('data') && decodedJson['data'] is Map<String, dynamic>) {
            return decodedJson;
          }
        }
      }
      return {};
    } catch (e) {
      print("Error in fetchData: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data.'));
          } else if (snapshot.hasData) {
            final jsonData = snapshot.data!;
            if (jsonData['data'] != null) {
              if(init){
                constantJsonData = ConstantDataModel.fromJson(jsonData['data']);
                init=false;
              }

              return ConstantHomePage(
                levelSensor: constantJsonData.fetchUserDataDefault.configMaker.waterSource
                    .map((waterSource) => waterSource.level)
                    .whereType<LevelSensor>()
                    .toList(),
                waterSource: constantJsonData.fetchUserDataDefault.configMaker.waterSource,
                moistureSensors: constantJsonData.fetchUserDataDefault.configMaker.moistureSensor,
                controllerId: widget.controllerId,
                userId: widget.userId,
                alarmData: jsonData['data']['default']['alarm'],
                normalAlarm: constantJsonData.fetchUserDataDefault.alarm.toList(),
                criticalAlarm: constantJsonData.fetchUserDataDefault.alarm.toList(),
                alarm: constantJsonData.fetchUserDataDefault.alarm,
                constantMenu: constantJsonData.fetchUserDataDefault.constantMenu,
                irrigationLines: constantJsonData.fetchUserDataDefault.configMaker.irrigationLine,
                pump: constantJsonData.fetchUserDataDefault.configMaker.pump,
                mainValves: constantJsonData.fetchUserDataDefault.configMaker.irrigationLine.expand((line) => line.mainValve).toList(),
                valves: constantJsonData.fetchUserDataDefault.configMaker.irrigationLine.expand((line) => line.valves).toList(),
                fertilizerSite: constantJsonData.fetchUserDataDefault.configMaker.fertilizerSite,
                channels: constantJsonData.fetchUserDataDefault.configMaker.fertilizerSite.expand((site) => site.channel).toList(),
                ec: constantJsonData.fetchUserDataDefault.configMaker.fertilizerSite.expand((site) => site.ec).toList(),
                ph: constantJsonData.fetchUserDataDefault.configMaker.fertilizerSite.expand((site) => site.ph).toList(),
                waterMeter: [
                  ...constantJsonData.fetchUserDataDefault.configMaker.irrigationLine.map((line) => line.waterMeter).whereType<WaterMeters>(),
                  ...constantJsonData.fetchUserDataDefault.configMaker.pump.map((pump) => pump.waterMeter).whereType<WaterMeters>()
                ],
                controlSensors: List<String>.from(jsonData['controlSensors'] ?? []),

                generalUpdated: jsonData['data']['constant'] != null &&
                    jsonData['data']['constant']['general'] != null
                    ? List<Map<String, dynamic>>.from(jsonData['data']['constant']['general'])
                    :  [
                  {"sNo": 1, "title": "Number of Programs", "widgetTypeId": 1, "value": "0"},
                  {"sNo": 2, "title": "Number of Valve Groups", "widgetTypeId": 1, "value": "0"},
                  {"sNo": 3, "title": "Number of Conditions", "widgetTypeId": 1, "value": "0"},
                  {"sNo": 4, "title": "Run List Limit", "widgetTypeId": 1, "value": "0"},
                  {"sNo": 5, "title": "Fertilizer Leakage Limit", "widgetTypeId": 1, "value": "0"},
                  {"sNo": 6, "title": "Reset Time", "widgetTypeId": 3, "value": "00:00:00"},
                  {"sNo": 7, "title": "No Pressure Delay", "widgetTypeId": 3, "value": "00:00:00"},
                  {"sNo": 8, "title": "Common dosing coefficient", "widgetTypeId": 1, "value": "0"},
                  {"sNo": 9, "title": "Water pulse before dosing", "widgetTypeId": 2, "value": false},
                  {"sNo": 10, "title": "Pump on after valve on", "widgetTypeId": 2, "value": false},
                  {"sNo": 11, "title": "Lora Key 1", "widgetTypeId": 1, "value": "0"},
                  {"sNo": 12, "title": "Lora Key 2", "widgetTypeId": 1, "value": "0"},
                ],

              );
            } else {
              return const Center(child: Text('No data available in the response.'));
            }
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}

