import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/communication_codes.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/Models/Configuration/device_model.dart';
import 'package:oro_drip_irrigation/Widgets/connection_grid_list_tile.dart';
import 'package:oro_drip_irrigation/Widgets/connector_widget.dart';
import 'package:oro_drip_irrigation/Widgets/sized_image.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../StateManagement/config_maker_provider.dart';

class Connection extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  const Connection({
    super.key,
    required this.configPvd
  });

  @override
  State<Connection> createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    DeviceModel selectedDevice = widget.configPvd.listOfDeviceModel.firstWhere((device) => device.controllerId == widget.configPvd.selectedModelControllerId);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(builder: (context, constraint){
        return SizedBox(
          width: constraint.maxWidth,
          height: constraint.maxHeight,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getAvailableDeviceCategory(),
                const SizedBox(height: 8,),
                getModelBySelectedCategory(),
                const SizedBox(height: 10,),
                // if(selectedDevice.categoryId == 4)
                //   WeatherGridListTile( configPvd: widget.configPvd, device: selectedDevice)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 20,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if((selectedDevice.noOfRelay == 0 ? selectedDevice.noOfLatch : selectedDevice.noOfRelay) != 0)
                        getConnectionBox(
                            selectedDevice: selectedDevice,
                            color: const Color(0xffD2EAFF),
                            from: 0,
                            to: selectedDevice.noOfRelay == 0 ? selectedDevice.noOfLatch : selectedDevice.noOfRelay,
                            type: '1,2',
                            typeName: selectedDevice.noOfRelay == 0 ? 'Latch' : 'Relay',
                            keyWord: selectedDevice.noOfRelay == 0 ? 'L' : 'R'
                        ),
                      if(selectedDevice.noOfAnalogInput != 0)
                        getConnectionBox(
                            selectedDevice: selectedDevice,
                            color: getObjectTypeCodeToColor(3),
                            from: 0,
                            to: selectedDevice.noOfAnalogInput,
                            type: '3',
                            typeName: 'Analog',
                            keyWord: 'A'
                        ),
                      if(selectedDevice.noOfDigitalInput != 0)
                        getConnectionBox(
                            selectedDevice: selectedDevice,
                            color: getObjectTypeCodeToColor(4),
                            from: 0,
                            to: selectedDevice.noOfDigitalInput,
                            type: '4',
                            typeName: 'Digital',
                            keyWord: 'D'
                        ),
                      if(selectedDevice.noOfPulseInput != 0)
                        getConnectionBox(
                            selectedDevice: selectedDevice,
                            color: getObjectTypeCodeToColor(6),
                            from: 0,
                            to: selectedDevice.noOfPulseInput,
                            type: '6',
                            typeName: 'Pulse',
                            keyWord: 'P'
                        ),
                      if(selectedDevice.noOfMoistureInput != 0)
                        getConnectionBox(
                            selectedDevice: selectedDevice,
                            color: getObjectTypeCodeToColor(5),
                            from: 0,
                            to: selectedDevice.noOfMoistureInput,
                            type: '5',
                            typeName: 'Moisture',
                            keyWord: 'M'
                        ),
                      if(selectedDevice.noOfI2CInput != 0)
                        getConnectionBox(
                            selectedDevice: selectedDevice,
                            color: getObjectTypeCodeToColor(7),
                            from: 0,
                            to: selectedDevice.noOfI2CInput,
                            type: '7',
                            typeName: 'I2c',
                            keyWord: 'I2c'
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                if(widget.configPvd.selectedSelectionMode == SelectionMode.auto)
                  ...getAutoSelection(selectedDevice)
                else
                  ...getManualSelection(selectedDevice),

              ],
            ),
          ),
        );
      }),
    );
  }

  List<Widget> getManualSelection(DeviceModel selectedDevice){
    return [
      const Text('Select Object To Connect', style: AppProperties.normalBlackBoldTextStyle,),
      ResponsiveGridList(
        horizontalGridMargin: 20,
        verticalGridMargin: 10,
        minItemWidth: 150,
        shrinkWrap: true,
        listViewBuilderOptions: ListViewBuilderOptions(
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: widget.configPvd.listOfGeneratedObject
            .where((object) => object.type == widget.configPvd.selectedType
            && selectedDevice.connectingObjectId.contains(object.objectId)
            && object.controllerId == null || (object.controllerId == selectedDevice.controllerId && object.connectionNo == widget.configPvd.selectedConnectionNo))
            .toList()
            .map((object){
          bool isSelected = object.controllerId == selectedDevice.controllerId
              && object.type == widget.configPvd.selectedType
              && object.connectionNo == widget.configPvd.selectedConnectionNo;
          return InkWell(
            onTap: (){
              setState(() {
                // remove if there any old connection
                for(var generatedObject in widget.configPvd.listOfGeneratedObject){
                  if(widget.configPvd.selectedConnectionNo == generatedObject.connectionNo && selectedDevice.controllerId == generatedObject.controllerId){
                    generatedObject.controllerId = null;
                    generatedObject.connectionNo = 0;
                    for(var connectionObject in widget.configPvd.listOfObjectModelConnection){
                     if(generatedObject.objectId == connectionObject.objectId){
                       int integerValue = int.parse(connectionObject.count == '' ? '0' : connectionObject.count!);
                       connectionObject.count = (integerValue - 1).toString();
                     }
                    }
                  }
                }
                // update connection for selected object
                for(var generatedObject in widget.configPvd.listOfGeneratedObject){
                  if(object.sNo == generatedObject.sNo){
                    generatedObject.controllerId = selectedDevice.controllerId;
                    generatedObject.connectionNo = widget.configPvd.selectedConnectionNo;
                    for(var connectionObject in widget.configPvd.listOfObjectModelConnection){
                      if(generatedObject.objectId == connectionObject.objectId){
                        int integerValue = int.parse(connectionObject.count == '' ? '0' : connectionObject.count!);
                        connectionObject.count = (integerValue + 1).toString();
                      }
                    }
                  }
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedImageSmall(imagePath: 'assets/Images/Png/objectId_${object.objectId}.png'),
                  Text('${object.name}', style: isSelected ? AppProperties.tableHeaderStyleWhite : AppProperties.tableHeaderStyle,),
                ],
              ),
            ),
          );
        }).toList(),
      )

    ];
  }

  List<Widget> getAutoSelection(DeviceModel selectedDevice){
    return [
      outputObject(selectedDevice),
      const SizedBox(height: 10,),
      analogObject(),
    ];
  }

  Widget getConnectionBox(
  {
    required DeviceModel selectedDevice,
    required Color color,
    required int from,
    required int to,
    required String type,
    required String typeName,
    required String keyWord,
  }
      ){
    int firstEight = 8;
    if(to < 8){
      firstEight = firstEight - (8 - to);
    }
    return Container(
      width: to > 8 ? 500 : 250,
      height: 260,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color,
          // boxShadow: AppProperties.customBoxShadow
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    for(var count = from;count < firstEight;count++)
                      ...[
                        ConnectorWidget(
                          connectionNo: count + 1,
                          selectedDevice: selectedDevice,
                          configPvd: widget.configPvd,
                          type: type,
                          keyWord: keyWord,
                        ),
                        const SizedBox(height: 5,)
                      ],
                  ],
                ),
              ),
              if(to > 8)
                const SizedBox(width: 10,),
              if(to > 8)
                Expanded(
                child: Column(
                  children: [
                    for(var count = firstEight;count < to;count++)
                      ...[
                        ConnectorWidget(
                          connectionNo: count + 1,
                          selectedDevice: selectedDevice,
                          configPvd: widget.configPvd,
                          type: type,
                          keyWord: keyWord,
                        ),
                        const SizedBox(height: 5,)
                      ],
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('$typeName ${from+1} to $typeName $to', style: AppProperties.tableHeaderStyle,),
              IconButton(
                  onPressed: (){
                    setState(() {
                      widget.configPvd.selectedSelectionMode = widget.configPvd.selectedSelectionMode == SelectionMode.auto
                          ? SelectionMode.manual
                          : SelectionMode.auto;
                      widget.configPvd.selectedConnectionNo = 0;
                    });
                  },
                  icon: widget.configPvd.selectedSelectionMode == SelectionMode.auto ? const Icon(Icons.list) : const Icon(Icons.grid_view_outlined)
              )
            ],
          )
        ],
      ),
    );
  }

  Widget outputObject(DeviceModel selectedDevice){
    DeviceModel selectedDevice = widget.configPvd.listOfDeviceModel.firstWhere((device) => device.controllerId == widget.configPvd.selectedModelControllerId);
    List<int> filteredObjectList = widget.configPvd.listOfSampleObjectModel
        .where((object) => (object.type == '1,2' && !['', '0', null].contains(object.count)))
        .toList().where((object) => selectedDevice.connectingObjectId.contains(object.objectId)).toList().map((object) => object.objectId)
        .toList();
    List<DeviceObjectModel> filteredList = widget.configPvd.listOfObjectModelConnection.where((object)=> filteredObjectList.contains(object.objectId)).toList();

    return ConnectionGridListTile(
      listOfObjectModel: filteredList,
      title: 'Output Object',
      leadingColor: const Color(0xffD2EAFF),
      configPvd: widget.configPvd,
      selectedDevice: selectedDevice,
    );
  }
  Widget analogObject(){
    DeviceModel selectedDevice = widget.configPvd.listOfDeviceModel.firstWhere((device) => device.controllerId == widget.configPvd.selectedModelControllerId);
    List<int> filteredObjectList = widget.configPvd.listOfSampleObjectModel
        .where((object) => (!['-', '1,2'].contains(object.type) && !['', '0', null].contains(object.count)))
        .toList().where((object) => selectedDevice.connectingObjectId.contains(object.objectId)).toList().map((object) => object.objectId)
        .toList();
    List<DeviceObjectModel> filteredList = widget.configPvd.listOfObjectModelConnection.where((object)=> filteredObjectList.contains(object.objectId)).toList();    filteredList.sort((a, b) => a.type.compareTo(b.type));
    return ConnectionGridListTile(
      listOfObjectModel: filteredList,
      title: 'Input Object',
      configPvd: widget.configPvd,
      selectedDevice: selectedDevice,
    );
  }
  Widget getAvailableDeviceCategory(){
    List<int> listOfCategory = [];
    for(var device in widget.configPvd.listOfDeviceModel){
      if(![1, 10].contains(device.categoryId) && device.masterId != null && !listOfCategory.contains(device.categoryId)){
        listOfCategory.add(device.categoryId);
      }
    }
    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            for(var categoryId in listOfCategory)
              InkWell(
                onTap: (){
                  setState(() {
                    widget.configPvd.selectedCategory = categoryId;
                    for(var device in widget.configPvd.listOfDeviceModel){
                      if(device.categoryId == categoryId){
                        widget.configPvd.selectedModelControllerId = device.controllerId;
                        break;
                      }
                    }
                  });
                  widget.configPvd.updateSelectedConnectionNoAndItsType(0, '');
                  widget.configPvd.updateConnectionListTile();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.configPvd.selectedCategory == categoryId ? Theme.of(context).primaryColorLight : Colors.grey.shade300
                  ),
                  child: Text(getDeviceCodeToString(categoryId), style: TextStyle(color: widget.configPvd.selectedCategory == categoryId ? Colors.white : Colors.black, fontSize: 13),),
                ),
              )
          ],
        ),
        Container(
          width: double.infinity,
          height: 3,
          color: Theme.of(context).primaryColorLight,
        )
      ],
    );
    return child;
  }
  Widget getModelBySelectedCategory(){
    List<DeviceModel> filteredDeviceModel = widget.configPvd.listOfDeviceModel.where((device) => (device.categoryId == widget.configPvd.selectedCategory && device.masterId != null)).toList();
    Widget child = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for(var model in filteredDeviceModel)
              ...[
                InkWell(
                  onTap: (){
                    setState(() {
                      widget.configPvd.selectedModelControllerId = model.controllerId;
                    });
                    widget.configPvd.updateConnectionListTile();
                    widget.configPvd.updateSelectedConnectionNoAndItsType(0, '');
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: widget.configPvd.selectedModelControllerId == model.controllerId ? Color(0xff1C863F) :Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Column(
                        children: [
                          Text(model.deviceName,style: TextStyle(color: widget.configPvd.selectedModelControllerId == model.controllerId ? Colors.white : Colors.black, fontSize: 13),),
                          Text(model.deviceId,style: TextStyle(color: widget.configPvd.selectedModelControllerId == model.controllerId ? Colors.amberAccent : Colors.black, fontSize: 10, fontWeight: FontWeight.bold),),
                        ],
                      )
                  ),
                ),
                const SizedBox(width: 10,)
              ]

          ],
        ),
      );
    return child;
  }
}

enum SelectionMode {auto, manual}