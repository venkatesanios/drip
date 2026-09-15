import 'device_object_model.dart';

class ChannelConfigModel{
  DeviceObjectModel commonDetails;
  double dosingMeter;

  ChannelConfigModel({
    required this.commonDetails,
    this.dosingMeter = 0.0,
  });

  factory ChannelConfigModel.fromJson(dynamic data){
    DeviceObjectModel deviceObjectModel = DeviceObjectModel.fromJson(data);
    return ChannelConfigModel(
        commonDetails: deviceObjectModel,
        dosingMeter: data['dosingMeter'] ?? 0.0
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
      'dosingMeter' : dosingMeter,
    });
    return commonInfo;
  }

  void updateObjectIdIfDeletedInProductLimit(List<double> objectIdToBeDeleted){
    dosingMeter = objectIdToBeDeleted.contains(dosingMeter) ? 0.0 : dosingMeter;
  }
}