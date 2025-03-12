import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/calibration/view/calibration_screen.dart';
import 'package:oro_drip_irrigation/config_maker/view/config_base_page.dart';
import 'package:oro_drip_irrigation/config_maker/view/table_demo.dart';

import '../views/screen_controller.dart';
import '../views/login_screen.dart';
import '../views/splash_screen.dart';

class Routes {
  static const String flash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case flash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case dashboard:
        return MaterialPageRoute(
          // builder: (_) => const CalibrationScreen(userData: {"userId" : 4, "controllerId": 1, "deviceId":"2CCF674C0F8A" },),
          // builder: (_) => const ConfigBasePage(masterData: {}),
           builder: (_) => const ScreenController(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Unknown Route')),
          ),
          settings: settings,
        );
    }
  }
}