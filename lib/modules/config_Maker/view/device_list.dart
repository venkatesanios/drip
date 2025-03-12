import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Constants/communication_codes.dart';
import '../../../Constants/dialog_boxes.dart';
import '../../../Constants/properties.dart';
import '../model/device_model.dart';
import '../state_management/config_maker_provider.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:oro_drip_irrigation/services/mqtt_manager_mobile.dart' if (dart.library.html) 'package:oro_drip_irrigation/services/mqtt_manager_web.dart';

import '../../../Widgets/custom_buttons.dart';
import '../../../Widgets/custom_drop_down_button.dart';
import '../../../Widgets/custom_side_tab.dart';
import '../../../Widgets/custom_table.dart';
import '../../../Widgets/sized_image.dart';
import '../../../Widgets/title_with_back_button.dart';
import '../../../flavors.dart';
import '../../../utils/environment.dart';
import 'config_base_page.dart';

class DeviceList extends StatefulWidget {
  List<DeviceModel> listOfDevices;
  DeviceList({
    super.key,
    required this.listOfDevices
  });

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  late ConfigMakerProvider configPvd;
  bool selectAllNode = false;
  late ThemeData themeData;
  late bool themeMode;

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
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    double screenWidth = MediaQuery.of(context).size.width - 16;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: screenWidth > 500 ? 880 : screenWidth,
          child: Column(
            children: [
              masterBox(
                  listOfDevices: widget.listOfDevices
              ),
              const SizedBox(height: 20,),
              Expanded(
                child: DataTable2(
                  minWidth: 950,
                  headingRowColor: WidgetStatePropertyAll(themeData.colorScheme.onBackground),
                  dataRowColor: const WidgetStatePropertyAll(Colors.white),
                    fixedLeftColumns: 2,
                    columns: [
                      DataColumn2(
                        fixedWidth: 80,
                        label: Text('SNO', style: themeData.textTheme.headlineLarge,),
                      ),
                      DataColumn2(
                        fixedWidth: 180,
                        label: Text('MODEL NAME', style: themeData.textTheme.headlineLarge,),
                      ),
                      DataColumn2(
                        fixedWidth: 180,
                        label: Text('DEVICE ID', style: themeData.textTheme.headlineLarge,),
                      ),
                      DataColumn2(
                        fixedWidth: 200,
                        label: Text('Extend', style: themeData.textTheme.headlineLarge,),
                      ),
                      DataColumn2(
                        fixedWidth: 150,
                        label: Text('INTERVAL', style: themeData.textTheme.headlineLarge,),
                      ),
                      const DataColumn2(
                        fixedWidth: 100,
                        label: Text(''),
                      ),
                    ],
                    rows: widget.listOfDevices
                        .where((node) => node.masterId == configPvd.masterData['controllerId'])
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      DeviceModel device = entry.value;
                      int index = entry.key;
                      var node = entry.value;
                      return DataRow(
                          cells: [
                            DataCell(
                              Text('${index + 1}', style: themeData.textTheme.headlineSmall),
                            ),
                            DataCell(
                              Text(device.deviceName, style: themeData.textTheme.headlineSmall),
                            ),
                            DataCell(
                              Text(device.deviceId, style: TextStyle(color: themeData.primaryColorDark),),
                            ),
                            DataCell(
                                (![44, 45, 46, 47,].contains(device.modelId) && configPvd.listOfDeviceModel.any((device) => device.categoryId == 10 && device.masterId != null)) ? CustomDropDownButton(
                                    value: getInitialExtendValue(device.extendControllerId),
                                    list: [
                                      '-',
                                      ...configPvd.listOfDeviceModel
                                          .where((device) => (device.masterId != null && device.categoryId == 10))
                                          .map((device) => '${device.deviceName}\n${device.deviceId}')
                                    ],
                                    onChanged: (String? newValue) {
                                      List<String> interface = newValue!.split('\n');
                                      setState(() {
                                        device.extendControllerId = getExtendControllerId(newValue);
                                      });
                                    }
                                ) : Text('N/A', style: themeData.textTheme.headlineSmall,)
                            ),
                            DataCell(
                              CustomDropDownButton(
                                  value: getIntervalCodeToString(device.interfaceInterval!, 'Sec'),
                                  list: [5 , 10, 15, 20, 25].map((e) => getIntervalCodeToString(e, 'Sec')).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      device.interfaceInterval = getIntervalStringToCode(newValue!);
                                    });
                                  }
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red,),
                                onPressed: (){
                                  bool configured = configPvd.listOfGeneratedObject.any((object) => object.controllerId == device.controllerId);
                                  if(configured){
                                    simpleDialogBox(context: context, title: 'Alert', message: '${device.deviceName} cannot be removed. Please detach all connected objects first.');
                                  }else{
                                    setState(() {
                                      device.masterId = null;
                                      if(device.categoryId == 10){
                                        for(var d in configPvd.listOfDeviceModel){
                                          if(d.extendControllerId!= null && d.extendControllerId == device.masterId){
                                            d.extendControllerId = null;
                                          }
                                        }
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ]
                      );
                    }).toList()
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getInitialExtendValue(int? extendControllerId){
    String value;
    if(extendControllerId != null){
      DeviceModel deviceModel = configPvd.listOfDeviceModel.firstWhere((device) => device.controllerId == extendControllerId);
      value = '${deviceModel.deviceName}\n${deviceModel.deviceId}';
    }else{
      value = '-';
    }
    print('getInitialExtendValue : $value');
    return value;
  }

  int? getExtendControllerId(String value){
    if(value == '-'){
      return null;
    }else{
      DeviceModel deviceModel = configPvd.listOfDeviceModel.firstWhere((device) => device.deviceId == value.split('\n')[1]);
      return deviceModel.controllerId;
    }
  }


  Widget masterBox(
      {
        required List<DeviceModel> listOfDevices
      }
      ){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width:  double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(width: 0.5, color: const Color(0xffC9C6C6)),
        boxShadow: AppProperties.customBoxShadowLiteTheme
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: SizedImageMedium(imagePath: 'assets/Images/Png/${F.name.contains('oro') ? 'Oro' : 'SmartComm'}/category_${configPvd.masterData['categoryId']}.png'),
        title: Text('${configPvd.masterData['deviceName']}', style: themeData.textTheme.bodyLarge,),
        subtitle: Text('${configPvd.masterData['deviceId']}', style: themeData.textTheme.bodySmall,),
        trailing: IntrinsicWidth(
          child: CustomMaterialButton(
              onPressed: (){
                setState(() {
                  selectAllNode = false;
                });
                bool isThereNodeToConfigure = listOfDevices.any((node) => node.masterId == null);
                if(isThereNodeToConfigure){
                  showDialog(
                      context: context,
                      builder: (context){
                        return StatefulBuilder(
                            builder: (context, stateSetter){
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0)
                                ),
                                title: const Text('Choose Node for Configuration Under Master',),
                                content: SizedBox(
                                  width: MediaQuery.of(context).size.width >= 400 ? 400 : MediaQuery.of(context).size.width,
                                  child: DataTable(
                                    headingRowColor: WidgetStatePropertyAll(themeData.colorScheme.onBackground),
                                    dataRowColor: WidgetStatePropertyAll(themeData.colorScheme.onBackground),
                                      columns: [
                                        DataColumn(
                                          label: Checkbox(
                                              value: selectAllNode,
                                              onChanged: (value){
                                                stateSetter((){
                                                  setState(() {
                                                    selectAllNode = !selectAllNode;
                                                    for(var device in configPvd.listOfDeviceModel){
                                                      device.select = selectAllNode;
                                                    }
                                                  });
                                                });
                                              }
                                          )
                                        ),
                                        DataColumn(
                                          label: Text('MODEL NAME', style: themeData.textTheme.headlineLarge,),
                                        ),
                                        DataColumn(
                                          label: Text('DEVICE ID',style: themeData.textTheme.headlineLarge,),
                                        )
                                      ],
                                      rows: listOfDevices
                                          .where((node) => node.masterId == null)
                                          .toList()
                                          .asMap()
                                          .entries.map((entry){
                                        int index = entry.key;
                                        DeviceModel device = entry.value;
                                        return DataRow(
                                            cells: [
                                              DataCell(
                                                Checkbox(
                                                  value: device.select,
                                                  onChanged: (value){
                                                    stateSetter((){
                                                      setState(() {
                                                        device.select = value!;
                                                      });
                                                    });
                                                  },
                                                ),
                                              ),
                                              DataCell(
                                                Text(device.deviceName,style: themeData.textTheme.headlineSmall,)
                                              ),
                                              DataCell(
                                                  Text(device.deviceId, style: TextStyle(color: themeData.primaryColor))
                                              ),
                                            ]
                                        );
                                      }).toList(),
                                  ),
                                ),
                                actions: [
                                  CustomMaterialButton(
                                    onPressed: () {
                                      for (var node in configPvd.listOfDeviceModel) {
                                        stateSetter(() {
                                          setState(() {
                                            if (node.select) {
                                              configPvd.serialNumberIncrement += 1;
                                              node.masterId = configPvd.masterData['controllerId'];
                                              node.select = false;
                                              node.serialNumber = configPvd.serialNumberIncrement;
                                            }
                                          });
                                        });
                                      }
                                      Navigator.pop(context);
                                    },
                                    title: 'Add',
                                  )
                                ],
                              );
                            }
                        );
                      }
                  );
                }else{
                  simpleDialogBox(context: context, title: 'Alert', message: 'There are no available nodes to configure at the moment');
                }

              },
              title: 'Add Nodes'
          ),
        ),
      ),
    );
  }

