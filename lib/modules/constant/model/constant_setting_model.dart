import 'package:flutter/cupertino.dart';

class ConstantSettingModel{
  final int sNo;
  final String title;
  final int widgetTypeId;
  final String dataType;
  final bool software;
  final bool hardware;
  bool? common;
  ValueNotifier<dynamic> value;


  ConstantSettingModel({
    required this.sNo,
    required this.title,
    required this.widgetTypeId,
    required this.dataType,
    required this.software,
    required this.hardware,
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
        software: data['software'],
        hardware: data['hardware'],
        common: data['common'],
        value: ValueNotifier<dynamic>(oldValue != null ? oldValue['value'] : data['value'])
        // value: ValueNotifier<dynamic>(data['value'])
    );
  }

  dynamic toJson(){
    return {
      'sNo' : sNo,
      // 'title' : title,
      // 'widgetTypeId' : widgetTypeId,
      // 'dataType' : dataType,
      // 'software' : software,
      // 'hardware' : hardware,
      'value' : value.value,
    };
  }

}