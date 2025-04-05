import 'package:flutter/material.dart';

class EventLog {
  final String onReason;
  final String offReason;
  final String onTime;
  final String offTime;
  final String duration;
  final Color background;
  final bool isAllDay;

  EventLog({
    required this.onReason,
    required this.offReason,
    required this.onTime,
    required this.offTime,
    required this.duration,
    required this.background,
    required this.isAllDay
  });

  factory EventLog.fromJson(String data) {
    // print("data in the event model ==> $data");
    return EventLog(
      onReason: data.split(",")[0],
      onTime: data.split(",")[1],
      offReason: data.split(",")[2],
      offTime: data.split(",")[3],
      duration: data.split(",")[4],
      background: data.split(",")[0].contains("ON") ? Colors.green : Colors.red,
      isAllDay: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "onReason": onReason,
      "offReason": offReason,
      "onTime": onTime,
      "offTime": offTime,
      "duration": duration,
      "background": background,
      "isAllDay": isAllDay,
    };
  }
}