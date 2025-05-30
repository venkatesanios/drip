import 'dart:async';
import 'dart:io' show Platform; // Added for platform-specific checks
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oro_drip_irrigation/utils/shared_preferences_helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/Constant/ConstantPageProvider/changeNotifier_constantProvider.dart';
import 'app/app.dart';
import 'firebase_options.dart';
import 'flavors.dart';
import 'modules/PumpController/state_management/pump_controller_provider.dart';
import 'modules/IrrigationProgram/state_management/irrigation_program_provider.dart';
import 'modules/Preferences/state_management/preference_provider.dart';
import 'modules/SystemDefinitions/state_management/system_definition_provider.dart';
import 'modules/config_Maker/state_management/config_maker_provider.dart';
import 'modules/constant/state_management/constant_provider.dart';
import 'services/bluetooth_manager.dart';
import 'services/communication_service.dart';
import 'services/mqtt_service.dart';
import 'StateManagement/customer_provider.dart';
import 'StateManagement/mqtt_payload_provider.dart';
import 'StateManagement/overall_use.dart';

// Initialize local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📥 Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.oroProduction;
  if (!kIsWeb) {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Set background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Print FCM token
      String? token = await messaging.getToken();
      print("🔑 FCM Token: $token");

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('deviceToken', token);
          debugPrint('FCM Token: $token');
      }

      // Setup Android notification channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      final AndroidFlutterLocalNotificationsPlugin? androidPlatform =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidPlatform?.createNotificationChannel(channel);

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      // Add iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combine Android and iOS settings
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the local notifications plugin
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("📩 Foreground message: ${message.messageId}");

        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;
        AppleNotification? apple = message.notification?.apple;

        if (notification != null) {
          if (android != null && !kIsWeb && Platform.isAndroid) {
            flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channelDescription: channel.description,
                  importance: Importance.high,
                  priority: Priority.high,
                  icon: '@mipmap/ic_launcher',
                ),
              ),
            );
          } else if (apple != null && !kIsWeb && Platform.isIOS) {
            flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              const NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
              ),
            );
          }
        }
      });

      // Notification opened handler
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("🚀 Notification caused app to open: ${message.messageId}");
        // Navigate to specific screen here if needed
      });
    } catch (e, stacktrace) {
      debugPrint("🔥 Firebase initialization error: $e");
      debugPrint("🔥 Firebase stacktrace error: $stacktrace");
    }
  }

  runApp(
    MultiProvider(
      providers: [
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
        if (!kIsWeb)
          ChangeNotifierProvider<BluetoothManager>(
            create: (_) => BluetoothManager(state: MqttPayloadProvider()),
          ),
        ProxyProvider2<BluetoothManager?, CustomerProvider, CommunicationService>(
          update: (context, bluetooth, customer, previous) {
            return CommunicationService(
              mqttService: MqttService(),
              bluetoothManager: bluetooth,
              customerProvider: customer,
            );
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}
