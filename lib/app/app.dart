import 'package:az_notification_hub/az_notification_hub.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
    _configureFirebaseMessaging();
  }

  void _configureFirebaseMessaging() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.messageId}');
      if (message.notification != null) {
        _showNotification({
          'notification': {
            'title': message.notification?.title ?? 'Notification',
            'body': message.notification?.body ?? 'New notification received',
          },
          'data': message.data,
        });
      }
    });

    // Handle notifications when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened app: ${message.messageId}');
      _navigateToScreen({
        'notification': {
          'title': message.notification?.title,
          'body': message.notification?.body,
        },
        'data': message.data,
      });
    });

    // Handle initial message when the app is launched from a terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('Initial message: ${message.messageId}');
        _navigateToScreen({
          'notification': {
            'title': message.notification?.title,
            'body': message.notification?.body,
          },
          'data': message.data,
        });
      }
    });
  }

  Future<void> _showNotification(Map<String, dynamic> notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'oro_channel_id',
      'Oro Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      notification['notification']['title'] ?? 'Notification',
      notification['notification']['body'] ?? 'You have a new notification',
      platformChannelSpecifics,
      payload: notification['data']?.toString(),
    );
  }

  void _navigateToScreen(Map<String, dynamic> notification) {
    // Implement navigation logic based on notification data
    print('Navigate based on: $notification');
    // Example: Navigate to a specific screen if notification contains a route
    // if (notification['data']['route'] != null) {
    //   Navigator.pushNamed(context, notification['data']['route']);
    // }
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
        );
      },
    );
  }
}

/// Helper function to navigate to the appropriate screen
Widget navigateToInitialScreen(String route) {
  print("route:-->$route");
  switch (route) {
    case Routes.login:
      return const LoginScreen();
    case Routes.dashboard:
      return const ScreenController();
    default:
      return const SplashScreen();
  }
}