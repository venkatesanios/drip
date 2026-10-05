import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../models/customer/site_model.dart';
import '../../../services/http_service.dart';
import '../../Logs/model/motor_data.dart';
import '../../Logs/model/motor_data_hourly.dart';
import '../../Logs/model/pump_log_data.dart';
import '../../Logs/repository/log_repos.dart';

class PumpControllerProvider extends ChangeNotifier {
  final LogRepository repository = LogRepository(HttpService());
  List<PumpLogData> pumpLogData = [];
  DateTime focusedDay = DateTime.now();
  Map<int, String> segments = {};
  String message = "";
  int selectedIndex = 0;
  CalendarFormat calendarFormat = CalendarFormat.week;
  final ScrollController scrollController = ScrollController();
  DateTime selectedDate = DateTime.now();

  List<DateTime> dates = List.generate(1, (index) => DateTime.now().subtract(Duration(days: index)));
  List<MotorDataHourly> motorDataList = [];
  List<PageController> pageController= [];
  List<MotorData> chartData = [];
  bool isLoading = false;

  List<Map<String, dynamic>> voltageData = [];

  List<String> getPumpNames(MasterControllerModel? masterData, int nodeControllerId, int controllerId) {
    if (masterData != null) {
      final targetControllerId = nodeControllerId != 0 ? nodeControllerId : controllerId;

      var targetPumps = masterData.configObjects
          .where((e) => e.objectId == 5 && e.controllerId == targetControllerId)
          .toList();

      if (targetPumps.isEmpty) {
        targetPumps = masterData.configObjects
            .where((e) => e.objectId == 5)
            .toList();
      }

      if (targetPumps.isNotEmpty) {
        String m1 = "Motor 1";
        String m2 = "Motor 2";
        String m3 = "Motor 3";

        for (var pump in targetPumps) {
          if (pump.name.isNotEmpty) {
            if (pump.connectionNo == 1) {
              m1 = pump.name;
            } else if (pump.connectionNo == 2) {
              m2 = pump.name;
            } else if (pump.connectionNo == 3) {
              m3 = pump.name;
            }
          }
        }

        if (m1 == "Motor 1" && targetPumps.isNotEmpty && targetPumps[0].name.isNotEmpty) {
          m1 = targetPumps[0].name;
        }
        if (m2 == "Motor 2" && targetPumps.length > 1 && targetPumps[1].name.isNotEmpty) {
          m2 = targetPumps[1].name;
        }
        if (m3 == "Motor 3" && targetPumps.length > 2 && targetPumps[2].name.isNotEmpty) {
          m3 = targetPumps[2].name;
        }

        return [m1, m2, m3];
      }

      if (nodeControllerId != 0) {
        final matchingNode = masterData.nodeList
            .where((n) => n.controllerId == nodeControllerId)
            .firstOrNull;
        if (matchingNode != null && matchingNode.deviceName.isNotEmpty) {
          return [matchingNode.deviceName, matchingNode.deviceName, matchingNode.deviceName];
        }
      }
    }
    return ["Motor 1", "Motor 2", "Motor 3"];
  }

