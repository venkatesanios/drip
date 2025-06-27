
import 'device_object_model.dart';

class IrrigationLineModel{
  DeviceObjectModel commonDetails;
  List<double> sourcePump;
  List<double> irrigationPump;
  double centralFiltration;
  double localFiltration;
  double centralFertilization;
  double localFertilization;
  List<double> valve;
  List<double> mainValve;
  List<double> light;
  List<double> gate;
  List<double> fan;
  List<double> fogger;
  List<double> mist;
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
  List<int> weatherStation;

  IrrigationLineModel({
    required this.commonDetails,
    required this.sourcePump,
    required this.irrigationPump,
    this.centralFiltration = 0.00,
    this.localFiltration = 0.00,
    this.centralFertilization = 0.00,
    this.localFertilization = 0.00,
    required this.valve,
    required this.mainValve,
    required this.light,
    required this.gate,
    required this.fan,
    required this.fogger,
    required this.mist,
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
    required this.weatherStation,
  });



  factory IrrigationLineModel.fromJson(data){
    DeviceObjectModel deviceObjectModel = DeviceObjectModel.fromJson(data);

    return IrrigationLineModel(
        commonDetails: deviceObjectModel,
        sourcePump: (data['sourcePump'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        irrigationPump: (data['irrigationPump'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        centralFiltration: intOrDoubleValidate(data['centralFiltration']),
        localFiltration: intOrDoubleValidate(data['localFiltration']),
        centralFertilization: intOrDoubleValidate(data['centralFertilization']),
        localFertilization: intOrDoubleValidate(data['localFertilization']),
        valve: (data['valve'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        mainValve: (data['mainValve'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        light: data['light'] == null ? [] : (data['light'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        gate: data['gate'] == null ? [] : (data['gate'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        fan: (data['fan'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        fogger: (data['fogger'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        mist: data['mist'] == null ? [] : (data['mist'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        pesticides: (data['pesticides'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        heater: (data['heater'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        screen: (data['screen'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        vent: (data['vent'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        powerSupply: intOrDoubleValidate(data['powerSupply']),
        pressureSwitch: intOrDoubleValidate(data['pressureSwitch']),
        waterMeter: intOrDoubleValidate(data['waterMeter']),
        pressureIn: intOrDoubleValidate(data['pressureIn']),
        pressureOut: intOrDoubleValidate(data['pressureOut']),
        moisture: (data['moisture'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        temperature: (data['temperature'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        soilTemperature: (data['soilTemperature'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        humidity: (data['humidity'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        co2: (data['co2'] as List<dynamic>).map((sNo) => sNo as double).toList(),
        weatherStation: data['weatherStation'] != null ? (data['weatherStation'] as List<dynamic>).map((controllerNo) => controllerNo as int).toList() : []
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
      'sourcePump' : sourcePump,
      'irrigationPump' : irrigationPump,
      'centralFiltration' : centralFiltration,
      'localFiltration' : localFiltration,
      'centralFertilization' : centralFertilization,
      'localFertilization' : localFertilization,
      'valve' : valve,
      'mainValve' : mainValve,
      'light' : light,
      'gate' : gate,
      'fan' : fan,
      'fogger' : fogger,
      'mist' : mist,
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
      'weatherStation' : weatherStation,
    });
    return commonInfo;
  }

  void updateObjectIdIfDeletedInProductLimit(List<double> objectIdToBeDeleted){
    sourcePump = sourcePump.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    irrigationPump = irrigationPump.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    valve = valve.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    mainValve = mainValve.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    light = light.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    gate = gate.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    fan = fan.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    fogger = fogger.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    mist = mist.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    pesticides = pesticides.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    heater = heater.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    screen = screen.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    vent = vent.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    moisture = moisture.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    temperature = temperature.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    soilTemperature = soilTemperature.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    humidity = humidity.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    co2 = co2.where((objectId) => !objectIdToBeDeleted.contains(objectId)).toList();
    centralFiltration = objectIdToBeDeleted.contains(centralFiltration) ? 0.0 : centralFiltration;
    localFiltration = objectIdToBeDeleted.contains(localFiltration) ? 0.0 : localFiltration;
    centralFertilization = objectIdToBeDeleted.contains(centralFertilization) ? 0.0 : centralFertilization;
    localFertilization = objectIdToBeDeleted.contains(localFertilization) ? 0.0 : localFertilization;
    powerSupply = objectIdToBeDeleted.contains(powerSupply) ? 0.0 : powerSupply;
    pressureSwitch = objectIdToBeDeleted.contains(pressureSwitch) ? 0.0 : pressureSwitch;
    waterMeter = objectIdToBeDeleted.contains(waterMeter) ? 0.0 : waterMeter;
    pressureIn = objectIdToBeDeleted.contains(pressureIn) ? 0.0 : pressureIn;
    pressureOut = objectIdToBeDeleted.contains(pressureOut) ? 0.0 : pressureOut;
  }
}

double intOrDoubleValidate(value){
  if(value is int){
    return value.toDouble();
  }else{
    return value;
  }
}

enum LineParameter{source, sourcePump, irrigationPump, centralFiltration, localFiltration, centralFertilization, localFertilization, valve, mainValve, light, gate, fan, fogger,mist, pesticides, heater, screen, vent, powerSupply, pressureSwitch, waterMeter, pressureIn, pressureOut, moisture, temperature, soilTemperature, humidity, co2}

