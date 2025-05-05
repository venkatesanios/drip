import 'package:flutter/material.dart';
import '../flavors.dart';
import '../modules/config_Maker/view/config_base_page.dart';
import '../utils/Theme/smart_comm_theme.dart';
import '../utils/Theme/oro_theme.dart';
import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';
import '../views/login_screen.dart';
import '../views/screen_controller.dart';
import '../views/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Decide the initial route based on whether a token exists
  Future<String> getInitialRoute() async {
    try {
      final token = await PreferenceHelper.getToken();
      print("token--->$token");
      if (token != null && token.isNotEmpty) {
        return Routes.dashboard;
      } else {
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
        print('vfdv');
        /*print('ConnectionState.done:${snapshot.connectionState}  F.appFlavor : ${F.appFlavor}');
        // Show splash screen or loading while waiting for route or flavor
        if (snapshot.connectionState != ConnectionState.done || F.appFlavor == null) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(), // or a loading widget
          );
        }*/

        final isOro = F.appFlavor!.name.contains('oro');

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: isOro ? OroTheme.lightTheme : SmartCommTheme.lightTheme,
          darkTheme: isOro ? OroTheme.darkTheme : SmartCommTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // home: ConfigBasePage(masterData: {}),
          home: navigateToInitialScreen(snapshot.data ?? Routes.login),
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}

/// Helper function to navigate to the appropriate screen
Widget navigateToInitialScreen(String route) {
  print("route:-->$route");
  switch (route) {
    case Routes.login:
      return const LoginScreen();
    case Routes.dashboard:
      // return const ConfigBasePage(masterData: {});
      return const ScreenController();
    default:
      return const SplashScreen();
  }
}
