import 'package:oro_drip_irrigation/utils/constants.dart';

class LiveData {
  int? code;
  String? message;
  List<Datum>? data;

  LiveData({
    this.code,
    this.message,
    this.data,
  });
  // Manual fromJson
  factory LiveData.fromJson(Map<String, dynamic> json) {
    return LiveData(
      code: json['code'],
      message: json['message'],
      data: (json['data'] as List?)?.map((e) => Datum.fromJson(e)).toList(),
    );
  }
  // Manual toJson
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class Datum {
  int? groupId;
  String? groupName;
  List<Master>? master;

  Datum({
    this.groupId,
    this.groupName,
    this.master,
  });

  // Manual fromJson
  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      groupId: json['groupId'],
      groupName: json['groupName'],
      master: (json['master'] as List?)?.map((e) => Master.fromJson(e)).toList(),
    );
  }

  // Manual toJson
  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'master': master?.map((e) => e.toJson()).toList(),
    };
  }
}

class Master {
  int? controllerId;
  String? deviceId;
  String? deviceName;
  int? categoryId;
  String? categoryName;
  int? modelId;
  String? modelName;
  int? conditionLibraryCount;
  List<Unit>? units;
  List<dynamic>? nodeList;
  Config? config;
  Live? live;

  Master({
    this.controllerId,
    this.deviceId,
    this.deviceName,
    this.categoryId,
    this.categoryName,
    this.modelId,
    this.modelName,
    this.conditionLibraryCount,
    this.units,
    this.nodeList,
    this.config,
    this.live,
  });

  // Manual fromJson
  factory Master.fromJson(Map<String, dynamic> json) {
    return Master(
      controllerId: json['controllerId'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      modelId: json['modelId'],
      modelName: json['modelName'],
      conditionLibraryCount: json['conditionLibraryCount'],
      units: (json['units'] as List?)?.map((e) => Unit.fromJson(e)).toList(),
      nodeList: json['nodeList'],
      config: json['config'] != null ? Config.fromJson(AppConstants().payloadConversion(json['config'])) : null,
      live: json['live'] != null ? Live.fromJson(json['live']) : null,
    );
  }

  // Manual toJson
  Map<String, dynamic> toJson() {
    return {
      'controllerId': controllerId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'modelId': modelId,
      'modelName': modelName,
      'conditionLibraryCount': conditionLibraryCount,
      'units': units?.map((e) => e.toJson()).toList(),
      'nodeList': nodeList,
      // 'config': config?.toJson(),
      'live': live?.toJson(),
    };
  }
}

class Config {
  List<FilterSite>? filterSite;
  List<FertilizerSite>? fertilizerSite;
  List<WaterSource>? waterSource;
  List<Pump>? pump;
  List<MoistureSensor>? moistureSensor;
  List<IrrigationLine>? irrigationLine;

  Config({
    this.filterSite,
    this.fertilizerSite,
    this.waterSource,
    this.pump,
    this.moistureSensor,
    this.irrigationLine,
  });

  // Manual fromJson
  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      filterSite: (json['filterSite'] as List?)?.map((e) => FilterSite.fromJson(e)).toList(),
      fertilizerSite: (json['fertilizerSite'] as List?)?.map((e) => FertilizerSite.fromJson(e)).toList(),
      waterSource: (json['waterSource'] as List?)?.map((e) => WaterSource.fromJson(e)).toList(),
      pump: (json['pump'] as List?)?.map((e) => Pump.fromJson(e)).toList(),
      moistureSensor: (json['moistureSensor'] as List?)?.map((e) => MoistureSensor.fromJson(e)).toList(),
      irrigationLine: (json['irrigationLine'] as List?)?.map((e) => IrrigationLine.fromJson(e)).toList(),
    );
  }

// Manual toJson
// Map<String, dynamic> toJson() {
//   return {
//     'filterSite': filterSite?.map((e) => e.toJson()).toList(),
//     'fertilizerSite': fertilizerSite?.map((e) => e.toJson()).toList(),
//     'waterSource': waterSource?.map((e) => e.toJson()).toList(),
//     'pump': pump?.map((e) => e.toJson()).toList(),
//     'moistureSensor': moistureSensor?.map((e) => e.toJson()).toList(),
//     'irrigationLine': irrigationLine?.map((e) => e.toJson()).toList(),
//   };
// }
}

