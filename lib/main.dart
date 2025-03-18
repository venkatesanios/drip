import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:oro_drip_irrigation/app/app.dart';
import 'package:oro_drip_irrigation/services/mqtt_service.dart';
import 'package:provider/provider.dart';
import 'Screens/Constant/ConstantPageProvider/changeNotifier_constantProvider.dart';
import 'modules/config_Maker/state_management/config_maker_provider.dart';
import 'StateManagement/irrigation_program_provider.dart';
import 'StateManagement/preference_provider.dart';
import 'StateManagement/schedule_view_provider.dart';
import 'StateManagement/system_definition_provider.dart';
import 'StateManagement/mqtt_payload_provider.dart';
import 'StateManagement/overall_use.dart';

import 'flavors.dart';


FutureOr<void> main() async {
  // debugPaintSizeEnabled = true;
  MqttService mqttService = MqttService();
  MqttPayloadProvider myMqtt = MqttPayloadProvider();
  ScheduleViewProvider mySchedule = ScheduleViewProvider();
  myMqtt.editMySchedule(mySchedule);

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
        ChangeNotifierProvider(create: (_) => ConstantProvider()),
      ],
      child: MyApp(),
      
    ),
  );}