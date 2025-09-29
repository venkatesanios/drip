import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oro_drip_irrigation/Constants/notifications_service.dart';
import 'package:oro_drip_irrigation/modules/config_Maker/view/config_base_page.dart';
import 'package:oro_drip_irrigation/modules/irrigation_report/view/fertilizer_pump_runtime_log.dart';
import 'package:oro_drip_irrigation/modules/irrigation_report/view/motor_cyclic_log.dart';
import 'package:oro_drip_irrigation/modules/irrigation_report/view/zone_cyclic_log.dart';
import '../Screens/Dealer/bLE_update.dart';
import '../Screens/Dealer/ble_controllerlog_ftp.dart';
import '../Screens/login_screenOTP/landing_screen.dart';
import '../flavors.dart';
import '../modules/constant/view/constant_base_page.dart';
import '../utils/Theme/smart_comm_theme.dart';
import '../utils/Theme/oro_theme.dart';
import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';
import '../views/common/login/login_screen.dart';
import '../views/screen_controller.dart';
import '../views/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> _initialRouteFuture;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      NotificationServiceCall().initialize();
      NotificationServiceCall().configureFirebaseMessaging();
    }
    _initialRouteFuture = getInitialRoute();
  }

  Future<String> getInitialRoute() async {
    try {
      final token = await PreferenceHelper.getToken();
      if (token != null && token.trim().isNotEmpty) {
        return Routes.dashboard;
      } else {
        return Routes.login;
      }
    } catch (e) {
      print("Error in getInitialRoute: $e");
      return Routes.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOro = F.appFlavor?.name.contains('oro') ?? false;
    const isDarkMode = false;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isOro ? OroTheme.lightTheme : SmartCommTheme.lightTheme,
      darkTheme: isOro ? OroTheme.darkTheme : SmartCommTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: Routes.generateRoute,
      home: FutureBuilder<String>(
        future: _initialRouteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          return navigateToInitialScreen(snapshot.data ?? Routes.login);
        },
      ),
    );
  }
}

/// Helper function
Widget navigateToInitialScreen(String route) {
  final isOro = F.appFlavor?.name.contains('oro') ?? false;
  switch (route) {
    case Routes.login:
      return kIsWeb ? const LoginScreen() : isOro ? const LandingScreen() : const LoginScreen();
    case Routes.dashboard:
      return const ScreenController();
    default:
      return const SplashScreen();
  }
}

// Copy-Item -Path "web\smartComm\index.html" -Destination "web\index.html" -Force
// flutter build web --target=lib\main_oroProduction.dart