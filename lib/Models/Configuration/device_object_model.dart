
class DeviceObjectModel {
  final int objectId;
  double? sNo;
  String? name;
  String objectName;
  int? connectionNo;
  final String type;
  int? controllerId;
  String? count;

  DeviceObjectModel({
    required this.objectId,
    this.sNo,
    this.name,
    this.connectionNo,
    required this.objectName,
    required this.type,
    this.controllerId,
    this.count,
  });

  @override
  String toString() {
    return '$objectName(name: $name, objectId: $objectId, connectionNo: $connectionNo, type: $type, controllerId: $controllerId, count: $count)';
  }

  factory DeviceObjectModel.fromJson(Map<String, dynamic> data) {
    return DeviceObjectModel(
      objectId: data['objectId'],
      sNo: data['sNo'],
      name: data['name'],
      connectionNo: data['connectionNo'],
      objectName: data['objectName'],
      type: data['type'],
      controllerId: data['controllerId'],
      count: data['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
    };
  }
}
