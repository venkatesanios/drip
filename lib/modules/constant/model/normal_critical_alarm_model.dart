import 'package:oro_drip_irrigation/modules/constant/model/constant_setting_type_Model.dart';

import 'alarm_in_constant_model.dart';
import 'object_in_constant_model.dart';

class NormalCriticalAlarmModel{
  final int objectId;
  final double sNo;
  final String name;
  final String objectName;
  final double location;
  List<AlarmInConstantModel> normal;
  List<AlarmInConstantModel> critical;

  NormalCriticalAlarmModel({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.objectName,
    required this.location,
    required this.normal,
    required this.critical,
  });

  factory NormalCriticalAlarmModel.fromJson({
    required objectData,
    required List<dynamic> defaultSetting,
    required List<dynamic> globalAlarm,
    required Map<String, dynamic>? oldSetting,
  }){
    return NormalCriticalAlarmModel(
        objectId: objectData['objectId'],
        sNo: objectData['sNo'],
        name: objectData['name'],
        objectName: objectData['objectName'],
        location: objectData['location'],
        normal: globalAlarm.map((alarm){
          return AlarmInConstantModel.fromJson(
              objectData: alarm,
              defaultSetting: defaultSetting,
              oldSetting: oldSetting == null ? [] : oldSetting['normal']
          );
        }).toList(),
        critical: globalAlarm.map((alarm){
          return AlarmInConstantModel.fromJson(
              objectData: alarm,
              defaultSetting: defaultSetting,
              oldSetting: oldSetting == null ? [] : oldSetting['critical']
          );
        }).toList(),
      );
  }

  Map<String, dynamic> toJson(){
    return {
      'objectId' : objectId,
      'sNo' : sNo,
      'name' : name,
      'objectName' : objectName,
      'location' : location,
      'normal' : normal.map((alarm) {
        return alarm.toJson();
      }).toList(),
      'critical' : critical.map((alarm) {
        return alarm.toJson();
      }).toList(),
    };
  }

}