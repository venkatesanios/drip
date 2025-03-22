


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
  final List<ValveData>? valveList;
  final List<Pump>? pumpList;
  final List<MainValveData>? mainValveList;
  final List<IrrigationLine>? irrigationLineList;

  ConstantData({
    required this.controllerReadStatus,
    required this.generalMenu,
    required this.valveList,
    required this.pumpList,
    required this.mainValveList,
    required this.irrigationLineList,
  });

  factory ConstantData.fromJson(Map<String, dynamic> jsonConstant, List<Map<String, dynamic>> jsonConfigObject) {

    List<Map<String, dynamic>> valveDataList = jsonConfigObject
        .where((obj) => obj['objectId'] == 13)
        .toList();

    List<Map<String, dynamic>> pumpDataList = jsonConfigObject
        .where((obj) => obj['objectId'] == 5)
        .toList();

    List<Map<String, dynamic>> mainValveDataList = jsonConfigObject
        .where((obj) => obj['objectId'] == 14)
        .toList();

    List<Map<String, dynamic>>  irrigationLineList = jsonConfigObject
        .where((obj) => obj['objectId'] == 2)
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
          ?.map((val) => ValveData.fromJson(val))
          .toList() ??
          valveDataList.map((val) => ValveData.fromJson(val)).toList(),

      pumpList: (jsonConstant['pump'] as List<dynamic>?)?.isNotEmpty == true
          ? (jsonConstant['pump'] as List<dynamic>).map((pmp) => Pump.fromJson(pmp)).toList()
          : pumpDataList.map((pmp) => Pump.fromJson(pmp)).toList(),

      mainValveList: (jsonConstant['mainValve'] as List<dynamic>?)?.isNotEmpty == true
          ? (jsonConstant['mainValve'] as List<dynamic>).map((mv) => MainValveData.fromJson(mv)).toList()
          : mainValveDataList.map((mv) => MainValveData.fromJson(mv)).toList(),

      irrigationLineList: (jsonConstant['irrigationLine'] as List<dynamic>?)?.isNotEmpty == true
          ? (jsonConstant['mainValve'] as List<dynamic>).map((ir) => IrrigationLine.fromJson(ir)).toList()
          : irrigationLineList.map((ir) => IrrigationLine.fromJson(ir)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'controllerReadStatus': controllerReadStatus,
      'general': generalMenu.map((e) => e.toJson()).toList(),
      'valveList': valveList?.map((e) => e.toJson()).toList() ?? [],
      'pumpList': pumpList?.map((e) => e.toJson()).toList() ?? [],
      'mainValveList': mainValveList?.map((e) => e.toJson()).toList() ?? [],
      'irrigationLineList': irrigationLineList?.map((e) => e.toJson()).toList() ?? [],
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

class ValveData {
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

  ValveData({
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

  factory ValveData.fromJson(Map<String, dynamic> json) {
    return ValveData(
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

class MainValveData {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String? type;
  final int? controllerId;
  final int? count;
  String pickerVal;
  String delay;

  MainValveData({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.count,
    required this.pickerVal,
    this.delay = "No delay",
  });

  factory MainValveData.fromJson(Map<String, dynamic> json) => MainValveData(
    objectId: json["objectId"],
    sNo: (json["sNo"] as num).toDouble(),
    name: json["name"],
    connectionNo: json["connectionNo"]??0,
    objectName: json["objectName"],
    type: json["type"],
    controllerId: json["controllerId"]??0,
    count: json["count"]??0,
    delay: json["delay"] != null && json["delay"].isNotEmpty ? json["delay"] : "No delay",
    pickerVal: json.containsKey('pickerVal') ? json['pickerVal'] : "00:00:00",

  );

  Map<String, dynamic> toJson() => {
    "objectId": objectId,
    "sNo": sNo,
    "name": name,
    "connectionNo": connectionNo,
    "objectName": objectName,
    "type": type,
    "controllerId": controllerId,
    "count": count,
    "pickerVal": pickerVal,
    "delay": delay,
  };
}

class Pump {
  final int objectId;
  final double sNo;
  final String name;
 // final String objectName;
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
   // required this.objectName,
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
     // objectName: json['objectName'],
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
     // 'objectName': objectName,
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

class IrrigationLine {
  final int objectId;
  final double sNo;
  final String name;
  final String objectName;
  final String type;
  final dynamic connectionNo;
  final dynamic controllerId;
  final dynamic count;
  final dynamic connectedObject;
  final dynamic siteMode;
  final double location;
  String pickerVal;
  String lowFlowAction;
  String highFlowAction;

  IrrigationLine({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.objectName,
    required this.type,
    this.connectionNo,
    this.controllerId,
    this.count,
    this.connectedObject,
    this.siteMode,
    required this.location,
    required this.pickerVal,
    required this.lowFlowAction,
    required this.highFlowAction,
  });

  factory IrrigationLine.fromJson(Map<String, dynamic> json) {
    return IrrigationLine(
      objectId: json['objectId'] ?? 0,
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'] ?? '',
      objectName: json['objectName'] ?? '',
      type: json['type'] ?? '-',
      connectionNo: json['connectionNo'],
      controllerId: json['controllerId'],
      count: json['count'],
      connectedObject: json['connectedObject'],
      siteMode: json['siteMode'],
      location: (json['location'] as num).toDouble(),
      pickerVal: json.containsKey('pickerVal') ? json['pickerVal'] : "00:00:00",
      lowFlowAction: json["lowFlowAction"] != null && json["lowFlowAction"].isNotEmpty ? json["lowFlowAction"] : "Ignore",
      highFlowAction: json["lowFlowAction"] != null && json["lowFlowAction"].isNotEmpty ? json["lowFlowAction"] : "Ignore",


    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'objectName': objectName,
      'type': type,
      'connectionNo': connectionNo,
      'controllerId': controllerId,
      'count': count,
      'connectedObject': connectedObject,
      'siteMode': siteMode,
      'location': location,
      'pickerVal': pickerVal,
      'lowFlowAction': lowFlowAction,
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
