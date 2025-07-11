import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothDevice;
import 'package:oro_drip_irrigation/Screens/Dealer/sevicecustomer.dart';
import 'package:oro_drip_irrigation/Screens/Logs/irrigation_and_pump_log.dart';
import 'package:oro_drip_irrigation/modules/ScheduleView/view/schedule_view_screen.dart';
import 'package:oro_drip_irrigation/views/customer/sent_and_received.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import '../../Screens/Dealer/ble_mobile_screen.dart';
import '../../StateManagement/customer_provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../flavors.dart';
import '../../modules/IrrigationProgram/view/program_library.dart';
import '../../modules/PumpController/view/node_settings.dart';
import '../../modules/PumpController/view/pump_controller_home.dart';
import '../../modules/bluetooth_low_energy/view/node_connection_page.dart';
import '../../modules/open_ai/view/open_ai_screen.dart';
import '../../repository/repository.dart';
import '../../services/communication_service.dart';
import '../../services/http_service.dart';
import '../../utils/formatters.dart';
import '../../utils/my_function.dart';
import '../../utils/routes.dart';
import '../../utils/shared_preferences_helper.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import '../account_settings.dart';
import '../customer/app_info.dart';
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
                body: Center(child: Text('Site loading please wait....')));
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: F.appFlavor!.name.contains('oro') ?
              Image.asset(
                width: 70,
                "assets/png/oro_logo_white.png",
                fit: BoxFit.fitWidth,
              ) :
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
                          vm.programRunning ? CircleAvatar(
                            radius: 15,
                            backgroundImage: const AssetImage('assets/gif/water_drop_ani.gif'),
                            backgroundColor: Colors.blue.shade100,
                          )
                              : const SizedBox(),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  AlarmButton(alarmPayload: vm.alarmDL, deviceID: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                      customerId: customerId, controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId),
                  IconButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AIChatScreen()),
                        );
                      },
                      icon: const Icon(Icons.assistant)
                  ),
                  // const SizedBox(width: 16),
                ],
                if(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2)...[
                  Container(
                    height: 35,
                    decoration: BoxDecoration(
                        color: MediaQuery.of(context).size.width >= 600 ? Colors.transparent: Theme.of(context).primaryColorLight,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), bottomLeft: Radius.circular(25))
                    ),
                    child: Row(
                      children: [
                        if(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].nodeList.isNotEmpty
                            && [48, 49].contains(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId))
                          InkWell(
                              onTap: (){
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
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.settings_remote),
                              )
                          ),
                        InkWell(
                            onTap: (){
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
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.question_answer_outlined),
                            )
                        ),
                        if(!kIsWeb)
                          InkWell(
                              onTap: (){
                                final Map<String, dynamic> data = {
                                  'controllerId': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                  'deviceId': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                  'deviceName': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceName,
                                  'categoryId': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId,
                                  'categoryName': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName,
                                  'modelId': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId,
                                  'modelName': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelName,
                                  'InterfaceType': 1,
                                  'interface': 'GSM',
                                  'relayOutput': 3,
                                  'latchOutput': 0,
                                  'analogInput': 8,
                                  'digitalInput': 4,
                                };
                                Navigator.push(context, MaterialPageRoute(builder: (context) => NodeConnectionPage(
                                  nodeData: data,
                                  masterData: {
                                    "userId" : userId,
                                    "customerId" : customerId,
                                    "controllerId" : vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId
                                  },
                                )));
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.bluetooth),
                              )
                          ),
                        InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AIChatScreen()),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.assistant),
                            )
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15),
                          SiteSelectorWidget(vm: vm, context: context),
                          const VerticalDividerWhite(),
                          MasterSelectorWidget(vm: vm, sIndex: vm.sIndex, mIndex: vm.mIndex),
                          if (vm.mySiteList.data[vm.sIndex].master.length > 1)
                            const VerticalDividerWhite(),
                          IrrigationLineSelectorWidget(vm: vm),
                          if (vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 &&
                              vm.mySiteList.data[vm.sIndex].master[vm.mIndex].irrigationLine.length > 1)
                            const VerticalDividerWhite(),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.transparent,
                            ),
                            width: 45,
                            height: 45,
                            child: IconButton(
                              tooltip: 'refresh',
                              onPressed: vm.onRefreshClicked,
                              icon: const Icon(Icons.refresh),
                              color: Colors.white,
                              iconSize: 24.0,
                              hoverColor: Theme.of(context).primaryColorLight,
                            ),
                          ),

                          Selector<CustomerScreenControllerViewModel, String>(
                            selector: (_, vm) => vm.mqttProvider.liveDateAndTime,
                            builder: (_, liveDateAndTime, __) => Text('Last sync @ - ${Formatters.formatDateTime(liveDateAndTime)}',
                                style: const TextStyle(fontSize: 14, color: Colors.white60)),
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
                                Text(emailId,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 14)),
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
                          builder: (context) => AccountSettings(userId: customerId, customerId: customerId, userName: customerName, mobileNo: mobileNo, emailId: emailId, hideAppbar: false),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppInfo(),
                        ),
                      );
                    },
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
                        Image.asset('assets/png/company_logo_nia.png', width: 60):
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
            bottomNavigationBar: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 ?
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
            )
            : null,
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
                      offset: const Offset(0, -180),
                      color: Colors.white,
                      onSelected: (String value) {
                        switch (value) {
                          case 'Node Status':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NodeList(
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
                  onPressed: ()=>_showBottomSheet(context, vm, vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId),
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
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                ),
                child: Column(
                  children: [
                    if (vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1) ...[
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
                          final master = vm.mySiteList.data[vm.sIndex].master[vm.mIndex];

                          switch (vm.selectedIndex) {
                            case 0:
                              return CustomerHome(
                                customerId: userId,
                                controllerId: master.controllerId,
                                deviceId: master.deviceId,
                              );

                            case 1:
                              return ScheduledProgram(
                                userId: customerId,
                                scheduledPrograms: master.programList,
                                controllerId: master.controllerId,
                                deviceId: master.deviceId,
                                customerId: customerId,
                                currentLineSNo: master.irrigationLine[vm.lIndex].sNo,
                                groupId: vm.mySiteList.data[vm.sIndex].groupId,
                                categoryId: master.categoryId,
                                modelId: master.modelId,
                                deviceName: master.deviceName,
                                categoryName: master.categoryName,
                              );

                            case 2:
                              return IrrigationAndPumpLog(
                                userData: {
                                  'userId': userId,
                                  'controllerId': master.controllerId,
                                },
                                masterData: master,
                              );

                            default:
                              return ControllerSettings(
                                customerId: customerId,
                                userId: userId,
                                masterController: master,
                              );
                          }
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
              backgroundColor: Theme.of(context).primaryColorLight,
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
                  if(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId==3)...[
                    ListTile(
                      title: const Text('Scan & Connect the controller via Bluetooth',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Stay close to the controller near by 10 meters',
                          style: TextStyle(color: Colors.black45)),
                      trailing: const Icon(CupertinoIcons.arrow_right_circle),
                      onTap: (){
                        final Map<String, dynamic> data = {
                          'controllerId': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                          'deviceId': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                          'deviceName': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceName,
                          'categoryId': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId,
                          'categoryName': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName,
                          'modelId': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId,
                          'modelName': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelName,
                          'InterfaceType': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].interfaceTypeId,
                          'interface': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].interface,
                          'relayOutput': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].relayOutput,
                          'latchOutput': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].latchOutput,
                          'analogInput': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].analogInput,
                          'digitalInput': vm.mySiteList.data[vm.sIndex].master[vm.mIndex].digitalInput,
                        };
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NodeConnectionPage(
                          nodeData: data,
                          masterData: {
                            "userId" : userId,
                            "customerId" : customerId,
                            "controllerId" : vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId
                          },
                        )));
                      },
                    ),
                  ]
                  else...[
                    BluetoothScanTile(vm: vm),
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
                                    const Icon(Icons.check_circle, color: Colors.green),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        requestAndShowWifiList(context, false);
                                      },
                                      icon: const Icon(CupertinoIcons.text_badge_checkmark),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BLEMobileScreen(deviceID: vm.mySiteList.data[vm.sIndex]
                                                .master[vm.mIndex].deviceId, communicationType: 'Bluetooth',),
                                          ),
                                        );
                                      },
                                      icon: const Icon(CupertinoIcons.exclamationmark_octagon),
                                    ),
                                  ],
                                ):
                                d.isConnecting ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ):
                                TextButton(
                                  onPressed: d.isDisConnected ? () => vm.blueService.connectToDevice(d) : null,
                                  child: const Text('Connect'),
                                ),
                              );
                            }).toList(),
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'Stay close to the controller and tap refresh to try scanning again.',
                              style: TextStyle(fontSize: 12, color: Colors.black38),
                            ),
                          );
                        }
                      },
                    ),
                  ]
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
        final wifiStatus = provider.wifiStatus;
        final interfaceType = provider.interfaceType;
        final ipAddress = provider.ipAddress;

        if (message != null && message.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (message == 'WWi-Fi is now ON' || message == 'Wi-Fi is now OFF') {
              context.read<MqttPayloadProvider>().clearWifiMessage();
              Future.delayed(const Duration(milliseconds: 1500), () {
                requestAndShowWifiList(context, true);
              });
            } else {
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
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          showWifiListDialog(context);
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  );
                },
              );
            }
          });
        }

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.wifi),
                    title: const Text("Wi-Fi"),
                    subtitle: wifiStatus == '2'
                        ? const Text(
                      'Wi-Fi is enabled on the controller \n But No Internet connection',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    )
                        : Text(
                      wifiStatus == '1'
                          ? 'Wi-Fi is enabled on the controller'
                          : 'Wi-Fi is disabled on the controller',
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: provider.wifiStateChanging? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ) : Switch(
                        value: wifiStatus == '1' || wifiStatus == '2',
                        activeColor: Colors.blue,
                        onChanged: (bool value) async {
                          provider.updateWifiStatus('0', true);
                          final communicationService = context.read<CommunicationService>();
                          final livePayload = jsonEncode({
                            "6000": {
                              "6001": value ? '1,0,0' : '0,0,0',
                            }
                          });

                          await communicationService.sendCommand(serverMsg: '', payload: livePayload,);

                        },
                      ),
                    ),
                  ),
                  const Divider(height: 0),
                  (wifiStatus=='1'||wifiStatus=='2')? ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Available Networks"),
                    subtitle: const Text(
                      "Select a Wi-Fi network to change the controller's connection.",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        requestAndShowWifiList(context, true);
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ):
                  const SizedBox(),
                ],
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: SizedBox(
                width: double.maxFinite,
                child: interfaceType=='ethernet'? ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Controller connected with ethernet'),
                  subtitle: Text('IpAddress : $ipAddress'),
                  trailing: const Icon(Icons.cast_connected),
                ):
                networks.isEmpty
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

