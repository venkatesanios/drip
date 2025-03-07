import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/product_limit.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/site_configure.dart';
import 'package:oro_drip_irrigation/Widgets/sized_image.dart';
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
import '../../utils/Theme/oro_theme.dart';
import '../../utils/constants.dart';
import 'config_base_page.dart';
import 'config_mobile_view.dart';
import 'connection.dart';
import 'device_list.dart';
import 'package:oro_drip_irrigation/services/mqtt_manager_mobile.dart' if (dart.library.html) 'package:oro_drip_irrigation/services/mqtt_manager_web.dart';


class ConfigWebView extends StatefulWidget {
  List<DeviceModel> listOfDevices;
  ConfigWebView({super.key, required this.listOfDevices});

  @override
  State<ConfigWebView> createState() => _ConfigWebViewState();
}

class _ConfigWebViewState extends State<ConfigWebView> {
  late ConfigMakerProvider configPvd;
  late Future<List<DeviceModel>> listOfDevices;
  double sideNavigationWidth = 220;
  double sideNavigationBreakPointWidth = 60;
  double sideNavigationTabWidth = 200;
  double sideNavigationTabBreakPointWidth = 50;
  double webBreakPoint = 1000;
  late ThemeData themeData;
  late bool themeMode;
  bool clearOnHover = false;
  bool sendOnHover = false;
  List<Map<String, dynamic>> listOfPayload = [];
  PayloadSendState payloadSendState = PayloadSendState.idle;
  MqttManager mqttManager = MqttManager();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    themeData = Theme.of(context);
    themeMode = themeData.brightness == Brightness.light;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool themeMode = themeData.brightness == Brightness.light;
    return Material(
      color: themeData.primaryColorDark.withOpacity(themeMode ? 1.0 : 0.2),
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
                  spacing:20,
                  children: [
                    InkWell(
                    onHover: (value){
                      setState(() {
                        clearOnHover = value;
                      });
                    },
                    onTap: (){
                      configPvd.clearData();
                    },
                    child:  Row(
                      spacing: 10,
                      children: [
                        CircleAvatar(
                          backgroundColor: clearOnHover ? themeData.primaryColorLight : themeData.primaryColorLight.withOpacity(0.5),
                          radius: 20,
                          child: SizedImageSmall(imagePath: '${AppConstants.svgObjectPath}clear.svg',color:  Colors.white,),
                        ),
                        const Text('Click To Clear Config', style: TextStyle(color: Colors.white),)
                      ],
                    ),
                  ),
                    InkWell(
                      onHover: (value){
                        setState(() {
                          sendOnHover = value;
                        });
                      },
                      onTap: (){
                        sendToMqtt();
                        sendToHttp();
                        },
                      child:  Row(
                        spacing: 10,
                        children: [
                          CircleAvatar(
                            backgroundColor: sendOnHover ? themeData.primaryColorLight : themeData.primaryColorLight.withOpacity(0.5),
                            radius: 20,
                            child: SizedImageSmall(imagePath: '${AppConstants.svgObjectPath}send.svg',color:  Colors.white,),
                          ),
                          const Text('Click To Send Config', style: TextStyle(color: Colors.white),)
                        ],
                      ),
                    ),
                    const SizedBox(width: 10,)
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
                    decoration: BoxDecoration(
                      color: themeData.colorScheme.background,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10))
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
    setState(() {
      listOfPayload.clear();
      listOfPayload.addAll(configPvd.getOroPumpPayload());
    });

    if([1, 2, 4].contains(configPvd.masterData['modelId'])){
      final Map<String, dynamic> configMakerPayload = {
        '100' : {
          '101' : configPvd.getDeviceListPayload(),
          '102' : configPvd.getObjectPayload(),
          '103' : configPvd.getPumpPayload(),
          '104' : configPvd.getFilterPayload(),
          '105' : configPvd.getFertilizerPayload(),
          '106' : configPvd.getFertilizerInjectorPayload(),
          '107' : configPvd.getIrrigationLinePayload(),
        }
      };
      setState(() {
        listOfPayload.insert(0,{
          'title' : '${configPvd.masterData['deviceId']}(gem config)',
          'deviceId' : configPvd.masterData['deviceId'],
          'deviceIdToSend' : configPvd.masterData['deviceId'],
          'payload' : jsonEncode(configMakerPayload),
          'acknowledgementState' : HardwareAcknowledgementSate.notSent,
          'selected' : true,
          'checkingCode' : '200'
        });
      });
    }
    // MqttManager().topicToPublishAndItsMessage('${Environment.mqttWebPublishTopic}/${configPvd.masterData['deviceId']}', jsonEncode(configMakerPayload));
    print("listOfPayload ==> $listOfPayload");
    payloadAlertBox();
  }

