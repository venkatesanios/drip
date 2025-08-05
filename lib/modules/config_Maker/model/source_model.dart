import 'package:oro_drip_irrigation/modules/config_Maker/model/irrigationLine_model.dart';

import 'device_object_model.dart';

class SourceModel {
  DeviceObjectModel commonDetails;
  int sourceType;
  double level;
  double topFloatForInletPump;
  double bottomFloatForInletPump;
  double topFloatForOutletPump;
  double bottomFloatForOutletPump;
  List<double> inletPump;
  List<double> outletPump;
  List<double> valves;

  SourceModel({
    required this.commonDetails,
    this.sourceType = 1,
    this.level = 0.0,
    this.topFloatForInletPump = 0.0,
    this.bottomFloatForInletPump = 0.0,
    this.topFloatForOutletPump = 0.0,
    this.bottomFloatForOutletPump = 0.0,
    required this.inletPump,
    required this.outletPump,
    required this.valves,
  });

  void updateObjectIdIfDeletedInProductLimit(List<double> objectIdToBeDeleted){
    inletPump = inletPump.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    outletPump = outletPump.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    valves = valves.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    level = objectIdToBeDeleted.contains(level) ? 0.0 : level;
    topFloatForInletPump = objectIdToBeDeleted.contains(topFloatForInletPump) ? 0.0 : topFloatForInletPump;
    bottomFloatForInletPump = objectIdToBeDeleted.contains(bottomFloatForInletPump) ? 0.0 : bottomFloatForInletPump;
    topFloatForOutletPump = objectIdToBeDeleted.contains(topFloatForOutletPump) ? 0.0 : topFloatForOutletPump;
    bottomFloatForOutletPump = objectIdToBeDeleted.contains(bottomFloatForOutletPump) ? 0.0 : bottomFloatForOutletPump;
  }

  factory SourceModel.fromJson(data){
    DeviceObjectModel deviceObjectModel = DeviceObjectModel.fromJson(data);

    return SourceModel(
        commonDetails: deviceObjectModel,
        sourceType: data['sourceType'],
        level: intOrDoubleValidate(data['level']),
        topFloatForInletPump: intOrDoubleValidate(data['topFloatForInletPump'] ?? 0.0),
        bottomFloatForInletPump: intOrDoubleValidate(data['bottomFloatForInletPump'] ?? 0.0),
        topFloatForOutletPump: intOrDoubleValidate(data['topFloatForOutletPump'] ?? 0.0),
        bottomFloatForOutletPump: intOrDoubleValidate(data['bottomFloatForOutletPump'] ?? 0.0),
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
      'topFloatForInletPump' : topFloatForInletPump,
      'bottomFloatForInletPump' : bottomFloatForInletPump,
      'topFloatForOutletPump' : topFloatForOutletPump,
      'bottomFloatForOutletPump' : bottomFloatForOutletPump,
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