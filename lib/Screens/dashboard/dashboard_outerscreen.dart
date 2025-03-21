import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_drip_irrigation/modules/ScheduleView/view/schedule_view_screen.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/customer/hiddenmenu_model.dart';
import '../../modules/IrrigationProgram/state_management/irrigation_program_provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../StateManagement/overall_use.dart';
import '../../modules/Preferences/state_management/preference_provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../modules/IrrigationProgram/view/preview_screen.dart';
import '../../modules/IrrigationProgram/view/program_library.dart';
import '../../modules/IrrigationProgram/view/schedule_screen.dart';
import '../../modules/Preferences/view/preference_main_screen.dart';
import '../../modules/Preferences/view/view_settings.dart';
import '../planning/fiterbackwash.dart';
import '../planning/frost_productionScreen.dart';
import '../planning/planningwatersource.dart';
import '../planning/virtual_screen.dart';
import 'customerdashboard.dart';

//This is Main dashboard --
class HomeScreen extends StatefulWidget {
  final int userId;
  final bool fromDealer;
  const HomeScreen({super.key, required this.userId, required this.fromDealer});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late IrrigationProgramMainProvider irrigationProgramProvider;
  late OverAllUse overAllPvd;
  late MqttPayloadProvider payloadProvider;
  // int selectIndex = 0;
  bool isBottomSheet = false;
  bool isBottomNavigation = false;
  int userId = 53;
  int fetchcount = 0;
  int controllerId = 584;
  String imeiNo = 'B48C9D810C51';
  String uName = '';
  String uMobileNo = '';
  String uEmail = '';
  String appBarTitle = "Home page";
  HiddenMenu _hiddenMenu = HiddenMenu();
  dynamic listOfSite = [];
  int selectedSite = 0;
  int selectedMaster = 0;
  bool httperroronhs = false;
  // MqttManager manager = MqttManager();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isMenuOpen = false;
  var liveData;
  // TODO: bottom menu bar button in page calling
  static const List<Widget> _widgetOptions = <Widget>[
    MobDashboard(),
    ProgramLibraryScreenNew(
      userId: 0,
      controllerId: 0,
      deviceId: 'B48C9D810C51',
      fromDealer: false, customerId: 0,
      groupId: 0,
      categoryId: 0,
    ),
     ScheduleViewScreen(deviceId: '0', userId: 0, controllerId: 0, customerId: 0, groupId: 0),
    // IrrigationAndPumpLog(
    //   userId: 0,
    //   controllerId: 0,
    // ),
  ];
  static List<Widget> _widgetOptionspump = <Widget>[
    const MobDashboard(),
    const PreferenceMainScreen(
      controllerId: 0,
      userId: 0,
      deviceId: "",
      customerId: 0,
      menuId: 78,
    ),
    const ViewSettings(userId: 0, controllerId: 0),
    // PumpLogs(),
  ];
  DateTime? _lastPressedAt;