  Future<void> getUserPumpLog(userId, controllerId, nodeControllerId, [MasterControllerModel? masterData]) async {
    Map<String, dynamic> data = {
      "userId": userId,
      "controllerId": controllerId,
      "nodeControllerId": nodeControllerId,
      "fromDate": DateFormat("yyyy-MM-dd").format(selectedDate),
      "toDate": DateFormat("yyyy-MM-dd").format(selectedDate),
    };

    try {
      isLoading = true;
      final getPumpController = await repository.getUserPumpLog(data, nodeControllerId != 0);
      final response = jsonDecode(getPumpController.body);
      pumpLogData.clear();
      segments.clear();
      selectedIndex = 0;
      message = "";
      if (getPumpController.statusCode == 200) {
        if (response['data'] is List) {
          pumpLogData = (response['data'] as List).map((i) => PumpLogData.fromJson(i)).toList();
          final pumpNames = getPumpNames(masterData, nodeControllerId, controllerId);
          for (var i = 0; i < pumpLogData.length; i++) {
            print(pumpLogData[i].motor1);
            if (pumpLogData[i].motor1.isNotEmpty) {
              segments.addAll({0: pumpNames[0]});
            }
            if (pumpLogData[i].motor2.isNotEmpty) {
              segments.addAll({1: pumpNames[1]});
            }
            if (pumpLogData[i].motor3.isNotEmpty) {
              segments.addAll({2: pumpNames[2]});
            }
            if (pumpLogData[i].motor2.isNotEmpty) {
              selectedIndex = 1;
            } else if (pumpLogData[i].motor3.isNotEmpty) {
              selectedIndex = 2;
            } else {
              selectedIndex = 0;
            }
          }
        } else {
          message = '${response['message']}';
          // print('Data is not a List');
        }

        if (pumpLogData.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (scrollController.hasClients) {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      } else {
        // print('Failed to load data');
      }
      await Future.delayed(const Duration(seconds: 1));
      isLoading = false;
      notifyListeners();
      // print("isLoading in the pump log : $isLoading");
    } catch (e, stackTrace) {
      // print("$e");
      // print("stackTrace ==> $stackTrace");
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPumpControllerData({int selectedIndex = 0,
    required int userId, required int controllerId, required int nodeControllerId}) async {
    if (selectedIndex == 1) {
      dates = List.generate(7, (index) => DateTime.now().subtract(Duration(days: index)));
    } else if (selectedIndex == 2) {
      dates = List.generate(30, (index) => DateTime.now().subtract(Duration(days: index)));
    } else if(selectedIndex == 0){
      dates.last = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    } else {
      dates.last = DateTime.parse(dates.last.toString().split(' ')[0]);
    }

    var data = {
      "userId": userId,
      "controllerId": controllerId,
      "nodeControllerId": nodeControllerId,
      "fromDate": DateFormat("yyyy-MM-dd").format(selectedIndex == 0 ? selectedDate : dates.last),
      "toDate": DateFormat("yyyy-MM-dd").format(selectedIndex == 0 ? selectedDate : dates.first),
      "needSum" : selectedIndex != 0
    };
    try {
      chartData.clear();
      isLoading = true;
      final getPumpController = await repository.getUserPumpHourlyLog(data, nodeControllerId != 0);
      final response = jsonDecode(getPumpController.body);
      if (getPumpController.statusCode == 200) {
        // print(data);
        Future.delayed(const Duration(microseconds: 1000));
        if (response['data'] is List) {
          List<dynamic> dataList = response['data'];
          motorDataList = dataList.map((item) => MotorDataHourly.fromJson(item)).toList();
          for (var i = 0; i < motorDataList[0].numberOfPumps; i++) {
            List<Color> colors = [Colors.lightBlueAccent.shade100.withOpacity(0.6), Colors.lightGreenAccent.withOpacity(0.6), Colors.greenAccent.withOpacity(0.6)];
            chartData.add(
                MotorData(
                    "M${i + 1}",
                    [motorDataList[0].motorRunTime1, motorDataList[0].motorRunTime2, motorDataList[0].motorRunTime3][i],
                    colors[i]
                )
            );
          }

        } else {
          motorDataList = [];
          chartData = [];
          log('Data is not a List');
        }
      } else {
        chartData.clear();
        log('Failed to load data');
      }
      await Future.delayed(const Duration(seconds: 1));
      isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      chartData.clear();
      log("Error ==> $e");
      log("StackTrace ==> $stackTrace");
    }
    notifyListeners();
  }

  Future<void> getUserVoltageLog({required int userId, required int controllerId, required int nodeControllerId}) async {
    message = '';
    voltageData.clear();
    Map<String, dynamic> data = {
      "userId": userId,
      "controllerId": controllerId,
      "nodeControllerId": nodeControllerId,
      "fromDate": DateFormat("yyyy-MM-dd").format(selectedDate),
      "toDate": DateFormat("yyyy-MM-dd").format(selectedDate),
    };

    // print("getUserVoltageLog :: $data");
    try {
      isLoading = true;
      final getPumpController = await repository.getUserVoltageLog(data, nodeControllerId != 0);
      final response = jsonDecode(getPumpController.body);
      if (getPumpController.statusCode == 200) {
        if (response['data'] is List) {
          if(DateFormat("yyyy-MM-dd").format(selectedDate) == DateFormat("yyyy-MM-dd").format(DateTime.now())) {
            for(var i in response['data'][0]['voltageDetails']) {
              if(i['hour'] <= DateTime.now().hour) {
                voltageData.add(i);
              }
            }
          } else {
            voltageData = List<Map<String, dynamic>>.from(response['data'][0]['voltageDetails']);
          }
          message = "";
        } else {
          message = 'No data available for the selected date.';
        }
      } else {
        message = 'Failed to load data: ${response['message']}';
      }
      await Future.delayed(const Duration(seconds: 1));
      isLoading = false;
    } catch (e, stackTrace) {
      message = 'Error occurred: $e';
      // print("$e");
      // print("stackTrace ==> $stackTrace");
    }
    notifyListeners();
  }
}