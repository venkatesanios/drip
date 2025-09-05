import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';
import 'package:oro_drip_irrigation/Constants/notifications_service.dart';
import 'package:oro_drip_irrigation/modules/config_Maker/view/config_base_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Screens/Dealer/bLE_update.dart';
import '../Screens/Dealer/ble_controllerlog_ftp.dart';
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
  PackageInfo? _packageInfo;
  bool _hasCheckedVersion = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      NotificationServiceCall().initialize();
      NotificationServiceCall().configureFirebaseMessaging();
    }
  }

  Future<void> checkVersion(BuildContext context) async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      if (_packageInfo == null) {
        debugPrint('Package info not available');
        return;
      }
      if (Platform.isAndroid) {
        AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
        if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
          if (updateInfo.immediateUpdateAllowed) {
            await InAppUpdate.performImmediateUpdate();
          } else if (updateInfo.flexibleUpdateAllowed) {
            await InAppUpdate.startFlexibleUpdate();
            debugPrint('Flexible update started');
          } else {
            debugPrint('Update available, but neither immediate nor flexible updates allowed');
          }
        } else {
          debugPrint('No update available');
        }
      } else if (Platform.isIOS) {
        await Upgrader().initialize();
        if (await Upgrader().isUpdateAvailable()) {
          _showUpdateDialog(context, Upgrader().currentAppStoreListingURL);
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  void _showUpdateDialog(BuildContext context, String? appStoreLink) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: const Text('A new version of the app is available. Please update to continue.'),
        actions: [
          TextButton(
            onPressed: () async {
              if (appStoreLink != null) {
                final Uri url = Uri.parse(appStoreLink);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  debugPrint('Could not launch App Store URL');
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Update Now'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
        ],
      ),
    );
  }

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
          home: Builder(
            builder: (context) {
              if (!_hasCheckedVersion && kReleaseMode) {
                _hasCheckedVersion = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  checkVersion(context);
                });
              }
              return navigateToInitialScreen(snapshot.data ?? Routes.login);
            },
          ),
          onGenerateRoute: Routes.generateRoute,
        );
      },
    );
  }
}

Widget navigateToInitialScreen(String route) {
  switch (route) {
    case Routes.login:
      return const LoginScreen();
    case Routes.dashboard:
      return const ScreenController();
    default:
      return const SplashScreen();
  }
}