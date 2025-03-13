
import 'dart:convert';

class ConstantDataModel {
  final Constant constant;
  final Default fetchUserDataDefault;
  ConstantDataModel({
    required this.constant,
    required this.fetchUserDataDefault,
  });

  factory ConstantDataModel.fromJson(Map<String, dynamic> json) {
    return ConstantDataModel(
      constant: json["constant"] is Map<String, dynamic> ? Constant.fromJson(json["constant"])
          : Constant(general: [], line: [], mainValve: [], valve: [], pump: [], waterMeter: [],
          fertilization: [], filtration: [], ecPh: [], analogSensor: [], moistureSensor: [],
          levelSensor: [], normalAlarm: [], criticalAlarm: [], globalAlarm: [], controllerReadStatus: ''),

      fetchUserDataDefault: json["default"] is Map<String, dynamic>
          ? Default.fromJson(json["default"])
          : Default(alarm: [], constantMenu: [], configMaker:
      ConfigMaker(filterSite: [], fertilizerSite: [], waterSource: [],moistureSensor: [],
          pump: [], irrigationLine: [],), ),
    );
  }

  Map<String, dynamic> toJson() => {
    "constant": constant.toJson(),
    "default": fetchUserDataDefault.toJson(),
  };
}
class Constant {
  List<dynamic> general;
  List<dynamic> line;
  List<dynamic> mainValve;
  List<dynamic> valve;
  List<dynamic> pump;
  List<dynamic> waterMeter;
  List<dynamic> fertilization;
  List<dynamic> filtration;
  List<dynamic> ecPh;
  List<dynamic> analogSensor;
  List<dynamic> moistureSensor;
  List<dynamic> levelSensor;
  List<dynamic> normalAlarm;
  List<dynamic> criticalAlarm;
  List<dynamic> globalAlarm;
  String controllerReadStatus;

  Constant({
    required this.general,
    required this.line,
    required this.mainValve,
    required this.valve,
    required this.pump,
    required this.waterMeter,
    required this.fertilization,
    required this.filtration,
    required this.ecPh,
    required this.analogSensor,
    required this.moistureSensor,
    required this.levelSensor,
    required this.normalAlarm,
    required this.criticalAlarm,
    required this.globalAlarm,
    required this.controllerReadStatus,
  });

  factory Constant.fromJson(Map<String, dynamic> json) {
    final constantData = json['constant'] ?? {}; // Safe check for null
    return Constant(
      general: List<dynamic>.from(constantData['general'] ?? []),
      line: List<dynamic>.from(constantData['line'] ?? []),
      mainValve: List<dynamic>.from(constantData['mainValve'] ?? []),
      valve: List<dynamic>.from(constantData['valve'] ?? []),
      pump: List<dynamic>.from(constantData['pump'] ?? []),
      waterMeter: List<dynamic>.from(constantData['waterMeter'] ?? []),
      fertilization: List<dynamic>.from(constantData['fertilization'] ?? []),
      filtration: List<dynamic>.from(constantData['filtration'] ?? []),
      ecPh: List<dynamic>.from(constantData['ecPh'] ?? []),
      analogSensor: List<dynamic>.from(constantData['analogSensor'] ?? []),
      moistureSensor: List<dynamic>.from(constantData['moistureSensor'] ?? []),
      levelSensor: List<dynamic>.from(constantData['levelSensor'] ?? []),
      normalAlarm: List<dynamic>.from(constantData['normalAlarm'] ?? []),
      criticalAlarm: List<dynamic>.from(constantData['criticalAlarm'] ?? []),
      globalAlarm: List<dynamic>.from(constantData['globalAlarm'] ?? []),
      controllerReadStatus: constantData['controllerReadStatus'] ?? '0',
    );
  }


  Map<String, dynamic> toJson() => {
    "constant": {
      "general": general,
      "line": line,
      "mainValve": mainValve,
      "valve": valve,
      "pump": pump,
      "waterMeter": waterMeter,
      "fertilization": fertilization,
      "filtration": filtration,
      "ecPh": ecPh,
      "analogSensor": analogSensor,
      "moistureSensor": moistureSensor,
      "levelSensor": levelSensor,
      "normalAlarm": normalAlarm,
      "criticalAlarm": criticalAlarm,
      "globalAlarm": globalAlarm,
      "controllerReadStatus": controllerReadStatus,
    },
  };
}

class Default {
  List<Alarm> alarm;
  List<ConstantMenu> constantMenu;
  ConfigMaker configMaker;
  Default({
    required this.alarm,
    required this.constantMenu,
    required this.configMaker,
  });
  factory Default.fromJson(Map<String, dynamic> json) {
    return Default(
      alarm: List<Alarm>.from(json["alarm"].map((x) => Alarm.fromMap(x))),
      constantMenu: List<ConstantMenu>.from(json["constantMenu"].map((x) => ConstantMenu.fromJson(x))),
      configMaker: ConfigMaker.fromJson(Map<String, dynamic>.from(payloadConversion(json["configMaker"]))),
    );
  }

  Map<String, dynamic> toJson() => {
    "alarm": List<dynamic>.from(alarm.map((x) => x.toJson())),
    "constantMenu": List<dynamic>.from(constantMenu.map((x) => x.toJson())),
    "configMaker": configMaker.toJson(),
  };
}

