import 'device_object_model.dart';
import 'irrigationLine_model.dart';

class FiltrationModel {
  DeviceObjectModel commonDetails;
  int siteMode;
  List<double> filters;
  double pressureIn;
  double pressureOut;
  double backWashValve;

  FiltrationModel({
    required this.commonDetails,
    this.siteMode = 1,
    required this.filters,
    this.pressureIn = 0.0,
    this.pressureOut = 0.0,
    this.backWashValve = 0.0,
  });

  factory FiltrationModel.fromJson(data){
    DeviceObjectModel deviceObjectModel = DeviceObjectModel.fromJson(data);
    return FiltrationModel(
        commonDetails: deviceObjectModel,
        siteMode: data['siteMode'],
        filters: (data['filters'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        pressureIn: intOrDoubleValidate(data['pressureIn']),
        pressureOut: intOrDoubleValidate(data['pressureOut']) ,
        backWashValve: intOrDoubleValidate(data['backWashValve']),
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
      'siteMode' : siteMode,
      'filters' : filters,
      'pressureIn' : pressureIn,
      'pressureOut' : pressureOut,
      'backWashValve' : backWashValve,
    });
    return commonInfo;
  }
}