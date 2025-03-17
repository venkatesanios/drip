import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/NewIrrigationProgram/program_library.dart';
import '../flavors.dart';
import '../utils/Theme/smart_comm_theme.dart';
import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';
import '../utils/Theme/oro_theme.dart';
import '../views/customer/program_schedule.dart';
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
  switch (route) {
    case Routes.login:
      // return ProgramLibraryScreenNew(userId: 4, controllerId: 1, deviceId: '2CCF674C0F8A', fromDealer: false, customerId: 4,);
      return const LoginScreen();
    case Routes.dashboard:
      // return ProgramLibraryScreenNew(userId: 4, controllerId: 1, deviceId: '2CCF674C0F8A', fromDealer: false, customerId: 4,);
     //return const ScreenController();
       return const ProgramSchedule(customerID: 4, controllerID: 1, siteName: '', imeiNumber: '2CCF674C0F8A', userId: 4,);
    default:
      return const SplashScreen();
  }
}