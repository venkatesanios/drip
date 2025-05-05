import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:oro_drip_irrigation/app/app.dart';
import 'package:oro_drip_irrigation/modules/PumpController/state_management/pump_controller_provider.dart';
import 'package:oro_drip_irrigation/services/mqtt_service.dart';
import 'package:provider/provider.dart';
import 'Constants/notifi_service.dart';
import 'Constants/notifications_service.dart';
import 'Screens/Constant/ConstantPageProvider/changeNotifier_constantProvider.dart';
import 'firebase_options.dart';
import 'modules/IrrigationProgram/state_management/irrigation_program_provider.dart';
import 'modules/Preferences/state_management/preference_provider.dart';
import 'modules/SystemDefinitions/state_management/system_definition_provider.dart';
import 'modules/config_Maker/state_management/config_maker_provider.dart';
import 'StateManagement/mqtt_payload_provider.dart';
import 'StateManagement/overall_use.dart';
import 'modules/constant/state_management/constant_provider.dart';
import 'package:firebase_core/firebase_core.dart';

FutureOr<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // debugPaintSizeEnabled = true;
  MqttService mqttService = MqttService();
  MqttPayloadProvider myMqtt = MqttPayloadProvider();
  NotificationServiceCall().initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigMakerProvider()),
        ChangeNotifierProvider(create: (_) => IrrigationProgramMainProvider()),
        ChangeNotifierProvider(create: (_) => myMqtt),
        ChangeNotifierProvider(create: (_) => OverAllUse()),
        ChangeNotifierProvider(create: (_) => PreferenceProvider()),
        ChangeNotifierProvider(create: (_) => SystemDefinitionProvider()),
        ChangeNotifierProvider(create: (_) => ConstantProviderMani()),
        ChangeNotifierProvider(create: (_) => ConstantProvider()),
        ChangeNotifierProvider(create: (_) => PumpControllerProvider()),
      ],
      child: MyApp(),
      
    ),
  );}