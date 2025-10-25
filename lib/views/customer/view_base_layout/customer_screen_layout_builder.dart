import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/customer_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/constants.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../../view_models/nav_rail_view_model.dart';
import '../widgets/connection_banner.dart';
import '../widgets/customer_app_bar.dart';
import '../widgets/customer_main_screen.dart';
import '../widgets/navigation_rail_destination.dart';
import '../widgets/side_action_menu.dart';
import '../widgets/site_loading_or_empty.dart';

class CustomerScreenLayoutBuilder extends StatelessWidget {
  final bool isWide;
  final bool isMiddle;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final void Function(String) callbackFunction;

  const CustomerScreenLayoutBuilder({
    super.key,
    this.isWide = false,
    this.isMiddle = false,
    this.scaffoldKey,
    required this.callbackFunction,
  });

  @override
  Widget build(BuildContext context) {

    final userProvider = context.read<UserProvider>();
    final loggedInUser = userProvider.loggedInUser;

    final vm = context.watch<CustomerScreenControllerViewModel>();
    final navRail = context.watch<NavRailViewModel>();

    if (vm.isLoading) return const SiteLoadingOrEmpty(isLoading: true);
    if (vm.mySiteList.data.isEmpty) return const SiteLoadingOrEmpty(isLoading: false);

    final cMaster = vm.mySiteList.data[vm.sIndex].master[vm.mIndex];
    final isGemRNova = [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList]
        .contains(cMaster.modelId);

    int totalPages = _getTotalPagesCount(vm);
    final pages = List.generate(
      totalPages, (i) => buildCustomerMainScreen(
        index: i,
        role: loggedInUser.role,
        userId: loggedInUser.id,
        vm: vm,
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: buildCustomerAppBar(context, vm, cMaster, scaffoldKey, showMenu: false, isNarrow: false),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavigationRail(
            selectedIndex: navRail.selectedIndex,
            labelType: NavigationRailLabelType.all,
            elevation: 5,
            onDestinationSelected: navRail.onDestinationSelectingChange,
            destinations: NavigationDestinationsBuilder.build(context, cMaster),
          ),
          Expanded(
            child: Column(
              children: [
                Consumer<CustomerScreenControllerViewModel>(
                  builder: (context, viewModel, _) {
                    return viewModel.onRefresh ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: LinearProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                        backgroundColor: Colors.grey[200],
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ) : const SizedBox();
                  },
                ),
                if (isGemRNova)
                  Consumer<CustomerProvider>(
                    builder: (_, provider, __) {
                      final mode = provider.controllerCommMode ?? 0;
                      return ConnectionBanner(vm: vm, commMode: mode);
                    },
                  ),
                Expanded(
                  child: IndexedStack(
                    index: navRail.selectedIndex,
                    children: pages,
                  ),
                ),
              ],
            ),
          ),
          if (isGemRNova && (isMiddle || isWide))
            SideActionMenu(
              screenHeight: MediaQuery.sizeOf(context).height,
              callbackFunction: callbackFunction,
            ),
        ],
      ),
    );
  }

  int _getTotalPagesCount(CustomerScreenControllerViewModel vm) {
    final mId = vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId;
    if ([1, 2, 3, 4, 56, 57, 58, 59].contains(mId)) return 8;
    return 6;
  }
}