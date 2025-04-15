import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:oro_drip_irrigation/modules/constant/model/constant_menu_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/constant_setting_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/ec_ph_in_constant_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/normal_critical_alarm_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/object_in_constant_model.dart';
import 'package:oro_drip_irrigation/modules/constant/widget/arrow_tab.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';

import '../model/constant_setting_type_Model.dart';

class ConstantProvider extends ChangeNotifier{
  Map<String, dynamic> constantDataFromHttp = {};
  Map<String, dynamic> userData = {};
  List<dynamic> deviceList = [];
  List<dynamic> configObjectDataFromHttp = [];
  List<ConstantMenuModel> listOfConstantMenuModel = [];
  List<ConstantSettingModel> general = [];
  List<ConstantSettingModel> globalAlarm = [];
  List<NormalCriticalAlarmModel> normalCriticalAlarm = [];
  List<ObjectInConstantModel> pump = [];
  List<ObjectInConstantModel> filterSite = [];
  List<ObjectInConstantModel> filter = [];
  List<ObjectInConstantModel> mainValve = [];
  List<ObjectInConstantModel> valve = [];
  List<ObjectInConstantModel> waterMeter = [];
  List<ObjectInConstantModel> fertilizerSite = [];
  List<ObjectInConstantModel> channel = [];
  List<EcPhInConstantModel> ecPhSensor = [];
  List<ObjectInConstantModel> moisture = [];
  List<ObjectInConstantModel> level = [];
  List<ConstantSettingModel> defaultPumpSetting = [];
  List<ConstantSettingModel> defaultFilterSiteSetting = [];
  List<ConstantSettingModel> defaultFilterSetting = [];
  List<ConstantSettingModel> defaultMainValveSetting = [];
  List<ConstantSettingModel> defaultValveSetting = [];
  List<ConstantSettingModel> defaultWaterMeterSetting = [];
  List<ConstantSettingModel> defaultFertilizerSiteSetting = [];
  List<ConstantSettingModel> defaultChannelSetting = [];
  List<ConstantSettingModel> defaultEcPhSetting = [];
  List<ConstantSettingModel> defaultMoistureSetting = [];
  List<ConstantSettingModel> defaultLevelSetting = [];
  List<ConstantSettingModel> defaultNormalCriticalAlarmSetting = [];
  List<PopUpItemModel> filterSiteWhileBackwash = [];
  List<PopUpItemModel> mainValveMode = [];
  List<PopUpItemModel> fertilizerSiteControlFlag = [];
  List<PopUpItemModel> fertilizerChannelMode = [];
  List<PopUpItemModel> moistureMode = [];
  List<PopUpItemModel> alarmOnStatus = [];
  List<PopUpItemModel> alarmResetAfterIrrigation = [];

  String getName(dynamic sNo){
    var name = '';
    for(var n in configObjectDataFromHttp){
      if(n['sNo'].toString() == sNo.toString()){
        name = n['name'];
      }
    }
    print("name : $name");
    return name.isEmpty ? 'Location N/A' : name;
  }


  List<PopUpItemModel> generatePopUpItemModel({
    required Map<String, dynamic> defaultData,
    required String keyName
  }){
    return (defaultData[keyName] as List<dynamic>).map((setting) {
      return PopUpItemModel.fromJson(setting);
    }).toList();
  }

  List<ConstantSettingModel> generateDefaultSetting({
        required Map<String, dynamic> defaultData,
        required String keyName
      }){
    return (defaultData[keyName] as List<dynamic>).map((setting) {
      return ConstantSettingModel.fromJson(setting, null);
    }).toList();
  }

  List<ObjectInConstantModel> generateObjectInConstantModel(
      {
        required List<dynamic> listOfObject,
        required Map<String, dynamic> defaultData,
        required Map<String, dynamic> constantOldData,
        required String keyName
      }){
    return listOfObject.map((object){
      List<dynamic> oldSetting = (constantOldData[keyName] as List<dynamic>).where((setting) => setting['sNo'] == object['sNo']).toList();
      return ObjectInConstantModel.fromJson(
          objectData: object,
          defaultSetting: defaultData[keyName] as List<dynamic>,
          oldSetting: oldSetting.isNotEmpty ? oldSetting.first['setting'] : []
      );
    }).toList();
  }

