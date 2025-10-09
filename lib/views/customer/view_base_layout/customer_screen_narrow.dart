
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/utils/helpers/mc_permission_helper.dart';
import 'package:oro_drip_irrigation/views/customer/scheduled_program/scheduled_program_narrow.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/connection_banner.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/customer_drawer.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/customer_fab_menu.dart';
import 'package:provider/provider.dart';

import '../../../Screens/Logs/irrigation_and_pump_log.dart';
import '../../../StateManagement/customer_provider.dart';
import '../../../Widgets/network_connection_banner.dart';
import '../../../layouts/layout_selector.dart';
import '../../../modules/PumpController/view/pump_controller_home.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/enums.dart';
import '../../../utils/my_helper_class.dart';
import '../../../view_models/bottom_nav_view_model.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../controller_settings/settings_menu_narrow.dart';
import '../widgets/customer_app_bar.dart';
import '../widgets/customer_bottom_nav.dart';
import '../widgets/site_loading_or_empty.dart';
import 'base_customer_layout.dart';

class CustomerScreenNarrow extends StatefulWidget {
  const CustomerScreenNarrow({super.key});

  @override
  State<CustomerScreenNarrow> createState() => _CustomerScreenNarrowState();
}

class _CustomerScreenNarrowState extends BaseCustomerScreenState<CustomerScreenNarrow> {

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final loggedInUser = userProvider.loggedInUser;
    final viewedCustomer = userProvider.viewedCustomer;
    final navModel = context.watch<BottomNavViewModel>();
    final vm = context.watch<CustomerScreenControllerViewModel>();

    if (vm.isLoading) return const SiteLoadingOrEmpty(isLoading: true);
    if (vm.mySiteList.data.isEmpty) return const SiteLoadingOrEmpty(isLoading: false);

    final cM = vm.mySiteList.data[vm.sIndex].master[vm.mIndex];
    final isGem = isGemModel(cM.modelId);

    final pages = isGem ? [
      const DashboardLayoutSelector(userRole: UserRole.customer),
      Consumer<CustomerScreenControllerViewModel>(
        builder: (context, viewModel, _) {
          final master =
          viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex];
          final lines = master.irrigationLine;

          final lineSNo = (viewModel.lIndex < lines.length) ? lines[viewModel.lIndex].sNo : 0;

          return ScheduledProgramNarrow(
            userId: loggedInUser.id,
            customerId: viewedCustomer!.id,
            currentLineSNo: lineSNo.toDouble(),
            groupId: viewModel.mySiteList.data[viewModel.sIndex].groupId,
            master: master,
          );
        },
      ),
      IrrigationAndPumpLog(
        userData: {
          'userId': loggedInUser.id,
          'controllerId': cM.controllerId,
          'customerId': viewedCustomer!.id,
        },
        masterData: cM,
      ),
      const SettingsMenuNarrow(),
    ] :
    [
      PumpControllerHome(
        userId: loggedInUser.id,
        customerId: viewedCustomer!.id,
        masterData: cM,
      ),
    ];

    return BaseCustomerLayout(
      scaffoldKey: scaffoldKey,
      appBar: buildCustomerAppBar(context, vm, cM, scaffoldKey, showMenu: true, isNarrow: true),
      drawer: CustomerDrawer(viewedCustomer: viewedCustomer, loggedInUser: loggedInUser, vm: vm),
      floatingActionButton: CustomerFabMenu(
        currentMaster: cM,
        loggedInUser: loggedInUser,
        vm: vm,
        callbackFunction: callbackFunction,
        myPermissionFlags: [
          cM.getPermissionStatus("Planning"),
          cM.getPermissionStatus("Standalone On/Off"),
          cM.getPermissionStatus("View Controller Log"),
        ],
      ),
      bottomNavigationBar: isGem ? CustomerBottomNav(index: navModel.index, onTap: navModel.setIndex) : null,
      banners: [
        const NetworkConnectionBanner(),
        Consumer<CustomerProvider>(
          builder: (_, provider, __) => ConnectionBanner(vm: vm, commMode: provider.controllerCommMode ?? 0),
        ),
      ],
      body: IndexedStack(index: navModel.index, children: pages),
    );
  }
}