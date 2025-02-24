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
        level: (data['level'] as int).toDouble(),
        pressureIn: (data['pressureIn'] as int).toDouble(),
        pressureOut: (data['pressureOut'] as int).toDouble(),
        waterMeter: (data['waterMeter'] as int).toDouble(),
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