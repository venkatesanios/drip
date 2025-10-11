import 'device_object_model.dart';

class EcModel{
  DeviceObjectModel commonDetails;
  int? controllerId;

  EcModel({
    required this.commonDetails,
    required this.controllerId,
  });

  factory EcModel.fromJson(dynamic data){
    DeviceObjectModel deviceObjectModel = DeviceObjectModel.fromJson(data);
    return EcModel(
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