import '../../utils/constants.dart';

class SiteModel {
  final List<Group> data;

  SiteModel({required this.data});

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      data: List<Group>.from(json['data'].map((x) => Group.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}

class Group {
  final int groupId;
  final String groupName;
  final List<Master> master;

  Group({required this.groupId, required this.groupName, required this.master});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['userGroupId'],
      groupName: json['groupName'],
      master: List<Master>.from(json['master'].map((x) => Master.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userGroupId': groupId,
      'groupName': groupName,
      'master': master.map((x) => x.toJson()).toList(),
    };
  }
}

class Master {
  final int controllerId;
  final String deviceId;
  final String deviceName;
  final int categoryId;
  final String categoryName;
  final int modelId;
  final String modelName;
  final List<Unit> units;
  final Config config;
  List<ConfigObject> configObjects;
  final Live? live;
  List<NodeDataList> nodeList;

  Master({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.categoryId,
    required this.categoryName,
    required this.modelId,
    required this.modelName,
    required this.units,
    required this.config,
    required this.configObjects,
    required this.live,
    required this.nodeList,
  });

  factory Master.fromJson(Map<String, dynamic> json) {
    List<ConfigObject> configObjects = json["config"]['configObject'] != null
        ? (json["config"]['configObject'] as List)
        .map((item) => ConfigObject.fromJson(item))
        .toList()
        : [];

    return Master(
      controllerId: json['controllerId'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      modelId: json['modelId'],
      modelName: json['modelName'],
      units: List<Unit>.from(json['units'].map((x) => Unit.fromJson(x))),
      config: (json["config"] != null && json["config"] is Map<String, dynamic> && json["config"].isNotEmpty)
          ? Config.fromJson(Map<String, dynamic>.from(AppConstants().payloadConversion(json["config"])))
          : Config(waterSource: [], pump: [], filterSite: [], fertilizerSite: [], moistureSensor: [], lineData: []),
      configObjects: configObjects,
      live: json['liveMessage'] != null ? Live.fromJson(json['liveMessage']) : null,
      nodeList: json['nodeList'] != null
          ? (json['nodeList'] as List)
          .map((item) => NodeDataList.fromJson(item, configObjects))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'controllerId': controllerId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'modelId': modelId,
      'modelName': modelName,
      'units': units.map((x) => x.toJson()).toList(),
      'config': config,
      'liveMessage': live?.toJson(),
    };
  }
}

class RelayStatus {
  final double? sNo;
  final String? name;
  String? swName;
  final int? rlyNo;
  int status;

  RelayStatus({
    required this.sNo,
    required this.name,
    required this.swName,
    required this.rlyNo,
    this.status=0,
  });

  factory RelayStatus.fromJson(Map<String, dynamic> json) {
    return RelayStatus(
      sNo: json['sNo'],
      name: json['name'],
      swName: json['name'] ?? json['objectName'],
      rlyNo: json['connectionNo'],
    );
  }

}

class Unit {
  final int dealerDefinitionId;
  final String parameter;
  final String value;

  Unit({required this.dealerDefinitionId, required this.parameter, required this.value});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      dealerDefinitionId: json['dealerDefinitionId'],
      parameter: json['parameter'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dealerDefinitionId': dealerDefinitionId,
      'parameter': parameter,
      'value': value,
    };
  }
}

class ConfigObject {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final int? count;

  ConfigObject({
    required this.objectId,
    required this.sNo,
    required this.name,
    this.connectionNo,
    required this.objectName,
    required this.type,
    this.controllerId,
    this.count,
  });

  factory ConfigObject.fromJson(Map<String, dynamic> json) {
    return ConfigObject(
      objectId: json['objectId'],
      sNo: (json['sNo'] as num).toDouble(), // Ensures proper double conversion
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
    };
  }
}

class Config {
  final List<WaterSource> waterSource;
  final List<Pump> pump;
  final List<dynamic> filterSite;
  final List<FertilizerSite> fertilizerSite;
  final List<dynamic> moistureSensor;
  final List<IrrigationLineData> lineData;

  Config({
    required this.waterSource,
    required this.pump,
    required this.filterSite,
    required this.fertilizerSite,
    required this.moistureSensor,
    required this.lineData,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      waterSource: (json['waterSource'] as List)
          .map((e) => WaterSource.fromJson(e))
          .toList(),
      pump: (json['pump'] as List).map((e) => Pump.fromJson(e)).toList(),
      filterSite: json['filterSite'] ?? [],
      fertilizerSite: (json['fertilizerSite'] as List)
          .map((e) => FertilizerSite.fromJson(e))
          .toList(),
      moistureSensor: json['moistureSensor'] ?? [],
      lineData: (json['irrigationLine'] != null && json['irrigationLine'] is List && json['irrigationLine'].isNotEmpty)
          ? (json['irrigationLine'] as List)
          .map((e) => IrrigationLineData.fromJson(e))
          .toList()
          : [],
    );
  }
}

class WaterSource {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final dynamic count;
  final Level? level;
  final List<Pump> outletPump;
  final List<dynamic> valves;

  WaterSource({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    required this.count,
    required this.level,
    required this.outletPump,
    required this.valves,
  });

  factory WaterSource.fromJson(Map<String, dynamic> json) {
    return WaterSource(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'] ?? 0,
      count: json['count'] ?? 0,
      level: json['level'] != null && json['level'].isNotEmpty
          ? Level.fromJson(json['level'])
          : null,
      outletPump: (json['outletPump'] as List)
          .map((e) => Pump.fromJson(e))
          .toList(),
      valves: json['valves'] ?? [],
    );
  }
}

class Pump {
  final int objectId;
  final double sNo;
  final String name;
  final int connectionNo;
  final String objectName;
  final String type;
  final int controllerId;
  final dynamic count;
  int status;

  Pump({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    required this.count,
    this.status=0,
  });

  factory Pump.fromJson(Map<String, dynamic> json) {
    return Pump(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
    );
  }
}

class FertilizerSite {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final dynamic count;
  final int siteMode;

  FertilizerSite({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    required this.count,
    required this.siteMode,
  });

  factory FertilizerSite.fromJson(Map<String, dynamic> json) {
    return FertilizerSite(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
      siteMode: json['siteMode'],
    );
  }
}

class IrrigationLineData {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final dynamic count;
  final List<Pump> irrigationPump;
  final List<Valve> valves;

  IrrigationLineData({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    required this.count,
    required this.irrigationPump,
    required this.valves,
  });

  factory IrrigationLineData.fromJson(Map<String, dynamic> json) {
    return IrrigationLineData(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
      irrigationPump: (json['irrigationPump'] as List)
          .map((e) => Pump.fromJson(e))
          .toList(),
      valves: (json['valve'] as List).map((v) => Valve.fromJson(v))
          .toList(),
    );
  }
}

class Valve {
  final int objectId;
  final double sNo;
  final String name;
  final int connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final int? count;
  int status;

  Valve({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.count,
    this.status = 0
  });

  factory Valve.fromJson(Map<String, dynamic> json) {
    print(json);
    return Valve(
      objectId: json['objectId'],
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId']??0,
      count: json['count']??0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
      "status": status,
    };
  }
}

class Level {
  int? objectId;
  double? sNo;
  String? name;
  String? percentage;
  int? connectionNo;
  int? controllerId;

  Level({
    this.objectId,
    this.sNo,
    this.name,
    this.percentage='0',
    this.connectionNo,
    this.controllerId,
  });

  factory Level.fromJson(Map<String, dynamic> json) => Level(
    objectId: json['objectId'],
    sNo: json['sNo'],
    name: json['name'],
    //percentage: json['percentage'],
    connectionNo: json['connectionNo'],
    controllerId: json['controllerId'],
  );
}

class Item {
  int? objectId;
  double? sNo;
  String? name;
  int status;

  Item({this.objectId, this.sNo, this.name, this.status = 0});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    objectId: json['objectId'],
    sNo: json['sNo'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {
    "objectId": objectId,
    "sNo": sNo,
    "name": name,
    "status": status,
  };
}

class Live {
  final String cC;
  final String cD;
  final String cT;

  Live({required this.cC, required this.cD, required this.cT});

  factory Live.fromJson(Map<String, dynamic> json) {
    return Live(
      cC: json['cC'],
      cD: json['cD'],
      cT: json['cT'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cC': cC,
      'cD': cD,
      'cT': cT,
    };
  }
}

class NodeDataList{
  int controllerId;
  String deviceId;
  String deviceName;
  int categoryId;
  String categoryName;
  int modelId;
  String modelName;
  int serialNumber;
  int referenceNumber;
  int interfaceTypeId;
  String interface;
  String? extendControllerId;
  int status;
  String communicationCount;
  String lastFeedbackReceivedTime;
  double sVolt;
  double batVolt;
  List<RelayStatus> rlyStatus;

  NodeDataList({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.categoryId,
    required this.categoryName,
    required this.modelId,
    required this.modelName,
    required this.serialNumber,
    required this.referenceNumber,
    required this.interfaceTypeId,
    required this.interface,
    required this.extendControllerId,
    this.status = 0,
    this.communicationCount = '0,0',
    this.lastFeedbackReceivedTime = '',
    this.sVolt = 0.0,
    this.batVolt = 0.0,
    required this.rlyStatus,
  });

  factory NodeDataList.fromJson(Map<String, dynamic> json, List<ConfigObject> configObjects) {

    List<ConfigObject> filteredConfigObjects =
    configObjects.where((config) => config.controllerId == json['controllerId']).toList();
    List<RelayStatus> rlyStatus = filteredConfigObjects.map((config) => RelayStatus.fromJson(config.toJson())).toList();

    return NodeDataList(
      controllerId: json['controllerId'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      modelId: json['modelId'],
      modelName: json['modelName'],
      serialNumber: json['serialNumber'],
      referenceNumber: json['referenceNumber'],
      interfaceTypeId: json['interfaceTypeId'] ?? 0,
      interface: json['interface'] ?? '',
      extendControllerId: json['extendControllerId'] ?? '',
      rlyStatus: rlyStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'controllerId': controllerId,
      'DeviceId': deviceId,
      'deviceName': deviceName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'modelId': modelId,
      'modelName': modelName,
      'serialNumber': serialNumber,
      'referenceNumber': referenceNumber,
      'InterfaceType': interfaceTypeId,
      'interface': interface,
      'Status': status,
    };
  }
}