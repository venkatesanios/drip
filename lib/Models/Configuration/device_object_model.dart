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

  factory DeviceObjectModel.fromJson(data){
    print('data :: ${data}');
    return DeviceObjectModel(
        objectId : data['objectId'],
        sNo : data['sNo'],
        name : data['name'],
        connectionNo : data['connectionNo'] ?? 0,
        objectName : data['objectName'],
        type : data['type'],
        controllerId : data['controllerId'],
        count: data['count']
    );
  }

  dynamic toJson(){
    return {
      'objectId' : objectId,
      'sNo' : sNo,
      'name' : name,
      'connectionNo' : connectionNo,
      'objectName' : objectName,
      'type' : type,
      'controllerId' : controllerId,
      'count' : count
    };
  }
}