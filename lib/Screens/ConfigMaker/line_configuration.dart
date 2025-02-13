import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Models/Configuration/fertigation_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/pump_model.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/site_configure.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/source_configuration.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../../Constants/dialog_boxes.dart';
import '../../Constants/properties.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../Models/Configuration/filtration_model.dart';
import '../../Models/Configuration/irrigationLine_model.dart';
import '../../Models/Configuration/moisture_model.dart';
import '../../Models/Configuration/source_model.dart';
import '../../Models/LineDataModel.dart';
import '../../StateManagement/config_maker_provider.dart';
import '../../Widgets/sized_image.dart';
import '../../services/http_service.dart';
import 'config_object_name_editing.dart';
import 'fertilization_configuration.dart';
import 'filtration_configuration.dart';
import 'package:oro_drip_irrigation/Constants/mqtt_manager_mobile.dart' if (dart.library.html) 'package:oro_drip_irrigation/Constants/mqtt_manager_web.dart';

class LineConfiguration extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  const LineConfiguration({super.key, required this.configPvd});

  @override
  State<LineConfiguration> createState() => _LineConfigurationState();
}

class _LineConfigurationState extends State<LineConfiguration> {
  double pumpExtendedWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    IrrigationLineModel? selectedIrrigationLine = widget.configPvd.line.cast<IrrigationLineModel?>().firstWhere((line)=> line!.commonDetails.sNo == widget.configPvd.selectedLineSno, orElse: ()=> null);
    print('selectedIrrigationLine ::: ${selectedIrrigationLine!.commonDetails.name}');
    return Padding(
        padding: const EdgeInsets.all(8),
      child: LayoutBuilder(builder: (context, constraint){
        return Scaffold(
          body: SafeArea(
            child: Container(
              width: constraint.maxWidth,
              height: constraint.maxHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).primaryColor == Colors.black ? Colors.white10 : Colors.white
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: getLineTabs(),
                  ),
                  const SizedBox(height: 10,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  spacing: 20,
                                  children: [
                                    IconButton(
                                        onPressed: (){
                                          showModalBottomSheet(
                                            shape: Border.all(),
                                            isScrollControlled: true,
                                              context: context,
                                              builder: (context){
                                                return SizedBox(
                                                  width: 700,
                                                  child: ConfigObjectNameEditing(listOfObjectInLine: widget.configPvd.listOfGeneratedObject, configPvd: widget.configPvd,),
                                                );
                                              }
                                          );
                                        }, icon: const Icon(Icons.dataset)
                                    ),
                                    if(availability(2))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.sourcePump, parameterType: LineParameter.sourcePump, objectId: 5, objectName: 'Source Pump', validateAllLine: false, listOfObject: widget.configPvd.pump.where((pump) => (pump.pumpType == 1)).toList().map((pump) => pump.commonDetails).toList()),
                                    if(availability(2))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.irrigationPump, parameterType: LineParameter.irrigationPump, objectId: 5, objectName: 'Irrigation Pump', validateAllLine: false, listOfObject: widget.configPvd.pump.where((pump) => (pump.pumpType == 2)).toList().map((pump) => pump.commonDetails).toList()),
                                    if(availability(13))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.valve, parameterType: LineParameter.valve, objectId: 13, objectName: 'Valve', validateAllLine: true),
                                    if(availability(14))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.mainValve, parameterType: LineParameter.mainValve, objectId: 14, objectName: 'Main Valve', validateAllLine: true),
                                    if(availability(15))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.fan, parameterType: LineParameter.fan, objectId: 15, objectName: 'Fan', validateAllLine: true),
                                    if(availability(16))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.fogger, parameterType: LineParameter.fogger, objectId: 16, objectName: 'Fogger', validateAllLine: true),
                                    if(availability(17))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.heater, parameterType: LineParameter.heater, objectId: 17, objectName: 'Heater', validateAllLine: true),
                                    if(availability(36))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.humidity, parameterType: LineParameter.humidity, objectId: 36, objectName: 'Humidity', validateAllLine: true),
                                    if(availability(21))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.screen, parameterType: LineParameter.screen, objectId: 21, objectName: 'Screen', validateAllLine: true),
                                    if(availability(33))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.co2, parameterType: LineParameter.co2, objectId: 33, objectName: 'Co2', validateAllLine: true),
                                    if(availability(25))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.moisture, parameterType: LineParameter.moisture, objectId: 25, objectName: 'Moisture', validateAllLine: true),
                                    if(availability(20))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.vent, parameterType: LineParameter.vent, objectId: 20, objectName: 'Vent', validateAllLine: true),
                                    if(availability(18))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.pesticides, parameterType: LineParameter.pesticides, objectId: 18, objectName: 'Pesticides', validateAllLine: true),
                                    if(availability(30))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.soilTemperature, parameterType: LineParameter.soilTemperature, objectId: 30, objectName: 'Soil Temperature', validateAllLine: true),
                                    if(availability(29))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.temperature, parameterType: LineParameter.temperature, objectId: 29, objectName: 'Temperature', validateAllLine: true),
                                    if(availability(22))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.waterMeter], parameterType: LineParameter.waterMeter, objectId: 22, objectName: 'Water Meter', validateAllLine: true, singleSelection: true),
                                    if(availability(42))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.powerSupply], parameterType: LineParameter.powerSupply, objectId: 42, objectName: 'Power Supply', validateAllLine: true, singleSelection: true),
                                    if(availability(23))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.pressureSwitch], parameterType: LineParameter.pressureSwitch, objectId: 23, objectName: 'Power Switch', validateAllLine: true, singleSelection: true),
                                    if(availability(24))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.pressureIn], parameterType: LineParameter.pressureIn, objectId: 24, objectName: 'Pressure In', validateAllLine: true, singleSelection: true, listOfObject: widget.configPvd.listOfGeneratedObject.where((object) => !widget.configPvd.pump.any((pump) => [pump.pressureIn,pump.pressureOut].contains(object.sNo))).toList()),
                                    if(availability(24))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.pressureOut], parameterType: LineParameter.pressureOut, objectId: 24, objectName: 'Pressure Out', validateAllLine: true, singleSelection: true),
                                    if(availability(3))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.centralFertilization], parameterType: LineParameter.centralFertilization, objectId: 3, objectName: 'Central Fertilization', validateAllLine: false, singleSelection: true, listOfObject: widget.configPvd.fertilization.where((site) => (site.siteMode == 1)).toList().map((site) => site.commonDetails).toList()),
                                    if(availability(3))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.localFertilization], parameterType: LineParameter.localFertilization, objectId: 3, objectName: 'Local Fertilization', validateAllLine: false, singleSelection: true, listOfObject: widget.configPvd.fertilization.where((site) => (site.siteMode == 2)).toList().map((site) => site.commonDetails).toList()),
                                    if(availability(4))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.centralFiltration], parameterType: LineParameter.centralFiltration, objectId: 4, objectName: 'Central Filtration', validateAllLine: false, singleSelection: true, listOfObject: widget.configPvd.filtration.where((site) => (site.siteMode == 1)).toList().map((site) => site.commonDetails).toList()),
                                    if(availability(4))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.localFiltration], parameterType: LineParameter.localFiltration, objectId: 4, objectName: 'Local Filtration', validateAllLine: false, singleSelection: true, listOfObject: widget.configPvd.filtration.where((site) => (site.siteMode == 2)).toList().map((site) => site.commonDetails).toList()),
                                    if(availability(3))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.centralFertilization], parameterType: LineParameter.centralFertilization, objectId: 3, objectName: 'Central Fertilization', validateAllLine: false, singleSelection: true, listOfObject: widget.configPvd.fertilization.cast<FertilizationModel>().where((site) => (site.siteMode == 1)).toList().map((site) => site.commonDetails).toList()),
                                    if(availability(3))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.localFertilization], parameterType: LineParameter.localFertilization, objectId: 3, objectName: 'Local Fertilization', validateAllLine: false, singleSelection: true, listOfObject: widget.configPvd.fertilization.cast<FertilizationModel>().where((site) => (site.siteMode == 2)).toList().map((site) => site.commonDetails).toList()),
                                    if(availability(4))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.centralFiltration], parameterType: LineParameter.centralFiltration, objectId: 4, objectName: 'Central Filtration', validateAllLine: false, singleSelection: true, listOfObject: widget.configPvd.filtration.cast<FiltrationModel>().where((site) => (site.siteMode == 1)).toList().map((site) => site.commonDetails).toList()),
                                    if(availability(4))
                                      getLineParameter(line: selectedIrrigationLine, currentParameterValue: [selectedIrrigationLine.localFiltration], parameterType: LineParameter.localFiltration, objectId: 4, objectName: 'Local Filtration', validateAllLine: false, singleSelection: true, listOfObject: widget.configPvd.filtration.cast<FiltrationModel>().where((site) => (site.siteMode == 2)).toList().map((site) => site.commonDetails).toList()),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10,),
                            diagramWidget(selectedIrrigationLine),
                            const SizedBox(height: 20,),
                            checkingAnyParameterAvailableInLine(selectedIrrigationLine),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Container(
                  //   // color: Colors.green.shade50,
                  //   width: double.infinity,
                  //   height: 254,
                  //   child: Row(
                  //     children: [
                  //       SvgPicture.asset(
                  //         'assets/Images/Filtration/filtration_joint_1.svg',
                  //         width: 120,
                  //         height: 254,
                  //       ),
                  //       SizedBox(
                  //         width: 1500,
                  //         height: 254,
                  //         child: Stack(
                  //           children: [
                  //             Positioned(
                  //               top: 100,
                  //               child: Row(
                  //                 children: [
                  //                   if(widget.configPvd.filtration[0].filters.length == 1)
                  //                     singleFilter(ratio, constraint, widget.configPvd.filtration[0], widget.configPvd),
                  //                   if(widget.configPvd.filtration[0].filters.length > 1)
                  //                     multipleFilter(ratio, constraint, widget.configPvd.filtration[0], widget.configPvd),
                  //                 ],
                  //               ),
                  //             ),
                  //             Positioned(
                  //               bottom: 6,
                  //               left: 528,
                  //               child: SvgPicture.asset(
                  //                 'assets/Images/Filtration/filtration_to_fertilization_1.svg',
                  //                 width: 95,
                  //                 height: 17,
                  //               )
                  //             ),
                  //
                  //             Positioned(
                  //               top: 34,
                  //               left: 596,
                  //               child: Column(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 crossAxisAlignment: CrossAxisAlignment.center,
                  //                 children: [
                  //                   // if(fertilizationSite.channel.length == 1)
                  //                   //   getSingleChannel(fertilizerSite: fertilizationSite),
                  //                   // if(fertilizationSite.channel.length > 1)
                  //                     getMultipleChannel(fertilizerSite: widget.configPvd.fertilization[0])
                  //                 ],
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       )
                  //
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {

              // MqttManager().topicToPublishAndItsMessage('siva', 'hi from siva');
              sendToMqtt();
              // sendToHttp();


            },
            child: const Icon(Icons.send),
          ),
        );
      }),
    );
  }

  void sendToMqtt(){
    final Map<String, dynamic> configMakerPayload = {
      "100": [
        {"101": widget.configPvd.getDeviceListPayload()},
        {"102": widget.configPvd.getObjectPayload()},
        {"102": widget.configPvd.getPumpPayload()},
        {"202": widget.configPvd.getIrrigationLinePayload()},
        {"203": widget.configPvd.getFertilizerPayload()},
        {"203": widget.configPvd.getFertilizerInjectorPayload()},
        {"203": widget.configPvd.getMoisturePayload()},
      ]
    };

    print("configMakerPayload ==> ${jsonEncode(configMakerPayload)}");
    // print("getOroPumpPayload ==> ${widget.configPvd.getOroPumpPayload()}");
  }

  void sendToHttp()async{
    var listOfSampleObjectModel = widget.configPvd.listOfSampleObjectModel.map((object){
      return object.toJson();
    }).toList();
    var listOfObjectModelConnection = widget.configPvd.listOfObjectModelConnection.map((object){
      return object.toJson();
    }).toList();
    var listOfGeneratedObject = widget.configPvd.listOfGeneratedObject.map((object){
      return object.toJson();
    }).toList();
    var filtration = widget.configPvd.filtration.cast<FiltrationModel>().map((object){
      return object.toJson();
    }).toList();
    var fertilization = widget.configPvd.fertilization.cast<FertilizationModel>().map((object){
      return object.toJson();
    }).toList();
    var source = widget.configPvd.source.cast<SourceModel>().map((object){
      return object.toJson();
    }).toList();
    var pump = widget.configPvd.pump.cast<PumpModel>().map((object){
      return object.toJson();
    }).toList();
    var moisture = widget.configPvd.moisture.cast<MoistureModel>().map((object){
      return object.toJson();
    }).toList();
    var line = widget.configPvd.line.cast<IrrigationLineModel>().map((object){
      return object.toJson();
    }).toList();

    var body = {
      "userId" : widget.configPvd.masterData['customerId'],
      "controllerId" : widget.configPvd.masterData['controllerId'],
      'groupId' : widget.configPvd.masterData['groupId'],
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
      "deviceList" : widget.configPvd.listOfDeviceModel.map((device) {
        return {
          'productId' : device.productId,
          'controllerId' : device.controllerId,
          'masterId' : device.masterId,
          'referenceNumber' : widget.configPvd.findOutReferenceNumber(device),
          'serialNumber' : device.serialNumber,
          'interfaceTypeId' : device.interfaceTypeId,
          'interfaceInterval' : device.masterId == null ? null : device.interfaceInterval,
          'extendControllerId' : device.extendControllerId,
        };
      }).toList(),
      "hardware" : {},
      "controllerReadStatus" : '0',
      "createUser" : widget.configPvd.masterData['userId']
    };
    var response = await HttpService().postRequest('/user/configMaker/create', body);
    // print('response : ${response.body}');
    print('body : ${jsonEncode(body)}');
    print('response : ${response.body}');
  }

  Widget checkingAnyParameterAvailableInLine(IrrigationLineModel selectedIrrigationLine){
    List<Widget> childrenWidget = [
      ...getObjectInLine(selectedIrrigationLine.mainValve, 12),
      if(selectedIrrigationLine.waterMeter != 0.0)
        ...getObjectInLine([selectedIrrigationLine.waterMeter], 22),
      ...getObjectInLine(selectedIrrigationLine.valve, 13),
      ...getObjectInLine(selectedIrrigationLine.fan, 15),
      ...getObjectInLine(selectedIrrigationLine.fogger, 16),
      ...getObjectInLine(selectedIrrigationLine.heater, 17),
      ...getObjectInLine(selectedIrrigationLine.humidity, 36),
      ...getObjectInLine(selectedIrrigationLine.screen, 21),
      ...getObjectInLine(selectedIrrigationLine.co2, 33),
      ...getObjectInLine(selectedIrrigationLine.moisture, 25),
      ...getObjectInLine(selectedIrrigationLine.vent, 20),
      ...getObjectInLine(selectedIrrigationLine.pesticides, 18),
      ...getObjectInLine(selectedIrrigationLine.soilTemperature, 30),
      ...getObjectInLine(selectedIrrigationLine.temperature, 29),
      if(selectedIrrigationLine.pressureIn != 0.0)
        ...getObjectInLine([selectedIrrigationLine.pressureIn], 24),
      if(selectedIrrigationLine.pressureOut != 0.0)
        ...getObjectInLine([selectedIrrigationLine.pressureOut], 24),
      if(selectedIrrigationLine.pressureSwitch != 0.0)
        ...getObjectInLine([selectedIrrigationLine.pressureSwitch], 23),
      if(selectedIrrigationLine.powerSupply != 0.0)
        ...getObjectInLine([selectedIrrigationLine.powerSupply], 42),
    ];
    return childrenWidget.isEmpty ? Container() : Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black)
      ),
      child: ResponsiveGridList(
        horizontalGridMargin: 0,
        verticalGridMargin: 10,
        minItemWidth: 100,
        shrinkWrap: true,
        listViewBuilderOptions: ListViewBuilderOptions(
          physics: const NeverScrollableScrollPhysics(),
        ),
        children: childrenWidget,
      ),
    );
  }

  List<Widget> getObjectInLine(List<double> parameters, int objectId){
    return [
      for(var objectSno in parameters)
        Column(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Image.asset('assets/Images/Png/objectId_$objectId.png'),
            ),
            Text(getObjectName(objectSno, widget.configPvd).name!, style: AppProperties.listTileBlackBoldStyle,)
          ],
        )
    ];

  }

  bool availability(objectId){
    return widget.configPvd.listOfSampleObjectModel.any((object) => (object.objectId == objectId && object.count != '0'));
  }

  Widget getLineTabs(){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for(var line in widget.configPvd.line)
            ...[
              InkWell(
                onTap: (){
                  setState(() {
                    widget.configPvd.selectedLineSno = line.commonDetails.sNo!;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: widget.configPvd.selectedLineSno == line.commonDetails.sNo! ? const Color(0xff1C863F) : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(line.commonDetails.name!.toString(),style: TextStyle(color: widget.configPvd.selectedLineSno == line.commonDetails.sNo! ? Colors.white : Colors.black, fontSize: 13),),

                ),
              ),
              const SizedBox(width: 10,)
            ]
        ],
      ),
    );
  }

  Widget diagramWidget(IrrigationLineModel selectedIrrigationLine){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1700,
        child: getSuitableSourceConnection(selectedIrrigationLine),
      ),
    );
  }

  Widget getLineParameter({
    required IrrigationLineModel line,
    required List<double> currentParameterValue,
    required LineParameter parameterType,
    required int objectId,
    required String objectName,
    required bool validateAllLine,
    bool singleSelection = false,
    List<DeviceObjectModel>? listOfObject
  }){
    return InkWell(
      onTap: (){
        setState(() {
          widget.configPvd.listOfSelectedSno.clear();
          widget.configPvd.listOfSelectedSno.addAll(currentParameterValue);
          if(currentParameterValue.isNotEmpty){
            widget.configPvd.selectedSno = currentParameterValue[0];
          }
        });
        selectionDialogBox(
            context: context,
            title: 'Select $objectName',
            singleSelection: singleSelection,
            // listOfObject: mode != null ? widget.configPvd.pump.where((pump) => (mode == pump.pumpType)).toList().map((pump) => pump.commonDetails).toList() :
            listOfObject: listOfObject ??
            getUnselectedLineParameterObject(
                currentParameterList: currentParameterValue,
                objectId: objectId,
                parameter: parameterType,
              validateAllLine: validateAllLine,
            ),
            onPressed: (){
              setState(() {
                widget.configPvd.updateSelectionInLine(line.commonDetails.sNo!, parameterType);
              });
              Navigator.pop(context);
            }
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).primaryColorLight.withOpacity(0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedImage(imagePath: 'assets/Images/Png/objectId_$objectId.png'),
            const SizedBox(width: 20,),
            Text(objectName, style: AppProperties.listTileBlackBoldStyle,),
          ],
        ),
      ),
    );
  }

  List<DeviceObjectModel> getUnselectedLineParameterObject({
    required List<double> currentParameterList,
    required int objectId,
    required LineParameter parameter,
    required bool validateAllLine
  }){
    List<DeviceObjectModel> listOfObject = widget.configPvd.listOfGeneratedObject
        .where((object) => object.objectId == objectId)
        .toList();
    List<double> assigned = [];
    if(validateAllLine){
      for(var line in widget.configPvd.line){
        List<double> lineParameter = parameter == LineParameter.source
            ? line.source
            : parameter == LineParameter.sourcePump
            ? line.sourcePump
            : parameter == LineParameter.irrigationPump
            ? line.irrigationPump
            : parameter == LineParameter.valve
            ? line.valve
            : parameter == LineParameter.mainValve
            ? line.mainValve
            : parameter == LineParameter.fan
            ? line.fan
            : parameter == LineParameter.fogger
            ? line.fogger
            : parameter == LineParameter.pesticides
            ? line.pesticides
            : parameter == LineParameter.heater
            ? line.heater
            : parameter == LineParameter.screen
            ? line.screen
            : parameter == LineParameter.vent
            ? line.vent
            : parameter == LineParameter.moisture
            ? line.moisture
            : parameter == LineParameter.temperature
            ? line.temperature
            : parameter == LineParameter.soilTemperature
            ? line.soilTemperature
            : parameter == LineParameter.humidity
            ? line.humidity : line.co2;
        assigned.addAll(lineParameter);
      }
    }

    listOfObject = listOfObject
        .where((object) => (!assigned.contains(object.sNo!) || currentParameterList.contains(object.sNo))).toList();
    return listOfObject;
  }


  //Todo :: getSuitableSourceConnection
  Widget getSuitableSourceConnection(IrrigationLineModel selectedIrrigationLine){
    List<FiltrationModel> filterSite = [];
    for(var site in widget.configPvd.filtration){
      if(site.commonDetails.sNo == selectedIrrigationLine.centralFiltration){
        filterSite.add(site);
      }if(site.commonDetails.sNo == selectedIrrigationLine.localFiltration){
        filterSite.add(site);
      }
    }
    List<FertilizationModel> fertilizerSite = [];
    for(var site in widget.configPvd.fertilization){
      if(site.commonDetails.sNo == selectedIrrigationLine.centralFertilization){
        fertilizerSite.add(site);
      }if(site.commonDetails.sNo == selectedIrrigationLine.localFertilization){
        fertilizerSite.add(site);
      }
    }
    List<SourceModel> suitableSource = widget.configPvd.source
        .where(
            (source){
              print("source.sourceType :: ${source.sourceType}");
              bool sourcePumpAvailability = selectedIrrigationLine.sourcePump.any((pump) => (source.outletPump.contains(pump) || source.inletPump.contains(pump)));
              bool irrigationPumpAvailability = selectedIrrigationLine.irrigationPump.any((pump) => (source.outletPump.contains(pump) || source.inletPump.contains(pump)));
              return ((sourcePumpAvailability || irrigationPumpAvailability));
            }
    )
        .map((source) => source.copy())
        .toList();

    for(var src in suitableSource){
      src.inletPump = src.inletPump.where((pumpSno) => selectedIrrigationLine.sourcePump.contains(pumpSno) || selectedIrrigationLine.irrigationPump.contains(pumpSno)).toList();
      src.outletPump = src.outletPump.where((pumpSno) => selectedIrrigationLine.sourcePump.contains(pumpSno) || selectedIrrigationLine.irrigationPump.contains(pumpSno)).toList();
      print('source name : ${src.commonDetails.name}  ${src.sourceType}');
    }

    List<SourceModel> boreOrOthers = suitableSource.where((source) => source.outletPump.any((pumpSno) => widget.configPvd.pump.cast<PumpModel>().firstWhere((pump) => pump.commonDetails.sNo == pumpSno).pumpType == 1)).toList();
    List<SourceModel> wellSumpTank = suitableSource.where((source) => source.outletPump.any((pumpSno) => widget.configPvd.pump.cast<PumpModel>().firstWhere((pump) => pump.commonDetails.sNo == pumpSno).pumpType == 2)).toList();
    print('boreOrOthers: ${boreOrOthers.length}');
    print('wellSumpTank: ${wellSumpTank.length}');

    if(boreOrOthers.length == 1 && wellSumpTank.isEmpty){
      return oneSource(suitableSource, selectedIrrigationLine, filterSite: filterSite, fertilizerSite: fertilizerSite);
    }else if(boreOrOthers.isEmpty && wellSumpTank.length == 1){
      return oneTank(suitableSource[0],selectedIrrigationLine, inlet: false , filterSite: filterSite, fertilizerSite: fertilizerSite);
    }else if(boreOrOthers.length == 1 && wellSumpTank.length == 1){
      return oneSourceAndOneTank(boreOthers: boreOrOthers[0],sumpTankWell: wellSumpTank[0], selectedIrrigationLine: selectedIrrigationLine, filterSite: filterSite, fertilizerSite: fertilizerSite);
    }else{
      return multipleSourceAndMultipleTank(multipleSource: boreOrOthers, multipleTank: wellSumpTank, selectedIrrigationLine: selectedIrrigationLine);
    }
  }

  Widget oneSource(List<SourceModel> suitableSource, IrrigationLineModel selectedIrrigationLine,
      {
        required List<FiltrationModel> filterSite,
        required List<FertilizationModel> fertilizerSite
      }){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...oneSourceList(suitableSource[0]),
        ...filtrationAndFertilization(maxLength: 1, fertilizerSite: fertilizerSite, filterSite: filterSite)
      ],
    );
  }

  // Todo :: oneTank
  Widget oneTank(SourceModel source, IrrigationLineModel selectedIrrigationLine, {bool inlet = true, int? maxOutletPumpForTank, required List<FiltrationModel> filterSite, required List<FertilizationModel> fertilizerSite}){
    print('oneTank maxOutletPumpForTank : $maxOutletPumpForTank');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...oneTankList(source, inlet: inlet, maxOutletPumpForTank: maxOutletPumpForTank),
        if(fertilizerSite.isNotEmpty || filterSite.isNotEmpty)
          ...filtrationAndFertilization(maxLength: 1, filterSite: filterSite, fertilizerSite: fertilizerSite)
      ],
    );
  }

  Widget oneSourceAndOneTank({required SourceModel boreOthers, required SourceModel sumpTankWell, required IrrigationLineModel selectedIrrigationLine, required List<FiltrationModel> filterSite, required List<FertilizationModel> fertilizerSite}){
    print('oneSourceAndOneTank filterSite : $filterSite');
    print('oneSourceAndOneTank fertilizerSite : $fertilizerSite');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...oneSourceList(boreOthers),
        ...oneTankList(sumpTankWell),
        ...filtrationAndFertilization(maxLength: 1, filterSite: filterSite, fertilizerSite: fertilizerSite)
      ],
    );
  }

  Widget multipleSourceAndMultipleTank({
    required List<SourceModel> multipleSource,
    required List<SourceModel> multipleTank,
    required IrrigationLineModel selectedIrrigationLine
}){
    List<FiltrationModel> filterSite = [];
    for(var site in widget.configPvd.filtration){
      if(site.commonDetails.sNo == selectedIrrigationLine.centralFiltration){
        filterSite.add(site);
      }if(site.commonDetails.sNo == selectedIrrigationLine.localFiltration){
        filterSite.add(site);
      }
    }
    List<FertilizationModel> fertilizerSite = [];
    for(var site in widget.configPvd.fertilization){
      if(site.commonDetails.sNo == selectedIrrigationLine.centralFertilization){
        fertilizerSite.add(site);
      }if(site.commonDetails.sNo == selectedIrrigationLine.localFertilization){
        fertilizerSite.add(site);
      }
    }
    print('filterSite : $filterSite');
    print('fertilizerSite : $fertilizerSite');
    int maxLength = multipleSource.length > multipleTank.length ? multipleSource.length : multipleTank.length;
    int maxOutletPumpForTank = 0;
    int maxOutletPumpForSource = 0;
    for(var tank in multipleTank){
      maxOutletPumpForTank = maxOutletPumpForTank < tank.outletPump.length ? tank.outletPump.length : maxOutletPumpForTank;
    }
    for(var tank in multipleSource){
      maxOutletPumpForSource = maxOutletPumpForSource < tank.outletPump.length ? tank.outletPump.length : maxOutletPumpForSource;
    }
    print('multipleSourceAndMultipleTank maxOutletPumpForTank : $maxOutletPumpForTank');
    print('multipleSourceAndMultipleTank maxOutletPumpForSource : $maxOutletPumpForSource');
    return LayoutBuilder(builder: (context, constraint){
      if(maxOutletPumpForTank == 0 && maxOutletPumpForSource == 0){
        return Container();
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for(var src in multipleSource)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  // padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      ...oneSourceList(src, maxOutletPumpForTank: maxOutletPumpForTank, maxOutletPumpForSource: maxOutletPumpForSource)
                    ],
                  ),
                )
            ],
          ),
          if(maxOutletPumpForTank != 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for(var srcOrTank = 0;srcOrTank < maxLength;srcOrTank++)
                  SizedBox(
                  width: 8 * widget.configPvd.ratio,
                  height: 160 * widget.configPvd.ratio,
                  child: Stack(
                    children: [
                      if(srcOrTank == 0)
                        Positioned(
                            left: 0,
                            bottom: 0,
                            child: Container(
                              width: 8,
                              height: 80  * widget.configPvd.ratio,
                              decoration: const BoxDecoration(
                                  gradient: RadialGradient(
                                      radius: 2,
                                      colors: [
                                        Color(0xffC0E3EE),
                                        Color(0xff67B1C1),
                                      ]
                                  )
                              ),
                            )
                        ),
                      if(maxLength - 1 == srcOrTank)
                        Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 68,
                              decoration: const BoxDecoration(
                                  gradient: RadialGradient(
                                      radius: 3,
                                      colors: [
                                        Color(0xffC0E3EE),
                                        Color(0xff67B1C1),
                                      ]
                                  )
                              ),
                            )
                        ),
                      if(maxLength > 2 && ![0, maxLength - 1].contains(srcOrTank))
                        Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 160,
                              decoration: const BoxDecoration(
                                  gradient: RadialGradient(
                                      radius: 3,
                                      colors: [
                                        Color(0xffC0E3EE),
                                        Color(0xff67B1C1),
                                      ]
                                  )
                              ),
                            )
                        ),
                    ],
                  ),
                )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for(var tank = 0;tank < multipleTank.length;tank++)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  // padding: const EdgeInsets.symmetric(vertical: 20),
                  child: oneTank(multipleTank[tank], selectedIrrigationLine, maxOutletPumpForTank: maxOutletPumpForTank, fertilizerSite: [], filterSite: []),
                ),
            ],
          ),
          ...filtrationAndFertilization(maxLength: maxLength, fertilizerSite: fertilizerSite, filterSite: filterSite)
        ],
      );
    });
  }

  List<Widget> filtrationAndFertilization({
    required List<FertilizationModel> fertilizerSite,
    required List<FiltrationModel> filterSite,
    required int maxLength
}){
    double connectionPipeHeight = maxLength * 160;
    double connectingHeight = filterSite.isEmpty ? 198 : 400;
    return [
      if(fertilizerSite.isNotEmpty)
        SizedBox(
          width: 50,
          height: (connectionPipeHeight > connectingHeight ? connectionPipeHeight : connectingHeight) * widget.configPvd.ratio,
          child: Stack(
            children: [
              Positioned(
                top: 80 * widget.configPvd.ratio,
                child: Container(
                  width: 8 * widget.configPvd.ratio,
                  height: (maxLength == 1 ? 200 : (connectionPipeHeight - 123)) * widget.configPvd.ratio,
                  decoration: const BoxDecoration(
                      gradient: RadialGradient(
                          radius: 2,
                          colors: [
                            Color(0xffC0E3EE),
                            Color(0xff67B1C1),
                          ]
                      )
                  ),
                ),
              ),
              Positioned(
                top: 190 * widget.configPvd.ratio,
                child: Container(
                  width: 50,
                  height: 8  * widget.configPvd.ratio,
                  decoration: const BoxDecoration(
                      gradient: RadialGradient(
                          radius: 2,
                          colors: [
                            Color(0xffC0E3EE),
                            Color(0xff67B1C1),
                          ]
                      )
                  ),
                ),
              ),
              if(filterSite.isNotEmpty)
                Positioned(
                  top: 277  * widget.configPvd.ratio,
                  child: Container(
                    width: 50,
                    height: 8 * widget.configPvd.ratio,
                    decoration: const BoxDecoration(
                        gradient: RadialGradient(
                            radius: 2,
                            colors: [
                              Color(0xffC0E3EE),
                              Color(0xff67B1C1),
                            ]
                        )
                    ),
                  ),
                ),
            ],
          ),
        ),
      Stack(
        children: [
          if(fertilizerSite.isNotEmpty && filterSite.isNotEmpty)
            Positioned(
              right: 0,
              top: 98 * widget.configPvd.ratio,
              child: Container(
                width: (filterSite[0].filters.length * 150 - 50) * widget.configPvd.ratio,
                height: 7 * widget.configPvd.ratio,
                decoration: const BoxDecoration(
                    gradient: RadialGradient(
                        radius: 2,
                        colors: [
                          Color(0xffC0E3EE),
                          Color(0xff67B1C1),
                        ]
                    )
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(fertilizerSite.isNotEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(fertilizerSite[0].channel.length == 1)
                      FertilizationDashboardFormation(fertilizationFormation: FertilizationFormation.singleChannel, fertilizationSite: fertilizerSite[0]),
                    if(fertilizerSite[0].channel.length > 1)
                      FertilizationDashboardFormation(fertilizationFormation: FertilizationFormation.multipleChannel, fertilizationSite: fertilizerSite[0]),
                  ],
                ),
              if(filterSite.isNotEmpty)
                ...[
                  SizedBox(height: 80 * widget.configPvd.ratio,),
                  Row(
                    children: [
                      if(filterSite[0].filters.length == 1)
                        FiltrationDashboardFormation(filtrationFormation: FiltrationFormation.singleFilter, filtrationSite: filterSite[0]),
                      if(filterSite[0].filters.length > 1)
                        FiltrationDashboardFormation(filtrationFormation: FiltrationFormation.multipleFilter, filtrationSite: filterSite[0]),
                    ],
                  ),
                ]
            ],
          ),
          if(fertilizerSite.isNotEmpty && filterSite.isNotEmpty)
            Positioned(
              right: 0,
              bottom: 8 * widget.configPvd.ratio,
              child: Container(
                width: 8 * widget.configPvd.ratio ,
                height: 320 * widget.configPvd.ratio,
                decoration: const BoxDecoration(
                    gradient: RadialGradient(
                        radius: 2,
                        colors: [
                          Color(0xffC0E3EE),
                          Color(0xff67B1C1),
                        ]
                    )
                ),
              ),
            ),
        ],
      ),
      if(fertilizerSite.length > 1 || filterSite.length > 1)
        Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 30),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(10)
            ),
            child: FertilizationDashboardFormation(fertilizationFormation: fertilizerSite[1].channel.length == 1 ? FertilizationFormation.singleChannel : FertilizationFormation.multipleChannel, fertilizationSite: fertilizerSite[1]),
          ),
          const SizedBox(height: 20,),
          Container(
            margin: const EdgeInsets.only(left: 30),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(10)
            ),
            child: FiltrationDashboardFormation(filtrationFormation: filterSite[1].filters.length == 1 ? FiltrationFormation.singleFilter : FiltrationFormation.multipleFilter, filtrationSite: filterSite[1]) ,
          ),
        ],
      ),
    ];
  }

  // Todo :: oneSourceList
  List<Widget> oneSourceList(SourceModel source,{ int? maxOutletPumpForTank, int? maxOutletPumpForSource} ){
    print("oneSourceList maxOutletPumpForTank : $maxOutletPumpForTank");
    pumpExtendedWidth += (120 * 2);
    return [
      getSource(source,widget.configPvd , inlet: false, dashboard: true),
      if(source.outletPump.length == 1)
        Row(
          children: [
            singlePump(source, false, widget.configPvd, dashboard: true),
            if(maxOutletPumpForSource != null)
              for(var i = 0;i < (maxOutletPumpForSource - source.outletPump.length);i++)
                SizedBox(
                  width: 94,
                  height: 120 * widget.configPvd.ratio,
                  child: Stack(
                    children: [
                      Positioned(
                        bottom : 32 * widget.configPvd.ratio,
                        child: SvgPicture.asset(
                          'assets/Images/Source/backside_pipe_1.svg',
                          width: 120,
                          height: 8.5 * widget.configPvd.ratio,
                        ),
                      )
                    ],
                  ),
                )
          ],
        )
      else
        multiplePump(source, false, widget.configPvd, dashBoard: true, maxOutletPumpForTank: maxOutletPumpForTank)
    ];
  }

  List<Widget> oneTankList(SourceModel source, {bool inlet = true, int? maxOutletPumpForTank}){
    pumpExtendedWidth += 120 + (source.outletPump.length * 120);
    return [
      getSource(source, widget.configPvd, inlet: inlet),
      multiplePump(source, false, widget.configPvd, dashBoard: true, maxOutletPumpForTank: maxOutletPumpForTank),
    ];
  }

  Widget lJointPipeConnectionForPumps(){
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(-1.0, 1.0),
      child: SvgPicture.asset(
        'assets/Images/Source/pump_joint_1.svg',
        width: 120,
        height: 154,
      ),
    );
  }

  Widget getSource(SourceModel source,ConfigMakerProvider configPvd, {bool dashboard = false, bool inlet = true}){
    return Stack(
      children: [
        getTankImage(source, configPvd, dashboard: dashboard, inlet: inlet),
        Positioned(
          left : 5,
          top: 0,
          child: Text(getObjectName(source.commonDetails.sNo!, widget.configPvd).name!,style: TextStyle(fontSize: 12 * configPvd.ratio, fontWeight: FontWeight.bold),),
        ),
      ],
    );
  }
}
