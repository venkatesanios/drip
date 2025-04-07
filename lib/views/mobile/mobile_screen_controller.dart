import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/Logs/irrigation_and_pump_log.dart';
import 'package:oro_drip_irrigation/Screens/planning/WeatherScreen.dart';
import 'package:oro_drip_irrigation/views/customer/sent_and_received.dart';
import '../../Models/customer/site_model.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
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
  const MobileScreenController({super.key, required this.userId, required this.customerName, required this.mobileNo, required this.emailId, required this.customerId, required this.fromLogin});
  final int customerId, userId;
  final String customerName, mobileNo, emailId;
  final bool fromLogin;

  void callbackFunction(message)
  {

  }

  @override
  Widget build(BuildContext context) {
    const String correctPassword = 'Oro@321';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavRailViewModel()),
        ChangeNotifierProvider(
          create: (_) => CustomerScreenControllerViewModel(context, Repository(HttpService()))..getAllMySites(context, customerId),
        ),
      ],
      child: Consumer2<NavRailViewModel, CustomerScreenControllerViewModel>(
        builder: (context, navViewModel, vm, _) {

          int wifiStrength = Provider.of<MqttPayloadProvider>(context).wifiStrength;
          String liveDataAndTime = Provider.of<MqttPayloadProvider>(context).liveDateAndTime;
          Duration lastCommunication = Provider.of<MqttPayloadProvider>(context).lastCommunication;
          int powerSupply = Provider.of<MqttPayloadProvider>(context).powerSupply;


          if(liveDataAndTime.isNotEmpty){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              vm.updateLivePayload(wifiStrength, liveDataAndTime);
            });
          }

          if(vm.isLoading){
            return const Scaffold(body: Center(child: Text('Site loading please waite....')));
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      scrollDirection: Axis.horizontal, // Enables horizontal scrolling
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
                                  style: const TextStyle(color: Colors.white, fontSize: 17),
                                ),
                              );
                            }).toList(),
                            onChanged: (siteName) => vm.siteOnChanged(siteName!),
                            value: vm.myCurrentSite,
                            dropdownColor: Colors.teal,
                            iconEnabledColor: Colors.white,
                            iconDisabledColor: Colors.white,
                            focusColor: Colors.transparent,
                          )
                              : Text(
                            vm.mySiteList.data[vm.sIndex].groupName,
                            style: const TextStyle(fontSize: 15, color: Colors.white54),
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(width: 15),
                          Container(width: 1, height: 20, color: Colors.white54),
                          const SizedBox(width: 5),

                          vm.mySiteList.data[vm.sIndex].master.length > 1
                              ? PopupMenuButton<String>(
                            color: Colors.white,
                            surfaceTintColor: Theme.of(context).primaryColorLight,
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
                                return PopupMenuItem<String>(
                                  value: vm.mySiteList.data[vm.sIndex].master[index].categoryName,
                                  child: Text(vm.mySiteList.data[vm.sIndex].master[index].categoryName),
                                );
                              });
                            },
                            onSelected: (selectedCategory) {
                              vm.masterOnChanged(selectedCategory);
                            },
                          )
                              : Text(
                            vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName,
                            style: const TextStyle(fontSize: 15, color: Colors.white54),
                          ),

                          const SizedBox(width: 15),
                          Container(width: 1, height: 20, color: Colors.white54),
                          const SizedBox(width: 5),

                          vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 &&
                              vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData.length > 1
                              ? DropdownButton(
                            underline: Container(),
                            items: (vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData ?? [])
                                .map((line) {
                              return DropdownMenuItem(
                                value: line.name,
                                child: Text(
                                  line.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 17),
                                ),
                              );
                            }).toList(),
                            onChanged: (lineName) => vm.lineOnChanged(lineName),
                            value: vm.myCurrentIrrLine,
                            dropdownColor: Theme.of(context).primaryColorLight,
                            iconEnabledColor: Colors.white,
                            iconDisabledColor: Colors.white,
                            focusColor: Colors.transparent,
                          )
                              : vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1
                              ? Text(
                            vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData.isNotEmpty
                                ? vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData[0].name
                                : 'Line empty',
                            style: const TextStyle(fontSize: 15),
                          )
                              : const SizedBox(),

                          const SizedBox(width: 15),
                          Container(width: 1, height: 20, color: Colors.white54),
                          const SizedBox(width: 5),

                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5), color: Colors.transparent),
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

                          Text(
                            'Last sync @ - ${Formatters.formatDateTime('${vm.mySiteList.data[vm.sIndex].master[vm.mIndex].live?.cD} ${vm.mySiteList.data[vm.sIndex].master[vm.mIndex].live?.cT}')}',
                            style: const TextStyle(fontSize: 15, color: Colors.white54),
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
                                Text(customerName, style: const TextStyle(color: Colors.white)),
                                Text(mobileNo, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                Text(emailId, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                const SizedBox(height: 20),
                                const Text("Version 1.0.0", style: TextStyle(color: Colors.white54)),
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
                    leading: Icon(Icons.account_circle_outlined, color: Theme.of(context).primaryColor),
                    title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                    title: const Text("App Info", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
                    title: const Text("Help", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback_outlined, color: Theme.of(context).primaryColor),
                    title: const Text("Send Feedback", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.support_agent_sharp, color: Theme.of(context).primaryColor),
                    title: const Text("Service Request", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),
                  ListTile(
                    leading: Icon(Icons.devices, color: Theme.of(context).primaryColor),
                    title: const Text("All my devices", style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_rounded),
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 25),
                    child: Divider(height: 0, color: Colors.grey.shade300),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Logout", style: TextStyle(color: Colors.red, fontSize: 17)),
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
            floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              elevation: 10,
              selectedFontSize: 14,
              unselectedFontSize: 12,
              currentIndex: vm.selectedIndex,
              onTap: vm.onItemTapped,
              selectedItemColor: Theme.of(context).primaryColorLight,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(icon: Icon(Icons.list), label: "Scheduled Program"),
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
              ],
            ),
            floatingActionButton: Stack(
              alignment: Alignment.bottomRight,
              children: [
                FloatingActionButton(
                  onPressed: null,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: PopupMenuButton<String>(
                    onSelected: (String value) {
                      switch (value) {
                        case 'Node Status':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NodeList(
                                customerId: customerId,
                                nodes: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].nodeList,
                                deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                deviceName: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName,
                                controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                userId: userId,
                              ),
                            ),
                          );
                          break;
                        case 'option2':
                          print("Option 2 selected");
                          break;
                        case 'option3':
                          print("Option 3 selected");
                          break;
                      }
                    },
                    offset: const Offset(0, -180), // Move menu **above** FAB
                    color: Colors.white,
                    icon: const Icon(Icons.menu, color: Colors.white),
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'Node Status',
                        child: Center(
                          child: Column(
                            children: [
                              CircleAvatar(backgroundColor: Theme.of(context).primaryColor,
                                  child: const Icon(Icons.format_list_numbered,
                                      color: Colors.white)),
                              const SizedBox(height: 5),
                              const Text('Node Status',textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'option2',
                        child: Center(
                          child: Column(children: [
                            CircleAvatar(backgroundColor: Theme.of(context).primaryColor,
                                child: const Icon(Icons.settings_input_component_outlined, color: Colors.white)),
                            const SizedBox(height: 5),
                            const Center(child: Text('I/O\nConnection',textAlign: TextAlign.center)),
                            const SizedBox(height: 8),
                          ],
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'option3',
                        child: Center(
                          child: Column(
                            children: [
                              CircleAvatar(backgroundColor: Theme.of(context).primaryColor,
                                  child: const Icon(Icons.list_alt, color: Colors.white)),
                              const SizedBox(height: 5),
                              const Text('Program',textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'option4',
                        child: Center(
                          child: Column(
                            children: [
                              CircleAvatar(backgroundColor: Theme.of(context).primaryColor,
                                  child: const Icon(Icons.view_list_outlined, color: Colors.white)),
                              const SizedBox(height: 5),
                              const Text('Scheduled\nprogram\ndetails',textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'option5',
                        child: Center(
                          child: Column(
                            children: [
                              CircleAvatar(backgroundColor: Theme.of(context).primaryColor,
                                  child: const Icon(Icons.touch_app_outlined, color: Colors.white)),
                              const SizedBox(height: 5),
                              const Text('Manual',textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'option6',
                        child: Center(
                          child: Column(
                            children: [
                              CircleAvatar(backgroundColor: Theme.of(context).primaryColor,
                                  child: const Icon(Icons.question_answer_outlined, color: Colors.white)),
                              const SizedBox(height: 5),
                              const Text('Sent &\nReceived',textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                lastCommunication.inMinutes >= 10 && powerSupply == 0?Container(
                  height: 23.0,
                  decoration: BoxDecoration(
                    color: Colors.red.shade300,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                  ),
                  child: Center(
                    child: Text('No communication and power Supply to Controller'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ):
                powerSupply == 0? Container(
                  height: 20.0,
                  decoration: BoxDecoration(
                    color: Colors.red.shade300,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                  ),
                  child: Center(
                    child: Text('No power Supply to Controller'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ):
                const SizedBox(),

                Expanded(
                  child: vm.selectedIndex==0 ?
                  mainScreen(navViewModel.selectedIndex, vm.mySiteList.data[vm.sIndex].groupId,
                      vm.mySiteList.data[vm.sIndex].groupName, vm.mySiteList.data[vm.sIndex].master,
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId):
                  vm.selectedIndex==1?
                  ScheduledProgram(
                    userId: customerId,
                    scheduledPrograms: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].programList,
                    controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                    deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                    customerId: customerId,
                  ):
                  ControllerSettings(customerId: customerId, controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId, adDrId: fromLogin ? 1 : 0, userId: userId,),
                ),
              ],
            ),

          );
        },
      ),
    );
  }


  List<NavigationRailDestination> getNavigationDestinations() {
    final destinations = [
      const NavigationRailDestination(
        padding: EdgeInsets.only(top: 5),
        icon: Tooltip(
          message: 'Home',
          child: Icon(Icons.home_outlined),
        ),
        selectedIcon: Icon(Icons.home, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Tooltip(
          message: 'All my devices',
          child: Icon(Icons.devices_other),
        ),
        selectedIcon: Icon(Icons.devices_other, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Tooltip(
          message: 'Sent & Received',
          child: Icon(Icons.question_answer_outlined),
        ),
        selectedIcon: Icon(Icons.question_answer, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Tooltip(
          message: 'Controller Logs',
          child: Icon(Icons.receipt_outlined),
        ),
        selectedIcon: Icon(Icons.receipt, color: Colors.white,),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Tooltip(
          message: 'Settings',
          child: Icon(Icons.settings_outlined),
        ),
        selectedIcon: Icon(Icons.settings, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Tooltip(
          message: 'Configuration',
          child: Icon(Icons.confirmation_num_outlined),
        ),
        selectedIcon: Icon(Icons.confirmation_num, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Tooltip(
          message: 'Weather',
          child: Icon(Icons.sunny_snowing),
        ),
        selectedIcon: Icon(Icons.sunny_snowing, color: Colors.white),
        label: Text(''),
      ),
    ];

    return destinations;
  }

  Widget mainScreen(int index, groupId, groupName, List<Master> masterData, int controllerId, int categoryId) {
    switch (index) {
      case 0:
        return categoryId==1?
        CustomerHome(customerId: userId, controllerId: controllerId):
        const Text('pump dashboard');
      case 1:
        return CustomerProduct(customerId: userId);
      case 2:
        return SentAndReceived(customerId: userId, controllerId: controllerId);
      case 3:
        return IrrigationAndPumpLog(userData: {'userId' : userId, 'controllerId' : controllerId});
      case 4:
        return ControllerSettings(customerId: customerId, controllerId: controllerId, adDrId: fromLogin ? 1 : 0, userId: userId,);
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
