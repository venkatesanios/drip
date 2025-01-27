import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/constants.dart';
import 'package:oro_drip_irrigation/Models/Configuration/device_object_model.dart';
import 'package:oro_drip_irrigation/StateManagement/config_maker_provider.dart';
import 'package:provider/provider.dart';

import '../../Models/Configuration/device_model.dart';

class PayloadProcessing extends StatefulWidget {
  const PayloadProcessing({super.key});

  @override
  State<PayloadProcessing> createState() => _PayloadProcessingState();
}

class _PayloadProcessingState extends State<PayloadProcessing> {
  late Future<List<DeviceModel>> listOfDevices;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listOfDevices = context.read<ConfigMakerProvider>().fetchData();
  }
  @override
  Widget build(BuildContext context) {
    final configPvd = context.read<ConfigMakerProvider>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Payload Processing'),
            ElevatedButton(
                onPressed: () async {
                  getPumpPayload();
                  getDeviceListPayload();
                },
                child: Text('Continue')
            )
          ],
        ),
      ),
    );
  }

  String getPumpPayload() {
    final configPvd = context.read<ConfigMakerProvider>();
    List<String> pumpPayload = [];

    for (var i = 0; i < configPvd.pump.length; i++) {
      var pump = configPvd.pump[i];
      DeviceObjectModel actualPump = configPvd.listOfGeneratedObject.firstWhere((object) => object.sNo == pump.commonDetails.sNo);
      var controller = configPvd.listOfDeviceModel.firstWhere((e) => e.controllerId == actualPump.controllerId);
      var relatedSources = configPvd.source.where((e) => e.inletPump.contains(pump.commonDetails.sNo) || e.outletPump.contains(pump.commonDetails.sNo)).toList();
      var sump = configPvd.source.where((e) => ![1, 4].contains(e.sourceType));
      var tank = configPvd.source.where((e) => e.sourceType == 1);
      var irrigationLine = configPvd.line.where((line) => pump.pumpType == 1
          ? line.sourcePump.contains(pump.commonDetails.sNo)
          : line.irrigationPump.contains(pump.commonDetails.sNo)).toList();

      Map<String, dynamic> payload = {
        "S_No": pump.commonDetails.sNo, // [0]
        "PumpCategory": pump.pumpType, // [1]
        "PumpNumber": i+1, // [2]
        "WaterMeterAvailable": pump.waterMeter == 0.0 ? 0 : 1, // [3]
        "OroPumpPlus": (controller.categoryId == 2 && controller.modelId == 5) ? 1 : 0, // [4]
        "OroPump": (controller.categoryId == 2 && controller.modelId == 4) ? 1 : 0, // [5]
        "RelayCount": pump.commonDetails.connectionNo == 0.0 ? '' : pump.commonDetails.connectionNo, // [6]
        "LevelType": relatedSources.any((level) => level.level != 0.0) ? 1 : 0, // [7]
        "PressureSensorAvailable": pump.pressure == 0.0 ? 0 : 1, // [8]
        "TopTankHighAvailable": sump.any((src) => src.topFloat != 0.0) ? 1 : 0, // [9]
        "TopTankLowAvailable": sump.any((src) => src.bottomFloat != 0.0) ? 1 : 0, // [10]
        "SumpTankHighAvailable": tank.any((src) => src.topFloat != 0.0) ? 1 : 0, // [11]
        "SumpTankLowAvailable": tank.any((src) => src.bottomFloat != 0.0) ? 1 : 0, // [12]
        "IrrigationLine": irrigationLine.map((line) => line.commonDetails.sNo).join('_'), // [13]
        "WaterMeter": pump.waterMeter == 0.0 ? '' : pump.waterMeter, // [14]
        "Level": relatedSources.map((src) => src.level).join('_'), // [15]
        "PressureSensor": pump.pressure == 0.0 ? '' : pump.pressure, // [16]
        "TopTankHigh": sump.map((src) => src.topFloat).join('_'), // [17]
        "TopTankLow": sump.map((src) => src.bottomFloat).join('_'), // [18]
        "SumpTankHigh": tank.map((src) => src.topFloat).join('_'), // [19]
        "SumpTankLow": tank.map((src) => src.bottomFloat).join('_'), // [20]
        "LevelControlOnOff": 0 // [21]
      };

      pumpPayload.add(payload.entries.map((e) => e.value).join(","));
    }

    // print(pumpPayload.join(";\n"));
    return pumpPayload.join(";\n");
  }

  String getDeviceListPayload() {
    final configPvd = context.read<ConfigMakerProvider>();
    List<dynamic> devicePayload = [];
    for(var i = 0; i < configPvd.listOfDeviceModel.length; i++) {
      Map<String, dynamic> payload = {};
      var device = configPvd.listOfDeviceModel[i];
      if(configPvd.listOfDeviceModel[i].masterId != null) {
        payload = {
          "S_No" : device.serialNumber,
          "DeviceTypeNumber" : device.categoryId,
          "DeviceRunningNumber" : i+1,
          "DeviceId" : device.deviceId,
          "InterfaceType" : device.interfaceTypeId,
          "ExtendNode" : device.extendDeviceId,
        };
        devicePayload.add(payload.entries.map((e) => e.value).join(","));
      }
    }
    // print(devicePayload.join(";\n"));
    return devicePayload.join(";\n");
  }

}