  // void sendToMqttSetSerial(){
  //
  //   final Map<String, dynamic> setSerialPayload = {
  //     '2300' : {
  //       '2301' : configPvd.listOfDeviceModel.where((device) => device.masterId != null).map((device) => device.serialNumber).toList().join(','),
  //
  //     }
  //   };
  //   MqttManager().topicToPublishAndItsMessage('${Environment.mqttWebPublishTopic}/${configPvd.masterData['deviceId']}', jsonEncode(setSerialPayload));
  //   print("configMakerPayload ==> ${jsonEncode(setSerialPayload)}");
  //   // print("getOroPumpPayload ==> ${widget.configPvd.getOroPumpPayload()}");
  // }


  String getTabName(ConfigMakerTabs configMakerTabs) {
    switch (configMakerTabs) {
      case ConfigMakerTabs.deviceList:
        return 'Device List';
      case ConfigMakerTabs.productLimit:
        return 'Product Limit';
      case ConfigMakerTabs.connection:
        return 'Connection';
      case ConfigMakerTabs.siteConfigure:
        return 'Site Configure';
      default:
        throw ArgumentError('Invalid ConfigMakerTabs value: $configMakerTabs');
    }
  }
  String getTabImage(ConfigMakerTabs configMakerTabs) {
    switch (configMakerTabs) {
      case ConfigMakerTabs.deviceList:
        return 'device_list_';
      case ConfigMakerTabs.productLimit:
        return 'product_limit_';
      case ConfigMakerTabs.connection:
        return 'connection_';
      case ConfigMakerTabs.siteConfigure:
        return 'site_configure_';
      default:
        throw ArgumentError('Invalid ConfigMakerTabs value: $configMakerTabs');
    }
  }
}

Color textColorInCell = const Color(0xff667085);
TextStyle textStyleInCell = TextStyle(color: textColorInCell, fontWeight: FontWeight.bold, fontSize: 13);