class Alarm {
   String name;
   String? sNo;
  String unit;
  String scanTime;
  String resetAfterIrrigation;
  String autoResetDuration;
  String threshold;
  String type;
  Alarm({
    required this.name,
    required this.sNo,
    required this.unit,
    required this.scanTime,
    required this.resetAfterIrrigation,
    required this.autoResetDuration,
    required this.threshold,
    required this.type,

  });

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      name: map['name'] ?? '',
      sNo: map['sNo']?.toString() ?? '0',
      unit: map['unit']?.toString() ?? 'Unknown',
      scanTime: map['scanTime'] ?? '00:00:00',
      resetAfterIrrigation: map['resetAfterIrrigation'] ?? 'No',
      autoResetDuration: map['autoResetDuration'] ?? '00:00:00',
      threshold: map['Threshold']?.toString() ?? '100',
      type: map['type'] ?? '',
    );
  }

  dynamic toJson(){
    return {
      'name' : name,
      'scanTime' : scanTime,
      'resetAfterIrrigation' : resetAfterIrrigation,
      'autoResetDuration' : autoResetDuration,
      'threshold' : threshold,
      'type': type,
    };
  }
}

class AlarmNew {
  String name;
  String unit;
  String scanTime;
  String alarmOnStatus;
  String resetAfterIrrigation;
  String autoResetDuration;
  String threshold;
  String type;

  AlarmNew({
    required this.name,
    required this.unit,
    required this.scanTime,
    required this.alarmOnStatus,
    required this.resetAfterIrrigation,
    required this.autoResetDuration,
    required this.threshold,
    required this.type,
  });

  // ✅ Added .copyWith() method for controlled updates
  AlarmNew copyWith({
    String? name,
    String? unit,
    String? scanTime,
    String? alarmOnStatus,
    String? resetAfterIrrigation,
    String? autoResetDuration,
    String? threshold,
    String? type,
  }) {
    return AlarmNew(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      scanTime: scanTime ?? this.scanTime,
      alarmOnStatus: alarmOnStatus ?? this.alarmOnStatus,
      resetAfterIrrigation: resetAfterIrrigation ?? this.resetAfterIrrigation,
      autoResetDuration: autoResetDuration ?? this.autoResetDuration,
      threshold: threshold ?? this.threshold,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "scanTime": scanTime,
      "alarmOnStatus": alarmOnStatus,
      "resetAfterIrrigation": resetAfterIrrigation,
      "autoResetDuration": autoResetDuration,
      "threshold": threshold,
      "unit": unit,
      "type": type,
    };
  }

  factory AlarmNew.fromMap(Map<String, dynamic> map) {
    return AlarmNew(
      name: map['name'],
      unit: map['unit']?.toString() ?? 'Unknown',
      scanTime: map['scanTime'],
      alarmOnStatus: map['AlarmOnStatus'],
      resetAfterIrrigation: map['Reset After irrigation'],
      autoResetDuration: map['Auto Reset Duration'],
      threshold: map['Threshold']?.toString() ?? '100',
      type: map['type'],
    );
  }
}


enum Unit {
  BAR,
  DELTA,
  EMPTY,
  UNIT
}

final unitValues = EnumValues({
  "bar": Unit.BAR,
  "delta": Unit.DELTA,
  "%": Unit.EMPTY,
  "": Unit.UNIT
});

class ConfigMaker {
  List<WaterSource> waterSource;
  List<Pump> pump;
  List<FilterSite> filterSite;
  List<FertilizerSite> fertilizerSite;
  List<MoistureSensor> moistureSensor;
  List<IrrigationLine> irrigationLine;

  ConfigMaker({
    required this.waterSource,
    required this.pump,
    required this.filterSite,
    required this.fertilizerSite,
    required this.moistureSensor,
    required this.irrigationLine,
  });

