import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../utils/constants.dart';
import '../../../utils/my_helper_class.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../../view_models/nav_rail_view_model.dart';
import '../widgets/customer_app_bar.dart';
import '../widgets/customer_body_content.dart';
import '../widgets/customer_main_screen.dart';

class CustomerScreenMiddle extends StatefulWidget {
  const CustomerScreenMiddle({super.key});

  @override
  State<CustomerScreenMiddle> createState() => _CustomerScreenMiddleState();
}

class _CustomerScreenMiddleState extends State<CustomerScreenMiddle> with ProgramRefreshMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void callbackFunction(String status) {
    if (status == 'Program created' && mounted) onProgramCreated(context);
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = context.read<UserProvider>().loggedInUser;
    final navModel = context.watch<NavRailViewModel>();
    final vm = context.watch<CustomerScreenControllerViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: Text('Site loading, please wait...')),
      );
    }

    final cSite = vm.mySiteList.data[vm.sIndex];
    final cM = cSite.master[vm.mIndex];
    final isGem = [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList,].contains(cM.modelId);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: buildCustomerAppBar(context, vm, cM, _scaffoldKey, showMenu: false, isNarrow: false),
      extendBody: true,
      body: CustomerBodyContent(
        isGem: isGem,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        callbackFunction: callbackFunction,
        vm: vm,
        navModel: navModel,
        buildMainScreen: () => buildCustomerMainScreen(
          index: navModel.selectedIndex,
          role: loggedInUser.role,
          userId: loggedInUser.id,
          vm: vm,
        ),
      ),
    );
  }
}