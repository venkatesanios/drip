import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/theme.dart';
import 'package:oro_drip_irrigation/StateManagement/config_maker_provider.dart';
import 'package:provider/provider.dart';
import 'Screens/ConfigMaker/config_base_page.dart';

void main() {
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

