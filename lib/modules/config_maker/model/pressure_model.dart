import 'device_object_model.dart';

class PressureModel{
  DeviceObjectModel commonDetails;
  List<double> valves;
  List<double> mainValve;

  PressureModel({
    required this.commonDetails,
    required this.valves,
    required this.mainValve,
  });

  factory PressureModel.fromJson(dynamic data){
    DeviceObjectModel deviceObjectModel = DeviceObjectModel.fromJson(data);
    return PressureModel(
        commonDetails: deviceObjectModel,
        valves: (data['valves'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        mainValve: data['mainValve'] != null ? (data['mainValve'] as List<dynamic>).map((sNo) => sNo as double).toList() : []
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
      'valves' : valves,
      'mainValve' : mainValve,
    });
    return commonInfo;
  }

  void updateObjectIdIfDeletedInProductLimit(List<double> objectIdToBeDeleted){
    valves = valves.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    mainValve = mainValve.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
  }

  bool isPressureModelParameterIsEmpty(){
    if(valves.isEmpty && mainValve.isEmpty){
      return true;
    }
    return false;
  }
}