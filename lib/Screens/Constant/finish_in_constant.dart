import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'ConstantPageProvider/changeNotifier_constantProvider.dart';
import 'modal_in_constant.dart';

class FinishInConstant extends StatefulWidget {
   List<Pump> pumps;
   List<Valve> valves;
   List<EC> ec;
   List<PH> ph;
   List<FertilizerSite> fertilizerSite;
   List<String> controlSensors;
   List<IrrigationLine> irrigationLines;
   List<MainValve> mainValves;
   List<dynamic> generalUpdated;
   List<Alarm> alarm;
   int controllerId;
   int userId;
  List<MoistureSensor> moistureSensors;
   List<LevelSensor> levelSensor;
    List<WaterMeters> waterMeter;
   FinishInConstant({
    super.key,
    required this.pumps,
    required this.valves,
    required this.ec,
    required this.ph,
    required this.fertilizerSite,
    required this.controlSensors,
    required this.irrigationLines,
    required this.mainValves,
    required this.generalUpdated,
    required this.alarm,
    required this.controllerId,
    required this.userId,
    required this.levelSensor,
    required this.moistureSensors,
    required this.waterMeter,
  });

  @override
  State<FinishInConstant> createState() => _FinishInConstantState();
}

class _FinishInConstantState extends State<FinishInConstant> {
  List<dynamic> generalUpdated = [];
  List<Pump> updatedPumps = [];
  List<IrrigationLine> updatedIrrigationLines = [];
  final String baseURL =
      "http://52.172.214.208:5000/api/v1/user/constant/create";

