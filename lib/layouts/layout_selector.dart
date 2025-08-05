import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/layouts/user_layout.dart';
import '../utils/enums.dart';
import 'base_layout.dart';

class LayoutSelector extends StatelessWidget {
  const LayoutSelector({super.key, required this.userRole});
  final UserRole userRole;

  BaseLayout getLayoutForRole() {
    switch (userRole) {
      case UserRole.admin:
        return const AdminLayout();
      case UserRole.dealer:
        return const DealerLayout();
      case UserRole.customer:
      case UserRole.subUser:
        return const CustomerLayout();
      case UserRole.superAdmin:
        throw UnimplementedError('SuperAdmin layout not implemented');
    }
  }

  @override
  Widget build(BuildContext context) {
    return getLayoutForRole();
  }
}