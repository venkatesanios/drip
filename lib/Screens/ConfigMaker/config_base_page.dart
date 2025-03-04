import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/Configuration/device_model.dart';
import '../../StateManagement/config_maker_provider.dart';
import 'config_mobile_view.dart';
import 'config_web_view.dart';


enum ConfigMakerTabs {deviceList, productLimit, connection, siteConfigure}


class ConfigBasePage extends StatefulWidget {
  final Map<String, dynamic> masterData;
  const ConfigBasePage({super.key, required this.masterData});

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
    print("widget.masterData :: ${jsonEncode(widget.masterData)}");
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
    // listOfDevices = configPvd.fetchData({"userId":3,"customerId":4,"controllerId":1,"deviceId":"2CCF674C0F8A","deviceName":"xMm","categoryId":1,"categoryName":"xMm","modelId":1,"modelName":"xMm1000_R","groupId":1,"groupName":"LK Demo","connectingObjectId":["1","2","3","4","1","2","3","4"]});
    // listOfDevices = configPvd.fetchData({"userId":3,"customerId":7,"controllerId":9,"deviceId":"GEM123456701","deviceName":"ORO GEM","categoryId":1,"categoryName":"ORO GEM","modelId":1,"modelName":"OGEMR","groupId":2,"groupName":"Kamaraj Testing Farm","connectingObjectId":["1","2","3","4","1","2","3","4"]});
    // listOfDevices = configPvd.fetchData({"userId":3,"customerId":4,"controllerId":5,"deviceId":"2CCF676089F2","deviceName":"ORO GEM","categoryId":1,"categoryName":"ORO GEM","modelId":1,"modelName":"xMm1000ROOO","groupId":1,"groupName":"Testing Site","connectingObjectId":["1","2","3","4","1","2","3","4"]});
    listOfDevices = configPvd.fetchData(widget.masterData);
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
          return const Text('No data'); // Shouldn't reach here normally
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
