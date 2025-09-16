import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/customer/send_and_received/sent_and_received.dart';
import 'package:oro_drip_irrigation/views/customer/site_config.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/app_bar_action.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/app_bar_drop_down_menu.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/navigation_rail_destination.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/side_action_menu.dart';
import 'package:provider/provider.dart';

import '../../Screens/Dealer/sevicecustomer.dart';
import '../../Screens/Logs/irrigation_and_pump_log.dart';
import '../../Screens/planning/WeatherScreen.dart';
import '../../models/customer/site_model.dart';
import '../../modules/PumpController/view/pump_controller_home.dart';
import '../../providers/user_provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../view_models/nav_rail_view_model.dart';
import 'controller_settings/wide/controller_settings_wide.dart';
import 'customer_home.dart';
import 'customer_product.dart';

class CustomerWideLayout extends StatefulWidget {
  const CustomerWideLayout({super.key});

  @override
  State<CustomerWideLayout> createState() => _CustomerWideLayoutState();
}

class _CustomerWideLayoutState extends State<CustomerWideLayout> {

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

    final navModel = context.watch<NavRailViewModel>();
    final vm = context.watch<CustomerScreenControllerViewModel>();

    if(vm.isLoading){
      return const Scaffold(body: Center(child: Text('Site loading please waite....')));
    }

    final cSite = vm.mySiteList.data[vm.sIndex];
    final cM = cSite.master[vm.mIndex];

