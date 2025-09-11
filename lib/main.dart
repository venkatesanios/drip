import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/PumpController/state_management/pump_controller_provider.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/state_management/ble_service.dart';
import 'package:oro_drip_irrigation/providers/user_provider.dart';
import 'package:oro_drip_irrigation/services/bluetooth_service.dart';
import 'package:oro_drip_irrigation/services/communication_service.dart';
import 'package:oro_drip_irrigation/services/mqtt_service.dart';
import 'package:oro_drip_irrigation/utils/network_utils.dart';
import 'package:oro_drip_irrigation/views/customer/sent_and_received.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'Constants/notifi_service.dart';
import 'Screens/Constant/ConstantPageProvider/changeNotifier_constantProvider.dart';
import 'StateManagement/search_provider.dart';
import 'app/app.dart';
import 'StateManagement/customer_provider.dart';
import 'firebase_options.dart';
import 'flavors.dart';
import 'modules/IrrigationProgram/state_management/irrigation_program_provider.dart';
import 'modules/Preferences/state_management/preference_provider.dart';
import 'modules/SystemDefinitions/state_management/system_definition_provider.dart';
import 'modules/config_Maker/state_management/config_maker_provider.dart';
import 'StateManagement/mqtt_payload_provider.dart';
import 'StateManagement/overall_use.dart';
import 'modules/constant/state_management/constant_provider.dart';

// Initialize local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Background message handler for Firebase
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}



FutureOr<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NetworkUtils.initialize();

  if(!kIsWeb){
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Request notification permissions
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Set up Firebase background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // print('Message received: ${message.messageId}');
        if (message.notification != null) {
          NotificationService().showNotification(
            title: message.notification!.title,
            body: message.notification!.body,
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Message received onMessageOpenedApp: ${message.messageId}');
      });

/*      messaging.getToken().then((String? token) async{
        print("FCM Token: $token");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('deviceToken', token ?? '' );
      });*/

      messaging.getAPNSToken().then((String? token) {
        print("APN Token: $token");
      });

    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }




  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ConfigMakerProvider()),
        ChangeNotifierProvider(create: (_) => IrrigationProgramMainProvider()),
        ChangeNotifierProvider(create: (_) => MqttPayloadProvider()),
        ChangeNotifierProvider(create: (_) => OverAllUse()),
        ChangeNotifierProvider(create: (_) => PreferenceProvider()),
        ChangeNotifierProvider(create: (_) => SystemDefinitionProvider()),
        ChangeNotifierProvider(create: (_) => ConstantProviderMani()),
        ChangeNotifierProvider(create: (_) => ConstantProvider()),
        ChangeNotifierProvider(create: (_) => PumpControllerProvider()),
        ChangeNotifierProvider(create: (_) => BleProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),

        ProxyProvider2<MqttPayloadProvider, CustomerProvider, CommunicationService>(
          update: (BuildContext context, MqttPayloadProvider mqttProvider,
              CustomerProvider customer, CommunicationService? previous) {
            return CommunicationService(
              mqttService: MqttService(),
              blueService: BluService(),
              customerProvider: customer,
            );
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}