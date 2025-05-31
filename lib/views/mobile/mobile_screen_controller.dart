import 'dart:async';
import 'dart:convert';

import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/Dealer/sevicecustomer.dart';
import 'package:oro_drip_irrigation/Screens/Logs/irrigation_and_pump_log.dart';
import 'package:oro_drip_irrigation/Screens/planning/WeatherScreen.dart';
import 'package:oro_drip_irrigation/modules/ScheduleView/view/schedule_view_screen.dart';
import 'package:oro_drip_irrigation/views/customer/sent_and_received.dart';
import 'package:popover/popover.dart';
import '../../Models/customer/blu_device.dart';
import '../../Models/customer/site_model.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/customer_provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../flavors.dart';
import '../../modules/IrrigationProgram/view/program_library.dart';
import '../../modules/PumpController/view/node_settings.dart';
import '../../modules/PumpController/view/pump_controller_home.dart';
import '../../repository/repository.dart';
import '../../services/bluetooth_sevice.dart';
import '../../services/communication_service.dart';
import '../../services/http_service.dart';
import '../../utils/formatters.dart';
import '../../utils/my_function.dart';
import '../../utils/routes.dart';
import '../../utils/shared_preferences_helper.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../view_models/nav_rail_view_model.dart';
import '../account_settings.dart';
import '../customer/controller_settings.dart';
import '../customer/customer_home.dart';
import '../customer/customer_product.dart';
import '../customer/home_sub_classes/scheduled_program.dart';
import '../customer/input_output_connection_details.dart';
import '../customer/node_list.dart';
import '../customer/stand_alone.dart';


class MobileScreenController extends StatelessWidget {
  const MobileScreenController({super.key, required this.userId, required this.customerName, required this.mobileNo, required this.emailId, required this.customerId, required this.fromLogin});
  final int customerId, userId;
  final String customerName, mobileNo, emailId;
  final bool fromLogin;

