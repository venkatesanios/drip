import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/app/app.dart';
import 'package:provider/provider.dart';
import 'StateManagement/config_maker_provider.dart';
import 'StateManagement/irrigation_program_provider.dart';
import 'StateManagement/preference_provider.dart';
import 'StateManagement/system_definition_provider.dart';
import 'StateManagement/mqtt_payload_provider.dart';
import 'StateManagement/overall_use.dart';
import 'package:oro_drip_irrigation/services/mqtt_manager_mobile.dart' if (dart.library.html) 'package:oro_drip_irrigation/services/mqtt_manager_web.dart';

import 'flavors.dart';


FutureOr<void> main() async {
  MqttManager mqttManager = MqttManager();
  MqttPayloadProvider myMqtt = MqttPayloadProvider();
  mqttManager.initializeMQTTClient(myMqtt);
  mqttManager.connect();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigMakerProvider()),
        ChangeNotifierProvider(create: (_) => IrrigationProgramMainProvider()),
        ChangeNotifierProvider(create: (_) => myMqtt),
        ChangeNotifierProvider(create: (_) => OverAllUse()),
        ChangeNotifierProvider(create: (_) => PreferenceProvider()),
        ChangeNotifierProvider(create: (_) => SystemDefinitionProvider()),
       ],
      child: MyApp(),
    ),
  );}