    final isGem = [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(cM.modelId);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return  Scaffold(
      appBar: AppBar(
          title:  appBarDropDownMenu(context, vm, cM),
          leadingWidth: 75,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                tileMode: TileMode.clamp,
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor],
              ),
            ),
          ),
          actions: appBarActions(context, vm, cM, false),
        ),
      extendBody: true,
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NavigationRail(
              selectedIndex: navModel.selectedIndex,
              labelType: NavigationRailLabelType.all,
              elevation: 5,
              onDestinationSelected: (int index) {
                navModel.onDestinationSelectingChange(index);
              },
              destinations: NavigationDestinationsBuilder.build(context, cM),
            ),
            Container(
              width: isGem ? screenWidth-140 : screenWidth <= 600 ? screenWidth : screenWidth - 80,
              height:  screenHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
              ),
              child: Column(
                children: [
                  if (isGem) ...[
                    if (vm.isNotCommunicate)
                      Container(
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Colors.red.shade300,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'NO COMMUNICATION TO CONTROLLER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      )
                    else if (vm.powerSupply == 0)
                      Container(
                        height: 23.0,
                        decoration: BoxDecoration(
                          color: Colors.red.shade300,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'NO POWER SUPPLY TO CONTROLLER',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(),
                  ],

                  Expanded(
                    child: Builder(
                      builder: (_) {
                        return mainScreen(
                          navModel.selectedIndex,
                          cSite.groupId,
                          cSite.groupName,
                          cM,
                          cSite.master,
                          vm.isChanged,
                          loggedInUser.role,
                          vm.mySiteList.data[vm.sIndex].customerId,
                          vm.mySiteList.data[vm.sIndex].customerName,
                          viewedCustomer!.id,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (isGem) ...[
              SideActionMenu(
                screenHeight: screenHeight,
                callbackFunction: callbackFunction,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget mainScreen(int index, int groupId, String groupName, MasterControllerModel currentMaster,
      List<MasterControllerModel> allMaster, bool isChanged,
      UserRole role, int customerId, String customerName, int userId) {

    final isGem = [1, 2, 3, 4].contains(currentMaster.modelId);
    final isNova = [56, 57, 58, 59].contains(currentMaster.modelId);

    switch (index) {
      case 0:
        return [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId) ?
        CustomerHome(
          customerId: customerId,
          controllerId: currentMaster.controllerId,
          deviceId: currentMaster.deviceId,
          modelId: currentMaster.modelId,
        ) :
        isChanged ? PumpControllerHome(
          userId: userId,
          customerId: customerId,
          masterData: currentMaster,
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
        );

      case 1:
        return CustomerProduct(customerId: customerId);

      case 2:
        return SentAndReceived(
          customerId: customerId,
          controllerId: currentMaster.controllerId,
          isWide: true,
        );

      case 3:
        return (isGem || isNova) ? IrrigationAndPumpLog(
          userData: {
            'userId': userId,
            'controllerId': currentMaster.controllerId,
            'customerId': customerId,
          },
          masterData: currentMaster,
        ) :
        ControllerSettingWide(
          userId: userId,
          customerId: customerId,
          masterController: currentMaster,
        );

      case 4:
        return (isGem || isNova) ? ControllerSettingWide(
          userId: userId,
          customerId: customerId,
          masterController: currentMaster,
        ) :
        role == UserRole.admin ? SiteConfig(
          userId: userId,
          customerId: customerId,
          customerName: customerName,
          groupId: groupId,
          groupName: groupName,
        ) :
        _PasswordProtectedSiteConfig(
          userId: userId,
          customerId: customerId,
          customerName: customerName,
          allMaster: allMaster,
          groupId: groupId,
          groupName: groupName,
        );

      case 5:
        return (isGem || isNova) ? (role == UserRole.admin ? SiteConfig(
          userId: userId,
          customerId: customerId,
          customerName: customerName,
          groupId: groupId,
          groupName: groupName,
        ) : _PasswordProtectedSiteConfig(
          userId: userId,
          customerId: customerId,
          customerName: customerName,
          allMaster: allMaster,
          groupId: groupId,
          groupName: groupName,
        ))
            : TicketHomePage(
          userId: customerId,
          controllerId: currentMaster.controllerId,
        );

      case 6:
        return TicketHomePage(
          userId: customerId,
          controllerId: currentMaster.controllerId,
        );

      case 7:
        return WeatherScreen(
          userId: customerId,
          controllerId: currentMaster.controllerId,
          deviceID: currentMaster.deviceId,
        );

      default:
        return const Scaffold(
          body: Center(
            child: Text("Invalid screen index"),
          ),
        );
    }
  }
}

class _PasswordProtectedSiteConfig extends StatefulWidget {
  final int userId;
  final int customerId;
  final String customerName;
  final List<MasterControllerModel> allMaster;
  final int groupId;
  final String groupName;

  const _PasswordProtectedSiteConfig({
    Key? key,
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.allMaster,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  State<_PasswordProtectedSiteConfig> createState() =>
      _PasswordProtectedSiteConfigState();
}

class _PasswordProtectedSiteConfigState
    extends State<_PasswordProtectedSiteConfig> {
  bool _authorized = false;

  @override
  void initState() {
    super.initState();
    // show password dialog after first build
    WidgetsBinding.instance.addPostFrameCallback((_) => _askPassword());
  }

  Future<void> _askPassword() async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final userPsw = controller.text;

                try {
                  final Repository repository = Repository(HttpService());
                  var getUserDetails = await repository.checkpassword({
                    "passkey": userPsw,
                  });

                  if (getUserDetails.statusCode == 200) {
                    var jsonData = jsonDecode(getUserDetails.body);
                    print("jsonData $jsonData");

                    if (jsonData['code'] == 200) {
                      print("getUserDetails.body: ${getUserDetails.body}");
                      if (ctx.mounted) Navigator.pop(ctx, true); // ✅ close dialog safely
                    } else {
                      if (ctx.mounted) Navigator.pop(ctx, false); // wrong password
                    }
                  }
                } catch (e, stackTrace) {
                  print('Error getData => ${e.toString()}');
                  print('Trace getData => $stackTrace');
                  if (ctx.mounted) Navigator.pop(ctx, false);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() => _authorized = true);
    } else {
      // Wrong password → show error
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Incorrect Password!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authorized) {
      return SiteConfig(
        userId: widget.userId,
        customerId: widget.customerId,
        customerName: widget.customerName,
        groupId: widget.groupId,
        groupName: widget.groupName,
      );
    }
    return const SizedBox.shrink(); // empty until password is validated
  }
}