import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothDevice;
import 'package:oro_drip_irrigation/Screens/Dealer/sevicecustomer.dart';
import 'package:oro_drip_irrigation/Screens/Logs/irrigation_and_pump_log.dart';
import 'package:oro_drip_irrigation/Widgets/network_connection_banner.dart';
import 'package:oro_drip_irrigation/modules/ScheduleView/view/schedule_view_screen.dart';
import 'package:oro_drip_irrigation/modules/UserChat/view/user_chat.dart';
import 'package:oro_drip_irrigation/views/customer/sent_and_received.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../models/customer/site_model.dart';
import '../../Screens/Dealer/ble_mobile_screen.dart';
import '../../StateManagement/customer_provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../flavors.dart';
import '../../modules/IrrigationProgram/view/program_library.dart';
import '../../modules/PumpController/view/node_settings.dart';
import '../../modules/PumpController/view/pump_controller_home.dart';
import '../../modules/bluetooth_low_energy/view/node_connection_page.dart';
import '../../modules/open_ai/view/open_ai_screen.dart';
import '../../providers/user_provider.dart';
import '../../services/communication_service.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/routes.dart';
import '../../utils/shared_preferences_helper.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import '../common/user_profile/user_profile.dart';
import '../customer/app_info.dart';
import '../customer/controller_settings/wide/controller_settings_wide.dart';
import '../customer/customer_home.dart';
import '../customer/customer_product.dart';
import '../customer/scheduled_program/scheduled_program_wide.dart';
import '../customer/input_output_connection_details.dart';
import '../customer/node_list/node_list.dart';
import '../customer/stand_alone.dart';
import '../customer/widgets/alarm_button.dart';
import '../customer/widgets/irrigation_line_selector_widget.dart';
import '../customer/widgets/master_selector_widget.dart';
import '../customer/widgets/site_selector_widget.dart';


class MobileScreenController extends StatefulWidget {
  const MobileScreenController({super.key, required this.fromLogin, required this.userId});
  final bool fromLogin;
  final int userId;

  @override
  State<MobileScreenController> createState() => _MobileScreenControllerState();
}

class _MobileScreenControllerState extends State<MobileScreenController> with WidgetsBindingObserver {