  void callbackFunction(message){
  }

  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider mqttProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => CustomerScreenControllerViewModel(context, Repository(HttpService()), mqttProvider)
        ..getAllMySites(context, customerId),
      child: Consumer<CustomerScreenControllerViewModel>(
        builder: (context, vm, _) {

          final commMode = Provider.of<CustomerProvider>(context).controllerCommMode;

          if (vm.isLoading) {
            return const Scaffold(
                body: Center(child: Text('Site loading please waite....')));
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: F.appFlavor!.name.contains('oro') ?
              Image.asset(
                width: 70,
                "assets/png/oro_logo_white.png",
                fit: BoxFit.fitWidth,
              ):
              Image.asset(
                width: 160,
                "assets/png/lk_logo_white.png",
                fit: BoxFit.fitWidth,
              ),
              actions: [
                if(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId != 2)...[
                  Consumer<CustomerScreenControllerViewModel>(
                    builder: (context, vm, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          vm.programRunning
                              ? CircleAvatar(
                            radius: 15,
                            backgroundImage: const AssetImage('assets/gif/water_drop_ani.gif'),
                            backgroundColor: Colors.blue.shade100,
                          )
                              : const SizedBox(),
                        ],
                      );
                    },
                  ),
                  AlarmButton(alarmPayload: vm.alarmDL, deviceID: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                      customerId: customerId, controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId),
                ],
                if(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2)...[
                  if(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].nodeList.isNotEmpty
                      && [48, 49].contains(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId))
                    IconButton(
                        onPressed: (){
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return NodeSettings(
                                  userId: userId,
                                  controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                  customerId: customerId,
                                  nodeList: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].nodeList,
                                  deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                );
                              }
                          );
                        },
                        icon: const Icon(Icons.settings_remote)
                    ),
                  IconButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SentAndReceived(
                                  customerId: userId,
                                  controllerId: vm.mySiteList.data[vm.sIndex]
                                      .master[vm.mIndex].controllerId,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.question_answer_outlined)
                  ),
                ],
                const SizedBox(width: 16),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      // Enables horizontal scrolling
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15),

                          vm.mySiteList.data.length > 1
                              ? DropdownButton(
                            isExpanded: false,
                            underline: Container(),
                            items: (vm.mySiteList.data ?? []).map((site) {
                              return DropdownMenuItem(
                                value: site.groupName,
                                child: Text(
                                  site.groupName,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              );
                            }).toList(),
                            onChanged: (siteName) =>
                                vm.siteOnChanged(siteName!),
                            value: vm.myCurrentSite,
                            dropdownColor: Colors.teal,
                            iconEnabledColor: Colors.white,
                            iconDisabledColor: Colors.white,
                            focusColor: Colors.transparent,
                          )
                              : Text(
                            vm.mySiteList.data[vm.sIndex].groupName,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white54),
                            overflow: TextOverflow.ellipsis,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Container(width: 1, height: 20, color: Colors.white54),
                          ),

                          vm.mySiteList.data[vm.sIndex].master.length > 1? PopupMenuButton<int>(
                            color: Theme.of(context).primaryColorLight,
                            tooltip: 'master controller',
                            child: MaterialButton(
                              onPressed: null,
                              textColor: Colors.white,
                              child: Row(
                                children: [
                                  Text(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                                ],
                              ),
                            ),
                            itemBuilder: (context) {
                              return List.generate(vm.mySiteList.data[vm.sIndex].master.length, (index) {
                                final master = vm.mySiteList.data[vm.sIndex].master[index];
                                return PopupMenuItem<int>(
                                  value: index,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        master.categoryName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(
                                        master.modelName,
                                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            },
                            onSelected: (index) {
                              vm.masterOnChanged(index); // ✅ Pass only the index
                            },
                          ):
                          const SizedBox(),

                          vm.mySiteList.data[vm.sIndex].master.length > 1? Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Container(width: 1, height: 20, color: Colors.white54),
                          ):const SizedBox(),

                          vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 &&
                              vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                                  .irrigationLine.length > 1
                              ? DropdownButton<int>(
                            underline: Container(),
                            items: List.generate(
                              vm.mySiteList.data[vm.sIndex].master[vm.mIndex].irrigationLine.length,
                                  (index) {
                                final line = vm.mySiteList.data[vm.sIndex].master[vm.mIndex].irrigationLine[index];
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(
                                    line.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                );
                              },
                            ),
                            onChanged: (selectedIndex) {
                              if (selectedIndex != null) {
                                vm.lineOnChanged(selectedIndex); // Pass index to your function
                              }
                            },
                            value: vm.lIndex,
                            dropdownColor: Theme.of(context).primaryColorLight,
                            iconEnabledColor: Colors.white,
                            iconDisabledColor: Colors.white,
                            focusColor: Colors.transparent,
                          )
                              : const SizedBox(),

                          vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 &&
                              vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                                  .irrigationLine.length > 1 ?Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Container(width: 1, height: 20, color: Colors.white54),
                          ):const SizedBox(),

                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.transparent),
                            width: 45,
                            height: 45,
                            child: IconButton(
                              tooltip: 'refresh',
                              onPressed: vm.onRefreshClicked,
                              icon: const Icon(Icons.refresh),
                              color: Colors.white,
                              iconSize: 24.0,
                              hoverColor: Theme
                                  .of(context)
                                  .primaryColorLight,
                            ),
                          ),

                          Text(
                            'Last sync @ - ${Formatters.formatDateTime(
                                '${vm.mySiteList.data[vm.sIndex].master[vm
                                    .mIndex].live?.cD} ${vm.mySiteList.data[vm
                                    .sIndex].master[vm.mIndex].live?.cT}')}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white60),
                          ),

                          const SizedBox(width: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            drawer: Drawer(
              shape: const RoundedRectangleBorder(),
              surfaceTintColor: Colors.white,
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Theme
                        .of(context)
                        .primaryColor),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(customerName, style: const TextStyle(
                                    color: Colors.white)),
                                Text(mobileNo, style: const TextStyle(
                                    color: Colors.white, fontSize: 14)),
                                Text(emailId, style: const TextStyle(
                                    color: Colors.white, fontSize: 14)),
                                const SizedBox(height: 20),
                                const Text("Version 1.0.0",
                                    style: TextStyle(color: Colors.white54)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 75,
                            height: 75,
                            child: CircleAvatar(),
                          )
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.account_circle_outlined, color: Theme
                        .of(context)
                        .primaryColor),
                    title: const Text("Profile",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountSettings(userId: customerId, customerId: customerId, userName: customerName, mobileNo: mobileNo, emailId: emailId),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: Theme
                        .of(context)
                        .primaryColor),
                    title: const Text("App Info",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.help_outline, color: Theme
                        .of(context)
                        .primaryColor),
                    title: const Text(
                        "Help", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback_outlined, color: Theme
                        .of(context)
                        .primaryColor),
                    title: const Text("Send Feedback",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.support_agent_sharp, color: Theme
                        .of(context)
                        .primaryColor),
                    title: const Text("Service Request",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  TicketHomePage(userId: userId, controllerId: vm.mySiteList.data[vm.sIndex].master[vm
                            .mIndex].controllerId,)),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.devices, color: Theme
                        .of(context)
                        .primaryColor),
                    title: const Text("All my devices",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  CustomerProduct(customerId: userId)),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, top: 16, right: 16),
                    child: TextButton.icon(
                      onPressed: () async {
                        await PreferenceHelper.clearAll();
                        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false,);
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Logout", style: TextStyle(color: Colors
                          .red, fontSize: 17)),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  const Spacer(), // Pushes the version/logo to the bottom
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        F.appFlavor!.name.contains('oro') ?
                        CircleAvatar(radius:30, child: Image.asset('assets/png/company_logo_nia.png')):
                        SizedBox(
                          height: 60,
                          child: Image.asset('assets/png/company_logo.png'),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
            bottomNavigationBar: vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                .categoryId == 1 ? BottomNavigationBar(
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              elevation: 10,
              selectedFontSize: 14,
              unselectedFontSize: 12,
              currentIndex: vm.selectedIndex,
              onTap: vm.onItemTapped,
              selectedItemColor: Theme
                  .of(context)
                  .primaryColorLight,
              unselectedItemColor: Colors.black87,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.list), label: "Scheduled Program"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined), label: "Settings"),
              ],
            ) : null,
            floatingActionButton: vm.mySiteList.data[vm.sIndex].master[vm
                .mIndex].categoryId == 1 ?
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: null,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: PopupMenuButton<String>(
                      onSelected: (String value) {
                        switch (value) {
                          case 'Node Status':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NodeList(
                                      customerId: customerId,
                                      nodes: vm.mySiteList.data[vm.sIndex].master[vm
                                          .mIndex].nodeList,
                                      deviceId: vm.mySiteList.data[vm.sIndex]
                                          .master[vm.mIndex].deviceId,
                                      deviceName: vm.mySiteList.data[vm.sIndex]
                                          .master[vm.mIndex].categoryName,
                                      controllerId: vm.mySiteList.data[vm.sIndex]
                                          .master[vm.mIndex].controllerId,
                                      userId: userId, configObjects: vm.mySiteList.data[vm.sIndex]
                                        .master[vm.mIndex].configObjects,
                                    ),
                              ),
                            );
                            break;

                          case 'I/O Connection':
                            Navigator.push(context,
                              MaterialPageRoute(
                                builder: (context) => InputOutputConnectionDetails(masterInx: vm.mIndex,
                                    nodes: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].nodeList),
                              ),
                            );
                            break;

                          case 'Sent & Received':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SentAndReceived(
                                      customerId: userId,
                                      controllerId: vm.mySiteList.data[vm.sIndex]
                                          .master[vm.mIndex].controllerId,
                                    ),
                              ),
                            );
                            break;
                          case 'Program':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return ProgramLibraryScreenNew(
                                        customerId: customerId,
                                        controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                        deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                        userId: userId,
                                        groupId: vm.mySiteList.data[vm.sIndex].groupId,
                                        categoryId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId,
                                        modelId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId,
                                        deviceName: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceName,
                                        categoryName: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName,
                                      );
                                    }
                                )
                            );
                            break;
                          case 'ScheduleView':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return ScheduleViewScreen(
                                        deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                        userId: userId,
                                        controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                        customerId: customerId,
                                        groupId: vm.mySiteList.data[vm.sIndex].groupId,
                                      );
                                    }
                                )
                            );
                            break;

                          case 'Manual':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return StandAlone(siteId: vm.mySiteList.data[vm.sIndex].groupId,
                                          controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                          customerId: customerId,
                                          deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                          callbackFunction: callbackFunction, userId: userId, masterData: vm.mySiteList.data[vm.sIndex].master[vm.mIndex]);
                                    }
                                )
                            );
                            break;
                        }
                      },
                      offset: const Offset(0, -180),
                      color: Colors.blue.shade50,
                      icon: const Icon(Icons.menu, color: Colors.white),
                      itemBuilder: (BuildContext context) =>
                      [
                        _buildPopupItem(
                            context, 'Node Status', Icons.format_list_numbered,
                            'Node Status'),
                        _buildPopupItem(context, 'I/O Connection',
                            Icons.settings_input_component_outlined,
                            'I/O\nConnection\ndetails'),
                        _buildPopupItem(
                            context, 'Program', Icons.list_alt, 'Program'),
                        _buildPopupItem(
                            context, 'ScheduleView', Icons.view_list_outlined,
                            'Scheduled\nprogram\ndetails'),
                        _buildPopupItem(
                            context, 'Manual', Icons.touch_app_outlined, 'Manual'),
                        _buildPopupItem(context, 'Sent & Received',
                            Icons.question_answer_outlined, 'Sent &\nReceived'),
                      ]
                  ),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  backgroundColor: commMode == 1? Theme.of(context).primaryColorLight:
                  (commMode == 2 && vm.blueService.isConnected) ?
                  Theme.of(context).primaryColorLight : Colors.redAccent,
                  onPressed: ()=>_showBottomSheet(context, vm, vm.mySiteList.data[vm.sIndex].master[vm
                      .mIndex].controllerId),
                  tooltip: 'Second Action',
                  child: commMode == 1?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(vm.wifiStrength == 0? Icons.wifi_off:
                      vm.wifiStrength >= 1 && vm.wifiStrength <= 20 ? Icons.network_wifi_1_bar_outlined:
                      vm.wifiStrength >= 21 && vm.wifiStrength <= 40 ? Icons.network_wifi_2_bar_outlined:
                      vm.wifiStrength >= 41 && vm.wifiStrength <= 60 ? Icons.network_wifi_3_bar_outlined:
                      vm.wifiStrength >= 61 && vm.wifiStrength <= 80 ? Icons.network_wifi_3_bar_outlined:
                      Icons.wifi, color: Colors.white,),
                      Text('${vm.wifiStrength} %',style: const TextStyle(fontSize: 11.0, color: Colors.white70),
                      ),
                    ],
                  ) :
                  Icon((commMode == 2 && vm.blueService.isConnected)?Icons.bluetooth:Icons.bluetooth_disabled,
                      color: Colors.white),
                ),
              ],
            ) : null,

            body: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2 ?
            vm.isChanged ? PumpControllerHome(
              userId: userId,
              customerId: customerId,
              masterData: vm.mySiteList.data[vm.sIndex].master[vm.mIndex],
            ) : const Scaffold(
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
            ) : RefreshIndicator(
              onRefresh: () => _handleRefresh(vm),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                ),
                child: Column(
                  children: [
                    if (vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1) ...[
                      if (!vm.isLiveSynced)
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
                          height: 30,
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
                          return vm.selectedIndex == 0 ?
                          CustomerHome(customerId: userId, controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                            deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,)
                              : vm.selectedIndex == 1
                              ? ScheduledProgram(
                            userId: customerId,
                            scheduledPrograms: vm.mySiteList.data[vm.sIndex].master[vm
                                .mIndex].programList,
                            controllerId: vm.mySiteList.data[vm.sIndex].master[vm
                                .mIndex].controllerId,
                            deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                                .deviceId,
                            customerId: customerId,
                            currentLineSNo: vm.mySiteList.data[vm.sIndex].master[vm
                                .mIndex].irrigationLine[vm.lIndex].sNo,
                            groupId: vm.mySiteList.data[vm.sIndex].groupId,
                            categoryId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId,
                            modelId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId,
                            deviceName: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceName,
                            categoryName: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName,
                          )
                              : ControllerSettings(customerId: customerId,
                            userId: userId,
                            masterController: vm.mySiteList.data[vm.sIndex].master[vm.mIndex],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavRailViewModel()),
        ChangeNotifierProvider(
          create: (_) =>
          CustomerScreenControllerViewModel(context, Repository(HttpService()), mqttProvider)
            ..getAllMySites(context, customerId),
        ),
      ],
      child: Consumer2<NavRailViewModel, CustomerScreenControllerViewModel>(
        builder: (context, navViewModel, vm, _) {
          final commMode = Provider.of<CustomerProvider>(context).controllerCommMode;
          final manager = Provider.of<BluService>(context);

          if (vm.isLoading) {
            return const Scaffold(
                body: Center(child: Text('Site loading please waite....')));
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: F.appFlavor!.name.contains('oro') ?
              Image.asset(
                width: 70,
                "assets/png/oro_logo_white.png",
                fit: BoxFit.fitWidth,
              ):
              Image.asset(
                width: 160,
                "assets/png/lk_logo_white.png",
                fit: BoxFit.fitWidth,
              ),
              actions: [
                if(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId != 2)...[
                  AlarmButton(alarmPayload: vm.alarmDL, deviceID: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                    customerId: customerId, controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId),
                ],
                if(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2)...[
                  if(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].nodeList.isNotEmpty
                      && [48, 49].contains(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId))
                    IconButton(
                        onPressed: (){
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return NodeSettings(
                                  userId: userId,
                                  controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                  customerId: customerId,
                                  nodeList: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].nodeList,
                                  deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                );
                              }
                          );
                        },
                        icon: const Icon(Icons.settings_remote)
                    ),
                  IconButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SentAndReceived(
                                  customerId: userId,
                                  controllerId: vm.mySiteList.data[vm.sIndex]
                                      .master[vm.mIndex].controllerId,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.question_answer_outlined)
                  ),
                ],
                const SizedBox(width: 16),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      // Enables horizontal scrolling
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15),

                          vm.mySiteList.data.length > 1
                              ? DropdownButton(
                            isExpanded: false,
                            underline: Container(),
                            items: (vm.mySiteList.data ?? []).map((site) {
                              return DropdownMenuItem(
                                value: site.groupName,
                                child: Text(
                                  site.groupName,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              );
                            }).toList(),
                            onChanged: (siteName) =>
                                vm.siteOnChanged(siteName!),
                            value: vm.myCurrentSite,
                            dropdownColor: Colors.teal,
                            iconEnabledColor: Colors.white,
                            iconDisabledColor: Colors.white,
                            focusColor: Colors.transparent,
                          )
                              : Text(
                            vm.mySiteList.data[vm.sIndex].groupName,
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white54),
                            overflow: TextOverflow.ellipsis,
                          ),

                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Container(width: 1, height: 20, color: Colors.white54),
                          ),

                          vm.mySiteList.data[vm.sIndex].master.length > 1? PopupMenuButton<int>(
                            color: Theme.of(context).primaryColorLight,
                            tooltip: 'master controller',
                            child: MaterialButton(
                              onPressed: null,
                              textColor: Colors.white,
                              child: Row(
                                children: [
                                  Text(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                                ],
                              ),
                            ),
                            itemBuilder: (context) {
                              return List.generate(vm.mySiteList.data[vm.sIndex].master.length, (index) {
                                final master = vm.mySiteList.data[vm.sIndex].master[index];
                                return PopupMenuItem<int>(
                                  value: index,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        master.categoryName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Text(
                                        master.modelName,
                                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            },
                            onSelected: (index) {
                              vm.masterOnChanged(index); // ✅ Pass only the index
                            },
                          ):
                          const SizedBox(),

                          vm.mySiteList.data[vm.sIndex].master.length > 1? Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Container(width: 1, height: 20, color: Colors.white54),
                          ):const SizedBox(),

                          vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 &&
                              vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                                  .irrigationLine.length > 1
                              ? DropdownButton<int>(
                            underline: Container(),
                            items: List.generate(
                              vm.mySiteList.data[vm.sIndex].master[vm.mIndex].irrigationLine.length,
                                  (index) {
                                final line = vm.mySiteList.data[vm.sIndex].master[vm.mIndex].irrigationLine[index];
                                return DropdownMenuItem<int>(
                                  value: index,
                                  child: Text(
                                    line.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                );
                              },
                            ),
                            onChanged: (selectedIndex) {
                              if (selectedIndex != null) {
                                vm.lineOnChanged(selectedIndex); // Pass index to your function
                              }
                            },
                            value: vm.lIndex,
                            dropdownColor: Theme.of(context).primaryColorLight,
                            iconEnabledColor: Colors.white,
                            iconDisabledColor: Colors.white,
                            focusColor: Colors.transparent,
                          )
                              : const SizedBox(),

                          vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 &&
                              vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                                  .irrigationLine.length > 1 ?Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Container(width: 1, height: 20, color: Colors.white54),
                          ):const SizedBox(),

                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.transparent),
                            width: 45,
                            height: 45,
                            child: IconButton(
                              tooltip: 'refresh',
                              onPressed: vm.onRefreshClicked,
                              icon: const Icon(Icons.refresh),
                              color: Colors.white,
                              iconSize: 24.0,
                              hoverColor: Theme
                                  .of(context)
                                  .primaryColorLight,
                            ),
                          ),

                          Text(
                            'Last sync @ - ${Formatters.formatDateTime(
                                '${vm.mySiteList.data[vm.sIndex].master[vm
                                    .mIndex].live?.cD} ${vm.mySiteList.data[vm
                                    .sIndex].master[vm.mIndex].live?.cT}')}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white60),
                          ),

                          const SizedBox(width: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            drawer: Drawer(
              shape: const RoundedRectangleBorder(),
              surfaceTintColor: Colors.white,
              child: Column(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Theme
                        .of(context)
                        .primaryColor),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(customerName, style: const TextStyle(
                                    color: Colors.white)),
                                Text(mobileNo, style: const TextStyle(
                                    color: Colors.white, fontSize: 14)),
                                Text(emailId, style: const TextStyle(
                                    color: Colors.white, fontSize: 14)),
                                const SizedBox(height: 20),
                                const Text("Version 1.0.0",
                                    style: TextStyle(color: Colors.white54)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 75,
                            height: 75,
                            child: CircleAvatar(),
                          )
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.account_circle_outlined, color: Theme
                        .of(context)
                        .primaryColor),
                    title: const Text("Profile",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountSettings(userId: customerId, customerId: customerId, userName: customerName, mobileNo: mobileNo, emailId: emailId),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: Theme
                        .of(context)
                        .primaryColor),
                    title: const Text("App Info",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.help_outline, color: Theme
                        .of(context)
                        .primaryColor),
                    title: const Text(
                        "Help", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback_outlined, color: Theme
                        .of(context)
                        .primaryColor),
                    title: const Text("Send Feedback",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.support_agent_sharp, color: Theme
                        .of(context)
                        .primaryColor),
                    title: const Text("Service Request",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  TicketHomePage(userId: userId, controllerId: vm.mySiteList.data[vm.sIndex].master[vm
                            .mIndex].controllerId,)),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.devices, color: Theme
                        .of(context)
                        .primaryColor),
                    title: const Text("All my devices",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  CustomerProduct(customerId: userId)),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, top: 16, right: 16),
                    child: TextButton.icon(
                      onPressed: () async {
                        await PreferenceHelper.clearAll();
                        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false,);
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Logout", style: TextStyle(color: Colors
                          .red, fontSize: 17)),
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  const Spacer(), // Pushes the version/logo to the bottom
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        F.appFlavor!.name.contains('oro') ?
                        CircleAvatar(radius:30, child: Image.asset('assets/png/company_logo_nia.png')):
                        SizedBox(
                          height: 60,
                          child: Image.asset('assets/png/company_logo.png'),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
            bottomNavigationBar: vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                .categoryId == 1 ? BottomNavigationBar(
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              elevation: 10,
              selectedFontSize: 14,
              unselectedFontSize: 12,
              currentIndex: vm.selectedIndex,
              onTap: vm.onItemTapped,
              selectedItemColor: Theme
                  .of(context)
                  .primaryColorLight,
              unselectedItemColor: Colors.black87,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.list), label: "Scheduled Program"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined), label: "Settings"),
              ],
            ) : null,
            floatingActionButton: vm.mySiteList.data[vm.sIndex].master[vm
                .mIndex].categoryId == 1 ?
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: null,
                  backgroundColor: Theme.of(context).primaryColorLight,
                  child: PopupMenuButton<String>(
                      onSelected: (String value) {
                        switch (value) {
                          case 'Node Status':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NodeList(
                                      customerId: customerId,
                                      nodes: vm.mySiteList.data[vm.sIndex].master[vm
                                          .mIndex].nodeList,
                                      deviceId: vm.mySiteList.data[vm.sIndex]
                                          .master[vm.mIndex].deviceId,
                                      deviceName: vm.mySiteList.data[vm.sIndex]
                                          .master[vm.mIndex].categoryName,
                                      controllerId: vm.mySiteList.data[vm.sIndex]
                                          .master[vm.mIndex].controllerId,
                                      userId: userId, configObjects: vm.mySiteList.data[vm.sIndex]
                                        .master[vm.mIndex].configObjects,
                                    ),
                              ),
                            );
                            break;

                          case 'I/O Connection':
                            Navigator.push(context,
                              MaterialPageRoute(
                                builder: (context) => InputOutputConnectionDetails(masterInx: vm.mIndex,
                                    nodes: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].nodeList),
                              ),
                            );
                            break;

                          case 'Sent & Received':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SentAndReceived(
                                      customerId: userId,
                                      controllerId: vm.mySiteList.data[vm.sIndex]
                                          .master[vm.mIndex].controllerId,
                                    ),
                              ),
                            );
                            break;
                          case 'Program':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return ProgramLibraryScreenNew(
                                        customerId: customerId,
                                        controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                        deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                        userId: userId,
                                        groupId: vm.mySiteList.data[vm.sIndex].groupId,
                                        categoryId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId,
                                        modelId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId,
                                        deviceName: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceName,
                                        categoryName: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName,
                                      );
                                    }
                                )
                            );
                            break;
                          case 'ScheduleView':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return ScheduleViewScreen(
                                        deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                        userId: userId,
                                        controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                        customerId: customerId,
                                        groupId: vm.mySiteList.data[vm.sIndex].groupId,
                                      );
                                    }
                                )
                            );
                            break;

                          case 'Manual':
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return StandAlone(siteId: vm.mySiteList.data[vm.sIndex].groupId,
                                          controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                          customerId: customerId,
                                          deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                          callbackFunction: callbackFunction, userId: userId, masterData: vm.mySiteList.data[vm.sIndex].master[vm.mIndex]);
                                    }
                                )
                            );
                            break;
                        }
                      },
                      offset: const Offset(0, -180),
                      color: Colors.blue.shade50,
                      icon: const Icon(Icons.menu, color: Colors.white),
                      itemBuilder: (BuildContext context) =>
                      [
                        _buildPopupItem(
                            context, 'Node Status', Icons.format_list_numbered,
                            'Node Status'),
                        _buildPopupItem(context, 'I/O Connection',
                            Icons.settings_input_component_outlined,
                            'I/O\nConnection\ndetails'),
                        _buildPopupItem(
                            context, 'Program', Icons.list_alt, 'Program'),
                        _buildPopupItem(
                            context, 'ScheduleView', Icons.view_list_outlined,
                            'Scheduled\nprogram\ndetails'),
                        _buildPopupItem(
                            context, 'Manual', Icons.touch_app_outlined, 'Manual'),
                        _buildPopupItem(context, 'Sent & Received',
                            Icons.question_answer_outlined, 'Sent &\nReceived'),
                      ]
                  ),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  backgroundColor: commMode == 1? Theme.of(context).primaryColorLight:
                  (commMode == 2 && manager.isConnected) ?
                  Theme.of(context).primaryColorLight : Colors.redAccent,
                  onPressed: ()=>_showBottomSheet(context, vm, vm.mySiteList.data[vm.sIndex].master[vm
                      .mIndex].controllerId),
                  tooltip: 'Second Action',
                  child: commMode == 1?
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(vm.wifiStrength == 0? Icons.wifi_off:
                      vm.wifiStrength >= 1 && vm.wifiStrength <= 20 ? Icons.network_wifi_1_bar_outlined:
                      vm.wifiStrength >= 21 && vm.wifiStrength <= 40 ? Icons.network_wifi_2_bar_outlined:
                      vm.wifiStrength >= 41 && vm.wifiStrength <= 60 ? Icons.network_wifi_3_bar_outlined:
                      vm.wifiStrength >= 61 && vm.wifiStrength <= 80 ? Icons.network_wifi_3_bar_outlined:
                      Icons.wifi, color: Colors.white,),
                      Text('${vm.wifiStrength} %',style: const TextStyle(fontSize: 11.0, color: Colors.white70),
                      ),
                    ],
                  ) :
                  Icon((commMode == 2 && manager.isConnected)?Icons.bluetooth:Icons.bluetooth_disabled,
                  color: Colors.white),
                ),
              ],
            ) : null,

            body: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2 ?
            vm.isChanged ? PumpControllerHome(
              userId: userId,
              customerId: customerId,
              masterData: vm.mySiteList.data[vm.sIndex].master[vm.mIndex],
            ) : const Scaffold(
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
            ) : RefreshIndicator(
              onRefresh: () => _handleRefresh(vm),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                ),
                child: Column(
                  children: [
                    if (vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1) ...[
                      if (!vm.isLiveSynced)
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
                          height: 30,
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
                          return vm.selectedIndex == 0 ?
                          CustomerHome(customerId: userId, controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                            deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,)
                              : vm.selectedIndex == 1
                              ? ScheduledProgram(
                            userId: customerId,
                            scheduledPrograms: vm.mySiteList.data[vm.sIndex].master[vm
                                .mIndex].programList,
                            controllerId: vm.mySiteList.data[vm.sIndex].master[vm
                                .mIndex].controllerId,
                            deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                                .deviceId,
                            customerId: customerId,
                            currentLineSNo: vm.mySiteList.data[vm.sIndex].master[vm
                                .mIndex].irrigationLine[vm.lIndex].sNo,
                            groupId: vm.mySiteList.data[vm.sIndex].groupId,
                            categoryId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId,
                            modelId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId,
                            deviceName: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceName,
                            categoryName: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName,
                          )
                              : ControllerSettings(customerId: customerId,
                            userId: userId,
                            masterController: vm.mySiteList.data[vm.sIndex].master[vm.mIndex],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRefresh(CustomerScreenControllerViewModel vm) async {
    await vm.onRefreshClicked();
  }

  PopupMenuItem<String> _buildPopupItem(BuildContext context, String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget mainScreen(int index, groupId, groupName, List<MasterControllerModel> masterData, int controllerId, int categoryId, int masterIndex, int siteIndex, bool isChanged, CustomerScreenControllerViewModel vm) {
    switch (index) {
      case 0:
        return categoryId==1? CustomerHome(customerId: userId, controllerId: controllerId,
          deviceId: masterData[masterIndex].deviceId,):
        isChanged ? PumpControllerHome(
          userId: userId,
          customerId: customerId,
          masterData: masterData[masterIndex],
        ) : const Scaffold(
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
        return CustomerProduct(customerId: userId);
      case 2:
        return SentAndReceived(customerId: userId, controllerId: controllerId);
      case 3:
        return IrrigationAndPumpLog(userData: {'userId' : userId, 'controllerId' : controllerId},
          masterData: masterData[masterIndex]);
      case 4:
        return ControllerSettings(
          customerId: customerId,
          userId: userId,
          masterController: masterData[masterIndex],
        );
      case 6:
        return WeatherScreen(userId: userId, controllerId: controllerId, deviceID: '',);

      default:
        return const SizedBox();
    }
  }

  void _showBottomSheet(BuildContext context, CustomerScreenControllerViewModel vm, controllerId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          //final manager = Provider.of<BluService>(context);
          final commMode = Provider.of<CustomerProvider>(context).controllerCommMode;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                const Text(
                  "Controller Communication Mode",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.wifi),
                  title: const Text("Wi-Fi / MQTT"),
                  trailing: commMode == 1 ?
                  Icon(Icons.check, color: Theme.of(context).primaryColorLight) : null,
                  onTap: () {
                    vm.updateCommunicationMode(1, customerId);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: const Text("Bluetooth"),
                  trailing: commMode == 2
                      ? Icon(Icons.check, color: Theme.of(context).primaryColorLight)
                      : null,
                  onTap: () {
                    vm.updateCommunicationMode(2, customerId);
                  },
                ),
                if (commMode == 2) ...[
                  const Divider(),
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Scan for Bluetooth Devices and Connect",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh_outlined, color: Colors.black),
                      onPressed: () => vm.blueService.getDevices(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Consumer<MqttPayloadProvider>(
                    builder: (context, provider, _) {
                      final devices = provider.pairedDevices;
                      if (devices.isNotEmpty) {
                        return Column(
                          children: devices.map((d) {
                            return ListTile(
                              title: Text(d.device.name ?? ''),
                              subtitle: Text(d.device.address),
                              trailing: d.isConnected ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const TextButton(
                                    onPressed: null,
                                    child: Text(
                                      'Connected',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      requestAndShowWifiList(context, false);
                                    },
                                    icon: const Icon(CupertinoIcons.text_badge_checkmark),
                                  ),
                                ],
                              ):
                              d.isConnecting ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ):
                              TextButton(
                                onPressed: d.isDisConnected? () => vm.blueService.connectToDevice(d): null,
                                child: const Text('Connect'),
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return const Center(
                          child: Text(
                            'Make sure your phone is paired with the controller, then tap the refresh icon to try again',
                            style: TextStyle(fontSize: 12, color: Colors.black38),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          );
        });
      },
    );
  }

  void requestAndShowWifiList(BuildContext context, bool visibleDg) {
    final commService = Provider.of<CommunicationService>(context, listen: false);
    String payLoadFinal = jsonEncode({"7200": {"7201": ''}});
    commService.sendCommand(serverMsg: '', payload: payLoadFinal);
    if(!visibleDg){
      showWifiListDialog(context);
    }
  }

  void showWifiListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final connectingNetwork = ValueNotifier<String?>(null);
        final provider = context.watch<MqttPayloadProvider>();
        final networks = provider.wifiList;
        final message = provider.wifiMessage;

        if (message != null && message.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Changing controller network..."),
                  content: Text(message),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.read<MqttPayloadProvider>().clearWifiMessage();
                        Navigator.of(context).pop(); // Close message dialog
                        Navigator.of(context).pop(); // Close main Wi-Fi dialog
                        showWifiListDialog(context); // Reopen
                      },
                      child: const Text("OK"),
                    ),
                  ],
                );
              },
            );
          });
        }

        return AlertDialog(
          backgroundColor: Colors.white,
          title: ListTile(
            title: const Text("Available Networks"),
            subtitle: const Text(
              "Select a Wi-Fi network to change the controller's connection.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: IconButton(
              onPressed: () {
                requestAndShowWifiList(context, true);
              },
              icon: const Icon(Icons.refresh),
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SizedBox(
            width: double.maxFinite,
            child: networks.isEmpty
                ? const SizedBox(height: 20, child: Center(child: Text("No networks found.")))
                : ValueListenableBuilder<String?>(
              valueListenable: connectingNetwork,
              builder: (dialogContext, connectingSsid, _) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: networks.length,
                  itemBuilder: (context, index) {
                    final net = networks[index];
                    final ssid = net["SSID"] ?? "Unknown";
                    final bool isSecured = (net["SECURITY"] != null);

                    return ListTile(
                      leading: Icon(
                        Icons.wifi,
                        color: net["SIGNAL"] >= 75
                            ? Colors.green
                            : (net["SIGNAL"] >= 50 ? Colors.orange : Colors.red),
                      ),
                      title: Text(ssid),
                      subtitle: Text("Signal: ${net["SIGNAL"]}%"),
                      trailing: connectingSsid == ssid
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : (net["IN-USE"] == "1"
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : null),
                      onTap: () async {
                        connectingNetwork.value = ssid;

                        final communicationService = context.read<CommunicationService>();

                        if (isSecured) {
                          final password = await showPasswordDialog(context, ssid);
                          if (password == null || password.isEmpty) return;

                          final payload = '2,$ssid,$password';
                          final livePayload = jsonEncode({"6000": {"6001": payload}});
                          await communicationService.sendCommand(serverMsg: '', payload: livePayload);
                        } else {
                          final payload = '2,$ssid,';
                          final livePayload = jsonEncode({"6000": {"6001": payload}});
                          await communicationService.sendCommand(serverMsg: '', payload: livePayload);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            )
          ],
        );
      },
    );
  }

  Future<String?> showPasswordDialog(BuildContext context, String ssid) async {
    final TextEditingController passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter password for "$ssid"'),
        content: PasswordField(controller: passwordController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, passwordController.text),
            child: const Text("Connect"),
          ),
        ],
      ),
    );
  }

}

class BadgeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final int badgeNumber;

  const BadgeButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.badgeNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          tooltip: 'Alarm',
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white,),
          hoverColor: Theme.of(context).primaryColorLight,
        ),
        if (badgeNumber > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class AlarmButton extends StatelessWidget {
  const AlarmButton({super.key, required this.alarmPayload, required this.deviceID, required this.customerId, required this.controllerId});
  final List<String> alarmPayload;
  final String deviceID;
  final int customerId, controllerId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: BadgeButton(
        onPressed: (){
          showPopover(
            context: context,
            bodyBuilder: (context) => AlarmListItems(alarm : alarmPayload, deviceID:deviceID, customerId: customerId, controllerId: controllerId,),
            onPop: () => print('Popover was popped!'),
            direction: PopoverDirection.bottom,
            width: alarmPayload[0].isNotEmpty?400:150,
            height: alarmPayload[0].isNotEmpty?(alarmPayload.length*80):50,
            arrowHeight: 15,
            arrowWidth: 30,
          );
        },
        icon: Icons.notifications_none,
        badgeNumber: (alarmPayload.isNotEmpty && alarmPayload[0].isNotEmpty) ?
        alarmPayload.length : 0,
      ),
    );
  }
}

class AlarmListItems extends StatelessWidget {
  const AlarmListItems({super.key, required this.alarm, required this.deviceID, required this.customerId, required this.controllerId});
  final List<String> alarm;

