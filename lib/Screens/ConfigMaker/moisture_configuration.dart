import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Constants/communication_codes.dart';
import 'package:oro_drip_irrigation/Models/Configuration/fertigation_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/moisture_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/pump_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/source_model.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/site_configure.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/source_configuration.dart';
import 'package:oro_drip_irrigation/Widgets/custom_drop_down_button.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../Constants/dialog_boxes.dart';
import '../../Constants/properties.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../Models/Configuration/filtration_model.dart';
import '../../StateManagement/config_maker_provider.dart';
import '../../Widgets/sized_image.dart';
import 'config_web_view.dart';

class MoistureConfiguration extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  const MoistureConfiguration({super.key, required this.configPvd});

  @override
  State<MoistureConfiguration> createState() => _MoistureConfigurationState();
}

class _MoistureConfigurationState extends State<MoistureConfiguration> {
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
                    for(var moistureSensor in widget.configPvd.moisture)
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
                              stepWidth: 300,
                              child: ListTile(
                                leading: SizedImage(imagePath: 'assets/Images/Png/objectId_25.png'),
                                title: Text(moistureSensor.commonDetails.name!),
                              ),
                            ),
                            // Container(
                            //   width: double.infinity,
                            //   alignment: Alignment.center,
                            //   child: Stack(
                            //     children: [
                            //       SvgPicture.asset(
                            //         'assets/Images/Source/pump_1.svg',
                            //         width: 120,
                            //         height: 120,
                            //       ),
                            //       ...getWaterMeterAndPressure(
                            //           pump.pressure,
                            //           pump.waterMeter,
                            //           widget.configPvd
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: getValve(moistureSensor: moistureSensor, valveList: moistureSensor.valves),
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

  Widget getValve({
    required MoistureModel moistureSensor,
    required List<double> valveList
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
          const SizedImage(imagePath: 'assets/Images/Png/objectId_13.png'),
          const SizedBox(width: 20,),
          const Text('Valves : ', style: AppProperties.listTileBlackBoldStyle,),
          Center(
            child: Text(valveList.isEmpty ? '-' : valveList.map((sNo) => getObjectName(sNo, widget.configPvd).name!).join(', '), style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold),),
          ),
          IconButton(
              onPressed: (){
                setState(() {
                  widget.configPvd.listOfSelectedSno.addAll(valveList);
                });
                selectionDialogBox(
                    context: context,
                    title: 'Select Valve',
                    singleSelection: false,
                    listOfObject: widget.configPvd.listOfGeneratedObject.where((object) => object.objectId == 13).toList(),
                    onPressed: (){
                      setState(() {
                        widget.configPvd.updateSelectionInMoisture(moistureSensor.commonDetails.sNo!,);
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
