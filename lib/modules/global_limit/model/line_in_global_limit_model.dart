import 'package:oro_drip_irrigation/modules/global_limit/model/valve_with_central_local_channel_model.dart';

class LineInGlobalLimitModel {
  final int objectId;
  final double sNo;
  final String name;
  final String objectName;
  ValveWithCentralLocalChannelModel valve;

  LineInGlobalLimitModel({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.objectName,
    required this.valve,
  });

  factory LineInGlobalLimitModel.fromJson(data){
    return LineInGlobalLimitModel(
        objectId: data['objectId'],
        sNo: data['sNo'],
        name: data['name'],
        objectName: data['objectName'],
        valve: ValveWithCentralLocalChannelModel.fromJson(data['valve']),
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "objectId" : objectId,
      "sNo" : sNo,
      "name" : name,
      "objectName" : objectName,
      "valve" : valve.toJson(),
    };
  }

}