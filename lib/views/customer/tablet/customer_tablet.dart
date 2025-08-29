import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../customer_screen_controller.dart';

class CustomerTablet extends StatelessWidget {
  const CustomerTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedInUser = Provider.of<UserProvider>(context).loggedInUser;
    final viewedCustomer = Provider.of<UserProvider>(context).viewedCustomer;
    return ChangeNotifierProvider(
      create: (_) => CustomerScreenControllerViewModel(context, Repository(HttpService()),
        Provider.of<MqttPayloadProvider>(context, listen: false),
      )..getAllMySites(context, viewedCustomer.id),
      child: CustomerScreenController(
        userId: loggedInUser.id,
        customerName: viewedCustomer!.name,
        mobileNo: viewedCustomer.mobileNo,
        emailId: viewedCustomer.email,
        customerId: viewedCustomer.id,
        fromLogin: true,
      ),
    );
  }
}