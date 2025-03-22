import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Screens/Dealer/dealer_definition.dart';
import '../Screens/planning/WeatherScreen.dart';
import '../Screens/planning/names_form.dart';
import '../Screens/planning/valve_group_screen.dart';
import '../view_models/screen_controller_view_model.dart';
import 'admin_dealer/admin_screen_controller.dart';
import 'admin_dealer/dealer_screen_controller.dart';
import 'customer/customer_screen_controller.dart';

class ScreenController extends StatelessWidget {
  const ScreenController({super.key});

  @override
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

          return Scaffold(
            body: controllerScreen(viewModel.userRole!, viewModel.userId!, viewModel.userName!, viewModel.mobileNo!, viewModel.emailId!),
          );
        },
      ),
    );
  }

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
          fromLogin: true,
          emailId: emailId,
        );
      default:
        // return  GroupListScreen(userId: 4, controllerId: 1, deviceId: '',) ;
         return CustomerScreenController(userId: userId,
          customerName: userName,
          mobileNo: mobileNo,
          emailId: emailId,
          customerId: userId,
          fromLogin: true,
        ) ;
    }
  }
}
