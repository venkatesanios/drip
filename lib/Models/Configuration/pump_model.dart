import 'device_object_model.dart';

class PumpModel{
  DeviceObjectModel commonDetails;
  int? level;
  int? pressure;

  PumpModel({
    required this.commonDetails,
    required this.level,
    required this.pressure
  });

  factory PumpModel.fromJson(dynamic data){
    return PumpModel(
        commonDetails: data,
        level: data['level'],
        pressure: data['pressure']
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
      'level' : level,
      'pressure' : pressure,
    });
    return commonInfo;
  }
}