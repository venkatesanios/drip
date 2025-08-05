import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oro_drip_irrigation/Constants/notifications_service.dart';
import 'package:oro_drip_irrigation/modules/config_Maker/view/config_base_page.dart';
import '../Screens/Dealer/bLE_update.dart';
import '../Screens/Dealer/ble_controllerlog_ftp.dart';
import '../flavors.dart';
import '../utils/Theme/smart_comm_theme.dart';
import '../utils/Theme/oro_theme.dart';
import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';
import '../views/login_screen.dart';
import '../views/screen_controller.dart';
import '../views/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    if(!kIsWeb){
      NotificationServiceCall().initialize();
      NotificationServiceCall().configureFirebaseMessaging();
    }
  }

  /// Decide the initial route based on whether a token exists
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
    debugPrint('Flavor is: ${F.appFlavor}');
    bool isDarkMode = false;
    return FutureBuilder<String>(
      future: getInitialRoute(),
      builder: (context, snapshot) {
        var isOro = F.appFlavor?.name.contains('oro') ?? false;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: isOro ? OroTheme.lightTheme : SmartCommTheme.lightTheme,
          darkTheme: isOro ? OroTheme.darkTheme : SmartCommTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // home: ConfigBasePage(masterData: {"userId":3,"customerId":6,"controllerId":9,"productId":9,"deviceId":"2CCF6773D07D","deviceName":"xMm","categoryId":1,"categoryName":"xMm","modelId":1,"modelName":"xMm1000ROOO","groupId":2,"groupName":"Testing site","connectingObjectId":["1","2","3","4","-"],"productStock":[{"productId":239,"categoryName":"xMh 2000","modelName":"Smart+ (R16R)","modelId":32,"deviceId":"997878879979","dateOfManufacturing":"2025-08-01","warrantyMonths":12},{"productId":39,"categoryName":"xMp","modelName":"Pump (L2R)","modelId":5,"deviceId":"9C956EC76100","dateOfManufacturing":"2025-06-10","warrantyMonths":12},{"productId":38,"categoryName":"xMp","modelName":"Pump (L2R)","modelId":5,"deviceId":"9C956EC7C000","dateOfManufacturing":"2025-06-10","warrantyMonths":12},{"productId":37,"categoryName":"xMp","modelName":"Pump (L2R)","modelId":5,"deviceId":"9C956EC81000","dateOfManufacturing":"2025-06-10","warrantyMonths":12},{"productId":25,"categoryName":"xMp","modelName":"Pump (L2R)","modelId":5,"deviceId":"9C956EC79111","dateOfManufacturing":"2025-06-03","warrantyMonths":12}]}),
          home: navigateToInitialScreen(snapshot.data ?? Routes.login),
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}

/// Helper function to navigate to the appropriate screen
Widget navigateToInitialScreen(String route) {
  switch (route) {
    case Routes.login:
       return const LoginScreen();
    case Routes.dashboard:
       // return  FileTransferPage();
       return const ScreenController();
    default:
      return const SplashScreen();
  }
}