class BluetoothScanTile extends StatefulWidget {
  final CustomerScreenControllerViewModel vm;

  const BluetoothScanTile({super.key, required this.vm});

  @override
  State<BluetoothScanTile> createState() => _BluetoothScanTileState();
}

class _BluetoothScanTileState extends State<BluetoothScanTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _rotationAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  Future<void> startScan() async {
    if (isScanning) return;
    setState(() {
      isScanning = true;
    });
    _controller.repeat();
    await widget.vm.blueService.getDevices(widget.vm.mySiteList.data[widget.vm.sIndex].master[widget.vm.mIndex].deviceId);
    setState(() {
      isScanning = false;
    });
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      title: const Text(
        "Scan for Bluetooth Devices and Connect",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      trailing: RotationTransition(
        turns: _rotationAnimation,
        child: IconButton(
          icon: Icon(
            Icons.refresh_outlined,
            color: isScanning ? Colors.blue : Colors.black,
          ),
          onPressed: startScan,
        ),
      ),
    );
  }
}

class VerticalDividerWhite extends StatelessWidget {
  const VerticalDividerWhite({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: 1,
        height: 20,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.white54),
        ),
      ),
    );
  }
}

class SiteSelectorWidget extends StatelessWidget {
  final CustomerScreenControllerViewModel vm;
  final BuildContext context;

