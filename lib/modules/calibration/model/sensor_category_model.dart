
import 'calibration_object_model.dart';

class SensorCategoryModel {
  final int objectTypeId;
  final String object;
  List<CalibrationObjectModel> calibrationObject;
  SensorCategoryModel({
    required this.objectTypeId,
    required this.object,
    required this.calibrationObject,
  });

  factory SensorCategoryModel.fromJson(data){
    return SensorCategoryModel(
        objectTypeId: data['objectTypeId'],
        object: data['object'],
        calibrationObject: (data['objectList'] as List<dynamic>).map((element){
          return CalibrationObjectModel.fromJson(element);
        }).toList()
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "objectTypeId" : objectTypeId,
      "object" : object,
      "objectList" : calibrationObject.map((object) => object.toJson()).toList()
    };
  }
}
