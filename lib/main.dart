import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/theme.dart';
import 'package:oro_drip_irrigation/StateManagement/config_maker_provider.dart';
import 'package:provider/provider.dart';
import 'Constants/constants.dart';
import 'Constants/env_setup.dart';
import 'Screens/ConfigMaker/config_base_page.dart';
import 'Screens/ConfigMaker/payload_proccessing.dart';
import 'Screens/ConfigMaker/config_web_view.dart';

void main() {
  GlobalConfig.setEnvironment(Environment.development);
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

