import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Models/Configuration/irrigationLine_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/moisture_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/pump_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/source_model.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/site_configure.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../Constants/communication_codes.dart';
import '../../Constants/dialog_boxes.dart';
import '../../Constants/properties.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../Models/Configuration/fertigation_model.dart';
import '../../Models/Configuration/filtration_model.dart';
import '../../StateManagement/config_maker_provider.dart';
import '../../Widgets/custom_drop_down_button.dart';
import '../../Widgets/sized_image.dart';
import 'config_web_view.dart';

class FertilizationConfiguration extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  const FertilizationConfiguration({super.key, required this.configPvd});

  @override
  State<FertilizationConfiguration> createState() => _FertilizationConfigurationState();
}

class _FertilizationConfigurationState extends State<FertilizationConfiguration> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(builder: (context, constraint){
        return SizedBox(
          width: constraint.maxWidth,
          height: constraint.maxHeight,
          child:  SingleChildScrollView(
            child: Column(
              children: [
                ResponsiveGridList(
                  horizontalGridMargin: 0,
                  verticalGridMargin: 10,
                  minItemWidth: 500,
                  shrinkWrap: true,
                  listViewBuilderOptions: ListViewBuilderOptions(
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  children: [
                    for(var fertilizationSite in widget.configPvd.fertilization)
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: AppProperties.customBoxShadow
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntrinsicWidth(
                              stepWidth: 200,
                              child: ListTile(
                                leading: const SizedImage(imagePath: 'assets/Images/Png/objectId_3.png'),
                                title: Text(fertilizationSite.commonDetails.name!),
                                trailing: IntrinsicWidth(
                                  child: CustomDropDownButton(
                                      value: getCentralLocalCodeToString(fertilizationSite.siteMode),
                                      list: const ['Central', 'Local'],
                                      onChanged: (value){
                                        setState(() {
                                          fertilizationSite.siteMode = getCentralLocalStringToCode(value!);
                                        });
                                      }
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              height: 250 * widget.configPvd.ratio,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if(fertilizationSite.channel.length == 1)
                                      FertilizationDashboardFormation(fertilizationFormation: FertilizationFormation.singleChannel, fertilizationSite: fertilizationSite),
                                    if(fertilizationSite.channel.length > 1)
                                      FertilizationDashboardFormation(fertilizationFormation: FertilizationFormation.multipleChannel, fertilizationSite: fertilizationSite),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                spacing: 30,
                                runSpacing: 20,
                                children: [
                                  getFertilizerParameter(fertilizationSite: fertilizationSite, currentParameterValue: fertilizationSite.channel, parameterType: 1, objectId: 10, objectName: 'Channel'),
                                  getFertilizerParameter(fertilizationSite: fertilizationSite, currentParameterValue: fertilizationSite.boosterPump, parameterType: 2, objectId: 7, objectName: 'Booster'),
                                  getFertilizerParameter(fertilizationSite: fertilizationSite, currentParameterValue: fertilizationSite.agitator, parameterType: 3, objectId: 9, objectName: 'Agitator'),
                                  getFertilizerParameter(fertilizationSite: fertilizationSite, currentParameterValue: fertilizationSite.selector, parameterType: 4, objectId: 8, objectName: 'Selector'),
                                  getFertilizerParameter(fertilizationSite: fertilizationSite, currentParameterValue: fertilizationSite.ec, parameterType: 5, objectId: 27, objectName: 'Ec'),
                                  getFertilizerParameter(fertilizationSite: fertilizationSite, currentParameterValue: fertilizationSite.ph, parameterType: 6, objectId: 28, objectName: 'Ph'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: (){
                          var listOfDeviceModel = widget.configPvd.listOfDeviceModel.map((object){
                            return object.toJson();
                          }).toList();
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
                          // print('listOfGeneratedObject :: ${jsonEncode(listOfGeneratedObject)}');
                          // print('filtration :: ${jsonEncode(filtration)}');
                          // print('fertilization :: ${jsonEncode(fertilization)}');
                          // print('source :: ${jsonEncode(source)}');
                          // print('pump :: ${jsonEncode(pump)}');
                          // print('moisture :: ${jsonEncode(moisture)}');
                          String data = jsonEncode({
                            'listOfDeviceModel' : listOfDeviceModel,
                            'listOfSampleObjectModel' : listOfSampleObjectModel,
                            'listOfObjectModelConnection' : listOfObjectModelConnection,
                            'listOfGeneratedObject' : listOfGeneratedObject,
                            'filterSite' : filtration,
                            'fertilizerSite' : fertilization,
                            'waterSource' : source,
                            'pump' : pump,
                            'moistureSensor' : moisture,
                            'irrigationLine' : line,
                          });
                          print('data : $data');
                          saveToSessionStorage('configData',data);
                        },
                        child: const Text('Store')
                    ),
                    ElevatedButton(
                        onPressed: (){
                          String dataFromSession = readFromSessionStorage('configData')!;
                          print('dataFromSession :: $dataFromSession');
                        },
                        child: const Text('Read')
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget getFertilizerParameter({
    required FertilizationModel fertilizationSite,
    required List<double> currentParameterValue,
    required int parameterType,
    required int objectId,
    required String objectName,
}){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).primaryColorLight.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedImage(imagePath: 'assets/Images/Png/objectId_$objectId.png'),
          const SizedBox(width: 20,),
          Text('$objectName : ', style: AppProperties.listTileBlackBoldStyle,),
          Center(
            child: Text(currentParameterValue.isEmpty ? '-' : currentParameterValue.map((sNo) => getObjectName(sNo, widget.configPvd).name!).join(', '), style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold),),
          ),
          IconButton(
              onPressed: (){
                setState(() {
                  widget.configPvd.listOfSelectedSno.addAll(currentParameterValue);
                });
                selectionDialogBox(
                    context: context,
                    title: 'Select $objectName',
                    singleSelection: false,
                    listOfObject: getUnselectedFertilizationParameterObject(
                        currentParameterList: currentParameterValue,
                        objectId: objectId,
                        parameter: parameterType
                    ),
                    onPressed: (){
                      setState(() {
                        widget.configPvd.updateSelectionInFertilization(fertilizationSite.commonDetails.sNo!, parameterType);
                      });
                      Navigator.pop(context);
                    }
                );
              },
              icon: Icon(Icons.touch_app, color: Theme.of(context).primaryColor, size: 20,)
          )
        ],
      ),
    );
  }

  List<DeviceObjectModel> getUnselectedFertilizationParameterObject({
    required List<double> currentParameterList,
    required int objectId,
    required int parameter
  }){
    List<DeviceObjectModel> listOfObject = widget.configPvd.listOfGeneratedObject
        .where((object) => object.objectId == objectId)
        .toList();
    List<double> assigned = [];
    List<double> unAssigned = [];
    for(var site in widget.configPvd.fertilization){
      List<double> siteParameter = parameter == 1
          ? site.channel
          : parameter == 2
          ? site.boosterPump
          : parameter == 3
          ? site.agitator
          : parameter == 4
          ? site.selector
          : parameter == 5
          ? site.ec : site.ph;
      assigned.addAll(siteParameter);
    }
    listOfObject = listOfObject
          .where((object) => (!assigned.contains(object.sNo!) || currentParameterList.contains(object.sNo))).toList();
    return listOfObject;
  }



}





Widget getImageWithText(String title, String imagePath, ConfigMakerProvider configPvd){
  return IntrinsicWidth(
    stepWidth: 150 * configPvd.ratio,
    child: ListTile(
      title: Text(title),
      leading: SizedImage(imagePath: imagePath),
    ),
  );
}

enum FertilizationFormation {singleChannel, multipleChannel}

class FertilizationDashboardFormation extends StatefulWidget {
  FertilizationFormation fertilizationFormation;
  FertilizationModel fertilizationSite;
  FertilizationDashboardFormation({
    super.key,
    required this.fertilizationFormation,
    required this.fertilizationSite,
  });
  @override
  State<FertilizationDashboardFormation> createState() => _FertilizationDashboardFormationState();
}

class _FertilizationDashboardFormationState extends State<FertilizationDashboardFormation> {
  late ConfigMakerProvider configPvd;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    if(widget.fertilizationFormation == FertilizationFormation.singleChannel){
      return getSingleChannel();
    }else{
      return getMultipleChannel();
    }
  }
  Widget getSingleChannel(){
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                ...getAgitator(),
                if(widget.fertilizationSite.agitator.isNotEmpty)
                  SvgPicture.asset(
                    'assets/Images/Fertilization/agitator_connection_pipe_last_1.svg',
                    width: 151,
                    height: 45 * configPvd.ratio,
                  ),
              ],
            ),
            Row(
              children: [
                ...getBooster(),
                SvgPicture.asset(
                  'assets/Images/Fertilization/single_channel_1.svg',
                  width: 150,
                  height: 150 * configPvd.ratio,
                ),
              ],
            ),
          ],
        ),
        getEcPhSelector()
      ],
    );
  }
  List<Widget> getAgitator(){
    return [
      if(widget.fertilizationSite.agitator.isNotEmpty || widget.fertilizationSite.boosterPump.isNotEmpty)
        SvgPicture.asset(
          (widget.fertilizationSite.agitator.isNotEmpty) ? 'assets/Images/Fertilization/agitator_1.svg' : '',
          width: 150,
          height: 47 * configPvd.ratio,
        ),
    ];
  }
  List<Widget> getBooster(){
    return [
      if(widget.fertilizationSite.boosterPump.isNotEmpty || widget.fertilizationSite.agitator.isNotEmpty)
        Stack(
          children: [
            SvgPicture.asset(
              (widget.fertilizationSite.boosterPump.isNotEmpty) ? 'assets/Images/Fertilization/booster_1.svg' : '',
              width: 150,
              height: 150 * configPvd.ratio,
            ),
            Positioned(
              left: 0,
              bottom: 50,
              child: Text(widget.fertilizationSite.boosterPump.map((sNo) => getObjectName(sNo, configPvd).name!).join(', '), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),),
            )
          ],
        ),
    ];
  }
  Widget getEcPhSelector(){
    return Column(
      children: [
        if(widget.fertilizationSite.selector.isNotEmpty)
          getImageWithText('Selector', 'assets/Images/Png/objectId_8.png', configPvd),
        if(widget.fertilizationSite.ec.isNotEmpty)
          getImageWithText('Ec', 'assets/Images/Png/objectId_27.png', configPvd),
        if(widget.fertilizationSite.ph.isNotEmpty)
          getImageWithText('Ph', 'assets/Images/Png/objectId_28.png', configPvd),
      ],
    );
  }
  Widget getMultipleChannel(){
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...getAgitator(),
                if(widget.fertilizationSite.agitator.isNotEmpty)
                  ...[
                    if(widget.fertilizationSite.channel.length > 1)
                      for(var middle = 0;middle < widget.fertilizationSite.channel.length- 1;middle++)
                        SvgPicture.asset(
                          'assets/Images/Fertilization/agitator_connection_pipe_first_1.svg',
                          width: 151,
                          height: 45 * configPvd.ratio,
                        ),
                    SvgPicture.asset(
                      'assets/Images/Fertilization/agitator_connection_pipe_last_1.svg',
                      width: 151,
                      height: 45* configPvd.ratio,
                    ),
                  ]
              ],
            ),
            Row(
              children: [
                ...getBooster(),
                SvgPicture.asset(
                  'assets/Images/Fertilization/multiple_channel_first_1.svg',
                  width: 150,
                  height: 150 * configPvd.ratio,
                ),
                if(widget.fertilizationSite.channel.length > 2)
                  for(var middle = 1;middle < widget.fertilizationSite.channel.length- 1;middle++)
                    SvgPicture.asset(
                      'assets/Images/Fertilization/multiple_channel_middle_1.svg',
                      width: 150,
                      height: 150 * configPvd.ratio,
                    ),
                SvgPicture.asset(
                  'assets/Images/Fertilization/multiple_channel_last_1.svg',
                  width: 150,
                  height: 150 * configPvd.ratio,
                ),
              ],
            ),
          ],
        ),
        getEcPhSelector()
      ],
    );
  }
}