  const SiteSelectorWidget({
    super.key,
    required this.vm,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    if ((vm.mySiteList.data.length ?? 0) > 1) {
      return DropdownButton(
        isExpanded: false,
        underline: Container(),
        items: (vm.mySiteList.data ?? []).map((site) {
          return DropdownMenuItem(
            value: site.groupName,
            child: Text(
              site.groupName,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
        onChanged: (siteName) => vm.siteOnChanged(siteName!),
        value: vm.myCurrentSite,
        dropdownColor: Theme.of(context).primaryColorLight,
        iconEnabledColor: Colors.white,
        iconDisabledColor: Colors.white,
        focusColor: Colors.transparent,
      );
    } else {
      return Text(
        vm.mySiteList.data[vm.sIndex].groupName,
        style: const TextStyle(fontSize: 15, color: Colors.white54, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}

class MasterSelectorWidget extends StatelessWidget {
  final CustomerScreenControllerViewModel vm;
  final int sIndex;
  final int mIndex;

  const MasterSelectorWidget({
    super.key,
    required this.vm,
    required this.sIndex,
    required this.mIndex,
  });

  @override
  Widget build(BuildContext context) {
    final masterList = vm.mySiteList.data[sIndex].master;
    if (masterList.length <= 1) return const SizedBox();
    return PopupMenuButton<int>(
      color: Theme.of(context).primaryColorLight,
      tooltip: 'master controller',
      child: MaterialButton(
        onPressed: null,
        textColor: Colors.white,
        child: Row(
          children: [
            Text(masterList[mIndex].categoryName),
            const SizedBox(width: 3),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
      itemBuilder: (context) {
        return List.generate(masterList.length, (index) {
          final master = masterList[index];
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
        vm.masterOnChanged(index);
      },
    );
  }
}

class IrrigationLineSelectorWidget extends StatelessWidget {
  final CustomerScreenControllerViewModel vm;

  const IrrigationLineSelectorWidget({
    super.key,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final master = vm.mySiteList.data[vm.sIndex].master[vm.mIndex];
    if (master.categoryId != 1 || master.irrigationLine.length <= 1) {
      return const SizedBox();
    }
    return DropdownButton<int>(
      underline: Container(),
      items: List.generate(master.irrigationLine.length, (index) {
        final line = master.irrigationLine[index];
        return DropdownMenuItem<int>(
          value: index,
          child: Text(
            line.name,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      }),
      onChanged: (selectedIndex) {
        if (selectedIndex != null) {
          vm.lineOnChanged(selectedIndex);
        }
      },
      value: vm.lIndex,
      dropdownColor: Theme.of(context).primaryColorLight,
      iconEnabledColor: Colors.white,
      iconDisabledColor: Colors.white,
      focusColor: Colors.transparent,
    );
  }
}
