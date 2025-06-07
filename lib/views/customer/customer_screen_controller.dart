import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/Dealer/sevicecustomer.dart';
import 'package:oro_drip_irrigation/Screens/Logs/irrigation_and_pump_log.dart';
import 'package:oro_drip_irrigation/Screens/planning/WeatherScreen.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/program_library.dart';
import 'package:oro_drip_irrigation/views/customer/sent_and_received.dart';
import 'package:oro_drip_irrigation/views/customer/site_config.dart';
import 'package:oro_drip_irrigation/views/customer/stand_alone.dart';
import 'package:popover/popover.dart';
import '../../Models/customer/site_model.dart';
import 'package:provider/provider.dart';
import '../../Screens/Dealer/controllerverssionupdate.dart';
import '../../Screens/Map/CustomerMap.dart';
import '../../Screens/Map/allAreaBoundry.dart';
import '../../Screens/planning/FactoryReset.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../flavors.dart';
import '../../modules/PumpController/view/node_settings.dart';
import '../../modules/ScheduleView/view/schedule_view_screen.dart';
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
    MqttPayloadProvider mqttProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavRailViewModel()),
        ChangeNotifierProvider(
          create: (_) => CustomerScreenControllerViewModel(context, Repository(HttpService()), mqttProvider)
            ..getAllMySites(context, customerId),
        ),
      ],
      child: Consumer2<NavRailViewModel, CustomerScreenControllerViewModel>(
        builder: (context, navViewModel, vm, _) {
          if(vm.isLoading){
            return const Scaffold(body: Center(child: Text('Site loading please waite....')));
          }
          return  Scaffold(
            appBar: AppBar(
              title:  Row(
                children: [
                  fromLogin ?const SizedBox():
                  const SizedBox(width: 10),
                  fromLogin ? Image(
                    image: F.appFlavor!.name.contains('oro')? const AssetImage("assets/png/oro_logo_white.png"):
                    const AssetImage("assets/png/company_logo.png"),
                    width: F.appFlavor!.name.contains('oro')? 70:110,
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

                  vm.mySiteList.data[vm.sIndex].master.length>1? PopupMenuButton<int>(
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
                          child: Row(
                            children: [
                              const Icon(Icons.home_max_sharp, size: 20, color: Colors.white),
                              const SizedBox(width: 8),
                              Column(
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
                            ],
                          ),
                        );
                      });
                    },
                    onSelected: (index) {
                      vm.masterOnChanged(index); // ✅ Pass only the index
                    },
                  ):
                  Text(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName,
                    style: const TextStyle(fontSize: 17),),

                  vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1?
                  const SizedBox(width: 15,): const SizedBox(),

                  vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1?
                  Container(width: 1,height: 20, color: Colors.white54,): const SizedBox(),

                  vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1?
                  const SizedBox(width: 5,): const SizedBox(),

                  vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1 &&
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].irrigationLine.length>1?
                  DropdownButton<int>(
                    underline: Container(),
                    items: List.generate(
                      vm.mySiteList.data[vm.sIndex].master[vm.mIndex].irrigationLine.length, (index) {
                      final line = vm.mySiteList.data[vm.sIndex].master[vm.mIndex].irrigationLine[index];
                      return DropdownMenuItem<int>(
                        value: index,
                        child: Text(
                          line.name,
                          style: const TextStyle(color: Colors.white, fontSize: 17),
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
                  ) :
                  vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 1?
                  Text(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].irrigationLine.isNotEmpty?
                  vm.mySiteList.data[vm.sIndex].master[vm.mIndex].irrigationLine[0].name:
                  'Line empty', style: const TextStyle(fontSize: 17),):
                  const SizedBox(),

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
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor],
                  ),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

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

                    const SizedBox(width: 10,),

                    (vm.lineLiveMessage.isNotEmpty &&
                        vm.mySiteList.data[vm.sIndex].master[vm.mIndex].irrigationLine.length > 1)?
                    Builder(
                      builder: (context) {
                        bool allPaused = vm.lineLiveMessage.every((line) {
                          final parts = line.split(',');
                          return parts.length > 1 && parts[1] == '1';
                        });

                        return TextButton(
                          onPressed: () => vm.linePauseOrResume(vm.lineLiveMessage),
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(
                              allPaused ? Colors.green : Colors.amber,
                            ),
                            shape: WidgetStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                allPaused ? Icons.play_arrow_outlined : Icons.pause,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                allPaused ? 'RESUME ALL LINE' : 'PAUSE ALL LINE',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        );
                      },
                    ):
                    const SizedBox(),

                    const SizedBox(width: 10),
                    const IconButton(color: Colors.transparent, onPressed: null, icon: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.black12,
                      child: Icon(Icons.mic, color: Colors.black26,),
                    )),
                    IconButton(tooltip : 'Help & Support', onPressed: (){
                      showMenu(
                        context: context,
                        color: Colors.white,
                        position: const RelativeRect.fromLTRB(100, 0, 50, 0),
                        items: <PopupMenuEntry>[
                          PopupMenuItem(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.info_outline),
                                  title: const Text('App info'),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.help_outline),
                                  title: const Text('Help'),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.info_outline),
                                  title: const Text('Controller info'),
                                  onTap: () {
                                    // showPasswordDialog(context, _correctPassword, userId, vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId, vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId);
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResetVerssion(userId: userId, controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId, deviceID: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.restore),
                                  title: const Text('Factory Reset'),
                                  onTap: () {
                                    // showPasswordDialog(context, _correctPassword, userId, vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId, vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId);
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResetAccumalationScreen(userId: userId, controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId, deviceID: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,),
                                      ),
                                    );
                                  },
                                ),
                                const Divider(height: 0),
                                ListTile(
                                  leading: const Icon(Icons.feedback_outlined),
                                  title: const Text('Send feedback'),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }, icon: const CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.live_help_outlined),
                    )),
                    IconButton(tooltip : 'Your Account\n$customerName\n $mobileNo', onPressed: (){
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
                                  child: const Text('Manage Your Account'),
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

                    if(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].nodeList.isNotEmpty && vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId == 2 && [48, 49].contains(vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId))
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
                  ],),
                const SizedBox(width: 05),
              ],
            ),
            extendBody: true,
            body: Container(
              color: Theme.of(context).primaryColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(kIsWeb)
                    NavigationRail(
                      selectedIndex: navViewModel.selectedIndex,
                      labelType: NavigationRailLabelType.all,
                      elevation: 5,
                      onDestinationSelected: (int index) {
                        navViewModel.onDestinationSelectingChange(index);
                      },
                      destinations: getNavigationDestinations(),
                    ),
                  Container(
                    width: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId==1?
                    MediaQuery.sizeOf(context).width-140: MediaQuery.sizeOf(context).width <= 600 ? MediaQuery.sizeOf(context).width : MediaQuery.sizeOf(context).width - 80,
                    height: MediaQuery.sizeOf(context).height,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
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
                              height: 23.0,
                              decoration: BoxDecoration(
                                color: Colors.red.shade300,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'NO POWER SUPPLY TO CONTROLLER',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(),
                        ],

                        Expanded(
                          child: mainScreen(
                              navViewModel.selectedIndex,
                              vm.mySiteList.data[vm.sIndex].groupId,
                              vm.mySiteList.data[vm.sIndex].groupName,
                              vm.mySiteList.data[vm.sIndex].master,
                              vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                              vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId,
                              vm.mIndex,
                              vm.sIndex,
                              vm.isChanged,
                            vm
                          ),
                        ),
                      ],
                    ),
                  ),
                  vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId==1?
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
                          AlarmButton(alarmPayload: vm.alarmDL, deviceID: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                            customerId: customerId, controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                            irrigationLine: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].irrigationLine),
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
                                                controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId, userId: userId,
                                                configObjects: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].configObjects);
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
                                    builder: (context) => ProgramLibraryScreenNew(
                                      customerId: customerId,
                                      controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                      deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                      userId: userId,
                                      groupId: vm.mySiteList.data[vm.sIndex].groupId,
                                      categoryId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryId,
                                      modelId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].modelId,
                                      deviceName: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceName,
                                      categoryName: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].categoryName,
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
                              // onPressed: (){},
                              onPressed:  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScheduleViewScreen(
                                      deviceId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,
                                      userId: userId,
                                      controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                                      customerId: customerId,
                                      groupId: vm.mySiteList.data[vm.sIndex].groupId,
                                    ),
                                  ),
                                );
                              },
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
                                                callbackFunction: callbackFunction, userId: userId, masterData: vm.mySiteList.data[vm.sIndex].master[vm.mIndex]);
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

                           const SizedBox(height: 15),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.transparent
                            ),
                            width: 45,
                            height: 45,
                            child: IconButton(
                              tooltip: 'Geography',
                               onPressed: () {
                                Navigator.push(context,
                                  MaterialPageRoute(
                                    builder: (context) => MapScreenall(userId: userId, customerId: customerId,controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId, imeiNo: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.map_outlined),
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
                              onPressed: () {
                                Navigator.push(context,
                                  MaterialPageRoute(
                                    builder: (context) => MapScreenAllArea(userId: userId, customerId: customerId,controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId, imeiNo: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].deviceId,),
                                  ),
                                );
                              },

                              tooltip: 'Area',
                              icon: const Icon(Icons.map),
                              color: Colors.white,
                              iconSize: 24.0,
                              hoverColor: Theme.of(context).primaryColorLight,
                            ),
                          ),
                         ]),
                  ):
                  const SizedBox()
                ],
              ),
            ),
          ) ;
        },
      ),
    );
  }

  void showPasswordDialog(BuildContext context, correctPassword,userId,controllerID,imeiNumber) {
    final TextEditingController passwordController = TextEditingController();


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final enteredPassword = passwordController.text;

                if (enteredPassword == correctPassword) {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  ResetVerssion(userId: userId, controllerId: controllerID, deviceID: imeiNumber,)),
                  );
                } else {
                  Navigator.of(context).pop(); // Close the dialog
                  showErrorDialog(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Incorrect password. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  List<NavigationRailDestination> getNavigationDestinations() {
    final destinations = [
      const NavigationRailDestination(
        padding: EdgeInsets.only(top: 6),
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
          message: 'Service Request',
          child: Icon(Icons.support_agent_sharp),
        ),
        selectedIcon: Icon(Icons.support_agent_sharp, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Tooltip(
          message: 'Weather',
          child: Icon(Icons.sunny_snowing),
        ),
        selectedIcon: Icon(Icons.wb_sunny_rounded, color: Colors.white),
        label: Text(''),
      ),



    ];

    return destinations;
  }

  Widget mainScreen(int index, groupId, groupName, List<MasterControllerModel> masterData, int controllerId, int categoryId, int masterIndex, int siteIndex, bool isChanged, CustomerScreenControllerViewModel vm) {
    switch (index) {
      case 0:
        return categoryId==1 ?
        CustomerHome(customerId: userId, controllerId: controllerId, deviceId: masterData[masterIndex].deviceId):
        isChanged ? PumpControllerHome(
      /*    deviceId: masterData[masterIndex].deviceId,
          liveData: masterData[masterIndex].live!.cM as PumpControllerData,
          masterName: masterData[masterIndex].deviceName,*/
          userId: userId,
          customerId: customerId,
          masterData: masterData[masterIndex],
      /*    controllerId: controllerId,
          siteIndex: siteIndex,
          masterIndex: masterIndex,
          vm: vm,*/
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
        return IrrigationAndPumpLog(userData: {'userId' : userId, 'controllerId' : controllerId}, masterData: masterData[masterIndex],);
      case 4:
        return ControllerSettings(
            userId: userId,
            customerId: userId,
          masterController: masterData[masterIndex],
        );
      case 5:
        return SiteConfig(
            userId: userId,
            customerId: customerId,
            customerName: customerName,
            masterData: masterData,
            groupId: groupId,
            groupName: groupName
        );
      case 6:
        return TicketHomePage(userId: userId, controllerId: controllerId);
      case 7:
        return WeatherScreen(userId: userId, controllerId: controllerId, deviceID: masterData[masterIndex].deviceId,);
      case 8:
        return MapScreenall(userId: userId, customerId: customerId, controllerId: controllerId, imeiNo: masterData[masterIndex].deviceId);
      case 9:
        return MapScreenAllArea(userId: userId, customerId: customerId, controllerId: controllerId, imeiNo: masterData[masterIndex].deviceId);
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

class AlarmButton extends StatelessWidget {
  const AlarmButton({super.key, required this.alarmPayload, required this.deviceID, required this.customerId, required this.controllerId, required this.irrigationLine});
  final List<String> alarmPayload;
  final String deviceID;
  final int customerId, controllerId;
  final List<IrrigationLineModel> irrigationLine;

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
            bodyBuilder: (context) => AlarmListItems(alarm : alarmPayload, deviceID:deviceID, customerId: customerId, controllerId: controllerId, irrigationLine: irrigationLine),
            onPop: () => print('Popover was popped!'),
            direction: PopoverDirection.left,
            width: alarmPayload[0].isNotEmpty?600:150,
            height: alarmPayload[0].isNotEmpty?(alarmPayload.length*45)+20:50,
            arrowHeight: 15,
            arrowWidth: 30,
          );
        },
        icon: Icons.alarm,
        badgeNumber: (alarmPayload.isNotEmpty && alarmPayload[0].isNotEmpty) ?
        alarmPayload.length : 0,
      ),
    );
  }
}

