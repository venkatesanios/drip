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

  static dynamic payloadConversion(data) {
    // List<dynamic> configObject = List<dynamic>.from(data["configObject"]);
    List<dynamic> configObject = List<dynamic>.from(data["configObject"]);

    dynamic dataFormation = {};
    for(var globalKey in data.keys) {
      if(['filterSite', 'fertilizerSite', 'waterSource', 'pump', 'moistureSensor', 'irrigationLine'].contains(globalKey)){
        dataFormation[globalKey] = [];
        for(var site in data[globalKey]){
          dynamic siteFormation = site;
          for(var siteKey in site.keys){
            if(!['objectId', 'sNo', 'name', 'objectName', 'connectionNo', 'type', 'controllerId', 'count', 'siteMode', 'pumpType', 'connectedObject'].contains(siteKey)){
              siteFormation[siteKey] = siteFormation[siteKey] is List<dynamic>
                  ? (siteFormation[siteKey] as List<dynamic>).map((element) {
                if(element is double){
                  return configObject.firstWhere((object) => object['sNo'] == element);
                }else{
                  var object = configObject.firstWhere((object) => object['sNo'] == element['sNo']);
                  for(var key in element.keys){
                    if(!(object as Map<String, dynamic>).containsKey(key)){
                      object[key] = element[key];
                    }
                  }
                  return object;
                }
              }).toList()
                  : configObject.firstWhere((object) => object['sNo'] == siteFormation[siteKey], orElse: ()=> {});
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
}