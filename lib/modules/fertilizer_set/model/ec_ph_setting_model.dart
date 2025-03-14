class EcPhSettingModel{
  final int objectId;
  final double sNo;
  final String name;
  int active;
  String value;

  EcPhSettingModel({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.active,
    required this.value,
  });

  factory EcPhSettingModel.fromJson(data){
    return EcPhSettingModel(
        objectId: data['objectId'],
        sNo: data['sNo'],
        name: data['name'],
        active: data['active'],
        value: data['value']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'objectId' : objectId,
      'sNo' : sNo,
      'name' : name,
      'active' : active,
      'value' : value,
    };
  }
}