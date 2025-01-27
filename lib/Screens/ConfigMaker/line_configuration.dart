import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/Models/Configuration/irrigationLine_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/source_model.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/site_configure.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/source_configuration.dart';
import 'package:oro_drip_irrigation/StateManagement/config_maker_provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../../Constants/dialog_boxes.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../Widgets/sized_image.dart';
import 'fertilization_configuration.dart';
import 'filtration_configuration.dart';

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
        return Container(
          width: constraint.maxWidth,
          height: constraint.maxHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getLineTabs(),
              const SizedBox(height: 10,),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: AppProperties.customBoxShadow
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
                              spacing: 30,
                              children: [
                                if(availability(13))
                                  getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.sourcePump, parameterType: LineParameter.sourcePump, objectId: 13, objectName: 'Source Pump', validateAllLine: false, mode: 1),
                                if(availability(13))
                                  getLineParameter(line: selectedIrrigationLine, currentParameterValue: selectedIrrigationLine.irrigationPump, parameterType: LineParameter.irrigationPump, objectId: 13, objectName: 'Irrigation Pump', validateAllLine: false, mode: 2),
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
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        diagramWidget(),
                        const SizedBox(height: 20,),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black)
                              // color: Colors.blueGrey.shade50,
                              // boxShadow: AppProperties.customBoxShadow
                          ),
                          child: ResponsiveGridList(
                            horizontalGridMargin: 0,
                            verticalGridMargin: 10,
                            minItemWidth: 100,
                            shrinkWrap: true,
                            listViewBuilderOptions: ListViewBuilderOptions(
                              physics: const NeverScrollableScrollPhysics(),
                            ),
                            children: [
                              for(var i = 0;i < 2;i++)
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: Image.asset('assets/Images/Png/objectId_12.png'),
                                    ),
                                    Text('Main Valve ${i+1}', style: AppProperties.listTileBlackBoldStyle,)
                                  ],
                                ),
                              for(var i = 0;i < 2;i++)
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: Image.asset('assets/Images/Png/objectId_22.png'),
                                    ),
                                    Text('Water Meter ${i+1}', style: AppProperties.listTileBlackBoldStyle,)
                                  ],
                                ),
                              for(var i = 0;i < 14;i++)
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: Image.asset('assets/Images/Png/objectId_13.png'),
                                    ),
                                    Text('Valve ${i+1}', style: AppProperties.listTileBlackBoldStyle,)
                                  ],
                                )
                            ],
                          ),
                        ),
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
        );
      }),
    );
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
                      color: widget.configPvd.selectedLineSno == line.commonDetails.sNo! ? const Color(0xff1C863F) :Colors.grey.shade300,
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

  Widget diagramWidget(){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 1600,
        child: getSuitableSourceConnection(),
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
    int? mode,
  }){
    return InkWell(
      onTap: (){
        setState(() {
          widget.configPvd.listOfSelectedSno.clear();
          widget.configPvd.listOfSelectedSno.addAll(currentParameterValue);
        });
        selectionDialogBox(
            context: context,
            title: 'Select $objectName',
            singleSelection: false,
            listOfObject: mode != null ? widget.configPvd.pump.where((pump) => (mode == pump.pumpType)).toList().map((pump) => pump.commonDetails).toList() :
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
          color: Theme.of(context).primaryColorLight.withOpacity(0.1),
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
    List<double> unAssigned = [];
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

  Widget getSuitableSourceConnection(){
    List<SourceModel> boreOrOthers = widget.configPvd.source.where((source) => ([4, 5].contains(source.sourceType) || (source.sourceType == 3 && source.inletPump.isEmpty))).toList();
    List<SourceModel> wellSumpTank = widget.configPvd.source.where((source) => ![3, 4, 5].contains(source.sourceType) || (source.sourceType == 3 && source.inletPump.isNotEmpty)).toList();
    if(boreOrOthers.length == 1 && wellSumpTank.isEmpty){
      return oneSource();
    }else if(boreOrOthers.isEmpty && wellSumpTank.length == 1){
      return oneTank(widget.configPvd.source[0], inlet: false);
    }else if(boreOrOthers.length == 1 && wellSumpTank.length == 1){
      return oneSourceAndOneTank();
    }else if(boreOrOthers.length > 1 && wellSumpTank.length == 1){
      return multipleSourceAndOneTank(multipleSource: boreOrOthers, oneTankList: wellSumpTank);
    }else{
      return multipleSourceAndMultipleTank(multipleSource: boreOrOthers, multipleTank: wellSumpTank);
    }
  }

  Widget oneSource(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...oneSourceList(widget.configPvd.source[0]),
        ...filtrationAndFertilization(maxLength: 1)      ],
    );
  }

  Widget oneTank(SourceModel source, {bool inlet = true, bool fertilizerSite = true}){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...oneTankList(source, inlet: inlet),
        if(fertilizerSite)
          ...filtrationAndFertilization(maxLength: 1)
      ],
    );
  }

  Widget oneSourceAndOneTank(){
    List<SourceModel> source = widget.configPvd.source;
    SourceModel boreOthers = [4,5].contains(source[0].sourceType) ? source[0] : source[1];
    SourceModel sumpTankWell = ![4,5].contains(source[0].sourceType) ? source[0] : source[1];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...oneSourceList(boreOthers),
        ...oneTankList(sumpTankWell),
        ...filtrationAndFertilization(maxLength: 1)
      ],
    );
  }

  Widget multipleSourceAndOneTank({required List<SourceModel> multipleSource, required List<SourceModel> oneTankList}){
    return LayoutBuilder(builder: (context, constraint){
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              for(var src in multipleSource)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      ...oneSourceList(src)
                    ],
                  ),
                )
            ],
          ),
          Column(
            children: [
              for(var src = 0;src < multipleSource.length;src++)
                Container(
                  width: 8 * widget.configPvd.ratio,
                  height: 160 * widget.configPvd.ratio,
                  child: Stack(
                    children: [
                      if(src == 0)
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
                      if(multipleSource.length - 1 == src)
                        Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 109,
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
                      if(multipleSource.length > 2 && ![0, multipleSource.length - 1].contains(src))
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
          oneTank(oneTankList[0], fertilizerSite: false),
          ...filtrationAndFertilization(maxLength: 1)
        ],
      );
    });
  }

  Widget multipleSourceAndMultipleTank({
    required List<SourceModel> multipleSource,
    required List<SourceModel> multipleTank
}){
    int maxLength = multipleSource.length > multipleTank.length ? multipleSource.length : multipleTank.length;
    print('maxLength : $maxLength');
    return LayoutBuilder(builder: (context, constraint){
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              for(var src in multipleSource)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      ...oneSourceList(src)
                    ],
                  ),
                )
            ],
          ),
          Column(
            children: [
              for(var srcOrTank = 0;srcOrTank < maxLength;srcOrTank++)
                Container(
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
                              height: 60  * widget.configPvd.ratio,
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
                              height: 109,
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
            children: [
              for(var tank = 0;tank < multipleTank.length;tank++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: oneTank(multipleTank[tank], fertilizerSite: false),
                ),
            ],
          ),
          ...filtrationAndFertilization(maxLength: maxLength)
        ],
      );
    });
  }

  List<Widget> filtrationAndFertilization({
    required int maxLength
}){
    double connectionPipeHeight = maxLength * 160;
    double connectingHeight = widget.configPvd.filtration.isEmpty ? 198 : 400;
    return [
      if(widget.configPvd.fertilization.isNotEmpty)
        SizedBox(
          width: 50,
          height: (connectionPipeHeight > connectingHeight ? connectionPipeHeight : connectingHeight) * widget.configPvd.ratio,
          child: Stack(
            children: [
              Positioned(
                top: (maxLength == 1 ? 80 : 100) * widget.configPvd.ratio,
                child: Container(
                  width: 8 * widget.configPvd.ratio ,
                  height: (maxLength == 1 ? 200 : (connectionPipeHeight - 135)) * widget.configPvd.ratio,
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
              if(widget.configPvd.filtration.isNotEmpty)
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
          if(widget.configPvd.fertilization.isNotEmpty && widget.configPvd.filtration.isNotEmpty)
            Positioned(
            right: 0,
            top: 98 * widget.configPvd.ratio,
            child: Container(
              width: (widget.configPvd.filtration[0].filters.length * 150 - 50) * widget.configPvd.ratio,
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
              if(widget.configPvd.fertilization.isNotEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if(widget.configPvd.fertilization[0].channel.length == 1)
                      FertilizationDashboardFormation(fertilizationFormation: FertilizationFormation.singleChannel, fertilizationSite: widget.configPvd.fertilization[0]),
                    if(widget.configPvd.fertilization[0].channel.length > 1)
                      FertilizationDashboardFormation(fertilizationFormation: FertilizationFormation.multipleChannel, fertilizationSite: widget.configPvd.fertilization[0]),
                  ],
                ),
              if(widget.configPvd.filtration.isNotEmpty)
                ...[
                  SizedBox(height: 80 * widget.configPvd.ratio,),
                  Row(
                    children: [
                      if(widget.configPvd.filtration[0].filters.length == 1)
                        FiltrationDashboardFormation(filtrationFormation: FiltrationFormation.singleFilter, filtrationSite: widget.configPvd.filtration[0]),
                      if(widget.configPvd.filtration[0].filters.length > 1)
                        FiltrationDashboardFormation(filtrationFormation: FiltrationFormation.multipleFilter, filtrationSite: widget.configPvd.filtration[0]),
                    ],
                  ),
                ]
            ],
          ),
          if(widget.configPvd.fertilization.isNotEmpty && widget.configPvd.filtration.isNotEmpty)
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
    ];
  }

  List<Widget> oneSourceList(SourceModel source, ){
    pumpExtendedWidth += (120 * 2);
    return [
      getSource(source,widget.configPvd , inlet: false,dashboard: true),
      if(source.outletPump.length == 1)
        singlePump(source, false, widget.configPvd, dashboard: true)
      else
        multiplePump(source, false, widget.configPvd, dashBoard: true)
    ];
  }

  List<Widget> oneTankList(SourceModel source, {bool inlet = true}){
    pumpExtendedWidth += 120 + (source.outletPump.length * 120);
    return [
      getSource(source, widget.configPvd, inlet: inlet),
      multiplePump(source, false, widget.configPvd, dashBoard: true),
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
