import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layouts/layout_selector.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../utils/enums.dart';
import '../utils/shared_preferences_helper.dart';
import 'common/login/login_screen.dart';

class ScreenController extends StatelessWidget {
  const ScreenController({super.key});

  Future<bool> initializeUser(BuildContext context) async {
    final token = await PreferenceHelper.getToken();
    if (token == null || token.isEmpty) return false;

    final roleString = await PreferenceHelper.getUserRole();
    final userId = await PreferenceHelper.getUserId();
    final userName = await PreferenceHelper.getUserName();
    final countryCode = await PreferenceHelper.getCountryCode();
    final mobile = await PreferenceHelper.getMobileNumber();
    final email = await PreferenceHelper.getEmail();
    final role = getRoleFromString(roleString);
    final user = UserModel(
      token: token,
      id: userId ?? 0,
      name: userName ?? '',
      role: role,
      countryCode: countryCode ?? '',
      mobileNo: mobile ?? '',
      email: email ?? '',
    );

    final userProvider = context.read<UserProvider>();
    userProvider.setLoggedInUser(user);
    context.read<UserProvider>().pushViewedCustomer(user);

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

        if (snapshot.hasData && snapshot.data == false) {
          return const LoginScreen();
        }

        final userRole = context.read<UserProvider>().loggedInUser.role;
        return LayoutSelector(userRole: userRole);
      },
    );
  }
}