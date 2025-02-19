import 'dart:convert';
import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/product_limit.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/site_configure.dart';
import 'package:oro_drip_irrigation/utils/environment.dart';
import 'package:provider/provider.dart';
import '../../Constants/properties.dart';
import '../../Models/Configuration/device_model.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../Models/Configuration/fertigation_model.dart';
import '../../Models/Configuration/filtration_model.dart';
import '../../Models/Configuration/irrigationLine_model.dart';
import '../../Models/Configuration/moisture_model.dart';
import '../../Models/Configuration/pump_model.dart';
import '../../Models/Configuration/source_model.dart';
import '../../StateManagement/config_maker_provider.dart';
import '../../Widgets/custom_buttons.dart';
import '../../Widgets/custom_side_tab.dart';
import '../../Widgets/title_with_back_button.dart';
import '../../services/http_service.dart';
import 'config_base_page.dart';
import 'config_mobile_view.dart';
import 'connection.dart';
import 'device_list.dart';
import 'package:oro_drip_irrigation/Constants/mqtt_manager_mobile.dart' if (dart.library.html) 'package:oro_drip_irrigation/Constants/mqtt_manager_web.dart';



void saveToSessionStorage(String key, String value) {
  window.sessionStorage[key] = value;
}

String? readFromSessionStorage(String key) {
  return window.sessionStorage[key];
}

void deleteFromSessionStorage(String key) {
  // window.sessionStorage.remove(key);
}

class ConfigWebView extends StatefulWidget {
  List<DeviceModel> listOfDevices;
  ConfigWebView({super.key, required this.listOfDevices});

  @override
  State<ConfigWebView> createState() => _ConfigWebViewState();
}

