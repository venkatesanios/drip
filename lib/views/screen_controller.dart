import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layouts/layout_selector.dart';
import '../providers/user_provider.dart';
import '../repository/repository.dart';
import '../utils/auth_pref_checker.dart';
import '../utils/enums.dart';
import '../utils/shared_preferences_helper.dart';
import 'common/login/login_screen.dart';

class ScreenController extends StatelessWidget {
  const ScreenController({super.key});


  Future<bool> initializeUser(BuildContext context) async {

    final user = await AuthPrefChecker.getLoggedInUser();
    if (user == null) return false;

    context.read<UserProvider>().setLoggedInUser(user);
    context.read<UserProvider>().pushViewedCustomer(user);

    // Validate ONLY password-login users
    if (user.password.isNotEmpty) {
      try {
        final response = await context.read<ApiRepository>().validateUser({
          'userId': user.id,
          'password': user.password,
        });
        final data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['code'] == 200) {
          return true;
        }else{
          await PreferenceHelper.clearAll();
          return false;
        }
      } catch (e) {
        debugPrint('Validation skipped: $e');
        await PreferenceHelper.clearAll();
        return false;
      }
    }

    return true;
  }

  UserRole getRoleFromString(String? role) {
    switch (role?.toLowerCase()) {
      case '0':
        return UserRole.superAdmin;
      case '1':
        return UserRole.admin;
      case '2':
        return UserRole.dealer;
      case '3':
        return UserRole.customer;
      case 'sub user':
        return UserRole.subUser;
      default:
        return UserRole.customer;
    }
  }


  @override
  Widget build(BuildContext context) {

    return FutureBuilder<bool>(
      future: initializeUser(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != true) {
          return const LoginScreen();
        }

        final userData = context.read<UserProvider>().loggedInUser;

        return UserLayoutSelector(userRole: userData.role);
      },
    );
  }
}