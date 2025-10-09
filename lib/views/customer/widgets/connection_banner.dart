import 'package:flutter/material.dart';

import '../../../view_models/customer/customer_screen_controller_view_model.dart';

class ConnectionBanner extends StatelessWidget {
  final CustomerScreenControllerViewModel vm;
  final int commMode;

  const ConnectionBanner({super.key, required this.vm, required this.commMode});

  @override
  Widget build(BuildContext context) {
    if (commMode == 2) {
      return Container(
        width: double.infinity,
        color: Colors.black38,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: const Text(
          'Bluetooth mode enabled. Please ensure Bluetooth is connected.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.white70),
        ),
      );
    }else if (vm.isNotCommunicate) {
      return _buildBanner('NO COMMUNICATION TO CONTROLLER', Colors.red.shade200);
    }else if (vm.powerSupply == 0) {
      return _buildBanner('NO POWER SUPPLY TO CONTROLLER', Colors.red.shade300);
    }
    return const SizedBox();
  }

  Widget _buildBanner(String text, Color color) {
    return Container(
      height: 25,
      color: color,
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.white)),
    );
  }
}