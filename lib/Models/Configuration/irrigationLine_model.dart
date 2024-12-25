
import 'device_object_model.dart';

class IrrigationLineModel{
  DeviceObjectModel commonDetails;
  List<int> pump;
  List<int> centralFiltration;
  List<int> localFiltration;
  List<int> centralFertilization;
  List<int> localFertilization;
  List<int>? valve;
  List<int>? mainValve;
  List<int>? fan;
  List<int>? fogger;
  List<int>? pesticides;
  List<int>? heater;
  List<int>? screen;
  List<int>? vent;
  List<int>? powerSupply;
  List<int>? pressureSwitch;
  List<int>? waterMeter;
  List<int>? pressureIn;
  List<int>? pressureOut;
  List<int>? moisture;
  List<int>? temperature;
  List<int>? soilTemperature;
  List<int>? humidity;
  List<int>? co2;

  IrrigationLineModel({
    required this.commonDetails,
    required this.pump,
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

  factory IrrigationLineModel.fromJson(data){
    return IrrigationLineModel(
        commonDetails: data,
        pump: data['pump'],
        centralFiltration: data['centralFiltration'],
        localFiltration: data['localFiltration'],
        centralFertilization: data['centralFertilization'],
        localFertilization: data['localFertilization'],
        valve: data['valve'],
        mainValve: data['mainValve'],
        fan: data['fan'],
        fogger: data['fogger'],
        pesticides: data['pesticides'],
        heater: data['heater'],
        screen: data['screen'],
        vent: data['vent'],
        powerSupply: data['powerSupply'],
        pressureSwitch: data['pressureSwitch'],
        waterMeter: data['waterMeter'],
        pressureIn: data['pressureIn'],
        pressureOut: data['pressureOut'],
        moisture: data['moisture'],
        temperature: data['temperature'],
        soilTemperature: data['soilTemperature'],
        humidity: data['humidity'],
        co2: data['co2']
    );
  }

  Map<String, dynamic> toJson(){
    var commonInfo = commonDetails.toJson();
    commonInfo.addAll({
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