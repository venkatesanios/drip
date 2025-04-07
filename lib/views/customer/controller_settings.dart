import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_drip_irrigation/Models/admin&dealer/dealer_definition_model.dart';
import 'package:oro_drip_irrigation/Models/customer/constant_model.dart';
import 'package:oro_drip_irrigation/Screens/Dealer/dealer_definition.dart';
import 'package:oro_drip_irrigation/view_models/customer/controller_settings_view_model.dart';
import 'package:oro_drip_irrigation/views/customer/condition_library.dart';
import 'package:provider/provider.dart';

import '../../Models/customer/site_model.dart';
import '../../Screens/planning/frost_productionScreen.dart';
import '../../Screens/planning/names_form.dart';
import '../../Screens/planning/valve_group_screen.dart';
import '../../Screens/planning/virtual_screen.dart';
import '../../modules/SystemDefinitions/view/system_definition_screen.dart';
import '../../modules/calibration/view/calibration_screen.dart';
import '../../modules/fertilizer_set/view/fertilizer_Set_screen.dart';
import '../../modules/global_limit/view/global_limit_screen.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../mobile/general_setting.dart';
import 'constant.dart';

class ControllerSettings extends StatelessWidget {
  const ControllerSettings({super.key, required this.customerId, required this.controllerId, required this.adDrId, required this.userId, required this.deviceId});
  final int customerId, controllerId, adDrId, userId;
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ControllerSettingsViewModel(Repository(HttpService()))
        ..getSettingsMenu(customerId, controllerId),
      child: Consumer<ControllerSettingsViewModel>(
        builder: (context, viewModel, _) {
          return viewModel.isLoading?
          buildLoadingIndicator(true, MediaQuery.sizeOf(context).width):
          kIsWeb? Scaffold(
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
                          mainAxisSize: MainAxisSize.min, // Prevents excessive spacing
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
                        final String title = tab['title'];
                        switch (title) {
                          case 'General':
                            return GeneralSetting(
                              customerId: customerId,
                              controllerId: controllerId,
                              adDrId: adDrId,
                              userId: adDrId,
                            );
                          case 'Constant':
                            return Constant(
                              customerId: customerId,
                              controllerId: controllerId,
                              userId: adDrId,
                            );
                          case 'Condition Library':
                            return ConditionLibrary(
                              customerId,
                              controllerId,
                              adDrId,
                              deviceId: deviceId,
                            );
                          case 'Name':
                            return Names(
                              userID: userId,
                              customerID: customerId,
                              controllerId: controllerId,
                              menuId: 0,
                              imeiNo: deviceId,
                            );
                          case 'Fertilizer Set':
                            return FertilizerSetScreen(
                              userData: {
                                'userId': userId,
                                'controllerId': controllerId,
                                'deviceId': deviceId,
                              },
                            );
                          case 'Valve Group':
                            return GroupListScreen(
                              userId: userId,
                              controllerId: controllerId,
                              deviceId: deviceId,
                            );
                          case 'System Definitions':
                            return SystemDefinition(
                              userId: userId,
                              controllerId: controllerId,
                              deviceId: deviceId,
                              customerId: customerId,
                            );
                          case 'Global Limit':
                            return GlobalLimitScreen(
                              userData: {
                                'userId': userId,
                                'controllerId': controllerId,
                                'deviceId': deviceId,
                              },
                            );
                          case 'Virtual Water Meter':
                            return VirtualMeterScreen(
                              userId: userId,
                              controllerId: controllerId,
                              menuId: 67,
                              deviceId: deviceId,
                            );
                          case 'Frost Protection':
                            return FrostMobUI(
                              userId: userId,
                              controllerId: controllerId,
                              deviceID: deviceId,
                              menuId: 71,
                            );
                          case 'Calibration':
                            return CalibrationScreen(
                              userData: {
                                'userId': userId,
                                'controllerId': controllerId,
                                'deviceId': deviceId,
                              },
                            );
                          case 'Dealer Definition':
                            return DealerDefinitionInConfig(
                              userId: userId,
                              customerId: customerId,
                              controllerId: controllerId,
                              imeiNo: deviceId,
                            );
                          default:
                            return const Center(child: Text('Coming Soon'));
                        }
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ) :
          Scaffold(
            body: ListView.builder(
              itemCount: viewModel.filteredSettingList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(viewModel.filteredSettingList[index]['icon'], color: Theme.of(context).primaryColor),
                      title: Text(
                        viewModel.filteredSettingList[index]['title'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        if(viewModel.filteredSettingList[index]['title']=='General'){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => GeneralSetting(customerId: customerId, controllerId: controllerId, adDrId: adDrId, userId: adDrId,)));
                        }
                      },
                    ),
                    if (index < viewModel.filteredSettingList.length - 1) const Padding(
                      padding: EdgeInsets.only(left: 40, right: 8),
                      child: Divider(height: 0),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );

  }

  Widget buildLoadingIndicator(bool isVisible, double width) {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: width / 2 - 25),
        child: const LoadingIndicator(
          indicatorType: Indicator.ballPulse,
        ),
      ),
    );
  }

}
