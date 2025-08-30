import 'dart:convert';

PumpConditionModel pumpConditionModelFromJson(String str) => PumpConditionModel.fromJson(json.decode(str));

String pumpConditionModelToJson(PumpConditionModel data) => json.encode(data.toJson());

class PumpConditionModel {
  int? code;
  String? message;
  Data? data;

  PumpConditionModel({
    this.code,
    this.message,
    this.data,
  });

  factory PumpConditionModel.fromJson(Map<String, dynamic> json) => PumpConditionModel(
    code: json["code"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<PumpCondition>? pumpCondition;
  String? controllerReadStatus;

  Data({
    this.pumpCondition,
    this.controllerReadStatus,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pumpCondition: json["pumpCondition"] == null
        ? []
        : List<PumpCondition>.from(json["pumpCondition"].map((x) => PumpCondition.fromJson(x))),
    controllerReadStatus: json["controllerReadStatus"],
  );

  Map<String, dynamic> toJson() => {
    "pumpCondition": pumpCondition == null
        ? []
        : List<dynamic>.from(pumpCondition!.map((x) => x.toJson())),
    "controllerReadStatus": controllerReadStatus,
  };
}

class PumpCondition {
  int? objectId;
  double? sNo;
  String? name;
  String? objectName;
  double? location;
  List<SelectedPump>? selectedPumps;

  PumpCondition({
    this.objectId,
    this.sNo,
    this.name,
    this.objectName,
    this.location,
    this.selectedPumps,
  });

  factory PumpCondition.fromJson(Map<String, dynamic> json) => PumpCondition(
    objectId: json["objectId"],
    sNo: (json["sNo"] as num?)?.toDouble(),
    name: json["name"],
    objectName: json["objectName"],
    location: (json["location"] as num?)?.toDouble(),
    selectedPumps: json["selectedPumps"] == null
        ? []
        : List<SelectedPump>.from(json["selectedPumps"].map((x) => SelectedPump.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "objectId": objectId,
    "sNo": sNo,
    "name": name,
    "objectName": objectName,
    "location": location,
    "selectedPumps": selectedPumps == null
        ? []
        : List<dynamic>.from(selectedPumps!.map((x) => x.toJson())),
  };
}

class SelectedPump {
  double? sNo;
  int? objectId;

  SelectedPump({
    this.sNo,
    this.objectId,
  });

  factory SelectedPump.fromJson(Map<String, dynamic> json) => SelectedPump(
    sNo: json["sNo"],
    objectId: json["objectId"],
   );

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "objectId": objectId,
   };
}
