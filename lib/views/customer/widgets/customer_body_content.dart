import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/side_action_menu.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/customer_provider.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../../view_models/nav_rail_view_model.dart';
import 'connection_banner.dart';
import 'navigation_rail_destination.dart';

class CustomerBodyContent extends StatelessWidget {
  final bool isGem;
  final double screenWidth;
  final double screenHeight;
  final Function(String) callbackFunction;
  final CustomerScreenControllerViewModel vm;
  final NavRailViewModel navModel;
  final Widget Function() buildMainScreen;

  const CustomerBodyContent({
    super.key,
    required this.isGem,
    required this.screenWidth,
    required this.screenHeight,
    required this.callbackFunction,
    required this.vm,
    required this.navModel,
    required this.buildMainScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavigationRail(
            selectedIndex: navModel.selectedIndex,
            labelType: NavigationRailLabelType.all,
            elevation: 5,
            onDestinationSelected: navModel.onDestinationSelectingChange,
            destinations: NavigationDestinationsBuilder.build(
              context,
              vm.mySiteList.data[vm.sIndex].master[vm.mIndex],
            ),
          ),
          Container(
            width: isGem ? screenWidth - 140 :
            screenWidth <= 600 ? screenWidth : screenWidth - 80,
            height: screenHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Column(
              children: [
                if (isGem)
                  Consumer<CustomerProvider>(
                    builder: (_, customerProvider, __) {
                      final mode = customerProvider.controllerCommMode ?? 0;
                      return ConnectionBanner(vm: vm, commMode: mode);
                    },
                  ),
                Expanded(
                  child: Builder(
                    builder: (_) => buildMainScreen(),
                  ),
                ),
              ],
            ),
          ),
          if (isGem)
            SideActionMenu(
              screenHeight: screenHeight,
              callbackFunction: callbackFunction,
            ),
        ],
      ),
    );
  }
}