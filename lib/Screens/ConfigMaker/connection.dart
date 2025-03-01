
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/NewIrrigationProgram/schedule_screen.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../../Constants/communication_codes.dart';
import '../../Constants/properties.dart';
import '../../Models/Configuration/device_model.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../StateManagement/config_maker_provider.dart';
import '../../Widgets/connection_grid_list_tile.dart';
import '../../Widgets/connector_widget.dart';
import '../../Widgets/sized_image.dart';
import '../../utils/Theme/oro_theme.dart';
import '../../utils/constants.dart';

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
  late Future<bool> updateValuesConnectionPageInitialize;
  late ThemeData themeData;
  late bool themeMode;

  @override
  void initState() {
    super.initState();
    updateValuesConnectionPageInitialize = updateConnection(); // Initialize Future
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeData = Theme.of(context);
    themeMode = themeData.brightness == Brightness.light;
  }

  Future<bool> updateConnection() async {
    try {
      await Future.delayed(Duration(milliseconds: 100));
      List<int> listOfCategory = [];

      for (var device in widget.configPvd.listOfDeviceModel) {
        if (![1, 10].contains(device.categoryId) &&
            device.masterId != null &&
            !listOfCategory.contains(device.categoryId)) {
          listOfCategory.add(device.categoryId);
        }
      }

      if (listOfCategory.isEmpty) {
        return false; // Return false if no valid category found
      }

      widget.configPvd.selectedCategory = listOfCategory[0];

      for (var device in widget.configPvd.listOfDeviceModel) {
        if (device.categoryId == listOfCategory[0]) {
          widget.configPvd.selectedModelControllerId = device.controllerId;
          break;
        }
      }

      widget.configPvd.updateSelectedConnectionNoAndItsType(0, '');
      widget.configPvd.updateConnectionListTile();

      return true;
    } catch (e) {
      print('Error in updateConnection: ${e.toString()}');
      return false; // Return false on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: updateValuesConnectionPageInitialize,
        builder: (context, snapShot){
          if (snapShot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading
          }
          if (snapShot.hasError) {
            return const Center(child: Text('Error loading data'));
          }
          if(snapShot.hasData && snapShot.data == true){
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
                            spacing: 10,
                             crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if((selectedDevice.noOfRelay == 0 ? selectedDevice.noOfLatch : selectedDevice.noOfRelay) != 0)
                                getConnectionBox(
                                    selectedDevice: selectedDevice,
                                    color: outputColor,
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
          }else{
            return const Center(child: CircularProgressIndicator());
          }

        }
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
                  color: isSelected ? themeData.primaryColor : Colors.grey.shade200
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedImageSmall(imagePath: '${AppConstants.svgObjectPath}objectId_${object.objectId}.svg'),
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
        borderRadius: BorderRadius.circular(5),
        color: color.withOpacity(0.2),
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
              Text('$typeName ${from+1} to $typeName $to', style: TextStyle(color: color),),
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
      leadingColor: outputColor,
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
    Color borderColor = themeMode ? Colors.black : Colors.white;
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
          spacing: 10,
           mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: EdgeInsets.symmetric(horizontal: 15,vertical: widget.configPvd.selectedCategory == categoryId ? 12 :10),
                  decoration: BoxDecoration(
                      border: Border(top: BorderSide(width: 0.5, color: borderColor), left: BorderSide(width: 0.5, color: borderColor), right: BorderSide(width: 0.5, color: borderColor),),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                      color: widget.configPvd.selectedCategory == categoryId ? themeData.primaryColorDark.withOpacity(themeMode ? 1.0 : 0.5) : themeData.cardColor
                  ),
                  child: Text(getDeviceCodeToString(categoryId), style: widget.configPvd.selectedCategory == categoryId ? const TextStyle(color: Colors.white70) : const TextStyle(color: Colors.grey),),
                ),
              )
          ],
        ),
        Container(
          width: double.infinity,
          height: 3,
          color: themeData.primaryColorDark.withOpacity(themeMode ? 1.0 : 0.4),
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
          spacing: 10,
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
                      color: widget.configPvd.selectedModelControllerId == model.controllerId ? themeData.primaryColorDark.withOpacity(themeMode ? 1.0 : 0.5) : themeData.cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(width: 0.3)
                      ),
                      child: Column(
                        children: [
                          Text(model.deviceName, style: widget.configPvd.selectedModelControllerId == model.controllerId ? const TextStyle(color: Colors.white70) : const TextStyle(color: Colors.grey),),
                          Text(model.deviceId,style: TextStyle(color: Colors.amberAccent.withOpacity(themeMode ? 1.0 : 0.7), fontSize: 10, fontWeight: FontWeight.bold),),
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