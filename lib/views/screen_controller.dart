import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/mobile/mobile_screen_controller.dart';
import 'package:provider/provider.dart';
import '../view_models/screen_controller_view_model.dart';
import 'admin_dealer/admin_screen_controller.dart';
import 'admin_dealer/dealer_screen_controller.dart';
import 'customer/customer_screen_controller.dart';

class ScreenController extends StatelessWidget {
  const ScreenController({super.key});

  @override
  Widget build(BuildContext context) {
    print('Screen controller loaded');
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
         return kIsWeb?
         CustomerScreenController(userId: userId,
          customerName: userName,
          mobileNo: mobileNo,
          emailId: emailId,
          customerId: userId,
          fromLogin: true,
        ):
         MobileScreenController(userId: userId,
             customerName: userName,
             mobileNo: mobileNo,
             emailId: emailId,
             customerId: userId,
             fromLogin: true
         );
    }
  }
}

