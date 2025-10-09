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
  final isGem = [1, 2, 3, 4].contains(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId);
  final isNova = [56, 57, 58, 59].contains(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId);

  switch (index) {
    case 0:
      return [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList]
          .contains(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId) ?
      CustomerHome(
        customerId: vm.mySiteList.data[vm.sIndex].customerId,
        controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
        deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
        modelId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId,
      ) :
      vm.isChanged ? PumpControllerHome(
        userId: userId,
        customerId: vm.mySiteList.data[vm.sIndex].customerId,
        masterData: vm.mySiteList.data[vm.sIndex].master[vm.mIndex],
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
      return CustomerProduct(customerId: vm.mySiteList.data[vm.sIndex].customerId);

    case 2:
      return SentAndReceived(
        customerId: vm.mySiteList.data[vm.sIndex].customerId,
        controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
        isWide: true,
      );

    case 3:
      return (isGem || isNova) ? IrrigationAndPumpLog(
        userData: {
          'userId': userId,
          'controllerId': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
          'customerId': vm.mySiteList.data[vm.sIndex].customerId,
        },
        masterData: vm.mySiteList.data[vm.sIndex].master[vm.mIndex],
      ) :
      ControllerSettingWide(
        userId: userId,
        customerId: vm.mySiteList.data[vm.sIndex].customerId,
        masterController: vm.mySiteList.data[vm.sIndex].master[vm.mIndex],
      );

    case 4:
      return (isGem || isNova) ? ControllerSettingWide(
        userId: userId,
        customerId: vm.mySiteList.data[vm.sIndex].customerId,
        masterController: vm.mySiteList.data[vm.sIndex].master[vm.mIndex],
      ) :
      role == UserRole.admin ? SiteConfig(
        userId: userId,
        customerId: vm.mySiteList.data[vm.sIndex].customerId,
        customerName: vm.mySiteList.data[vm.sIndex].customerName,
        groupId: vm.mySiteList.data[vm.sIndex].groupId,
        groupName: vm.mySiteList.data[vm.sIndex].groupName,
      ) :
      PasswordProtectedSiteConfig(
        userId: userId,
        customerId: vm.mySiteList.data[vm.sIndex].customerId,
        customerName: vm.mySiteList.data[vm.sIndex].customerName,
        allMaster: vm.mySiteList.data[vm.sIndex].master,
        groupId: vm.mySiteList.data[vm.sIndex].groupId,
        groupName: vm.mySiteList.data[vm.sIndex].groupName,
      );

    case 5:
      return (isGem || isNova) ? (role == UserRole.admin ? SiteConfig(
        userId: userId,
        customerId: vm.mySiteList.data[vm.sIndex].customerId,
        customerName: vm.mySiteList.data[vm.sIndex].customerName,
        groupId: vm.mySiteList.data[vm.sIndex].groupId,
        groupName: vm.mySiteList.data[vm.sIndex].groupName,
      ) :
      PasswordProtectedSiteConfig(
        userId: userId,
        customerId: vm.mySiteList.data[vm.sIndex].customerId,
        customerName: vm.mySiteList.data[vm.sIndex].customerName,
        allMaster: vm.mySiteList.data[vm.sIndex].master,
        groupId: vm.mySiteList.data[vm.sIndex].groupId,
        groupName: vm.mySiteList.data[vm.sIndex].groupName,
      )) :
      TicketHomePage(
        userId: vm.mySiteList.data[vm.sIndex].customerId,
        controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
      );

    case 6:
      return TicketHomePage(
        userId: vm.mySiteList.data[vm.sIndex].customerId,
        controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
      );

    case 7:
      return WeatherScreen(
        userId: vm.mySiteList.data[vm.sIndex].customerId,
        controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
        deviceID: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
      );

    default:
      return const Scaffold(
        body: Center(
          child: Text("Invalid screen index"),
        ),
      );
  }
}