import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:oro_drip_irrigation/Constants/communication_codes.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/config_web_view.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/device_list.dart';
import 'package:oro_drip_irrigation/Screens/ConfigMaker/config_mobile_view.dart';
import 'package:oro_drip_irrigation/Widgets/custom_buttons.dart';
import 'package:oro_drip_irrigation/Widgets/custom_drop_down_button.dart';
import 'package:oro_drip_irrigation/Widgets/custom_side_tab.dart';
import 'package:oro_drip_irrigation/Widgets/custom_table.dart';
import 'package:oro_drip_irrigation/Widgets/sized_image.dart';
import 'package:oro_drip_irrigation/Widgets/title_with_back_button.dart';
import 'package:provider/provider.dart';

import '../../Constants/properties.dart';
import '../../Models/Configuration/device_model.dart';
import '../../StateManagement/config_maker_provider.dart';


enum ConfigMakerTabs {deviceList, productLimit, connection, siteConfigure}


class ConfigBasePage extends StatefulWidget {
  const ConfigBasePage({super.key});

  @override
  State<ConfigBasePage> createState() => _ConfigBasePageState();
}

class _ConfigBasePageState extends State<ConfigBasePage> {
  late ConfigMakerProvider configPvd;
  late Future<List<DeviceModel>> listOfDevices;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
    listOfDevices = configPvd.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: true);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder<List<DeviceModel>>(
      future: listOfDevices,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Loading state
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Error state
        } else if (snapshot.hasData) {
          List<DeviceModel> listOfDevices = snapshot.data!;
          return screenWidth > 500 ? Material(
            child: ConfigWebView(listOfDevices: listOfDevices),
          ) : ConfigMobileView(listOfDevices: listOfDevices,);
        } else {
          return Text('No data'); // Shouldn't reach here normally
        }
      },
    );
  }
}
String getTabName(ConfigMakerTabs configMakerTabs) {
  switch (configMakerTabs) {
    case ConfigMakerTabs.deviceList:
      return 'Device List';
    case ConfigMakerTabs.productLimit:
      return 'Product Limit';
    case ConfigMakerTabs.connection:
      return 'Connection';
    case ConfigMakerTabs.siteConfigure:
      return 'Site Configure';
    default:
      throw ArgumentError('Invalid ConfigMakerTabs value: $configMakerTabs');
  }
}
