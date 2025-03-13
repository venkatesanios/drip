import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:oro_drip_irrigation/app/app.dart';
import 'package:provider/provider.dart';
import 'StateManagement/config_maker_provider.dart';
import 'StateManagement/irrigation_program_provider.dart';
import 'StateManagement/preference_provider.dart';
import 'StateManagement/schedule_view_provider.dart';
import 'StateManagement/system_definition_provider.dart';
import 'StateManagement/mqtt_payload_provider.dart';
import 'StateManagement/overall_use.dart';
import 'app.dart';
import 'package:oro_drip_irrigation/services/mqtt_manager_mobile.dart' if (dart.library.html) 'package:oro_drip_irrigation/services/mqtt_manager_web.dart';

import 'flavors.dart';


FutureOr<void> main() async {
  // debugPaintSizeEnabled = true;
  MqttManager mqttManager = MqttManager();
  MqttPayloadProvider myMqtt = MqttPayloadProvider();
  ScheduleViewProvider mySchedule = ScheduleViewProvider();
  myMqtt.editMySchedule(mySchedule);
  mqttManager.initializeMQTTClient(myMqtt);
  mqttManager.connect();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigMakerProvider()),
        ChangeNotifierProvider(create: (_) => IrrigationProgramMainProvider()),
        ChangeNotifierProvider(create: (_) => myMqtt),
        ChangeNotifierProvider(create: (_) => OverAllUse()),
        ChangeNotifierProvider(create: (_) => mySchedule),
        ChangeNotifierProvider(create: (_) => PreferenceProvider()),
        ChangeNotifierProvider(create: (_) => SystemDefinitionProvider()),
      ],
      child: MyApp(),
    ),
  );}