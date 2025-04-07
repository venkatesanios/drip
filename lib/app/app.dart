import 'package:flutter/material.dart';
import '../Screens/Map/MapAddObject.dart';
import '../Screens/Map/valvectrlMap.dart';
import '../Screens/planning/test.dart';
import '../flavors.dart';
import '../utils/Theme/smart_comm_theme.dart';
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
      print("token--->$token");
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
          theme: F.appFlavor!.name.contains('oro') ? OroTheme.lightTheme : SmartCommTheme.lightTheme,
          darkTheme: F.appFlavor!.name.contains('oro') ? OroTheme.darkTheme : SmartCommTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: navigateToInitialScreen(snapshot.data ?? Routes.login),
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}

Widget navigateToInitialScreen(String route) {
  print("route:-->$route");
  switch (route) {
    case Routes.login:
      // return ScheduleViewScreen(deviceId: "2CCF674C0F8A", userId: 4, controllerId: 1, customerId: 4, groupId: 1);
      // return ProgramLibraryScreenNew(userId: 4, controllerId: 1, deviceId: '2CCF674C0F8A', fromDealer: false, customerId: 4,);
      return const LoginScreen();
    case Routes.dashboard:
       // return ValveControllerMap();
       // return GroupListScreen(userId: 8, controllerId: 23, deviceId: '2CCF6773D07D',);
      return const ScreenController();

    default:
      return const SplashScreen();
  }
}