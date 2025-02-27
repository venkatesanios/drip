import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/screen_controller_view_model.dart';
import 'admin_dealer/admin_screen_controller.dart';
import 'admin_dealer/dealer_screen_controller.dart';

class ScreenController extends StatelessWidget {
  const ScreenController({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => ScreenControllerViewModel(),
      child: Consumer<ScreenControllerViewModel>(
        builder: (context, viewModel, _) {

          debugPrint(viewModel.userId.toString());
          if (viewModel.userId == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                viewModel.isNetworkConnected?
                const SizedBox():
                Container(
                  color: Colors.red.shade100,
                  width: MediaQuery.sizeOf(context).width,
                  height: 25,
                  child: const Center(child: Text('No network connection')),
                ),
                Expanded(child: controllerScreen(viewModel.userRole!, viewModel.userId!, viewModel.userName!, viewModel.mobileNo!, viewModel.emailId!)),
              ],
            ),
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
        return const SizedBox();
    }
  }
}