  factory ConfigMaker.fromJson(Map<String, dynamic> json) {
    return ConfigMaker(
      waterSource: (json["waterSource"] as List?)?.cast<Map<String, dynamic>>().map((x) => WaterSource.fromJson(x)).toList() ?? [],
      pump: (json["pump"] as List?)?.cast<Map<String, dynamic>>().map((x) => Pump.fromJson(x)).toList() ?? [],
      filterSite: (json["filterSite"] as List?)?.cast<Map<String, dynamic>>().map((x) => FilterSite.fromJson(x)).toList() ?? [],
      fertilizerSite: (json["fertilizerSite"] as List?)?.cast<Map<String, dynamic>>().map((x) => FertilizerSite.fromJson(x)).toList() ?? [],
      moistureSensor: (json["moistureSensor"] as List?)?.cast<Map<String, dynamic>>().map((x) => MoistureSensor.fromJson(x)).toList() ?? [],
      irrigationLine: (json["irrigationLine"] as List?)?.cast<Map<String, dynamic>>().map((x) => IrrigationLine.fromJson(x)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    "waterSource": waterSource.map((x) => x.toJson()).toList(),
    "pump": pump.map((x) => x.toJson()).toList(),
    "filterSite": filterSite.map((x) => x.toJson()).toList(),
    "fertilizerSite": fertilizerSite.map((x) => x.toJson()).toList(),
    "moistureSensor": moistureSensor.map((x) => x.toJson()).toList(), // Fix missing `.toJson()`
    "irrigationLine": irrigationLine.map((x) => x.toJson()).toList(),
  };
}


class ConfigObject {
  int objectId;
  double sNo;
  String name;
  int? connectionNo;
  String objectName;
  Type type;
  int? controllerId;
  dynamic count;

  ConfigObject({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    required this.count,
  });

  factory ConfigObject.fromJson(Map<String, dynamic> json) => ConfigObject(
    objectId: json["objectId"],
    sNo: json["sNo"]?.toDouble(),
    name: json["name"],
    connectionNo: json["connectionNo"],
    objectName: json["objectName"],
    type: typeValues.map[json["type"]]!,
    controllerId: json["controllerId"],
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "objectId": objectId,
    "sNo": sNo,
    "name": name,
    "connectionNo": connectionNo,
    "objectName": objectName,
    "type": typeValues.reverse[type],
    "controllerId": controllerId,
    "count": count,
  };
}

enum Type {
  EMPTY,
  THE_12, defaultType, unknown
}
final typeValues = EnumValues({
  "-": Type.EMPTY,
  "1,2": Type.THE_12
});

class FertilizerSite {
  int objectId;
  double sNo;
  String name;
  int? connectionNo;
  String objectName;
  final String type;
  int? controllerId;
  int? count;
  int siteMode;
  List<Channel> channel;
  List<int> boosterPump;
  List<int> agitator;
  List<int> selector;
  List<EC> ec;
  List<PH> ph;
  String minimalOnTime;
  String minimalOffTime;
  String boosterOffDelay;
  String ratio;
  String shortestPulse;
  String nominalFlow;
  String injectorMode;
  String mode;
  List<Injector> injectors;

  FertilizerSite({
    required this.objectId,
    required this.sNo,
    required this.name,
    this.connectionNo,
    required this.objectName,
    required this.type,
    this.controllerId,
    this.count,
    required this.siteMode,
    required this.channel,
    required this.boosterPump,
    required this.agitator,
    required this.selector,
    required this.ec,
    required this.ph,
    required this.minimalOnTime,
    required this.minimalOffTime ,
    required this.boosterOffDelay ,
    required this.ratio,
    required this.shortestPulse,
    required this.nominalFlow,
    this.injectorMode = 'Unknown',
    this.mode = 'Unknown',
    required this.injectors,
  });

  factory FertilizerSite.fromJson(Map<String, dynamic> json) => FertilizerSite(
    objectId: json["objectId"] ?? 0,
    sNo: (json["sNo"] is num) ? (json["sNo"] as num).toDouble() : 0.0,
    name: json["name"] ?? '',
    connectionNo: json["connectionNo"],
    objectName: json["objectName"] ?? '',
    type: json["type"] ?? "-",
    controllerId: json["controllerId"],
    count: json["count"],
    siteMode: json["siteMode"] ?? 0,
    channel: (json["channel"] is List) ? List<Channel>.from(json["channel"].map((x) => Channel.fromJson(x))) : [],
    boosterPump: (json["boosterPump"] is List) ? json["boosterPump"].whereType<int>().toList() : [],
    agitator: (json["agitator"] is List) ? json["agitator"].whereType<int>().toList() : [],
    selector: (json["selector"] is List) ? json["selector"].whereType<int>().toList() : [],
    ec: (json['ec'] as List).map((item) => EC.fromJson(item)).toList(),
    ph: (json['ph'] as List).map((item) => PH.fromJson(item)).toList(),
    minimalOnTime: (json["minimalOnTime"] == null || json["minimalOnTime"] == 0) ? "00:00:00" : json["minimalOnTime"].toString(),
    minimalOffTime: (json["minimalOffTime"] == null || json["minimalOffTime"] == 0) ? "00:00:00" : json["minimalOffTime"].toString(),
    boosterOffDelay: (json["boosterOffDelay"] == null || json["boosterOffDelay"] == 0) ? "00:00:00" : json["boosterOffDelay"].toString(),
    ratio: (json["ratio"] == null || json["ratio"] == 0) ? "100" : json["ratio"].toString(),
    shortestPulse: (json["shortestPulse"] == null || json["shortestPulse"] == 0) ? "100" : json["shortestPulse"].toString(),
    nominalFlow: (json["nominalFlow"] == null || json["nominalFlow"] == 0) ? "100" : json["nominalFlow"].toString(),
    injectorMode: (json['injectorMode'] == null || json['injectorMode'] == 'Unknown') ? 'Concentration' : json['injectorMode'], mode: json['mode'] ?? 'Unknown',
    injectors: (json["injector"] as List?)?.map((e) => Injector.fromJson(e)).toList() ?? [],
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
    "siteMode": siteMode,
    "channel": channel.map((x) => x.toJson()).toList(),
    "boosterPump": boosterPump,
    "agitator": agitator,
    "selector": selector,
    "ec": ec,
    "ph": ph,
    "minimalOnTime": minimalOnTime,
    "minimalOffTime": minimalOffTime,
    "boosterOffDelay": boosterOffDelay,
    "ratio": ratio,
    "shortestPulse": shortestPulse,
    "nominalFlow": nominalFlow,
    "injectorMode": injectorMode,
    "mode": mode,
    "injector": injectors.map((e) => e.toJson()).toList(),
  };
}

class Injector {
  String name;
  int objectId;
  double sNo;
  String? type;
  String ratio;
  String shortestPulse;
  String nominalFlow;
  String injectorMode;
  String objectName;
  final int? controllerId;
  final int? count;
  final int level;
  final int? connectionNo;
  Injector({
    required this.name,
    required this.objectId,
    required this.sNo,
    this.type, // Handle missing or empty type
    required this.ratio,
    required this.shortestPulse,
    required this.nominalFlow,
    required this.injectorMode,
    this.controllerId,
    this.count,
    required this.level,
    required this.objectName,
    this.connectionNo,
  });

  factory Injector.fromJson(Map<String, dynamic> json) {
    return Injector(
      name: json["name"] ?? "",
      objectName: json["objectName"],
      objectId: json["objectId"] ?? 0,
      sNo: (json["sNo"] as num?)?.toDouble() ?? 0.0,
      type: (json["type"] == "-" || json["type"] == null || json["type"].toString().trim().isEmpty)
          ? null
          : json["type"].toString(),
      ratio: json["ratio"] ?? "0",
      shortestPulse: json["shortestPulse"] ?? "0",
      nominalFlow: json["nominalFlow"] ?? "0",
      injectorMode: json["injectorMode"] ?? "",
      controllerId: json["controllerId"]??0,
      count: json["count"]??0,
      level: json["level"],
      connectionNo: json["connectionNo"]??0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "objectId": objectId,
      "sNo": sNo,
      "type": type ?? "", // Convert `null` to empty string when sending
      "ratio": ratio,
      "shortestPulse": shortestPulse,
      "nominalFlow": nominalFlow,
      "injectorMode": injectorMode,
    };
  }
}
class EC {
  int objectId;
  double sNo;
  String name;
  String objectName;
  String? type;
  int? connectionNo;
  int? controllerId;
  int? count;
  String? connectedObject;
  String? siteMode;
  bool selected;
  String controlCycle;
  String delta;
  String fineTuning;
  String coarseTuning;
  String deadBand;
  String? controlSensor;
  String avgFiltSpeed;
  String percentage;
  String integ;
  int sensitivity;
  EC({
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
    this.selected = false,
    required this.controlCycle,
    required this.delta,
    required this.fineTuning ,
    required this.coarseTuning ,
    required this.deadBand ,
    this.controlSensor,
    required this.avgFiltSpeed,
    required this.percentage,
    required this.integ,
    required this.sensitivity
  });

  factory EC.fromJson(Map<String, dynamic> json) {
    return EC(
      objectId: json['objectId'] as int,
      sNo: (json['sNo'] is num) ? (json['sNo'] as num).toDouble() : 0.0, // Handle num to double conversion
      name: json['name'] as String,
      objectName: json['objectName'] as String,
      type: json['type'] as String?,
      connectionNo: json['connectionNo'] as int?,
      controllerId: json['controllerId'] as int?,
      count: json['count'] as int?,
      connectedObject: json['connectedObject'] as String?,
      siteMode: json['siteMode'] as String?,
      selected: json['selected'] ?? false,
      controlCycle: (json["controlCycle"] == null || json["controlCycle"] == 0) ? "00:00:00" : json["controlCycle"].toString(),
      integ: (json["integ"] == null || json["integ"] == 0) ? "00:00:00" : json["integ"].toString(),
      delta: (json["delta"] == null || json["delta"] == 0) ? "100" : json["delta"].toString(),
      fineTuning: (json["fineTuning"] == null || json["fineTuning"] == 0) ? "100" : json["fineTuning"].toString(),
      coarseTuning: (json["coarseTuning"] == null || json["coarseTuning"] == 0) ? "100" : json["coarseTuning"].toString(),
      deadBand: (json["deadBand"] == null || json["deadBand"] == 0) ? "100" : json["deadBand"].toString(),
      avgFiltSpeed: (json["avgFiltSpeed"] == null || json["avgFiltSpeed"] == 0) ? "100" : json["avgFiltSpeed"].toString(),
      percentage: (json["percentage"] == null || json["percentage"] == 0) ? "100" : json["percentage"].toString(),
      controlSensor: json["highFlowAction"] ?? "Average",
      sensitivity: (json['sensitivity'] as num?)?.toInt() ?? 0,
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
      'selected': selected,
      'controlCycle': controlCycle,
      'delta': delta,
      'fineTuning': fineTuning,
      'coarseTuning': coarseTuning,
      'deadBand': deadBand,
      "controlSensor": controlSensor ?? "Average",
      'avgFiltSpeed': avgFiltSpeed,
      'percentage': percentage,
      'integ': integ,
    };
  }
}

class PH {
  int objectId;
  double sNo;
  String name;
  String objectName;
  String? type;
  int? connectionNo;
  int? controllerId;
  int? count;
  String? connectedObject;
  String? siteMode;

  bool selected;
  String controlCycle;
  String delta;
  String fineTuning;
  String coarseTuning;
  String deadBand;
  String? controlSensor;
  String avgFiltSpeed;
  String percentage;
  String integ;

  PH({
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
    this.selected = false,
    required this.controlCycle,
    required this.delta ,
    required this.fineTuning,
    required this.coarseTuning,
    required this.deadBand,
    required this.controlSensor,
    required this.avgFiltSpeed,
    required this.percentage,
    required this.integ,
  });

  factory PH.fromJson(Map<String, dynamic> json) {
    return PH(
      objectId: json['objectId'] as int,
      sNo: (json['sNo'] is num) ? (json['sNo'] as num).toDouble() : 0.0, // Handle num to double conversion
      name: json['name'] as String,
      objectName: json['objectName'] as String,
      type: json['type'] as String?,
      connectionNo: json['connectionNo'] as int?,
      controllerId: json['controllerId'] as int?,
      count: json['count'] as int?,
      connectedObject: json['connectedObject'] as String?,
      siteMode: json['siteMode'] as String?,
      selected: json['selected'] ?? false,
      controlCycle: (json["controlCycle"] == null || json["controlCycle"] == 0) ? "00:00:00" : json["controlCycle"].toString(),
      integ: (json["integ"] == null || json["integ"] == 0) ? "00:00:00" : json["integ"].toString(),
      delta: (json["delta"] == null || json["delta"] == 0) ? "100" : json["delta"].toString(),
      fineTuning: (json["fineTuning"] == null || json["fineTuning"] == 0) ? "100" : json["fineTuning"].toString(),
      coarseTuning: (json["coarseTuning"] == null || json["coarseTuning"] == 0) ? "100" : json["coarseTuning"].toString(),
      deadBand: (json["deadBand"] == null || json["deadBand"] == 0) ? "100" : json["deadBand"].toString(),
      avgFiltSpeed: (json["avgFiltSpeed"] == null || json["avgFiltSpeed"] == 0) ? "100" : json["avgFiltSpeed"].toString(),
      percentage: (json["percentage"] == null || json["percentage"] == 0) ? "100" : json["percentage"].toString(),
      controlSensor: json["highFlowAction"] ?? "Average",
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
      'selected': selected,
      'controlCycle': controlCycle,
      'delta': delta,
      'fineTuning': fineTuning,
      'coarseTuning': coarseTuning,
      'deadBand': deadBand,
      "controlSensor": controlSensor ?? "Average",
      'avgFiltSpeed': avgFiltSpeed,
      'percentage': percentage,
      'integ': integ,
    };
  }
}

class Channel {
  int objectId;
  double sNo;
  String name;
  String objectName;
  String? type;
  int? connectionNo;
  int? controllerId;
  int? count;
  double level;
  int injectorMode;
  double shortestPulse;
  double nominalFlow;
  double ratio;
  Channel({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.objectName,
    required this.type,
    this.connectionNo,
    this.controllerId,
    required this.count,
    required this.level,
    required this.injectorMode,
    required this.ratio,
    required this.shortestPulse,
    required this.nominalFlow,
  });

  /// Factory constructor to create a `Channel` instance from JSON
  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      objectId: json['objectId'] as int,
      sNo: (json['sNo'] is num) ? (json['sNo'] as num).toDouble() : 0.0,
      name: json['name'] as String,
      objectName: json['objectName'] as String,
      type: json['type'] as String,
      connectionNo: json['connectionNo'] as int?,
      controllerId: json['controllerId'] as int?,
      count: json['count'] as int?,
      level: (json['level'] is num) ? (json['level'] as num).toDouble() : 0.0,
      injectorMode: json['injectorMode']??0,
      ratio: (json['ratio'] ?? 0).toDouble(),
      shortestPulse: (json['shortestPulse'] ?? 0).toDouble(),
      nominalFlow: (json['nominalFlow'] ?? 0).toDouble(),
    );
  }

