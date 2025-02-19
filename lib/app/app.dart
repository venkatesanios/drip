import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/utils/environment.dart';
import '../utils/Theme/lk_theme.dart';
import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';
import '../utils/Theme/oro_theme.dart';
import '../views/login_screen.dart';
import '../views/screen_controller.dart';
import '../views/splash_screen.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> getInitialRoute() async {
    try {
      final token = await PreferenceHelper.getToken();
      if (token!.isNotEmpty) {
        return Routes.dashboard;
      }else{
        return Routes.login;
      }
    } catch (e) {
      return Routes.login;
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isDarkMode = false;
    return FutureBuilder<String>(
      future: getInitialRoute(),
      builder: (context, snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Environment.currentEnvironment == 'oroDevelopment' ? OroTheme.lightTheme : LkTheme.lightTheme,
          darkTheme: OroTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: navigateToInitialScreen(snapshot.data ?? Routes.login),
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}

Widget navigateToInitialScreen(String route) {
  switch (route) {
    case Routes.login:
      return const LoginScreen();
    case Routes.dashboard:
      return const ScreenController();
    default:
      return const SplashScreen();
  }
}