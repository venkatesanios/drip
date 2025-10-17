
class PhModel{
  double sNo;
  String name;
  int phControllerId;

  PhModel({
    required this.sNo,
    required this.name,
    this.phControllerId = 0,
  });

  factory PhModel.fromJson(dynamic data){
    return PhModel(
        sNo: data['sNo'],
        name: data['name'],
        phControllerId: data['phControllerId']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'sNo' : sNo,
      'name' : name,
      'phControllerId' : phControllerId,
    };
  }

}