  /// Convert `Channel` instance to JSON
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
      'level': level,
      'injectorMode': injectorMode,

    };
  }
}

class FilterSite {
  int objectId;
  double sNo;
  String name;
  int? connectionNo;
  String objectName;
  String type;
  int? controllerId;
  int? count;
  int siteMode;
  List<dynamic> filters;
  List<dynamic> pressureIn;
  List<dynamic> pressureOut;
  List<dynamic> backWashValve;

  FilterSite({
    required this.objectId,
    required this.sNo,
    required this.name,
    this.connectionNo,
    required this.objectName,
    required this.type,
    this.controllerId,
    this.count,
    required this.siteMode,
    required this.filters,
    required this.pressureIn,
    required this.pressureOut,
    required this.backWashValve,
  });
  factory FilterSite.fromJson(Map<String, dynamic> json) {
    return FilterSite(
      objectId: json["objectId"] ?? 0,
      sNo: json["sNo"] != null && json["sNo"] is num ? (json["sNo"] as num).toDouble() : 0.0,
      name: json["name"] ?? "",
      connectionNo: json["connectionNo"],
      objectName: json["objectName"] ?? "",
      type: json["type"] ?? "",
      controllerId: json["controllerId"],
      count: json["count"],
      siteMode: json["siteMode"] ?? 0,
      filters: json["filters"] is List ? json["filters"].whereType<int>().toList() : [],
      pressureIn: json["pressureIn"] is List ? json["pressureIn"].whereType<int>().toList() : [],
      pressureOut: json["pressureOut"] is List ? json["pressureOut"].whereType<int>().toList() : [],
      backWashValve: json["backWashValve"] is List ? json["backWashValve"].whereType<int>().toList() : [],
    );
  }

