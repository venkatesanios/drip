import 'dart:convert';
import 'package:oro_drip_irrigation/Constants/mqtt_manager_mobile.dart' if (dart.library.html) 'package:oro_drip_irrigation/Constants/mqtt_manager_web.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/theme.dart';
import 'package:oro_drip_irrigation/StateManagement/config_maker_provider.dart';
import 'package:oro_drip_irrigation/StateManagement/mqtt_payload_provider.dart';
import 'package:provider/provider.dart';
import 'Constants/constants.dart';
import 'Constants/env_setup.dart';
import 'Constants/sample_data.dart';
import 'Screens/ConfigMaker/config_base_page.dart';
import 'Screens/ConfigMaker/payload_proccessing.dart';
import 'Screens/ConfigMaker/config_web_view.dart';
import 'Screens/NewIrrigationProgram/irrigation_program_main.dart';
import 'Screens/NewIrrigationProgram/program_library.dart';
import 'StateManagement/irrigation_program_provider.dart';
import 'StateManagement/overall_use.dart';

void main() {
  GlobalConfig.setEnvironment(Environment.development);
  MqttManager mqttManager = MqttManager();
  // print(payloadConversion());
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConfigMakerProvider()),
          ChangeNotifierProvider(create: (_) => IrrigationProgramMainProvider()),
          ChangeNotifierProvider(create: (_) => MqttPayloadProvider()),
          ChangeNotifierProvider(create: (_) => OverAllUse()),
          // Provider<Logger>(
          //   create: (_) => GlobalConfig.getService<Logger>(),
          // ),
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppThemes.lightTheme,
      home: const ProgramLibraryScreenNew(userId: 4, controllerId: 1, deviceId: '', fromDealer: false),
    );
  }
}