  bool checkAnySettingAvailable({
    required List<ConstantSettingModel> defaultSetting,
  }){
    return defaultSetting.any((setting) => setting.ecoGemDisplay == true);
  }

  void updateConstant({required constantData, required configMakerData, required userDataAndMasterData}){
    try{
      constantDataFromHttp = constantData['data'];
      userData = userDataAndMasterData;
      configObjectDataFromHttp = configMakerData['data']['configObject'];
      Map<String, dynamic> defaultData = constantDataFromHttp['default'];
      deviceList = defaultData['nodeList'];
      if(AppConstants.ecoGemModelList.contains(userData['modelId'])){
        deviceList.insert(1, userData);
      }
      Map<String, dynamic> constantOldData = constantDataFromHttp['constant'];
      // update constant menu
      listOfConstantMenuModel = (defaultData['constantMenu'] as List<dynamic>).map((menu){
        return ConstantMenuModel(
            dealerDefinitionId: menu['dealerDefinitionId'],
            parameter: menu['parameter'],
            arrowTabState: ValueNotifier(menu['dealerDefinitionId'] == AppConstants.generalInConstant ? ArrowTabState.onProgress : ArrowTabState.inComplete)
        );
      }).toList();

      if(AppConstants.ecoGemModelList.contains(userData['modelId'])){
        listOfConstantMenuModel = listOfConstantMenuModel.where((menuModel){
          if(menuModel.dealerDefinitionId == AppConstants.levelSensorInConstant){
            return checkAnySettingAvailable(defaultSetting: defaultLevelSetting);
          }else if(menuModel.dealerDefinitionId == AppConstants.fertilizerSiteInConstant){
            return checkAnySettingAvailable(defaultSetting: defaultFertilizerSiteSetting);
          }else if(menuModel.dealerDefinitionId == AppConstants.ecPhInConstant){
            return checkAnySettingAvailable(defaultSetting: defaultEcPhSetting);
          }else if(menuModel.dealerDefinitionId == AppConstants.mainValveInConstant){
            return checkAnySettingAvailable(defaultSetting: defaultMainValveSetting);
          }else if(menuModel.dealerDefinitionId == AppConstants.normalCriticalInConstant){
            return checkAnySettingAvailable(defaultSetting: defaultNormalCriticalAlarmSetting);
          }else{
            return true;
          }
        }).toList();
      }

      //update object
      List<dynamic> listOfPumpObject = [];
      List<dynamic> listOfFilterSiteObject = [];
      List<dynamic> listOfFilterObject = [];
      List<dynamic> listOfMainValveObject = [];
      List<dynamic> listOfValveObject = [];
      List<dynamic> listOfWaterMeterObject = [];
      List<dynamic> listOfFertilizerSiteObject = [];
      List<dynamic> listOfChannelObject = [];
      List<dynamic> listOfEcObject = [];
      List<dynamic> listOfPhObject = [];
      List<dynamic> listOfMoistureObject = [];
      List<dynamic> listOfLevelObject = [];
      List<dynamic> listOfIrrigationLineObject = [];

      for (var object in configObjectDataFromHttp) {
        if(object['objectId'] == AppConstants.pumpObjectId){
          listOfPumpObject.add(object);
        }
        else if(object['objectId'] == AppConstants.filterSiteObjectId){
          listOfFilterSiteObject.add(object);
        }
        else if(object['objectId'] == AppConstants.filterObjectId){
          listOfFilterObject.add(object);
        }else if(object['objectId'] == AppConstants.mainValveObjectId){
          listOfMainValveObject.add(object);
        }else if(object['objectId'] == AppConstants.valveObjectId){
          listOfValveObject.add(object);
        }else if(object['objectId'] == AppConstants.waterMeterObjectId){
          listOfWaterMeterObject.add(object);
        }else if(object['objectId'] == AppConstants.fertilizerSiteObjectId){
          listOfFertilizerSiteObject.add(object);
        }else if(object['objectId'] == AppConstants.channelObjectId){
          listOfChannelObject.add(object);
        }else if(object['objectId'] == AppConstants.ecObjectId){
          listOfEcObject.add(object);
        }else if(object['objectId'] == AppConstants.phObjectId){
          listOfPhObject.add(object);
        }else if(object['objectId'] == AppConstants.moistureObjectId){
          listOfMoistureObject.add(object);
        }else if(object['objectId'] == AppConstants.levelObjectId){
          listOfLevelObject.add(object);
        }else if(object['objectId'] == AppConstants.irrigationLineObjectId){
          listOfIrrigationLineObject.add(object);
        }
      }

      // update general
      general = (defaultData['general'] as List<dynamic>)
          .map((menu){
        List<dynamic> oldValue = [];
        List<dynamic> generalOldData = constantOldData['general'] as List<dynamic>;
        if(generalOldData.any((oldSetting) => oldSetting['sNo'] == menu['sNo'])){
          oldValue = generalOldData.where((oldSetting) => oldSetting['sNo'] == menu['sNo']).toList();
        }
        return ConstantSettingModel.fromJson(menu, oldValue.firstOrNull);
      }).toList();

      // update globalAlarm
      globalAlarm = (defaultData['globalAlarm'] as List<dynamic>).map((menu){
        List<dynamic> oldValue = [];
        List<dynamic> generalOldData = constantOldData['globalAlarm'] as List<dynamic>;
        if(generalOldData.any((oldSetting) => oldSetting['sNo'] == menu['sNo'])){
          oldValue = generalOldData.where((oldSetting) => oldSetting['sNo'] == menu['sNo']).toList();
        }
        return ConstantSettingModel.fromJson(menu, oldValue.firstOrNull);
      }).toList();
      if (kDebugMode) {
        print('global Alarm updated..');
      }

      // update normal and critical
      alarmOnStatus = generatePopUpItemModel(defaultData: defaultData, keyName: 'alarmOnStatus');
      alarmResetAfterIrrigation = generatePopUpItemModel(defaultData: defaultData, keyName: 'alarmResetAfterIrrigation');
      defaultNormalCriticalAlarmSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'normalCriticalAlarm');
      normalCriticalAlarm = listOfIrrigationLineObject.map((line){
        print("constantOldData['normalCriticalAlarm'] : ${constantOldData}");
        List<dynamic> lineData = (constantOldData['normalCriticalAlarm'] as List<dynamic>).where((oldLine) => oldLine['sNo'] == line['sNo']).toList();
        return NormalCriticalAlarmModel.fromJson(
            objectData: line,
            defaultSetting: defaultData['normalCriticalAlarm'],
            globalAlarm: defaultData['globalAlarm'],
            oldSetting: lineData.firstOrNull
        );
      }).toList();
      if (kDebugMode) {
        print('normalCriticalAlarm updated..');
    }



      // update level
      defaultLevelSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'levelSensor');
      level = generateObjectInConstantModel(listOfObject: listOfLevelObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'levelSensor');
      if (kDebugMode) {
        print('level updated..');
      }


