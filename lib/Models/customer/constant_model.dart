import 'dart:convert';

class UserConstant {
  final ConstantData constant;
  final DefaultData defaultData;

  UserConstant({
    required this.constant,
    required this.defaultData,
  });

  factory UserConstant.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> configObject = [];

    if (json['default'] != null &&
        json['default']['configMaker'] != null &&
        json['default']['configMaker']['configObject'] != null) {

      configObject =  (json['default']['configMaker']['configObject'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } else {
      print("configObject is null or missing");
    }

    return UserConstant(
      constant: ConstantData.fromJson(json['constant'], configObject),
      defaultData: DefaultData.fromJson(json['default']),
    );
  }
}

class ConstantData {
  final String controllerReadStatus;
  final List<GeneralMenu> generalMenu;
  final List<Valve>? valveList;
  final List<Pump>? pumpList;

  ConstantData({
    required this.controllerReadStatus,
    required this.generalMenu,
    required this.valveList,
    required this.pumpList,
  });

  factory ConstantData.fromJson(Map<String, dynamic> jsonConstant, List<Map<String, dynamic>> jsonConfigObject) {

    List<Map<String, dynamic>> valveDataList = jsonConfigObject
        .where((obj) => obj['objectId'] == 13)
        .toList();

    List<Map<String, dynamic>> pumpDataList = jsonConfigObject
        .where((obj) => obj['objectId'] == 5)
        .toList();

    return ConstantData(
      controllerReadStatus: jsonConstant['controllerReadStatus'] ?? '0',
      generalMenu : (jsonConstant['general'] as List<dynamic>?)
          ?.map((general) => GeneralMenu.fromJson(general))
          .toList() ??
          [
            GeneralMenu.fromJson({"sNo": 1, "title": "Number of Programs", "widgetTypeId": 1, "value": "0"}),
            GeneralMenu.fromJson({"sNo": 2, "title": "Number of Valve Groups", "widgetTypeId": 1, "value": "0"}),
            GeneralMenu.fromJson({"sNo": 3, "title": "Number of Conditions", "widgetTypeId": 1, "value": "0"}),
            GeneralMenu.fromJson({"sNo": 4, "title": "Run List Limit", "widgetTypeId": 1, "value": "0"}),
            GeneralMenu.fromJson({"sNo": 5, "title": "Fertilizer Leakage Limit", "widgetTypeId": 1, "value": "0"}),
            GeneralMenu.fromJson({"sNo": 6, "title": "Reset Time", "widgetTypeId": 3, "value": "00:00:00"}),
            GeneralMenu.fromJson({"sNo": 7, "title": "No Pressure Delay", "widgetTypeId": 3, "value": "00:00:00"}),
            GeneralMenu.fromJson({"sNo": 8, "title": "Common dosing coefficient", "widgetTypeId": 1, "value": "0"}),
            GeneralMenu.fromJson({"sNo": 9, "title": "Water pulse before dosing", "widgetTypeId": 2, "value": false}),
            GeneralMenu.fromJson({"sNo": 10, "title": "Pump on after valve on", "widgetTypeId": 2, "value": false}),
            GeneralMenu.fromJson({"sNo": 11, "title": "Lora Key 1", "widgetTypeId": 1, "value": "0"}),
            GeneralMenu.fromJson({"sNo": 12, "title": "Lora Key 2", "widgetTypeId": 1, "value": "0"}),
          ],

      valveList: (jsonConstant['valve'] as List<dynamic>?)
          ?.map((general) => Valve.fromJson(general))
          .toList() ??
          valveDataList.map((valve) => Valve.fromJson(valve)).toList(),

      pumpList: (jsonConstant['pump'] as List<dynamic>?)?.isNotEmpty == true
          ? (jsonConstant['pump'] as List<dynamic>).map((pmp) => Pump.fromJson(pmp)).toList()
          : pumpDataList.map((pmp) => Pump.fromJson(pmp)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'controllerReadStatus': controllerReadStatus,
      'general': generalMenu.map((e) => e.toJson()).toList(),
      'valveList': valveList?.map((e) => e.toJson()).toList() ?? [],
      'pumpList': pumpList?.map((e) => e.toJson()).toList() ?? [],
    };
  }

}

class GeneralMenu {
  final int sNo;
  final String title;
  final int widgetTypeId;
  dynamic value;

  GeneralMenu({
    required this.sNo,
    required this.title,
    required this.widgetTypeId,
    required this.value,
  });

  factory GeneralMenu.fromJson(Map<String, dynamic> json) {
    return GeneralMenu(
      sNo: json['sNo'] as int,
      title: json['title'] as String,
      widgetTypeId: json['widgetTypeId'] as int,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'title': title,
      'widgetTypeId': widgetTypeId,
      'value': value,
    };
  }
}

class Valve {
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
  String txtValue;
  String pickerVal;

  Valve({
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
    required this.txtValue,
    required this.pickerVal,
  });

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
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
      txtValue: json.containsKey('txtValue') ? json['txtValue'] : "0",
      pickerVal: json.containsKey('pickerVal') ? json['pickerVal'] : "00:00:00",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'connectionNo': connectionNo,
      'count': count,
      'connectedObject': connectedObject,
      'siteMode': siteMode,
      'txtValue': txtValue,
      'pickerVal': pickerVal,
    };
  }
}

class Pump {
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
  bool pumpStation;
  bool controlGem;

  Pump({
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
    required this.pumpStation,
    required this.controlGem,
  });

  factory Pump.fromJson(Map<String, dynamic> json) {
    return Pump(
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
      pumpStation: json.containsKey('pumpStation') ? json['pumpStation'] : false,
      controlGem: json.containsKey('controlGem') ? json['controlGem'] : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'connectionNo': connectionNo,
      'count': count,
      'connectedObject': connectedObject,
      'siteMode': siteMode,
      'pumpStation': pumpStation,
      'controlGem': controlGem,
    };
  }
}

class DefaultData {
  final List<Alarm> alarms;
  final List<ConstantMenu> constantMenus;

  DefaultData({
    required this.alarms,
    required this.constantMenus,
  });

  factory DefaultData.fromJson(Map<String, dynamic> json) {
    return DefaultData(
      alarms: (json['alarm'] as List).map((e) => Alarm.fromJson(e)).toList(),
      constantMenus: (json['constantMenu'] as List)
          .map((e) => ConstantMenu.fromJson(e)).toList(),
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
