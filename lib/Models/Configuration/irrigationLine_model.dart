
import 'device_object_model.dart';

class IrrigationLineModel{
  DeviceObjectModel commonDetails;
  List<double> source;
  List<double> pump;
  double centralFiltration;
  double localFiltration;
  double centralFertilization;
  double localFertilization;
  List<double> valve;
  List<double> mainValve;
  List<double> fan;
  List<double> fogger;
  List<double> pesticides;
  List<double> heater;
  List<double> screen;
  List<double> vent;
  double powerSupply;
  double pressureSwitch;
  double waterMeter;
  double pressureIn;
  double pressureOut;
  List<double> moisture;
  List<double> temperature;
  List<double> soilTemperature;
  List<double> humidity;
  List<double> co2;

  IrrigationLineModel({
    required this.commonDetails,
    required this.source,
    required this.pump,
    this.centralFiltration = 0.00,
    this.localFiltration = 0.00,
    this.centralFertilization = 0.00,
    this.localFertilization = 0.00,
    required this.valve,
    required this.mainValve,
    required this.fan,
    required this.fogger,
    required this.pesticides,
    required this.heater,
    required this.screen,
    required this.vent,
    this.powerSupply = 0.00,
    this.pressureSwitch = 0.00,
    this.waterMeter = 0.00,
    this.pressureIn = 0.00,
    this.pressureOut = 0.00,
    required this.moisture,
    required this.temperature,
    required this.soilTemperature,
    required this.humidity,
    required this.co2,
  });

  factory IrrigationLineModel.fromJson(data){
    DeviceObjectModel deviceObjectModel = DeviceObjectModel.fromJson(data);
    return IrrigationLineModel(
        commonDetails: deviceObjectModel,
        source: (data['source'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        pump: (data['pump'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        centralFiltration: data['centralFiltration'],
        localFiltration: data['localFiltration'],
        centralFertilization: data['centralFertilization'],
        localFertilization: data['localFertilization'],
        valve: (data['valve'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        mainValve: (data['mainValve'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        fan: (data['fan'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        fogger: (data['fogger'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        pesticides: (data['pesticides'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        heater: (data['heater'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        screen: (data['screen'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        vent: (data['vent'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        powerSupply: data['powerSupply'],
        pressureSwitch: data['pressureSwitch'],
        waterMeter: data['waterMeter'],
        pressureIn: data['pressureIn'],
        pressureOut: data['pressureOut'],
        moisture: (data['moisture'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        temperature: (data['temperature'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        soilTemperature: (data['soilTemperature'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        humidity: (data['humidity'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        co2: (data['co2'] as List<dynamic>).map((sNo) => sNo as double).toList()
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
      'source' : source,
      'pump' : pump,
      'centralFiltration' : centralFiltration,
      'localFiltration' : localFiltration,
      'centralFertilization' : centralFertilization,
      'localFertilization' : localFertilization,
      'valve' : valve,
      'mainValve' : mainValve,
      'fan' : fan,
      'fogger' : fogger,
      'pesticides' : pesticides,
      'heater' : heater,
      'screen' : screen,
      'vent' : vent,
      'powerSupply' : powerSupply,
      'pressureSwitch' : pressureSwitch,
      'waterMeter' : waterMeter,
      'pressureIn' : pressureIn,
      'pressureOut' : pressureOut,
      'moisture' : moisture,
      'temperature' : temperature,
      'soilTemperature' : soilTemperature,
      'humidity' : humidity,
      'co2' : co2,
    });
    return commonInfo;
  }

}

enum LineParameter{source, pump, centralFiltration, localFiltration, centralFertilization, localFertilization, valve, mainValve, fan, fogger, pesticides, heater, screen, vent, powerSupply, pressureSwitch, waterMeter, pressureIn, pressureOut, moisture, temperature, soilTemperature, humidity, co2}