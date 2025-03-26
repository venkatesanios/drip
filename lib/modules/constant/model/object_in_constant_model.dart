import 'package:oro_drip_irrigation/modules/constant/model/constant_setting_model.dart';

class ObjectInConstantModel{
  final int objectId;
  final double sNo;
  final String name;
  final String objectName;
  final double location;
  List<ConstantSettingModel> setting = [];

  ObjectInConstantModel({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.objectName,
    required this.location,
    required this.setting,
  });

  factory ObjectInConstantModel.fromJson({
    required objectData,
    required List<dynamic> defaultSetting,
    required List<dynamic> oldSetting
  }){
    return ObjectInConstantModel(
        objectId: objectData['objectId'],
        sNo: objectData['sNo'],
        name: objectData['name'],
        objectName: objectData['objectName'],
        location: objectData['location'],
        setting : defaultSetting.map((setting){
          List<dynamic> oldData = oldSetting.where((oldSetting) => oldSetting['sNo'] == setting['sNo']).toList();
          return ConstantSettingModel.fromJson(setting, oldData.firstOrNull);
        }).toList()
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'objectId' : objectId,
      'sNo' : sNo,
      'name' : name,
      'objectName' : objectName,
      'location' : location,
      'setting' : setting.map((setting) => setting.toJson()).toList()
    };
  }
}