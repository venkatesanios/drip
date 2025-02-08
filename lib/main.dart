import 'dart:convert';
import 'package:oro_drip_irrigation/Constants/mqtt_manager_mobile.dart' if (dart.library.html) 'package:oro_drip_irrigation/Constants/mqtt_manager_web.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/theme.dart';
import 'package:oro_drip_irrigation/Screens/IrrigationProgram/program_library.dart';
import 'package:oro_drip_irrigation/StateManagement/config_maker_provider.dart';
import 'package:provider/provider.dart';
import 'Constants/constants.dart';
import 'Constants/env_setup.dart';
import 'Screens/ConfigMaker/config_base_page.dart';
import 'Screens/ConfigMaker/payload_proccessing.dart';
import 'Screens/ConfigMaker/config_web_view.dart';

void main() {
  GlobalConfig.setEnvironment(Environment.development);
  MqttManager mqttManager = MqttManager();
  mqttManager.initializeMQTTClient();
  mqttManager.connect();
  Future.delayed(Duration(seconds: 5),(){
    mqttManager.topicToPublishAndItsMessage('siva', 'hi from siva');
  });
  // print(payloadConversion());
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConfigMakerProvider()),
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
      home: const ConfigBasePage(),
    );
  }
}

class TimeInputModel{
  int type;
  String value;

  TimeInputModel({
    required this.type,
    required this.value,
  });

  String getHours(){
    return value.split(':')[0];
  }

  String getMinutes(){
    return value.split(':')[1];
  }

  String getSeconds(){
    return value.split(':')[2];
  }
}

class IntInput{
  int inputId;
  int type;
  int value;

  IntInput({
    required this.inputId,
    required this.type,
    required this.value,
  });

  String stringValue(){
    return value.toString();
  }

  void updateValue(String val){
    if(val.isEmpty){
      value = 0;
    }else{
      value = int.parse(val);
    }
  }
}


