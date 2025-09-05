import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../models/customer/site_model.dart';
import '../../../Screens/Dealer/controllerlogfile.dart';
import '../../../Screens/Dealer/dealer_definition.dart';
import '../../../Screens/Map/CustomerMap.dart';
import '../../../Screens/Map/allAreaBoundry.dart';
import '../../../Screens/planning/PumpCondition.dart';
import '../../../Screens/planning/frost_productionScreen.dart';
import '../../../Screens/planning/names_form.dart';
import '../../../Screens/planning/valve_group_screen.dart';
import '../../../Screens/planning/virtual_screen.dart';
import '../../../modules/Preferences/view/preference_main_screen.dart';
import '../../../modules/SystemDefinitions/view/system_definition_screen.dart';
import '../../../modules/calibration/view/calibration_screen.dart';
import '../../../modules/constant/view/constant_base_page.dart';
import '../../../modules/fertilizer_set/view/fertilizer_Set_screen.dart';
import '../../../modules/global_limit/view/global_limit_screen.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/constants.dart';
import '../../../view_models/customer/controller_settings_view_model.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../crop_advisory_form.dart';
import 'narrow/condition_library_narrow.dart';
import 'narrow/general_settings_narrow.dart';

class SettingsMenuNarrow extends StatelessWidget {
  const SettingsMenuNarrow({super.key});

  @override
  Widget build(BuildContext context) {

    final loggedInUser = Provider.of<UserProvider>(context).loggedInUser;
    final vCustomer = Provider.of<UserProvider>(context).viewedCustomer;

    final cVM = context.watch<CustomerScreenControllerViewModel>();
    final master = cVM.mySiteList.data[cVM.sIndex].master[cVM.mIndex];

    final controllerContext = ControllerContext(
      userId: loggedInUser.id,
      customerId: vCustomer!.id,
      controllerId: master.controllerId,
      categoryId: master.categoryId,
      modelId: master.modelId,
      imeiNo: master.deviceId,
      deviceName: master.deviceName,
      master: master,
      categoryName: master.categoryName,
    );

    final viewModel = context.watch<ControllerSettingsViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.separated(
        itemCount: viewModel.filteredSettingList.length,
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(left: 50, top: 5),
          child: Divider(height : 0, thickness: 0.5, color: Colors.black12),
        ),
        itemBuilder: (context, index) {
          final item = viewModel.filteredSettingList[index];
          final title = item['title'];

          return ListTile(
            visualDensity: const VisualDensity(vertical: -4),
            isThreeLine: true,
            leading: Icon(
              item['icon'],
              color: Theme.of(context).primaryColor,
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              AppConstants.getSettingsSummary(title),
              style: const TextStyle(color: Colors.black45),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToScreen(context, title, controllerContext),
          );
        },
      ),
    );
  }


  void _navigateToScreen(BuildContext context, String title, ControllerContext ctx) {
    final widget = _getScreenWidget(title, ctx);
    if (widget != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => widget));
    }
  }

  Widget? _getScreenWidget(String title, ControllerContext ctx) {
    switch (title) {
      case 'General':
        return GeneralSettingsNarrow(controllerId: ctx.controllerId);
      case 'Preference':
        return PreferenceMainScreen(
          userId: ctx.userId,
          customerId: ctx.customerId,
          masterData: ctx.master,
          selectedIndex: 0,
        );
      case 'Constant':
        return ConstantBasePage(userData: {
          "userId": ctx.userId,
          "customerId": ctx.customerId,
          "controllerId": ctx..controllerId,
          "deviceId": ctx..imeiNo,
          "modelId": ctx..modelId,
          "deviceName": ctx..deviceName,
          "categoryId": ctx..categoryId,
          "categoryName": ctx..categoryName,
        });
      case 'Condition Library':
        return ConditionLibraryNarrow(
          customerId: ctx.customerId,
          controllerId: ctx.controllerId,
          deviceId: ctx.imeiNo,
          userId: ctx.userId,
        );
      case 'Name':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Names(
            userID: ctx.userId,
            customerID: ctx.customerId,
            controllerId: ctx.controllerId,
            menuId: 0,
            imeiNo: ctx.imeiNo,
          ),
        );
      case 'Fertilizer Set':
        return FertilizerSetScreen(userData: {
          'userId': ctx.userId,
          'customerId': ctx.customerId,
          'controllerId': ctx.controllerId,
          'deviceId': ctx.imeiNo,
        });
      case 'Valve Group':
        return GroupListScreen(
          userId: ctx.userId,
          customerId: ctx.customerId,
          controllerId: ctx.controllerId,
          deviceId: ctx.imeiNo,
        );
      case 'System Definitions':
        return SystemDefinition(
          userId: ctx.userId,
          controllerId: ctx.controllerId,
          deviceId: ctx.imeiNo,
          customerId: ctx.customerId,
        );
      case 'Global Limit':
        return GlobalLimitScreen(userData: {
          'userId': ctx.userId,
          'customerId': ctx.customerId,
          'controllerId': ctx.controllerId,
          'deviceId': ctx.imeiNo,
        });
      case 'Virtual Water Meter':
        return VirtualMeterScreen(
          userId: ctx.userId,
          controllerId: ctx.controllerId,
          menuId: 67,
          deviceId: ctx.imeiNo,
        );
      case 'Frost Protection':
        return FrostMobUI(
          userId: ctx.userId,
          controllerId: ctx.controllerId,
          deviceID: ctx.imeiNo,
          menuId: 71,
        );
      case 'Calibration':
        return CalibrationScreen(userData: {
          'userId': ctx.userId,
          'customerId': ctx.customerId,
          'controllerId': ctx.controllerId,
          'deviceId': ctx.imeiNo,
        });
      case 'Dealer Definition':
        return DealerDefinitionInConfig(
          userId: ctx.userId,
          customerId: ctx.customerId,
          controllerId: ctx.controllerId,
          imeiNo: ctx.imeiNo,
        );
      case 'Geography':
        return MapScreenall(
          userId: ctx.userId,
          customerId: ctx.customerId,
          controllerId: ctx.controllerId,
          imeiNo: ctx.imeiNo,
        );
      case 'Geography Area':
        return MapScreenAllArea(
          userId: ctx.userId,
          customerId: ctx.customerId,
          controllerId: ctx.controllerId,
          imeiNo: ctx.imeiNo,
        );
      case 'Pump Condition':
        return PumpConditionScreen(
          userId: ctx.userId,
          customerId: ctx.customerId,
          controllerId: ctx.controllerId,
          imeiNo: ctx.imeiNo,
        );
      case 'Controller Log':
        return ControllerLog(
          deviceID: ctx.imeiNo,
          communicationType: 'MQTT',
        );
      case 'Crop Advisory':
        return CropAdvisoryForm(
            customerId: ctx.userId,
            controllerId: ctx.controllerId
        );
      default:
        return const Center(child: Text('Coming Soon'));
    }
  }


  Widget buildLoadingIndicator(bool isVisible, double width) {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: width / 2 - 25),
        child: const LoadingIndicator(indicatorType: Indicator.ballPulse),
      ),
    );
  }

}

class ControllerContext {
  final int userId;
  final int customerId;
  final int controllerId;
  final int categoryId, modelId;
  final String categoryName, imeiNo, deviceName;
  final MasterControllerModel master;

  ControllerContext({
    required this.userId,
    required this.customerId,
    required this.controllerId,
    required this.categoryId,
    required this.modelId,
    required this.categoryName,
    required this.imeiNo,
    required this.deviceName,
    required this.master,
  });
}
