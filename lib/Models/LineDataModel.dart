import 'Configuration/device_object_model.dart';

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