class FilterSite {
  final DeviceObjectModel filterSite;
  final int? siteMode;
  final List<DeviceObjectModel> filters;
  final DeviceObjectModel pressureIn;
  final DeviceObjectModel pressureOut;
  final DeviceObjectModel backWashValve;

  FilterSite({
    required this.filterSite,
    required this.siteMode,
    required this.filters,
    required this.pressureIn,
    required this.pressureOut,
    required this.backWashValve,
  });

  factory FilterSite.fromJson(Map<String, dynamic> json) {
    return FilterSite(
      filterSite: DeviceObjectModel.fromJson(json),
      siteMode: json['siteMode'],
      filters: (json['filters'] as List).map((e) => DeviceObjectModel.fromJson(e as Map<String, dynamic>)).toList(),
      pressureIn: DeviceObjectModel.fromJson(Map<String, dynamic>.from(json['pressureIn'])),
      pressureOut: DeviceObjectModel.fromJson(Map<String, dynamic>.from(json['pressureOut'])),
      backWashValve: DeviceObjectModel.fromJson(Map<String, dynamic>.from(json['backWashValve'])),
    );
  }
}

class FertilizerSite {
  final DeviceObjectModel fertilizerSite;
  final int? siteMode;
  final List<DeviceObjectModel> channel;
  final List<DeviceObjectModel> boosterPump;
  final List<DeviceObjectModel> agitator;
  final List<DeviceObjectModel> selector;
  final List<DeviceObjectModel> ec;
  final List<DeviceObjectModel> ph;

  FertilizerSite({
    required this.fertilizerSite,
    required this.siteMode,
    required this.channel,
    required this.boosterPump,
    required this.agitator,
    required this.selector,
    required this.ec,
    required this.ph,
  });

