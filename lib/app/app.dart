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
          home: navigateToInitialScreen(snapshot.data ?? Routes.login),
          onGenerateRoute: Routes.generateRoute,
          // home: ConfigBasePage(masterData: {"userId":2,"customerId":10,"controllerId":39,"productId":39,"deviceId":"2CCF674C0F8A","deviceName":"ORO GEM","categoryId":1,"categoryName":"ORO GEM","modelId":4,"modelDescription":"Gem+ (RL)","modelName":"NAm2000ROOL","groupId":8,"groupName":"SIDDIQUE","connectingObjectId":["1","2","3","4","-"],"productStock":[{"productId":452,"categoryName":"ORO PUMP","modelName":"Pump (L3R)","modelId":5,"deviceId":"1213141516AD","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":451,"categoryName":"ORO RTU","modelName":"RTU (L4L with ADC)","modelId":35,"deviceId":"1213141516AC","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":450,"categoryName":"ORO RTU","modelName":"RTU (L4L)","modelId":34,"deviceId":"YUVARAJ00005","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":449,"categoryName":"ORO RTU+","modelName":"RTU+ (L4L, with SM, ST)","modelId":39,"deviceId":"1213141516AB","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":448,"categoryName":"ORO SMART+","modelName":"Smart+ (L8R)","modelId":27,"deviceId":"1122334455AB","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":447,"categoryName":"ORO PUMP","modelName":"Pump (L3R)","modelId":5,"deviceId":"123456789ABC","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":214,"categoryName":"ORO PUMP","modelName":"Pump+ (W3R)","modelId":10,"deviceId":"9C956EC7B015","dateOfManufacturing":"2025-08-13","warrantyMonths":12}]}),
        );
      },
    );
  }
}

/// Helper function to navigate to the appropriate screen
Widget navigateToInitialScreen(String route) {
  var isOro = F.appFlavor?.name.contains('oro') ?? false;
  switch (route) {
    case Routes.login:
       return kIsWeb ? LoginScreen() : isOro ? LandingScreen() : LoginScreen();
     case Routes.dashboard:
       return const ScreenController();
    default:
      return const SplashScreen();
  }
}

// Copy-Item -Path "web\smartComm\index.html" -Destination "web\index.html" -Force
// flutter build web --target=lib\main_oroProduction.dart