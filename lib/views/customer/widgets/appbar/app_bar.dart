import 'package:flutter/material.dart';
import '../../../../flavors.dart';
import 'app_bar_actions.dart';
import 'app_bar_bottom.dart';

class CustomerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic vm;
  final dynamic currentMaster;
  final dynamic viewedCustomer;
  final dynamic loggedInUser;

  const CustomerAppBar({
    super.key,
    required this.vm,
    required this.currentMaster,
    required this.viewedCustomer,
    required this.loggedInUser,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: F.appFlavor!.name.contains('oro')
          ? Image.asset("assets/png/oro_logo_white.png", width: 70)
          : Image.asset("assets/png/lk_logo_white.png", width: 160),
      actions: [
        CustomerAppBarActions(vm: vm, currentMaster: currentMaster,
            viewedCustomer: viewedCustomer, loggedInUser: loggedInUser),
      ],
      bottom: CustomerAppBarBottom(vm: vm, currentMaster: currentMaster),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}