  @override
  void initState() {
    // TODO: implement initState
    irrigationProgramProvider =
        Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    //payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    // fetchData();
    if (payloadProvider.selectedSiteString == '' || widget.fromDealer) {
      if (mounted) {
        getData();
        Future.delayed(const Duration(seconds: 2), () {
          irrigationProgramProvider.updateBottomNavigation(0);
        });
        // if (!(widget.fromDealer)) {
        //   checkForUpdate(context);
        // }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller = AnimationController(
            duration: const Duration(milliseconds: 500),
            vsync: this,
          );
          _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ));
          // getData();
        });
      }
    }
    super.initState();
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    if (!_isMenuOpen) {
      _controller.forward();
      setState(() => _isMenuOpen = true);
    }
  }

  void _closeMenu() {
    if (_isMenuOpen) {
      _controller.reverse().then((_) {
        setState(() => _isMenuOpen = false);
      });
    }
  }

  Future<void> getData() async {
    try {
      // await mqttConfigureAndConnect();
      // await initializeSharedPreference();
      await getDashBoardData();
      await fetchData();
    } catch (e) {
      print('error: ${e.toString()}');
    }
  }

  // Future<void> mqttConfigureAndConnect() async {
  //   MqttPayloadProvider payloadProvider =
  //   Provider.of<MqttPayloadProvider>(context, listen: false);
  //   // manager.initializeMQTTClient(payloadProvider);
  //   // manager.connect();
  // }

  Future<void> initializeSharedPreference() async {
    // print("getUserData function");
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration.zero, () {
      setState(() {
        // final userIdFromPref = prefs.getString('userId') ?? '';
        uName = prefs.getString('userName') ?? '';
        uMobileNo = prefs.getString('mobileNumber') ?? '';
        uEmail = prefs.getString('email') ?? '';
      });
    });
    // print("uName:$uName,uMobileNo:$uMobileNo,uEmail:$uEmail,");
  }

  Future<void> fetchData() async {
    try {
      // print("fetch data function");
      overAllPvd.menuIdList.clear();

      final Repository repository = Repository(HttpService());
      var response = await repository.getPlanningHiddenMenu({
        "userId":  widget.userId,
        "controllerId": 1
      });

      // Map<String, Object> body = {"userId": 15, "controllerId": 1};
      print('getPlanningHiddenMenu');
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          var jsonData = jsonDecode(response.body);
          _hiddenMenu = HiddenMenu.fromJson(jsonData);
          overAllPvd.menuIdList = _hiddenMenu.data!.map((e) => e.dealerDefinitionId!).toList();
        });
      } else {
        // _showSnackBar(response.body);
      }
    } catch (e) {
      httperroronhs = true;
      print(e.toString());
    }
  }

  dynamic getPublishMessage() {
    dynamic refersh = '';
    if (![3, 4].contains(!overAllPvd.takeSharedUserId
        ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master']
    [payloadProvider.selectedMaster]['categoryId']
        : payloadProvider.listOfSharedUser['devices']
    [payloadProvider.selectedMaster]['categoryId'])) {
      refersh = jsonEncode({
        "3000": [
          {"3001": ""}
        ]
      });
    } else {
      refersh = jsonEncode({"sentSms": "#live"});
      if (mounted) {
        setState(() {
          payloadProvider.dataFetchingStatus = 2;
        });
        Future.delayed(const Duration(seconds: 10), () {
          if (payloadProvider.dataFetchingStatus != 1) {
            setState(() {
              payloadProvider.dataFetchingStatus = 3;
            });
          }
        });
      }
    }
    return refersh;
  }

  void autoReferesh() async {
    // manager.subscribeToTopic('FirmwareToApp/${overAllPvd.imeiNo}');
    // manager.publish(
    //     payloadProvider.publishMessage, 'AppToFirmware/${overAllPvd.imeiNo}');
    if (mounted) {
      setState(() {
        payloadProvider.tryingToGetPayload += 1;
      });
    }
  }

  Future<void> getDashBoardData()
  async {
   print("getData");
  // print('//////////////////////////////////////////get function called//////////////////////////');
  if (payloadProvider.timerForIrrigationPump != null) {
  setState(() {
  payloadProvider.timerForIrrigationPump!.cancel();
  payloadProvider.timerForSourcePump!.cancel();
  payloadProvider.timerForCentralFiltration!.cancel();
  payloadProvider.timerForLocalFiltration!.cancel();
  payloadProvider.timerForCentralFertigation!.cancel();
  payloadProvider.timerForLocalFertigation!.cancel();
  payloadProvider.timerForCurrentSchedule!.cancel();
  });
  }
  // payloadProvider.clearData();

  print("userId:$userId");

  // final usernameFromPref = prefs.getString('user_role');
// print("userIdFromPref:$userIdFromPref usernameFromPref:usernameFromPref");
  // payloadProvider.editLoading(true);
  try {
  final Repository repository = Repository(HttpService());
  var getUserDetails = await repository.fetchAllMySite({
  "userId": userId ?? 4,
  });

  final jsonData = jsonDecode(getUserDetails.body);
  print("jason data---: $jsonData");
  if (jsonData['code'] == 200) {
  await payloadProvider.updateDashboardPayload(jsonData);
  setState(() {
  liveData = payloadProvider.dashboardLiveInstance!.data;
  overAllPvd.editControllerType((!overAllPvd.takeSharedUserId
  ? liveData[payloadProvider.selectedSite]
      .master[payloadProvider.selectedMaster]
      .categoryId
      : payloadProvider.listOfSharedUser['devices']
  [payloadProvider.selectedMaster]['categoryId']));
  overAllPvd.edituserGroupId(payloadProvider.dashboardLiveInstance!
      .data[payloadProvider.selectedSite].groupId);
  overAllPvd.editDeviceId(payloadProvider
      .dashboardLiveInstance!
      .data[payloadProvider.selectedSite]
      .master[payloadProvider.selectedMaster]
      .deviceId);
  });
  }
  payloadProvider.httpError = false;
  } catch (e, stackTrace) {
  payloadProvider.httpError = true;
  print(' Error overAll getData => ${e.toString()}');
  print(' trace overAll getData  => ${stackTrace}');
  }
}

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    irrigationProgramProvider =
        Provider.of<IrrigationProgramMainProvider>(context);
    overAllPvd = Provider.of<OverAllUse>(context, listen: true);
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);

    return buildMainScreen(context);
  }

  Widget buildMainScreen(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isBottomSheet
        //     ? Scaffold(
        //   body: Container(
        //     height: MediaQuery.of(context).size.height - 180,
        //       child: _buildSelectedScreen()
        //   ),
        //   floatingActionButton: _buildNavigationButtons(),
        // )
            ? _buildSelectedScreen()
            : buildControllerContent(),
      ),
      bottomNavigationBar: [1, 2, 3, 4].contains(overAllPvd.controllerType)
          ? Stack(
        alignment: Alignment.center,
        children: [
          buildBottomNavigationBar(),
          if ([1, 2].contains(overAllPvd.controllerType))
            Positioned(
              child: InkWell(
                onTap: _showMenuSheet,
                child: Card(
                  color: Theme.of(context).primaryColorDark,
                  shape: const CircleBorder(),
                  elevation: 20,
                  child: Container(
                      padding: const EdgeInsets.all(8),

                      child:  const Icon(
                        Icons.keyboard_arrow_up,
                        size: 35,
                        color: Colors.white,
                      )),
                ),
              ),
              // child: FloatingActionButton(
              //   onPressed: _showMenuSheet2,
              //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              //   backgroundColor: Theme.of(context).primaryColor,
              //   child: Icon(Icons.keyboard_arrow_up),
              // ),
            ),
        ],
      )
          : Container(),
    );
  }

  void _showMenuSheet() {
    if (_hiddenMenu.data!.isEmpty) return;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 300),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Consumer<OverAllUse>(
          builder: (context, overAllPvd, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RefreshIndicator(
                onRefresh: fetchData,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 310,
                      child: GridView.builder(
                        itemCount: _hiddenMenu.data!.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 15,
                        ),
                        itemBuilder: (context, index) {
                          final item = _hiddenMenu.data![index];
                          return buildMenuItems(
                            context: context,
                            label: item.parameter,
                            id: item.dealerDefinitionId,
                            onTap: () {
                              try {
                                setState(() {
                                  isBottomSheet = true;
                                  appBarTitle = item.parameter!;
                                  overAllPvd.selectedMenu =
                                  item.dealerDefinitionId!;
                                  irrigationProgramProvider
                                      .updateBottomNavigation(-1);
                                });
                                Navigator.pop(context);
                              } catch (error, stackTrace) {
                                print("error in  the bottom sheet $error");
                                print(
                                    "stackTrace in  the bottom sheet $stackTrace");
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    FloatingActionButton(
                      onPressed: () {
                        // setState(() {
                        //   isBottomSheet = false;
                        // });
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      backgroundColor: Theme.of(context).primaryColor,
                      child: AnimatedIcon(
                        icon: AnimatedIcons.close_menu,
                        color: Colors.white,
                        progress: _controller,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMenuSheet2() async {
    await fetchData();
    if (_hiddenMenu.data!.isEmpty) return;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 300),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Consumer<OverAllUse>(
          builder: (context, overAllPvd, _) {
            return ListView.builder(
              itemCount: _hiddenMenu.data!.length,
              itemBuilder: (context, index) {
                final item = _hiddenMenu.data![index];
                final bool controllerReadStatus =
                    _hiddenMenu.data![index].controllerReadStatus;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      subtitle: Text(
                        item.parameter!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      title: Text(
                        "STEP ${index + 1}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      leading: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controllerReadStatus
                              ? Colors.green
                              : Colors.orange.shade200,
                        ),
                        child: Icon(
                          controllerReadStatus ? Icons.done : Icons.cancel,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        try {
                          setState(() {
                            isBottomSheet = true;
                            appBarTitle = item.parameter!;
                            overAllPvd.selectedMenu = item.dealerDefinitionId!;
                            irrigationProgramProvider
                                .updateBottomNavigation(-1);
                          });
                          Navigator.pop(context);
                        } catch (error, stackTrace) {
                          print("Error in the bottom sheet: $error");
                          print("Stack trace: $stackTrace");
                        }
                      },
                      tileColor: !isBottomSheet
                          ? Colors.transparent
                          : overAllPvd.selectedMenu == item.dealerDefinitionId!
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : Colors.transparent,
                      trailing: IntrinsicWidth(
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: controllerReadStatus
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            controllerReadStatus
                                ? 'Acknowledged'
                                : 'Not acknowledged',
                            style: TextStyle(
                                color: controllerReadStatus
                                    ? Colors.green
                                    : Colors.orange),
                          ),
                        ),
                      ),
                    ),
                    if (index != _hiddenMenu.data!.length - 1)
                      Container(
                        margin: const EdgeInsets.only(left: 35),
                        height: 15,
                        width: 3,
                        decoration: BoxDecoration(
                          color: controllerReadStatus
                              ? Colors.green
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildMenuItems({
    required BuildContext context,
    IconData? icon,
    String? label,
    int? id,
    List<Color>? color,
    Color? borderColor,
    void Function()? onTap,
  }) {
    return InkWell(
      onTap: () {
        try {
          onTap!();
        } catch (error, stackTrace) {
          print("error in  the bottom sheet $error");
          print("stackTrace in  the bottom sheet $stackTrace");
        }
      },
      child: Column(
        children: [
          Container(
            height: 40,
            width: 40,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: color ?? [const Color(0xffd2e5ee), const Color(0xffcde6fc)],
              ),
              boxShadow: customBoxShadow,
              border: Border.all(color: borderColor ?? Colors.grey, width: 0.3),
            ),
            child: Center(child: getIconsMenu(id!)),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 80,
            height: 30,
            child: Center(
              child: Text(
                label ?? "Coming soon",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorScreen() {
    return Material(
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Network is unreachable!!'),
              MaterialButton(
                onPressed: getData,
                color: Colors.blueGrey,
                child: const Text('RETRY', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: [1, 2].contains(overAllPvd.controllerType)
          ? !isBottomSheet
          ? irrigationProgramProvider.selectedIndex > 1
          ? irrigationProgramProvider.selectedIndex + 1
          : irrigationProgramProvider.selectedIndex
          : 2
          : irrigationProgramProvider.selectedIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      elevation: 10,
      backgroundColor: cardColor,
      // showUnselectedLabels: false, // Hide labels for unselected items
      onTap: (index) {
        if ([1, 2].contains(overAllPvd.controllerType)) {
          if (index == 2) return;
        }
        final actualIndex = index > 2 ? index - 1 : index;
        isBottomSheet = false;
        if ([3, 4].contains(overAllPvd.controllerType) && !isBottomSheet) {
          Provider.of<PreferenceProvider>(context, listen: false)
              .getUserPreference(
              userId: overAllPvd.userId,
              controllerId: overAllPvd.controllerId);
        }
        irrigationProgramProvider.updateBottomNavigation(
            [1, 2].contains(overAllPvd.controllerType) ? actualIndex : index);
      },
      items: [
        const BottomNavigationBarItem(
            activeIcon: Icon(Icons.dashboard),
            label: "Dashboard",
            icon: Icon(Icons.dashboard_outlined)),
        BottomNavigationBarItem(
            activeIcon: Icon([1, 2].contains(overAllPvd.controllerType)
                ? Icons.schedule
                : Icons.settings),
            label: [1, 2].contains(overAllPvd.controllerType)
                ? "Program"
                : "Settings",
            icon: Icon([1, 2].contains(overAllPvd.controllerType)
                ? Icons.schedule_outlined
                : Icons.settings_outlined)),
        if ([1, 2].contains(overAllPvd.controllerType))
          const BottomNavigationBarItem(
              icon: SizedBox.shrink(), label: ''), // Placeholder
        BottomNavigationBarItem(
          icon: Icon([1, 2].contains(overAllPvd.controllerType)
              ? Icons.calendar_month_outlined
              : Icons.schedule_outlined),
          activeIcon: Icon([1, 2].contains(overAllPvd.controllerType)
              ? Icons.calendar_month
              : Icons.schedule),
          label:
          [1, 2].contains(overAllPvd.controllerType) ? "Schedule" : "View",
        ),
        BottomNavigationBarItem(
            icon: const Icon(Icons.assessment_outlined),
            activeIcon: const Icon(Icons.assessment),
            label: [1, 2].contains(overAllPvd.controllerType) ? "Log" : "Logs"),
      ],
    );
  }

  Widget buildControllerContent() {
      return _widgetOptions[0];
   }

  String getAppBarTitle(int index, int controllerType) {
    if ([1, 2].contains(controllerType)) {
      switch (index) {
        case 0:
          return "Dashboard";
        case 1:
          return "Program";
        case 2:
          return "Schedule";
        case 3:
          return "Log";
      }
    } else {
      switch (index) {
        case 0:
          return "Dashboard";
        case 1:
          return "Settings";
        case 2:
          return "View";
        case 3:
          return "Logs";
      }
    }
    return "";
  }

  Widget _buildSelectedScreen() {
    overAllPvd = Provider.of<OverAllUse>(context, listen: true);

    final screens = {
      66: () => watersourceUI(
        userId: overAllPvd.takeSharedUserId
            ? overAllPvd.sharedUserId
            : overAllPvd.userId,
        controllerId: overAllPvd.controllerId,
        deviceID: overAllPvd.imeiNo,
        menuId: 66,
      ),
      67: () => VirtualMeterScreen(
        userId: overAllPvd.takeSharedUserId
            ? overAllPvd.sharedUserId
            : overAllPvd.userId,
        controllerId: overAllPvd.controllerId,
        deviceId: overAllPvd.imeiNo,
        menuId: 67,
      ),
      // 68: () => RadiationSetUI(
      //   userId: overAllPvd.takeSharedUserId
      //       ? overAllPvd.sharedUserId
      //       : overAllPvd.userId,
      //   controllerId: overAllPvd.controllerId,
      //   deviceId: overAllPvd.imeiNo,
      //   menuId: 68,
      // ),
      69: () => VirtualMeterScreen(
        userId: overAllPvd.takeSharedUserId
            ? overAllPvd.sharedUserId
            : overAllPvd.userId,
        controllerId: overAllPvd.controllerId,
        deviceId: overAllPvd.imeiNo,
        menuId: 69,
      ),
      // 70: () => ConditionScreen(
      //   userId: overAllPvd.takeSharedUserId
      //       ? overAllPvd.sharedUserId
      //       : overAllPvd.userId,
      //   controllerId: overAllPvd.controllerId,
      //   deviceID: overAllPvd.imeiNo,
      //   isProgram: false,
      //   menuId: 70,
      // ),
      71: () => FrostMobUI(
        userId: overAllPvd.takeSharedUserId
            ? overAllPvd.sharedUserId
            : overAllPvd.userId,
        controllerId: overAllPvd.controllerId,
        deviceID: overAllPvd.imeiNo,
        menuId: 71,
      ),
      72: () => FilterBackwashUI(
        userId: overAllPvd.takeSharedUserId
            ? overAllPvd.sharedUserId
            : overAllPvd.userId,
        controllerId: overAllPvd.controllerId,
        deviceId: overAllPvd.imeiNo, customerId: overAllPvd.customerId, fromDealer: false,

      ),
      // 73: () => FertilizerSetScreen(
      //   userId: overAllPvd.takeSharedUserId
      //       ? overAllPvd.sharedUserId
      //       : overAllPvd.userId,
      //   customerID: overAllPvd.customerId,
      //   controllerId: overAllPvd.controllerId,
      //   deviceId: overAllPvd.imeiNo,
      //   menuId: 73,
      // ),
      // 74: () => GlobalFertilizerLimit(
      //   customerId: overAllPvd.customerId,
      //   userId: overAllPvd.takeSharedUserId
      //       ? overAllPvd.sharedUserId
      //       : overAllPvd.userId,
      //   controllerId: overAllPvd.controllerId,
      //   deviceId: overAllPvd.imeiNo,
      //   menuId: 74,
      // ),
      // 75: () => SystemDefinition(
      //   userId: overAllPvd.takeSharedUserId
      //       ? overAllPvd.sharedUserId
      //       : overAllPvd.userId,
      //   controllerId: controllerId,
      //   deviceId: overAllPvd.imeiNo,
      //   menuId: 75,
      // ),
      // 76: () => ProgramQueueScreen(
      //   userId: overAllPvd.takeSharedUserId
      //       ? overAllPvd.sharedUserId
      //       : overAllPvd.userId,
      //   controllerId: controllerId,
      //   customerId: overAllPvd.customerId,
      //   deviceId: overAllPvd.imeiNo,
      //   menuId: 76,
      // ),
      // 77: () => WeatherScreen(
      //   userId: overAllPvd.takeSharedUserId
      //       ? overAllPvd.sharedUserId
      //       : overAllPvd.userId,
      //   controllerId: overAllPvd.controllerId,
      //   menuId: 77,
      //   initialIndex: 0,
      // ),
      // 78: () => PreferenceMainScreen(
      //   userId: overAllPvd.takeSharedUserId
      //       ? overAllPvd.sharedUserId
      //       : overAllPvd.userId,
      //   controllerId: overAllPvd.controllerId,
      //   deviceId: overAllPvd.imeiNo,
      //   customerId: overAllPvd.customerId,
      //   menuId: 78,
      // ),
      // 79: () => ConstantInConfig(
      //   userId: overAllPvd.customerId,
      //   deviceId: overAllPvd.imeiNo,
      //   customerId: overAllPvd.userId,
      //   controllerId: overAllPvd.controllerId,
      //   menuId: 79,
      // ),
      // 80: () => Names(
      //   userID: overAllPvd.takeSharedUserId
      //       ? overAllPvd.sharedUserId
      //       : overAllPvd.customerId,
      //   customerID: overAllPvd.takeSharedUserId
      //       ? overAllPvd.sharedUserId
      //       : overAllPvd.userId,
      //   controllerId: overAllPvd.controllerId,
      //   imeiNo: overAllPvd.imeiNo,
      //   menuId: 80,
      // ),
      // 81: () => CustomMarkerPage(
      //   userId: overAllPvd.customerId,
      //   controllerId: overAllPvd.controllerId,
      //   deviceID: overAllPvd.imeiNo,
      //   menuId: 81,
      // ),
      // 127: () => Calibration(
      //   userId: overAllPvd.userId,
      //   controllerId: overAllPvd.controllerId,
      //   deviceId: overAllPvd.imeiNo,
      //   menuId: 127,
      // ),
    };

    try {
      return screens[overAllPvd.selectedMenu]?.call() ?? Container();
    } catch (error, stackTrace) {
      print("error in  the bottom sheet $error");
      print("stackTrace in  the bottom sheet $stackTrace");
      return Container();
    }
  }

  dynamic getIconsMenu(int name) {
    final icons = {
      66: 'assets/png_images/menuwatersource.png',
      67: 'assets/png_images/menuwatersource.png',
      68: 'assets/png_images/menuradiationset.png',
      69: 'assets/png_images/menugroup.png',
      70: 'assets/png_images/menucondition.png',
      71: 'assets/png_images/menufrost.png',
      72: 'assets/png_images/menufilter.png',
      73: 'assets/png_images/menufertlizerset.png',
      74: 'assets/png_images/menuglobal.png',
      75: 'assets/png_images/menuwatersource.png',
      76: 'assets/png_images/menuprogramque.png',
      77: 'assets/png_images/menuweather.png',
      78: 'assets/png_images/menufrost.png',
      79: const Icon(Icons.construction),
      80: const Icon(Icons.contact_page_sharp),
      81: const Icon(Icons.map),
    };

    final icon = icons[name];
    return icon is String ? Image.asset(icon) : icon ?? const Icon(Icons.person);
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Exit"),
        content: const Text("Do you want to exit?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => exit(0),
            // onPressed: () => Navigator.of(context).pop(true),// Return true to pop the route
            child: const Text(
              "Yes",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              "No",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<bool> _handleBackButton() async {
    final now = DateTime.now();
    final isWithinTwoSeconds =
        now.difference(_lastPressedAt!) <= const Duration(seconds: 2);
    _lastPressedAt = now;
    if (isWithinTwoSeconds) {
      // Exit the app
      await SystemNavigator.pop(); // Navigate back twice to exit
      return true;
    } else {
      // Show a snackbar with a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
  }
  // TODO: Bottom menu settings particular page calling in send user id and controller id

  Widget buildBottomNavigationTab(
      {required BuildContext context,
        required void Function()? onPressed,
        required IconData icon,
        required bool selected,
        required String label}) {
    return Expanded(
      child: Container(
        child: Column(
          children: [
            IconButton(
              onPressed: onPressed,
              icon: Icon(
                icon,
                color:
                selected ? Theme.of(context).primaryColor : Colors.black54,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                  color: selected
                      ? Theme.of(context).primaryColor
                      : Colors.black54,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> showNavigationDialog(
    {required BuildContext context,
      required int menuId,
      bool ack = false}) async {
  showAdaptiveDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Text(
            ack ? "Acknowledged successfully!" : "Failed!",
            style: TextStyle(color: ack ? Colors.green : Colors.red),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text(
                  "Stay",
                  style: TextStyle(color: Colors.red),
                )),
            TextButton(
                onPressed: () {
                  Provider.of<OverAllUse>(context, listen: false)
                      .updateSelectedMenu(menuId);
                  Navigator.pop(dialogContext);
                },
                child: const Text("Go Next")),
          ],
        );
      });
}
