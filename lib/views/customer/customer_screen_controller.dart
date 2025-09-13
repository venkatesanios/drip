import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/Dealer/controllerlogfile.dart';
import 'package:oro_drip_irrigation/Screens/Dealer/sevicecustomer.dart';
import 'package:oro_drip_irrigation/Screens/Logs/irrigation_and_pump_log.dart';
import 'package:oro_drip_irrigation/Screens/planning/WeatherScreen.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/program_library.dart';
import 'package:oro_drip_irrigation/views/customer/sent_and_received.dart';
import 'package:oro_drip_irrigation/views/customer/site_config.dart';
import 'package:oro_drip_irrigation/views/customer/stand_alone.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/alarm_button.dart';
import 'package:popover/popover.dart';
import '../../models/customer/site_model.dart';
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
import '../../modules/UserChat/view/user_chat.dart';
import '../../providers/user_provider.dart';
import '../../repository/repository.dart';
import '../../services/communication_service.dart';
import '../../services/http_service.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../utils/my_function.dart';
import '../../utils/routes.dart';
import '../../utils/shared_preferences_helper.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../view_models/nav_rail_view_model.dart';
import '../common/user_profile/user_profile.dart';
import 'controller_settings/wide/controller_settings_wide.dart';
import 'customer_home.dart';
import 'customer_product.dart';
import 'input_output_connection_details.dart';
import 'node_list.dart';

class CustomerScreenController extends StatefulWidget {
  const CustomerScreenController({super.key, required this.userId, required this.customerName, required this.mobileNo, required this.emailId, required this.customerId, required this.fromLogin});
  final int customerId, userId;
  final String customerName, mobileNo, emailId;
  final bool fromLogin;

  @override
  State<CustomerScreenController> createState() => _CustomerScreenControllerState();
}

class _CustomerScreenControllerState extends State<CustomerScreenController> {
  late String role;

