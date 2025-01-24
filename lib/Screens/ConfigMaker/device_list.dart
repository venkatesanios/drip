import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/dialog_boxes.dart';
import 'package:provider/provider.dart';
import '../../Constants/communication_codes.dart';
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
  ScrollController _scrollController = ScrollController();
  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  int selectedMasterId = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollable1 = LinkedScrollControllerGroup();
    _verticalScroll1 = _scrollable1.addAndGet();
    _verticalScroll2 = _scrollable1.addAndGet();
    _scrollable2 = LinkedScrollControllerGroup();
    _horizontalScroll1 = _scrollable2.addAndGet();
    _horizontalScroll2 = _scrollable2.addAndGet();
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    double screenWidth = MediaQuery.of(context).size.width - 16;
    double screenHeight = MediaQuery.of(context).size.height;
    double headerBoxWidth = screenWidth * 0.5;
    double headerBoxMinimumWidth = 300;
    double headerWidth = 120;
    double fixedColumnWidth = headerWidth * 2;
    double scrollableColumnWidth = headerWidth * 6;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const SizedBox(height: 10,),
          masterBox(
              headerWidth: headerWidth,
              headerBoxWidth: headerBoxWidth,
              headerBoxMinimumWidth: headerBoxMinimumWidth,
              listOfDevices: widget.listOfDevices
          ),
          const SizedBox(height: 20,),
          Expanded(
            child: tableWidget(
                fixedColumnWidth: fixedColumnWidth,
                scrollableColumnWidth: scrollableColumnWidth,
                headerWidth: headerWidth,
                listOfDevices: widget.listOfDevices
            ),
          ),
        ],
      ),
    );
  }

  Widget masterBox(
      {
        required double headerWidth,
        required double headerBoxWidth,
        required double headerBoxMinimumWidth,
        required List<DeviceModel> listOfDevices
      }
      ){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width: headerBoxMinimumWidth < headerBoxWidth ? headerBoxWidth : double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: AppProperties.linearGradientPrimaryLite
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: const SizedImageMedium(imagePath: 'assets/Images/Png/category_1_model_1.png'),
        title: Text('${configPvd.masterData['deviceName']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        subtitle: Text('${configPvd.masterData['deviceId']}', style: const TextStyle(color: Colors.white,fontSize: 12 ),),
        trailing: IntrinsicWidth(
          child: RadiusButtonStyle(
              onPressed: (){
                bool isThereNodeToConfigure = listOfDevices.any((node) => node.masterId == null);
                if(isThereNodeToConfigure){
                  showDialog(
                      context: context,
                      builder: (context){
                        return StatefulBuilder(
                            builder: (context, stateSetter){
                              return AlertDialog(
                                title: const Text('Choose Node for Configuration Under Master',style: AppProperties.normalBlackBoldTextStyle,),
                                content: SizedBox(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const CustomTableCellPassingWidget(
                                              widget: Icon(Icons.touch_app),
                                              width: 50
                                          ),
                                          CustomTableHeader(title: 'MODEL NAME', width: headerWidth),
                                          CustomTableHeader(title: 'DEVICE ID', width: headerWidth),
                                        ],
                                      ),
                                      ...listOfDevices
                                          .where((node) => node.masterId == null)
                                          .toList()
                                          .asMap()
                                          .entries.map((entry){
                                        int index = entry.key;
                                        DeviceModel device = entry.value;
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            CustomTableCellPassingWidget(
                                                widget: Checkbox(
                                                  value: device.select,
                                                  onChanged: (value){
                                                    stateSetter((){
                                                      setState(() {
                                                        device.select = value!;
                                                      });
                                                    });
                                                  },
                                                ),
                                                width: 50
                                            ),
                                            CustomTableCell(title: device.deviceName, width: 120),
                                            CustomTableCell(title: device.deviceId, width: 120),
                                          ],
                                        );
                                      })
                                    ],
                                  ),
                                ),
                                actions: [
                                  RadiusButtonStyle(
                                    onPressed: () {
                                      for (var node in configPvd.listOfDeviceModel) {
                                        stateSetter(() {
                                          setState(() {
                                            if (node.select) {
                                              node.masterId = selectedMasterId;
                                              node.select = false;
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
  Widget tableWidget(
      {
        required double fixedColumnWidth,
        required double scrollableColumnWidth,
        required double headerWidth,
        required List<DeviceModel> listOfDevices,
      }
      ){
    return Column(
      children: [
        Expanded(
          child: SizedBox(
            width: scrollableColumnWidth,
            height: double.infinity,
            child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              var width = constraints.maxWidth;
              return Row(
                children: [
                  Column(
                    children: [
                      //Todo : first column
                      Row(
                        children: [
                          CustomTableHeader(title: 'SNO', width: headerWidth),
                          CustomTableHeader(title: 'MODEL NAME', width: headerWidth),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                            controller: _verticalScroll1,
                            child: Column(
                              children: listOfDevices
                                  .where((node) => node.masterId == selectedMasterId)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int index = entry.key;
                                var node = entry.value;
                                return Row(
                                  children: [
                                    CustomTableCell(title: '${index + 1}', width: 120),
                                    CustomTableCell(title: node.deviceName, width: 120),
                                  ],
                                );
                              }).toList(),
                            )
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: width-fixedColumnWidth,
                        child: SingleChildScrollView(
                          controller: _horizontalScroll1,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              CustomTableHeader(title: 'DEVICE ID', width: headerWidth),
                              CustomTableHeader(title: 'INTERFACE', width: headerWidth),
                              CustomTableHeader(title: 'INTERVAL', width: headerWidth),
                              CustomTableHeader(title: 'ACTION', width: headerWidth),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: width-fixedColumnWidth,
                          child: Scrollbar(
                            thumbVisibility: true,
                            controller: _horizontalScroll2,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: _horizontalScroll2,
                              child: Scrollbar(
                                thumbVisibility: true,
                                controller: _verticalScroll2,
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    controller: _verticalScroll2,
                                    child:  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: listOfDevices
                                          .where((node) => node.masterId == selectedMasterId)
                                          .toList()
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        DeviceModel device = entry.value;
                                        return Row(
                                          children: [
                                            CustomTableCell(title: device.deviceId, width: headerWidth),
                                            CustomTableCellPassingWidget(
                                                widget: CustomDropDownButton(
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
                                                          device.extendDeviceId = interface[1];
                                                        }else{
                                                          device.extendDeviceId = '';
                                                        }
                                                      });
                                                    }
                                                ),
                                                width: headerWidth
                                            ),
                                            CustomTableCellPassingWidget(
                                                widget: CustomDropDownButton(
                                                    value: getIntervalCodeToString(device.interfaceInterval!, 'Sec'),
                                                    list: [5 , 10, 15, 20, 25].map((e) => getIntervalCodeToString(e, 'Sec')).toList(),
                                                    onChanged: (String? newValue) {
                                                      setState(() {
                                                        device.interfaceInterval = getIntervalStringToCode(newValue!);
                                                      });
                                                    }
                                                ),
                                                width: headerWidth
                                            ),
                                            CustomTableCellPassingWidget(
                                                widget: IconButton(
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
                                                width: headerWidth
                                            )
                                          ],
                                        );
                                      }).toList(),
                                    )
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),

                ],
              );
            },),
          ),
        )
      ],
    );
  }

  String getInterfaceValue(DeviceModel device){
    String interface = getInterfaceCodeToString(device.interfaceTypeId);
    String interfaceWithDeviceId = device.interfaceTypeId == 5
        ? '$interface\n${device.extendDeviceId}'
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
