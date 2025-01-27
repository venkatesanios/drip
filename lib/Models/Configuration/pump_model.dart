import 'device_object_model.dart';

class PumpModel{
  DeviceObjectModel commonDetails;
  double level;
  double pressure;
  double waterMeter;
  int pumpType;

  PumpModel({
    required this.commonDetails,
    this.level = 0.0,
    this.pressure = 0.0,
    this.waterMeter = 0.0,
    this.pumpType = 0,
  });

  factory PumpModel.fromJson(dynamic data){
    DeviceObjectModel deviceObjectModel = DeviceObjectModel.fromJson(data);
    return PumpModel(
        commonDetails: deviceObjectModel,
        level: data['level'],
        pressure: data['pressure'],
        waterMeter: data['waterMeter'],
        pumpType: data['pumpType']
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
      'level' : level,
      'pressure' : pressure,
      'waterMeter' : waterMeter,
      'pumpType' : pumpType,
    });
    return commonInfo;
  }

}