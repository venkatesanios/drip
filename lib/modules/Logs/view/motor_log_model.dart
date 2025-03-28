import 'event_log_model.dart';

class MotorLogs {
  final List<EventLog> motor1;
  final List<EventLog> motor2;
  final List<EventLog> motor3;

  MotorLogs({required this.motor1, required this.motor2, required this.motor3});

  factory MotorLogs.fromJson(Map<String, dynamic> json) {
    List<EventLog> motor1Data = (json['motor1'] as List<dynamic>)
        .map((e) => EventLog.fromJson(e as String))
        .toList();
    List<EventLog> motor2Data = (json['motor2'] as List<dynamic>)
        .map((e) => EventLog.fromJson(e as String))
        .toList();
    List<EventLog> motor3Data = (json['motor3'] as List<dynamic>)
        .map((e) => EventLog.fromJson(e as String))
        .toList();
    return MotorLogs(
      motor1: motor1Data,
      motor2: motor2Data,
      motor3: motor3Data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'motor1': motor1,
      'motor2': motor2,
      'motor3': motor3,
    };
  }
}