import 'package:oro_drip_irrigation/modules/config_Maker/model/irrigationLine_model.dart';

import 'device_object_model.dart';

class SourceModel {
  DeviceObjectModel commonDetails;
  int sourceType;
  double level;
  double topFloat;
  double bottomFloat;
  List<double> inletPump;
  List<double> outletPump;
  List<double> valves;

  SourceModel({
    required this.commonDetails,
    this.sourceType = 1,
    this.level = 0.0,
    this.topFloat = 0.0,
    this.bottomFloat = 0.0,
    required this.inletPump,
    required this.outletPump,
    required this.valves,
  });

  factory SourceModel.fromJson(data){
    DeviceObjectModel deviceObjectModel = DeviceObjectModel.fromJson(data);

    return SourceModel(
        commonDetails: deviceObjectModel,
        sourceType: data['sourceType'],
        level: intOrDoubleValidate(data['level']),
        topFloat: intOrDoubleValidate(data['topFloat']),
        bottomFloat: intOrDoubleValidate(data['bottomFloat']),
        inletPump: (data['inletPump'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        outletPump: (data['outletPump'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        valves: (data['valves'] as List<dynamic>).map((sNo) => sNo as double).toList(),
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
      'sourceType' : sourceType,
      'level' : level,
      'topFloat' : topFloat,
      'bottomFloat' : bottomFloat,
      'inletPump' : inletPump,
      'outletPump' : outletPump,
      'valves' : valves,
    });
    return commonInfo;
  }

  SourceModel copy(){
    return SourceModel.fromJson(toJson());
  }

}

// tank type