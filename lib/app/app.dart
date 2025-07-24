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
    print("enter my app..............");
    if(!kIsWeb){
      NotificationServiceCall().initialize();
      NotificationServiceCall().configureFirebaseMessaging();
    }
  }

  /// Decide the initial route based on whether a token exists
  Future<String> getInitialRoute() async {
    try {
      print("getInitialRoute---");
      final token = await PreferenceHelper.getToken();
      print("token--->$token");
      // Check if token is valid
      if (token != null && token.trim().isNotEmpty) {
        print("Navigating to dashboard");
        return Routes.dashboard;
      } else {
        print("No valid token, navigating to login");
        return Routes.login;
      }
    } catch (e) {
      print("Error in getInitialRoute: $e");
      return Routes.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Flavor is: ${F.appFlavor}');
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
          // home: ConfigBasePage(masterData: {
          //   "userId": 4,
          //   "customerId": 16,
          //   "controllerId": 74,
          //   "productId": 132,
          //   "deviceId": "2CCF67391FE1",
          //   "deviceName": "xMm",
          //   "categoryId": 1,
          //   "categoryName": "xMm",
          //   "modelId": 4,
          //   "modelName": "xMm2000ROOL",
          //   "groupId": 16,
          //   "groupName": "TANK 5A",
          //   "connectingObjectId": [
          //     "1",
          //     "2",
          //     "3",
          //     "4",
          //     "-"
          //   ],
          //   "productStock": [
          //     {
          //       "productId": 100,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC771B5",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 98,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC768EF",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 97,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC7906D",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 96,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC76FEC",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 95,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC777ED",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 94,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC8233A",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 93,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9EDC956EC771",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 92,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC78923",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 91,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC7F432",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 90,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC7B940",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 89,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC79892",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 88,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC77CCA",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 87,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC792DD",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 86,
          //       "categoryName": "xMh 2000",
          //       "modelName": "xMh2000R16O",
          //       "modelId": 32,
          //       "deviceId": "9C956EC78E66",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 12
          //     },
          //     {
          //       "productId": 84,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC77D0E",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 83,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC7A03F",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 82,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC7BE1D",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 81,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC7BD23",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 80,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC7B60E",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 79,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC7C108",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 78,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC81C32",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 77,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC774F5",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 76,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC8215E",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 75,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC7760A",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 74,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC7C06D",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 73,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC7C95F",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 72,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC7693A",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 69,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC7C304",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 68,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC78C1B",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 67,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC76B65",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 66,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC763CD",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 65,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC768F7",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 64,
          //       "categoryName": "xMp",
          //       "modelName": "xMp1000LOOO",
          //       "modelId": 5,
          //       "deviceId": "9C956EC76ACA",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 62,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF67990963",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 61,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF676C21FF",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 60,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF67391E35",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 59,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF676C21E9",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 58,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF6798E921",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 57,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF67990919",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 56,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF6798EE46",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 55,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF67990952",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 54,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF67392147",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 53,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF67391E83",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 52,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF67990918",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 51,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF67990977",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 50,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF67392164",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 49,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF679908FC",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 48,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF67391B19",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 47,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF6798EC85",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 46,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF67990931",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 45,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF67391B1F",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 44,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF6798E949",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 43,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF6798EDSF",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     },
          //     {
          //       "productId": 42,
          //       "categoryName": "xMm",
          //       "modelName": "xMm2000ROOL",
          //       "modelId": 4,
          //       "deviceId": "2CCF6798ECAF",
          //       "dateOfManufacturing": "2025-06-14",
          //       "warrantyMonths": 15
          //     }
          //   ]
          // }),
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