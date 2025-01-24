import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:oro_drip_irrigation/Models/Configuration/fertigation_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/filtration_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/moisture_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/pump_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/weather_model.dart';

import '../Models/Configuration/device_model.dart';
import '../Models/Configuration/device_object_model.dart';
import '../Models/Configuration/source_model.dart';
import '../Screens/ConfigMaker/config_base_page.dart';
import '../Screens/ConfigMaker/config_web_view.dart';
import '../Screens/ConfigMaker/connection.dart';

class ConfigMakerProvider extends ChangeNotifier{
  double ratio = 1.0;
  ConfigMakerTabs selectedTab = ConfigMakerTabs.siteConfigure;
  Map<int, String> configurationTab = {
    0 : 'Source Configuration',
    1 : 'Pump Configuration',
    2 : 'Filtration Configuration',
    3 : 'Fertilization Configuration',
    4 : 'Moisture Configuration',
    5 : 'Line Configuration',
  };
  int selectedConfigurationTab = 5;
  SelectionMode selectedSelectionMode = SelectionMode.auto;
  int selectedConnectionNo = 0;
  String selectedType = '';
  int selectedCategory = 6;
  int selectedModelControllerId = 100;
  List<int> noticeableObjectId = [];
  List<double> listOfSelectedSno = [];
  double selectedSno = 0.0;
  List<DeviceModel> listOfDeviceModel = [];
  Map<String, dynamic> masterData = {
    "controllerId": 1, "deviceId": "EDEFEADE0001", "deviceName": "Oro Gem 1", "categoryId": 1, "categoryName": "Oro Gem", "modelId": 1, "modelName": "Gem", "groupId" : 1, "groupName" : "Carrot"
  };
  List<dynamic>sampleData = [
    // {
    //   "connectingObjectId" : [1, 2, 3, 4], "controllerId": 1, "deviceId": "EDEFEADE0001", "deviceName": "Oro Gem 1", "categoryId": 1, "categoryName": "Oro Gem", "modelId": 1, "modelName": "Gem", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 1, "masterId": "EDEFEADE0001", "noOfRelay": 0, "noOfLatch": 0, "noOfAnalogInput": 0, "noOfDigitalInput": 0, "noOfPulseInput": 0, "noOfMoistureInput": 0, "noOfI2CInput": 0
    // },
    {
      "connectingObjectId" : [5], "controllerId": 2, "deviceId": "EDEFEADE0002", "deviceName": "Oro Pump 1", "categoryId": 2, "categoryName": "Oro Pump", "modelId": 1, "modelName": "Oro Pump m1", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 1, "masterId": 1, "noOfRelay": 3, "noOfLatch": 0, "noOfAnalogInput": 0, "noOfDigitalInput": 0, "noOfPulseInput": 0, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 22, 24, 26, 39], "controllerId": 3, "deviceId": "EDEFEADE0003", "deviceName": "Oro Pump Plus 1", "categoryId": 2, "categoryName": "Oro Pump Plus", "modelId": 2, "modelName": "Oro Pump m2", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 1, "masterId": 1, "noOfRelay": 3, "noOfLatch": 0, "noOfAnalogInput": 5, "noOfDigitalInput": 6, "noOfPulseInput": 1, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [24, 26, 39], "controllerId": 4, "deviceId": "EDEFEADE0004", "deviceName": "Oro Level 1", "categoryId": 3, "categoryName": "Oro Level", "modelId": 1, "modelName": "Oro Level m1", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 1, "masterId": 1, "noOfRelay": 0, "noOfLatch": 0, "noOfAnalogInput": 4, "noOfDigitalInput": 4, "noOfPulseInput": 0, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 24, 26, 39], "controllerId": 5, "deviceId": "EDEFEADE0005", "deviceName": "Oro Level 2", "categoryId": 3, "categoryName": "Oro Level", "modelId": 2, "modelName": "Oro Level m2", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 1, "masterId": 1, "noOfRelay": 0, "noOfLatch": 4, "noOfAnalogInput": 4, "noOfDigitalInput": 4, "noOfPulseInput": 1, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 24, 26, 27, 28, 31, 35, 37], "controllerId": 6, "deviceId": "EDEFEADE0006", "deviceName": "Oro Smart 1", "categoryId": 5, "categoryName": "Oro Smart", "modelId": 4, "modelName": "Oro Smart m4", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 1, "masterId": 1, "noOfRelay": 8, "noOfLatch": 0, "noOfAnalogInput": 4, "noOfDigitalInput": 0, "noOfPulseInput": 0, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 30, 31, 32, 35, 37, 38, 39, 40], "controllerId": 7, "deviceId": "EDEFEADE0007", "deviceName": "Oro Smart Plus 1", "categoryId": 6, "categoryName": "Oro Smart Plus", "modelId": 3, "modelName": "Oro Smart Plus m3", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 1, "masterId": 1, "noOfRelay": 16, "noOfLatch": 0, "noOfAnalogInput": 8, "noOfDigitalInput": 5, "noOfPulseInput": 1, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 30, 31, 32, 35, 37, 38, 39, 40], "controllerId": 100, "deviceId": "EDEFEADE0100", "deviceName": "Oro Smart Plus 2", "categoryId": 6, "categoryName": "Oro Smart Plus", "modelId": 3, "modelName": "Oro Smart Plus m3", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 1, "masterId": 1, "noOfRelay": 16, "noOfLatch": 0, "noOfAnalogInput": 8, "noOfDigitalInput": 5, "noOfPulseInput": 1, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 30, 31, 32, 35, 37, 38, 39, 40], "controllerId": 99, "deviceId": "EDEFEADE0101", "deviceName": "Oro Smart Plus 3", "categoryId": 6, "categoryName": "Oro Smart Plus", "modelId": 3, "modelName": "Oro Smart Plus m3", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 1, "masterId": 1, "noOfRelay": 16, "noOfLatch": 0, "noOfAnalogInput": 8, "noOfDigitalInput": 5, "noOfPulseInput": 1, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 24, 26, 27, 28, 31, 35, 37], "controllerId": 8, "deviceId": "EDEFEADE0008", "deviceName": "Oro Rtu 1", "categoryId": 7, "categoryName": "Oro Rtu", "modelId": 5, "modelName": "Oro Rtu m5", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 0, "masterId": null, "noOfRelay": 0, "noOfLatch": 8, "noOfAnalogInput": 4, "noOfDigitalInput": 0, "noOfPulseInput": 1, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 24, 26, 27, 28, 30, 31, 32, 35, 37, 38, 39, 40], "controllerId": 9, "deviceId": "EDEFEADE0009", "deviceName": "Oro Rtu Plus 1", "categoryId": 8, "categoryName": "Oro Rtu Plus", "modelId": 2, "modelName": "Oro Rtu Plus m2", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 0, "masterId": null, "noOfRelay": 0, "noOfLatch": 8, "noOfAnalogInput": 4, "noOfDigitalInput": 1, "noOfPulseInput": 0, "noOfMoistureInput": 4, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [ 23, 25, 30, 32, 38, 39, 40], "controllerId": 10, "deviceId": "EDEFEADE0010", "deviceName": "Oro Sense 1", "categoryId": 9, "categoryName": "Oro Sense", "modelId": 1, "modelName": "Oro Sense m1", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 0, "masterId": null, "noOfRelay": 0, "noOfLatch": 0, "noOfAnalogInput": 0, "noOfDigitalInput": 1, "noOfPulseInput": 0, "noOfMoistureInput": 4, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [29, 33, 34], "controllerId": 11, "deviceId": "EDEFEADE0011", "deviceName": "Oro Sense 2", "categoryId": 9, "categoryName": "Oro Sense", "modelId": 2, "modelName": "Oro Sense m2", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 0, "masterId": null, "noOfRelay": 0, "noOfLatch": 0, "noOfAnalogInput": 0, "noOfDigitalInput": 0, "noOfPulseInput": 0, "noOfMoistureInput": 0, "noOfI2CInput": 2
    },
    {
      "connectingObjectId" : [0], "controllerId": 12, "deviceId": "EDEFEADE0012", "deviceName": "Oro Extend 1", "categoryId": 10, "categoryName": "Oro Extend", "modelId": 3, "modelName": "Oro Extend m3", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 0, "masterId": null, "noOfRelay": 0, "noOfLatch": 0, "noOfAnalogInput": 0, "noOfDigitalInput": 0, "noOfPulseInput": 0, "noOfMoistureInput": 0, "noOfI2CInput": 2
    },
    {
      "connectingObjectId" : [0], "controllerId": 13, "deviceId": "EDEFEADE0013", "deviceName": "Oro Extend 2", "categoryId": 10, "categoryName": "Oro Extend", "modelId": 3, "modelName": "Oro Extend m3", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 0, "masterId": null, "noOfRelay": 0, "noOfLatch": 0, "noOfAnalogInput": 0, "noOfDigitalInput": 0, "noOfPulseInput": 0, "noOfMoistureInput": 0, "noOfI2CInput": 0
    },
    {
      "connectingObjectId" : [25, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39], "controllerId": 14, "deviceId": "EDEFEADE0014", "deviceName": "Oro Weather 1", "categoryId": 4, "categoryName": "Oro Weather", "modelId": 1, "modelName": "Oro Weather m1", "interfaceTypeId": 1, "interfaceInterval": 5, "serialNumber": 0, "isUsedInConfig": 0, "masterId": null, "noOfRelay": 0, "noOfLatch": 0, "noOfAnalogInput": 3, "noOfDigitalInput": 4, "noOfPulseInput": 0, "noOfMoistureInput": 4, "noOfI2CInput": 4
    }
  ];
  List<dynamic> sampleObject = [
    {"objectId" : 1, "type" : "-", "objectName" : "Source"},
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
    {"objectId" : 39, "type" : "4", "objectName" : "Atm. Pressure"},
    {"objectId" : 40, "type" : "4", "objectName" : "Float"},
    {"objectId" : 41, "type" : "4", "objectName" : "Manual Button"},
  ];
  List<DeviceObjectModel> listOfSampleObjectModel = [];
  List<DeviceObjectModel> listOfObjectModelConnection = [];
  List<DeviceObjectModel> listOfGeneratedObject = [];
  List<FiltrationModel> filtration = [];
  List<FertilizationModel> fertilization = [];
  List<SourceModel> source = [];
  List<PumpModel> pump = [];
  List<MoistureModel> moisture = [];

  DeviceObjectModel mapToDeviceObject(dynamic object) {
    return DeviceObjectModel(
      objectId: object['objectId'],
      objectName: object['objectName'],
      type: object['type'],
      count: '0',
    );
  }

  Future<List<DeviceModel>> fetchData()async {
    await Future.delayed(const Duration(seconds: 0));
    try{
      String? dataFromSession = readFromSessionStorage('configData');
      if(dataFromSession != null){
        Map<String, dynamic> jsonData = jsonDecode(dataFromSession);
        listOfDeviceModel = (jsonData['listOfDeviceModel'] as List<dynamic>).map((devices) {
          return DeviceModel(
              controllerId: devices['controllerId'],
              deviceId: devices['deviceId'],
              deviceName: devices['deviceName'],
              categoryId: devices['categoryId'],
              categoryName: devices['categoryName'],
              modelId: devices['modelId'],
              modelName: devices['modelName'],
              interfaceTypeId: devices['interfaceTypeId'],
              interfaceInterval: 5,
              serialNumber: devices['serialNo'],
              masterId: devices['masterId'],
              extendDeviceId: devices['extendDeviceId'],
              noOfRelay: devices['noOfRelay'],
              noOfLatch: devices['noOfLatch'],
              noOfAnalogInput: devices['noOfAnalogInput'],
              noOfDigitalInput: devices['noOfDigitalInput'],
              noOfPulseInput: devices['noOfPulseInput'],
              noOfMoistureInput: devices['noOfMoistureInput'],
              noOfI2CInput: devices['noOfI2CInput'],
              select: false,
              connectingObjectId: (devices['connectingObjectId'] as List<dynamic>).map((e) => e as int).toList(),
          );
        }).toList();
        listOfSampleObjectModel = (jsonData['listOfSampleObjectModel'] as List<dynamic>).map((object) => DeviceObjectModel.fromJson(object)).toList();
        listOfObjectModelConnection = (jsonData['listOfObjectModelConnection'] as List<dynamic>).map((object) => DeviceObjectModel.fromJson(object)).toList();
        listOfGeneratedObject = (jsonData['listOfGeneratedObject'] as List<dynamic>).map((object) => DeviceObjectModel.fromJson(object)).toList();
        filtration = (jsonData['filtration'] as List<dynamic>).map((filtrationObject) => FiltrationModel.fromJson(filtrationObject)).toList();
        fertilization = (jsonData['fertilization'] as List<dynamic>).map((fertilizationObject) => FertilizationModel.fromJson(fertilizationObject)).toList();
        source = (jsonData['source'] as List<dynamic>).map((sourceObject) => SourceModel.fromJson(sourceObject)).toList();
        pump = (jsonData['pump'] as List<dynamic>).map((pumpObject) => PumpModel.fromJson(pumpObject)).toList();
        moisture = (jsonData['moisture'] as List<dynamic>).map((moistureObject) => MoistureModel.fromJson(moistureObject)).toList();
        selectedCategory = listOfDeviceModel[1].categoryId;
        selectedModelControllerId = listOfDeviceModel[1].controllerId;

      }else{
        listOfDeviceModel = sampleData.map((devices) {
          return DeviceModel(
              controllerId: devices['controllerId'],
              deviceId: devices['deviceId'],
              deviceName: devices['deviceName'],
              categoryId: devices['categoryId'],
              categoryName: devices['categoryName'],
              modelId: devices['modelId'],
              modelName: devices['modelName'],
              interfaceTypeId: devices['interfaceTypeId'],
              interfaceInterval: 5,
              serialNumber: devices['serialNo'],
              masterId: devices['masterId'],
              extendDeviceId: devices['extendDeviceId'],
              noOfRelay: devices['noOfRelay'],
              noOfLatch: devices['noOfLatch'],
              noOfAnalogInput: devices['noOfAnalogInput'],
              noOfDigitalInput: devices['noOfDigitalInput'],
              noOfPulseInput: devices['noOfPulseInput'],
              noOfMoistureInput: devices['noOfMoistureInput'],
              noOfI2CInput: devices['noOfI2CInput'],
              select: false,
              connectingObjectId: devices['connectingObjectId'],
          );
        }).toList();
        listOfSampleObjectModel = sampleObject.map(mapToDeviceObject).toList();
        listOfObjectModelConnection = sampleObject.map(mapToDeviceObject).toList();
      }

    }catch (e, stackTrace){
      print('Error on converting to device model :: $e');
      print('stackTrace on converting to device model :: $stackTrace');
    }
    notifyListeners();
    return listOfDeviceModel;
  }

  void updateObjectCount(int objectId, String count){
    for(var object in listOfSampleObjectModel){
      if(object.objectId == objectId){
        int oldCount = object.count == '' ? 0 : int.parse(object.count!);
        int newCount = int.parse(count);
        object.count = count;
        if(oldCount <= newCount){
          for(var start = oldCount;start < newCount;start++){
            int increment = start+1;
            String StringDecimalNo = '${object.objectId}.${increment < 100 ? '0' : ''}${increment < 10 ? '0' : ''}${start+1}';
            DeviceObjectModel deviceObjectModel = DeviceObjectModel(
              objectId: object.objectId,
              objectName: object.objectName,
              type: object.type,
              name: '${object.objectName} ${start+1}',
              sNo: double.parse(StringDecimalNo),
              controllerId: null,
              location: [],
            );
            listOfGeneratedObject.add(
                deviceObjectModel
            );
            if(deviceObjectModel.objectId == 4){
              filtration.add(
                FiltrationModel(
                    commonDetails: deviceObjectModel,
                  filters: []
                )
              );
            }else if(deviceObjectModel.objectId == 3){
              fertilization.add(
                  FertilizationModel(commonDetails: deviceObjectModel, channel: [], boosterPump: [], agitator: [], selector: [], ec: [], ph: [])
              );
            }else if(deviceObjectModel.objectId == 1){
              source.add(
                SourceModel(commonDetails: deviceObjectModel, inletPump: [], outletPump: [], valves: [])
              );
            }else if(deviceObjectModel.objectId == 5){
              pump.add(
                PumpModel(commonDetails: deviceObjectModel)
              );
            }else if(deviceObjectModel.objectId == 25){
              moisture.add(
                MoistureModel(commonDetails: deviceObjectModel, valves: [])
              );
            }
          }
        }else{
          int howManyObjectToDelete = oldCount - newCount;
          List<double> filteredList = listOfGeneratedObject
              .where((available) => (available.objectId == object.objectId))
              .map((e) => e.sNo!).toList();
          filteredList = filteredList.sublist(filteredList.length - howManyObjectToDelete, filteredList.length);
          listOfGeneratedObject.removeWhere((e) => filteredList.contains(e.sNo));
          filtration.removeWhere((e) => filteredList.contains(e.commonDetails.sNo));
          fertilization.removeWhere((e) => filteredList.contains(e.commonDetails.sNo));
          source.removeWhere((e) => filteredList.contains(e.commonDetails.sNo));
          moisture.removeWhere((e) => filteredList.contains(e.commonDetails.sNo));
        }
      }
    }
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
    for(var object in listOfGeneratedObject){
      print('generated :: ${object.toJson()}');
    }
  }

  void updateObjectConnection(DeviceObjectModel selectedConnectionObject,int newCount){
    print('selectedConnectionObject : ${selectedConnectionObject.objectName}  newCount : ${newCount}');

    // ------making connection list--------------------------------------------------------
    DeviceModel selectedDevice = listOfDeviceModel.firstWhere((device) => device.controllerId == selectedModelControllerId);
    Map<String, int> connectionTypeCountMapping = {
      '1,2': selectedDevice.noOfRelay == 0 ? selectedDevice.noOfLatch : selectedDevice.noOfRelay,
      '3': selectedDevice.noOfAnalogInput,
      '4': selectedDevice.noOfDigitalInput,
      '5': selectedDevice.noOfMoistureInput,
      '6': selectedDevice.noOfPulseInput,
      '7': selectedDevice.noOfI2CInput,
    };
    int totalConnectionCount = connectionTypeCountMapping[selectedConnectionObject.type]!;
    List<int> selectedModelDefaultConnectionList = List<int>.generate(totalConnectionCount, (index) => index + 1);


    // ------filtering object by objectId, configure & not configured----------------------
    int oldCount = ['', null].contains(selectedConnectionObject.count) ? 0 : int.parse(selectedConnectionObject.count!);
    List<DeviceObjectModel> filteredByObjectId = listOfGeneratedObject
        .where((object) => object.objectId == selectedConnectionObject.objectId)
        .toList();
    List<DeviceObjectModel> filteredByNotConfigured = filteredByObjectId.where((object) => object.controllerId == null).toList();
    List<DeviceObjectModel> filteredByConfigured = listOfGeneratedObject.where((object) => (object.controllerId == selectedDevice.controllerId && object.type == selectedConnectionObject.type)).toList();
    List<DeviceObjectModel> filteredByObjectIdToConfigured = listOfGeneratedObject.where((object) => (object.controllerId == selectedDevice.controllerId && object.type == selectedConnectionObject.type && object.objectId == selectedConnectionObject.objectId)).toList();
    for(var configuredObject in filteredByConfigured){
      if(selectedModelDefaultConnectionList.contains(configuredObject.connectionNo)){
        selectedModelDefaultConnectionList.remove(configuredObject.connectionNo);
      }
    }

    if(newCount > oldCount){   // adding
      // ------------- validate ec, ph and pressure switch for category 6----------------------------
      if(selectedDevice.categoryId == 6){
        int ph = 28;
        if(selectedConnectionObject.objectId == ph && selectedDevice.categoryId == 6){
          selectedModelDefaultConnectionList = selectedModelDefaultConnectionList.where((connectionNo) => [5,6].contains(connectionNo)).toList();
        }
        int ec = 27;
        if(selectedConnectionObject.objectId == ec && selectedDevice.categoryId == 6){
          selectedModelDefaultConnectionList = selectedModelDefaultConnectionList.where((connectionNo) => [7,8].contains(connectionNo)).toList();
        }
        int pressureSwitch = 23;
        if(selectedConnectionObject.objectId == pressureSwitch && selectedDevice.categoryId == 6){
          selectedModelDefaultConnectionList = selectedModelDefaultConnectionList.where((connectionNo) => [5].contains(connectionNo)).toList();
        }
      }
      // // ------------- validate ph, others for category 5----------------------------
      // int ph = 28;
      // if(selectedConnectionObject.objectId == ph && selectedDevice.categoryId == 5){
      //   selectedModelDefaultConnectionList = selectedModelDefaultConnectionList.where((connectionNo) => [1,2].contains(connectionNo)).toList();
      // }
      // if(selectedDevice.categoryId == 5 && selectedConnectionObject.objectId != ph){
      //   selectedModelDefaultConnectionList = selectedModelDefaultConnectionList.where((connectionNo) => ![1,2].contains(connectionNo)).toList();
      // }

      print('selectedModelDefaultConnectionList :: $selectedModelDefaultConnectionList');
      int howManyObjectSupposedToConnect = newCount - oldCount;
      for(var notConfiguredObject = 0;notConfiguredObject < howManyObjectSupposedToConnect;notConfiguredObject++){
        inner : for(var object in listOfGeneratedObject){
          if(object.sNo == filteredByNotConfigured[notConfiguredObject].sNo){
            print('object.sNo : ${object.sNo}');
            object.connectionNo = selectedModelDefaultConnectionList[notConfiguredObject];
            object.controllerId = selectedDevice.controllerId;
            break inner;
          }
        }
      }
    }else{  // removing
      int deletingCount = oldCount - newCount;
      List<DeviceObjectModel> objectToDelete = filteredByObjectIdToConfigured.sublist(filteredByObjectIdToConfigured.length - deletingCount, filteredByObjectIdToConfigured.length);
      for(var delete in objectToDelete){
        print('name : ${delete.name}, objectName : ${delete.objectName}');
      }
      for(var deletingObject in objectToDelete){
        inner : for(var object in listOfGeneratedObject){
          if(deletingObject.sNo == object.sNo){
            object.connectionNo = 0;
            object.controllerId = null;
            break inner;
          }
        }
      }
    }
    for(var connectionObject in listOfObjectModelConnection){
      if(connectionObject.objectId == selectedConnectionObject.objectId){
        connectionObject.count = newCount.toString();
      }
    }
    // for(var object in listOfGeneratedObject){
    //   print('generated :: ${object.name} , ${object.sNo}  connection :: ${object.connectionNo}  deviceId :: ${object.deviceId}');
    // }
    for(var obj in listOfSampleObjectModel){
      print('productLimit : ${obj.toJson()}');
    }
    for(var obj in listOfObjectModelConnection){
      print('connection : ${obj.toJson()}');
    }
    // for(var obj in listOfGeneratedObject){
    //   print('generated : ${obj.toJson()}');
    // }


    notifyListeners();

  }

  void noticeObjectForTemporary(List<int> listOfObjectId){
    noticeableObjectId = listOfObjectId;
    notifyListeners();
    Future.delayed(const Duration(seconds: 4),(){
      noticeableObjectId = [];
      notifyListeners();
    });
  }

  void updateConnectionListTile(){
    DeviceModel selectedDevice = listOfDeviceModel.firstWhere((device) => device.controllerId == selectedModelControllerId);
    for(var connectionObject in listOfObjectModelConnection){
      int count = 0;
      for(var object in listOfGeneratedObject){
        if(connectionObject.objectId == object.objectId && selectedDevice.controllerId == object.controllerId){
          count += 1;
        }
      }
      print('connectionObject :: ${connectionObject.objectName}  , count :: $count');
      connectionObject.count = count.toString();
    }
    notifyListeners();
  }

  void removeSingleObjectFromConfigureToConfigure(DeviceObjectModel object){
    for(var generatedObject in listOfGeneratedObject){
      if(generatedObject.sNo == object.sNo){
        generatedObject.controllerId = null;
        generatedObject.connectionNo = 0;
        break;
      }
    }
    for(var connectionObject in listOfObjectModelConnection){
      if(connectionObject.objectId == object.objectId){
        connectionObject.count = (int.parse(connectionObject.count!) - 1).toString();
      }
    }
    notifyListeners();
  }

  void updateSelectedConnectionNoAndItsType(int no, String type){
    selectedConnectionNo = no;
    selectedType = type;
    notifyListeners();
  }

  void updateListOfSelectedSno(double sNo){
    if(listOfSelectedSno.contains(sNo)){
      listOfSelectedSno.remove(sNo);
    }else{
      listOfSelectedSno.add(sNo);
    }
    notifyListeners();
  }

  void updateSelectedSno(double sNo){
    selectedSno = selectedSno == sNo ? 0.0 : sNo;
    notifyListeners();
  }

  void updateSelectionInFertilization(double sNo, int parameter){
    for(var fertilizerSite in fertilization){
      if(fertilizerSite.commonDetails.sNo == sNo){
        if(parameter == 1){
          fertilizerSite.channel.clear();
          fertilizerSite.channel.addAll(listOfSelectedSno);
        }else if(parameter == 2){
          fertilizerSite.boosterPump.clear();
          fertilizerSite.boosterPump.addAll(listOfSelectedSno);
        }else if(parameter == 3){
          fertilizerSite.agitator.clear();
          fertilizerSite.agitator.addAll(listOfSelectedSno);
        }else if(parameter == 4){
          fertilizerSite.selector.clear();
          fertilizerSite.selector.addAll(listOfSelectedSno);
        }else if(parameter == 5){
          fertilizerSite.ec.clear();
          fertilizerSite.ec.addAll(listOfSelectedSno);
        }else{
          fertilizerSite.ph.clear();
          fertilizerSite.ph.addAll(listOfSelectedSno);
        }
        listOfSelectedSno.clear();
      }
    }

  }

  void updateSelectionInMoisture(double sNo){
    for(var moistureSensor in moisture){
      if(moistureSensor.commonDetails.sNo == sNo){
        moistureSensor.valves.clear();
        moistureSensor.valves.addAll(listOfSelectedSno);
        listOfSelectedSno.clear();
      }
    }
    notifyListeners();
  }

}