  Map<String, dynamic> toJson() => {
    "objectId": objectId,
    "sNo": sNo,
    "name": name,
    "connectionNo": connectionNo,
    "objectName": objectName,
    "type": type,
    "controllerId": controllerId,
    "count": count,
    "siteMode": siteMode,
    "filters": filters.map((x) => x).toList(),
    "pressureIn": pressureIn.map((x) => x).toList(),
    "pressureOut": pressureOut.map((x) => x).toList(),
    "backWashValve": backWashValve.map((x) => x).toList(),
  };
}


class IrrigationLine {
  int objectId;
  double sNo;
  String name;
  int? connectionNo;
  String objectName;
  String? type;
  int? controllerId;
  int? count;
  List<int> source;
  List<int> sourcePump;
  List<int> irrigationPump;
  double centralFiltration;
  int localFiltration;
  double centralFertilization;
  int localFertilization;
  List<Valve> valves;
  List<MainValve> mainValve;
  List<int> fan;
  List<int> fogger;
  List<int> pesticides;
  List<int> heater;
  List<int> screen;
  List<int> vent;
  int powerSupply;
  int pressureSwitch;
  final WaterMeter? waterMeter;
  int pressureIn;
  int pressureOut;
  List<int> moisture;
  List<int> temperature;
  List<int> soilTemperature;
  List<int> humidity;
  List<int> co2;
  String lowFlowDelay;
  String highFlowDelay;
  String? lowFlowAction;
  String? highFlowAction;

  IrrigationLine({
    required this.objectId,
    required this.sNo,
    required this.name,
    this.connectionNo,
    required this.objectName,
    required this.type,
    this.controllerId,
    this.count,
    required this.source,
    required this.sourcePump,
    required this.irrigationPump,
    required this.centralFiltration,
    required this.localFiltration,
    required this.centralFertilization,
    required this.localFertilization,
    required this.valves,
    required this.mainValve,
    required this.fan,
    required this.fogger,
    required this.pesticides,
    required this.heater,
    required this.screen,
    required this.vent,
    required this.powerSupply,
    required this.pressureSwitch,
    required this.waterMeter,
    required this.pressureIn,
    required this.pressureOut,
    required this.moisture,
    required this.temperature,
    required this.soilTemperature,
    required this.humidity,
    required this.co2,
    required this.lowFlowDelay,
    required this.highFlowDelay,
    this.lowFlowAction,
    this.highFlowAction,
  });

