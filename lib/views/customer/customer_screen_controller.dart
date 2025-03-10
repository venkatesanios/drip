import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/customer/program_schedule.dart';
import 'package:oro_drip_irrigation/views/customer/sent_and_received.dart';
import 'package:oro_drip_irrigation/views/customer/site_config.dart';
import 'package:oro_drip_irrigation/views/customer/stand_alone.dart';
import '../../Models/customer/site_model.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../flavors.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/formatters.dart';
import '../../utils/routes.dart';
import '../../utils/shared_preferences_helper.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../view_models/nav_rail_view_model.dart';
import '../account_settings.dart';
import 'controller_settings.dart';
import 'customer_home.dart';
import 'customer_product.dart';
import 'input_output_connection_details.dart';
import 'node_list.dart';

class CustomerScreenController extends StatelessWidget {
  const CustomerScreenController({super.key, required this.userId, required this.customerName, required this.mobileNo, required this.emailId, required this.customerId, required this.fromLogin});
  final int customerId, userId;
  final String customerName, mobileNo, emailId;
  final bool fromLogin;

  void callbackFunction(message)
  {
    /*Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 500), () {
      _showSnackBar(message);
    });*/
  }

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavRailViewModel()),
        ChangeNotifierProvider(
          create: (_) => CustomerScreenControllerViewModel(context, Repository(HttpService()))..getAllMySites(customerId),
        ),
      ],
      child: Consumer2<NavRailViewModel, CustomerScreenControllerViewModel>(
        builder: (context, navViewModel, vm, _) {

          int wifiStrength = Provider.of<MqttPayloadProvider>(context).wifiStrength;
          String liveDataAndTime = Provider.of<MqttPayloadProvider>(context).liveDateAndTime;

          if(liveDataAndTime.isNotEmpty){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              vm.updateLivePayload(wifiStrength, liveDataAndTime);
            });
          }

          if(vm.isLoading){
            return const Scaffold(body: Center(child: Text('Site loading please waite....')));
          }
          return Scaffold(
            appBar: AppBar(
              title:  Row(
                children: [
                  fromLogin ?const SizedBox():
                  const SizedBox(width: 10),
                  fromLogin ? Image(
                    image: F.appFlavor!.name.contains('oro')?const AssetImage("assets/png_images/oro_logo_white.png"):
                    const AssetImage("assets/png_images/company_logo.png"),
                    width: 110,
                    fit: BoxFit.fitWidth,
                  ):
                  const SizedBox(),

                  fromLogin ?const SizedBox(width: 20,):
                  const SizedBox(width: 0),

                  Container(width: 1, height: 20, color: Colors.white54,),
                  const SizedBox(width: 5,),

                  vm.mySiteList.data.length>1? DropdownButton(
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
                  ):
                  Text(vm.mySiteList.data[vm.sIndex].groupName,
                    style: const TextStyle(fontSize: 17), overflow: TextOverflow.ellipsis,),

                  const SizedBox(width: 15,),
                  Container(width: 1,height: 20, color: Colors.white54,),
                  const SizedBox(width: 5,),

                  vm.mySiteList.data[vm.sIndex].master.length>1? DropdownButton(
                    isExpanded: false,
                    underline: Container(),
                    items: (vm.mySiteList.data[vm.sIndex].master ?? []).map((master) {
                      return DropdownMenuItem(
                        value: master.categoryName,
                        child: Text(master.deviceName, style: const TextStyle(color: Colors.white, fontSize: 17),),
                      );
                    }).toList(),
                    onChanged: (categoryName) => vm.masterOnChanged(categoryName),
                    value: vm.myCurrentMaster,
                    dropdownColor: Colors.teal,
                    iconEnabledColor: Colors.white,
                    iconDisabledColor: Colors.white,
                    focusColor: Colors.transparent,
                  ) :
                  Text(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName,
                    style: const TextStyle(fontSize: 17),),

                  vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 ||
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2?
                  const SizedBox(width: 15,): const SizedBox(),

                  vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 ||
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2?
                  Container(width: 1,height: 20, color: Colors.white54,): const SizedBox(),

                  vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 ||
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2?
                  const SizedBox(width: 5,): const SizedBox(),

                  /*(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 ||
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2) &&
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData.length>1?
                  DropdownButton(
                    underline: Container(),
                    items: (vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData ?? []).map((line) {
                      return DropdownMenuItem(
                        value: line.name,
                        child: Text(line.name, style: const TextStyle(color: Colors.white, fontSize: 17),),
                      );
                    }).toList(),
                    onChanged: (lineName) =>vm.lineOnChanged(lineName),
                    value: vm.myCurrentIrrLine,
                    dropdownColor: Colors.teal,
                    iconEnabledColor: Colors.white,
                    iconDisabledColor: Colors.white,
                    focusColor: Colors.transparent,
                  ) :
                  (vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 ||
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2)?
                  Text(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData.isNotEmpty?
                  vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData[0].name:
                  'Line empty', style: const TextStyle(fontSize: 17),):
                  const SizedBox(),*/

                  (vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 ||
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2) &&
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData.isNotEmpty
                      ? DropdownButton<String>(
                    underline: Container(),
                    items: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData
                        .map((line) => DropdownMenuItem<String>(
                      value: line.name,
                      child: Text(
                        line.name,
                        style: const TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ))
                        .toList(),
                    onChanged: (lineName) => vm.lineOnChanged(lineName),
                    value: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData
                        .any((line) => line.name == vm.myCurrentIrrLine)
                        ? vm.myCurrentIrrLine
                        : null,
                    dropdownColor: Colors.teal,
                    iconEnabledColor: Colors.white,
                    iconDisabledColor: Colors.white,
                    focusColor: Colors.transparent,
                  )
                      : (vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 ||
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2)
                      ? Text(
                    vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData.isNotEmpty
                        ? vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config.lineData[0].name
                        : 'Line empty',
                    style: const TextStyle(fontSize: 17),
                  )
                      : const SizedBox(),

                  const SizedBox(width: 15,),
                  Container(width: 1, height: 20, color: Colors.white54,),
                  const SizedBox(width: 5,),

                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.transparent
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

                  Text(
                    'Last sync @ - ${Formatters.formatDateTime('${vm.mySiteList.data[vm.sIndex].master[vm.mIndex].live?.cD} ${vm.mySiteList.data[vm.sIndex].master[vm.mIndex].live?.cT}')}',
                    style: const TextStyle(fontSize: 15, color: Colors.white70),
                  ),
                ],
              ),
              leadingWidth: 75,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    tileMode: TileMode.clamp,
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor], // Define your gradient colors
                  ),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                   /* payload.currentSchedule.isNotEmpty?
                    CircleAvatar(
                      radius: 15,
                      backgroundImage: const AssetImage('assets/GifFile/water_drop_ani.gif'),
                      backgroundColor: Colors.blue.shade100,
                    ):
                    const SizedBox(),
                    const SizedBox(width: 10,),*/

                    TextButton(
                      onPressed: () {},
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
                        shape: WidgetStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pause, color: Colors.black),
                          SizedBox(width: 5),
                          Text('PAUSE ALL LINE', style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),
                    const IconButton(color: Colors.transparent, onPressed: null, icon: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.mic, color: Colors.black26,),
                    )),
                    IconButton(tooltip : 'Help & Support', onPressed: (){

                    }, icon: const CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.live_help_outlined),
                    )),
                    IconButton(tooltip : 'Niagara Account\n$customerName\n $mobileNo', onPressed: (){
                      showMenu(
                        context: context,
                        position: const RelativeRect.fromLTRB(100, 0, 10, 0),
                        color: Colors.white,
                        items: <PopupMenuEntry>[
                          PopupMenuItem(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: CircleAvatar(radius: 30, backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                    child: Text(customerName.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(fontSize: 25)),),
                                ),
                                Text('Hi, $customerName!',style: const TextStyle(fontSize: 20)),
                                Text(mobileNo, style: const TextStyle(fontSize: 13)),
                                const SizedBox(height: 8),
                                MaterialButton(
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  child: const Text('Manage Your Niagara Account'),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AccountSettings(userId: customerId, customerId: customerId, userName: customerName, mobileNo: mobileNo, emailId: emailId),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                TextButton(onPressed: () async {
                                  await PreferenceHelper.clearAll();
                                  Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false,);
                                },
                                  child: const SizedBox(
                                    width:100,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.exit_to_app, color: Colors.red),
                                        SizedBox(width: 7),
                                        Text('Logout', style: TextStyle(color: Colors.red),),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                        icon: CircleAvatar(
                          radius: 17,
                          backgroundColor: Colors.white,
                          child: Text(customerName.substring(0, 1).toUpperCase()),
                        )
                    ),
                  ],),
                const SizedBox(width: 05),
              ],
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NavigationRail(
                  selectedIndex: navViewModel.selectedIndex,
                  labelType: NavigationRailLabelType.all,
                  elevation: 5,
                  onDestinationSelected: (int index) {
                    navViewModel.onDestinationSelectingChange(index);
                  },
                  destinations: getNavigationDestinations(),
                ),
                Expanded(
                  child: Container(
                      width: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId==1 ||
                          vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId==2?
                      MediaQuery.sizeOf(context).width-140:
                      MediaQuery.sizeOf(context).width-80,
                      height: MediaQuery.sizeOf(context).height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          tileMode: TileMode.clamp,
                          colors: [Theme.of(context).primaryColorDark, Theme.of(context).primaryColor],
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                        ),
                        child: mainScreen(navViewModel.selectedIndex, vm.mySiteList.data[vm.sIndex].groupId,
                            vm.mySiteList.data[vm.sIndex].groupName, vm.mySiteList.data[vm.sIndex].master,
                            vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId),
                      )
                  ),
                ),
                Container(
                  width: 60,
                  height: MediaQuery.sizeOf(context).height,
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.transparent
                        ),
                        width: 45,
                        height: 45,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        width: 45,
                        height: 45,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: BadgeButton(
                          onPressed: (){
                            /*showPopover(
                              context: context,
                              bodyBuilder: (context) => AlarmListItems(payload:payload, deviceID:deviceID, customerId: customerId, controllerId: controllerId,),
                              onPop: () => print('Popover was popped!'),
                              direction: PopoverDirection.left,
                              width: payload.alarmList.isNotEmpty?600:250,
                              height: payload.alarmList.isNotEmpty?(payload.alarmList.length*45)+20:50,
                              arrowHeight: 15,
                              arrowWidth: 30,
                            );*/
                          },
                          icon: Icons.alarm,
                          badgeNumber: 0,
                        ),
                      ),
                      const SizedBox(height: 15),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.transparent,
                        child: SizedBox(
                          height: 45,
                          width: 45,
                          child: IconButton(
                            tooltip: 'Node status',
                            onPressed: () {
                              showGeneralDialog(
                                barrierLabel: "Side sheet",
                                barrierDismissible: true,
                                barrierColor: const Color(0xff66000000),
                                transitionDuration: const Duration(milliseconds: 300),
                                context: context,
                                pageBuilder: (context, animation1, animation2) {
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: Material(
                                      elevation: 15,
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.zero,
                                      child: StatefulBuilder(
                                        builder: (BuildContext context, StateSetter stateSetter) {
                                          return NodeList(customerId: customerId, nodes: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].nodeList,
                                            deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                            deviceName: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName,
                                            controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId, userId: userId,);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                transitionBuilder: (context, animation1, animation2, child) {
                                  return SlideTransition(
                                    position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
                                    child: child,
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.format_list_numbered),
                            color: Colors.white,
                            iconSize: 24.0,
                            hoverColor: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.transparent
                        ),
                        width: 45,
                        height: 45,
                        child: IconButton(
                          tooltip: 'Input/Output Connection details',
                          onPressed: () {
                            Navigator.push(context,
                              MaterialPageRoute(
                                builder: (context) => InputOutputConnectionDetails(masterInx: vm.mIndex, nodes: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].nodeList),
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings_input_component_outlined),
                          color: Colors.white,
                          iconSize: 24.0,
                          hoverColor: Theme.of(context).primaryColorLight,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.transparent
                        ),
                        width: 45,
                        height: 45,
                        child: IconButton(
                          tooltip: 'Program',
                          onPressed: vm.getPermissionStatusBySNo(context, 10) ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProgramSchedule(
                                  customerID: customerId,
                                  controllerID: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                  siteName: vm.mySiteList.data[vm.sIndex].groupName,
                                  imeiNumber: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                  userId: userId,
                                ),
                              ),
                            );
                          }:null,
                          icon: const Icon(Icons.list_alt),
                          color: Colors.white,
                          iconSize: 24.0,
                          hoverColor: Theme.of(context).primaryColorLight,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.transparent
                        ),
                        width: 45,
                        height: 45,
                        child: IconButton(
                          tooltip: 'Scheduled Program details',
                          onPressed: (){},
                          /*onPressed: getPermissionStatusBySNo(context, 3) ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScheduleViewScreen(deviceId: mySiteList[siteIndex].master[masterIndex].deviceId, userId: widget.userId, controllerId: mySiteList[siteIndex].master[masterIndex].controllerId, customerId: widget.customerId),
                              ),
                            );
                          }:null,*/
                          icon: const Icon(Icons.view_list_outlined),
                          color: Colors.white,
                          iconSize: 24.0,
                          hoverColor: Theme.of(context).primaryColorLight,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.transparent
                        ),
                        width: 45,
                        height: 45,
                        child: IconButton(
                          tooltip: 'Manual',
                          onPressed:  () {
                            showGeneralDialog(
                              barrierLabel: "Side sheet",
                              barrierDismissible: true,
                              barrierColor: const Color(0xff66000000),
                              transitionDuration: const Duration(milliseconds: 300),
                              context: context,
                              pageBuilder: (context, animation1, animation2) {
                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Material(
                                    elevation: 15,
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.zero,
                                    child: StatefulBuilder(
                                      builder: (BuildContext context, StateSetter stateSetter) {
                                        return StandAlone(siteId: vm.mySiteList.data[vm.sIndex].groupId,
                                          controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                          customerId: customerId,
                                          deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                          callbackFunction: callbackFunction, userId: userId, config: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].config,);
                                      },
                                    ),
                                  ),
                                );
                              },
                              transitionBuilder: (context, animation1, animation2, child) {
                                return SlideTransition(
                                  position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
                                  child: child,
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.touch_app_outlined),
                          color: Colors.white,
                          iconSize: 24.0,
                          hoverColor: Theme.of(context).primaryColorLight,
                        ),
                      ),
                    ],
                  ),
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
    ];

    return destinations;
  }

  Widget mainScreen(int index, groupId, groupName, List<Master> masterData, int controllerId) {
    switch (index) {
      case 0:
        return CustomerHome(customerId: userId);
      case 1:
        return CustomerProduct(customerId: userId);
      case 2:
        return SentAndReceived(customerId: userId, controllerId: controllerId);
      case 3:
        return ControllerSettings(customerId: userId, controllerId: controllerId, adDrId: fromLogin?1:0,);
      /*case 4:
        return SiteConfig(
            userId: userId,
            customerId: customerId,
            customerName: customerName,
            masterData: masterData,
            groupId: groupId,
            groupName: groupName
        );*/
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
