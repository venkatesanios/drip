import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../flavors.dart';
import '../../../../view_models/login_view_model.dart';
import '../widgets/continue_button.dart';
import '../widgets/login_header.dart';
import '../widgets/password_input_field.dart';
import '../widgets/phone_input_field.dart';
import 'package:http/http.dart' as http;

class LoginMobile extends StatefulWidget {
  const LoginMobile({super.key});

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  String ioscurrentVersion = "";
  Future<void> checkForUpdate(BuildContext context) async {
    String? latestVersion;

    if (Platform.isAndroid) {
      latestVersion = await fetchLatestVersion('com.niagaraautomations.oroDripirrigation');
      // latestVersion = '1.1.1';
    } else if (Platform.isIOS) {
      latestVersion = await fetchLatestVersionIOS('com.niagaraautomations.oroDripirrigation');
    }

    final currentVersion = await getCurrentVersion();
    print("currentVersion ==> $currentVersion");
    print("latestVersion ==> $latestVersion");
    ioscurrentVersion = currentVersion!;
    if (latestVersion != null && isUpdateRequired(currentVersion, latestVersion)) {
      showUpdateDialog(context);
    }
  }

  Future<String?> fetchLatestVersionIOS(String appId) async {
    // print("fetchLatestVersionIOS");
    final url = 'https://itunes.apple.com/lookup?bundleId=$appId';
    try {
      final response = await http.get(Uri.parse(url));
      print(jsonDecode(response.body));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['resultCount'] > 0) {
          return data['results'][0]['version'] as String;
        }
      }
    } catch (e) {
      print('Error fetching iOS version: $e');
    }
    return null;
  }

  Future<String?> fetchLatestVersion(String packageName) async {

    final url = 'https://play.google.com/store/apps/details?id=$packageName';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final regex = RegExp(r',\[\[\["([0-9,\.]*)"]],');
        final match = regex.firstMatch(response.body);
        if (match != null) {
          return match.group(1);
        }
      }
    } catch (e) {
      print('Error fetching version: $e');
    }
    return null;
  }

  Future<String?> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      print('Error fetching release version: $e');
      return null;
    }
  }

  bool isUpdateRequired(String currentVersion, String latestVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> latest = latestVersion.split('.').map(int.parse).toList();

    while (current.length < latest.length) current.insert(0, 0);
    while (latest.length < current.length) latest.add(0);

    for (int i = 0; i < latest.length; i++) {
      if (latest[i] > current[i]) {
        return true;
      } else if (latest[i] < current[i]) {
        return false;
      }
    }
    return false;
  }

  void showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Available"),
        content: const Text("A newer version of the app is available. Please update to continue."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Later"),
          ),
          TextButton(
            onPressed: () {
              final url = Platform.isAndroid
                  ? "https://play.google.com/store/apps/details?id=com.niagaraautomations.oro"
                  : "https://apps.apple.com/app/id6502343441";
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkForUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    final isOro = F.appFlavor!.name.contains('oro');

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).primaryColor,
          child: SingleChildScrollView(
            child: Column(
              children: [
                isOro ? const OroLoginHeader() : const LkLoginHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PhoneInputField(isWeb: false),
                        const SizedBox(height: 15),
                        const PasswordInputField(isWeb: false),
                        if (viewModel.errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 40, top: 8),
                            child: Text(
                              viewModel.errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 20),
                        const ContinueButton(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}