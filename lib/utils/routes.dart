import 'package:flutter/material.dart';
import '../views/screen_controller.dart';
import '../views/login_screen.dart';
import '../views/splash_screen.dart';

class Routes {
  static const String flash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.flash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case Routes.dashboard:
        return MaterialPageRoute(
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