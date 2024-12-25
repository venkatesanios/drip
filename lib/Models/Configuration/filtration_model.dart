import 'device_object_model.dart';

class FiltrationModel {
  DeviceObjectModel commonDetails;
  int? siteMode;
  List<int>? filters;
  int? pressureIn;
  int? pressureOut;
  int? backWashValve;

  FiltrationModel({
    required this.commonDetails,
    required this.siteMode,
    required this.filters,
    required this.pressureIn,
    required this.pressureOut,
    required this.backWashValve,
  });

  factory FiltrationModel.fromJson(data){
    return FiltrationModel(
        commonDetails: data,
        siteMode: data['siteMode'],
        filters: data['filters'],
        pressureIn: data['pressureIn'],
        pressureOut: data['pressureOut'],
        backWashValve: data['backWashValve'],
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