import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/calibration/view/calibration_screen.dart';
import 'package:oro_drip_irrigation/modules/config_Maker/view/config_base_page.dart';
import 'package:oro_drip_irrigation/modules/config_Maker/view/table_demo.dart';
import 'package:oro_drip_irrigation/modules/fertilizer_set/view/fertilizer_Set_screen.dart';
import 'package:oro_drip_irrigation/modules/global_limit/view/global_limit_screen.dart';
import '../modules/ScheduleView/view/schedule_view_screen.dart';
import '../modules/constant/view/constant_base_page.dart';
import '../modules/irrigation_report/view/list_of_log_config.dart';
import '../modules/irrigation_report/view/standalone_log.dart';
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
          builder: (_) => const ConstantBasePage(userData: {"userId" : 4, "controllerId": 1, "deviceId":"2CCF674C0F8A" },),
          // builder: (_) => const FertilizerSetScreen(userData: {"userId" : 4, "controllerId": 1, "deviceId":"2CCF674C0F8A" },),
          // builder: (_) => const StandaloneLog(userData: {"userId" : 4, "controllerId": 1, "deviceId":"2CCF674C0F8A" },),
          // builder: (_) => const ListOfLogConfig(userData: {"userId" : 4, "controllerId": 1, "deviceId":"2CCF674C0F8A" },),
          // builder: (_) => const GlobalLimitScreen(userData: {"userId" : 4, "controllerId": 1, "deviceId":"2CCF674C0F8A" },),
          // builder: (_) => const CalibrationScreen(userData: {"userId" : 4, "controllerId": 1, "deviceId":"2CCF674C0F8A" },),
          // builder: (_) => const ConfigBasePage(masterData: {}),
          // builder: (_) => ScheduleViewScreen(deviceId: "2CCF674C0F8A", userId: 4, controllerId: 1, customerId: 4, groupId: 1),
          // builder: (_) => ScheduleViewScreen(deviceId: "2CCF674C0F8A", userId: 4, controllerId: 1, customerId: 4, groupId: 1),
          //  builder: (_) => const ScreenController(),
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