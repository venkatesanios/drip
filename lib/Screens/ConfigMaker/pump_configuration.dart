import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/site_configure.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/source_configuration.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../Constants/communication_codes.dart';
import '../../Constants/dialog_boxes.dart';
import '../../Constants/properties.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../Models/Configuration/filtration_model.dart';
import '../../Models/Configuration/pump_model.dart';
import '../../StateManagement/config_maker_provider.dart';
import '../../Widgets/custom_drop_down_button.dart';
import '../../Widgets/sized_image.dart';
import 'config_web_view.dart';

class PumpConfiguration extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  const PumpConfiguration({super.key, required this.configPvd});

  @override
  State<PumpConfiguration> createState() => _PumpConfigurationState();
}

class _PumpConfigurationState extends State<PumpConfiguration> {
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
                  minItemWidth: 250,
                  shrinkWrap: true,
                  listViewBuilderOptions: ListViewBuilderOptions(
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                  children: [
                    for(var pump in widget.configPvd.pump)
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
                              stepWidth: 250,
                              child: ListTile(
                                leading: SizedImage(imagePath: 'assets/Images/Png/objectId_5.png'),
                                title: Text(pump.commonDetails.name!),
                                trailing: IntrinsicWidth(
                                  child: CustomDropDownButton(
                                      value: getPumpTypeCodeToString(pump.pumpType),
                                      list: const ['source', 'irrigation'],
                                      onChanged: (value){
                                        setState(() {
                                          pump.pumpType = getPumpTypeStringToCode(value!);
                                        });
                                      }
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  SvgPicture.asset(
                                    'assets/Images/Source/pump_1.svg',
                                    width: 120,
                                    height: 120,
                                  ),
                                  ...getWaterMeterAndPressure(
                                      pump.pressureIn,
                                      pump.waterMeter,
                                    widget.configPvd
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                spacing: 30,
                                runSpacing: 20,
                                children: [
                                  for(var mode in [1,2,3])
                                    getWaterMeterAndPressureSelection(pump, mode)
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

  Widget getWaterMeterAndPressureSelection(PumpModel currentPump, int mode){
    int objectId = mode == 1 ? 24 : mode == 2 ? 24 : 22;
    String objectName = mode == 1 ? 'PressureIn' : mode == 2 ? 'PressureOut' : 'Water Meter';
    double currentSno = mode == 1 ? currentPump.pressureIn : mode == 2 ? currentPump.pressureOut : currentPump.waterMeter;
    List<double> validateSensorFromOtherSource = [];
    for(var pump in widget.configPvd.pump){
      if(pump.commonDetails.sNo != currentPump.commonDetails.sNo){
        validateSensorFromOtherSource.add(pump.level);
        validateSensorFromOtherSource.add(pump.waterMeter);
        validateSensorFromOtherSource.add(pump.pressureIn);
        validateSensorFromOtherSource.add(pump.pressureOut);
      }else{
        validateSensorFromOtherSource.add(mode == 1 ? pump.pressureOut : pump.pressureIn);
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
          SizedImage(imagePath: 'assets/Images/Png/objectId_$objectId.png'),
          const SizedBox(width: 20,),
          Text('$objectName : ', style: AppProperties.listTileBlackBoldStyle,),
          Expanded(child: Text(currentSno == 0.0 ? '-' : getObjectName(currentSno, widget.configPvd).name!, style: const TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold,),)),
          IconButton(
              onPressed: (){
                setState(() {
                  widget.configPvd.selectedSno = currentSno;
                });
                selectionDialogBox(
                    context: context,
                    title: 'Select $objectName',
                    singleSelection: true,
                    listOfObject: widget.configPvd.listOfGeneratedObject.where((object) => (object.objectId == objectId && !validateSensorFromOtherSource.contains(object.sNo))).toList(),
                    onPressed: (){
                      setState(() {
                        if(mode == 1){
                          currentPump.pressureIn = widget.configPvd.selectedSno;
                        }else if(mode == 2){
                          currentPump.pressureOut = widget.configPvd.selectedSno;
                        }else{
                          currentPump.waterMeter = widget.configPvd.selectedSno;
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