  void callbackFunction(String status)
  {
    print('program status:$status');
    if(status=='Program created'){
      CustomerScreenControllerViewModel viewModel =
      Provider.of<CustomerScreenControllerViewModel>(context, listen: false);
      viewModel.getAllMySites(context, widget.customerId, preserveSelection: true);
    }

    /*Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 500), () {
      _showSnackBar(message);
    });*/
  }

  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider mqttProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    final loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;
     role = loggedInUser.name;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavRailViewModel(Repository(HttpService()))),
        ChangeNotifierProvider(
          create: (_) => CustomerScreenControllerViewModel(context, Repository(HttpService()), mqttProvider)
            ..getAllMySites(context, widget.customerId),
        ),
      ],
      child: Consumer2<NavRailViewModel, CustomerScreenControllerViewModel>(
        builder: (context, navViewModel, vm, _) {
          if(vm.isLoading){
            return const Scaffold(body: Center(child: Text('Site loading please waite....')));
          }

          final screenWidth = MediaQuery.sizeOf(context).width;//
          final screenHeight = MediaQuery.sizeOf(context).height;

          final currentSite = vm.mySiteList.data[vm.sIndex];
          final currentMaster = currentSite.master[vm.mIndex];

          return  Scaffold(
            appBar: AppBar(
              title:  Row(
                children: [

                  if(widget.fromLogin)...[
                    Image(
                      image: F.appFlavor!.name.contains('oro')? const AssetImage("assets/png/oro_logo_white.png"):
                      const AssetImage("assets/png/company_logo.png"),
                      width: F.appFlavor!.name.contains('oro')? 70:110,
                      fit: BoxFit.fitWidth,
                    ),
                    const SizedBox(width: 20),
                    Container(width: 1, height: 20, color: Colors.white54),
                    const SizedBox(width: 5),
                  ],

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
                    dropdownColor: Theme.of(context).primaryColorLight,
                    iconEnabledColor: Colors.white,
                    iconDisabledColor: Colors.white,
                    focusColor: Colors.transparent,
                  ):
                  Text(currentSite.groupName,
                    style: const TextStyle(fontSize: 17), overflow: TextOverflow.ellipsis,),

                  const SizedBox(width: 15),
                  Container(width: 1,height: 20, color: Colors.white54,),
                  const SizedBox(width: 5),

                  currentSite.master.length>1? PopupMenuButton<int>(
                    color: Theme.of(context).primaryColorLight,
                    tooltip: 'master controller',
                    child: MaterialButton(
                      onPressed: null,
                      textColor: Colors.white,
                      child: Row(
                        children: [
                          Text(currentSite.master[vm.mIndex].deviceName),
                          const SizedBox(width: 3),
                          const Icon(Icons.arrow_drop_down, color: Colors.white),
                        ],
                      ),
                    ),
                    itemBuilder: (context) {
                      return List.generate(currentSite.master.length, (index) {
                        final master = currentSite.master[index];
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
                                    master.deviceName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Text(
                                    master.modelDescription,
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
                  Text(currentMaster.deviceName,
                    style: const TextStyle(fontSize: 17)),

                  [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId) ?
                  const SizedBox(width: 15): const SizedBox(),

                  [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId)?
                  Container(width: 1,height: 20, color: Colors.white54,): const SizedBox(),

                  [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId)?
                  const SizedBox(width: 5): const SizedBox(),

                  [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId) &&
                      currentMaster.irrigationLine.length>1?
                  DropdownButton<int>(
                    underline: Container(),
                    items: List.generate(
                      currentMaster.irrigationLine.length, (index) {
                      final line = currentMaster.irrigationLine[index];
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
                  [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId)?
                  Text(currentMaster.irrigationLine.isNotEmpty?
                    currentMaster.irrigationLine[0].name:
                    'Line empty', style: const TextStyle(fontSize: 17)):
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
                  Selector<CustomerScreenControllerViewModel, String>(
                    selector: (_, vm) => vm.mqttProvider.liveDateAndTime,
                    builder: (_, liveDateAndTime, __) => Text('Last sync @ - ${Formatters.formatDateTime(liveDateAndTime)}',
                        style: const TextStyle(fontSize: 15, color: Colors.white70)),
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

                    (vm.lineLiveMessage.isNotEmpty && currentMaster.irrigationLine.length > 1)?
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (BuildContext context) => UserChatScreen(
                                            userId: vm.mySiteList.data[vm.sIndex].customerId,
                                            userName: vm.mySiteList.data[vm.sIndex].customerName,
                                            phoneNumber: widget.mobileNo))
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.info_outline),
                                  title: const Text('Controller info'),
                                  onTap: () {
                                     Navigator.pop(context);
                                     if(role == "Admin"){
                                       Navigator.push(
                                         context,
                                         MaterialPageRoute(builder: (context) =>
                                             ResetVerssion(userId: vm.mySiteList.data[vm.sIndex].customerId,
                                               controllerId: currentMaster.controllerId,
                                               deviceID: currentMaster.deviceId,)),
                                       );
                                     }
                                     else
                                     {
                                       showPasswordDialog(context,'Oro@321',vm.mySiteList.data[vm.sIndex].customerId,
                                           currentMaster.controllerId,currentMaster.deviceId,1);
                                     }

                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.restore),
                                  title: const Text('Factory Reset'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    if(role == "Admin"){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            ResetAccumalationScreen(userId: vm.mySiteList.data[vm.sIndex].customerId,
                                              controllerId: currentMaster.controllerId,
                                              deviceID: currentMaster.deviceId,)),
                                      );
                                    }
                                    else
                                      {
                                        showPasswordDialog(context,'Oro@321',vm.mySiteList.data[vm.sIndex].customerId,
                                            currentMaster.controllerId,currentMaster.deviceId,2);
                                      }
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
                    IconButton(tooltip : 'Your Account\n${widget.customerName}\n ${widget.mobileNo}', onPressed: (){
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
                                    child: Text(widget.customerName.substring(0, 1).toUpperCase(),
                                        style: const TextStyle(fontSize: 25)),),
                                ),
                                Text('Hi, ${widget.customerName}!',style: const TextStyle(fontSize: 20)),
                                Text(widget.mobileNo, style: const TextStyle(fontSize: 13)),
                                const SizedBox(height: 8),
                                MaterialButton(
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  child: const Text('Manage Your Account'),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => FractionallySizedBox(
                                        heightFactor: 0.84,
                                        widthFactor: 0.75,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                          ),
                                          child: const UserProfile(),
                                        ),
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
                          child: Text(widget.customerName.substring(0, 1).toUpperCase()),
                        )
                    ),

                    if(currentMaster.nodeList.isNotEmpty && currentMaster.categoryId == 2
                        && [48, 49].contains(currentMaster.modelId))
                      IconButton(
                          onPressed: (){
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return NodeSettings(
                                    userId: widget.userId,
                                    controllerId: currentMaster.controllerId,
                                    customerId: vm.mySiteList.data[vm.sIndex].customerId,
                                    nodeList: currentMaster.nodeList,
                                    deviceId: currentMaster.deviceId,
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
                  if(kIsWeb)...[
                    NavigationRail(
                      selectedIndex: navViewModel.selectedIndex,
                      labelType: NavigationRailLabelType.all,
                      elevation: 5,
                      onDestinationSelected: (int index) {
                        navViewModel.onDestinationSelectingChange(index);
                      },
                      destinations: getNavigationDestinations(),
                    ),
                  ],
                  Container(
                    width: [1, 2, 3, 4, 56, 57, 58, 59].contains(currentMaster.modelId)?
                    screenWidth-140: screenWidth <= 600 ? screenWidth : screenWidth - 80,
                    height: screenHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8)),
                    ),
                    child: Column(
                      children: [
                        if ([...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId)) ...[
                          if (vm.isNotCommunicate)
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
                          child: Builder(
                            builder: (_) {
                              return mainScreen(
                                navViewModel.selectedIndex,
                                currentSite.groupId,
                                currentSite.groupName,
                                currentMaster,
                                currentSite.master,
                                vm.isChanged,
                                role,
                                vm.mySiteList.data[vm.sIndex].customerId,
                                  vm.mySiteList.data[vm.sIndex].customerName,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if([1, 2, 3, 4, 56, 57, 58, 59].contains(currentMaster.modelId))...[
                    Container(
                      width: 60,
                      height: screenHeight,
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
                            AlarmButton(
                                alarmPayload: vm.alarmDL, deviceID: currentMaster.deviceId,
                                customerId: vm.mySiteList.data[vm.sIndex].customerId,
                                controllerId: currentMaster.controllerId,
                                irrigationLine: currentMaster.irrigationLine),
                            const SizedBox(height: 15),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: SizedBox(
                                height: 45,
                                width: 45,
                                child:/* [56, 57, 58, 59].contains(currentMaster.modelId) ?
                                NovaInfoButton(deviceID: currentMaster.deviceId,
                                    customerId: customerId, controllerId: currentMaster.controllerId):*/
                                IconButton(
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
                                                return NodeList(
                                                    customerId: vm.mySiteList.data[vm.sIndex].customerId,
                                                    userId: widget.userId,
                                                    nodes: currentMaster.nodeList,
                                                    configObjects: currentMaster.configObjects,
                                                    masterData: currentMaster);
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
                            if(![56, 57, 58, 59].contains(currentMaster.modelId))...[
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
                                        builder: (context) => InputOutputConnectionDetails(
                                            masterInx: vm.mIndex, nodes: currentMaster.nodeList),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.settings_input_component_outlined),
                                  color: Colors.white,
                                  iconSize: 24.0,
                                  hoverColor: Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ],
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
                                        customerId: vm.mySiteList.data[vm.sIndex].customerId,
                                        controllerId: currentMaster.controllerId,
                                        deviceId: currentMaster.deviceId,
                                        userId: widget.userId,
                                        groupId: vm.mySiteList.data[vm.sIndex].groupId,
                                        categoryId: currentMaster.categoryId,
                                        modelId: currentMaster.modelId,
                                        deviceName: currentMaster.deviceName,
                                        categoryName: currentMaster.categoryName,
                                        callbackFunction: callbackFunction,
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
                            if([1, 2, 3, 4].contains(currentMaster.modelId))...[
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
                                          deviceId: currentMaster.deviceId,
                                          userId: widget.userId,
                                          controllerId: currentMaster.controllerId,
                                          customerId: vm.mySiteList.data[vm.sIndex].customerId,
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
                            ],

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
                                                  controllerId: currentMaster.controllerId,
                                                  customerId:vm.mySiteList.data[vm.sIndex].customerId,
                                                  deviceId: currentMaster.deviceId,
                                                  callbackFunction: callbackFunction, userId: widget.userId, masterData: currentMaster);
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
                          ]),
                    )
                  ],
                ],
              ),
            ),
          ) ;
        },
      ),
    );
  }

  void showPasswordDialog(BuildContext context, correctPassword,userId,controllerID,imeiNumber,type) {
    final TextEditingController passwordController = TextEditingController();
    print('userId:$userId,controllerID:$controllerID,imeiNumber:$imeiNumber');
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
              onPressed: () async{
                final userPsw = passwordController.text;

                   try{
                    final Repository repository = Repository(HttpService());
                    var getUserDetails = await repository.checkpassword({
                      "passkey": userPsw
                    });

                    if (getUserDetails.statusCode == 200) {
                      var jsonData = jsonDecode(getUserDetails.body);
                      print("jsonData$jsonData");
                      if (jsonData['code'] == 200) {
                        print("getUserDetails.body: ${getUserDetails.body}");
                         if (type == 1) {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                ResetVerssion(userId: userId,
                                  controllerId: controllerID,
                                  deviceID: imeiNumber,)),
                          );
                        }
                        else if (type == 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ResetAccumalationScreen(userId: userId,
                                      controllerId: controllerID,
                                      deviceID: imeiNumber),
                            ),
                          );
                        }
                      } else {
                        Navigator.of(context).pop(); // Close the dialog
                        showErrorDialog(context);
                      }
                    }
                  }
                  catch (e, stackTrace) {
                    print(' Error overAll getData => ${e.toString()}');
                    print(' trace overAll getData  => ${stackTrace}');
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

    final viewModel = Provider.of<CustomerScreenControllerViewModel>(context, listen: true);

    if (viewModel.mySiteList.data.isEmpty ||
        viewModel.sIndex < 0 || viewModel.sIndex >= viewModel.mySiteList.data.length ||
        viewModel.mIndex < 0 || viewModel.mIndex >= viewModel.mySiteList.data[viewModel.sIndex].master.length) {
      return [
        const NavigationRailDestination(
          icon: Icon(Icons.downloading),
          label: Text('...'),
        ),
      ];// or fallback widget
    }

    final cMaster = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex];

    final destinations = [
      const NavigationRailDestination(
        icon: Tooltip(message: 'Home', child: Icon(Icons.home_outlined)),
        selectedIcon: Icon(Icons.home, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Tooltip(message: 'All my devices', child: Icon(Icons.devices_other)),
        selectedIcon: Icon(Icons.devices_other, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Tooltip(message: 'Sent & Received', child: Icon(Icons.question_answer_outlined)),
        selectedIcon: Icon(Icons.question_answer, color: Colors.white),
        label: Text(''),
      ),
      if([1, 2, 3, 4].contains(cMaster.modelId))...[
        const NavigationRailDestination(
          icon: Tooltip(message: 'Controller Logs', child: Icon(Icons.receipt_outlined)),
          selectedIcon: Icon(Icons.receipt, color: Colors.white),
          label: Text(''),
        )
      ],
      const NavigationRailDestination(
        icon: Tooltip(message: 'Settings', child: Icon(Icons.settings_outlined)),
        selectedIcon: Icon(Icons.settings, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Tooltip(message: 'Configuration', child: Icon(Icons.confirmation_num_outlined)),
        selectedIcon: Icon(Icons.confirmation_num, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Tooltip(message: 'Service Request', child: Icon(Icons.support_agent_sharp)),
        selectedIcon: Icon(Icons.support_agent_sharp, color: Colors.white),
        label: Text(''),
      ),
      if([1, 2, 3, 4].contains(cMaster.modelId))...[
        const NavigationRailDestination(
          icon: Tooltip(message: 'Weather', child: Icon(Icons.sunny_snowing)),
          selectedIcon: Icon(Icons.wb_sunny_rounded, color: Colors.white),
          label: Text(''),
        )
      ],

    ];

    return destinations;
  }

  Widget mainScreen(int index, int groupId, String groupName, MasterControllerModel currentMaster,
      List<MasterControllerModel> allMaster, bool isChanged, String role, int customerId, String customerName) {

    final isGem = [1, 2, 3, 4].contains(currentMaster.modelId);

    switch (index) {
      case 0:
        return [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId) ?
        CustomerHome(
          customerId: widget.customerId,
          controllerId: currentMaster.controllerId,
          deviceId: currentMaster.deviceId,
          modelId: currentMaster.modelId,
        ) :
        isChanged ? PumpControllerHome(
          userId: widget.userId,
          customerId: widget.customerId,
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
        );

      case 1:
        return CustomerProduct(customerId: widget.customerId);

      case 2:
        return SentAndReceived(
          customerId: customerId,
          controllerId: currentMaster.controllerId,
        );

      case 3:
        return isGem ? IrrigationAndPumpLog(
          userData: {
            'userId': widget.userId,
            'controllerId': currentMaster.controllerId,
            'customerId': customerId,
          },
          masterData: currentMaster,
        ) :
        ControllerSettingWide(
          userId: widget.userId,
          customerId: customerId,
          masterController: currentMaster,
        );

      case 4:
        return isGem ? ControllerSettingWide(
          userId: widget.userId,
          customerId: customerId,
          masterController: currentMaster,
        ) :
        role == 'Admin' ? SiteConfig(
          userId: widget.userId,
          customerId: customerId,
          customerName: customerName,
          masterData: allMaster,
          groupId: groupId,
          groupName: groupName,
        ) :
        _PasswordProtectedSiteConfig(
          userId: widget.userId,
          customerId: customerId,
          customerName: customerName,
          allMaster: allMaster,
          groupId: groupId,
          groupName: groupName,
        );

      case 5:
        return isGem
            ? (role == 'Admin'
            ? SiteConfig(
          userId: widget.userId,
          customerId: customerId,
          customerName: customerName,
          masterData: allMaster,
          groupId: groupId,
          groupName: groupName,
        ) : _PasswordProtectedSiteConfig(
          userId: widget.userId,
          customerId: customerId,
          customerName: customerName,
          allMaster: allMaster,
          groupId: groupId,
          groupName: groupName,
        ))
            : TicketHomePage(
          userId: customerId,
          controllerId: currentMaster.controllerId,
        );

      case 6:
        return TicketHomePage(
          userId: widget.customerId,
          controllerId: currentMaster.controllerId,
        );

      case 7:
        return WeatherScreen(
          userId: widget.customerId,
          controllerId: currentMaster.controllerId,
          deviceID: currentMaster.deviceId,
        );

      default:
        return const Scaffold(
          body: Center(
            child: Text("Invalid screen index"),
          ),
        );
    }
  }
}


class NovaInfoButton extends StatelessWidget {
  const NovaInfoButton({super.key, required this.deviceID,
    required this.customerId, required this.controllerId});

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
      child: IconButton(
        onPressed: (){
          showPopover(
            context: context,
            bodyBuilder: (context) => Container(),
            onPop: () => print('Popover was popped!'),
            direction: PopoverDirection.left,
            width: 400,
            height: 300,
            arrowHeight: 15,
            arrowWidth: 30,
          );
        },
        icon: const Icon(Icons.display_settings),
        color: Colors.white,
        iconSize: 24.0,
        hoverColor: Theme.of(context).primaryColorLight,
      ),
    );
  }
}



class _PasswordProtectedSiteConfig extends StatefulWidget {
  final int userId;
  final int customerId;
  final String customerName;
  final List<MasterControllerModel> allMaster;
  final int groupId;
  final String groupName;

  const _PasswordProtectedSiteConfig({
    Key? key,
    required this.userId,
    required this.customerId,
    required this.customerName,
    required this.allMaster,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  State<_PasswordProtectedSiteConfig> createState() =>
      _PasswordProtectedSiteConfigState();
}

class _PasswordProtectedSiteConfigState
    extends State<_PasswordProtectedSiteConfig> {
  bool _authorized = false;

  @override
  void initState() {
    super.initState();
    // show password dialog after first build
    WidgetsBinding.instance.addPostFrameCallback((_) => _askPassword());
  }

  Future<void> _askPassword() async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enter Password'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final userPsw = controller.text;

                try {
                  final Repository repository = Repository(HttpService());
                  var getUserDetails = await repository.checkpassword({
                    "passkey": userPsw,
                  });

                  if (getUserDetails.statusCode == 200) {
                    var jsonData = jsonDecode(getUserDetails.body);
                    print("jsonData $jsonData");

                    if (jsonData['code'] == 200) {
                      print("getUserDetails.body: ${getUserDetails.body}");
                      if (ctx.mounted) Navigator.pop(ctx, true); // ✅ close dialog safely
                    } else {
                      if (ctx.mounted) Navigator.pop(ctx, false); // wrong password
                    }
                  }
                } catch (e, stackTrace) {
                  print('Error getData => ${e.toString()}');
                  print('Trace getData => $stackTrace');
                  if (ctx.mounted) Navigator.pop(ctx, false);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() => _authorized = true);
    } else {
      // Wrong password → show error
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Incorrect Password!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authorized) {
      return SiteConfig(
        userId: widget.userId,
        customerId: widget.customerId,
        customerName: widget.customerName,
        masterData: widget.allMaster,
        groupId: widget.groupId,
        groupName: widget.groupName,
      );
    }
    return const SizedBox.shrink(); // empty until password is validated
  }
}

