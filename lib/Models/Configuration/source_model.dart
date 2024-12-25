import 'device_object_model.dart';

class SourceModel {
  DeviceObjectModel commonDetails;
  int sourceType;
  int level;
  int topFloat;
  int bottomFloat;
  final List<int> inletPump;
  final List<int> outletPump;
  final List<int> valves;

  SourceModel({
    required this.commonDetails,
    required this.sourceType,
    required this.level,
    required this.topFloat,
    required this.bottomFloat,
    required this.inletPump,
    required this.outletPump,
    required this.valves,
  });

  factory SourceModel.fromJson(data){
    return SourceModel(
        commonDetails: data,
        sourceType: data['sourceType'],
        level: data['level'],
        topFloat: data['topFloat'],
        bottomFloat: data['bottomFloat'],
        inletPump: data['inletPump'],
        outletPump: data['outletPump'],
        valves: data['valves']
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

}

// tank type