import 'package:oro_drip_irrigation/config_maker/model/irrigationLine_model.dart';

import 'device_object_model.dart';

class PumpModel{
  DeviceObjectModel commonDetails;
  double level;
  double pressureIn;
  double pressureOut;
  double waterMeter;
  int pumpType;

  PumpModel({
    required this.commonDetails,
    this.level = 0.0,
    this.pressureIn = 0.0,
    this.pressureOut = 0.0,
    this.waterMeter = 0.0,
    this.pumpType = 1,
  });

  factory PumpModel.fromJson(dynamic data){
    DeviceObjectModel deviceObjectModel = DeviceObjectModel.fromJson(data);
    return PumpModel(
        commonDetails: deviceObjectModel,
        level: intOrDoubleValidate(data['level']),
        pressureIn: intOrDoubleValidate(data['pressureIn']),
        pressureOut: intOrDoubleValidate(data['pressureOut']),
        waterMeter: intOrDoubleValidate(data['waterMeter']),
        pumpType: data['pumpType']
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
      'level' : level,
      'pressureIn' : pressureIn,
      'pressureOut' : pressureOut,
      'waterMeter' : waterMeter,
      'pumpType' : pumpType,
    });
    return commonInfo;
  }

}