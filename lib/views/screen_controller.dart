import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/mobile/mobile_screen_controller.dart';
import 'package:provider/provider.dart';
import '../StateManagement/mqtt_payload_provider.dart';
import '../layouts/layout_selector.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../repository/repository.dart';
import '../services/http_service.dart';
import '../utils/enums.dart';
import '../utils/shared_preferences_helper.dart';
import '../view_models/customer/customer_screen_controller_view_model.dart';
import 'admin_dealer/admin_screen_controller.dart';
import 'admin_dealer/dealer_screen_controller.dart';
import 'customer/customer_screen_controller.dart';

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
    userProvider.setViewedCustomer(user);


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

        final user = context.watch<UserProvider>().loggedInUser;
        return ScreenLayoutSelector(userRole: user.role);

      },
    );
  }


  /*@override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => ScreenControllerViewModel(),
      child: Consumer<ScreenControllerViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.userId == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Web vs Mobile check
          if (!kIsWeb && viewModel.userRole != 'admin' && viewModel.userRole != 'dealer') {
            return ChangeNotifierProvider(
              create: (_) => CustomerScreenControllerViewModel(
                context,
                Repository(HttpService()),
                Provider.of<MqttPayloadProvider>(context, listen: false),
              )..getAllMySites(context, viewModel.userId!),
              child: MobileScreenController(
                customerId: viewModel.userId!,
                customerName: viewModel.userName!,
                mobileNo: viewModel.mobileNo!,
                emailId: viewModel.emailId!,
                userId: viewModel.userId!,
                fromLogin: true,
              ),
            );
          }

          return Scaffold(
            body: controllerScreen(
              viewModel.userRole!,
              viewModel.userId!,
              viewModel.userName!,
              viewModel.mobileNo!,
              viewModel.emailId!,
            ),
          );
        },
      ),
    );
  }*/

  Widget controllerScreen(String userRole, int userId, String userName, String mobileNo, String emailId) {
    switch (userRole) {
      case 'admin':
        return AdminScreenController(
          userId: userId,
          userName: userName,
          mobileNo: mobileNo,
          emailId: emailId,
        );
      case 'dealer':
        return DealerScreenController(
          userId: userId,
          userName: userName,
          mobileNo: mobileNo,
          emailId: emailId,
          fromLogin: true,
        );
      default:
        return CustomerScreenController(
          userId: userId,
          customerName: userName,
          mobileNo: mobileNo,
          emailId: emailId,
          customerId: userId,
          fromLogin: true,
        );
    }
  }
}

