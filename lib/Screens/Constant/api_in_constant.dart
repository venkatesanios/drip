import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ConstantPageProvider/changeNotifier_constantProvider.dart';
import 'home_page_constant.dart';
import 'modal_in_constant.dart';

class ApiService {
  final String baseURL = "http://52.172.214.208:5000/api/v1/user/constant/get";

  Future<http.Response> postRequest(String action,
      Map<String, dynamic> bodyData) async {
    var headers = {
      'Content-Type': 'application/json',
      'action': action,
    };
    var body = json.encode(bodyData);

    try {
      return await http.post(Uri.parse(baseURL), headers: headers, body: body);
    } catch (e) {
      throw Exception("Failed to load data: $e");
    }
  }


  Future<Map<String, dynamic>> fetchData(BuildContext context) async {
    try {
      final response = await postRequest("fetch_data", {
        "userId": 4,
        "controllerId": 1,
      });

      if (response.statusCode == 200) {
        final dynamic decodedJson = json.decode(response.body);
        //print(response.body);
        if (decodedJson is Map<String, dynamic>) {
          if (decodedJson.containsKey('data') &&
              decodedJson['data'] is Map<String, dynamic>) {
            var constantData = decodedJson['data']['constant'];

            if (constantData != null && constantData['general'] is List) {
              List<Map<String, dynamic>> generalData = List<
                  Map<String, dynamic>>.from(constantData['general']);
              // Update the provider with the fetched 'general' data
              Provider.of<ConstantProvider>(context, listen: false)
                  .setGeneralUpdated(generalData);
            }
          }

          return decodedJson;
        } else {
          throw Exception(
              "Invalid response format: Expected a Map<String, dynamic>");
        }
      } else {
        throw Exception(
            "Failed to load data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error in fetchData: $e");
    }
  }



}



class ApiInConstant extends StatefulWidget {
  const ApiInConstant({super.key});
  @override
  _ApiInConstantState createState() => _ApiInConstantState();
}

class _ApiInConstantState extends State<ApiInConstant> {
  late ApiService apiService;
  Future<Map<String, dynamic>> ?futureData;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();

    futureData = Future(() => apiService.fetchData(context));
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
              final constantJsonData = ConstantDataModel.fromJson(jsonData['data']);

              return ConstantHomePage(
                alarmData: jsonData['data']['default']['alarm'],
                normalAlarm: constantJsonData.fetchUserDataDefault.alarm.toList() ,
                criticalAlarm: constantJsonData.fetchUserDataDefault.alarm.toList() ,
                alarm: constantJsonData.fetchUserDataDefault.alarm,
                constantMenu: constantJsonData.fetchUserDataDefault.constantMenu,
                irrigationLines: constantJsonData.fetchUserDataDefault.configMaker.irrigationLine,
                pump: constantJsonData.fetchUserDataDefault.configMaker.pump,
                mainValves: constantJsonData.fetchUserDataDefault.configMaker.irrigationLine.expand((line) => line.mainValve).toList(),
                valves: constantJsonData.fetchUserDataDefault.configMaker.irrigationLine
                    .expand((line) => line.valves)
                    .toList(),
                fertilizerSite: constantJsonData.fetchUserDataDefault.configMaker.fertilizerSite,
                channels: constantJsonData.fetchUserDataDefault.configMaker.fertilizerSite
                    .expand((site) => site.channel)
                    .toList(),
                ec: constantJsonData.fetchUserDataDefault.configMaker.fertilizerSite
                    .expand((site) => site.ec)
                    .toList(),
                ph: constantJsonData.fetchUserDataDefault.configMaker.fertilizerSite
                    .expand((site) => site.ph)
                    .toList(),
                waterMeter: [
                  ...constantJsonData.fetchUserDataDefault.configMaker.irrigationLine
                      .map((line) => line.waterMeter)
                      .whereType<WaterMeter>(),
                  ...constantJsonData.fetchUserDataDefault.configMaker.pump
                      .map((pump) => pump.waterMeter)
                      .whereType<WaterMeter>()
                ],
                controlSensors: List<String>.from(jsonData['controlSensors'] ?? []),
                generalUpdated:[
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
                  {"sNo": 12, "title": "Lora Key 2", "widgetTypeId": 1, "value": "0"}
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
