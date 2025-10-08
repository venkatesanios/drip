import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:oro_drip_irrigation/modules/config_Maker/repository/config_maker_repository.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';
import '../model/device_model.dart';
import '../model/device_object_model.dart';
import '../model/fertigation_model.dart';
import '../model/filtration_model.dart';
import '../model/irrigationLine_model.dart';
import '../model/moisture_model.dart';
import '../model/pump_model.dart';
import '../model/source_model.dart';
import '../view/config_base_page.dart';
import '../view/config_web_view.dart';
import '../view/connection.dart';

class ConfigMakerProvider extends ChangeNotifier{
  double ratio = 1.0;
  ConfigMakerTabs selectedTab = ConfigMakerTabs.deviceList;
  Map<String, dynamic> configMakerDataFromHttp = {};
  Map<String, dynamic> defaultDataFromHttp = {};
  Map<int, String> configurationTab = {
    0 : 'Source Configuration',
    1 : 'Pump Configuration',
    2 : 'Filtration Configuration',
    3 : 'Fertilization Configuration',
    4 : 'Moisture Configuration',
    5 : 'Line Configuration',
  };
  int selectedConfigurationTab = 0;
  int rangeStart = -1;
  int rangeEnd = -1;
  bool rangeMode = false;
  Map<int, int> configurationTabObjectId = {
    0 : AppConstants.sourceObjectId,
    1 : AppConstants.pumpObjectId,
    2 : AppConstants.filterSiteObjectId,
    3 : AppConstants.fertilizerSiteObjectId,
    4 : AppConstants.moistureObjectId,
    5 : AppConstants.irrigationLineObjectId,
  };

  SelectionMode selectedSelectionMode = SelectionMode.auto;
  int selectedConnectionNo = 0;
  String selectedType = '';
  int selectedCategory = 6;
  int selectedModelControllerId = 0;
  double selectedLineSno = 2.001;
  List<int> noticeableObjectId = [];
  List<double> listOfSelectedSno = [];
  double selectedSno = 0.0;
  List<DeviceModel> listOfDeviceModel = [];
  int serialNumber = 0;
  Map<String, dynamic> masterData = {};
  List<DeviceObjectModel> listOfSampleObjectModel = [];
  List<DeviceObjectModel> listOfObjectModelConnection = [];
  List<DeviceObjectModel> listOfGeneratedObject = [];
  List<FiltrationModel> filtration = [];
  List<FertilizationModel> fertilization = [];
  List<SourceModel> source = [];
  List<PumpModel> pump = [];
  List<MoistureModel> moisture = [];
  List<IrrigationLineModel> line = [];
  List<dynamic> productStock = [];

  void updateRangeMode(bool value){
    rangeMode = value;
    notifyListeners();
  }

  void clearData(){
    listOfSampleObjectModel = (defaultDataFromHttp['objectType'] as List<dynamic>).map(mapToDeviceObject).toList();
    listOfObjectModelConnection = (defaultDataFromHttp['objectType'] as List<dynamic>).map(mapToDeviceObject).toList();
    print("clear called............");
    for(var i in listOfDeviceModel){
      if(AppConstants.ecoGemModelList.contains(masterData['modelId'])){
        if(i.masterId != masterData['controllerId']){
          print('clear EC25');
          i.masterId = null;
          i.serialNumber = null;
          i.extendControllerId = null;
        }
      }else if(AppConstants.gemModelList.contains(masterData['modelId'])){
        print('clear gem');
        i.masterId = null;
        i.serialNumber = null;
        i.extendControllerId = null;
      }
    }
    serialNumber = 0;
    listOfGeneratedObject.clear();
    filtration.clear();
    fertilization.clear();
    source.clear();
    pump.clear();
    moisture.clear();
    line.clear();
    selectedSelectionMode = SelectionMode.auto;
    selectedConnectionNo = 0;
    selectedType = '';
    selectedCategory = 6;
    selectedModelControllerId = 0;
    selectedLineSno = 2.001;
    noticeableObjectId = [];
    listOfSelectedSno = [];
    selectedSno = 0.0;
    serialNumber = 0;
    notifyListeners();
  }

  void reInitialize(){
    listOfSampleObjectModel.clear();
    listOfObjectModelConnection.clear();
    listOfDeviceModel.clear();
    serialNumber = 0;
    listOfGeneratedObject.clear();
    filtration.clear();
    fertilization.clear();
    source.clear();
    pump.clear();
    moisture.clear();
    line.clear();
    selectedSelectionMode = SelectionMode.auto;
    selectedConnectionNo = 0;
    selectedType = '';
    selectedCategory = 6;
    selectedModelControllerId = 0;
    selectedLineSno = 2.001;
    noticeableObjectId = [];
    listOfSelectedSno = [];
    selectedSno = 0.0;
    serialNumber = 0;
    notifyListeners();
  }

  void updateAssignObject({required double sNo,required int objectId, required List<double> listOfSerialNo}){
    for(var object in listOfGeneratedObject){
      if(object.objectId == objectId && listOfSerialNo.contains(object.sNo)){
        if(!object.assignObject.contains(sNo)){
          object.assignObject.add(sNo);
          print('added : ${object.toJson()}');
        }
      }else if(object.objectId == objectId && !listOfSerialNo.contains(object.sNo)) {
        object.assignObject.remove(sNo);
        print('remove : ${object.toJson()}');
      }
    }
    notifyListeners();
  }

  DeviceObjectModel mapToDeviceObject(dynamic object) {
    return DeviceObjectModel(
      objectId: object['objectTypeId'],
      objectName: object['object'],
      type: object['ioType'],
      count: '0',
      assignObject: [],
    );
  }

  void updateFloatForPump()async{
    await Future.delayed(const Duration(seconds: 0));
    for(var currentPump in pump){
      if(currentPump.automateFloatSelection == false){
        for(var mode in [1,2,3,4]){
          int objectId = AppConstants.floatObjectId;
          Map<int, String> controlBy = {
            1 : 'Top Float (Sump)',
            2 : 'Bottom Float (Sump)',
            3 : 'Top Float (Tank)',
            4 : 'Bottom Float (Tank)',
          };
          Map<int, double> sNoSelection = {
            1 : currentPump.topSumpFloat,
            2 : currentPump.bottomSumpFloat,
            3 : currentPump.topTankFloat,
            4 : currentPump.bottomTankFloat,
          };
          String objectName = '${controlBy[mode]}';
          double currentSno = sNoSelection[mode]!;
          List<double> validateFloat = [];
          List<double> topTankFloatSnoForAllSource = [];
          List<double> bottomTankFloatSnoForAllSource = [];
          List<double> topSumpFloatSnoForAllSource = [];
          List<double> bottomSumpFloatSnoForAllSource = [];
          Map<int, List<double>> validateFloatAvailableInSource = {
            1 : topSumpFloatSnoForAllSource,
            2 : bottomSumpFloatSnoForAllSource,
            3 : topTankFloatSnoForAllSource,
            4 : bottomTankFloatSnoForAllSource,
          };
          for(var src in source){
            if(src.outletPump.contains(currentPump.commonDetails.sNo)){
              // print('take outlet pump');
              // print("src : ${src.toJson()}");
              topSumpFloatSnoForAllSource.add(src.topFloatForOutletPump);
              bottomSumpFloatSnoForAllSource.add(src.bottomFloatForOutletPump);
            }else if(src.inletPump.contains(currentPump.commonDetails.sNo)){
              // print('take inlet pump');
              // print("src : ${src.toJson()}");
              topTankFloatSnoForAllSource.add(src.topFloatForInletPump);
              bottomTankFloatSnoForAllSource.add(src.bottomFloatForInletPump);
            }
          }
          // for(var pump in widget.configPvd.pump){
          //   if(pump.commonDetails.sNo != currentPump.commonDetails.sNo && ){
          //     Map<int, double> sNoSelectionForPumpFloat = {
          //       1 : pump.topSumpFloat,
          //       2 : pump.bottomSumpFloat,
          //       3 : pump.topTankFloat,
          //       4 : pump.bottomTankFloat,
          //     };
          //     validateFloat.add(sNoSelectionForPumpFloat[mode]!);
          //   }
          // }
          List<double> filteredSno =  listOfGeneratedObject.where((object) => (object.objectId == objectId && !validateFloat.contains(object.sNo) && validateFloatAvailableInSource[mode]!.contains(object.sNo))).map((object) => object.sNo!).toList();
          if(filteredSno.isNotEmpty){
            double firstValue = filteredSno[0];
            double oldValue = currentPump.topSumpFloat;
            if(mode == 1){
              currentPump.topSumpFloat = oldValue == 0.0 ? filteredSno[0] : filteredSno.contains(oldValue) ? oldValue : firstValue;
            }else if(mode == 2){
              currentPump.bottomSumpFloat = oldValue == 0.0 ? filteredSno[0] : filteredSno.contains(oldValue) ? oldValue : firstValue;
            }else if(mode == 3){
              currentPump.topTankFloat = oldValue == 0.0 ? filteredSno[0] : filteredSno.contains(oldValue) ? oldValue : firstValue;
            }else{
              currentPump.bottomTankFloat = oldValue == 0.0 ? filteredSno[0] : filteredSno.contains(oldValue) ? oldValue : firstValue;
            }
          }
        }
        currentPump.automateFloatSelection = true;
      }
    }
    notifyListeners();
  }

