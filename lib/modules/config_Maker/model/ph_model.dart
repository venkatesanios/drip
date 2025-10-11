import 'device_object_model.dart';

class PhModel{
  DeviceObjectModel commonDetails;
  int? controllerId;

  PhModel({
    required this.commonDetails,
    required this.controllerId,
  });

  factory PhModel.fromJson(dynamic data){
    DeviceObjectModel deviceObjectModel = DeviceObjectModel.fromJson(data);
    return PhModel(
        commonDetails: deviceObjectModel,
        controllerId: data['controllerId']
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
      'controllerId' : controllerId,
    });
    return commonInfo;
  }

}