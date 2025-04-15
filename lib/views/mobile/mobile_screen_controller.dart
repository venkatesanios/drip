import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/Logs/irrigation_and_pump_log.dart';
import 'package:oro_drip_irrigation/Screens/planning/WeatherScreen.dart';
import 'package:oro_drip_irrigation/views/customer/sent_and_received.dart';
import '../../Models/customer/site_model.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../modules/IrrigationProgram/view/program_library.dart';
import '../../modules/PumpController/model/pump_controller_data_model.dart';
import '../../modules/PumpController/view/pump_controller_home.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/formatters.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../view_models/nav_rail_view_model.dart';
import '../customer/controller_settings.dart';
import '../customer/customer_home.dart';
import '../customer/customer_product.dart';
import '../customer/home_sub_classes/scheduled_program.dart';
import '../customer/node_list.dart';


class MobileScreenController extends StatelessWidget {
  const MobileScreenController(
      {super.key, required this.userId, required this.customerName, required this.mobileNo, required this.emailId, required this.customerId, required this.fromLogin});

  final int customerId, userId;
  final String customerName, mobileNo, emailId;
  final bool fromLogin;

  void callbackFunction(message) {

  }

  @override
  Widget build(BuildContext context) {
    const String correctPassword = 'Oro@321';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavRailViewModel()),
        ChangeNotifierProvider(
          create: (_) =>
          CustomerScreenControllerViewModel(context, Repository(HttpService()))
            ..getAllMySites(context, customerId),
        ),
      ],
      child: Consumer2<NavRailViewModel, CustomerScreenControllerViewModel>(
        builder: (context, navViewModel, vm, _) {
          final mqttProvider = Provider.of<MqttPayloadProvider>(context);

          int wifiStrength = mqttProvider.wifiStrength;
          String liveDataAndTime = mqttProvider.liveDateAndTime;
          var iLineLiveMessage = mqttProvider.lineLiveMessage;
          Duration lastCommunication = mqttProvider.lastCommunication;
          int powerSupply = mqttProvider.powerSupply;
          var currentSchedule = mqttProvider.currentSchedule;


          if (liveDataAndTime.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              vm.updateLivePayload(
                  wifiStrength, liveDataAndTime, currentSchedule);
            });
          }

          if (vm.isLoading) {
            return const Scaffold(
                body: Center(child: Text('Site loading please waite....')));
          }

          return Scaffold(
            backgroundColor: Theme
                .of(context)
                .scaffoldBackgroundColor,
            appBar: AppBar(
              title: Image.asset(
                width: 140,
                "assets/png/lk_logo_white.png",
                fit: BoxFit.fitWidth,
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      tooltip: 'Alarms',
                      onPressed: vm.onAlarmClicked,
                      icon: const Icon(Icons.notifications_none),
                      color: Colors.white,
                      iconSize: 28.0,
                    ),
                    if (vm.unreadAlarmCount > 0)
                      Positioned(
                        right: 5,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${vm.unreadAlarmCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: Colors.black54,
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

                          const SizedBox(width: 15),
                          Container(
                              width: 1, height: 20, color: Colors.white54),
                          const SizedBox(width: 5),

                          vm.mySiteList.data[vm.sIndex].master.length > 1
                              ? PopupMenuButton<Map<String, String>>(
                            color: Theme
                                .of(context)
                                .primaryColorLight,
                            tooltip: 'master controller',
                            child: MaterialButton(
                              onPressed: null,
                              textColor: Colors.white,
                              child: Row(
                                children: [
                                  Text(vm.mySiteList.data[vm.sIndex].master[vm
                                      .mIndex].categoryName),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.arrow_drop_down,
                                      color: Colors.white),
                                ],
                              ),
                            ),
                            itemBuilder: (context) {
                              return List.generate(
                                  vm.mySiteList.data[vm.sIndex].master.length, (
                                  index) {
                                final master = vm.mySiteList.data[vm.sIndex]
                                    .master[index];
                                return PopupMenuItem<Map<String, String>>(
                                  value: {
                                    'category': master.categoryName,
                                    'model': master.modelName,
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.home_max_sharp, size: 20,
                                          color: Colors.white),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              master.categoryName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              master.modelName,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white54),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                            },
                            onSelected: (selected) {
                              final category = selected['category']!;
                              final model = selected['model']!;
                              vm.masterOnChanged(category, model);
                            },
                          )
                              :
                          Text(vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                              .categoryName,
                            style: const TextStyle(fontSize: 12),),

                          const SizedBox(width: 15),
                          Container(
                              width: 1, height: 20, color: Colors.white54),
                          const SizedBox(width: 5),

                          vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                              .categoryId == 1 &&
                              vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                                  .config.lineData.length > 1
                              ? DropdownButton(
                            underline: Container(),
                            items: (vm.mySiteList.data[vm.sIndex].master[vm
                                .mIndex].config.lineData ?? [])
                                .map((line) {
                              return DropdownMenuItem(
                                value: line.name,
                                child: Text(
                                  line.name,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 17),
                                ),
                              );
                            }).toList(),
                            onChanged: (lineName) => vm.lineOnChanged(lineName),
                            value: vm.myCurrentIrrLine,
                            dropdownColor: Theme
                                .of(context)
                                .primaryColorLight,
                            iconEnabledColor: Colors.white,
                            iconDisabledColor: Colors.white,
                            focusColor: Colors.transparent,
                          )
                              : vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                              .categoryId == 1
                              ? Text(
                            vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                                .config.lineData.isNotEmpty
                                ? vm.mySiteList.data[vm.sIndex].master[vm
                                .mIndex].config.lineData[0].name
                                : 'Line empty',
                            style: const TextStyle(fontSize: 15),
                          )
                              : const SizedBox(),

                          const SizedBox(width: 15),
                          Container(
                              width: 1, height: 20, color: Colors.white54),
                          const SizedBox(width: 5),

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
                                fontSize: 15, color: Colors.white54),
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
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () {},
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
                    trailing: const Icon(Icons.arrow_forward_rounded),
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
                    trailing: const Icon(Icons.arrow_forward_rounded),
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
                    trailing: const Icon(Icons.arrow_forward_rounded),
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
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () {},
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
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, top: 16, right: 16),
                    child: TextButton.icon(
                      onPressed: () {},
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
            floatingActionButtonLocation: FloatingActionButtonLocation
                .miniEndFloat,
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
              unselectedItemColor: Colors.grey,
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
            FloatingActionButton(
              onPressed: null,
              backgroundColor: Theme
                  .of(context)
                  .primaryColor,
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
                                  userId: userId,
                                ),
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
                      case 'option3':
                        print("Option 3 selected");
                        break;
                    }
                  },
                  offset: const Offset(0, -180),
                  // Move menu **above** FAB
                  color: Colors.white,
                  icon: const Icon(Icons.menu, color: Colors.white),
                  itemBuilder: (BuildContext context) =>
                  [
                    _buildPopupItem(
                        context, 'Node Status', Icons.format_list_numbered,
                        'Node Status'),
                    _buildPopupItem(context, 'option2',
                        Icons.settings_input_component_outlined,
                        'I/O\nConnection\ndetails'),
                    _buildPopupItem(
                        context, 'option3', Icons.list_alt, 'Program'),
                    _buildPopupItem(
                        context, 'option4', Icons.view_list_outlined,
                        'Scheduled\nprogram\ndetails'),
                    _buildPopupItem(
                        context, 'option5', Icons.touch_app_outlined, 'Manual'),
                    _buildPopupItem(context, 'Sent & Received',
                        Icons.question_answer_outlined, 'Sent &\nReceived'),
                    _buildPopupItem(context, 'option7', Icons.devices_other,
                        'All my\ndevices'),
                  ]
              ),
            ) : null,
            body: Container(
              decoration: BoxDecoration(
                color: Theme
                    .of(context)
                    .scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              ),
              child: Column(
                children: [
                  lastCommunication.inMinutes >= 10 && powerSupply == 0
                      ? Container(
                    height: 23.0,
                    decoration: BoxDecoration(
                      color: Colors.red.shade300,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                    ),
                    child: Center(
                      child: Text(
                        'No communication and power Supply to Controller'
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  )
                      :
                  (powerSupply == 0 &&
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                          .categoryId == 1) ? Container(
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: Colors.red.shade300,
                      borderRadius: const BorderRadius.only(topLeft: Radius
                          .circular(5), topRight: Radius.circular(5)),
                    ),
                    child: Center(
                      child: Text('No power Supply to Controller'.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ) :
                  const SizedBox(),

                  Expanded(
                    child: vm.selectedIndex == 0 ?
                    mainScreen(
                        navViewModel.selectedIndex,
                        vm.mySiteList.data[vm.sIndex].groupId,
                        vm.mySiteList.data[vm.sIndex].groupName,
                        vm.mySiteList.data[vm.sIndex].master,
                        vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                            .controllerId,
                        vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                            .categoryId,
                        vm.mIndex,
                        vm.sIndex
                    ) :
                    vm.selectedIndex == 1 ?
                    ScheduledProgram(
                      userId: customerId,
                      scheduledPrograms: vm.mySiteList.data[vm.sIndex].master[vm
                          .mIndex].programList,
                      controllerId: vm.mySiteList.data[vm.sIndex].master[vm
                          .mIndex].controllerId,
                      deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                          .deviceId,
                      customerId: customerId,
                      currentLineSNo: vm.mySiteList.data[vm.sIndex].master[vm
                          .mIndex].config.lineData[vm.lIndex].sNo,
                    ) :
                    ControllerSettings(customerId: customerId,
                      controllerId: vm.mySiteList.data[vm.sIndex].master[vm
                          .mIndex].controllerId,
                      adDrId: fromLogin ? 1 : 0,
                      userId: userId,
                      deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex]
                          .deviceId,),
                  ),
                ],
              ),
            ),

          );
        },
      ),
    );
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

  Widget mainScreen(int index, groupId, groupName, List<Master> masterData, int controllerId, int categoryId, int masterIndex, int siteIndex) {

      switch (index) {
        case 0:
          return categoryId==1? CustomerHome(customerId: userId, controllerId: controllerId):
          PumpControllerHome(
            deviceId: masterData[masterIndex].deviceId,
            liveData: masterData[masterIndex].live!.cM as PumpControllerData,
            masterName: groupName,
            userId: userId,
            customerId: customerId,
            controllerId: controllerId,
            siteIndex: siteIndex,
            masterIndex: masterIndex,
          );
        case 1:
          return CustomerProduct(customerId: userId);
        case 2:
          return SentAndReceived(customerId: userId, controllerId: controllerId);
        case 3:
          return IrrigationAndPumpLog(userData: {'userId' : userId, 'controllerId' : controllerId});
        case 4:
          return ControllerSettings(customerId: customerId, controllerId: controllerId,
            adDrId: fromLogin ? 1 : 0, userId: userId, deviceId: '',);
        case 6:
          return WeatherScreen(userId: userId, controllerId: controllerId, deviceID: '',);

        default:
          return const SizedBox();
      }
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
