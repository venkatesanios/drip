import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import '../modal_in_constant.dart';

class ConstantProvider with ChangeNotifier {
  List<Map<String, dynamic>> generalUpdated = [];
  List<AlarmNew> overAllAlarm = [];

  void setGeneralUpdated(List<Map<String, dynamic>> updatedData) {
    generalUpdated = updatedData;
    notifyListeners();
  }

  void updateGeneralValue(int index, dynamic newValue) {
    if (index < 0 || index >= generalUpdated.length) return;

    // Create a mutable copy of the entry
    generalUpdated[index] = Map.from(generalUpdated[index]);
    generalUpdated[index]['value'] = newValue;

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

/*
List<Alarm> normalAlarm = [];
List<Alarm> criticalAlarm = [];

void updateAlarm(alarmData) {
  for (var alarm in alarmData) {
    normalAlarm.add(
        Alarm.fromJson(alarm)
    );
    criticalAlarm.add(
        Alarm.fromJson(alarm)
    );
  }
  print('alarm data updated');
  notifyListeners();
}*/