  List<int> getPossibleConnectingObjectId(){
    List<int> list = [];
    for(var device in listOfDeviceModel){
      if(device.masterId != null){
        list.addAll(device.connectingObjectId);
      }
    }
    return list;
  }

  Future<List<DeviceModel>> fetchData(masterDataFromSiteConfigure, bool fromDashboard)async {

    try{
      print("masterDataFromSiteConfigure : $masterDataFromSiteConfigure");
      reInitialize();
      if(!fromDashboard){
        productStock = masterDataFromSiteConfigure['productStock'];
      }
      else{
        print('get product list');
        var productListResponse = await ConfigMakerRepository().getProductStock({'userId' : masterDataFromSiteConfigure['customerId']});
        print("productListResponse : $productListResponse");
        Map<String, dynamic> productListJsonData = jsonDecode(productListResponse.body);
        productStock = productListJsonData['data'];
      }
      await Future.delayed(const Duration(seconds: 0));
      var body = {
        "userId" : masterDataFromSiteConfigure['customerId'],
        "controllerId" : masterDataFromSiteConfigure['controllerId'],
        "modelId" : masterDataFromSiteConfigure['modelId'],
        "groupId": masterDataFromSiteConfigure['groupId'],
        "categoryId" : masterDataFromSiteConfigure['categoryId']
      };
      var response = await ConfigMakerRepository().getUserConfigMaker(body);
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      print('jsonData : $jsonData');
      Map<String, dynamic> defaultData = jsonData['data']['default'];
      Map<String, dynamic> configMakerData = jsonData['data']['configMaker'];
      configMakerDataFromHttp = configMakerData;
      defaultDataFromHttp = defaultData;
      masterData = masterDataFromSiteConfigure;

      /* hardcoded for pushing master to deviceList*/
      if(![1, 2, 4].contains(masterDataFromSiteConfigure['modelId'])){
        // if([...AppConstants.pumpWithValveModelList, ...AppConstants.pumpModelList].contains(masterDataFromSiteConfigure['modelId'])){
        //   selectedTab = ConfigMakerTabs.productLimit;
        // }else{
        //   selectedTab = ConfigMakerTabs.deviceList;
        // }

        defaultData['deviceList'].add(
            {
              "controllerId": masterDataFromSiteConfigure['controllerId'],
              "productId": 0,
              "deviceId": masterDataFromSiteConfigure['deviceId'],
              "deviceName": masterDataFromSiteConfigure['deviceName'],
              "groupId": masterDataFromSiteConfigure['groupId'],
              "groupName": masterDataFromSiteConfigure['groupName'],
              "masterId": masterDataFromSiteConfigure['controllerId'],
              "categoryId": masterDataFromSiteConfigure['categoryId'],
              "categoryName": masterDataFromSiteConfigure['categoryName'],
              "modelId": masterDataFromSiteConfigure['modelId'],
              "modelName": masterDataFromSiteConfigure['modelName'],
              "referenceNumber": 1,
              "serialNumber": 1,
              "interfaceTypeId": 2,
              "interfaceType": "MQTT",
              "interfaceInterval": "5",
              "extendControllerId": null
            }
        );
      }

      List<int> senseNodeNotToAddInDeviceList = [44, 45];

      listOfDeviceModel = (defaultData['deviceList'] as List<dynamic>).where((device) => !senseNodeNotToAddInDeviceList.contains(device['modelId']))
          .map((devices) {
        print("devices['modelId'] : ${devices['modelId']}");
        Map<String, dynamic> deviceProperty = defaultData['productModel'].firstWhere((product) => devices['modelId'] == product['modelId']);
        var inputObjectId = deviceProperty['inputObjectId'] == '-' ? [] : deviceProperty['inputObjectId'].split(',').map((e) => int.parse(e.toString())).toList();
        var outputObjectId = deviceProperty['outputObjectId'] == '-' ? [] : deviceProperty['outputObjectId'].split(',').map((e) => int.parse(e.toString())).toList();
        return DeviceModel(
          productId: devices['productId'],
          controllerId: devices['controllerId'],
          deviceId: devices['deviceId'],
          deviceName: devices['deviceName'],
          categoryId: devices['categoryId'],
          categoryName: devices['categoryName'],
          modelId: devices['modelId'],
          modelDescription: devices['modelDescription'] ?? '',
          modelName: devices['modelName'],
          interfaceTypeId: devices['interfaceTypeId'],
          interfaceInterval: 5,
          serialNumber: devices['serialNumber'],
          masterId: devices['masterId'],
          extendControllerId: devices['extendControllerId'],
          noOfRelay: deviceProperty['relayOutput'] == '-' ? 0 : int.parse(deviceProperty['relayOutput']),
          noOfLatch: deviceProperty['latchOutput'] == '-' ? 0 : int.parse(deviceProperty['latchOutput']),
          noOfAnalogInput: deviceProperty['analogInput'] == '-' ? 0 : int.parse(deviceProperty['analogInput']),
          noOfDigitalInput: deviceProperty['digitalInput'] == '-' ? 0 : int.parse(deviceProperty['digitalInput']),
          noOfPulseInput: deviceProperty['pulseInput'] == '-' ? 0 : int.parse(deviceProperty['pulseInput']),
          noOfMoistureInput: deviceProperty['moistureInput'] == '-' ? 0 : int.parse(deviceProperty['moistureInput']),
          noOfI2CInput: deviceProperty['i2cInput'] == '-' ? 0 : int.parse(deviceProperty['i2cInput']),
          select: false,
          connectingObjectId: [
            ...inputObjectId,
            ...outputObjectId
          ],
        );
      }).toList();

      listOfDeviceModel.sort((a, b) {
        if(a.serialNumber == null) return 1;
        if(b.serialNumber == null) return -1;
        return a.serialNumber!.compareTo(b.serialNumber!);
      });

      for(var obj in defaultData['objectType']){
        if(configMakerData['productLimit'].isNotEmpty){
          var oldObject = (configMakerData['productLimit'] as List<dynamic>).firstWhere(
                (object) => object['objectId'] == obj['objectTypeId'],
            orElse: () => null,
          );
          if(oldObject == null){
            listOfSampleObjectModel.add(mapToDeviceObject(obj));
          }else{
            listOfSampleObjectModel.add(DeviceObjectModel.fromJson(oldObject));
          }
        }else{
          listOfSampleObjectModel.add(mapToDeviceObject(obj));
        }
        if(configMakerData['connectionCount'].isNotEmpty){
          var oldObject = (configMakerData['connectionCount'] as List<dynamic>).firstWhere(
                (object) => object['objectId'] == obj['objectTypeId'],
            orElse: () => null,
          );
          if(oldObject == null){
            listOfObjectModelConnection.add(mapToDeviceObject(obj));
          }else{
            listOfObjectModelConnection.add(DeviceObjectModel.fromJson(oldObject));
          }
        }else{
          listOfObjectModelConnection.add(mapToDeviceObject(obj));
        }
      }

      List<double> generatedSno = [];
      listOfGeneratedObject = (configMakerData['configObject'] as List<dynamic>).map((object) => DeviceObjectModel.fromJson(object)).toList();
      // remove if there any duplicates
      for(var i = listOfGeneratedObject.length - 1;i >= 0;i--){
        if(generatedSno.contains(listOfGeneratedObject[i].sNo)){
          listOfGeneratedObject.removeAt(i);
        }else{
          generatedSno.add(listOfGeneratedObject[i].sNo!);
        }
      }
      filtration = (configMakerData['filterSite'] as List<dynamic>).map((filtrationObject) => FiltrationModel.fromJson(filtrationObject)).toList();
      fertilization = (configMakerData['fertilizerSite'] as List<dynamic>).map((fertilizationObject) => FertilizationModel.fromJson(fertilizationObject)).toList();
      source = (configMakerData['waterSource'] as List<dynamic>).map((sourceObject) => SourceModel.fromJson(sourceObject)).toList();
      pump = (configMakerData['pump'] as List<dynamic>).map((pumpObject) => PumpModel.fromJson(pumpObject)).toList();
      moisture = (configMakerData['moistureSensor'] as List<dynamic>).map((moistureObject) => MoistureModel.fromJson(moistureObject)).toList();
      line = (configMakerData['irrigationLine'] as List<dynamic>).map((lineObject) => IrrigationLineModel.fromJson(lineObject)).toList();
    } catch (e, stackTrace){
      print('Error on converting to device model :: $e');
      print('stackTrace on converting to device model :: $stackTrace');
    }

    notifyListeners();
    return listOfDeviceModel;
  }

