import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Constants/dialog_boxes.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/Models/Configuration/device_object_model.dart';
import 'package:oro_drip_irrigation/Models/Configuration/filtration_model.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/fertilization_configuration.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/filtration_configuration.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/moisture_configuration.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/pump_configuration.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/source_configuration.dart';
import 'package:oro_drip_irrigation/Widgets/custom_buttons.dart';
import 'package:oro_drip_irrigation/Widgets/custom_drop_down_button.dart';
import 'package:oro_drip_irrigation/Widgets/sized_image.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

import '../../StateManagement/config_maker_provider.dart';
import 'config_web_view.dart';
import 'line_configuration.dart';

class SiteConfigure extends StatefulWidget {
  final ConfigMakerProvider configPvd;
  const SiteConfigure({super.key, required this.configPvd});

  @override
  State<SiteConfigure> createState() => _SiteConfigureState();
}

class _SiteConfigureState extends State<SiteConfigure> {
  @override
  Widget build(BuildContext context) {
    // return FertilizationConfiguration(configPvd: widget.configPvd);
    // return FiltrationConfiguration(configPvd: widget.configPvd);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LayoutBuilder(builder: (context, constraint){
        return SizedBox(
          width: constraint.maxWidth,
          height: constraint.maxHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getConfigurationCategory(),
              Expanded(
                child: widget.configPvd.selectedConfigurationTab == 0 ?
                    SourceConfiguration(configPvd: widget.configPvd)
                    : widget.configPvd.selectedConfigurationTab == 1
                    ? PumpConfiguration(configPvd: widget.configPvd)
                    : widget.configPvd.selectedConfigurationTab == 2
                    ? FiltrationConfiguration(configPvd: widget.configPvd)
                    : widget.configPvd.selectedConfigurationTab == 3
                    ? FertilizationConfiguration(configPvd: widget.configPvd)
                    : widget.configPvd.selectedConfigurationTab == 4 
                    ? MoistureConfiguration(configPvd: widget.configPvd)
                    : LineConfiguration(configPvd: widget.configPvd)
              )
            ],
          ),
        );
      }),
    );
  }
  Widget getConfigurationCategory(){
    List<int> listOfCategory = [];
    for(var device in widget.configPvd.listOfDeviceModel){
      if(device.categoryId != 1 && device.masterId != null && !listOfCategory.contains(device.categoryId)){
        listOfCategory.add(device.categoryId);
      }
    }
    Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            for(var tab in widget.configPvd.configurationTab.entries)
              InkWell(
                onTap: (){
                  setState(() {
                    widget.configPvd.selectedConfigurationTab = tab.key;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  decoration: BoxDecoration(
                      color: widget.configPvd.selectedConfigurationTab == tab.key ? Theme.of(context).primaryColorLight : Colors.grey.shade300
                  ),
                  child: Text(tab.value, style: TextStyle(color: widget.configPvd.selectedConfigurationTab == tab.key ? Colors.white : Colors.black, fontSize: 13),),
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
}

DeviceObjectModel getObjectName(double sNo,ConfigMakerProvider configPvd){
  return configPvd.listOfGeneratedObject.firstWhere((object) => object.sNo! == sNo);
}