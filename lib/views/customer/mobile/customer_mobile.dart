import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Screens/Logs/irrigation_and_pump_log.dart';
import '../../../StateManagement/customer_provider.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../Widgets/network_connection_banner.dart';
import '../../../modules/PumpController/view/pump_controller_home.dart';
import '../../../providers/user_provider.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../utils/constants.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../controller_settings.dart';
import '../customer_home.dart';
import '../home_sub_classes/scheduled_program.dart';
import '../widgets/appbar/app_bar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/drawer.dart';
import '../widgets/customer_fab/floating_actions.dart';
import '../widgets/loading_view.dart';
import 'mobile_dashboard.dart';

class CustomerMobile extends StatelessWidget {
  const CustomerMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedInUser = context.watch<UserProvider>().loggedInUser;
    final viewedCustomer = context.watch<UserProvider>().viewedCustomer;
    final commMode = context.watch<CustomerProvider>().controllerCommMode;

    return ChangeNotifierProvider(
      create: (_) => CustomerScreenControllerViewModel(
          context, Repository(HttpService()), context.read<MqttPayloadProvider>())..getAllMySites(
          context, viewedCustomer!.id),
      child: Consumer<CustomerScreenControllerViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) return const LoadingView();

          final currentMaster = vm.mySiteList.data[vm.sIndex].master[vm.mIndex];

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: CustomerAppBar(vm: vm, currentMaster: currentMaster,
                viewedCustomer: viewedCustomer, loggedInUser: loggedInUser),
            drawer: CustomerDrawer(vm: vm, viewedCustomer: viewedCustomer, loggedInUser: loggedInUser),
            body: vm.isLoading ? const Center(child: CircularProgressIndicator()) : ![...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId) ?
            vm.isChanged ? PumpControllerHome(
              userId: loggedInUser.id,
              customerId: viewedCustomer!.id,
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
            ) :
            RefreshIndicator(
              onRefresh: () => _handleRefresh(vm),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                ),
                child: Column(
                  children: [
                    if ([...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId)) ...[

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
                              return MobileDashboard(
                                customerId: loggedInUser.id,
                                controllerId: currentMaster.controllerId,
                                deviceId: currentMaster.deviceId,
                                modelId: currentMaster.modelId,
                              );
                            case 1:
                              return ScheduledProgram(
                                userId: loggedInUser.id,
                                scheduledPrograms: currentMaster.programList,
                                controllerId: currentMaster.controllerId,
                                deviceId: currentMaster.deviceId,
                                customerId: viewedCustomer!.id,
                                currentLineSNo: currentMaster.irrigationLine[vm.lIndex].sNo,
                                groupId: vm.mySiteList.data[vm.sIndex].groupId,
                                categoryId: currentMaster.categoryId,
                                modelId: currentMaster.modelId,
                                deviceName: currentMaster.deviceName,
                                categoryName: currentMaster.categoryName,
                              );
                            case 2:
                              return IrrigationAndPumpLog(
                                userData: {
                                  'userId': viewedCustomer!.id,
                                  'customerId': viewedCustomer.id,
                                  'controllerId': currentMaster.controllerId,
                                },
                                masterData: currentMaster,
                              );
                            default:
                              return ControllerSettings(
                                customerId: viewedCustomer!.id,
                                userId: loggedInUser.id,
                                masterController: currentMaster,
                              );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActions(vm: vm, currentMaster: currentMaster,
                viewedCustomer: viewedCustomer, loggedInUser: loggedInUser),
            bottomNavigationBar: CustomerBottomNav(vm: vm, currentMaster: currentMaster),
          );
        },
      ),
    );
  }

  Future<void> _handleRefresh(CustomerScreenControllerViewModel vm) async {
    await vm.onRefreshClicked();
  }
}