      //update pump
      defaultPumpSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'pump');
      pump = generateObjectInConstantModel(listOfObject: listOfPumpObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'pump');
      if (kDebugMode) {
        print('pump updated..');
      }


      // update filterSite
      filterSiteWhileBackwash = generatePopUpItemModel(defaultData: defaultData, keyName: 'filterSiteWhileBackwash');
      defaultFilterSiteSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'filterSite');
      filterSite = generateObjectInConstantModel(listOfObject: listOfFilterSiteObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'filterSite');
      if (kDebugMode) {
        print('filterSite updated..');
      }

      // update filter
      defaultFilterSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'filter');
      filter = generateObjectInConstantModel(listOfObject: listOfFilterObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'filter');
      if (kDebugMode) {
        print('filter updated..');
      }

      //update mainValve
      mainValveMode = generatePopUpItemModel(defaultData: defaultData, keyName: 'mainValveMode');
      defaultMainValveSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'mainValve');
      mainValve = generateObjectInConstantModel(listOfObject: listOfMainValveObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'mainValve');
      if (kDebugMode) {
        print('mainValve updated..');
      }

      // update valve
      defaultValveSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'valve');
      valve = generateObjectInConstantModel(listOfObject: listOfValveObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'valve');
      if (kDebugMode) {
        print('valve updated..');
      }

      // update waterMeter
      defaultWaterMeterSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'waterMeter');
      waterMeter = generateObjectInConstantModel(listOfObject: listOfWaterMeterObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'waterMeter');
      if (kDebugMode) {
        print('waterMeter updated..');
      }

      // update fertilizerSite
      fertilizerSiteControlFlag = generatePopUpItemModel(defaultData: defaultData, keyName: 'fertilizerSiteControlFlag');
      defaultFertilizerSiteSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'fertilizerSite');
      fertilizerSite = generateObjectInConstantModel(listOfObject: listOfFertilizerSiteObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'fertilizerSite');
      if (kDebugMode) {
        print('fertilizerSite updated..');
      }

      // update channel
      fertilizerChannelMode = generatePopUpItemModel(defaultData: defaultData, keyName: 'fertilizerChannelMode');
      defaultChannelSetting = generateDefaultSetting(defaultData: defaultData, keyName: "fertilizerChannel");
      channel = generateObjectInConstantModel(listOfObject: listOfChannelObject, defaultData: defaultData, constantOldData: constantOldData, keyName: "fertilizerChannel");
      if (kDebugMode) {
        print('channel updated..');
      }

      // update ec ph
      if(listOfFertilizerSiteObject.isNotEmpty){
        // find out and filter the fertilizer site has ec or ph
        defaultEcPhSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'ecPhSensor');
        List<dynamic> fertilizerSiteWithEcPh = listOfFertilizerSiteObject.where((site){
          bool ecAvailable = listOfEcObject.any((ecSensor) => ecSensor['location'] == site['sNo']);
          bool phAvailable = listOfPhObject.any((phSensor) => phSensor['location'] == site['sNo']);
          if(ecAvailable || phAvailable){
            return true;
          }else{
            return false;
          }
        }).toList();
        ecPhSensor = fertilizerSiteWithEcPh.map((site){
          return EcPhInConstantModel.fromJson(
              objectData: site,
              defaultSetting: defaultData["ecPhSensor"],
              oldSetting: constantOldData["ecPhSensor"],
              ec: listOfEcObject.where((ecSensor) => ecSensor['location'] == site['sNo']).toList(),
              ph: listOfPhObject.where((phSensor) => phSensor['location'] == site['sNo']).toList()
          );
        }).toList();
      }
      if (kDebugMode) {
        print('ecPh updated..');
      }

      // update moisture
      moistureMode = generatePopUpItemModel(defaultData: defaultData, keyName: 'moistureMode');
      defaultMoistureSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'moistureSensor');
      moisture = generateObjectInConstantModel(listOfObject: listOfMoistureObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'moistureSensor');
      notifyListeners();
      if (kDebugMode) {
        print('moisture updated..');
      }


    }catch(e, stackTrace){
      print('Error on update constant :: $e');
      print('stackTrace on update constant :: $stackTrace');
    }

    notifyListeners();
  }

  String getDeviceDetails({required String key, required int? controllerId}){

    String value = '';
    for(var device in deviceList){
      if(controllerId != null && device['controllerId'] == controllerId){
        value = device[key];
      }
    }
    return value;
  }



  dynamic payloadValidate(value){
    if(value is bool){
      return value ? 1 : 0;
    }else if(value is String && AppConstants.ecoGemModelList.contains(userData['modelId'])){
      if(value.contains(':')){
        return value.split(':').join(',');
      }
      return value.isEmpty ? 0 : value;
    }else{
      return value;
    }
  }

  String getGeneralPayload(){
    return general.where((setting) {
      return AppConstants.gemModelList.contains(userData['modelId']) ?  setting.gemPayload : setting.ecoGemPayload;
    }).map((setting) => payloadValidate(setting.value.value)).join(',');
  }

  String getGlobalAlarmPayload(){
    return globalAlarm.where((setting) {
      return AppConstants.gemModelList.contains(userData['modelId']) ?  setting.gemPayload : setting.ecoGemPayload;
    }).map((setting) => payloadValidate(setting.value.value)).join(',');
  }

  String getObjectInConstantPayload(List<ObjectInConstantModel> object){
    return object.map((object){
      bool isGem = AppConstants.gemModelList.contains(userData['modelId']);
      var objectSno = isGem ? object.sNo : object.sNo.toString().split('.').join(',');
      return [
        objectSno,
        ...object.setting.where((setting){
          return AppConstants.gemModelList.contains(userData['modelId']) ?  setting.gemPayload : setting.ecoGemPayload;
        }).map((setting){
          return payloadValidate(setting.value.value);
        })
      ].join(',');
    }).join(';');
  }

  String getFertilizerSitePayload(){
    return List.generate(fertilizerSite.length, (siteIndex){
      return [
        fertilizerSite[siteIndex].sNo,
        ...fertilizerSite[siteIndex].setting.where((setting){
          return AppConstants.gemModelList.contains(userData['modelId']) ?  setting.gemPayload : setting.ecoGemPayload;
        }).map((setting){
          return payloadValidate(setting.value.value);
        }),
        if(ecPhSensor.isNotEmpty && ecPhSensor[siteIndex].ecPopup.isNotEmpty)
          ...ecPhSensor[siteIndex].setting[0].where((setting){
            return AppConstants.gemModelList.contains(userData['modelId']) ?  setting.gemPayload : setting.ecoGemPayload;
          }).map((setting){
            return payloadValidate(setting.value.value);
          })
        else
          ...List.generate(defaultEcPhSetting.length, (index){
            return payloadValidate(defaultEcPhSetting[index].value.value);
          }),
        if(ecPhSensor.isNotEmpty && ecPhSensor[siteIndex].phPopup.isNotEmpty)
          ...ecPhSensor[siteIndex].setting[ecPhSensor[siteIndex].ecPopup.isEmpty ? 0 : 1].where((setting){
            return AppConstants.gemModelList.contains(userData['modelId']) ?  setting.gemPayload : setting.ecoGemPayload;
          }).map((setting){
            return payloadValidate(setting.value.value);
          })
        else
          ...List.generate(defaultEcPhSetting.length, (index){
            return payloadValidate(defaultEcPhSetting[index].value.value);
          }),
      ].join(',');
    }).join(';');
  }

  String getNormalCriticalAlarm(){
    int alarmUniqueSno = 0;
    List<dynamic> payloadList = [];
    for(var line in normalCriticalAlarm){
      for(var alarmIndex = 0;alarmIndex < line.normal.length;alarmIndex++){
        alarmUniqueSno++;
        payloadList.add(
          [
            alarmUniqueSno,
            line.sNo,
            line.normal[alarmIndex].sNo,
            ...line.normal[alarmIndex].setting.where((setting){
              return ((AppConstants.gemModelList.contains(userData['modelId']) ?  setting.gemPayload : setting.ecoGemPayload) && setting.common == null);
            }).map((setting){
              return payloadValidate(setting.value.value);
            }),
            ...line.critical[alarmIndex].setting.where((setting){
              return ((AppConstants.gemModelList.contains(userData['modelId']) ?  setting.gemPayload : setting.ecoGemPayload) && setting.common == null);
            }).map((setting){
              return payloadValidate(setting.value.value);
            }),
            ...line.normal[alarmIndex].setting.where((setting){
              return ((AppConstants.gemModelList.contains(userData['modelId']) ?  setting.gemPayload : setting.ecoGemPayload) && setting.common != null);
            }).map((setting){
              return payloadValidate(setting.value.value);
            }),
            line.normal[alarmIndex].title,

          ].join(','),
        );
      }
    }
    return payloadList.join(';');
  }

  String getFilterSitePayload(){
    return filterSite.map((site){
      List<ObjectInConstantModel> filterList = filter.where((filter) {
        return filter.location == site.sNo;
      }).toList();
      String ecoGemFilterSetting =
          '${payloadValidate(filterList.isNotEmpty ? filterList[0].setting[0].value.value : '')}'
          ',${payloadValidate(filterList.length > 1 ? filterList[1].setting[0].value.value : '')}';

      bool isGem = AppConstants.gemModelList.contains(userData['modelId']);
      var siteSno = isGem ? site.sNo : site.sNo.toString().split('.').join(',');
      return [
        siteSno,
        //filter setting when gem
        if(AppConstants.gemModelList.contains(userData['modelId']))
          filterList.map((filter){
            return filter.setting.map((setting){
              return payloadValidate(setting.value.value);
            }).first;
          }).join('_'),
        //filter setting when eco gem
        if(AppConstants.ecoGemModelList.contains(userData['modelId']))
          ecoGemFilterSetting,
        ...site.setting.where((setting){
          return AppConstants.gemModelList.contains(userData['modelId']) ?  setting.gemPayload : setting.ecoGemPayload;
        }).map((setting){
          return payloadValidate(setting.value.value);
        })
      ].join(',');
    }).join(';');
  }
}