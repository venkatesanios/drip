import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_drip_irrigation/Screens/Dealer/dealer_definition.dart';
import 'package:oro_drip_irrigation/view_models/customer/controller_settings_view_model.dart';
import 'package:oro_drip_irrigation/view_models/customer/customer_screen_controller_view_model.dart';
import 'package:oro_drip_irrigation/views/customer/condition_library.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../Screens/Map/CustomerMap.dart';
import '../../Screens/Map/allAreaBoundry.dart';
import '../../Screens/planning/frost_productionScreen.dart';
import '../../Screens/planning/names_form.dart';
import '../../Screens/planning/valve_group_screen.dart';
import '../../Screens/planning/virtual_screen.dart';
import '../../modules/Preferences/view/preference_main_screen.dart';
import '../../modules/SystemDefinitions/view/system_definition_screen.dart';
import '../../modules/calibration/view/calibration_screen.dart';
import '../../modules/constant/view/constant_base_page.dart';
import '../../modules/fertilizer_set/view/fertilizer_Set_screen.dart';
import '../../modules/global_limit/view/global_limit_screen.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../mobile/general_setting.dart';

class ControllerSettings extends StatelessWidget {
  const ControllerSettings({super.key,
    required this.customerId,
    required this.userId,
    required this.masterController,
  });

  final int customerId, userId;
  final MasterControllerModel masterController;


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ControllerSettingsViewModel(Repository(HttpService()))
        ..getSettingsMenu(customerId, masterController.controllerId, masterController.categoryId),
      child: Consumer<ControllerSettingsViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return buildLoadingIndicator(true, MediaQuery.sizeOf(context).width);
          }
          return kIsWeb ? _buildWebView(context, viewModel):
          _buildMobileView(context, viewModel);
        },
      ),
    );
  }

  Widget _buildWebView(BuildContext context, ControllerSettingsViewModel viewModel) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: viewModel.filteredSettingList.length,
        child: Column(
          children: [
            TabBar(
              indicatorColor: Theme.of(context).primaryColorLight,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: viewModel.filteredSettingList.map((tab) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tab['icon'], size: 18),
                      const SizedBox(width: 6),
                      Text(tab['title']),
                    ],
                  ),
                );
              }).toList(),
            ),
            Expanded(
              child: TabBarView(
                children: viewModel.filteredSettingList.map((tab) {
                  return _buildTabContent(context, tab['title']);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context, ControllerSettingsViewModel viewModel) {
    return Scaffold(
      body: ListView.builder(
        itemCount: viewModel.filteredSettingList.length,
        itemBuilder: (context, index) {
          final title = viewModel.filteredSettingList[index]['title'];

          return Column(
            children: [
              ListTile(
                leading: Icon(
                  viewModel.filteredSettingList[index]['icon'],
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  getSubTitle(title),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _navigateToScreen(context, title),
              ),
              if (index < viewModel.filteredSettingList.length - 1)
                const Padding(
                  padding: EdgeInsets.only(left: 40, right: 8),
                  child: Divider(height: 0),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, String title) {
    return _getScreenWidget(title) ?? const SizedBox();
  }

  void _navigateToScreen(BuildContext context, String title) {
    final widget = _getScreenWidget(title);
    if (widget != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => widget),
      );
    }
  }

  Widget? _getScreenWidget(String title) {
    switch (title) {
      case 'General':
        return GeneralSetting(
          customerId: customerId,
          controllerId: masterController.controllerId,
          userId: userId,
        );
      case 'Preference':
        return PreferenceMainScreen(
          userId: userId,
          customerId: customerId,
          masterData: masterController,
          selectedIndex: 0,
        );
      case 'Constant':
        return ConstantBasePage(userData: {
          "userId": customerId,
          "controllerId": masterController.controllerId,
          "deviceId": masterController.deviceId,
          "modelId": masterController.modelId,
          "deviceName": masterController.deviceName,
          "categoryId": masterController.categoryId,
          "categoryName": masterController.categoryName,
        });
      case 'Condition Library':
        return ConditionLibrary(
          customerId: customerId,
          controllerId: masterController.controllerId,
          deviceId: masterController.deviceId,
          userId: userId,
        );
      case 'Name':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Names(
            userID: userId,
            customerID: customerId,
            controllerId: masterController.controllerId,
            menuId: 0,
            imeiNo: masterController.deviceId,
          ),
        );
      case 'Fertilizer Set':
        return FertilizerSetScreen(userData: {
          'userId': userId,
          'controllerId': masterController.controllerId,
          'deviceId': masterController.deviceId,
        });
      case 'Valve Group':
        return GroupListScreen(
          userId: userId,
          controllerId: masterController.controllerId,
          deviceId: masterController.deviceId,
        );
      case 'System Definitions':
        return SystemDefinition(
          userId: userId,
          controllerId: masterController.controllerId,
          deviceId: masterController.deviceId,
          customerId: customerId,
        );
      case 'Global Limit':
        return GlobalLimitScreen(userData: {
          'userId': userId,
          'controllerId': masterController.controllerId,
          'deviceId': masterController.deviceId,
        });
      case 'Virtual Water Meter':
        return VirtualMeterScreen(
          userId: userId,
          controllerId: masterController.controllerId,
          menuId: 67,
          deviceId: masterController.deviceId,
        );
      case 'Frost Protection':
        return FrostMobUI(
          userId: userId,
          controllerId: masterController.controllerId,
          deviceID: masterController.deviceId,
          menuId: 71,
        );
      case 'Calibration':
        return CalibrationScreen(userData: {
          'userId': userId,
          'controllerId': masterController.controllerId,
          'deviceId': masterController.deviceId,
        });
      case 'Dealer Definition':
        return DealerDefinitionInConfig(
          userId: userId,
          customerId: customerId,
          controllerId: masterController.controllerId,
          imeiNo: masterController.deviceId,
        );
      case 'Geography':
        return MapScreenall(
          userId: userId,
          customerId: customerId,
          controllerId: masterController.controllerId,
          imeiNo: masterController.deviceId,
        );
      case 'Geography Area':
        return MapScreenAllArea(
          userId: userId,
          customerId: customerId,
          controllerId: masterController.controllerId,
          imeiNo: masterController.deviceId,
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

  String getSubTitle(String title) {
    switch (title) {
      case 'General':
        return 'Includes controller name, category, model, version, and UTC time settings.';
      case 'Preference':
        return 'Configure pump settings, voltage, current limits, timers, and calibration.';
      case 'Name':
        return 'Change names of pumps, sensors, filters, and other components.';
      case 'Condition Library':
        return 'Sensor-based conditions such as moisture, pressure, time-based triggers, and program ON/OFF logic.';
      default:
        return 'No additional information available.';
    }
  }
}
