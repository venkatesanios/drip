import 'dart:convert';

MapConfigModel mapConfigModelFromJson(String str) =>
    MapConfigModel.fromJson(json.decode(str));

String mapConfigModelToJson(MapConfigModel data) =>
    json.encode(data.toJson());

class MapConfigModel {
  int? code;
  String? message;
  Data? data;

  MapConfigModel({this.code, this.message, this.data});

  factory MapConfigModel.fromJson(Map<String, dynamic> json) => MapConfigModel(
    code: json["code"],
    message: json["message"],
    data:
    json["data"] == null ? null : Data.fromJson(json["data"]),
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

  Data({this.deviceList, this.liveMessage});

  factory Data.fromJson(Map<String, dynamic> json) {
    final liveMsg = json["liveMessage"];
    return Data(
      deviceList: json["deviceList"] == null
          ? []
          : List<DeviceList>.from(json["deviceList"].map(
              (x) => DeviceList.fromJson(x, liveMsg))),
      liveMessage: liveMsg,
    );
  }

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

  DeviceList({
    this.controllerId,
    this.deviceId,
    this.deviceName,
    this.siteName,
    this.categoryName,
    this.modelName,
    this.geography,
    this.connectedObject,
   });

  factory DeviceList.fromJson(
      Map<String, dynamic> json, Map<String, dynamic>? liveMessage) {
    // Use first object's sNo for geography status if available
    String? geoSerial = (json["connectedObject"] != null &&
        (json["connectedObject"] as List).isNotEmpty)
        ? "${json["connectedObject"][0]["sNo"]}"
        : "";

    return DeviceList(
      controllerId: json["controllerId"],
      deviceId: json["deviceId"],
      deviceName: json["deviceName"],
      siteName: json["siteName"],
      categoryName: json["categoryName"],
      modelName: json["modelName"],
      geography: Geography.fromJson(
          json["geography"] ?? {}, geoSerial, liveMessage),
      connectedObject: json["connectedObject"] == null
          ? []
          : List<ConnectedObject>.from(json["connectedObject"].map((x) =>
          ConnectedObject.fromJson(x, "${x["sNo"]}", liveMessage))),
     );
  }

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
  int? percentage;

  ConnectedObject({
    this.objectId,
    this.sNo,
    this.name,
    this.objectName,
    this.location,
    this.lat,
    this.long,
    this.status,
    this.percentage,
  });

  factory ConnectedObject.fromJson(Map<String, dynamic> json,
      String serialNumber, Map<String, dynamic>? liveMessage) =>
      ConnectedObject(
        objectId: json["objectId"],
        sNo: json["sNo"]?.toDouble(),
        name: json["name"],
        objectName: json["objectName"],
        location: json["location"]?.toDouble(),
        lat: json["lat"]?.toDouble(),
        long: json["long"]?.toDouble(),
        status: getValueOfStatus('${json["sNo"]}', liveMessage),
        percentage: getValuepercentage('${json["sNo"]}', liveMessage),
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
    "percentage": percentage,
  };
}

class Geography {
  double? lat;
  double? long;
  int? status;

  Geography({this.lat, this.long, this.status});

  factory Geography.fromJson(Map<String, dynamic> json, String serialNumber,
      Map<String, dynamic>? liveMessage) =>
      Geography(
        lat: json["lat"]?.toDouble(),
        long: json["long"]?.toDouble(),
        status: getValueOfStatus(serialNumber, liveMessage),
      );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "long": long,
    "status": status,
  };
}

int getValueOfStatus(String serialNumber, Map<String, dynamic>? liveMessage) {
  try {
    if (liveMessage == null || liveMessage['cM'] == null) return 0;

    final cM = liveMessage['cM'] as Map<String, dynamic>;
    final data = cM['2402'] as String?;

    if (data == null || data.isEmpty) return 0;

    final values = data.split(';');
    for (final value in values) {
      if (value.startsWith(serialNumber)) {
        final parts = value.split(',');
        return int.tryParse(parts[1]) ?? 0;
      }
    }
    return 0;
  } catch (e) {
    print('Error parsing status for $serialNumber: $e');
    return 0;
  }
}
int getValuepercentage(String serialNumber, Map<String, dynamic>? liveMessage) {
  try {
    if (liveMessage == null || liveMessage['cM'] == null) return 0;

    final cM = liveMessage['cM'] as Map<String, dynamic>;
    final data = cM['2402'] as String?;

    if (data == null || data.isEmpty) return 0;

    final values = data.split(';');
    for (final value in values) {
      if (value.startsWith(serialNumber)) {
        final parts = value.split(',');
        return int.tryParse(parts[2]) ?? 0;
      }
    }
    return 0;
  } catch (e) {
    print('Error parsing status for $serialNumber: $e');
    return 0;
  }
}

