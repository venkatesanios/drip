import'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oro_drip_irrigation/Constants/notifications_service.dart';
import 'package:oro_drip_irrigation/modules/config_Maker/view/config_base_page.dart';
import 'package:oro_drip_irrigation/modules/irrigation_report/view/fertilizer_pump_runtime_log.dart';
import 'package:oro_drip_irrigation/modules/irrigation_report/view/motor_cyclic_log.dart';
import 'package:oro_drip_irrigation/modules/irrigation_report/view/zone_cyclic_log.dart';
import '../Screens/Dealer/bLE_update.dart';
import '../Screens/Dealer/ble_controllerlog_ftp.dart';
import '../Screens/login_screenOTP/landing_screen.dart';
import '../Screens/login_screenOTP/login_screenotp.dart';
import '../flavors.dart';
import '../modules/constant/view/constant_base_page.dart';
import '../utils/Theme/smart_comm_theme.dart';
import '../utils/Theme/oro_theme.dart';
import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';
import '../views/common/login/login_screen.dart';
import '../views/screen_controller.dart';
import '../views/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return FutureBuilder<String>(
      future: getInitialRoute(),
      builder: (context, snapshot) {
        var isOro = F.appFlavor?.name.contains('oro') ?? false;
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: isOro ? OroTheme.lightTheme : SmartCommTheme.lightTheme,
          darkTheme: isOro ? OroTheme.darkTheme : SmartCommTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: navigateToInitialScreen(snapshot.data ?? Routes.login),
          // home: ConfigBasePage(masterData: {"userId":2,"customerId":16,"controllerId":61,"productId":60,"deviceId":"2CCF6773D07D","deviceName":"ORO GEM","categoryId":1,"categoryName":"ORO GEM","modelId":2,"modelDescription":"Gem (RL)","modelName":"NAm1000ROOL","groupId":14,"groupName":"GREEN FIELDS","connectingObjectId":["1","2","3","4","-"],"productStock":[{"productId":773,"categoryName":"ORO LEVEL","modelName":"Level (L4L, Digital input with ADC)","modelId":12,"deviceId":"LEVEL0000001","dateOfManufacturing":"2025-10-23","warrantyMonths":12},{"productId":519,"categoryName":"ORO RTU+","modelName":"RTU+ (L4L, with SM, ST)","modelId":39,"deviceId":"9C956EVVVVVV","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":518,"categoryName":"ORO RTU+","modelName":"RTU+ (L4L, with SM, ST)","modelId":39,"deviceId":"9TESTING","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":517,"categoryName":"ORO RTU+","modelName":"RTU+ (L4L, with SM, ST)","modelId":39,"deviceId":"9C956EC70000","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":516,"categoryName":"ORO RTU+","modelName":"RTU+ (L4L, with SM, ST)","modelId":39,"deviceId":"9C956E22334A","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":515,"categoryName":"ORO RTU","modelName":"RTU (L4L)","modelId":34,"deviceId":"SANTHOSH0011","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":514,"categoryName":"ORO RTU","modelName":"RTU (L4L)","modelId":34,"deviceId":"SANTHOSH0010","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":512,"categoryName":"ORO RTU","modelName":"RTU (L4L)","modelId":34,"deviceId":"SANTHOSH0008","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":511,"categoryName":"ORO RTU","modelName":"RTU (L4L)","modelId":34,"deviceId":"SANTHOSH0007","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":510,"categoryName":"ORO RTU","modelName":"RTU (L4L)","modelId":34,"deviceId":"9C95VVVVVVVV","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":509,"categoryName":"ORO RTU","modelName":"RTU (L4L)","modelId":34,"deviceId":"E8EB1B04B9F3","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":508,"categoryName":"ORO RTU","modelName":"RTU (L4L)","modelId":34,"deviceId":"E8EB1TEST","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":507,"categoryName":"ORO RTU","modelName":"RTU (L4L)","modelId":34,"deviceId":"803428813AAA","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":506,"categoryName":"ORO RTU","modelName":"RTU (L4L)","modelId":34,"deviceId":"8034284444AA","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":505,"categoryName":"ORO RTU","modelName":"RTU (L4L)","modelId":34,"deviceId":"E8EB1BEEEEEE","dateOfManufacturing":"2025-09-25","warrantyMonths":12},{"productId":475,"categoryName":"ORO PUMP","modelName":"Pump (L3R)","modelId":5,"deviceId":"9C956EC8AAAA","dateOfManufacturing":"2025-09-23","warrantyMonths":12},{"productId":474,"categoryName":"ORO PUMP","modelName":"Pump (L3R)","modelId":5,"deviceId":"9C956EC7AAZZ","dateOfManufacturing":"2025-09-23","warrantyMonths":12},{"productId":452,"categoryName":"ORO PUMP","modelName":"Pump (L3R)","modelId":5,"deviceId":"1213141516AD","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":451,"categoryName":"ORO RTU","modelName":"RTU (L4L with ADC)","modelId":35,"deviceId":"1213141516AC","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":450,"categoryName":"ORO RTU","modelName":"RTU (L4L)","modelId":34,"deviceId":"YUVARAJ00005","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":449,"categoryName":"ORO RTU+","modelName":"RTU+ (L4L, with SM, ST)","modelId":39,"deviceId":"1213141516AB","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":448,"categoryName":"ORO SMART+","modelName":"Smart+ (L8R)","modelId":27,"deviceId":"1122334455AB","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":447,"categoryName":"ORO PUMP","modelName":"Pump (L3R)","modelId":5,"deviceId":"123456789ABC","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":446,"categoryName":"ORO SMART+","modelName":"Smart+ (R16R)","modelId":32,"deviceId":"SEKAR0000003","dateOfManufacturing":"2025-09-22","warrantyMonths":12},{"productId":214,"categoryName":"ORO PUMP","modelName":"Pump+ (W3R)","modelId":10,"deviceId":"9C956EC7B015","dateOfManufacturing":"2025-08-13","warrantyMonths":12},{"productId":36,"categoryName":"ORO SMART+","modelName":"Smart+ (R16R)","modelId":32,"deviceId":"80342882ED32","dateOfManufacturing":"2025-05-30","warrantyMonths":12},{"productId":35,"categoryName":"ORO RTU+","modelName":"RTU+ (L4L, with SM, ST and ADC)","modelId":40,"deviceId":"E8EB1B04E125","dateOfManufacturing":"2025-05-30","warrantyMonths":12},{"productId":34,"categoryName":"ORO RTU+","modelName":"RTU+ (L4L, with SM, ST and ADC)","modelId":40,"deviceId":"E8EB1B049F8C","dateOfManufacturing":"2025-05-30","warrantyMonths":12},{"productId":33,"categoryName":"ORO RTU+","modelName":"RTU+ (L4L, with SM, ST and ADC)","modelId":40,"deviceId":"E8EB1B032176","dateOfManufacturing":"2025-05-30","warrantyMonths":12},{"productId":32,"categoryName":"ORO RTU+","modelName":"RTU+ (L4L, with SM, ST and ADC)","modelId":40,"deviceId":"E8EB1B032A51","dateOfManufacturing":"2025-05-30","warrantyMonths":12}]}, fromDashboard: false),
          onGenerateRoute: Routes.generateRoute,
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
       return kIsWeb ? const LoginScreen() : LoginScreenOTP();
     case Routes.dashboard:
       return const ScreenController();
    default:
      return const SplashScreen();
  }
}