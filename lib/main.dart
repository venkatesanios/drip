import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/state_management/ble_service.dart';
import 'package:oro_drip_irrigation/providers/user_provider.dart';
import 'Constants/notifi_service.dart';
import 'app/app.dart';
import 'firebase_options.dart';
import 'modules/PumpController/state_management/pump_controller_provider.dart';

// Local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Firebase background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background message: ${message.messageId}");
}

// Permissions request
Future<void> requestAppPermissions() async {
  debugPrint("Requesting permissions...");

  // Notifications (iOS + Android 13+)
  final notifStatus = await Permission.notification.request();
  debugPrint("Notification permission: $notifStatus");

  if (Platform.isAndroid) {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse, // better than generic .location
    ].request();

    debugPrint("BLE + Location permissions: $statuses");

    // Handle permanently denied
    if (notifStatus.isPermanentlyDenied ||
        statuses.values.any((s) => s.isPermanentlyDenied)) {
      await openAppSettings();
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  // Request runtime permissions before providers start
  if (!kIsWeb && Platform.isAndroid) {
    await requestAppPermissions();
  }
  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // Local notifications
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Background messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      NotificationService().showNotification(
        title: message.notification!.title,
        body: message.notification!.body,
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint("Message clicked: ${message.messageId}");
  });


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => PumpControllerProvider()),
        ChangeNotifierProvider(create: (_) => BleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
