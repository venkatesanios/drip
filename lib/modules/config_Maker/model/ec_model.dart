
class EcModel{
  double sNo;
  String name;
  int ecControllerId;

  EcModel({
    required this.sNo,
    required this.name,
    this.ecControllerId = 0,
  });

  factory EcModel.fromJson(dynamic data){
    return EcModel(
        sNo: data['sNo'],
        name: data['name'],
        ecControllerId: data['ecControllerId']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'sNo' : sNo,
      'name' : name,
      'ecControllerId' : ecControllerId,
    };
  }

}