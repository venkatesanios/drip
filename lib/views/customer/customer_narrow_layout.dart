import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/customer/scheduled_program/scheduled_program_narrow.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/app_bar_action.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/app_bar_logo.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/app_bar_drop_down_menu.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/customer_drawer.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/customer_fab_menu.dart';
import 'package:provider/provider.dart';

import '../../Screens/Logs/irrigation_and_pump_log.dart';
import '../../flavors.dart';
import '../../layouts/layout_selector.dart';
import '../../modules/PumpController/view/pump_controller_home.dart';
import '../../providers/user_provider.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';
import '../../view_models/bottom_nav_view_model.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import 'controller_settings/settings_menu_narrow.dart';

class CustomerNarrowLayout extends StatefulWidget {
  const CustomerNarrowLayout({super.key});

  @override
  State<CustomerNarrowLayout> createState() => _CustomerNarrowLayoutState();
}

class _CustomerNarrowLayoutState extends State<CustomerNarrowLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void callbackFunction(String status) {
    if (status == 'Program created') {
      final viewModel = Provider.of<CustomerScreenControllerViewModel>(context, listen: false);
      final viewedCustomer = Provider.of<UserProvider>(context, listen: false).viewedCustomer;
      if (viewedCustomer != null) {
        viewModel.getAllMySites(context, viewedCustomer.id, preserveSelection: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = context.read<UserProvider>().loggedInUser;
    final viewedCustomer = context.read<UserProvider>().viewedCustomer;

    final navModel = context.watch<BottomNavViewModel>();
    final vm = context.watch<CustomerScreenControllerViewModel>();

    final cM = vm.mySiteList.data[vm.sIndex].master[vm.mIndex];

    final isGem = [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList]
        .contains(cM.modelId);

    List<Widget> pages = [];

    if (isGem) {
      pages = [
        const DashboardLayoutSelector(userRole: UserRole.customer),
        Consumer<CustomerScreenControllerViewModel>(
          builder: (context, viewModel, _) {
            final master =
            viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex];
            return ScheduledProgramNarrow(
              userId: loggedInUser.id,
              customerId: viewedCustomer!.id,
              currentLineSNo: cM.irrigationLine[vm.lIndex].sNo,
              groupId: vm.mySiteList.data[vm.sIndex].groupId,
              master: master,
            );
          },
        ),
        IrrigationAndPumpLog(
          userData: {
            'userId': loggedInUser.id,
            'controllerId': cM.controllerId,
            'customerId': vm.mySiteList.data[vm.sIndex].customerId
          },
          masterData: cM,
        ),
        const SettingsMenuNarrow()
      ];
    } else {
      pages = [
        PumpControllerHome(
          userId: loggedInUser.id,
          customerId: viewedCustomer!.id,
          masterData: cM,
        )
      ];
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: appBarLogo(),
        actions: [
          ...appBarActions(context, vm, cM, true),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: appBarDropDownMenu(context, vm, cM),
        ),
      ),
      endDrawer: CustomerDrawer(
        viewedCustomer: viewedCustomer,
        loggedInUser: loggedInUser,
        vm: vm,
      ),
      floatingActionButton: CustomerFabMenu(
        currentMaster: cM,
        viewedCustomer: viewedCustomer,
        loggedInUser: loggedInUser,
        vm: vm,
        callbackFunction: callbackFunction,
      ),
      body: IndexedStack(
        index: navModel.index,
        children: pages,
      ),
      bottomNavigationBar: isGem ? BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navModel.index,
        onTap: navModel.setIndex,
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Scheduled Program',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_gmailerrorred),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      )
          : null,
    );
  }

  void openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer(); // ✅ opens the drawer programmatically
  }
}