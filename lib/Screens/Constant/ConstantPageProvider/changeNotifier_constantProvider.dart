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

  void updateGeneralValue(int index, String newValue) {
    generalUpdated[index]['value'] = newValue;
    notifyListeners();
  }

  void updateTime(int index, String field, String value) {
    if (index >= 0 && index < overAllAlarm.length) {
      AlarmNew updatedAlarm = overAllAlarm[index].copyWith(
        scanTime: field == "scanTime" ? value : overAllAlarm[index].scanTime,
        autoResetDuration: field == "autoResetDuration" ? value : overAllAlarm[index].autoResetDuration,
      );

      overAllAlarm[index] = updatedAlarm;
      notifyListeners();
    }
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
