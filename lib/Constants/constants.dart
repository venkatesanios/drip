import 'dart:convert';

import '../Screens/ConfigMaker/config_web_view.dart';

class Constants {
  static const String sNo = 'sNo';
  static const String objectId = 'objectId';
  static const String name = 'name';
  static const String connectionNo = 'connectionNo';
  static const String objectName = 'objectName';
  static const String location = 'location';
  static const String type = 'type';
  static const String pumpType = 'pumpType';
  static const String controllerId = 'controllerId';
  static const String count = 'count';
  static const String level = 'level';
  static const String pressure = 'pressure';
  static const String waterMeter = 'waterMeter';
}

dynamic payloadConversion(){
  String? dataFromSession = readFromSessionStorage('configData');
  Map<String, dynamic> data = jsonDecode(dataFromSession!);
  dynamic dataFormation = {};
  for(var globalKey in data.keys){
    if(['filterSite', 'fertilizerSite', 'waterSource', 'pump', 'moistureSensor', 'irrigationLine'].contains(globalKey)){
      dataFormation[globalKey] = [];
      for(var site in data[globalKey]){
        dynamic siteFormation = site;
        for(var siteKey in site.keys){
          if(!['objectId', 'sNo', 'name', 'objectName', 'connectionNo', 'type', 'controllerId', 'count', 'siteMode', 'pumpType'].contains(siteKey)){
            siteFormation[siteKey] = siteFormation[siteKey] is List<dynamic>
                ? (siteFormation[siteKey] as List<dynamic>).map((element) => (data['listOfGeneratedObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == element)).toList()
                : (data['listOfGeneratedObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == siteFormation[siteKey], orElse: ()=> {});
          }
        }
        dataFormation[globalKey].add(site);
      }
    }
  }
  // print('dataFormation : ${jsonEncode(dataFormation)}');
  // print('-------------------------------------------');
  return dataFormation;
}