  final String deviceID;
  final int customerId, controllerId;

  @override
  Widget build(BuildContext context) {

    return alarm[0].isNotEmpty? Container(
      color: Colors.white,
      child: Column(
        children: List.generate(alarm.length * 2 - 1, (index) {
          if (index.isEven) {
            List<String> values = alarm[index ~/ 2].split(',');
            return buildScheduleRow(context, values);
          } else {
            return const Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Divider(color: Colors.black12),
            );
          }
        }),
      ),
    ):
    const Center(child: Text('No active alarms.', style: TextStyle(color: Colors.black54)));

  }

  Widget buildScheduleRow(BuildContext context, List<String> values) {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.warning_amber, color: values[7]=='1' ? Colors.orangeAccent : Colors.redAccent,),
          title: Text(MyFunction().getAlarmMessage(int.parse(values[2]))),
          subtitle: Text('Location : ${values[1]} \n DT:${values[5]} - ${values[6]}'),
          trailing: MaterialButton(
            color: Colors.redAccent,
            textColor: Colors.white,
            onPressed: () async {
              String finalPayload =  values[0];
              String payLoadFinal = jsonEncode({
                "4100": {"4101": finalPayload}
              });

              final result = await context.read<CommunicationService>().sendCommand(
                  serverMsg: 'Rested the ${MyFunction().getAlarmMessage(int.parse(values[2]))} alarm',
                  payload: payLoadFinal);

              if (result['http'] == true) {
                debugPrint("Payload sent to Server");
              }
              if (result['mqtt'] == true) {
                debugPrint("Payload sent to MQTT Box");
              }
              if (result['bluetooth'] == true) {
                debugPrint("Payload sent via Bluetooth");
              }

              Navigator.pop(context);

            },
            child: const Text('Reset'),
          ),
        )
      ],
    );
  }

}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}
