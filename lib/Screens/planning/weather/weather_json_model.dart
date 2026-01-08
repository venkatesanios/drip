// To parse this JSON data, do
//
//     final WeatherJsonModel = WeatherJsonModelFromJson(jsonString);

import 'dart:convert';

import 'package:oro_drip_irrigation/Screens/planning/weather/weather_live_model.dart';

WeatherJsonModel WeatherJsonModelFromJson(String str) => WeatherJsonModel.fromJson(json.decode(str));

String WeatherJsonModelToJson(WeatherJsonModel data) => json.encode(data.toJson());

class WeatherJsonModel {
  int code;
  String message;
  Data data;

  WeatherJsonModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory WeatherJsonModel.fromJson(Map<String, dynamic> json) => WeatherJsonModel(
    code: json["code"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  WeatherLive weatherLive;
  List<DeviceList> deviceList;
  List<IrrigationLine> irrigationLine;
  List<ConfigObject> configObject;

  Data({
    required this.weatherLive,
    required this.deviceList,
    required this.irrigationLine,
    required this.configObject,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    weatherLive: WeatherLive.fromJson(json["weatherLive"]),
    deviceList: List<DeviceList>.from(json["deviceList"].map((x) => DeviceList.fromJson(x))),
    irrigationLine: List<IrrigationLine>.from(json["irrigationLine"].map((x) => IrrigationLine.fromJson(x))),
    configObject: List<ConfigObject>.from(json["configObject"].map((x) => ConfigObject.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "weatherLive": weatherLive.toJson(),
    "deviceList": List<dynamic>.from(deviceList.map((x) => x.toJson())),
    "irrigationLine": List<dynamic>.from(irrigationLine.map((x) => x.toJson())),
    "configObject": List<dynamic>.from(configObject.map((x) => x.toJson())),
  };
}

class ConfigObject {
  int objectId;
  double sNo;
  String name;
  String objectName;
  int? controllerId;
  double location;

  ConfigObject({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.objectName,
    required this.controllerId,
    required this.location,
  });

  factory ConfigObject.fromJson(Map<String, dynamic> json) => ConfigObject(
    objectId: json["objectId"],
    sNo: json["sNo"]?.toDouble(),
    name: json["name"],
    objectName: json["objectName"],
    controllerId: json["controllerId"],
    location: json["location"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "objectId": objectId,
    "sNo": sNo,
    "name": name,
    "objectName": objectName,
    "controllerId": controllerId,
    "location": location,
  };
}

class DeviceList {
  int controllerId;
  String deviceId;
  String deviceName;
  int serialNumber;

  DeviceList({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.serialNumber,
  });

  factory DeviceList.fromJson(Map<String, dynamic> json) => DeviceList(
    controllerId: json["controllerId"],
    deviceId: json["deviceId"],
    deviceName: json["deviceName"],
    serialNumber: json["serialNumber"],
  );

  Map<String, dynamic> toJson() => {
    "controllerId": controllerId,
    "deviceId": deviceId,
    "deviceName": deviceName,
    "serialNumber": serialNumber,
  };
}

class IrrigationLine {
  int objectId;
  double sNo;
  String name;
  String objectName;
  List<int> weatherStation;

  IrrigationLine({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.objectName,
    required this.weatherStation,
  });

  factory IrrigationLine.fromJson(Map<String, dynamic> json) => IrrigationLine(
    objectId: json["objectId"],
    sNo: json["sNo"]?.toDouble(),
    name: json["name"],
    objectName: json["objectName"],
    weatherStation: List<int>.from(json["weatherStation"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "objectId": objectId,
    "sNo": sNo,
    "name": name,
    "objectName": objectName,
    "weatherStation": List<dynamic>.from(weatherStation.map((x) => x)),
  };
}

class WeatherLive {
  String cC;
  CM cM;
  DateTime cD;
  String cT;
  String mC;

  WeatherLive({
    required this.cC,
    required this.cM,
    required this.cD,
    required this.cT,
    required this.mC,
  });

  factory WeatherLive.fromJson(Map<String, dynamic> json) => WeatherLive(
    cC: json["cC"],
    cM: CM.fromJson(json["cM"]),
    cD: DateTime.parse(json["cD"]),
    cT: json["cT"],
    mC: json["mC"],
  );

  Map<String, dynamic> toJson() => {
    "cC": cC,
    "cM": cM.toJson(),
    "cD": "${cD.year.toString().padLeft(4, '0')}-${cD.month.toString().padLeft(2, '0')}-${cD.day.toString().padLeft(2, '0')}",
    "cT": cT,
    "mC": mC,
  };
}

class CM {
  String the5101;

  CM({
    required this.the5101,
  });

  factory CM.fromJson(Map<String, dynamic> json) => CM(
    the5101: json["5101"],
  );

  Map<String, dynamic> toJson() => {
    "5101": the5101,
  };
}