  factory FertilizerSite.fromJson(Map<String, dynamic> json) {
    return FertilizerSite(
      fertilizerSite: DeviceObjectModel.fromJson(json),
      siteMode: json['siteMode'],
      channel: (json['channel'] as List).map((e) => DeviceObjectModel.fromJson(e as Map<String, dynamic>)).toList(),
      boosterPump: (json['boosterPump'] as List).map((e) => DeviceObjectModel.fromJson(e as Map<String, dynamic>)).toList(),
      agitator: (json['agitator'] as List).map((e) => DeviceObjectModel.fromJson(e as Map<String, dynamic>)).toList(),
      selector: (json['selector'] as List).map((e) => DeviceObjectModel.fromJson(e as Map<String, dynamic>)).toList(),
      ec: (json['ec'] as List).map((e) => DeviceObjectModel.fromJson(e as Map<String, dynamic>)).toList(),
      ph: (json['ph'] as List).map((e) => DeviceObjectModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class WaterSource {
  final DeviceObjectModel waterSource;
  final DeviceObjectModel sourceType;
  final DeviceObjectModel level;
  final DeviceObjectModel topFloat;
  final DeviceObjectModel bottomFloat;
  final List<DeviceObjectModel> inletPump;
  final List<DeviceObjectModel> outletPump;
  final List<DeviceObjectModel> valves;

  WaterSource({
    required this.waterSource,
    required this.sourceType,
    required this.level,
    required this.topFloat,
    required this.bottomFloat,
    required this.inletPump,
    required this.outletPump,
    required this.valves,
  });

  factory WaterSource.fromJson(Map<String, dynamic> json) {
    return WaterSource(
      waterSource: DeviceObjectModel.fromJson(json),
      sourceType: DeviceObjectModel.fromJson(json['sourceType']),
      level: DeviceObjectModel.fromJson(json['level']),
      topFloat: DeviceObjectModel.fromJson(json['topFloat']),
      bottomFloat: DeviceObjectModel.fromJson(json['bottomFloat']),
      inletPump: (json['inletPump'] as List).map((e) => DeviceObjectModel.fromJson(e as Map<String, dynamic>)).toList(),
      outletPump: (json['outletPump'] as List).map((e) => DeviceObjectModel.fromJson(e as Map<String, dynamic>)).toList(),
      valves: (json['valves'] as List).map((e) => DeviceObjectModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class Pump {
  final DeviceObjectModel waterSource;
  final DeviceObjectModel level;
  final DeviceObjectModel pressure;
  final DeviceObjectModel waterMeter;
  final int pumpType;

  Pump({
    required this.waterSource,
    required this.level,
    required this.pressure,
    required this.waterMeter,
    required this.pumpType,
  });

  factory Pump.fromJson(Map<String, dynamic> json) {
    return Pump(
      waterSource: DeviceObjectModel.fromJson(json),
      level: DeviceObjectModel.fromJson(json['level']),
      pressure: DeviceObjectModel.fromJson(json['pressure']),
      waterMeter: DeviceObjectModel.fromJson(json['waterMeter']),
      pumpType: json['pumpType'],
    );
  }
}

class MoistureSensor {
  final DeviceObjectModel waterSource;
  final List<DeviceObjectModel> valves;

  MoistureSensor({
    required this.waterSource,
    required this.valves,
  });

  factory MoistureSensor.fromJson(Map<String, dynamic> json) {
    return MoistureSensor(
      waterSource: DeviceObjectModel.fromJson(json),
      valves: (json['valves'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}

class IrrigationLine {
  DeviceObjectModel irrigationLine;
  List<DeviceObjectModel> source;
  List<DeviceObjectModel> sourcePump;
  List<DeviceObjectModel> irrigationPump;
  DeviceObjectModel centralFiltration;
  DeviceObjectModel localFiltration;
  DeviceObjectModel centralFertilization;
  DeviceObjectModel localFertilization;
  List<DeviceObjectModel> valve;
  List<DeviceObjectModel> mainValve;
  List<DeviceObjectModel> fan;
  List<DeviceObjectModel> fogger;
  List<DeviceObjectModel> pesticides;
  List<DeviceObjectModel> heater;
  List<DeviceObjectModel> screen;
  List<DeviceObjectModel> vent;
  DeviceObjectModel powerSupply;
  DeviceObjectModel pressureSwitch;
  DeviceObjectModel waterMeter;
  DeviceObjectModel pressureIn;
  DeviceObjectModel pressureOut;
  List<DeviceObjectModel> moisture;
  List<DeviceObjectModel> temperature;
  List<DeviceObjectModel> soilTemperature;
  List<DeviceObjectModel> humidity;
  List<DeviceObjectModel> co2;

  IrrigationLine({
    required this.irrigationLine,
    required this.source,
    required this.sourcePump,
    required this.irrigationPump,
    required this.centralFiltration,
    required this.localFiltration,
    required this.centralFertilization,
    required this.localFertilization,
    required this.valve,
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
  });

  factory IrrigationLine.fromJson(Map<String, dynamic> json) {
    return IrrigationLine(
      irrigationLine: DeviceObjectModel.fromJson(json),
      source: (json['source'] as List).map((e) => DeviceObjectModel.fromJson(Map<String,dynamic>.from(e))).toList(),
      sourcePump: (json['sourcePump'] as List).map((e) => DeviceObjectModel.fromJson(Map<String,dynamic>.from(e))).toList(),
      irrigationPump: (json['irrigationPump'] as List).map((e) => DeviceObjectModel.fromJson(Map<String,dynamic>.from(e))).toList(),
      centralFiltration: DeviceObjectModel.fromJson(Map<String,dynamic>.from(json['centralFiltration'])),
      localFiltration: DeviceObjectModel.fromJson(Map<String,dynamic>.from(json['localFiltration'])),
      centralFertilization: DeviceObjectModel.fromJson(Map<String,dynamic>.from(json['centralFertilization'])),
      localFertilization: DeviceObjectModel.fromJson(Map<String,dynamic>.from(json['localFertilization'])),
      valve: (json['valve'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      mainValve: (json['mainValve'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      fan: (json['fan'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      fogger: (json['fogger'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      pesticides: (json['pesticides'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      heater: (json['heater'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      screen: (json['screen'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      vent: (json['vent'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      powerSupply: DeviceObjectModel.fromJson(Map<String, dynamic>.from(json['powerSupply'])),
      pressureSwitch: DeviceObjectModel.fromJson(Map<String, dynamic>.from(json['pressureSwitch'])),
      waterMeter: DeviceObjectModel.fromJson(Map<String, dynamic>.from(json['waterMeter'])),
      pressureIn: DeviceObjectModel.fromJson(Map<String, dynamic>.from(json['pressureIn'])),
      pressureOut: DeviceObjectModel.fromJson(Map<String, dynamic>.from(json['pressureOut'])),
      moisture: (json['moisture'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      temperature: (json['temperature'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      soilTemperature: (json['soilTemperature'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      humidity: (json['humidity'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      co2: (json['co2'] as List).map((e) => DeviceObjectModel.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}

class DeviceObjectModel {
  final int objectId;
  double? sNo;
  String? name;
  String objectName;
  int? connectionNo;
  final String type;
  int? controllerId;
  String? count;
  int mode;

  DeviceObjectModel({
    required this.objectId,
    this.sNo,
    this.name,
    this.connectionNo,
    required this.objectName,
    required this.type,
    this.controllerId,
    this.count,
    this.mode = 0,
  });

  factory DeviceObjectModel.fromJson(data){
    return DeviceObjectModel(
        objectId : data['objectId'] ?? 0,
        sNo : data['sNo'],
        name : data['name'] ?? '',
        connectionNo : data['connectionNo'] ?? 0,
        objectName : data['objectName'] ?? '',
        type : data['type'] ?? '',
        controllerId : data['controllerId'],
        count: data['count']
    );
  }

  dynamic toJson(){
    return {
      'objectId' : objectId,
      'sNo' : sNo,
      'name' : name,
      'connectionNo' : connectionNo,
      'objectName' : objectName,
      'type' : type,
      'controllerId' : controllerId,
      'count' : count
    };
  }
}

class Live {
  String? the2402;
  String? the2403;
  String? the2404;
  String? the2405;
  String? the2406;
  String? the2407;
  String? the2408;
  String? the2409;
  String? the2410;
  String? the2412;
  String? cC;
  DateTime? cD;
  String? cT;
  String? mC;

  Live({
    this.the2402,
    this.the2403,
    this.the2404,
    this.the2405,
    this.the2406,
    this.the2407,
    this.the2408,
    this.the2409,
    this.the2410,
    this.the2412,
    this.cC,
    this.cD,
    this.cT,
    this.mC,
  });

  // Manual fromJson
  factory Live.fromJson(Map<String, dynamic> json) {
    return Live(
      the2402: json['2402'],
      the2403: json['2403'],
      the2404: json['2404'],
      the2405: json['2405'],
      the2406: json['2406'],
      the2407: json['2407'],
      the2408: json['2408'],
      the2409: json['2409'],
      the2410: json['2410'],
      the2412: json['2412'],
      cC: json['cC'],
      cD: json['cD'] != null ? DateTime.parse(json['cD']) : null,
      cT: json['cT'],
      mC: json['mC'],
    );
  }

  // Manual toJson
  Map<String, dynamic> toJson() {
    return {
      '2402': the2402,
      '2403': the2403,
      '2404': the2404,
      '2405': the2405,
      '2406': the2406,
      '2407': the2407,
      '2408': the2408,
      '2409': the2409,
      '2410': the2410,
      '2412': the2412,
      'cC': cC,
      'cD': cD?.toIso8601String(),
      'cT': cT,
      'mC': mC,
    };
  }
}

class Unit {
  int? dealerDefinitionId;
  String? parameter;
  String? value;

  Unit({
    this.dealerDefinitionId,
    this.parameter,
    this.value,
  });

  // Manual fromJson
  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      dealerDefinitionId: json['dealerDefinitionId'],
      parameter: json['parameter'],
      value: json['value'],
    );
  }

  // Manual toJson
  Map<String, dynamic> toJson() {
    return {
      'dealerDefinitionId': dealerDefinitionId,
      'parameter': parameter,
      'value': value,
    };
  }
}

class BackWashValve {
  BackWashValve();

  // Manual fromJson
  factory BackWashValve.fromJson(Map<String, dynamic> json) {
    return BackWashValve();
  }

  // Manual toJson
  Map<String, dynamic> toJson() {
    return {};
  }
}



