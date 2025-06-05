import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/PumpController/state_management/pump_controller_provider.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/state_management/ble_service.dart';
import 'package:oro_drip_irrigation/services/bluetooth_sevice.dart';
import 'package:oro_drip_irrigation/services/communication_service.dart';
import 'package:oro_drip_irrigation/services/mqtt_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Screens/Constant/ConstantPageProvider/changeNotifier_constantProvider.dart';
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

// Background message handler for Firebase
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

// Show a user-friendly dialog before requesting notification permissions
Future<bool> showNotificationPrompt(BuildContext context) async {
  bool? shouldRequest = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enable Notifications'),
      content: const Text(
          'Allow notifications to receive real-time updates on irrigation status and system alerts.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Skip'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Allow'),
        ),
      ],
    ),
  );
  return shouldRequest ?? false;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool notificationsEnabled = false;
  // F.appFlavor = Flavor.oroProduction;

  if (!kIsWeb) {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Request notification permissions with user consent
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      bool shouldRequest = true; // In a real app, call showNotificationPrompt(context) in a widget
      if (shouldRequest) {
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: true, // Enable provisional notifications for iOS
        );
        debugPrint('Notification permission status: ${settings.authorizationStatus}');
        notificationsEnabled = settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      }

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        requestCriticalPermission: false,
      );
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      bool? localNotificationsInitialized = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Local notification response: ${response.payload}');
          // Handle notification tap (e.g., navigate to specific screen)
        },
      );
      debugPrint('Local notifications initialized: $localNotificationsInitialized');

      // Set up Firebase background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Received foreground message: ${message.messageId}');
        if (message.notification != null) {
          // Show local notification for foreground messages
          flutterLocalNotificationsPlugin.show(
            message.hashCode,
            message.notification!.title,
            message.notification!.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'oro_drip_channel',
                'Oro Drip Notifications',
                importance: Importance.high,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails(),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Initialization error: $e');
      // Ensure app continues even if Firebase initialization fails
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
        ChangeNotifierProvider(create: (_) => NotifigationCheck(notificationsEnabled: notificationsEnabled)),
        ChangeNotifierProvider(create: (_) => PreferenceProvider()),
        ChangeNotifierProvider(create: (_) => SystemDefinitionProvider()),
        ChangeNotifierProvider(create: (_) => ConstantProviderMani()),
        ChangeNotifierProvider(create: (_) => ConstantProvider()),
        ChangeNotifierProvider(create: (_) => PumpControllerProvider()),
        ChangeNotifierProvider(create: (_) => BleProvider()),
        ProxyProvider2<MqttPayloadProvider, CustomerProvider, CommunicationService>(
          update: (BuildContext context, MqttPayloadProvider mqttService,
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


class NotifigationCheck with ChangeNotifier {
  final bool notificationsEnabled;

  NotifigationCheck({required this.notificationsEnabled});

  void updateIrrigationStatus(String status) {
    if (notificationsEnabled) {
      // Send push notification via Firebase
      debugPrint('Sending push notification: $status');
    } else {
      // Fallback: Update UI or use MQTT/Bluetooth
      debugPrint('Notifications disabled, using MQTT fallback: $status');
      notifyListeners();
    }
  }
}