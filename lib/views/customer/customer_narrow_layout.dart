import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/customer/scheduled_program/scheduled_program_narrow.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/app_bar_action.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/app_bar_logo.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/app_bar_bottom_bar.dart';
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

class CustomerNarrowLayout extends StatelessWidget {
  const CustomerNarrowLayout({super.key});

  @override
  Widget build(BuildContext context) {

    final loggedInUser = context.read<UserProvider>().loggedInUser;
    final viewedCustomer = context.read<UserProvider>().viewedCustomer;

    final navModel = context.watch<BottomNavViewModel>();
    final vm = context.watch<CustomerScreenControllerViewModel>();

    if (vm.isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Image.asset(F.appFlavor!.name.contains('oro') ?
        'assets/oro_store.png':'assets/smartcomm_playstore.png',width: 175, height: 175)),
      );
    }

    List<Widget> pages = [];

    final cM = vm.mySiteList.data[vm.sIndex].master[vm.mIndex];
    final isGem = [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(cM.modelId);

    if(isGem){
      pages = [
        const DashboardLayoutSelector(userRole: UserRole.customer),
        ScheduledProgramNarrow(
          userId: loggedInUser.id,
          customerId: viewedCustomer!.id,
          currentLineSNo: cM.irrigationLine[vm.lIndex].sNo,
          groupId: vm.mySiteList.data[vm.sIndex].groupId,
          master: cM,
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
    }else{
      pages = [
        PumpControllerHome(
          userId: loggedInUser.id,
          customerId: viewedCustomer!.id,
          masterData: cM,
        )
      ];
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: appBarLogo(),
        actions: appBarActions(context, vm, cM, loggedInUser, viewedCustomer),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: appBarBottomBar(context, vm, cM),
        ),
      ),
      drawer: CustomerDrawer(viewedCustomer: viewedCustomer, loggedInUser: loggedInUser, vm: vm),
      floatingActionButton: CustomerFabMenu(currentMaster: cM, viewedCustomer: viewedCustomer,
          loggedInUser: loggedInUser, vm: vm, callbackFunction: callbackFunction),
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
      ) :
      null,
    );
  }

  void callbackFunction(message){
  }
}

/*
@override
Widget build(BuildContext context) {
  final vm = context.watch<CustomerScreenControllerViewModel>();
  final loggedInUser = context.read<UserProvider>().loggedInUser;
  final vC = context.read<UserProvider>().viewedCustomer;
  final commMode = context.watch<CustomerProvider>().controllerCommMode;

  if (vm.isLoading) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset(F.appFlavor!.name.contains('oro') ?
      'assets/oro_store.png':'assets/smartcomm_playstore.png',width: 175, height: 175)),
    );
  }

  final cM = vm.mySiteList.data[vm.sIndex].master[vm.mIndex];

  return Scaffold(
    backgroundColor: Colors.grey.shade100,

    appBar: AppBar(
      title: appBarLogo(),
      actions: appBarActions(context, vm, cM, loggedInUser, vC),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: appBarBottomBar(context, vm, cM),
      ),
    ),

    drawer: CustomerDrawer(viewedCustomer: vC, loggedInUser: loggedInUser, vm: vm),

    floatingActionButton: CustomerFabMenu(currentMaster: cM, viewedCustomer: vC, loggedInUser: loggedInUser,
        vm: vm, callbackFunction: callbackFunction),

    bottomNavigationBar: [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(cM.modelId) ?
    BottomNavigationBar(
      backgroundColor: Theme.of(context).primaryColor,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      currentIndex: vm.selectedIndex,
      onTap: vm.onItemTapped,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "Scheduled Program"),
        BottomNavigationBarItem(icon: Icon(Icons.report_gmailerrorred), label: "Log"),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
      ],
    ) : null,

    body: ![...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(cM.modelId) ?
    vm.isChanged ? PumpControllerHome(
      userId: loggedInUser.id,
      customerId: vC!.id,
      masterData: cM,
    ) :
    const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please wait...'),
            SizedBox(height: 10),
            CircularProgressIndicator(),
          ],
        ),
      ),
    ) :
    RefreshIndicator(
      onRefresh: () => vm.onRefreshClicked(),
      child: Column(
        children: [
          if ([...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(cM.modelId)) ...[
            const NetworkConnectionBanner(),
            if (commMode == 2) ...[
              Container(
                width: double.infinity,
                color: Colors.black38,
                child: const Padding(
                  padding: EdgeInsets.only(top: 3, bottom: 4),
                  child: Text(
                    'Bluetooth mode enabled. Please ensure Bluetooth is connected.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ),
              ),
            ],

            if (vm.isNotCommunicate)
              Container(
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.red.shade200,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'NO COMMUNICATION TO CONTROLLER',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              )
            else if (vm.powerSupply == 0)
              Container(
                height: 25,
                color: Colors.red.shade300,
                child: const Center(
                  child: Text(
                    'NO POWER SUPPLY TO CONTROLLER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(),
          ],
          Expanded(
            child: Builder(
              builder: (context) {

                switch (vm.selectedIndex) {
                  case 0:
                    return const CustomerDashboardLayout();
                    return CustomerHome(
                      customerId: loggedInUser.id,
                      controllerId: cM.controllerId,
                      deviceId: cM.deviceId,
                      modelId: cM.modelId,
                    );
                  case 1:
                    return ScheduledProgram(
                      userId: loggedInUser.id,
                      scheduledPrograms: cM.programList,
                      controllerId: cM.controllerId,
                      deviceId: cM.deviceId,
                      customerId: vC!.id,
                      currentLineSNo: cM.irrigationLine[vm.lIndex].sNo,
                      groupId: vm.mySiteList.data[vm.sIndex].groupId,
                      categoryId: cM.categoryId,
                      modelId: cM.modelId,
                      deviceName: cM.deviceName,
                      categoryName: cM.categoryName,
                    );
                  case 2:
                    return IrrigationAndPumpLog(
                      userData: {
                        'userId': loggedInUser.id,
                        'controllerId': cM.controllerId,
                        'customerId': vC!.id
                      },
                      masterData: cM,
                    );
                  default:
                    return ControllerSettings(
                      customerId: vC!.id,
                      userId: loggedInUser.id,
                      masterController: cM,
                    );
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}*/