  Future<int> replaceDevice({required dynamic newDevice,required dynamic oldDevice, required int masterOrNode})async {
    try{
      var body = {
        "userId" : masterData['userId'],
        "oldControllerId" : oldDevice['controllerId'],
        "oldDeviceId" : oldDevice['deviceId'],
        "newDeviceId" : newDevice['deviceId'],
        "oldModelId" : oldDevice['modelId'],
        "newModelId" : newDevice['modelId'],
        "modifyUser" : masterData['userId']
      };
      var response = await ConfigMakerRepository().productReplace(body);
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      print("jsonData == $jsonData");
      notifyListeners();
      if(jsonData['code'] == 200){
        if(masterOrNode == 1){
          masterData = Map<String, dynamic>.from(masterData);
          masterData['deviceId'] = newDevice['deviceId'];
        }else{
          print("replacing node.......");
          for(var device in listOfDeviceModel){
            if(device.controllerId == oldDevice["controllerId"]){
              device.deviceId = newDevice["deviceId"];
            }
          }
        }
        notifyListeners();
        return 200;
      }else{
        return 400;
      }
    } catch (e, stackTrace){
      print('Error on replace deviceId :: $e');
      print('stackTrace on replace deviceId :: $stackTrace');
      return 400;
    }
  }

  void updateObjectCount(int objectId, String count){
    print('objectId : $objectId count : $count');
    for(var object in listOfSampleObjectModel){
      if(object.objectId == objectId){
        int oldCount = object.count == '' ? 0 : int.parse(object.count!);
        int newCount = int.parse(count);
        object.count = count;
        if(oldCount <= newCount){
          for(var start = oldCount;start < newCount;start++){
            int increment = start+1;
            String stringDecimalNo = '${object.objectId}.${increment < 100 ? '0' : ''}${increment < 10 ? '0' : ''}${start+1}';
            DeviceObjectModel deviceObjectModel = DeviceObjectModel(
              objectId: object.objectId,
              objectName: object.objectName,
              type: object.type,
              name: '${object.objectName} ${start+1}',
              sNo: double.parse(stringDecimalNo),
              controllerId: null,
              assignObject: [],
            );
            listOfGeneratedObject.add(
                deviceObjectModel
            );
            if(deviceObjectModel.objectId == AppConstants.filterSiteObjectId){
              filtration.add(
                  FiltrationModel(
                      commonDetails: deviceObjectModel,
                      filters: []
                  )
              );
            }else if(deviceObjectModel.objectId == AppConstants.fertilizerSiteObjectId){
              fertilization.add(
                  FertilizationModel(commonDetails: deviceObjectModel, channel: [], boosterPump: [], agitator: [], selector: [], ec: [], ph: [])
              );
            }else if(deviceObjectModel.objectId == AppConstants.sourceObjectId){
              source.add(
                  SourceModel(commonDetails: deviceObjectModel, inletPump: [], outletPump: [], valves: [])
              );
            }else if(deviceObjectModel.objectId == AppConstants.pumpObjectId){
              pump.add(
                  PumpModel(commonDetails: deviceObjectModel)
              );
            }else if(deviceObjectModel.objectId == AppConstants.moistureObjectId){
              moisture.add(
                  MoistureModel(commonDetails: deviceObjectModel, valves: [])
              );
            }else if(deviceObjectModel.objectId == AppConstants.irrigationLineObjectId){
              line.add(
                  IrrigationLineModel(
                      commonDetails: deviceObjectModel,
                      sourcePump: [],
                      irrigationPump: [],
                      valve: [],
                      mainValve: [],
                      light: [],
                      gate: [],
                      fan: [],
                      fogger: [],
                      mist: [],
                      pesticides: [],
                      heater: [],
                      screen: [],
                      vent: [],
                      moisture: [],
                      temperature: [],
                      soilTemperature: [],
                      humidity: [],
                      co2: [],
                      weatherStation: []
                  )
              );
            }
          }
        }else{
          int howManyObjectToDelete = oldCount - newCount;
          List<double> filteredList = listOfGeneratedObject
              .where((available) => (available.objectId == object.objectId))
              .map((e) => e.sNo!).toList();
          print("filteredList :::: $filteredList");
          filteredList = filteredList.sublist(filteredList.length - howManyObjectToDelete, filteredList.length);
          listOfGeneratedObject.removeWhere((e) => filteredList.contains(e.sNo));
          filtration.removeWhere((e) => filteredList.contains(e.commonDetails.sNo));
          fertilization.removeWhere((e) => filteredList.contains(e.commonDetails.sNo));
          source.removeWhere((e) => filteredList.contains(e.commonDetails.sNo));
          moisture.removeWhere((e) => filteredList.contains(e.commonDetails.sNo));
          line.removeWhere((e) => filteredList.contains(e.commonDetails.sNo));
          pump.removeWhere((e) => filteredList.contains(e.commonDetails.sNo));

          /* this process is to delete object from sites while delete operation in product limit */
          for(var pump in pump){
            pump.updateObjectIdIfDeletedInProductLimit(filteredList);
          }
          for(var filterSite in filtration){
            filterSite.updateObjectIdIfDeletedInProductLimit(filteredList);
          }
          for(var fertilizerSite in fertilization){
            fertilizerSite.updateObjectIdIfDeletedInProductLimit(filteredList);
          }
          for(var src in source){
            src.updateObjectIdIfDeletedInProductLimit(filteredList);
          }
          for(var ms in moisture){
            ms.updateObjectIdIfDeletedInProductLimit(filteredList);
          }
          for(var il in line){
            il.updateObjectIdIfDeletedInProductLimit(filteredList);
          }
          /* this process is to delete object from sites while delete operation in product limit */
        }
      }
    }
    listOfGeneratedObject.sort((a, b) => a.sNo!.compareTo(b.sNo!));
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });

    for(var object in listOfGeneratedObject){
      print('generated :: ${object.toJson()}');
    }

  }

  void updateObjectConnection(DeviceObjectModel selectedConnectionObject,int newCount){

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
    print('selectedModelDefaultConnectionList first: $selectedModelDefaultConnectionList');


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
        if(selectedConnectionObject.type == '3'){
          /* validate while analog object connection */
          int ph = AppConstants.phObjectId;
          if(selectedConnectionObject.objectId == ph && selectedDevice.modelId == 33){
            selectedModelDefaultConnectionList = selectedModelDefaultConnectionList.where((connectionNo) => [5,6].contains(connectionNo)).toList();
          }
          int ec = AppConstants.ecObjectId;
          if(selectedConnectionObject.objectId == ec && selectedDevice.modelId == 33){
            selectedModelDefaultConnectionList = selectedModelDefaultConnectionList.where((connectionNo) => [7,8].contains(connectionNo)).toList();
          }
        }else if(selectedConnectionObject.type == '4'){
          /* validate while digital object connection */
          int pressureSwitch = AppConstants.pressureSwitchObjectId;
          if(selectedConnectionObject.objectId == pressureSwitch){
            selectedModelDefaultConnectionList = selectedModelDefaultConnectionList.where((connectionNo) => [5].contains(connectionNo)).toList();
          }
        }
      }

      print('selectedModelDefaultConnectionList :: $selectedModelDefaultConnectionList');
      int howManyObjectSupposedToConnect = newCount - oldCount;
      for(var notConfiguredObject = 0;notConfiguredObject < howManyObjectSupposedToConnect;notConfiguredObject++){
        inner : for(var object in listOfGeneratedObject){
          if(object.sNo == filteredByNotConfigured[notConfiguredObject].sNo){
            object.connectionNo = selectedModelDefaultConnectionList[notConfiguredObject];
            object.controllerId = selectedDevice.controllerId;
            print('configuring object.sNo : ${object.toJson()}');
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
    // for(var obj in listOfSampleObjectModel){
    //   print('productLimit : ${obj.toJson()}');
    // }
    // for(var obj in listOfObjectModelConnection){
    //   print('connection : ${obj.toJson()}');
    // }
    // for(var obj in listOfGeneratedObject){
    //   print('generated : ${obj.toJson()}');
    // }

    notifyListeners();
  }

  void updateObjectConnectionForPowerSupply(DeviceObjectModel selectedConnectionObject, bool value){
    DeviceModel selectedDevice = listOfDeviceModel.firstWhere((device) => device.controllerId == selectedModelControllerId);
    for(var object in listOfObjectModelConnection){
      if(object.objectId == selectedConnectionObject.objectId){
        if(value == true){
          object.count = '1';
        }else{
          object.count = '0';
        }
      }
    }
    for(var object in listOfGeneratedObject){
      if(object.objectId == selectedConnectionObject.objectId){
        if(value == true){
          if(object.controllerId == null){
            object.controllerId = selectedDevice.controllerId;
            object.connectionNo = 9;
            break;
          }
          print("object ==> ${object.toJson()}");
        }
        else{
          if(object.controllerId == selectedDevice.controllerId){
            object.controllerId = null;
            object.connectionNo = null;
            break;
          }

        }
      }

    }
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

  void removeSingleObjectFromConfigureToNotConfigure(DeviceObjectModel object){
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
    print("no : $no, type : $type");
    selectedConnectionNo = no;
    selectedType = type;
    notifyListeners();
  }

  void updateListOfSelectedSnoWhenRangeMode(List<double> list,int index){
    if(rangeStart == -1){
      rangeStart = index;
      listOfSelectedSno.clear();
      listOfSelectedSno.add(list[index]);
    }else if (rangeStart != -1 && rangeEnd != -1){
      rangeStart = index;
      rangeEnd = -1;
      listOfSelectedSno.clear();
      listOfSelectedSno.add(list[index]);
    }else{
      rangeEnd = index;
      int from = rangeStart > rangeEnd ? rangeEnd : rangeStart;
      int to = rangeStart > rangeEnd ? rangeStart : rangeEnd;
      listOfSelectedSno.clear();
      for(var i = from;i <= to;i++){
        listOfSelectedSno.add(list[i]);
      }
    }
    listOfSelectedSno.sort();
    notifyListeners();
  }

  void updateListOfSelectedSno(double sNo){
    if(listOfSelectedSno.contains(sNo)){
      listOfSelectedSno.remove(sNo);
    }else{
      listOfSelectedSno.add(sNo);
    }
    listOfSelectedSno.sort();
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
          List<Injector> channelList = [];
          for(var selectedSno in listOfSelectedSno){
            if(fertilizerSite.channel.any((injector) => injector.sNo == selectedSno)){
              channelList.add(
                  Injector(
                      sNo: selectedSno,
                      level: fertilizerSite.channel.firstWhere((injector)=> injector.sNo == selectedSno).level
                  )
              );
            }else{
              channelList.add(
                  Injector(
                      sNo: selectedSno,
                      level: 0.0
                  )
              );
            }
          }

          fertilizerSite.channel.clear();
          fertilizerSite.channel.addAll(channelList);
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

  void updateSelectionInLine(double sNo, LineParameter parameter){
    listOfSelectedSno.sort();
    for(var irrigationLine in line){
      if(irrigationLine.commonDetails.sNo == sNo){
        if(parameter == LineParameter.sourcePump){
          irrigationLine.sourcePump.clear();
          irrigationLine.sourcePump.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.irrigationPump){
          irrigationLine.irrigationPump.clear();
          irrigationLine.irrigationPump.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.valve){
          irrigationLine.valve.clear();
          irrigationLine.valve.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.mainValve){
          irrigationLine.mainValve.clear();
          irrigationLine.mainValve.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.moisture){
          irrigationLine.moisture.clear();
          irrigationLine.moisture.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.light){
          irrigationLine.light.clear();
          irrigationLine.light.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.gate){
          irrigationLine.gate.clear();
          irrigationLine.gate.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.fan){
          irrigationLine.fan.clear();
          irrigationLine.fan.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.fogger){
          irrigationLine.fogger.clear();
          irrigationLine.fogger.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.mist){
          irrigationLine.mist.clear();
          irrigationLine.mist.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.mist){
          irrigationLine.mist.clear();
          irrigationLine.mist.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.pesticides){
          irrigationLine.pesticides.clear();
          irrigationLine.pesticides.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.heater){
          irrigationLine.heater.clear();
          irrigationLine.heater.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.screen){
          irrigationLine.screen.clear();
          irrigationLine.screen.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.vent){
          irrigationLine.vent.clear();
          irrigationLine.vent.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.temperature){
          irrigationLine.temperature.clear();
          irrigationLine.temperature.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.soilTemperature){
          irrigationLine.soilTemperature.clear();
          irrigationLine.soilTemperature.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.humidity){
          irrigationLine.humidity.clear();
          irrigationLine.humidity.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.co2){
          irrigationLine.co2.clear();
          irrigationLine.co2.addAll(listOfSelectedSno);
        }else if(parameter == LineParameter.waterMeter){
          irrigationLine.waterMeter = selectedSno;
        }else if(parameter == LineParameter.pressureIn){
          irrigationLine.pressureIn = selectedSno;
        }else if(parameter == LineParameter.pressureOut){
          irrigationLine.pressureOut = selectedSno;
        }else if(parameter == LineParameter.pressureSwitch){
          irrigationLine.pressureSwitch = selectedSno;
        }else if(parameter == LineParameter.powerSupply){
          irrigationLine.powerSupply = selectedSno;
        }else if(parameter == LineParameter.centralFiltration){
          irrigationLine.centralFiltration = selectedSno;
        }else if(parameter == LineParameter.centralFertilization){
          irrigationLine.centralFertilization = selectedSno;
        }else if(parameter == LineParameter.localFiltration){
          irrigationLine.localFiltration = selectedSno;
        }else if(parameter == LineParameter.localFertilization){
          irrigationLine.localFertilization = selectedSno;
        }
        selectedSno = 0.0;
        listOfSelectedSno.clear();
      }
    }
    notifyListeners();
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

  void updateName(List<DeviceObjectModel> listOfObject){
    for(var obj in listOfObject){
      for(var generatedObj in listOfGeneratedObject){
        if(obj.sNo == generatedObj.sNo){
          generatedObj.name = obj.name;
        }
      }
      for(var pump in pump) {
        if(pump.commonDetails.sNo == obj.sNo){
          pump.commonDetails.name = obj.name;
        }
      }
      for(var src in source){
        if(src.commonDetails.sNo == obj.sNo){
          src.commonDetails.name = obj.name;
        }
      }
      for(var filtration in filtration){
        if(filtration.commonDetails.sNo == obj.sNo){
          filtration.commonDetails.name = obj.name;
        }
      }
      for(var fertilization in fertilization){
        if(fertilization.commonDetails.sNo == obj.sNo){
          fertilization.commonDetails.name = obj.name;
        }
      }
      for(var line in line){
        if(line.commonDetails.sNo == obj.sNo){
          line.commonDetails.name = obj.name;
        }
      }
      for(var moisture in moisture){
        if(moisture.commonDetails.sNo == obj.sNo){
          moisture.commonDetails.name = obj.name;
        }
      }
    }
    notifyListeners();
  }

  void updateFilterMode(FiltrationModel filtrationSite, int filterIndex, int value){
    for(var site in filtration){
      if(site.commonDetails.sNo == filtrationSite.commonDetails.sNo){
        site.filters[filterIndex].filterMode = value;
      }
    }
    notifyListeners();
  }

  String serialNoOrEmpty(double sNo){
    return sNo == 0.0 ? '' : sNo.toString();
  }

  String getPumpPayload() {
    List<String> pumpPayload = [];

    for (var i = 0; i < pump.length; i++) {
      var pumpModelObject = pump[i];
      var relatedSources = source.where((e) => e.inletPump.contains(pumpModelObject.commonDetails.sNo) || e.outletPump.contains(pumpModelObject.commonDetails.sNo)).toList();
      var sumpTankLevel = relatedSources.cast<SourceModel?>().firstWhere((source) => source!.outletPump.contains(pumpModelObject.commonDetails.sNo), orElse: ()=>null);
      var topTankLevel = relatedSources.cast<SourceModel?>().firstWhere((source) => source!.inletPump.contains(pumpModelObject.commonDetails.sNo), orElse: ()=>null as SourceModel?);

      Map<String, dynamic> payload = {
        "S_No": pumpModelObject.commonDetails.sNo,
        "PumpCategory": pumpModelObject.pumpType,
        "PressureIn" : serialNoOrEmpty(pumpModelObject.pressureIn),
        "PressureOut" : serialNoOrEmpty(pumpModelObject.pressureOut),
        "WaterMeter": serialNoOrEmpty(pumpModelObject.waterMeter),
        "SumpTankLevel" : sumpTankLevel == null ? '' : serialNoOrEmpty(sumpTankLevel.level),
        "TopTankLevel" : topTankLevel == null ? '' : serialNoOrEmpty(topTankLevel.level),
        "TopTankFloatHigh" : serialNoOrEmpty(pumpModelObject.topTankFloat),
        "TopTankFloatLow" : serialNoOrEmpty(pumpModelObject.bottomTankFloat),
        "SumpTankFloatHigh" : serialNoOrEmpty(pumpModelObject.topSumpFloat),
        "SumpTankFloatLow" : serialNoOrEmpty(pumpModelObject.bottomSumpFloat),
        "IrrigationLine" : line.where((line) => (line.sourcePump.contains(pumpModelObject.commonDetails.sNo) || line.irrigationPump.contains(pumpModelObject.commonDetails.sNo))).map((line) => line.commonDetails.sNo).join('_'),
      };

      pumpPayload.add(payload.entries.map((e) => e.value).join(","));
    }

    return pumpPayload.join(";");
  }

  int? findOutReferenceNumber(DeviceModel device){
    int referenceNo = 0;
    for(var d = 0; d < listOfDeviceModel.length; d++){
      if(device.masterId != null && listOfDeviceModel[d].categoryId == device.categoryId){
        referenceNo += 1;
        if(listOfDeviceModel[d].controllerId == device.controllerId){
          break;
        }
      }
    }
    return referenceNo == 0 ? null : referenceNo;
  }

  int validateDeviceTypeNumber(DeviceModel device){
    if(AppConstants.extendLoraList.contains(device.modelId)){
      return 102;
    }else if(AppConstants.extendGsmList.contains(device.modelId)){
      return 103;
    }else{
      return device.categoryId;
    }
  }

  //Todo : getDeviceListPayload
  String getDeviceListPayload() {
    List<dynamic> devicePayload = [];
    for (var i = 0; i < listOfDeviceModel.length; i++) {
      var device = listOfDeviceModel[i];
      if (device.masterId != null) {
        devicePayload.add({
          "S_No": device.serialNumber,
          "DeviceTypeNumber": validateDeviceTypeNumber(device),
          "DeviceRunningNumber": findOutReferenceNumber(device),
          "DeviceId": device.deviceId,
          "InterfaceType": device.interfaceTypeId,
          if(AppConstants.gemModelList.contains(masterData['modelId']))
            "ExtendNode": device.extendControllerId ?? '',
          if(AppConstants.gemModelList.contains(masterData['modelId']))
            "Name" : device.deviceName
        }.entries.map((e) => e.value).join(","));
      }
    }
    return devicePayload.join(";");
  }

  String getFilterPayload() {
    List<dynamic> filterPayload = [];
    for(var i = 0;i < filtration.length;i++){
      var filterSite = filtration[i];
      filterPayload.add({
        "S_No": filterSite.commonDetails.sNo,
        "Filter": filterSite.filters.map((filter) => filter.sNo).join('_'),
        "PressureIn": serialNoOrEmpty(filterSite.pressureIn),
        "PressureOut": serialNoOrEmpty(filterSite.pressureOut),
        "IrrigationLine": line.where((irrigationLine) => [irrigationLine.centralFiltration, irrigationLine.localFiltration].contains(filterSite.commonDetails.sNo)).map((filteredLine) => filteredLine.commonDetails.sNo).toList().join('_'),
        "SiteType" : filterSite.siteMode,
        "Name" : filterSite.commonDetails.name
      }.entries.map((e) => e.value).join(","));
    }
    return filterPayload.join(";");
  }

  String getFertilizerPayload() {
    List<dynamic> fertilizerPayload = [];
    for(var i = 0;i < fertilization.length;i++){
      var fertilizer = fertilization[i];
      fertilizerPayload.add({
        "S_No": fertilizer.commonDetails.sNo,
        "FertilizerChannel": fertilizer.channel.map((injector) => injector.sNo).toList().join('_'),
        "BoosterSelection": fertilizer.boosterPump.join('_'),
        "IrrigationLine": line.where((irrigationLine) => [irrigationLine.centralFertilization, irrigationLine.localFertilization].contains(fertilizer.commonDetails.sNo)).map((filteredLine) => filteredLine.commonDetails.sNo).toList().join('_'),
        "Agitator": fertilizer.agitator.join('_'),
        "TankSelector": fertilizer.selector.join('_'),
        "SiteType" : fertilizer.siteMode,
        "Name" : fertilizer.commonDetails.name
      }.entries.map((e) => e.value).join(","));
    }
    return fertilizerPayload.join(";");
  }

  String getFertilizerInjectorPayload() {
    List<dynamic> fertilizerInjectorPayload = [];
    for(var i = 0;i < fertilization.length;i++){
      var fertilizerSite = fertilization[i];
      for(var injector = 0;injector < fertilizerSite.channel.length;injector++){
        fertilizerInjectorPayload.add({
          "S_No": fertilizerSite.channel[injector].sNo,
          "FertilizerSite": fertilizerSite.commonDetails.sNo,
          "InjectorNumber": injector + 1,
          "FertilizationMeter": '',
          "LevelSensor": '',
        }.entries.map((e) => e.value).join(","));
      }

    }
    return fertilizerInjectorPayload.join(";");
  }

  String getMoisturePayload() {
    List<dynamic> moisturePayload = [];
    for(var i = 0;i < moisture.length;i++){
      var moistureSensor = moisture[i];
      moisturePayload.add({
        "S_No": moistureSensor.commonDetails.sNo,
        "Valve": moistureSensor.valves.join('_'),
      }.entries.map((e) => e.value).join(","));
    }
    return moisturePayload.join(";");
  }

  String getObjectPayload() {
    List<dynamic> objectPayload = [];
    List<DeviceObjectModel> objectListToSend = [];
    if(AppConstants.ecoGemModelList.contains(masterData['modelId'])){
      List<DeviceObjectModel> valveList = listOfGeneratedObject.where((object) => object.objectId == AppConstants.valveObjectId).toList();
      List<DeviceObjectModel> filterList = listOfGeneratedObject.where((object) => object.objectId == AppConstants.filterObjectId).toList();
      List<DeviceObjectModel> boosterList = listOfGeneratedObject.where((object) => object.objectId == AppConstants.boosterObjectId).toList();
      List<DeviceObjectModel> channelList = listOfGeneratedObject.where((object) => object.objectId == AppConstants.channelObjectId).toList();
      List<DeviceObjectModel> moistureList = listOfGeneratedObject.where((object) => object.objectId == AppConstants.moistureObjectId).toList();
      List<DeviceObjectModel> soilTemperatureList = listOfGeneratedObject.where((object) => object.objectId == AppConstants.soilTemperatureObjectId).toList();
      objectListToSend = [
        ...valveList,
        ...filterList,
        ...boosterList,
        ...channelList,
        ...moistureList,
        ...soilTemperatureList
      ];
    }
    else{
      objectListToSend = listOfGeneratedObject;
    }
    final weatherControllersList = listOfDeviceModel.where((e) => e.categoryId == 4).toList();
    List<int> weatherControllerId = weatherControllersList.map((e) => e.controllerId).toList();
    for (var i = 0; i < objectListToSend.length; i++) {
      var object = objectListToSend[i];
      if(object.connectionNo != 0 && object.connectionNo != null && !weatherControllerId.contains(object.controllerId)){
        print(object.toJson());
        var controller = listOfDeviceModel.firstWhere((e) => e.controllerId == object.controllerId);
        List<String> objectSerialNoForEcoGemSplitList = object.sNo.toString().split('.');
        if(objectSerialNoForEcoGemSplitList[1].length == 2){
          objectSerialNoForEcoGemSplitList[1] += '0';
        }
        String objectSerialNoForEcoGem = objectSerialNoForEcoGemSplitList.join(',');
        objectPayload.add({
          "S_No": AppConstants.gemModelList.contains(masterData['modelId']) ? object.sNo : objectSerialNoForEcoGem,
          "ObjectType": object.objectId,
          "DeviceTypeNumber": controller.categoryId,
          "DeviceRunningNumber": findOutReferenceNumber(controller),
          "Output_InputNumber": object.connectionNo,
          "IO_Mode": controller.categoryId ==  4 ? 8 : getObjectTypeCodeToHardware(object.type),
          if(AppConstants.gemModelList.contains(masterData['modelId']))
            "Name" : object.name
        }.entries.map((e) => e.value).join(","));
      }
    }
    String weatherPayload = getWeatherPayload();
    if(weatherPayload.isNotEmpty){
      objectPayload.addAll(weatherPayload.split(';'));
    }
    return objectPayload.join(";");
  }

  String getWeatherPayload() {
    List<dynamic> weatherPayload = [];
    final weatherControllersList = listOfDeviceModel.where((e) => e.categoryId == 4).toList();
    for (var i = 0; i < weatherControllersList.length; i++) {
      var weather = weatherControllersList[i];
      // var irrigationLine = line.map((line) => weather.serialNumber).contains(pump.commonDetails.sNo)).toList();
      var soilMoistureSensor = listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 25).toList();
      var soilTemperatureSensor = listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 30).toList();
      var humiditySensor = listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 36).toList();
      var temperatureSensor = listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 29).toList();
      var atmosphericSensor = listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 39).toList();
      var co2Sensor = listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 33).toList();
      var ldrSensor = listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 35).toList();
      var luxSensor = listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 34).toList();
      var windDirectionSensor = listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 31).toList();
      var windSpeedSensor = listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 32).toList();
      var rainFallSensor = listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 38).toList();
      var leafWetnessSensor = listOfGeneratedObject.where((object) => object.controllerId == weather.controllerId && object.objectId == 37).toList();
      if (weather.masterId != null) {
        if(soilMoistureSensor.isNotEmpty){
          weatherPayload.add(weatherSensorPayload(weather, soilMoistureSensor[0], 1));
        }
        if(soilMoistureSensor.length > 1){
          weatherPayload.add(weatherSensorPayload(weather, soilMoistureSensor[1], 2));
        }
        if(soilMoistureSensor.length > 2){
          weatherPayload.add(weatherSensorPayload(weather, soilMoistureSensor[2], 3));
        }
        if(soilMoistureSensor.length > 3){
          weatherPayload.add(weatherSensorPayload(weather, soilMoistureSensor[3], 4));
        }
        if(soilTemperatureSensor.isNotEmpty){
          weatherPayload.add(weatherSensorPayload(weather, soilTemperatureSensor[0], 5));
        }
        if(humiditySensor.isNotEmpty){
          weatherPayload.add(weatherSensorPayload(weather, humiditySensor[0], 6));
        }
        if(temperatureSensor.isNotEmpty){
          weatherPayload.add(weatherSensorPayload(weather, temperatureSensor[0], 7));
        }
        if(atmosphericSensor.isNotEmpty){
          weatherPayload.add(weatherSensorPayload(weather, atmosphericSensor[0], 8));
        }
        if(co2Sensor.isNotEmpty){
          weatherPayload.add(weatherSensorPayload(weather, co2Sensor[0], 9));
        }
        if(ldrSensor.isNotEmpty){
          weatherPayload.add(weatherSensorPayload(weather, ldrSensor[0], 10));
        }
        if(luxSensor.isNotEmpty){
          weatherPayload.add(weatherSensorPayload(weather, luxSensor[0], 11));
        }
        if(windDirectionSensor.isNotEmpty){
          weatherPayload.add(weatherSensorPayload(weather, windDirectionSensor[0], 12));
        }
        if(windSpeedSensor.isNotEmpty){
          weatherPayload.add(weatherSensorPayload(weather, windSpeedSensor[0], 13));
        }
        if(rainFallSensor.isNotEmpty){
          weatherPayload.add(weatherSensorPayload(weather, rainFallSensor[0], 14));
        }
        if(leafWetnessSensor.isNotEmpty){
          weatherPayload.add(weatherSensorPayload(weather, leafWetnessSensor[0], 15));
        }
      }
    }
    return weatherPayload.join(";");
  }

  String weatherSensorPayload(DeviceModel weather, DeviceObjectModel sensor, int sensorId){
    return {
      "S_No": sensor.sNo,
      "ObjectType": sensor.objectId,
      "DeviceTypeNumber": weather.categoryId,
      "DeviceRunningNumber": findOutReferenceNumber(weather),
      "Output_InputNumber": sensorId,
      "IO_Mode": 8,
      "Name" : sensor.name
    }.entries.map((e) => e.value).join(",");
  }

  String getIrrigationLinePayload() {
    List<String> irrigationLinePayload = [];
    for (var i = 0; i < line.length; i++) {
      var lineModelObject = line[i];
      irrigationLinePayload.add({
        "S_No": lineModelObject.commonDetails.sNo,
        "CentralFertSite": serialNoOrEmpty(lineModelObject.centralFertilization),
        "CentralFilterSite": serialNoOrEmpty(lineModelObject.centralFiltration),
        "LocalFertSite": serialNoOrEmpty(lineModelObject.localFertilization),
        "LocalFilterSite": serialNoOrEmpty(lineModelObject.localFiltration),
        "SourcePump": lineModelObject.sourcePump.join('_'),
        "IrrigationPump": lineModelObject.irrigationPump.join('_'),
        "PressureIn": serialNoOrEmpty(lineModelObject.pressureIn),
        "PressureOut": serialNoOrEmpty(lineModelObject.pressureOut),
        "PressureSwitch": serialNoOrEmpty(lineModelObject.pressureSwitch),
        "WaterMeter": serialNoOrEmpty(lineModelObject.waterMeter),
        "Agitator" : '',
        "PowerSupplyFeedbackInput" : serialNoOrEmpty(lineModelObject.powerSupply),
        "Name" : lineModelObject.commonDetails.name
      }.entries.map((e) => e.value).toList().join(','));
    }
    return irrigationLinePayload.join(";");
  }

  int getObjectTypeCodeToHardware(String code) {
    switch(code) {
      case '1,2':
        return 1;
      case '3':
        return 2;
      case '4':
        return 3;
      case '5':
        return 7;
      case '6':
        return 4;
      case '7':
        return 6;
      default:
        return 1;
    }
  }

  List<Map<String, dynamic>> getOroPumpPayload() {
    HardwareType hardwareType = AppConstants.gemModelList.contains(masterData['modelId']) ? HardwareType.master : HardwareType.pump;
    List<Map<String, dynamic>> listOfPumpPayload = [];
    List<int> modelIdForPump1000 = [5, 6, 7];
    List<int> modelIdForPump2000 = [8, 9, 10, ...AppConstants.ecoGemModelList];
    List<DeviceModel> listOfPump1000 = listOfDeviceModel.where((device) => modelIdForPump1000.contains(device.modelId) && device.masterId != null).toList();
    List<DeviceModel> listOfPump2000 = listOfDeviceModel.where((device) => modelIdForPump2000.contains(device.modelId) && device.masterId != null).toList();
    // int pumpCodeUnderGem = 5900;
    var payloadPumpCount = 3;
    for(var p1000 in listOfPump1000){
      int pumpCount = listOfGeneratedObject.where((object) => (object.controllerId == p1000.controllerId && object.objectId == AppConstants.pumpObjectId)).length;
      List<String> findOutHowManySourceAndIrrigationPump = pump.where((pumpModel) => ((pumpModel.commonDetails.controllerId == p1000.controllerId || AppConstants.ecoGemModelList.contains(masterData['modelId'])) && pumpModel.commonDetails.objectId == AppConstants.pumpObjectId))
          .toList()
          .map((pumpModel) => pumpModel.pumpType.toString()).toList();
      int loopingLimit = payloadPumpCount - findOutHowManySourceAndIrrigationPump.length;
      for(var pump = 0;pump < loopingLimit;pump++){
        findOutHowManySourceAndIrrigationPump.add('0');
      }
      String joinPump = findOutHowManySourceAndIrrigationPump.join(',');
      var pumpPayload = {"sentSms":"pumpconfig,$pumpCount,${findOutReferenceNumber(p1000)},$joinPump,${hardwareType == HardwareType.master ? 1 : 0}"};
      int pumpConfigCode = 700;
      var gemPayload = {
        '5900' : {
          '5901' : {
            'SerialNumber' : p1000.serialNumber,
            'ReferenceNumber' : findOutReferenceNumber(p1000),
            'DeviceId' : p1000.deviceId,
            'InterfaceTypeId' : p1000.interfaceTypeId,
            'Payload' : jsonEncode({'700' : jsonEncode(pumpPayload)}),
            'SomeThing' : '4'
          }.entries.map((e) => e.value).join('+')
        }
      };
      String deviceIdToSend = hardwareType == HardwareType.master ? masterData['deviceId'] : p1000.deviceId;
      Map<String, dynamic> payloadToSend = hardwareType == HardwareType.master ? gemPayload : pumpPayload;
      listOfPumpPayload.add({
        'title' : '${p1000.deviceName}(pumpconfig)',
        'deviceId' : p1000.deviceId,
        'deviceIdToSend' : deviceIdToSend,
        'payload' : jsonEncode(payloadToSend),
        'acknowledgementState' : HardwareAcknowledgementState.notSent,
        'selected' : true,
        'checkingCode' : '$pumpConfigCode',
        'hardwareType' : HardwareType.pump
      });
    }
    for(var p2000 in listOfPump2000){
      String deviceIdToSend = p2000.interfaceTypeId == 2 ? masterData['deviceId'] : p2000.deviceId;
      int pumpCount = listOfGeneratedObject.where((object) => (object.controllerId == p2000.controllerId && object.objectId == 5)).length;

      // update pump count when eco gem
      if(AppConstants.ecoGemModelList.contains(masterData['modelId'])){
        pumpCount = listOfGeneratedObject.where((object) => object.objectId == AppConstants.pumpObjectId).length;
      }

      List<String> findOutHowManySourceAndIrrigationPump = pump.where((pumpModel) => ((pumpModel.commonDetails.controllerId == p2000.controllerId || AppConstants.ecoGemModelList.contains(masterData['modelId'])) && pumpModel.commonDetails.objectId == 5))
          .toList()
          .map((pumpModel) => pumpModel.pumpType.toString()).toList();
      int loopingLimit = payloadPumpCount - findOutHowManySourceAndIrrigationPump.length;
      for(var pump = 0;pump < loopingLimit;pump++){
        findOutHowManySourceAndIrrigationPump.add('0');
      }
      String joinPump = findOutHowManySourceAndIrrigationPump.join(',');
      var pumpPayload = {"sentSms":"pumpconfig,$pumpCount,${findOutReferenceNumber(p2000)},$joinPump,${hardwareType == HardwareType.master ? 1 : 0}"};
      int pumpConfigCode = 700;
      var gemPayload = {
        '5900' : {
          '5901' : {
            'SerialNumber' : p2000.serialNumber,
            'ReferenceNumber' : findOutReferenceNumber(p2000),
            'DeviceId' : p2000.deviceId,
            'InterfaceTypeId' : p2000.interfaceTypeId,
            'Payload' : jsonEncode({'$pumpConfigCode' : jsonEncode(pumpPayload)}),
            'SomeThing' : '4'
          }.entries.map((e) => e.value).join('+')
        }
      };
      Map<String, dynamic> payloadToSend = hardwareType == HardwareType.master ? gemPayload : pumpPayload;
      listOfPumpPayload.add({
        'title' : '${p2000.deviceName}(pumpconfig)',
        'deviceId' : p2000.deviceId,
        'deviceIdToSend' : deviceIdToSend,
        'payload' : jsonEncode(payloadToSend),
        'acknowledgementState' : HardwareAcknowledgementState.notSent,
        'selected' : true,
        'checkingCode' : '$pumpConfigCode',
        'hardwareType' : HardwareType.pump
      });
      List<DeviceObjectModel> listOfFloat = listOfGeneratedObject.where((object) => ((AppConstants.ecoGemModelList.contains(masterData['modelId']) || object.controllerId == p2000.controllerId) && object.objectId == AppConstants.floatObjectId)).toList();
      List<DeviceObjectModel> listOfPump = listOfGeneratedObject.where((object) => ((AppConstants.ecoGemModelList.contains(masterData['modelId']) || object.controllerId == p2000.controllerId) && object.objectId == AppConstants.pumpObjectId)).toList();
      List<DeviceObjectModel> listOfLevel = listOfGeneratedObject.where((object) => ((AppConstants.ecoGemModelList.contains(masterData['modelId']) || object.controllerId == p2000.controllerId) && object.objectId == AppConstants.levelObjectId)).toList();
      List<DeviceObjectModel> listOfPressure = listOfGeneratedObject.where((object) => ((AppConstants.ecoGemModelList.contains(masterData['modelId']) || object.controllerId == p2000.controllerId) && object.objectId == AppConstants.pressureSensorObjectId)).toList();
      List<DeviceObjectModel> listOfWaterMeter = listOfGeneratedObject.where((object) => ((AppConstants.ecoGemModelList.contains(masterData['modelId']) || object.controllerId == p2000.controllerId) && object.objectId == AppConstants.waterMeterObjectId)).toList();
      var listOfTankPayload = [];
      for(var p in listOfPump){
        PumpModel pumpModel = pump.firstWhere((pump) => pump.commonDetails.sNo == p.sNo);
        int tankPinCount = 0;
        int tankHighConnectionNo = 0;
        int tankLowConnectionNo = 0;
        int sumpPinCount = 0;
        int sumpHighConnectionNo = 0;
        int sumpLowConnectionNo = 0;
        int levelConnectionNo = 0;
        int availableOfWaterMeter = listOfWaterMeter.isNotEmpty ? 1 : 0;
        int availableOfPressure = listOfPressure.isNotEmpty ? 1 : 0;
        for(var float in listOfFloat){
          if(pumpModel.topSumpFloat == float.sNo){
            sumpPinCount += 1;
            sumpHighConnectionNo = float.connectionNo!;
          }
          if(pumpModel.bottomSumpFloat == float.sNo){
            sumpPinCount += 1;
            sumpLowConnectionNo = float.connectionNo!;
          }
          if(pumpModel.topTankFloat == float.sNo){
            tankPinCount += 1;
            tankHighConnectionNo = float.connectionNo!;
          }
          if(pumpModel.bottomTankFloat == float.sNo){
            tankPinCount += 1;
            tankLowConnectionNo = float.connectionNo!;
          }
        }
        for(var src in source){
          if((src.inletPump.contains(pumpModel.commonDetails.sNo) || src.outletPump.contains(pumpModel.commonDetails.sNo)) && listOfLevel.any((levelObject) => levelObject.sNo == src.level)){
            DeviceObjectModel levelObject = listOfLevel.firstWhere((levelObject) => levelObject.sNo == src.level);
            levelConnectionNo = levelObject.connectionNo!;
          }
        }
        // for(var src in source){
        //   if([...src.inletPump, ...src.outletPump].contains(p.sNo)){
        //     if(src.sourceType == 1){
        //       if(src.topFloat != 0.0 && listOfFloat.any((floatObject) => floatObject.sNo == src.topFloat)){
        //         DeviceObjectModel float = listOfFloat.firstWhere((floatObject) => floatObject.sNo == src.topFloat);
        //         tankPinCount += 1;
        //         tankHighConnectionNo = float.connectionNo!;
        //       }
        //       if(src.bottomFloat != 0.0 && listOfFloat.any((floatObject) => floatObject.sNo == src.bottomFloat)){
        //         DeviceObjectModel float = listOfFloat.firstWhere((floatObject) => floatObject.sNo == src.bottomFloat);
        //         tankPinCount += 1;
        //         tankLowConnectionNo = float.connectionNo!;
        //       }
        //       if(src.level != 0.0 && listOfLevel.any((levelObject) => levelObject.sNo == src.level)){
        //         DeviceObjectModel level = listOfLevel.firstWhere((levelObject) => levelObject.sNo == src.level);
        //         levelConnectionNo = level.connectionNo!;
        //       }
        //     }
        //     if([2, 3].contains(src.sourceType)){
        //       if(src.topFloat != 0.0 && listOfFloat.any((floatObject) => floatObject.sNo == src.topFloat)){
        //         DeviceObjectModel float = listOfFloat.firstWhere((floatObject) => floatObject.sNo == src.topFloat);
        //         sumpPinCount += 1;
        //         sumpHighConnectionNo = float.connectionNo!;
        //       }
        //       if(src.bottomFloat != 0.0 && listOfFloat.any((floatObject) => floatObject.sNo == src.bottomFloat)){
        //         DeviceObjectModel float = listOfFloat.firstWhere((floatObject) => floatObject.sNo == src.bottomFloat);
        //         sumpPinCount += 1;
        //         sumpLowConnectionNo = float.connectionNo!;
        //       }
        //       if(src.level != 0.0 && listOfLevel.any((levelObject) => levelObject.sNo == src.level)){
        //         DeviceObjectModel level = listOfLevel.firstWhere((levelObject) => levelObject.sNo == src.level);
        //         levelConnectionNo = level.connectionNo!;
        //       }
        //     }
        //   }
        // }
        listOfTankPayload.add({
          "No.of sump pins" : sumpPinCount,
          "Sump low pin float" : sumpLowConnectionNo,
          "Sump high pin float" : sumpHighConnectionNo,
          "No.of tank pins" : tankPinCount,
          "Tank low pin float" : tankLowConnectionNo,
          "Tank high pin float" : tankHighConnectionNo,
          "level sensor" : levelConnectionNo,
          "waterMeter" : availableOfWaterMeter,
          "pressureIn" : availableOfPressure
        }.entries.map((e) => e.value).join(','));
      }
      int fixedLengthOfTankPayload = 3;
      if(listOfTankPayload.length != fixedLengthOfTankPayload){
        for(var flp = 0;flp < fixedLengthOfTankPayload - listOfTankPayload.length;flp++){
          listOfTankPayload.add(List.generate(9, (index){
            return '0';
          }).join(','));
        }
      }
      var tankPayload = {"sentSms":"tankconfig,${listOfTankPayload.join(',')}"};
      int tankConfigCode = 800;
      var gemPayloadForTankConfig = {
        '5900' : {
          '5901' : {
            'SerialNumber' : p2000.serialNumber,
            'ReferenceNumber' : findOutReferenceNumber(p2000),
            'DeviceId' : p2000.deviceId,
            'InterfaceTypeId' : p2000.interfaceTypeId,
            'Payload' : jsonEncode({'$tankConfigCode' : jsonEncode(tankPayload)}),
            'SomeThing' : '4'
          }.entries.map((e) => e.value).join('+')
        }
      };
      Map<String, dynamic> payloadToSendForTankConfig = hardwareType == HardwareType.master ? gemPayloadForTankConfig : tankPayload;
      listOfPumpPayload.add({
        'title' : '${p2000.deviceName}(tankconfig)',
        'deviceIdToSend' : deviceIdToSend,
        'deviceId' : p2000.deviceId,
        'payload' : jsonEncode(payloadToSendForTankConfig),
        'acknowledgementState' : HardwareAcknowledgementState.notSent,
        'selected' : true,
        'checkingCode' : '$tankConfigCode',
        'hardwareType' : HardwareType.pump
      });
    }

    print('listOfPumpPayload :: $listOfPumpPayload');
    return listOfPumpPayload;
  }

  String formDevicePayloadIfThere(DeviceModel deviceModel){
    return {
      "S_No": deviceModel.serialNumber,
      "DeviceTypeNumber": deviceModel.categoryId,
      "DeviceRunningNumber": findOutReferenceNumber(deviceModel),
      "DeviceId": deviceModel.deviceId,
      "InterfaceType": deviceModel.interfaceTypeId,
    }.entries.map((e) => e.value).join(",");
  }

  String formDevicePayloadIfThereNot(){
    return List.generate(5, (index){
      return '0';
    }).join(',');
  }

  List<Map<String, dynamic>> getPumpWithValvePayload(){
    List<DeviceModel> listOfPumpWithValve = listOfDeviceModel.where((device) => AppConstants.pumpWithValveModelList.contains(device.modelId) && device.masterId != null).toList();
    List<Map<String, dynamic>> listOfPumpPayload = [];
    int pumpConfigCode = 50;

    for(var device in listOfPumpWithValve){
      int pumpCount = listOfGeneratedObject.where((object) => object.objectId == AppConstants.pumpObjectId).length;
      int valveCount = listOfGeneratedObject.where((object) => object.objectId == AppConstants.valveObjectId).length;
      int lightCount = listOfGeneratedObject.where((object) => object.objectId == AppConstants.lightObjectId).length;
      int pressureSensorCount = listOfGeneratedObject.where((object) => object.objectId == AppConstants.pressureSensorObjectId).length;
      int pressureSwitchCount = listOfGeneratedObject.where((object) => object.objectId == AppConstants.pressureSwitchObjectId).length;
      int moistureCount = listOfGeneratedObject.where((object) => object.objectId == AppConstants.moistureObjectId).length;
      int soilTemperatureCount = listOfGeneratedObject.where((object) => object.objectId == AppConstants.soilTemperatureObjectId).length;
      List<DeviceModel> nodeForMoisture = listOfDeviceModel.where((device) => AppConstants.senseModelList.contains(device.modelId))
          .where((device) => device.masterId != null).toList();
      var payload = {
        "sentSms":"ecoconfig,"
            "$pumpCount,"
            "$valveCount,"
            "$lightCount,"
            "$pressureSensorCount,"
            "$pressureSwitchCount,"
            "$moistureCount,"
            "$soilTemperatureCount,"
            "${nodeForMoisture.isNotEmpty ? formDevicePayloadIfThere(nodeForMoisture[0]) : formDevicePayloadIfThereNot()}"};

      listOfPumpPayload.add({
        'title' : '${device.deviceName}(pump and valve)',
        'deviceIdToSend' : device.deviceId,
        'deviceId' : device.deviceId,
        'payload' : jsonEncode(payload),
        'acknowledgementState' : HardwareAcknowledgementState.notSent,
        'selected' : true,
        'checkingCode' : '$pumpConfigCode',
        'hardwareType' : HardwareType.pumpWithValve
      });
    }
    return listOfPumpPayload;
  }

}