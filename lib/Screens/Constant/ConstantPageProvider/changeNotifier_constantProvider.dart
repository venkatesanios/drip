import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import '../modal_in_constant.dart';

class ConstantProvider with ChangeNotifier {
  List<Map<String, dynamic>> generalUpdated = [];
  List<AlarmNew> overAllAlarm = [];
  List<Pump> pumps = [];
  List<Valve> valves = [];
  List<IrrigationLine> irrigationLines = [];
  List<MainValve> mainValves = [];
  List<EC> ec = [];
  List<PH> ph = [];

  void updateData(Map<String, dynamic> newData) {
    pumps = (newData['pump'] as List)
        .map((item) => Pump.fromJson(item))
        .toList();
    valves = (newData['valve'] as List)
        .map((item) => Valve.fromJson(item))
        .toList();
    irrigationLines = (newData['line'] as List)
        .map((item) => IrrigationLine.fromJson(item))
        .toList();
    mainValves = (newData['mainValve'] as List)
        .map((item) => MainValve.fromJson(item))
        .toList();
    ec = (newData['ecPh'] as List)
        .map((item) => EC.fromJson(item))
        .toList();
    ph = (newData['ecPh'] as List)
        .map((item) => PH.fromJson(item))
        .toList();
    fertilizerSite = (newData['fertilization'] as List)
        .map((item) => FertilizerSite.fromJson(item))
        .toList();
    overAllAlarm = (newData['normalAlarm'] as List)
        .map((item) => AlarmNew.fromMap(item))
        .toList();


    notifyListeners();
  }

  List<FertilizerSite> fertilizerSite = [];
  void setGeneralUpdated(List<Map<String, dynamic>> updatedData) {
    generalUpdated = updatedData;
    notifyListeners();
  }

  void updateGeneralValue(int index, Map<String, dynamic> newValue) {
    generalUpdated[index] = newValue;
    notifyListeners();
  }

  void updateTime(int index, String field, String newValue) {
    if (field == "scanTime") {
      overAllAlarm[index] = overAllAlarm[index].copyWith(scanTime: newValue);
    } else if (field == "autoResetDuration") {
      overAllAlarm[index] = overAllAlarm[index].copyWith(autoResetDuration: newValue);
    }

    print("✅ Updated $field to: ${overAllAlarm[index].scanTime}"); // Debugging output
    notifyListeners(); // Ensure UI updates correctly
  }

}