class AlarmListItems extends StatelessWidget {
  const AlarmListItems({super.key, required this.alarm, required this.deviceID, required this.customerId, required this.controllerId, required this.irrigationLine});
  final List<String> alarm;
  final List<IrrigationLineModel> irrigationLine;

  final String deviceID;
  final int customerId, controllerId;

  @override
  Widget build(BuildContext context) {
    return alarm[0].isNotEmpty? DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 600,
      dataRowHeight: 45.0,
      headingRowHeight: 35.0,
      headingRowColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor.withOpacity(0.1)),
      columns: const [
        DataColumn2(
          label: Text('', style: TextStyle(fontSize: 13)),
          fixedWidth: 25,
        ),
        DataColumn2(
            label: Text('Message', style: TextStyle(fontSize: 13),),
            size: ColumnSize.L
        ),
        DataColumn2(
            label: Text('Location', style: TextStyle(fontSize: 13),),
            size: ColumnSize.M
        ),
        DataColumn2(
            label: Text('Time', style: TextStyle(fontSize: 13)),
            size: ColumnSize.S
        ),
        DataColumn2(
          label: Center(child: Text('', style: TextStyle(fontSize: 13),)),
          fixedWidth: 80,
        ),
      ],
      rows: List<DataRow>.generate(alarm.length, (index) {
        List<String> values = alarm[index].split(',');
        return DataRow(cells: [
          DataCell(Icon(Icons.warning_amber, color: values[7]=='1' ? Colors.orangeAccent : Colors.redAccent,)),
          DataCell(Text(MyFunction().getAlarmMessage(int.parse(values[2])))),
          DataCell(Text(irrigationLine.firstWhere(
                (line) => line.sNo.toString() == values[1],
          ).name)),
          DataCell(Text(Formatters().formatRelativeTime('${values[5]} ${values[6]}'))),
          DataCell(Center(child: MaterialButton(
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
          ))),
        ]);
      }),
    ):
    const Center(child: Text('Alarm not found'));
  }

}
