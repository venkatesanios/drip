import 'package:flutter/cupertino.dart';

class ConstantSettingModel{
  final int sNo;
  final String title;
  final int widgetTypeId;
  final String dataType;
  final bool gemDisplay;
  final bool gemPayload;
  final bool ecoGemDisplay;
  final bool ecoGemPayload;
  bool? common;
  ValueNotifier<dynamic> value;


  ConstantSettingModel({
    required this.sNo,
    required this.title,
    required this.widgetTypeId,
    required this.dataType,
    required this.gemDisplay,
    required this.gemPayload,
    required this.ecoGemDisplay,
    required this.ecoGemPayload,
    required this.value,
    required this.common,
  });

  factory ConstantSettingModel.fromJson(data, oldValue){
    print('name : ${data['title']}  ${data['common']}');
    return ConstantSettingModel(
        sNo: data['sNo'],
        title: data['title'],
        widgetTypeId: data['widgetTypeId'],
        dataType: data['dataType'],
        gemDisplay: data['gemDisplay'],
        gemPayload: data['gemPayload'],
        ecoGemDisplay: data['ecoGemDisplay'],
        ecoGemPayload: data['ecoGemDisplay'],
        common: data['common'],
        value: ValueNotifier<dynamic>(oldValue != null ? oldValue['value'] : data['value'])
        // value: ValueNotifier<dynamic>(data['value'])
    );
  }

  dynamic toJson(){
    return {
      'sNo' : sNo,
      'value' : value.value,
    };
  }

}