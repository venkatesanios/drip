import 'dart:convert';

class UserConstant {
  final ConstantData constant;
  final DefaultData defaultData;

  UserConstant({
    required this.constant,
    required this.defaultData,
  });

  factory UserConstant.fromJson(Map<String, dynamic> json) {
    return UserConstant(
      constant: ConstantData.fromJson(json['constant']),
      defaultData: DefaultData.fromJson(json['default']),
    );
  }
}

class ConstantData {
  final String controllerReadStatus;

  ConstantData({
    required this.controllerReadStatus,
  });

  factory ConstantData.fromJson(Map<String, dynamic> json) {
    return ConstantData(
      controllerReadStatus: json['controllerReadStatus'] ?? '0',
    );
  }
}

class DefaultData {
  final List<Alarm> alarms;
  final List<ConstantMenu> constantMenus;
  final ConfigMaker configMaker;

  DefaultData({
    required this.alarms,
    required this.constantMenus,
    required this.configMaker,
  });

  factory DefaultData.fromJson(Map<String, dynamic> json) {
    return DefaultData(
      alarms: (json['alarm'] as List).map((e) => Alarm.fromJson(e)).toList(),
      constantMenus: (json['constantMenu'] as List)
          .map((e) => ConstantMenu.fromJson(e))
          .toList(),
      configMaker: ConfigMaker.fromJson(json['configMaker']),
    );
  }
}

class Alarm {
  final int sNo;
  final String name;
  final String unit;
  final bool value;

  Alarm({
    required this.sNo,
    required this.name,
    required this.unit,
    required this.value,
  });

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      sNo: json['sNo'],
      name: json['name'],
      unit: json['unit'],
      value: json['value'],
    );
  }
}

class ConstantMenu {
  final int dealerDefinitionId;
  final String parameter;
  final String value;
  bool isSelected;

  ConstantMenu({
    required this.dealerDefinitionId,
    required this.parameter,
    required this.value,
    this.isSelected = false,
  });

  factory ConstantMenu.fromJson(Map<String, dynamic> json) {
    return ConstantMenu(
      dealerDefinitionId: json['dealerDefinitionId'],
      parameter: json['parameter'],
      value: json['value'],
    );
  }
}

class ConfigMaker {
  final String isNewConfig;
  final List<ConfigObject> configObjects;

  ConfigMaker({
    required this.isNewConfig,
    required this.configObjects,
  });

  factory ConfigMaker.fromJson(Map<String, dynamic> json) {
    return ConfigMaker(
      isNewConfig: json['isNewConfig'],
      configObjects: (json['configObject'] as List)
          .map((e) => ConfigObject.fromJson(e))
          .toList(),
    );
  }
}

class ConfigObject {
  final int objectId;
  final double sNo;
  final String name;
  final String objectName;
  final String type;
  final int? controllerId;
  final int? connectionNo;
  final int? count;
  final String? connectedObject;
  final String? siteMode;

  ConfigObject({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.objectName,
    required this.type,
    this.controllerId,
    this.connectionNo,
    this.count,
    this.connectedObject,
    this.siteMode,
  });

  factory ConfigObject.fromJson(Map<String, dynamic> json) {
    return ConfigObject(
      objectId: json['objectId'],
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      connectionNo: json['connectionNo'],
      count: json['count'],
      connectedObject: json['connectedObject'],
      siteMode: json['siteMode'],
    );
  }
}

UserConstant parseUserConstant(String responseBody) {
  final Map<String, dynamic> jsonData = json.decode(responseBody)['data'];
  return UserConstant.fromJson(jsonData);
}