  Future<void> sendPumpData() async {
    var headers = {'Content-Type': 'application/json'};
    var provider = Provider.of<ConstantProvider>(context, listen: false);



    var irrigationLinesValve = widget.irrigationLines
        .map((line) => {
              "objectId": line.objectId,
              "sNo": line.sNo,
              "name": line.name,
              "objectName": line.objectName,
              "type": line.type,
              "valve": widget.valves
                  .map((valve) => {
                        "objectId": valve.objectId,
                        "sNo": valve.sNo,
                        "name": valve.name,
                        "objectName": valve.objectName,
                        "type": valve.type,
                        "nominalFlow": valve.nominalFlow,
                        "fillUpDelay": valve.fillUpDelay,
                      })
                  .toList(),
            })
        .toList();

    var irrigationLinesMainValve = widget.irrigationLines
        .map((line) => {
              "objectId": line.objectId,
              "sNo": line.sNo,
              "name": line.name,
              "objectName": line.objectName,
              "type": line.type,
              "mainValve": widget.mainValves
                  .map((mainValve) => {
                        "objectId": mainValve.objectId,
                        "sNo": mainValve.sNo,
                        "name": mainValve.name,
                        "mode": mainValve.mode,
                        "objectName": mainValve.objectName,
                        "type": mainValve.type ?? "missing",
                        "delay": mainValve.delay,
                      })
                  .toList(),
            })
        .toList();



    var body = jsonEncode({
      "userId":widget.userId,
      "controllerId": widget.controllerId,
      "general": widget.generalUpdated,
      "pump": widget.pumps
          .map((pump) => {
                "objectId": pump.objectId,
                "sNo": pump.sNo,
                "name": pump.name,
                "type": pump.type,
                "pumpType": pump.pumpType,
                "pumpStation": pump.pumpStation,
                "controlGem": pump.controlGem,
              })
          .toList(),
      "line": widget.irrigationLines
          .map((line) => {
                "objectId": line.objectId,
                "sNo": line.sNo,
                "name": line.name,
                "objectName": line.objectName,
                "type": line.type,
                "lowFlowDelay": line.lowFlowDelay,
                "highFlowDelay": line.highFlowDelay,
                "lowFlowAction": line.lowFlowAction,
                "highFlowAction": line.highFlowAction,
              })
          .toList(),
      "mainValve": irrigationLinesMainValve,
      "valve": irrigationLinesValve,
      "waterMeter": widget.waterMeter
          .map((water) => {
        "objectId": water.objectId,
        "sNo": water.sNo,
        "name": water.name,
        "objectName": water.objectName,
        "type": water.type,
        "ratio": water.ratio,
      })
          .toList(),
      "filtration": [],
      "fertilization": widget.fertilizerSite
          .map((fertilization) => {
                "name": fertilization.name,
                "objectId": fertilization.objectId,
                "sNo": fertilization.sNo,
                "type": fertilization.type,
                "siteMode": fertilization.siteMode,
                "minimalOnTime": fertilization.minimalOnTime,
                "minimalOffTime": fertilization.minimalOffTime,
                "boosterOffDelay": fertilization.boosterOffDelay,
                "channel": fertilization.channel
                    .map((channel) => {
                          "name": channel.name,
                          "objectId": channel.objectId,
                          "sNo": channel.sNo,
                          "type": channel.type ?? "missing",
                          "ratio": fertilization.ratio,
                          "shortestPulse": fertilization.shortestPulse,
                          "nominalFlow": fertilization.nominalFlow,
                          "injectorMode": fertilization.injectorMode,
                          //  "level": fertilization,
                          "level": channel.level,
                        })
                    .toList()
              })
          .toList(),
      "ecPh": [
        ...widget.ec.map((ec) => {
              "objectId": ec.objectId,
              "sNo": ec.sNo,
              "name": ec.name,
              "connectionNo": ec.connectionNo,
              "objectName": ec.objectName,
              "type": ec.type,
              "selected": ec.selected,
              "controlCycle": ec.controlCycle,
              "delta": ec.delta,
              "fineTuning": ec.fineTuning,
              "coarseTuning": ec.coarseTuning,
              "deadBand": ec.deadBand,
              "integ": ec.integ,
              "controlSensor": ec.controlSensor,
              "avgFitSpeed": ec.avgFiltSpeed,
              "percentage": ec.percentage,
            }),
        ...widget.ph.map((ph) => {
              "objectId": ph.objectId,
              "sNo": ph.sNo,
              "name": ph.name,
              "connectionNo": ph.connectionNo,
              "objectName": ph.objectName,
              "type": ph.type,
              "selected": ph.selected,
              "controlCycle": ph.controlCycle,
              "delta": ph.delta,
              "fineTuning": ph.fineTuning,
              "coarseTuning": ph.coarseTuning,
              "deadBand": ph.deadBand,
              "integ": ph.integ,
              "controlSensor": ph.controlSensor,
              "avgFitSpeed": ph.avgFiltSpeed,
              "percentage": ph.percentage,
            }),
      ],
      "analogSensor": [],
      "moistureSensor": widget.moistureSensors
          .map((moisture) => {
        "objectId": moisture.objectId,
        "sNo": moisture.sNo,
        "name": moisture.name,
        "objectName": moisture.objectName,
        "type": moisture.type,
        "connectionNo": moisture.connectionNo,
        "highLow": moisture.highLow,
        "units": moisture.units,
        "base": moisture.base,
        "min": moisture.min,
        "max": moisture.max,
      })
          .toList(),
      "levelSensor":widget.levelSensor
          .map((level) => {
        "objectId": level.objectId,
        "sNo": level.sNo,
        "objectName": level.objectName,
        "type": level.type,
        "name": level.name,
        "highLow": level.highLow,
        "units":level.units,
        "base":level.base,
        "min":level.min,
        "max":level.max,
        "height":level.height,
      })
          .toList(),
      "normalAlarm": provider.overAllAlarm
          .where((alarm) => alarm.type == 'Normal')
          .map((alarm) => alarm.toJson())
          .toList(),
      "criticalAlarm": provider.overAllAlarm
          .where((alarm) => alarm.type == 'Critical')
          .map((alarm) => alarm.toJson())
          .toList(),
      "globalAlarm": widget.alarm
          .map((alarm) => {
                "sNo": alarm.sNo,
                "name": alarm.name,
                "unit":alarm.unit,
              })
          .toList(),
      "controllerReadStatus": '0',
      "createUser": widget.controllerId,
    });

    try {
      final response = await http.post(
        Uri.parse(baseURL),
        headers: headers,
        body: body,
      );

      print('🟢 Response Status: ${response.statusCode}');
      print('🟢 Response Body: ${response.body}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.statusCode == 200
                ? "✅ Data sent successfully"
                : "❌ Failed to send data: ${response.statusCode}\n${response.body}"),
          ),
        );
      }
    } catch (e) {
      print("🚨 Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Soft background color
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            gradient: const LinearGradient(
              colors: [Color(0xff003f62), Color(0xff0078AA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ElevatedButton(
            onPressed: () {
              // Your function logic here
              sendPumpData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xff003f62),
              elevation: 5,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
            ),
            child: const Text(
              "🚀 Send Data",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


