import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/dialog_boxes.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/connection.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/product_limit.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/site_configure.dart';
import 'package:provider/provider.dart';
import '../../Constants/properties.dart';
import '../../Models/Configuration/device_model.dart';
import '../../Models/Configuration/device_object_model.dart';
import '../../StateManagement/config_maker_provider.dart';
import '../../Widgets/custom_side_tab.dart';
import '../../Widgets/title_with_back_button.dart';
import 'config_base_page.dart';
import 'config_mobile_view.dart';
import 'device_list.dart';
import 'dart:html';


void saveToSessionStorage(String key, String value) {
  window.sessionStorage[key] = value;
}

String? readFromSessionStorage(String key) {
  return window.sessionStorage[key];
}

void deleteFromSessionStorage(String key) {
  window.sessionStorage.remove(key);
}

class ConfigWebView extends StatefulWidget {
  List<DeviceModel> listOfDevices;
  ConfigWebView({super.key, required this.listOfDevices});

  @override
  State<ConfigWebView> createState() => _ConfigWebViewState();
}

class _ConfigWebViewState extends State<ConfigWebView> {
  late ConfigMakerProvider configPvd;
  late Future<List<DeviceModel>> listOfDevices;
  double sideNavigationRatio = 0.15;
  double sideNavigationWidth = 220;
  double sideNavigationBreakPointWidth = 60;
  double sideNavigationTabWidth = 200;
  double sideNavigationTabBreakPointWidth = 50;
  double sideNavigationTabRatio = 0.07;
  double webBreakPoint = 1000;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Material(
      child: Row(
        children: [
          sideNavigationWidget(screenWidth, screenHeight),
          Expanded(
              child: configPvd.selectedTab == ConfigMakerTabs.deviceList
                  ? DeviceList(listOfDevices: widget.listOfDevices)
                  : configPvd.selectedTab == ConfigMakerTabs.productLimit
                  ? ProductLimit(listOfDevices: widget.listOfDevices,configPvd: configPvd,)
                  : configPvd.selectedTab == ConfigMakerTabs.connection
                  ? Connection(configPvd: configPvd,) : SiteConfigure(configPvd: configPvd)
          ),
        ],
      ),
    );
  }

  Widget sideNavigationWidget(screenWidth, screenHeight){
    return Container(
      width: screenWidth  > webBreakPoint ? sideNavigationWidth : sideNavigationBreakPointWidth,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ]
          )
      ),
      height: screenHeight,
      child: Column(
        children: [
          TitleWithBackButton(
            onPressed: (){

            },
            title: 'Config Maker',

            // titleWidth: screenWidth * sideNavigationTabRatio,
            titleWidth: sideNavigationTabWidth,
          ),
          const SizedBox(height: 50,),
          ...getSideNavigationTab(screenWidth)

        ],
      ),
    );
  }

  List<Widget> getSideNavigationTab(screenWidth){
    return [
      for(var i in ConfigMakerTabs.values)
        CustomSideTab(
          width: screenWidth  > webBreakPoint ? sideNavigationTabWidth : sideNavigationTabBreakPointWidth,
          imagePath: 'assets/Images/Png/${getTabImage(i)}${i == configPvd.selectedTab ? 1 : 0}.png',
          title: getTabName(i),
          selected: i == configPvd.selectedTab,
          onTap: (){
            updateConfigMakerTabs(
                context: context,
                configPvd: configPvd,
                setState: setState,
                selectedTab: i
            );
          },
        )
    ];
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
