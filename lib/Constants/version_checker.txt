import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class VersionChecker {
  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final currentVersion = await getCurrentVersion();
      String? latestVersion;

      if (Platform.isAndroid) {
        latestVersion = await fetchLatestVersion('com.niagaraautomations.oro');
      } else if (Platform.isIOS) {
        latestVersion = await fetchLatestVersionIOS('com.niagaraautomations.oro');
      }

      if (latestVersion != null && currentVersion != null && isUpdateRequired(currentVersion, latestVersion)) {
        showUpdateDialog(context);
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  Future<String?] getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      debugPrint('Error fetching current version: $e');
      return null;
    }
  }

  Future<String?> fetchLatestVersion(String packageName) async {
    final url = 'https://play.google.com/store/apps/details?id=$packageName';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final regex = RegExp(r',\[\[\["([0-9,\.]*)"]],');
        final match = regex.firstMatch(response.body);
        return match?.group(1);
      }
    } catch (e) {
      debugPrint('Error fetching Android version: $e');
    }
    return null;
  }

  Future<String?> fetchLatestVersionIOS(String appId) async {
    final url = 'https://itunes.apple.com/lookup?bundleId=$appId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['resultCount'] > 0) {
          return data['results'][0]['version'] as String;
        }
      }
    } catch (e) {
      debugPrint('Error fetching iOS version: $e');
    }
    return null;
  }

  bool isUpdateRequired(String currentVersion, String latestVersion) {
    try {
      final current = currentVersion.split('.').map(int.parse).toList();
      final latest = latestVersion.split('.').map(int.parse).toList();

      while (current.length < latest.length) current.add(0);
      while (latest.length < current.length) latest.add(0);

      for (var i = 0; i < latest.length; i++) {
        if (latest[i] > current[i]) return true;
        if (latest[i] < current[i]) return false;
      }
      return false;
    } catch (e) {
      debugPrint('Error comparing versions: $e');
      return false;
    }
  }

  void showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: const Text('A new version of the app is available. Please update to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () async {
              final url = Platform.isAndroid
                  ? 'https://play.google.com/store/apps/details?id=com.niagaraautomations.oro'
                  : 'https://apps.apple.com/app/id6502343441';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}