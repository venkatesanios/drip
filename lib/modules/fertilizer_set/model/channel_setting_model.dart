class ChannelSettingModel{
  final int objectId;
  final double sNo;
  final String name;
  int active;
  String method;
  String timeValve;
  String quantityValve;

  ChannelSettingModel({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.active,
    required this.method,
    required this.timeValve,
    required this.quantityValve,
  });

  factory ChannelSettingModel.fromJson(data){
    return ChannelSettingModel(
        objectId: data['objectId'],
        sNo: data['sNo'],
        name: data['name'],
        active: data['active'] ?? 0,
        method: data['method'] ?? 'Time',
        timeValve: data['timeValve'] ?? '00:00:00',
        quantityValve: data['quantityValve'] ?? '0',
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'objectId' : objectId,
      'sNo' : sNo,
      'name' : name,
      'active' : active,
      'method' : method,
      'timeValve' : timeValve,
      'quantityValve' : quantityValve,
    };
  }
}
// Time
// Pro.time
// Quantity
// Pro.quantity
// Pro.quant per 1000L