  factory IrrigationLine.fromJson(Map<String, dynamic> json) {
    return IrrigationLine(
      objectId: json["objectId"],
      sNo: (json["sNo"] is num) ? (json["sNo"] as num).toDouble() : 0.0, // Ensure it’s a number
      name: json["name"] ?? "",
      connectionNo: json["connectionNo"],
      objectName: json["objectName"] ?? "",
      type: json['type'] as String,
      controllerId: json["controllerId"],
      count: json["count"],
      source: (json["source"] is List) ? List<int>.from(json["source"]) : [],
      sourcePump: (json["sourcePump"] is List) ? (json["sourcePump"]as List).whereType<num>().map((x)=>x.toInt()).toList():[],
      irrigationPump: (json["irrigationPump"] is List) ? (json["irrigationPump"]as List).whereType<num>().map((x)=>x.toInt()).toList():[],
      centralFiltration: (json["centralFiltration"] is num) ? (json["centralFiltration"] as num).toDouble() : 0.0,
      localFiltration: (json["localFiltration"] is num) ? json["localFiltration"] : 0,
      centralFertilization: (json["centralFertilization"] is num) ? (json["centralFertilization"] as num).toDouble() : 0.0,
      localFertilization: (json["localFertilization"] is num) ? json["localFertilization"] : 0,
      valves: (json["valve"] as List<dynamic>?)?.map((e) => Valve.fromJson(e)).toList() ?? [],
      mainValve: (json["mainValve"] as List<dynamic>?)?.map((e) => MainValve.fromJson(e)).toList() ?? [],
      fan: (json["fan"] is List) ? List<int>.from(json["fan"]) : [],
      fogger: (json["fogger"] is List) ? List<int>.from(json["fogger"]) : [],
      pesticides: (json["pesticides"] is List) ? List<int>.from(json["pesticides"]) : [],
      heater: (json["heater"] is List) ? List<int>.from(json["heater"]) : [],
      screen: (json["screen"] is List) ? List<int>.from(json["screen"]) : [],
      vent: (json["vent"] is List) ? List<int>.from(json["vent"]) : [],
      powerSupply: (json["powerSupply"] is num) ? json["powerSupply"] : 0,
      pressureSwitch: (json["pressureSwitch"] is num) ? json["pressureSwitch"] : 0,
      waterMeter: json['waterMeter'].isNotEmpty ? WaterMeter.fromJson(json['waterMeter']) : null,
      pressureIn: (json["pressureIn"] is num) ? json["pressureIn"] : 0,
      pressureOut: (json["pressureOut"] is num) ? json["pressureOut"] : 0,
      moisture: (json["moisture"] is List) ? json["moisture"].map<int>((e) => (e is int) ? e : 0).toList() : [],
      temperature: (json["temperature"] is List) ? List<int>.from(json["temperature"]) : [],
      soilTemperature: (json["soilTemperature"] is List) ? List<int>.from(json["soilTemperature"]) : [],
      humidity: (json["humidity"] is List) ? List<int>.from(json["humidity"]) : [],
      co2: (json["co2"] is List) ? List<int>.from(json["co2"]) : [],
      lowFlowDelay: (json["lowFlowDelay"] == null || json["lowFlowDelay"] == 0) ? "00:00:00" : json["lowFlowDelay"].toString(),
      highFlowDelay: (json["highFlowDelay"] == null || json["highFlowDelay"] == 0) ? "00:00:00" : json["highFlowDelay"].toString(),
      lowFlowAction: json["lowFlowAction"] ?? "Ignore",
      highFlowAction: json["highFlowAction"] ?? "Ignore",
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "objectId": objectId,
      "sNo": sNo,
      "name": name,
      "connectionNo": connectionNo,
      "objectName": objectName,
      'type': type,
      "controllerId": controllerId,
      "count": count,
      "source": source,
      "sourcePump": sourcePump,
      "irrigationPump": irrigationPump,
      "centralFiltration": centralFiltration,
      "localFiltration": localFiltration,
      "centralFertilization": centralFertilization,
      "localFertilization": localFertilization,
      "valve": valves,
      "mainValve": mainValve,
      "fan": fan,
      "fogger": fogger,
      "pesticides": pesticides,
      "heater": heater,
      "screen": screen,
      "vent": vent,
      "powerSupply": powerSupply,
      "pressureSwitch": pressureSwitch,
      "waterMeter": waterMeter,
      "pressureIn": pressureIn,
      "pressureOut": pressureOut,
      "moisture": moisture,
      "temperature": temperature,
      "soilTemperature": soilTemperature,
      "humidity": humidity,
      "co2": co2,
      "lowFlowDelay": lowFlowDelay,
      "highFlowDelay": highFlowDelay,
      "lowFlowAction": lowFlowAction ?? "Ignore",
      "highFlowAction": highFlowAction ?? "Ignore",
    };
  }
}

class WaterMeter {
  int objectId;
  double sNo;
  int connectionNo;
  int controllerId;
  int? count;
  dynamic connectedObject;
  dynamic siteMode;
  int id;
  String name;
  String type;
  double value;
  double ratio;
  String objectName;

  WaterMeter({
    required this.objectId,
    required this.sNo,
    required this.connectionNo,
    required this.controllerId,
    this.count, // Nullable, so removed `required`
    this.connectedObject,
    this.siteMode,
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.ratio,
    required this.objectName,
  });

