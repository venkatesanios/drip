import 'package:oro_drip_irrigation/Constants/mqtt_manager_mobile.dart'
if (dart.library.html) 'package:oro_drip_irrigation/Constants/mqtt_manager_web.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/ValveGroup/valve_group_screen.dart';
import 'package:oro_drip_irrigation/StateManagement/config_maker_provider.dart';
import 'package:oro_drip_irrigation/StateManagement/preference_provider.dart';
import 'package:oro_drip_irrigation/StateManagement/system_definition_provider.dart';
import 'package:oro_drip_irrigation/utils/environment.dart';
import 'package:oro_drip_irrigation/utils/network_utils.dart';
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
import 'StateManagement/mqtt_payload_provider.dart';
import 'StateManagement/overall_use.dart';
import 'app/app.dart';

void main() {
  NetworkUtils.initialize();
  // GlobalConfig.setEnvironment(Environment.development);
  // GlobalConfig.setEnvironment(Environment.development);
  MqttManager mqttManager = MqttManager();
  mqttManager.initializeMQTTClient();
  mqttManager.connect();
  // Future.delayed(Duration(seconds: 5),(){
  //   mqttManager.topicToPublishAndItsMessage('siva', 'hi from siva');
  // });
  // print(payloadConversion());
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConfigMakerProvider()),
          ChangeNotifierProvider(create: (_) => IrrigationProgramMainProvider()),
          ChangeNotifierProvider(create: (_) => MqttPayloadProvider()),
          ChangeNotifierProvider(create: (_) => OverAllUse()),
          ChangeNotifierProvider(create: (_) => PreferenceProvider()),
          ChangeNotifierProvider(create: (_) => SystemDefinitionProvider()),
          // Provider<Logger>(
          //   create: (_) => GlobalConfig.getService<Logger>(),
          // ),
        ],
        child: MyApp(),
      )
  );
}
