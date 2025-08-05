import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/utils/enums.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../mobile/mobile_screen_controller.dart';

class CustomerMobile extends StatelessWidget {
  const CustomerMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedInUser = Provider.of<UserProvider>(context).loggedInUser;
    final viewedCustomer = Provider.of<UserProvider>(context).viewedCustomer;
    return ChangeNotifierProvider(
      create: (_) => CustomerScreenControllerViewModel(context, Repository(HttpService()),
        Provider.of<MqttPayloadProvider>(context, listen: false),
      )..getAllMySites(context, viewedCustomer.id),
      child: MobileScreenController(
        userId: viewedCustomer!.id,
        fromLogin: loggedInUser.role == UserRole.customer ? true : false,
      ),
    );
  }
}