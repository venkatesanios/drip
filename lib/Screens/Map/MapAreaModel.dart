import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';

MapAreaModel mapAreaModelFromJson(String str) => MapAreaModel.fromJson(json.decode(str));

String mapAreaModelToJson(MapAreaModel data) => json.encode(data.toJson());

class MapAreaModel {
  int? controllerId;
  String? deviceId;
  List<Mapobject>? mapobject;
  Map<String, dynamic>? liveMessage;

  MapAreaModel({
    this.controllerId,
    this.deviceId,
    this.mapobject,
    this.liveMessage,
  });

  factory MapAreaModel.fromJson(Map<String, dynamic> json) => MapAreaModel(
    controllerId: json["controllerId"],
    deviceId: json["deviceId"],
    mapobject: json["mapobject"] == null
        ? []
        : List<Mapobject>.from(json["mapobject"]!.map((x) => Mapobject.fromJson(x))),
    liveMessage: json["liveMessage"],
  );

  Map<String, dynamic> toJson() => {
    "controllerId": controllerId,
    "deviceId": deviceId,
    "mapobject": mapobject == null ? [] : List<dynamic>.from(mapobject!.map((x) => x.toJson())),
    "liveMessage": liveMessage,
  };
}

class Mapobject {
  int? objectId;
  double? sNo;
  String? name;
  String? objectName;
  List<Area>? areas;
  int? status;

  Mapobject({
    this.objectId,
    this.sNo,
    this.name,
    this.objectName,
    this.areas,
    this.status,
  });

  factory Mapobject.fromJson(Map<String, dynamic> json) => Mapobject(
    objectId: json["objectId"],
    sNo: json["sNo"]?.toDouble(),
    name: json["name"],
    objectName: json["objectName"],
    areas: json["areas"] == null ? [] : List<Area>.from(json["areas"]!.map((x) => Area.fromJson(x))),
    status: json["status"], // Note: We'll override this with getValueOfStatus
  );

  Map<String, dynamic> toJson() => {
    "objectId": objectId,
    "sNo": sNo,
    "name": name,
    "objectName": objectName,
    "areas": areas == null ? [] : List<dynamic>.from(areas!.map((x) => x.toJson())),
    "status": status,
  };
}

class Area {
  double? latitude;
  double? longitude;

  Area({
    this.latitude,
    this.longitude,
  });

  factory Area.fromJson(Map<String, dynamic> json) => Area(
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

// Corrected getValueOfStatus function
int getValueOfStatus(String serialNumber, Map<String, dynamic>? liveMessage) {
  try {
    if (liveMessage == null || liveMessage['cM'] == null) {
      return 0;
    }

    final cM = liveMessage['cM'] as Map<String, dynamic>;
    final data = cM['2402'] as String?;

    if (data == null || data.isEmpty) {
      return 0;
    }

    final values = data.split(';');
    for (final value in values) {
      if (value.startsWith(serialNumber)) {
        final parts = value.split(',');
        return int.parse(parts[1]);
      }
    }

    return 0;
  } catch (e) {
    print('Error parsing status for $serialNumber: $e');
    return 0;
  }
}

// Valve class for map rendering
class Valve {
  final String name;
  final List<LatLng> area;
  int status;
  final int objectId;
  final double sNo;
  final String objectName;

  Valve({
    required this.name,
    required this.area,
    required this.status,
    required this.objectId,
    required this.sNo,
    required this.objectName,
  });

  factory Valve.fromMapobject(Mapobject mapobject, Map<String, dynamic>? liveMessage) {
    return Valve(
      name: mapobject.name ?? '',
      area: mapobject.areas?.map((area) => LatLng(area.latitude ?? 0.0, area.longitude ?? 0.0)).toList() ?? [],
      status: getValueOfStatus(mapobject.sNo?.toString() ?? '', liveMessage),
      objectId: mapobject.objectId ?? 0,
      sNo: mapobject.sNo ?? 0.0,
      objectName: mapobject.objectName ?? '',
    );
  }

  void updateStatus(int newStatus) {
    status = newStatus;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'areas': area.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList(),
      'status': status,
      'objectId': objectId,
      'sNo': sNo,
      'objectName': objectName,
    };
  }

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      name: json['name'],
      area: List<LatLng>.from(
        (json['areas'] as List).map((point) => LatLng(point['latitude'], point['longitude'])),
      ),
      status: json['status'],
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      objectName: json['objectName'],
    );
  }
}