  void payloadAlertBox(){
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context){
          return StatefulBuilder(
              builder: (context, stateSetter){
                return AlertDialog(
                  title: const Text('Configuration Payload'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        for(var payload in listOfPayload)
                          CheckboxListTile(
                            enabled: payloadSendState == PayloadSendState.idle,
                            title: Text('${payload['title']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(payload['deviceId']),
                                payloadAcknowledgementWidget(payload['acknowledgementState'] as HardwareAcknowledgementSate),
                              ],
                            ),
                            value: payload['selected'],
                            onChanged: (value){
                              stateSetter((){
                                setState(() {
                                  payload['selected'] = value;
                                });
                              });
                            },
                          )
                      ],
                    ),
                  ),
                  actions: [
                    if(payloadSendState == PayloadSendState.start)
                      CustomMaterialButton(
                        outlined: true,
                        title: 'Cancel',
                        onPressed: (){
                          stateSetter((){
                            setState(() {
                              payloadSendState = PayloadSendState.idle;
                            });
                            Navigator.pop(context);
                          });
                        },
                      ),
                    if(payloadSendState == PayloadSendState.idle)
                      CustomMaterialButton(
                        onPressed: ()async{
                          for(var payload in listOfPayload){
                            if(!payload['selected']){
                              continue;
                            }
                            bool mqttAttempt = true;
                            for(var sec = 0;sec < 5;sec++){
                              if(mqttManager.connectionState == MqttConnectionState.connected && mqttAttempt == true){
                                mqttManager.topicToPublishAndItsMessage('${Environment.mqttPublishTopic}/${configPvd.masterData['deviceId']}', payload['payload']);
                                mqttAttempt = false;
                                print('payload sending ${sec+1}');
                              }
                              if(mqttManager.payload != null && mqttManager.payload!['cC'] == payload['deviceId'] && mqttManager.payload!['PayloadCode'] == payload['checkingCode'] && mqttManager.payload!['Code'] == '200'){
                                stateSetter((){
                                  setState(() {
                                    payload['acknowledgementState'] = HardwareAcknowledgementSate.success;

                                  });
                                });
                              }
                              if(sec == 0){
                                stateSetter((){
                                  setState(() {
                                    payloadSendState = PayloadSendState.start;
                                    payload['acknowledgementState'] = HardwareAcknowledgementSate.sending;
                                  });
                                });
                              }else if(sec == 4){
                                stateSetter((){
                                  setState(() {
                                    payload['acknowledgementState'] = HardwareAcknowledgementSate.failed;
                                  });
                                });
                              }
                              await Future.delayed(const Duration(seconds: 1));
                              if(payloadSendState == PayloadSendState.idle){
                                break;
                              }

                            }
                          }
                          stateSetter((){
                            setState(() {
                              payloadSendState = PayloadSendState.stop;
                              mqttManager.payload = null;
                            });
                          });

                        },
                        title: 'Send',
                      ),
                    if(payloadSendState == PayloadSendState.stop)
                      CustomMaterialButton(),
                  ],
                );
              }
          );
        }
    );
  }

  Widget payloadAcknowledgementWidget(HardwareAcknowledgementSate state){
    late Color color;
    if(state == HardwareAcknowledgementSate.notSent){
      color = Colors.grey;
      return statusBox(color, Text('not sent', style: TextStyle(color: color, fontSize: 12),));
    }else if(state == HardwareAcknowledgementSate.failed){
      color = Colors.red;
      return statusBox(color, Text('failed...', style: TextStyle(color: color, fontSize: 12),));
    }else if(state == HardwareAcknowledgementSate.success){
      color = Colors.green;
      return Text('success...', style: TextStyle(color: color, fontSize: 12),);
    }else{
      return const SizedBox(
          width: double.infinity,
          height: 5,
          child: LinearProgressIndicator()
      );
    }
  }

  Widget statusBox(Color color, Widget child){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(5)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10 , vertical: 5),
      child: child,
    );
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
      "deviceList" : ![1, 2, 4].contains(configPvd.masterData['modelId']) ? [] : configPvd.listOfDeviceModel.map((device) {
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
        if(configPvd.masterData['categoryId'] != 2 || (![ConfigMakerTabs.deviceList].contains(i)))
          CustomSideTab(
          width: screenWidth  > webBreakPoint ? sideNavigationTabWidth : sideNavigationTabBreakPointWidth,
          imagePath: '${AppConstants.svgObjectPath}${getTabImage(i)}.svg',
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

enum HardwareAcknowledgementSate{notSent, sending, failed, success, errorOnPayload, mqttNotConnected}
enum PayloadSendState{idle, start, stop}
