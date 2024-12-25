import 'package:flutter/cupertino.dart';

import '../Models/Configuration/device_model.dart';
import '../Models/Configuration/device_object_model.dart';
import '../Screens/ConfigMaker/config_base_page.dart';

class ConfigMakerProvider extends ChangeNotifier{
  ConfigMakerTabs selectedTab = ConfigMakerTabs.productLimit;
  List<int> noticeableObjectId = [];
  List<DeviceModel> listOfDeviceModel = [];
  List<Map<String, dynamic>>sampleData = [
    {
      "connectingObjectId" : [1, 2, 3, 4], "controllerId": 1, "deviceId": "EDEFEADE0001", "deviceName": "Oro Gem 1", "categoryId": 1, "categoryName": "Oro Gem", "modelId": 1, "modelName": "Gem", "interfaceId": 1, "interval": 5, "serialNo": 0, "isUsedInConfig": 1, "masterDeviceId": "EDEFEADE0001", "noOfRelay": 0, "noOfLatch": 0, "noOfAnalogInput": 0, "noOfDigitalInput": 0, "noOfPulseInput": 0, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5], "controllerId": 2, "deviceId": "EDEFEADE0002", "deviceName": "Oro Pump 1", "categoryId": 2, "categoryName": "Oro Pump", "modelId": 1, "modelName": "Oro Pump m1", "interfaceId": 1, "interval": 5, "serialNo": 0, "isUsedInConfig": 1, "masterDeviceId": "EDEFEADE0001", "noOfRelay": 3, "noOfLatch": 0, "noOfAnalogInput": 0, "noOfDigitalInput": 0, "noOfPulseInput": 0, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 22, 24, 26, 39], "controllerId": 3, "deviceId": "EDEFEADE0003", "deviceName": "Oro Pump Plus 1", "categoryId": 2, "categoryName": "Oro Pump Plus", "modelId": 2, "modelName": "Oro Pump m2", "interfaceId": 1, "interval": 5, "serialNo": 0, "isUsedInConfig": 1, "masterDeviceId": "EDEFEADE0001", "noOfRelay": 3, "noOfLatch": 0, "noOfAnalogInput": 5, "noOfDigitalInput": 6, "noOfPulseInput": 1, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [24, 26, 39], "controllerId": 4, "deviceId": "EDEFEADE0004", "deviceName": "Oro Level 1", "categoryId": 3, "categoryName": "Oro Level", "modelId": 1, "modelName": "Oro Level m1", "interfaceId": 1, "interval": 5, "serialNo": 0, "isUsedInConfig": 1, "masterDeviceId": "EDEFEADE0001", "noOfRelay": 0, "noOfLatch": 0, "noOfAnalogInput": 4, "noOfDigitalInput": 4, "noOfPulseInput": 0, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 24, 26, 39], "controllerId": 5, "deviceId": "EDEFEADE0005", "deviceName": "Oro Level 2", "categoryId": 3, "categoryName": "Oro Level", "modelId": 2, "modelName": "Oro Level m2", "interfaceId": 1, "interval": 5, "serialNo": 0, "isUsedInConfig": 1, "masterDeviceId": "EDEFEADE0001", "noOfRelay": 0, "noOfLatch": 4, "noOfAnalogInput": 4, "noOfDigitalInput": 4, "noOfPulseInput": 1, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 24, 26, 27, 28, 31, 35, 37], "controllerId": 6, "deviceId": "EDEFEADE0006", "deviceName": "Oro Smart 1", "categoryId": 5, "categoryName": "Oro Smart", "modelId": 4, "modelName": "Oro Smart m4", "interfaceId": 1, "interval": 5, "serialNo": 0, "isUsedInConfig": 1, "masterDeviceId": "EDEFEADE0001", "noOfRelay": 8, "noOfLatch": 0, "noOfAnalogInput": 4, "noOfDigitalInput": 0, "noOfPulseInput": 0, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 30, 31, 32, 35, 37, 38, 39, 40], "controllerId": 7, "deviceId": "EDEFEADE0007", "deviceName": "Oro Smart Plus 1", "categoryId": 6, "categoryName": "Oro Smart Plus", "modelId": 3, "modelName": "Oro Smart Plus m3", "interfaceId": 1, "interval": 5, "serialNo": 0, "isUsedInConfig": 1, "masterDeviceId": "EDEFEADE0001", "noOfRelay": 16, "noOfLatch": 0, "noOfAnalogInput": 8, "noOfDigitalInput": 5, "noOfPulseInput": 1, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 24, 26, 27, 28, 31, 35, 37], "controllerId": 8, "deviceId": "EDEFEADE0008", "deviceName": "Oro Rtu 1", "categoryId": 7, "categoryName": "Oro Rtu", "modelId": 5, "modelName": "Oro Rtu m5", "interfaceId": 1, "interval": 5, "serialNo": 0, "isUsedInConfig": 0, "masterDeviceId": "", "noOfRelay": 0, "noOfLatch": 8, "noOfAnalogInput": 4, "noOfDigitalInput": 0, "noOfPulseInput": 1, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 24, 26, 27, 28, 30, 31, 32, 35, 37, 38, 39, 40], "controllerId": 9, "deviceId": "EDEFEADE0009", "deviceName": "Oro Rtu Plus 1", "categoryId": 8, "categoryName": "Oro Rtu Plus", "modelId": 2, "modelName": "Oro Rtu Plus m2", "interfaceId": 1, "interval": 5, "serialNo": 0, "isUsedInConfig": 0, "masterDeviceId": "", "noOfRelay": 0, "noOfLatch": 8, "noOfAnalogInput": 4, "noOfDigitalInput": 1, "noOfPulseInput": 0, "noOfMoistureInput": 4, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [ 23, 25, 30, 32, 38, 39, 40], "controllerId": 10, "deviceId": "EDEFEADE0010", "deviceName": "Oro Sense 1", "categoryId": 9, "categoryName": "Oro Sense", "modelId": 1, "modelName": "Oro Sense m1", "interfaceId": 1, "interval": 5, "serialNo": 0, "isUsedInConfig": 0, "masterDeviceId": "", "noOfRelay": 0, "noOfLatch": 0, "noOfAnalogInput": 0, "noOfDigitalInput": 1, "noOfPulseInput": 0, "noOfMoistureInput": 4, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [29, 33, 34], "controllerId": 11, "deviceId": "EDEFEADE0011", "deviceName": "Oro Sense 2", "categoryId": 9, "categoryName": "Oro Sense", "modelId": 2, "modelName": "Oro Sense m2", "interfaceId": 1, "interval": 5, "serialNo": 0, "isUsedInConfig": 0, "masterDeviceId": "", "noOfRelay": 0, "noOfLatch": 0, "noOfAnalogInput": 0, "noOfDigitalInput": 0, "noOfPulseInput": 0, "noOfMoistureInput": 0, "noOfI2CInput": 2
    }

  ];

  List<Map<String, dynamic>> sampleObject = [
    {"objectId" : 1, "type" : "-", "objectName" : "Tank"},
    {"objectId" : 2, "type" : "-", "objectName" : "Irrigation Line"},
    {"objectId" : 3, "type" : "-", "objectName" : "Dosing Site"},
    {"objectId" : 4, "type" : "-", "objectName" : "Filtration Site"},
    {"objectId" : 5, "type" : "1,2","objectName" : "Pump"},
    {"objectId" : 7, "type" : "1,2","objectName" : "Booster Pump"},
    {"objectId" : 8, "type" : "1,2","objectName" : "Selector"},
    {"objectId" : 9, "type" : "1,2","objectName" : "Agitator"},
    {"objectId" : 10, "type" : "1,2","objectName" : "Injector"},
    {"objectId" : 11, "type" : "1,2","objectName" : "Filter"},
    {"objectId" : 12, "type" : "1,2","objectName" : "DownStream Valve"},
    {"objectId" : 13, "type" : "1,2","objectName" : "Valve"},
    {"objectId" : 14, "type" : "1,2","objectName" : "Main Valve"},
    {"objectId" : 15, "type" : "1,2","objectName" : "Fan"},
    {"objectId" : 16, "type" : "1,2","objectName" : "Fogger"},
    {"objectId" : 17, "type" : "1,2","objectName" : "Heater"},
    {"objectId" : 18, "type" : "1,2","objectName" : "Pesticides"},
    {"objectId" : 19, "type" : "1,2","objectName" : "Light"},
    {"objectId" : 20, "type" : "1,2","objectName" : "Vent"},
    {"objectId" : 21, "type" : "1,2","objectName" : "Screen"},
    {"objectId" : 22, "type" : "6", "objectName" : "Water Meter"},
    {"objectId" : 23, "type" : "4", "objectName" : "Pressure Switch"},
    {"objectId" : 24, "type" : "3", "objectName" : "Pressure Sensor"},
    {"objectId" : 25, "type" : "5", "objectName" : "Moisture Sensor"},
    {"objectId" : 26, "type" : "3", "objectName" : "Level Sensor"},
    {"objectId" : 27, "type" : "3", "objectName" : "EC Sensor"},
    {"objectId" : 28, "type" : "3", "objectName" : "PH Sensor"},
    {"objectId" : 29, "type" : "7", "objectName" : "Temperature Sensor"},
    {"objectId" : 30, "type" : "4", "objectName" : "Soil Temperature Sensor"},
    {"objectId" : 31, "type" : "3", "objectName" : "Wind Direction Sensor"},
    {"objectId" : 32, "type" : "4", "objectName" : "Wind Speed Sensor"},
    {"objectId" : 33, "type" : "7", "objectName" : "Co2 Sensor"},
    {"objectId" : 34, "type" : "7", "objectName" : "LUX Sensor"},
    {"objectId" : 35, "type" : "3", "objectName" : "LDR Sensor"},
    {"objectId" : 36, "type" : "7", "objectName" : "Humidity Sensor"},
    {"objectId" : 37, "type" : "3", "objectName" : "Leaf Wetness Sensor"},
    {"objectId" : 38, "type" : "4", "objectName" : "Rain Fall Sensor"},
    {"objectId" : 39, "type" : "4", "objectName" : "Float"},
    {"objectId" : 40, "type" : "4", "objectName" : "Manual Button"},
  ];
  List<DeviceObjectModel> listOfSampleObjectModel = [];

  Future<List<DeviceModel>> fetchData()async {
    await Future.delayed(const Duration(seconds: 0));
    try{
      listOfDeviceModel = sampleData.map((devices) {
        return DeviceModel(
          controllerId: devices['controllerId'],
          deviceId: devices['deviceId'],
          deviceName: devices['deviceName'],
          categoryId: devices['categoryId'],
          categoryName: devices['categoryName'],
          modelId: devices['modelId'],
          modelName: devices['modelName'],
          interfaceId: devices['interfaceId'],
          interval: 5,
          serialNo: devices['serialNo'],
          isUsedInConfig: devices['isUsedInConfig'],
          masterDeviceId: devices['masterDeviceId'],
          noOfRelay: devices['noOfRelay'],
          noOfLatch: devices['noOfLatch'],
          noOfAnalogInput: devices['noOfAnalogInput'],
          noOfDigitalInput: devices['noOfDigitalInput'],
          noOfPulseInput: devices['noOfPulseInput'],
          noOfMoistureInput: devices['noOfMoistureInput'],
          noOfI2CInput: devices['noOfI2CInput'],
          select: false,
          connectingObjectId: devices['connectingObjectId']
        );
      }).toList();
      listOfSampleObjectModel = sampleObject.map((object){
        return DeviceObjectModel(
            objectId: object['objectId'],
            objectName: object['objectName'],
            type: object['type'],
          count: [1,2].contains(object['objectId']) ? '1' :  '0'
        );
      }).toList();
    }catch (e){
      print('Error on converting to device model :: $e');
    }
    return listOfDeviceModel;
  }

  void updateObjectCount(int objectId, String count){
    for(var object in listOfSampleObjectModel){
      if(object.objectId == objectId){
        object.count = count;
      }
    }
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  void noticeObjectForTemporary(List<int> listOfObjectId){
    noticeableObjectId = listOfObjectId;
    notifyListeners();
    Future.delayed(const Duration(seconds: 4),(){
      noticeableObjectId = [];
      notifyListeners();
    });
  }

}