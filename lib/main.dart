import 'package:oro_drip_irrigation/Constants/mqtt_manager_mobile.dart'
if (dart.library.html) 'package:oro_drip_irrigation/Constants/mqtt_manager_web.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/StateManagement/config_maker_provider.dart';
import 'package:oro_drip_irrigation/utils/environment.dart';
import 'package:oro_drip_irrigation/utils/network_utils.dart';
import 'package:provider/provider.dart';
import 'Constants/env_setup.dart';
import 'Constants/theme.dart';
import 'Screens/ConfigMaker/config_base_page.dart';
import 'app/app.dart';

void main() {
  NetworkUtils.initialize();
  /*GlobalConfig.setEnvironment(Environment.development);
=======
  // GlobalConfig.setEnvironment(Environment.development);
>>>>>>> siva
  MqttManager mqttManager = MqttManager();
  mqttManager.initializeMQTTClient();
  mqttManager.connect();
  Future.delayed(Duration(seconds: 5),(){
    mqttManager.topicToPublishAndItsMessage('siva', 'hi from siva');
  });*/
  // print(payloadConversion());
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ConfigMakerProvider()),
        ],
        child: const MyApp(),
      )
  );
}