class _ConfigWebViewState extends State<ConfigWebView> {
  late ConfigMakerProvider configPvd;
  late Future<List<DeviceModel>> listOfDevices;
  double sideNavigationRatio = 0.15;
  double sideNavigationWidth = 220;
  double sideNavigationBreakPointWidth = 60;
  double sideNavigationTabWidth = 200;
  double sideNavigationTabBreakPointWidth = 50;
  double sideNavigationTabRatio = 0.07;
  double webBreakPoint = 1000;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Material(
      color: Theme.of(context).primaryColorDark,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleWithBackButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  title: 'Config Maker',

                  // titleWidth: screenWidth * sideNavigationTabRatio,
                  titleWidth: sideNavigationTabWidth,
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: (){
                              configPvd.clearData();
                            },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.green.shade100)
                          ),
                            icon: const Icon(Icons.cleaning_services_sharp),
                        ),
                        const SizedBox(width: 10,),
                        const Text('Click To Clear Config', style: TextStyle(color: Colors.white),)
                      ],
                    ),
                    const SizedBox(width: 50,),
                    Row(
                      children: [
                        IconButton(
                          onPressed: (){
                            sendToMqtt();
                            sendToHttp();
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.green.shade100)
                          ),
                          icon: const Icon(Icons.send),
                        ),
                        const SizedBox(width: 10,),
                        const Text('Click To Send Config', style: TextStyle(color: Colors.white),)
                      ],
                    ),
                    const SizedBox(width: 10,),
                  ],
                ),

              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                sideNavigationWidget(screenWidth, screenHeight),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xffF6F6F6),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10))
                    ),
                      child: configPvd.selectedTab == ConfigMakerTabs.deviceList
                          ? DeviceList(listOfDevices: widget.listOfDevices)
                          : configPvd.selectedTab == ConfigMakerTabs.productLimit
                          ? ProductLimit(listOfDevices: widget.listOfDevices,configPvd: configPvd,)
                          : configPvd.selectedTab == ConfigMakerTabs.connection
                          ? Connection(configPvd: configPvd,) : SiteConfigure(configPvd: configPvd)
                  ),
                )

              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendToMqtt(){
    final Map<String, dynamic> configMakerPayload = {
      "100": [
        {"101": configPvd.getDeviceListPayload()},
        {"102": configPvd.getObjectPayload()},
        {"103": configPvd.getPumpPayload()},
        {"104": configPvd.getFilterPayload()},
        {"105": configPvd.getFertilizerPayload()},
        {"106": configPvd.getFertilizerInjectorPayload()},
        {"107": configPvd.getMoisturePayload()},
        {"108": configPvd.getIrrigationLinePayload()},
      ]
    };
    MqttManager().topicToPublishAndItsMessage('${Environment.mqttWebPublishTopic}/${configPvd.masterData['deviceId']}', jsonEncode(configMakerPayload));
    print("configMakerPayload ==> ${jsonEncode(configMakerPayload)}");
    // print("getOroPumpPayload ==> ${widget.configPvd.getOroPumpPayload()}");
  }

  void sendToHttp()async{
    var listOfSampleObjectModel = configPvd.listOfSampleObjectModel.map((object){
      return object.toJson();
    }).toList();
    var listOfObjectModelConnection = configPvd.listOfObjectModelConnection.map((object){
      return object.toJson();
    }).toList();
    var listOfGeneratedObject = configPvd.listOfGeneratedObject.map((object){
      return object.toJson();
    }).toList();
    var filtration = configPvd.filtration.cast<FiltrationModel>().map((object){
      return object.toJson();
    }).toList();
    var fertilization = configPvd.fertilization.cast<FertilizationModel>().map((object){
      return object.toJson();
    }).toList();
    var source = configPvd.source.cast<SourceModel>().map((object){
      return object.toJson();
    }).toList();
    var pump = configPvd.pump.cast<PumpModel>().map((object){
      return object.toJson();
    }).toList();
    var moisture = configPvd.moisture.cast<MoistureModel>().map((object){
      return object.toJson();
    }).toList();
    var line = configPvd.line.cast<IrrigationLineModel>().map((object){
      return object.toJson();
    }).toList();

    var body = {
      "userId" : configPvd.masterData['customerId'],
      "controllerId" : configPvd.masterData['controllerId'],
      'groupId' : configPvd.masterData['groupId'],
      "isNewConfig" : '0',
      "productLimit" : listOfSampleObjectModel,
      "connectionCount" : listOfObjectModelConnection,
      "configObject" : listOfGeneratedObject,
      "waterSource" : source,
      "pump" : pump,
      "filterSite" : filtration,
      "fertilizerSite" : fertilization,
      "moistureSensor" : moisture,
      "irrigationLine" : line,
      "deviceList" : configPvd.listOfDeviceModel.map((device) {
        return {
          'productId' : device.productId,
          'controllerId' : device.controllerId,
          'masterId' : device.masterId,
          'referenceNumber' : configPvd.findOutReferenceNumber(device),
          'serialNumber' : device.serialNumber,
          'interfaceTypeId' : device.interfaceTypeId,
          'interfaceInterval' : device.masterId == null ? null : device.interfaceInterval,
          'extendControllerId' : device.extendControllerId,
        };
      }).toList(),
      "hardware" : {},
      "controllerReadStatus" : '0',
      "createUser" : configPvd.masterData['userId']
    };
    var response = await HttpService().postRequest('/user/configMaker/create', body);
    // print('response : ${response.body}');
    print('body : ${jsonEncode(body)}');
    print('response : ${response.body}');
  }

  Widget sideNavigationWidget(screenWidth, screenHeight){
    return SizedBox(
      width: screenWidth  > webBreakPoint ? sideNavigationWidth : sideNavigationBreakPointWidth,
      height: screenHeight,
      child: Column(
        children: [
          const SizedBox(height: 50,),
          ...getSideNavigationTab(screenWidth)

        ],
      ),
    );
  }

  List<Widget> getSideNavigationTab(screenWidth){
    return [
      for(var i in ConfigMakerTabs.values)
        if(configPvd.masterData['categoryId'] != 2 || (![ConfigMakerTabs.deviceList, ConfigMakerTabs.connection].contains(i)))
          CustomSideTab(
          width: screenWidth  > webBreakPoint ? sideNavigationTabWidth : sideNavigationTabBreakPointWidth,
          imagePath: 'assets/Images/Png/${getTabImage(i)}.png',
          title: getTabName(i),
          selected: i == configPvd.selectedTab,
          onTap: (){
            updateConfigMakerTabs(
                context: context,
                configPvd: configPvd,
                setState: setState,
                selectedTab: i
            );
          },
        )
    ];
  }

  String getTabImage(ConfigMakerTabs configMakerTabs) {
    switch (configMakerTabs) {
      case ConfigMakerTabs.deviceList:
        return 'device_list';
      case ConfigMakerTabs.productLimit:
        return 'product_limit';
      case ConfigMakerTabs.connection:
        return 'connection';
      case ConfigMakerTabs.siteConfigure:
        return 'site_configure';
      default:
        throw ArgumentError('Invalid ConfigMakerTabs value: $configMakerTabs');
    }
  }
}
