import 'dart:convert';

MapConfigModel mapConfigModelFromJson(String str) =>
    MapConfigModel.fromJson(json.decode(str));

String mapConfigModelToJson(MapConfigModel data) => json.encode(data.toJson());

class MapConfigModel {
  int? code;
  String? message;
  Data? data;

  MapConfigModel({
    this.code,
    this.message,
    this.data,
  });

  factory MapConfigModel.fromJson(Map<String, dynamic> json) =>
      MapConfigModel(
        code: json["code"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"], ""),
      );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<DeviceList>? deviceList;
  Map<String, dynamic>? liveMessage;

  Data({
    this.deviceList,
    this.liveMessage,
  });

  factory Data.fromJson(Map<String, dynamic> json, String serialNumber) =>
      Data(
        deviceList: json["deviceList"] == null
            ? []
            : List<DeviceList>.from(
            json["deviceList"]!.map((x) => DeviceList.fromJson(x, serialNumber))),
        liveMessage: json["liveMessage"] == null ? null : json["liveMessage"],
      );

  Map<String, dynamic> toJson() => {
    "deviceList": deviceList == null
        ? []
        : List<dynamic>.from(deviceList!.map((x) => x.toJson())),
    "liveMessage": liveMessage,
  };
}

class DeviceList {
  int? controllerId;
  String? deviceId;
  String? deviceName;
  String? siteName;
  String? categoryName;
  String? modelName;
  Geography? geography;
  List<ConnectedObject>? connectedObject;
  int? referenceNumber;
  int? serialNumber;

  DeviceList({
    this.controllerId,
    this.deviceId,
    this.deviceName,
    this.siteName,
    this.categoryName,
    this.modelName,
    this.geography,
    this.connectedObject,
    this.referenceNumber,
    this.serialNumber,
  });

  factory DeviceList.fromJson(Map<String, dynamic> json, String serialNumber) =>
      DeviceList(
        controllerId: json["controllerId"],
        deviceId: json["deviceId"],
        deviceName: json["deviceName"],
        siteName: json["siteName"],
        categoryName: json["categoryName"],
        modelName: json["modelName"],
        geography: Geography.fromJson(json["geography"] ?? {}, serialNumber),
        connectedObject: json["connectedObject"] == null
            ? []
            : List<ConnectedObject>.from(
            json["connectedObject"]!.map((x) => ConnectedObject.fromJson(x, serialNumber))),
        referenceNumber: json["referenceNumber"],
        serialNumber: json["serialNumber"],
      );

  Map<String, dynamic> toJson() => {
    "controllerId": controllerId,
    "deviceId": deviceId,
    "deviceName": deviceName,
    "siteName": siteName,
    "categoryName": categoryName,
    "modelName": modelName,
    "geography": geography?.toJson(),
    "connectedObject": connectedObject == null
        ? []
        : List<dynamic>.from(connectedObject!.map((x) => x.toJson())),
    "referenceNumber": referenceNumber,
    "serialNumber": serialNumber,
  };
}

class ConnectedObject {
  int? objectId;
  double? sNo;
  String? name;
  String? objectName;
  double? location;
  double? lat;
  double? long;
  int? status;

  ConnectedObject({
    this.objectId,
    this.sNo,
    this.name,
    this.objectName,
    this.location,
    this.lat,
    this.long,
    this.status,
  });

  factory ConnectedObject.fromJson(Map<String, dynamic> json, String serialNumber) =>
      ConnectedObject(
        objectId: json["objectId"],
        sNo: json["sNo"]?.toDouble(),
        name: json["name"],
        objectName: json["objectName"],
        location: json["location"],
        lat: json["lat"]?.toDouble(),
        long: json["long"]?.toDouble(),
        status: getValueOfStatus(serialNumber),
      );

  Map<String, dynamic> toJson() => {
    "objectId": objectId,
    "sNo": sNo,
    "name": name,
    "objectName": objectName,
    "location": location,
    "lat": lat,
    "long": long,
    "status": status,
  };
}

class Geography {
  double? lat;
  double? long;
  int? status;

  Geography({
    this.lat,
    this.long,
    this.status,
  });

  factory Geography.fromJson(Map<String, dynamic> json, String serialNumber) =>
      Geography(
        lat: json["lat"]?.toDouble() ?? null,
        long: json["long"]?.toDouble() ?? null,
        status: getValueOfStatus(serialNumber)  ?? null,  // Pass serialNumber to get the status
      );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "long": long,
    "status": status,
  };
}

int getValueOfStatus(String serialNumber) {
  Map<String, dynamic>? liveMessage = Data().liveMessage;
  try {
    // Null and empty check for liveMessage
    if (liveMessage == null || liveMessage.isEmpty) {
      return 0; // Return a default value if liveMessage is null or empty
    }

    Map<String, dynamic> cM = liveMessage['cM'] as Map<String, dynamic>;

    // Iterate over the keys in the map
    for (String key in cM.keys) {
      if (key.startsWith('24')) {
        String data = cM[key] as String;
        List<String> values = data.split(';');

        // Iterate over the values and check if the serialNumber matches
        for (int i = 0; i < values.length; i++) {
          if (values[i].startsWith(serialNumber)) {
            List<String> parts = values[i].split(',');
            return int.parse(parts[1]);
          }
        }
      }
    }

    return 7; // Default status if serialNumber is not found
  } catch (e) {
    print('Error parsing data: $e');
    return 7; // Return 0 in case of error
  }
}
