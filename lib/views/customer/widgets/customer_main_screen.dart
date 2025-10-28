import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/password_protected_site_config.dart';
import '../../../Screens/Dealer/sevicecustomer.dart';
import '../../../Screens/Logs/irrigation_and_pump_log.dart';
import '../../../Screens/planning/WeatherScreen.dart';
import '../../../modules/PumpController/view/pump_controller_home.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../controller_settings/wide/controller_settings_wide.dart';
import '../customer_home.dart';
import '../customer_product.dart';
import '../send_and_received/sent_and_received.dart';
import '../site_config.dart';

Widget buildCustomerMainScreen({required int index, required UserRole role, required int userId,
  required CustomerScreenControllerViewModel vm})
{
  final cSite = vm.mySiteList.data[vm.sIndex];
  final cMaster = cSite.master[vm.mIndex];

  final isGem = [...AppConstants.gemModelList].contains(cMaster.modelId);
  final isNova = [...AppConstants.ecoGemModelList].contains(cMaster.modelId);

  switch (index) {
    case 0:
      return (isGem || isNova) ?
      CustomerHome(
        customerId: cSite.customerId,
        controllerId: cMaster.controllerId,
        deviceId: cMaster.deviceId,
        modelId: cMaster.modelId,
      ) :
      vm.isChanged ? PumpControllerHome(
        userId: userId,
        customerId: cSite.customerId,
        masterData: cMaster,
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
      return CustomerProduct(customerId: cSite.customerId);

    case 2:
      return KeyedSubtree(
        key: ValueKey(DateTime.now().millisecondsSinceEpoch),
        child: SentAndReceived(
          customerId: cSite.customerId,
          controllerId: cMaster.controllerId,
          isWide: true,
        ),
      );

    case 3:
      return (isGem || isNova) ? IrrigationAndPumpLog(
        userData: {
          'userId': userId,
          'controllerId': cMaster.controllerId,
          'customerId': cSite.customerId,
        },
        masterData: cMaster,
      ) :
      ControllerSettingWide(
        userId: userId,
        customerId: cSite.customerId,
        masterController: cMaster,
      );

    case 4:
      return (isGem || isNova) ? ControllerSettingWide(
        userId: userId,
        customerId: cSite.customerId,
        masterController: cMaster,
      ) :
      (role == UserRole.admin || role == UserRole.dealer) ? SiteConfig(
        userId: userId,
        customerId: cSite.customerId,
        customerName: cSite.customerName,
        groupId: cSite.groupId,
        groupName: cSite.groupName,
      ) :
      PasswordProtectedSiteConfig(
        userId: userId,
        customerId: cSite.customerId,
        customerName: cSite.customerName,
        allMaster: cSite.master,
        groupId: cSite.groupId,
        groupName: cSite.groupName,
      );

    case 5:
      return (isGem || isNova) ? ((role == UserRole.admin || role == UserRole.dealer) ? SiteConfig(
        userId: userId,
        customerId: cSite.customerId,
        customerName: cSite.customerName,
        groupId: cSite.groupId,
        groupName: cSite.groupName,
      ) :
      PasswordProtectedSiteConfig(
        userId: userId,
        customerId: cSite.customerId,
        customerName: cSite.customerName,
        allMaster: cSite.master,
        groupId: cSite.groupId,
        groupName: cSite.groupName,
      )) :
      TicketHomePage(
        userId: cSite.customerId,
        controllerId: cMaster.controllerId,
      );

    case 6:
      return TicketHomePage(
        userId: cSite.customerId,
        controllerId: cMaster.controllerId,
      );

    case 7:
      return WeatherScreen(
        userId: cSite.customerId,
        controllerId: cMaster.controllerId,
        deviceID: cMaster.deviceId,
      );

    default:
      return const Scaffold(
        body: Center(
          child: Text("Invalid screen index"),
        ),
      );
  }
}