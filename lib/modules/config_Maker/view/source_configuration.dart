import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/modules/config_Maker/view/site_configure.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../../Constants/communication_codes.dart';
import '../../../Constants/dialog_boxes.dart';
import '../../../Constants/properties.dart';
import '../model/device_object_model.dart';
import '../model/filtration_model.dart';
import '../model/source_model.dart';
import '../state_management/config_maker_provider.dart';
import '../../../Widgets/custom_drop_down_button.dart';
import '../../../Widgets/sized_image.dart';
import '../../../utils/constants.dart';
import 'config_web_view.dart';

class SourceConfiguration extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  const SourceConfiguration({super.key, required this.configPvd});

  @override
  State<SourceConfiguration> createState() => _SourceConfigurationState();
}

class _SourceConfigurationState extends State<SourceConfiguration> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(builder: (context, constraint){
        double ratio = constraint.maxWidth < 500 ? 0.6 : 1.0;
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
                    for(var source in widget.configPvd.source)
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            boxShadow: AppProperties.customBoxShadowLiteTheme
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntrinsicWidth(
                              stepWidth: 250,
                              child: ListTile(
                                leading: SizedImage(imagePath: '${AppConstants.svgObjectPath}objectId_1.svg', color: Colors.black,),
                                title: Text(source.commonDetails.name!),
                                trailing: IntrinsicWidth(
                                  child: CustomDropDownButton(
                                      value: getTankCodeToString(source.sourceType),
                                      list: const ['Tank', 'Sump', 'Well', 'Bore', 'Others'],
                                      onChanged: (value){
                                        setState(() {
                                          source.sourceType = getTankStringToCode(value!);
                                          if([4, 5].contains(source.sourceType)){
                                            source.inletPump.clear();
                                            source.level = 0.0;
                                            source.topFloat = 0.0;
                                            source.bottomFloat = 0.0;
                                          }
                                        });
                                      }
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 200,
                              alignment: Alignment.center,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    if(source.inletPump.isNotEmpty)
                                      ...[
                                        if(source.inletPump.length == 1)
                                          singlePump(source, true, widget.configPvd)
                                        else
                                          multiplePump(source, true, widget.configPvd)
                                      ],
                                    Stack(
                                      children: [
                                        getTankImage(source, widget.configPvd),
                                        Positioned(
                                          left : 5,
                                          top: 0,
                                          child: Text(getObjectName(source.commonDetails.sNo!, widget.configPvd).name!,style: AppProperties.listTileBlackBoldStyle,),
                                        ),
                                      ],
                                    ),
                                    if(source.outletPump.isNotEmpty)
                                      ...[
                                        if(source.outletPump.length == 1)
                                          singlePump(source, false, widget.configPvd)
                                        else
                                          multiplePump(source, false, widget.configPvd)
                                      ],
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
                                  for(var pumpMode in [1,2])
                                    ...[
                                      if(pumpMode == 1 && ![4,5].contains(source.sourceType))
                                        getPumpSelection(source, pumpMode),
                                      if(pumpMode == 2)
                                        getPumpSelection(source, pumpMode),
                                    ],
                                  if(![4,5].contains(source.sourceType))
                                    for(var mode in [1,2,3])
                                      getLevelAndFloatSelection(source, mode)
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),

        );
      }),
    );
  }

  Widget getPumpSelection(SourceModel source, int pumpMode){
    List<double> currentParameter = pumpMode == 1 ? source.inletPump : source.outletPump;
    List<double> checkingParameter = pumpMode == 1 ? source.outletPump : source.inletPump;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).primaryColorLight.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedImage(imagePath: '${AppConstants.svgObjectPath}objectId_5.svg', color: Colors.black,),
          const SizedBox(width: 20,),
          Text('${pumpMode == 1 ? 'Inlet' : 'Outlet'} Pump : ', style: AppProperties.listTileBlackBoldStyle,),
          Center(
            child: Text(currentParameter.isEmpty ? '-' : currentParameter.map((sNo) => getObjectName(sNo, widget.configPvd).name!).join(', '), style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold),),
          ),
          IconButton(
              onPressed: (){
                setState(() {
                  widget.configPvd.listOfSelectedSno.addAll(currentParameter);
                });
                selectionDialogBox(
                    context: context,
                    title: 'Select ${pumpMode == 1 ? 'Inlet' : 'Outlet'} Pump',
                    singleSelection: false,
                    listOfObject: widget.configPvd.listOfGeneratedObject.where((object) => (object.objectId == 5 && !checkingParameter.contains(object.sNo))).toList(),
                    onPressed: (){
                      setState(() {
                        if(pumpMode == 1){
                          source.inletPump.clear();
                          source.inletPump.addAll(widget.configPvd.listOfSelectedSno);
                        }else{
                          source.outletPump.clear();
                          source.outletPump.addAll(widget.configPvd.listOfSelectedSno);
                        }
                        widget.configPvd.listOfSelectedSno.clear();
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

  Widget getLevelAndFloatSelection(SourceModel source, int mode){
    int objectId = mode == 1 ? 26 : 40;
    String objectName = mode == 1 ? 'Level' : mode == 2 ? 'Top Float' : 'Bottom Float';
    double currentSno = mode == 1 ? source.level : mode == 2 ? source.topFloat : source.bottomFloat;
    double checkingParameter = mode == 1 ? 0.0 : mode == 2 ? source.bottomFloat : source.topFloat;
    List<double> validateSensorFromOtherSource = [];
    for(var src in widget.configPvd.source){
      if(src.commonDetails.sNo != source.commonDetails.sNo){
        validateSensorFromOtherSource.add(src.level);
        validateSensorFromOtherSource.add(src.topFloat);
        validateSensorFromOtherSource.add(src.bottomFloat);
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).primaryColorLight.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedImage(imagePath: '${AppConstants.svgObjectPath}objectId_$objectId.svg', color: Colors.black,),
          const SizedBox(width: 20,),
          Text('$objectName : ', style: AppProperties.listTileBlackBoldStyle,),
          Center(
            child: Text(currentSno == 0.0 ? '-' : getObjectName(currentSno, widget.configPvd).name!, style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold),),
          ),
          IconButton(
              onPressed: (){
                setState(() {
                  widget.configPvd.selectedSno = currentSno;
                });
                selectionDialogBox(
                    context: context,
                    title: 'Select $objectName',
                    singleSelection: true,
                    listOfObject: widget.configPvd.listOfGeneratedObject.where((object) => (object.objectId == objectId && checkingParameter!= object.sNo && !validateSensorFromOtherSource.contains(object.sNo))).toList(),
                    onPressed: (){
                      setState(() {
                        if(mode == 1){
                          source.level = widget.configPvd.selectedSno;
                        }else if(mode == 2){
                          source.topFloat = widget.configPvd.selectedSno;
                        }else{
                          source.bottomFloat = widget.configPvd.selectedSno;
                        }
                        widget.configPvd.selectedSno = 0.0;
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

}

List<Widget> getWaterMeterAndPressure(double pressureInSno, double waterMeterSno, ConfigMakerProvider configPvd){
  return [
    if(pressureInSno != 0.0)
      Positioned(
        right: 0,
        top: 15 * configPvd.ratio,
        child: Image.asset(
            'assets/Images/Png/objectId_24.png',
          width: 30,
          height: 30,
        ),
        // child: SvgPicture.asset(
        //   '${AppConstants.svgObjectPath}objectId_24.svg',
        //   width: 30,
        //   height: 30 * configPvd.ratio,
        //   color: Colors.red,
        // ),
      ),
    if(waterMeterSno != 0.0)
      Positioned(
      right: 0,
      top: 50 * configPvd.ratio,
        child: Image.asset(
          'assets/Images/Png/objectId_22.png',
          width: 30,
          height: 30,
        ),
      // child: SvgPicture.asset(
      //   '${AppConstants.svgObjectPath}objectId_22.svg',
      //   width: 25,
      //   height: 25 * configPvd.ratio,
      //   color: Colors.blue,
      // ),
    ),
  ];
}

Widget singlePump(SourceModel source, bool fillingPump, ConfigMakerProvider configPvd, {bool dashboard = false}){
  List<double> currentParameter = fillingPump ? source.inletPump : source.outletPump;
  return Stack(
    children: [
      Positioned(
        left : fillingPump ? 40 : null,
        right : (!fillingPump && dashboard) ? 0 : (!fillingPump) ? 40 : null,
        bottom: 32 * configPvd.ratio,
        child: SvgPicture.asset(
          'assets/Images/Source/backside_pipe_1.svg',
          width: 120 ,
          height: 8.5 * configPvd.ratio,
        ),
      ),
      SvgPicture.asset(
        'assets/Images/Source/pump_1.svg',
        width: 120,
        height: 120 * configPvd.ratio,
      ),
      ...getWaterMeterAndPressure(
          configPvd.pump.firstWhere((pump) => pump.commonDetails.sNo == currentParameter[0]).pressureIn,
          configPvd.pump.firstWhere((pump) => pump.commonDetails.sNo == currentParameter[0]).waterMeter,
        configPvd
      ),
      Positioned(
        left : 5,
        top: 0,
        child: Text(getObjectName(currentParameter[0], configPvd).name!,style: TextStyle(fontSize: 12 * configPvd.ratio, fontWeight: FontWeight.bold),),
      )
    ],
  );
}

Widget multiplePump(SourceModel source, bool fillingPump, ConfigMakerProvider configPvd,
    {bool dashBoard = false, int? maxOutletPumpForTank}){
  List<double> currentParameter = fillingPump ? source.inletPump : source.outletPump;
  print('multiplePump maxOutletPumpForTank :: $maxOutletPumpForTank');
  return Row(
    children: [
      for(var i = 0;i < currentParameter.length;i++)
        Stack(
          children: [
            Positioned(
              left: fillingPump ? (i == 0 ? 50 : null) : null,
              right: (!fillingPump && i == currentParameter.length -1 && !dashBoard) ? 40 : null,
              bottom: 32 * configPvd.ratio,
              child: SvgPicture.asset(
                'assets/Images/Source/backside_pipe_1.svg',
                width: 120,
                height: 8.5 * configPvd.ratio,
              ),
            ),
            SvgPicture.asset(
              'assets/Images/Source/pump_1.svg',
              width: 120,
              height: 120 * configPvd.ratio,
            ),
            ...getWaterMeterAndPressure(
                configPvd.pump.firstWhere((pump) => pump.commonDetails.sNo == currentParameter[i]).pressureIn,
                configPvd.pump.firstWhere((pump) => pump.commonDetails.sNo == currentParameter[i]).waterMeter,
              configPvd
            ),
            if(currentParameter.length > 1)
              Positioned(
              right: i == 0 ? 0 : null,
              left: i == 1 ? 0 : null,
              bottom: 16 * configPvd.ratio,
              child: SvgPicture.asset(
                'assets/Images/Source/${
                    i == 0
                        ? 'front_corner_left_radius_pipe_1'
                        : i == (currentParameter.length - 1)
                        ? 'front_corner_right_radius_pipe_1'
                        : 'backside_pipe_1'}.svg',
                width: 120,
                height: 8.5 * configPvd.ratio,
              ),
            ),
            Positioned(
              left : 5,
              top: 0,
              child: Text(getObjectName(currentParameter[i], configPvd).name!,style: TextStyle(fontSize: 12 * configPvd.ratio, fontWeight: FontWeight.bold),),
            )
          ],
        ),
      if(maxOutletPumpForTank != null)
        for(var i = 0;i < (maxOutletPumpForTank - currentParameter.length);i++)
          SizedBox(
            width: 94,
            height: 120 * configPvd.ratio,
            child: Stack(
              children: [
                Positioned(
                  bottom : 32 * configPvd.ratio,
                  child: SvgPicture.asset(
                    'assets/Images/Source/backside_pipe_1.svg',
                    width: 120,
                    height: 8.5 * configPvd.ratio,
                  ),
                )
              ],
            ),
          )
    ],
  );
}

Widget getTankImage(SourceModel source ,ConfigMakerProvider configPvd, {bool dashboard = false, bool inlet = true,}){
  bool levelAvailable = source.level != 0.0;
  bool topFloatAvailable = source.topFloat != 0.0;
  bool bottomFloatAvailable = source.bottomFloat != 0.0;
  if(source.sourceType == 1){
    return Stack(
      children: [
        SvgPicture.asset(
          'assets/Images/Source/tank_${!inlet ? 'outlet_' : ''}1.svg',
          width: 120,
          height: 120 * configPvd.ratio,
        ),
        if(levelAvailable)
          Positioned(
            left: 52,
            bottom: 28,
            child: Container(
              width: 10,
              height: 40,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.green
                ),
              ),
            ),
          ),
        if(levelAvailable || topFloatAvailable || bottomFloatAvailable)
          Positioned(
            right: 42,
            bottom: 23,
            child: SvgPicture.asset(
              'assets/Images/Source/water_view.svg',
              width: 55,
              height: 55,
            ),
          ),
        if(topFloatAvailable)
          Positioned(
            right: 45,
            bottom: 50,
            child: SvgPicture.asset(
              'assets/Images/Source/top_float.svg',
              width: 30,
              height: 40,
            ),
          ),
        if(bottomFloatAvailable)
          Positioned(
            right: 60,
            bottom: 25,
            child: SvgPicture.asset(
              'assets/Images/Source/bottom_float.svg',
              width: 70,
              height: 70,
            ),
          )
      ],
    );
  }
  else if(source.sourceType == 2){
    return Stack(
      children: [
        SvgPicture.asset(
          'assets/Images/Source/sump_${!inlet ? 'outlet_' : ''}1.svg',
          width: 120,
          height: 120 * configPvd.ratio,
        ),
        if(levelAvailable)
          Positioned(
            left: 52,
            bottom: 35,
            child: Container(
              width: 10,
              height: 40,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.green
                ),
              ),
            ),
          ),
        if(topFloatAvailable)
          Positioned(
            right: 55,
            bottom: 55,
            child: SvgPicture.asset(
              'assets/Images/Source/top_float.svg',
              width: 30,
              height: 30,
            ),
          ),
        if(bottomFloatAvailable)
          Positioned(
            right: 70,
            bottom: 35,
            child: SvgPicture.asset(
              'assets/Images/Source/bottom_float.svg',
              width: 50,
              height: 50,
            ),
          )
      ],
    );
  }
  else if(source.sourceType == 3){
    return Stack(
      children: [
        SvgPicture.asset(
          'assets/Images/Source/well_${!inlet ? 'outlet_' : ''}1.svg',
          width: 120,
          height: 120 * configPvd.ratio,
        ),
        if(levelAvailable || topFloatAvailable || bottomFloatAvailable)
          Positioned(
            right: 47,
            bottom: 20,
            child: SvgPicture.asset(
              'assets/Images/Source/water_view.svg',
              width: 55,
              height: 55,
            ),
          ),
        if(levelAvailable)
          Positioned(
            left: 45,
            bottom: 22,
            child: Container(
              width: 10,
              height: 40,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.green
                ),
              ),
            ),
          ),
        if(topFloatAvailable)
          Positioned(
            right: 55,
            bottom: 55,
            child: SvgPicture.asset(
              'assets/Images/Source/top_float.svg',
              width: 30,
              height: 30,
            ),
          ),
        if(bottomFloatAvailable)
          Positioned(
            right: 70,
            bottom: 35,
            child: SvgPicture.asset(
              'assets/Images/Source/bottom_float.svg',
              width: 50,
              height: 50,
            ),
          )
      ],
    );
  }
  else if(source.sourceType == 4){
    return SvgPicture.asset(
      'assets/Images/Source/bore_1.svg',
      width: 120,
      height: 120* configPvd.ratio,
    );
  }else{
    return SvgPicture.asset(
      'assets/Images/Source/pond_1.svg',
      width: 120,
      height: 120* configPvd.ratio,
    );
  }
}