import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Constants/communication_codes.dart';
import '../../Constants/dialog_boxes.dart';
import '../../Constants/properties.dart';
import '../../Models/Configuration/device_model.dart';
import '../../StateManagement/config_maker_provider.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../../Widgets/custom_buttons.dart';
import '../../Widgets/custom_drop_down_button.dart';
import '../../Widgets/custom_side_tab.dart';
import '../../Widgets/custom_table.dart';
import '../../Widgets/sized_image.dart';
import '../../Widgets/title_with_back_button.dart';
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
  int selectedMasterId = 1;
  bool selectAllNode = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
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
                  minWidth: 900,
                  headingRowColor: WidgetStateProperty.all(Colors.white),
                  dataRowColor: WidgetStateProperty.all(Colors.white),
                    fixedLeftColumns: 2,
                    columns: const [
                      DataColumn2(
                        fixedWidth: 80,
                        label: Text('SNO'),
                      ),
                      DataColumn2(
                        fixedWidth: 180,
                        label: Text('MODEL NAME'),
                      ),
                      DataColumn2(
                        fixedWidth: 180,
                        label: Text('DEVICE ID'),
                      ),
                      DataColumn2(
                        fixedWidth: 150,
                        label: Text('INTERFACE'),
                      ),
                      DataColumn2(
                        fixedWidth: 150,
                        label: Text('INTERVAL'),
                      ),
                      DataColumn2(
                        fixedWidth: 100,
                        label: Text(''),
                      ),
                    ],
                    rows: widget.listOfDevices
                        .where((node) => node.masterId == selectedMasterId)
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
                              Text('${index + 1}', style: textStyleInCell),
                            ),
                            DataCell(
                              Text(device.deviceName, style: textStyleInCell),
                            ),
                            DataCell(
                              Text(device.deviceId, style: TextStyle(color: Theme.of(context).primaryColorDark),),
                            ),
                            DataCell(
                                CustomDropDownButton(
                                    value: getInterfaceValue(device),
                                    list: [
                                      'RS485', 'LoRa', 'MQTT',
                                      for(var extend in configPvd.listOfDeviceModel)
                                        if(extend.categoryId == 10 && extend.masterId != null)
                                          'Extend\n${extend.deviceId}'
                                    ],
                                    onChanged: (String? newValue) {
                                      List<String> interface = newValue!.split('\n');
                                      setState(() {
                                        device.interfaceTypeId = getInterfaceStringToCode(interface[0]);
                                        if(interface.length > 1){
                                          device.extendControllerId = configPvd.listOfDeviceModel.firstWhere((device) => device.deviceId == interface[1]).controllerId;
                                        }else{
                                          device.extendControllerId = null;
                                        }
                                      });
                                    }
                                )
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
        border: Border.all(width: 0.5, color: const Color(0xffC9C6C6))
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: const SizedImageMedium(imagePath: 'assets/Images/Png/category_1_model_1.png'),
        title: Text('${configPvd.masterData['deviceName']}', style: const TextStyle(fontWeight: FontWeight.bold),),
        subtitle: Text('${configPvd.masterData['deviceId']}', style: const TextStyle(fontSize: 12 ),),
        trailing: IntrinsicWidth(
          child: RadiusButtonStyle(
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
                                  child: DataTable2(
                                    headingRowColor: const WidgetStatePropertyAll(Color(0xffEAECF0)),
                                    dataRowColor: const WidgetStatePropertyAll(Color(0xffFCFCFD)),
                                    dataTextStyle: textStyleInCell,
                                      columns: [
                                        DataColumn2(
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
                                        DataColumn2(
                                          label: Text('MODEL NAME'),
                                          fixedWidth: 180,
                                        ),
                                        DataColumn2(
                                          fixedWidth: 180,
                                          label: Text('DEVICE ID'),
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
                                                Text(device.deviceName,)
                                              ),
                                              DataCell(
                                                  Text(device.deviceId, style: TextStyle(color: Theme.of(context).primaryColor))
                                              ),
                                            ]
                                        );
                                      }).toList(),
                                  ),
                                ),
                                actions: [
                                  RadiusButtonStyle(
                                    onPressed: () {
                                      for (var node in configPvd.listOfDeviceModel) {
                                        stateSetter(() {
                                          setState(() {
                                            if (node.select) {
                                              configPvd.serialNumberIncrement += 1;
                                              node.masterId = selectedMasterId;
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

  String getInterfaceValue(DeviceModel device){
    String interface = getInterfaceCodeToString(device.interfaceTypeId);
    String interfaceWithDeviceId = device.interfaceTypeId == 5
        ? '$interface\n${configPvd.listOfDeviceModel.firstWhere((deviceObject) => deviceObject.controllerId == device.extendControllerId).deviceId}'
        : interface;
    return interfaceWithDeviceId;
  }

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