  late CustomerScreenControllerViewModel viewModel;
  late String? version;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      viewModel = Provider.of<CustomerScreenControllerViewModel>(context, listen: false);
      viewModel.getAllMySites(context, widget.userId);
      loadVersion();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void loadVersion() async {
    version = await getCurrentVersion();
    print('Loaded version: $version');
  }
  Future<String?> getCurrentVersion() async {
    print('call:current verssion');
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      print('packageInfo.version:->${packageInfo.version}');
      return packageInfo.version;

    } catch (e) {
      print('Error fetching release version: $e');
      return null;
    }
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App is resumed');
      Future.delayed(const Duration(milliseconds: 200), () {
        try {
          viewModel.onRefreshClicked();
        } catch (e) {
          debugPrint("Provider not found: $e");
        }
      });
    }
  }

  void callbackFunction(message){
  }

  @override
  Widget build(BuildContext context) {
    final loggedInUser = Provider.of<UserProvider>(context).loggedInUser;
    final viewedCustomer = Provider.of<UserProvider>(context).viewedCustomer;

    final vm = Provider.of<CustomerScreenControllerViewModel>(context);
    final commMode = Provider.of<CustomerProvider>(context).controllerCommMode;

    if (vm.isLoading) {
      return Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: Image.asset(F.appFlavor!.name.contains('oro')?
          'assets/oro_store.png':'assets/smartcomm_playstore.png',width: 175, height: 175)),
      );
    }

    final currentMaster = vm.mySiteList.data[vm.sIndex].master[vm.mIndex];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
          if([...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId))...[
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
            AlarmButton(alarmPayload: vm.alarmDL, deviceID: currentMaster.deviceId,
                customerId: viewedCustomer!.id, controllerId: currentMaster.controllerId, irrigationLine: currentMaster.irrigationLine),
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
          if(![...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId))...[
            Container(
              height: 35,
              decoration: BoxDecoration(
                  color: MediaQuery.of(context).size.width >= 600 ? Colors.transparent: Theme.of(context).primaryColorLight,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), bottomLeft: Radius.circular(25))
              ),
              child: Row(
                children: [
                  if(currentMaster.nodeList.isNotEmpty
                      && [48, 49].contains(currentMaster.modelId))
                    InkWell(
                        onTap: (){
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return NodeSettings(
                                  userId: viewedCustomer!.id,
                                  controllerId: currentMaster.controllerId,
                                  customerId: viewedCustomer.id,
                                  nodeList: currentMaster.nodeList,
                                  deviceId: currentMaster.deviceId,
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
                                  customerId: loggedInUser.id,
                                  controllerId: currentMaster.controllerId,
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
                            'controllerId': currentMaster.controllerId,
                            'deviceId': currentMaster.deviceId,
                            'deviceName': currentMaster.deviceName,
                            'categoryId': currentMaster.categoryId,
                            'categoryName': currentMaster.categoryName,
                            'modelId': currentMaster.modelId,
                            'modelName': currentMaster.modelName,
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
                              "userId" : loggedInUser.id,
                              "customerId" : viewedCustomer!.id,
                              "controllerId" : currentMaster.controllerId
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
                    if ([...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId) &&
                        currentMaster.irrigationLine.length > 1)
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
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(viewedCustomer!.name, style: const TextStyle(
                              color: Colors.white)),
                          Text(viewedCustomer.mobileNo, style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                          Text(viewedCustomer.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 20),
                          Text("Version:$version",
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
                    builder: (context) => const UserProfile(),
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
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => UserChatScreen(userId: viewedCustomer.id,
                        userName: viewedCustomer.name, phoneNumber: viewedCustomer.mobileNo))
                );
              },
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
                  MaterialPageRoute(builder: (context) =>  TicketHomePage(userId: loggedInUser.id,
                    controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,)),
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
                  MaterialPageRoute(builder: (context) =>  CustomerProduct(customerId: loggedInUser.id)),
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
      bottomNavigationBar: [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId) ?
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
      ) : null,
      floatingActionButton: [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId) ?
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
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
                              customerId: viewedCustomer.id,
                              nodes: currentMaster.nodeList,
                              userId: loggedInUser.id,
                              configObjects: currentMaster.configObjects,
                              masterData: currentMaster, isWide: false),
                        ),
                      );
                      break;

                    case 'I/O Connection':
                      Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => InputOutputConnectionDetails(
                              masterInx: vm.mIndex, nodes: currentMaster.nodeList),
                        ),
                      );
                      break;

                    case 'Sent & Received':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SentAndReceived(
                              customerId: viewedCustomer.id,
                              controllerId: currentMaster.controllerId
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
                                  customerId: viewedCustomer.id,
                                  controllerId: currentMaster.controllerId,
                                  deviceId: currentMaster.deviceId,
                                  userId: loggedInUser.id,
                                  groupId: vm.mySiteList.data[vm.sIndex].groupId,
                                  categoryId: currentMaster.categoryId,
                                  modelId: currentMaster.modelId,
                                  deviceName: currentMaster.deviceName,
                                  categoryName: currentMaster.categoryName,
                                  callbackFunction: callbackFunction,
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
                                  deviceId: currentMaster.deviceId,
                                  userId: loggedInUser.id,
                                  controllerId: currentMaster.controllerId,
                                  customerId: viewedCustomer.id,
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
                                    controllerId: currentMaster.controllerId,
                                    customerId: viewedCustomer.id,
                                    deviceId: currentMaster.deviceId,
                                    callbackFunction: callbackFunction,
                                    userId: loggedInUser.id, masterData: currentMaster);
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
            heroTag: null,
            backgroundColor: commMode == 1? Theme.of(context).primaryColorLight:
            (commMode == 2 && vm.blueService.isConnected) ?
            Theme.of(context).primaryColorLight : Colors.redAccent,
            onPressed: ()=>_showBottomSheet(context, currentMaster, vm, viewedCustomer.id, loggedInUser.id),
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
      floatingActionButtonAnimator: null,
      body: ![...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId) ?
      vm.isChanged ? PumpControllerHome(
        userId: loggedInUser.id,
        customerId: viewedCustomer.id,
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
                      return CustomerHome(
                        customerId: loggedInUser.id,
                        controllerId: currentMaster.controllerId,
                        deviceId: currentMaster.deviceId,
                        modelId: currentMaster.modelId,
                      );
                    case 1:
                      return ScheduledProgramWide(
                        userId: loggedInUser.id,
                        scheduledPrograms: currentMaster.programList,
                        controllerId: currentMaster.controllerId,
                        deviceId: currentMaster.deviceId,
                        customerId: viewedCustomer.id,
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
                          'userId': loggedInUser.id,
                          'controllerId': currentMaster.controllerId,
                          'customerId': viewedCustomer.id
                        },
                        masterData: currentMaster,
                      );
                    default:
                      return ControllerSettingWide(
                        customerId: viewedCustomer.id,
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

  void _showBottomSheet(BuildContext context, MasterControllerModel currentMaster,
      CustomerScreenControllerViewModel vm, int customerId, int userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                  if(currentMaster.modelId==3)...[
                    ListTile(
                      title: const Text('Scan & Connect the controller via Bluetooth',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Stay close to the controller near by 10 meters',
                          style: TextStyle(color: Colors.black45)),
                      trailing: const Icon(CupertinoIcons.arrow_right_circle),
                      onTap: (){
                        final Map<String, dynamic> data = {
                          'controllerId': currentMaster.controllerId,
                          'deviceId': currentMaster.deviceId,
                          'deviceName': currentMaster.deviceName,
                          'categoryId': currentMaster.categoryId,
                          'categoryName': currentMaster.categoryName,
                          'modelId': currentMaster.modelId,
                          'modelName': currentMaster.modelName,
                          'InterfaceType': currentMaster.interfaceTypeId,
                          'interface': currentMaster.interface,
                          'relayOutput': currentMaster.relayOutput,
                          'latchOutput': currentMaster.latchOutput,
                          'analogInput': currentMaster.analogInput,
                          'digitalInput': currentMaster.digitalInput,
                        };
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NodeConnectionPage(
                          nodeData: data,
                          masterData: {
                            "userId" : userId,
                            "customerId" : customerId,
                            "controllerId" : currentMaster.controllerId
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
                                            builder: (context) => BLEMobileScreen(deviceID: currentMaster.deviceId,
                                                communicationType: 'Bluetooth',userId: customerId,controllerId: currentMaster.controllerId),
                                        ));
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
                  ) :
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


/*class AlarmButton extends StatelessWidget {
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
}*/

/*class AlarmListItems extends StatelessWidget {
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

}*/

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