  // Convert JSON to WaterMeter object
  factory WaterMeter.fromJson(Map<String, dynamic> json) {
    return WaterMeter(
      objectId: json['objectId'],
      sNo: (json['sNo'] as num).toDouble(),
      connectionNo: json['connectionNo'],
      controllerId: json['controllerId'],
      count: json['count'],
      connectedObject: json['connectedObject'],
      siteMode: json['siteMode'],
      id: json['id'] ?? 0,
      name: json['name'],
      type: json['type'],
      value: (json['value'] ?? 0).toDouble(),
      ratio: (json['ratio'] ?? 0).toDouble(),
      objectName: json['objectName'],
    );
  }

  // Convert WaterMeter object to JSON
  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'connectionNo': connectionNo,
      'controllerId': controllerId,
      'count': count,
      'connectedObject': connectedObject,
      'siteMode': siteMode,
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'ratio': ratio,
      'objectName': objectName,
    };
  }
}



class WaterSource {
  final int objectId;
  final double sNo;
  final String name;
  final LevelSensor? level;

  WaterSource({
    required this.objectId,
    required this.sNo,
    required this.name,
    this.level,
  });

  factory WaterSource.fromJson(Map<String, dynamic> json) {
    return WaterSource(
      objectId: json['objectId'] ?? 0,
      sNo: (json['sNo'] ?? 0).toDouble(),
      name: json['name'] ?? '',
      level: json['level'] != null && json['level'].isNotEmpty
          ? LevelSensor.fromJson(json['level'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'level': level?.toJson(),
    };
  }
}
class LevelSensor {
  int objectId;
  int sensorId;
  double sNo;
  String name;
  int connectionNo;
  String objectName;
  String type;
  int controllerId;
  int? count;
  final dynamic connectedObject;
  final dynamic siteMode;

  LevelSensor({
    required this.objectId,
    required this.sensorId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.count,
    this.connectedObject,
    this.siteMode,
  });

  factory LevelSensor.fromJson(Map<String, dynamic> json) {
    return LevelSensor(
      objectId: json['objectId'] is int ? json['objectId'] : int.tryParse(json['objectId'].toString()) ?? 0,
      sensorId: json["sensorId"] is int ? json["sensorId"] : int.tryParse(json["sensorId"].toString()) ?? 0,
      sNo: (json['sNo'] is num) ? (json['sNo'] as num).toDouble() : 0.0,
      name: json['name']?.toString() ?? '',
      connectionNo: json['connectionNo'] is int ? json['connectionNo'] : int.tryParse(json['connectionNo'].toString()) ?? 0,
      objectName: json['objectName']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      controllerId: json['controllerId'] is int ? json['controllerId'] : int.tryParse(json['controllerId'].toString()) ?? 0,
      count: json['count'] is int ? json['count'] : int.tryParse(json['count'].toString()),
      connectedObject: json['connectedObject'],
      siteMode: json['siteMode'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sensorId': sensorId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
      'connectedObject': connectedObject,
      'siteMode': siteMode,
    };
  }
}


/*class Level {
  LevelSensor? levelSensor;

  Level({this.levelSensor});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      levelSensor: json["levelSensor"] != null ? LevelSensor.fromJson(json["levelSensor"]) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "levelSensor": levelSensor?.toJson(),
  };
}*/



class ConstantMenu {
  int dealerDefinitionId;
  String parameter;
  String value;

  ConstantMenu({
    required this.dealerDefinitionId,
    required this.parameter,
    required this.value,
  });

  factory ConstantMenu.fromJson(Map<String, dynamic> json) => ConstantMenu(
    dealerDefinitionId: json["dealerDefinitionId"],
    parameter: json["parameter"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "dealerDefinitionId": dealerDefinitionId,
    "parameter": parameter,
    "value": value,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

class Pump {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final int? count;
  final int level;
  final int pressureIn;
  final int pressureOut;
  final WaterMeter? waterMeter;
  final int pumpType;
  bool pumpStation;
  bool controlGem;

  Pump({
    required this.objectId,
    required this.sNo,
    required this.name,
    this.connectionNo,
    required this.objectName,
    required this.type,
    this.controllerId,
    this.count,
    required this.level,
    required this.pressureIn,
    required this.pressureOut,
    this.waterMeter,
    required this.pumpType,
    required this.pumpStation,
    required this.controlGem,
  });

  factory Pump.fromJson(Map<String, dynamic> json) => Pump(
    objectId: json["objectId"] is int ? json["objectId"] : 0,
    sNo: (json["sNo"] is num) ? json["sNo"].toDouble() : 0.0,
    name: json["name"] ?? "",
    connectionNo: json["connectionNo"] is int ? json["connectionNo"] : null,
    objectName: json["objectName"] ?? "",
    type: json["type"] ?? "",
    controllerId: json["controllerId"] is int ? json["controllerId"] : null,
    count: json["count"] is int ? json["count"] : null,
    level: json["level"] is int ? json["level"] : 0,
    pressureIn: json["pressureIn"] is int ? json["pressureIn"] : 0,
    pressureOut: json["pressureOut"] is int ? json["pressureOut"] : 0,
    waterMeter: json['waterMeter'] is Map<String, dynamic>
        ? WaterMeter.fromJson(json['waterMeter'])
        : null, // Ensure `waterMeter` is parsed correctly
    pumpType: json["pumpType"] is int ? json["pumpType"] : 0,
    pumpStation: json['pumpStation'] is bool
        ? json['pumpStation']
        : (json['pumpStation'] == 1), // Convert int to bool if needed
    controlGem: json['controlGem'] is bool
        ? json['controlGem']
        : (json['controlGem'] == 1), // Convert int to bool if needed
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
    "level": level,
    "pressureIn": pressureIn,
    "pressureOut": pressureOut,
    "waterMeter": waterMeter?.toJson(),
    "pumpType": pumpType,
    "pumpStation": pumpStation,
    "controlGem": controlGem,
  };
}

class MainValve {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String? type;
  final int? controllerId;
  final int? count;
  String mode;
  String delay;

  MainValve({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.count,
    this.mode = "No delay",
    required this.delay,
  });

  factory MainValve.fromJson(Map<String, dynamic> json) => MainValve(
    objectId: json["objectId"],
    sNo: (json["sNo"] as num).toDouble(),
    name: json["name"],
    connectionNo: json["connectionNo"]??0,
    objectName: json["objectName"],
    type: json["type"],
    controllerId: json["controllerId"]??0,
    count: json["count"]??0,
    mode: json["mode"] ?? "No delay",
    delay: (json["delay"] == null || json["delay"] == 0) ? "00:00:00" : json["delay"].toString(),

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
    "mode": mode,
    "delay": delay,
  };
}

class Valve {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int controllerId;
  final int? count;
  String fillUpDelay;
  String nominalFlow;
  List<IrrigationLine> irrigationLine;
  Valve({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.count,
    required this.fillUpDelay,
    required this.nominalFlow,
    required this.irrigationLine,
  });

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      objectId: json["objectId"],
      sNo: (json["sNo"] as num).toDouble(),
      name: json["name"],
      connectionNo: json["connectionNo"]??0,
      objectName: json["objectName"],
      type: json["type"],
      controllerId: json["controllerId"]??0,
      count: json["count"]??0,
      nominalFlow: (json["nominalFlow"] == null || json["nominalFlow"] == 0) ? "100" : json["nominalFlow"].toString(),
      fillUpDelay: (json["fillUpDelay"] == null || json["fillUpDelay"] == 0) ? "00:00:00" : json["fillUpDelay"].toString(),
      irrigationLine: (json["irrigationLine"] != null && json["irrigationLine"] is List) ? (json["irrigationLine"] as List).map((line) => IrrigationLine.fromJson(line)).toList() : [],    );
  }


  Map<String, dynamic> toJson() {
    return {
      "objectId": objectId,
      "sNo": sNo,
      "name": name,
      "connectionNo": connectionNo,
      "objectName": objectName,
      "type": type,
      "controllerId": controllerId,
      "count": count,
      "fillUpDelay": fillUpDelay,
      "nominalFlow": nominalFlow,
      "irrigationLine": irrigationLine,
    };
  }
}

class GeneralData {
  final int sNo;
  final String title;
  final int widgetTypeId;
  final dynamic value;

  GeneralData({
    required this.sNo,
    required this.title,
    required this.widgetTypeId,
    required this.value,
  });

  // Convert GeneralData object to Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      "sNo": sNo,
      "title": title,
      "widgetTypeId": widgetTypeId,
      "value": value,
    };
  }

  // Convert Map<String, dynamic> back to GeneralData object
  factory GeneralData.fromMap(Map<String, dynamic> map) {
    return GeneralData(
      sNo: map["sNo"],
      title: map["title"],
      widgetTypeId: map["widgetTypeId"],
      value: map["value"],
    );
  }
}
class MoistureSensor {
   int objectId;
   int objectIds;
   double sNo;
  final String name;
  final int connectionNo;
  final String objectName;
  final String type;
  final int controllerId;
  final int? count;
  final Map<String, dynamic> connectedObject;
  final dynamic siteMode;
  final List<dynamic> valves;

  MoistureSensor({
    required this.objectId,
    required this.objectIds,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.count,
    required this.connectedObject,
    this.siteMode,
    required this.valves,
  });

  factory MoistureSensor.fromJson(Map<String, dynamic> json) {
    return MoistureSensor(
      objectId: json['objectId'],
      objectIds: json['objectIds']??0,
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'].toString(),
      controllerId: json['controllerId'],
      count: json['count'],
      connectedObject: json['connectedObject'] is Map<String, dynamic>
          ? json['connectedObject'] as Map<String, dynamic>
          : {}, // Ensure it's always a Map<String, dynamic>
      siteMode: json['siteMode'],
      valves: json['valves'] is List ? List.from(json['valves']) : [],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'objectIds': objectIds,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
      'connectedObject': connectedObject,
      'siteMode': siteMode,
      'valves': valves,
    };
  }
}



dynamic payloadConversion(data) {
  dynamic dataFormation = {};
  for(var globalKey in data.keys) {
    if(['filterSite', 'fertilizerSite', 'waterSource', 'pump', 'moistureSensor', 'irrigationLine'].contains(globalKey)){
      dataFormation[globalKey] = [];
      for(var site in data[globalKey]){
        dynamic siteFormation = site;
        for(var siteKey in site.keys){
          if(!['objectId', 'sNo', 'name', 'objectName', 'connectionNo', 'type', 'controllerId', 'count', 'siteMode', 'pumpType'].contains(siteKey)){
            siteFormation[siteKey] = siteFormation[siteKey] is List<dynamic>
                ? (siteFormation[siteKey] as List<dynamic>).map((element) {
              if(element is double){
                return (data['configObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == element);
              }else{
               // print('element : $element');
                var object = (data['configObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == element['sNo']);
                for(var key in element.keys){
                  if(!(object as Map<String, dynamic>).containsKey(key)){
                    object[key] = element[key];
                  }
                }
                return object;
              }
            }).toList()
                : (data['configObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == siteFormation[siteKey], orElse: ()=> {});
          }
        }
        dataFormation[globalKey].add(site);
      }
    }
  }
  // print('dataFormation : ${jsonEncode(dataFormation)}');
  // print('-------------------------------------------');
  return dataFormation;
}


