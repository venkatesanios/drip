import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_drip_irrigation/Screens/dashboard/mobileschedule_program.dart';
import 'package:oro_drip_irrigation/Screens/dashboard/sidedrawer.dart';
import 'package:oro_drip_irrigation/views/customer/node_list.dart';
import 'package:oro_drip_irrigation/views/customer/stand_alone.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../StateManagement/overall_use.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import 'package:oro_drip_irrigation/services/mqtt_manager_mobile.dart' if (dart.library.html) 'package:oro_drip_irrigation/services/mqtt_manager_web.dart';
import '../../utils/Theme/oro_theme.dart';
import '../../utils/constants.dart';
import '../../utils/shared_preferences_helper.dart';
import '../../utils/snack_bar.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../views/customer/home_sub_classes/irrigation_line.dart';
import '../NewIrrigationProgram/preview_screen.dart';
import '../NewIrrigationProgram/schedule_screen.dart';
import 'mobilecurrentprogram.dart';
import 'mobilenext_schedule.dart';

final double speed = 100.0;
final double gap = 100;
final double initialPosition = -100.0;
//siva prakash

class MobDashboard extends StatefulWidget {
  const MobDashboard({super.key});
  @override
  State<MobDashboard> createState() => _DashboardState();
}

class _DashboardState extends State<MobDashboard>
    with TickerProviderStateMixin {
  late MqttPayloadProvider payloadProvider;
  late OverAllUse overAllPvd;
  MqttManager manager = MqttManager();
  bool sourcePumpMode = false;
  bool irrigationLineMode = false;
  bool irrigationPumpMode = false;
  bool filtrationWidgetMode = false;
  bool fertigationWidgetMode = false;
  late Timer _timer;
  int selectedTab = 0;
  int userId = 0;
  double appBarHeight = 105.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _correctPassword = 'Oro@321';
  var liveData;
  late AnimationController _controller;

  @override
  void initState() {
    // final viewModel = Provider.of<CustomerScreenControllerViewModel>(context);
    // final scheduledProgram = viewModel.mySiteList.data[payloadProvider.selectedMaster].master[viewModel.mIndex].programList;

    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    _timer = Timer.periodic(const Duration(seconds: 15), (Timer timer) {
      if (mounted) {
        //
        setState(() {
          irrigationLineMode = !irrigationLineMode;
          sourcePumpMode = !sourcePumpMode;
          irrigationPumpMode = !irrigationPumpMode;
          filtrationWidgetMode = !filtrationWidgetMode;
          fertigationWidgetMode = !fertigationWidgetMode;
        });
      }
    });
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    getData();
    super.initState();
  }

  Future<void> fetchUserPreferences() async {
    // userRole = await PreferenceHelper.getUserRole();
    userId = (await PreferenceHelper.getUserId())!;
  }

  void getData() async {
    await fetchUserPreferences();
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
       await onRefresh();
      }
      payloadProvider.httpError = false;
    } catch (e, stackTrace) {
      payloadProvider.httpError = true;
      print(' Error overAll getData => ${e.toString()}');
      print(' trace overAll getData  => ${stackTrace}');
    }
  }



  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
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

  dynamic getLinePauseResumeMessage(code) {
    var lineMessage = '';
    switch (code) {
      case (0):
        {
          lineMessage = '';
        }
      case (1):
        {
          lineMessage = 'Paused Manually';
        }
      case (2):
        {
          lineMessage = 'Scheduled Program Paused By StandAlone Program';
        }
      case (3):
        {
          lineMessage = 'Paused By System Definition';
        }
      case (4):
        {
          lineMessage = 'Paused By LowFlow Alarm';
        }
      case (5):
        {
          lineMessage = 'Paused By HighFlow Alarm';
        }
      case (6):
        {
          lineMessage = 'Paused By NoFlow Alarm';
        }
      case (7):
        {
          lineMessage = 'Paused By EcHigh';
        }
      case (8):
        {
          lineMessage = 'Paused By PhLow';
        }
      case (9):
        {
          lineMessage = 'Paused By PhHigh';
        }
      case (10):
        {
          lineMessage = 'Paused By PressureLow';
        }
      case (11):
        {
          lineMessage = 'Paused By PressureHigh';
        }
      case (12):
        {
          lineMessage = 'Paused By No Power Supply';
        }
      case (13):
        {
          lineMessage = 'Paused By No Communication';
        }
    }
    return lineMessage;
  }

  void autoRefresh()async{
    String livePayload = '';
    if(liveData[payloadProvider.selectedSite]
        .master[payloadProvider.selectedMaster]
        .categoryId==1 ||
        liveData[payloadProvider.selectedSite]
            .master[payloadProvider.selectedMaster]
            .categoryId==2){
      livePayload = jsonEncode({"3000": {"3001": ""}});
    }else{
      livePayload = jsonEncode({"sentSMS": "#live"});
    }
    // manager.subscribeToTopic('FirmwareToApp/${overAllPvd.imeiNo}');
    manager.topicToSubscribe('FirmwareToApp/${liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].deviceId}');
    manager.topicToPublishAndItsMessage('AppToFirmware/${liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].deviceId}',livePayload,);
     // manager.publish(payloadProvider.publishMessage,'AppToFirmware/${overAllPvd.imeiNo}');
    setState(() {
      payloadProvider.tryingToGetPayload += 1;
    });
  }


  Future onRefresh() async{
    if(manager.isConnected){
      autoRefresh();
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {

    final viewModel = Provider.of<CustomerScreenControllerViewModel>(context);
    // var scheduledPrograms = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].programList;
    var scheduledPrograms = viewModel.mySiteList.data[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].programList;


    // print("sourcePumpMode$sourcePumpMode");
    var selectedSite = liveData?[payloadProvider.selectedSite];
    var selectedMaster = liveData?[payloadProvider.selectedSite]
        .master[payloadProvider.selectedMaster];
    var selectedLine = liveData?[payloadProvider.selectedSite]
        .master[payloadProvider.selectedMaster]
        .config
        .lineData[payloadProvider.selectedLine];
    var selectedfiltersite = liveData?[payloadProvider.selectedSite]
        .master[payloadProvider.selectedMaster]
        .config
        .filterSite;
    var selectedfertilizer = liveData?[payloadProvider.selectedSite]
        .master[payloadProvider.selectedMaster]
        .config
        .lineData[payloadProvider.selectedLine];
    return ((liveData != null))
        ? Scaffold(
      key: _scaffoldKey,
      backgroundColor: cardColor,
      floatingActionButton: ![3,4].contains(overAllPvd.controllerType) ? Container(
        padding: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0,-50),
                  blurRadius: 112,
                  color: Colors.black.withOpacity(0.06)
              ),
            ],
            // color: primaryColorDark,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(40),topLeft: Radius.circular(40))
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if(payloadProvider.currentSchedule.isNotEmpty)
              if(payloadProvider.selectedLine == 0 || payloadProvider.currentSchedule.map((cs) => cs[0]).join('').contains(payloadProvider.lineData[payloadProvider.selectedLine]['id']) )
                InkWell(
                  onTap: (){
                    setState(() {
                      selectedTab = 0;
                    });
                    sideSheet( payloadProvider: payloadProvider, selectedTab: selectedTab, overAllPvd: overAllPvd,scheduledPrograms: scheduledPrograms);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color(0xff95D394),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(30),bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8))
                    ),
                    padding: const EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                    child: const Text('Current\nSchedule',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12),),
                  ),
                ),
            if(payloadProvider.nextSchedule.isNotEmpty)
              if(payloadProvider.selectedLine == 0 || payloadProvider.nextSchedule.map((ns) => 0).join('').contains(payloadProvider.lineData[payloadProvider.selectedLine]['id']) )
                InkWell(
                  onTap: (){
                    setState(() {
                      selectedTab = 1;
                    });
                    sideSheet( payloadProvider: payloadProvider, selectedTab: selectedTab, overAllPvd: overAllPvd,scheduledPrograms: scheduledPrograms);

                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color(0xffFF9A49),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(30),bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8))
                    ),
                    padding: const EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                    child: const Text('Next\nSchedule',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12),),
                  ),
                ),
            // if(payloadProvider.upcomingProgram.isNotEmpty)
            //   if(payloadProvider.selectedLine == 0 || payloadProvider.upcomingProgram.map((up) => up['ProgCategory']).join('').contains(payloadProvider.lineData[payloadProvider.selectedLine]['id']) )
                InkWell(
                  onTap: (){
                    setState(() {
                      selectedTab = 2;
                    });
                    sideSheet( payloadProvider: payloadProvider, selectedTab: selectedTab, overAllPvd: overAllPvd,scheduledPrograms: scheduledPrograms);

                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color(0xff69BCFC),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(30),bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8))
                    ),
                    padding: const EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                    child: Row(
                      children: [
                        const Text('Scheduled\nProgram',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12),),
                        if(payloadProvider.upcomingProgram.any((program)=> (program['StartCondition'].isNotEmpty || program['StopCondition'].isNotEmpty)))
                          const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(Icons.info,color: Colors.amberAccent,size: 30,),
                          )
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      drawer: !overAllPvd.fromDealer ? DrawerWidget(listOfSite: payloadProvider.listOfSite) : Container(),

      body: SafeArea(
                child: Center(
                    child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              if (overAllPvd.fromDealer) {
                                // MqttManager().onDisconnected();
                                Future.delayed(Duration.zero, () {
                                  payloadProvider.clearData();
                                  overAllPvd.userId = 0;
                                  overAllPvd.controllerId = 0;
                                  overAllPvd.controllerType = 0;
                                  overAllPvd.imeiNo = '';
                                  overAllPvd.customerId = 0;
                                  overAllPvd.sharedUserId = 0;
                                  overAllPvd.takeSharedUserId = false;
                                });
                                Navigator.of(context).pop();
                              } else {
                                _scaffoldKey.currentState?.openDrawer();
                              }
                            },
                            icon: Icon(
                              !overAllPvd.fromDealer
                                  ? Icons.menu
                                  : Icons.arrow_back,
                              size: 25,
                            )),
                        InkWell(
                          onTap: () {
                            // print('liveData!!.length: ${liveData!.length}');
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(builder:
                                      (context, StateSetter stateSetter) {
                                    return Container(
                                      height: 400,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20))),
                                      child: Column(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'List of Site',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  for (var site = 0;
                                                      site < liveData!.length;
                                                      site++)
                                                    ListTile(
                                                      title: Text(liveData[site]
                                                              .groupName ??
                                                          ''),
                                                      trailing: IntrinsicWidth(
                                                        child: Radio(
                                                          value: 'site-${site}',
                                                          groupValue:
                                                              payloadProvider
                                                                  .selectedSiteString,
                                                          onChanged: (value) {
                                                            stateSetter(() {
                                                              setState(() {
                                                                var unSubscribeTopic =
                                                                    'FirmwareToApp/${overAllPvd.imeiNo}';
                                                                payloadProvider
                                                                        .selectedSite =
                                                                    site;
                                                                payloadProvider
                                                                        .selectedSiteString =
                                                                    value!;
                                                                payloadProvider
                                                                    .selectedMaster = 0;
                                                                overAllPvd
                                                                        .takeSharedUserId =
                                                                    false;
                                                                var selectedMasterData = liveData[payloadProvider
                                                                            .selectedSite]
                                                                        .master[
                                                                    payloadProvider
                                                                        .selectedMaster];
                                                                overAllPvd
                                                                        .imeiNo =
                                                                    selectedMasterData
                                                                        .deviceId;
                                                                overAllPvd
                                                                        .controllerId =
                                                                    selectedMasterData
                                                                        .controllerId;
                                                                overAllPvd
                                                                        .controllerType =
                                                                    selectedMasterData
                                                                        .categoryId;
                                                                /*if(selectedMasterData.config!.irrigationLine != null){
                                                            payloadProvider.editLineData(selectedMasterData.config!.irrigationLine);
                                                          }*/
                                                                manager.topicToUnSubscribe(
                                                                    unSubscribeTopic);

                                                                print(
                                                                    "controllerType ==> ${overAllPvd.controllerType}");
                                                                payloadProvider.updateReceivedPayload(
                                                                    jsonEncode([
                                                                      3,
                                                                      4
                                                                    ].contains(overAllPvd
                                                                            .controllerType)
                                                                        ? {
                                                                            "mC":
                                                                                "LD01",
                                                                            'cM':
                                                                                "selectedMasterData['liveMessage']"
                                                                          }
                                                                        : jsonEncode(
                                                                            selectedMasterData)),
                                                                    true);
                                                                if ([
                                                                  3,
                                                                  4
                                                                ].contains(
                                                                    overAllPvd
                                                                        .controllerType)) {
                                                                  if (payloadProvider
                                                                          .dataFetchingStatus !=
                                                                      1) {
                                                                    // payloadProvider.lastUpdate = DateTime.parse("${selectedMasterData['liveSyncDate']} ${selectedMasterData['liveSyncTime']}");
                                                                    payloadProvider
                                                                            .lastUpdate =
                                                                        DateTime.parse(
                                                                            "12-01-2025 00:00:00}");
                                                                  }
                                                                }
                                                                manager.topicToSubscribe(
                                                                    'FirmwareToApp/${overAllPvd.imeiNo}');

                                                                Future.delayed(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                    () {
                                                                  Navigator.pop(
                                                                      context);
                                                                });
                                                              });
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  if (payloadProvider
                                                      .listOfSharedUser
                                                      .isNotEmpty)
                                                    for (var sharedUser = 0;
                                                        sharedUser <
                                                            payloadProvider
                                                                .listOfSharedUser[
                                                                    'users']
                                                                .length;
                                                        sharedUser++)
                                                      if (payloadProvider
                                                          .listOfSharedUser[
                                                              'devices']
                                                          .isNotEmpty)
                                                        ListTile(
                                                          title: Text(payloadProvider
                                                                          .listOfSharedUser[
                                                                      'users']
                                                                  [sharedUser]
                                                              ['userName']),
                                                          trailing:
                                                              IntrinsicWidth(
                                                            child: Radio(
                                                              value:
                                                                  'sharedUser-${sharedUser}',
                                                              groupValue:
                                                                  payloadProvider
                                                                      .selectedSiteString,
                                                              onChanged:
                                                                  (value) async {
                                                                try {
                                                                  HttpService
                                                                      service =
                                                                      HttpService();
                                                                  var getSharedUserDetails =
                                                                      await service
                                                                          .postRequest(
                                                                              'getSharedUserDeviceList',
                                                                              {
                                                                        'userId':
                                                                            overAllPvd.userId,
                                                                        "sharedUser":
                                                                            payloadProvider.listOfSharedUser['users'][sharedUser]['userId']
                                                                      });
                                                                  stateSetter(
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      var unSubscribeTopic =
                                                                          'FirmwareToApp/${overAllPvd.imeiNo}';
                                                                      payloadProvider
                                                                              .selectedSite =
                                                                          sharedUser;
                                                                      payloadProvider
                                                                              .selectedSiteString =
                                                                          value!;
                                                                      payloadProvider
                                                                          .selectedMaster = 0;
                                                                      var jsonDataSharedDevice =
                                                                          jsonDecode(
                                                                              getSharedUserDetails.body);
                                                                      // print('code is =======================       ${jsonDataSharedDevice['code']}      ========================');
                                                                      if (jsonDataSharedDevice[
                                                                              'code'] ==
                                                                          200) {
                                                                        payloadProvider.listOfSharedUser =
                                                                            jsonDataSharedDevice['data'];
                                                                        // print('getSharedUserDeviceList : ${payloadProvider.listOfSharedUser}');
                                                                        if (payloadProvider
                                                                            .listOfSharedUser['devices']
                                                                            .isNotEmpty) {
                                                                          setState(
                                                                              () {
                                                                            payloadProvider.selectedMaster =
                                                                                0;
                                                                            var imeiNo =
                                                                                payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceId'];
                                                                            var controllerId =
                                                                                payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['controllerId'];
                                                                            overAllPvd.sharedUserId =
                                                                                jsonDataSharedDevice['data']['users'][0]['userId'];
                                                                            overAllPvd.takeSharedUserId =
                                                                                true;
                                                                            overAllPvd.imeiNo =
                                                                                imeiNo;
                                                                            overAllPvd.controllerId =
                                                                                controllerId;
                                                                            overAllPvd.controllerType =
                                                                                payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['categoryId'];
                                                                            if (payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['irrigationLine'] !=
                                                                                null) {
                                                                              payloadProvider.editLineData(payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['irrigationLine']);
                                                                            }
                                                                            payloadProvider.updateReceivedPayload(
                                                                                jsonEncode([3, 4].contains(overAllPvd.controllerType)
                                                                                    ? {
                                                                                        "mC": "LD01",
                                                                                        'cM': payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['liveMessage']
                                                                                      }
                                                                                    : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]),
                                                                                true);
                                                                            if ([
                                                                              3,
                                                                              4
                                                                            ].contains(overAllPvd.controllerType)) {
                                                                              if (payloadProvider.dataFetchingStatus != 1) {
                                                                                payloadProvider.lastUpdate = DateTime.parse("${payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['liveSyncDate']} ${payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['liveSyncTime']}");
                                                                              }
                                                                            }
                                                                            payloadProvider.editSubscribeTopic('FirmwareToApp/$imeiNo');
                                                                            payloadProvider.editPublishTopic('AppToFirmware/$imeiNo');
                                                                            payloadProvider.editPublishMessage(getPublishMessage());
                                                                            manager.topicToUnSubscribe(unSubscribeTopic);
                                                                            manager.topicToSubscribe('FirmwareToApp/${overAllPvd.imeiNo}');
                                                                            Future.delayed(const Duration(milliseconds: 300),
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            });
                                                                          });
                                                                          for (var i = 0;
                                                                              i < 2;
                                                                              i++) {
                                                                            Future.delayed(const Duration(seconds: 3),
                                                                                () {
                                                                              autoRefresh();
                                                                            });
                                                                          }
                                                                        }
                                                                      }
                                                                      overAllPvd.editImeiNo(payloadProvider
                                                                              .listOfSharedUser['devices']
                                                                          [
                                                                          payloadProvider
                                                                              .selectedMaster]['deviceId']);
                                                                      overAllPvd.editControllerId(payloadProvider
                                                                              .listOfSharedUser['devices']
                                                                          [
                                                                          payloadProvider
                                                                              .selectedMaster]['controllerId']);
                                                                      overAllPvd.editControllerType(payloadProvider
                                                                              .listOfSharedUser['devices']
                                                                          [
                                                                          payloadProvider
                                                                              .selectedMaster]['categoryId']);
                                                                    });
                                                                  });
                                                                } catch (e, stackTrace) {
                                                                  setState(() {
                                                                    payloadProvider
                                                                            .httpError =
                                                                        true;
                                                                  });
                                                                  print(
                                                                      ' Site selecting Error getSharedUserDeviceList  => ${e.toString()}');
                                                                  print(
                                                                      ' Site selecting trace getSharedUserDeviceList  => ${stackTrace}');
                                                                }
                                                                // print('after => ${overAllPvd.userId}');
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                                });
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${!overAllPvd.takeSharedUserId ? liveData![0].groupName : 'test'}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Last Sync : \n${payloadProvider.lastUpdate.day}/${payloadProvider.lastUpdate.month}/${payloadProvider.lastUpdate.year} ${payloadProvider.lastUpdate.hour}:${payloadProvider.lastUpdate.minute}:${payloadProvider.lastUpdate.second}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                          fontSize: 12,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    width: 15,
                                    child: Icon(Icons.arrow_drop_down_sharp))
                              ],
                            ),
                          ),
                        ),

                        // Modified by saravanan
                        buildPopUpMenuButton(
                            context: context,
                            dataList: ([1, 2]
                                        .contains(overAllPvd.controllerType) &&
                                    overAllPvd.fromDealer)
                                ? [
                                    "Standalone",
                                    "Node status",
                                    "Node details",
                                    "Sent and Received",
                                    "Controller Info"
                                  ]
                                : [1, 2].contains(overAllPvd.controllerType)
                                    ? [
                                        "Standalone",
                                        "Node status",
                                        "Node details"
                                      ]
                                    : ["Sent and Received", "Controller Info"],
                            onSelected: (newValue) {
                              if (newValue == "Standalone") {
                                showGeneralDialog(
                                  barrierLabel: "Side sheet",
                                  barrierDismissible: true,
                                  // barrierColor: const Color(0xff6600),
                                  transitionDuration:
                                      const Duration(milliseconds: 300),
                                  context: context,
                                  pageBuilder:
                                      (context, animation1, animation2) {
                                    return Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Scaffold( appBar: AppBar(title: const Text("StandAlone")),body: StandAlone(customerId: overAllPvd.customerId, siteId: overAllPvd.userGroupId, controllerId: overAllPvd.controllerId, userId: userId, deviceId: overAllPvd.deviceId, callbackFunction: callbackFunction, config: liveData?[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].config))
                                      ),
                                    );
                                  },
                                  transitionBuilder:
                                      (context, animation1, animation2, child) {
                                    return SlideTransition(
                                      position: Tween(
                                              begin: const Offset(1, 0),
                                              end: const Offset(0, 0))
                                          .animate(animation1),
                                      child: child,
                                    );
                                  },
                                );
                              }
                              else if(newValue == "Node status") {
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
                                        child: Consumer<MqttPayloadProvider>(
                                            builder: (context, mqttPayloadProvider, _) {
                                              return NodeList(customerId: overAllPvd.customerId, userId: userId, controllerId: overAllPvd.controllerId, deviceId: overAllPvd.deviceId, deviceName: liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].deviceName, nodes: liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].nodeList);
                                            }
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
                              }
                              else if (newValue == "Sent and Received") {
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => SentAndReceived()));
                              } else if (newValue == "Controller Info") {
                                showPasswordDialog(context, _correctPassword);
                              }
                            },
                            child: ([1, 2]
                                        .contains(overAllPvd.controllerType) ||
                                    overAllPvd.fromDealer)
                                ? const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Icon(Icons.more_vert),
                                  )
                                : ![1, 2].contains(overAllPvd.controllerType)
                                    ? Container()
                                    : Container())
                      ],
                    ),
                    (payloadProvider.listOfSite.isNotEmpty
                            ? liveData![payloadProvider.selectedSite]
                                        .master
                                        .length >
                                    1 ||
                                [1, 2].contains(overAllPvd.controllerType)
                            : true)
                        ? Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20)),
                              // boxShadow: customBoxShadow
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(context).primaryColor),
                                  child: PopupMenuButton<int>(
                                    offset: const Offset(0, 50),
                                    initialValue:
                                        payloadProvider.selectedMaster,
                                    onSelected: (int master) {
                                      setState(() {
                                        payloadProvider.selectedMaster = master;
                                      });
                                    },
                                    //every ternary operator  ? user device : sharedevice details
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<int>>[
                                      for (var master = 0;
                                          master <
                                              (!overAllPvd.takeSharedUserId
                                                      ? liveData[payloadProvider
                                                              .selectedSite]
                                                          .master
                                                      : liveData)
                                                  .length;
                                          master++)
                                        PopupMenuItem<int>(
                                          value: master,
                                          child: Text(!overAllPvd
                                                  .takeSharedUserId
                                              ? '${liveData[payloadProvider.selectedSite].master[master].deviceName ?? ''}\n${liveData[payloadProvider.selectedSite].master[master].deviceId} ${[
                                                  1,
                                                  2
                                                ].contains(liveData[payloadProvider.selectedSite].master[master].categoryId) ? '(version : ${payloadProvider.version})' : ''}'
                                              : '${liveData[payloadProvider.selectedSite].master[master].deviceName ?? ''}\n ${[
                                                  1,
                                                  2
                                                ].contains(liveData[payloadProvider.selectedSite].master[master].categoryId ?? '') ? '(version : ${payloadProvider.version})' : ''}'),
                                          onTap: () async {
                                            var unSubscribeTopic =
                                                'FirmwareToApp/${overAllPvd.imeiNo}';
                                            payloadProvider.selectedMaster =
                                                master;
                                            overAllPvd.editImeiNo((!overAllPvd.takeSharedUserId? liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].deviceName: payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceId']));
                                            overAllPvd.editControllerType((!overAllPvd.takeSharedUserId ? liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].categoryId : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['categoryId']));
                                            overAllPvd.editControllerId(
                                                (!overAllPvd.takeSharedUserId ? liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].controllerId : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['controllerId']));
                                            var selectedMaster = !overAllPvd
                                                    .takeSharedUserId
                                                ? liveData[payloadProvider
                                                            .selectedSite]
                                                        .master[
                                                    payloadProvider
                                                        .selectedMaster]
                                                : payloadProvider
                                                            .listOfSharedUser[
                                                        'devices'][
                                                    payloadProvider
                                                        .selectedMaster];

                                            manager.topicToUnSubscribe(
                                                'FirmwareToApp/${overAllPvd.imeiNo}');

                                            payloadProvider
                                                .updateReceivedPayload(
                                                    jsonEncode([3, 4].contains(
                                                            overAllPvd
                                                                .controllerType)
                                                        ? {
                                                            "mC": "LD01",
                                                            'cM': selectedMaster[
                                                                'liveMessage']
                                                          }
                                                        : jsonEncode(
                                                            selectedMaster)),
                                                    true);
                                            if ([3, 4].contains(
                                                overAllPvd.controllerType)) {
                                              payloadProvider.lastUpdate =
                                                  DateTime.parse(
                                                      "${selectedMaster['liveSyncDate']}${selectedMaster['liveSyncTime']}");
                                            }
                                            for (var i = 0; i < 1; i++) {
                                              await Future.delayed(
                                                  const Duration(seconds: 3));
                                              autoRefresh();
                                            }
                                          },
                                        ),
                                    ],
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Image.asset(
                                              'assets/png_images/choose_controller.png'),
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              //                 liveData!![payloadProvider.selectedSite].master![payloadProvider.selectedMaster]
                                              child: Text(
                                                '${(!overAllPvd.takeSharedUserId ? liveData![payloadProvider.selectedSite].master[payloadProvider.selectedMaster].config.lineData[payloadProvider.selectedLine].name : liveData![payloadProvider.selectedSite].master[payloadProvider.selectedMaster].deviceName)}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.wifi,
                                                  color: Colors.orange,
                                                  size: 20,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  '${payloadProvider.wifiStrength}',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (![3, 4].contains(overAllPvd.controllerType))
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white),
                                    child: PopupMenuButton<int>(
                                      offset: const Offset(0, 50),
                                      initialValue:
                                          payloadProvider.selectedLine,
                                      onSelected: (int line) {
                                        setState(() {
                                          payloadProvider.selectedLine = line;
                                        });
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<int>>[
                                        for (var line = 0;
                                            line <
                                                liveData[payloadProvider
                                                        .selectedSite]
                                                    .master[payloadProvider
                                                        .selectedMaster]
                                                    .config
                                                    .lineData
                                                    .length;
                                            line++)
                                          PopupMenuItem<int>(
                                            value: line,
                                            child: Row(
                                              children: [
                                                Text(
                                                    '${liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].config.lineData[line].name}'),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                if (payloadProvider
                                                            .lineData[line]
                                                        ['mode'] !=
                                                    0)
                                                  const Icon(
                                                    Icons.info,
                                                    color: Colors.red,
                                                  )
                                              ],
                                            ),
                                            onTap: () {
                                              setState(() {
                                                payloadProvider.selectedLine =
                                                    line;
                                              });
                                            },
                                          ),
                                      ],
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: Image.asset(
                                                'assets/png_images/irrigation_line1.png'),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                              child: Text(
                                                '${liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].config.lineData[0].name}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              )),
                                          if (payloadProvider.lineData
                                              .any((line) => line['mode'] != 0))
                                            const Icon(
                                              Icons.info,
                                              color: Colors.red,
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                if (![3, 4].contains(overAllPvd.controllerType))
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Consumer<MqttPayloadProvider>(
                                            builder: (context, payloadProvider,
                                                child) {
                                              return Container(
                                                height: 300,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                            'Alarms',
                                                            style: TextStyle(
                                                                fontSize: 20),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            // Close the bottom sheet
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          icon: const Icon(
                                                              Icons.cancel),
                                                        ),
                                                      ],
                                                    ),
                                                    for (var alarm = 0;
                                                        alarm <
                                                            payloadProvider
                                                                .alarmList
                                                                .length;
                                                        alarm++)
                                                      ListTile(
                                                        title: Text(
                                                            '${getAlarmMessage[payloadProvider.alarmList[alarm]['AlarmType']]}'),
                                                        subtitle: Text(
                                                            'Location : ${payloadProvider.alarmList[alarm]['Location']}'),
                                                        trailing: (overAllPvd
                                                                    .takeSharedUserId
                                                                ? (payloadProvider
                                                                            .userPermission[0]
                                                                        [
                                                                        'status'] ||
                                                                    payloadProvider
                                                                            .userPermission[5]
                                                                        [
                                                                        'status'])
                                                                : true)
                                                            ? MaterialButton(
                                                                color: payloadProvider.alarmList[alarm]
                                                                            [
                                                                            'Status'] ==
                                                                        1
                                                                    ? Colors
                                                                        .orange
                                                                    : Colors
                                                                        .red,
                                                                onPressed:
                                                                    () {},
                                                                // onPressed: DashboardPayloadHandler(manager: manager, payloadProvider: payloadProvider, overAllPvd: overAllPvd, setState: setState, context: context,index: alarm).alarmReset,
                                                                // onPressed: () {
                                                                //   String payload =  '${i['S_No']}';
                                                                //   String payLoadFinal = jsonEncode({
                                                                //     "4100": [{"4101": payload}]
                                                                //   });
                                                                //   MqttManager().publish(payLoadFinal, payloadProvider.publishTopic);
                                                                // },
                                                                child:
                                                                    const Text(
                                                                  'Reset',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              )
                                                            : null,
                                                      )
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          const Icon(
                                            Icons.notifications,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                          if (payloadProvider
                                              .alarmList.isNotEmpty)
                                            const Positioned(
                                              top: 0,
                                              left: 10,
                                              child: CircleAvatar(
                                                radius: 8,
                                                backgroundColor: Colors.red,
                                                child: Center(
                                                    child: Text(
                                                  '1',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                )),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: onRefresh,
                    child: [1, 2].contains(overAllPvd.controllerType)
                        ? SingleChildScrollView(
                            child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  topLeft: Radius.circular(30)),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (payloadProvider.tryingToGetPayload > 3)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.red),
                                    child: const Center(
                                      child: Text(
                                        'Please Check Internet In Your Controller.....',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                if (liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].live.cM['PowerSupply'] == 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.deepOrange),
                                    child: Center(
                                      child: Text(
                                          'No Power To ${!overAllPvd.takeSharedUserId ? liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].deviceName : liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].deviceName}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                // if(![3,4].contains(overAllPvd.controllerType))
                                ListTile(
                                  leading: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Image.asset(
                                        'assets/png_images/irrigation_line1.png'),
                                  ),
                                  subtitle: getLinePauseResumeMessage(
                                              selectedLine!.sNo) ==
                                          ''
                                      ? null
                                      : Text(
                                          '${getLinePauseResumeMessage(selectedLine!.sNo)}',
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                        ),
                                  title: Text(
                                    '${selectedLine!.name}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                  ),
                                  trailing: ([0, 1].contains(selectedLine) &&
                                          (overAllPvd.takeSharedUserId
                                              ? (payloadProvider
                                                          .userPermission[0]
                                                      ['status'] ||
                                                  payloadProvider
                                                          .userPermission[4]
                                                      ['status'])
                                              : true))
                                      ? MaterialButton(
                                          color: selectedLine.sNo == 0
                                              ? Colors.orange
                                              : Colors.yellow,
                                          onPressed: () {},
                                          // onPressed: DashboardPayloadHandler(manager: manager, payloadProvider: payloadProvider, overAllPvd: overAllPvd, setState: setState, context: context).irrigationLinePauseResume,
                                          child: Text(
                                            selectedLine.sNo == 0
                                                ? 'Pause'
                                                : 'Resume',
                                            style: TextStyle(
                                                color: selectedLine!.sNo == 0
                                                    ? Colors.white
                                                    : Colors.black),
                                          )
                                          // : loadingButton(),
                                          )
                                      : null,
                                  // subtitle: Text("subtile"),
                                  // title: Text("title"),
                                  // trailing: Text("trailing"),
                                ),
                                if ([3, 4].contains(overAllPvd.controllerType))
                                  Container(
                                    color: Colors.red,
                                    child: const Text(
                                      "PumpControllerDashboard",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ) //  PumpControllerDashboard(userId: overAllPvd.takeSharedUserId ? overAllPvd.sharedUserId : userId, deviceId: overAllPvd.imeiNo, controllerId: overAllPvd.controllerId, selectedSite: payloadProvider.selectedSite, selectedMaster: payloadProvider.selectedMaster,)
                                else
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(8),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Column(
                                            children: [
                                              mobdashboarddesign(context)
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.3,
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ))
                        : Container(
                            color: Colors.red,
                            child: const Text(
                              " PumpControllerDashboard",
                              style: TextStyle(color: Colors.white),
                            ),
                          ), // PumpControllerDashboard(userId: overAllPvd.takeSharedUserId ? overAllPvd.sharedUserId : userId, deviceId: overAllPvd.imeiNo, controllerId: overAllPvd.controllerId, selectedSite: payloadProvider.selectedSite, selectedMaster: payloadProvider.selectedMaster,),
                  ),
                ),
                // buildBottomNavigationBar(),
              ],
            ))),
          )
        : const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  @override
  Widget mobdashboarddesign(BuildContext context) {
    List<WaterSource> waterSource = payloadProvider.waterSourceMobDash;
    List<FilterSite> filterSite = payloadProvider.filterSiteMobDash;
    List<FertilizerSite> fertilizerSite = payloadProvider.fertilizerSiteMobDash;
    List<IrrigationLineData>? irrLineData = payloadProvider.irrLineDataMobDash;

    var outputOnOffLiveMessage = Provider.of<MqttPayloadProvider>(context).outputOnOffLiveMessage;
    print('outputOnOffLiveMessage:$outputOnOffLiveMessage');

    List<String> filteredPumpStatus = outputOnOffLiveMessage
        .where((item) => item.startsWith('5.')).toList();
    updatePumpStatus(waterSource, filteredPumpStatus);

    List<String> filteredValveStatus = outputOnOffLiveMessage
        .where((item) => item.startsWith('13.')).toList();
    updateValveStatus(irrLineData!, filteredValveStatus);


    double screenWith = MediaQuery.sizeOf(context).width - 50;

    int totalWaterSources = waterSource.length;
    int totalOutletPumps =
        waterSource.fold(0, (sum, source) => sum + source.outletPump.length);

    int totalFilters =
        filterSite.fold(0, (sum, site) => sum + (site.filters.length ?? 0));
    int totalPressureIn = filterSite.fold(
        0, (sum, site) => sum + (site.pressureIn! != null ? 1 : 0));
    int totalPressureOut = filterSite.fold(
        0, (sum, site) => sum + (site.pressureOut! != null ? 1 : 0));

    int totalBoosterPump = fertilizerSite.fold(
        0, (sum, site) => sum + (site.boosterPump.length ?? 0));
    int totalChannels =
        fertilizerSite.fold(0, (sum, site) => sum + (site.channel.length ?? 0));
    int totalAgitators = fertilizerSite.fold(
        0, (sum, site) => sum + (site.agitator.length ?? 0));

    int grandTotal = totalWaterSources +
        totalOutletPumps +
        totalFilters +
        totalPressureIn +
        totalPressureOut +
        totalBoosterPump +
        totalChannels +
        totalAgitators;

    print(screenWith);

    List<WaterSource> sortedWaterSources = [...waterSource]..sort((a, b) {
        bool aHasOutlet = a.outletPump.isNotEmpty;
        bool bHasOutlet = b.outletPump.isNotEmpty;

        bool aHasInlet = a.inletPump.isNotEmpty;
        bool bHasInlet = b.inletPump.isNotEmpty;

        if (aHasOutlet && !aHasInlet && (!bHasOutlet || bHasInlet)) return -1;
        if (bHasOutlet && !bHasInlet && (!aHasOutlet || aHasInlet)) return 1;

        return 0;
      });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade400,
            width: 0.5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: sortedWaterSources.asMap().entries.map((entry) {
                  int index = entry.key;
                  var source = entry.value;
                  bool isLastIndex = index == sortedWaterSources.length - 1;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: fertilizerSite.isNotEmpty ? 38.4 : 0),
                        child: Stack(
                          children: [
                            SizedBox(
                                width: 70,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: index == 0 ? 33 : 0),
                                      child: Divider(
                                          thickness: 2,
                                          color: Colors.grey.shade300,
                                          height: 5.5),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: index == 0 ? 37 : 0),
                                      child: Divider(
                                          thickness: 2,
                                          color: Colors.grey.shade300,
                                          height: 4.5),
                                    ),
                                  ],
                                )),
                            SizedBox(
                              width: 70,
                              height: 95,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
/*
                                  SizedBox(
                                    width: 70,
                                    height: 15,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 3),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Divider(thickness: 1, color: Colors.black, height: 3),
                                          Divider(thickness: 1, color: Colors.black, height: 5),
                                        ],
                                      ),
                                    ),
                                  ),
*/
                                  SizedBox(
                                    width: 70,
                                    height: 15,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 3),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          VerticalDivider(
                                              thickness: 1,
                                              color: Colors.grey.shade400,
                                              width: 3),
                                          VerticalDivider(
                                              thickness: 1,
                                              color: Colors.grey.shade400,
                                              width: 5),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                        color: Colors.blue.shade300,
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(5),
                                            bottomRight: Radius.circular(5))),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    source.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            if (source.level != null) ...[
                              Positioned(
                                top: 25,
                                left: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(2)),
                                    border: Border.all(
                                        color: Colors.grey, width: .50),
                                  ),
                                  width: 60,
                                  height: 18,
                                  child: Center(
                                    child: Text(
                                      '${source.level!.percentage!} feet',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 50,
                                left: 5,
                                child: SizedBox(
                                  width: 60,
                                  child: Center(
                                    child: Text(
                                      '${source.valves} %',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: 0.0,
                        children: source.outletPump.map((pump) {
                          return displayPump(pump);
                        }).toList(),
                      ),
                    ],
                  );
                }).toList(),
              ),
              if (filterSite.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: displayFilterSite(context, filterSite),
                ),
              if (fertilizerSite.isNotEmpty)
                displayFertilizerSite(context, fertilizerSite),
              IrrigationLine(
                lineData: irrLineData,
                pumpStationWith: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget displayPump(Pump pump) {
    return Stack(
      children: [
        SizedBox(
          width: 70,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: AppConstants.getAsset('pump', pump.status, ''),
              ),
              const SizedBox(height: 4),
              Text(
                pump.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget displayFilter(Filters filter) {
    return Stack(
      children: [
        SizedBox(
            width: 70,
            child:
                Divider(thickness: 2, color: Colors.grey.shade300, height: 10)),
        SizedBox(
          width: 70,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: AppConstants.getAsset('filter', filter.status, ''),
              ),
              const SizedBox(height: 4),
              Text(
                filter.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget displayFilterSite(context, List<FilterSite> filterSite) {
    return Column(
      children: [
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < filterSite.length; i++)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          filterSite[i].pressureIn! != null
                              ? SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        'assets/png_images/dp_prs_sensor.png',
                                      ),
                                      Positioned(
                                        top: 42,
                                        left: 5,
                                        child: Container(
                                          width: 60,
                                          height: 17,
                                          decoration: BoxDecoration(
                                            color: Colors.yellow,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(2)),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: .50,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${filterSite[i].pressureIn?.value} bar',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                          SizedBox(
                            height: 91,
                            width: filterSite[i].filters.length * 70,
                            child: ListView.builder(
                              itemCount: filterSite[i].filters.length,
                              scrollDirection: Axis.horizontal,
                              //reverse: true,
                              itemBuilder: (BuildContext context, int flIndex) {
                                return Column(
                                  children: [
                                    Stack(
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: AppConstants.getAsset(
                                              'filter',
                                              filterSite[i]
                                                  .filters[flIndex]
                                                  .status,
                                              ''),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 70,
                                      height: 20,
                                      child: Center(
                                        child: Text(
                                          filterSite[i].filters[flIndex].name,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          filterSite[i].pressureOut! != null
                              ? SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        'assets/png_images/dp_prs_sensor.png',
                                      ),
                                      Positioned(
                                        top: 42,
                                        left: 5,
                                        child: Container(
                                          width: 60,
                                          height: 17,
                                          decoration: BoxDecoration(
                                            color: Colors.yellow,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(2)),
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: .50,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${filterSite[i].pressureOut?.value} bar',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        width: filterSite[i].pressureIn! != null
                            ? filterSite[i].filters.length * 70 + 70
                            : filterSite[i].filters.length * 70,
                        height: 20,
                        child: Center(
                          child: Text(
                            filterSite[i].name,
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            )),
      ],
    );
  }

  Widget displayFertilizerSite(context, List<FertilizerSite> fertilizerSite) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        for (int fIndex = 0; fIndex < fertilizerSite.length; fIndex++)
          SizedBox(
            height: 170,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 120,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (fIndex != 0)
                            SizedBox(
                              width: 4.5,
                              height: 120,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 42),
                                    child: VerticalDivider(
                                      width: 0,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4.5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 45),
                                    child: VerticalDivider(
                                      width: 0,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(
                              width: 70,
                              height: 120,
                              child: Stack(
                                children: [
                                  AppConstants.getAsset(
                                      'booster',
                                      fertilizerSite[fIndex]
                                          .boosterPump[0]
                                          .status,
                                      ''),
                                  Positioned(
                                    top: 70,
                                    left: 15,
                                    child: fertilizerSite[fIndex]
                                            .selector
                                            .isNotEmpty
                                        ? const SizedBox(
                                            width: 50,
                                            child: Center(
                                              child: Text(
                                                'Selector',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                  Positioned(
                                    top: 85,
                                    left: 18,
                                    child: fertilizerSite[fIndex]
                                            .selector
                                            .isNotEmpty
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: fertilizerSite[fIndex]
                                                              .selector[0]
                                                          ['Status'] ==
                                                      0
                                                  ? Colors.grey.shade300
                                                  : fertilizerSite[fIndex]
                                                                  .selector[0]
                                                              ['Status'] ==
                                                          1
                                                      ? Colors.greenAccent
                                                      : fertilizerSite[fIndex]
                                                                      .selector[
                                                                  0]['Status'] ==
                                                              2
                                                          ? Colors.orangeAccent
                                                          : Colors.redAccent,
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                            width: 45,
                                            height: 22,
                                            child: Center(
                                              child: Text(
                                                fertilizerSite[fIndex]
                                                                .selector[0]
                                                            ['Status'] !=
                                                        0
                                                    ? fertilizerSite[fIndex]
                                                        .selector[0]['Name']
                                                    : '--',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                  Positioned(
                                    top: 115,
                                    left: 8.3,
                                    child: Image.asset(
                                      'assets/png_images/dp_frt_vertical_pipe.png',
                                      width: 9.5,
                                      height: 37,
                                    ),
                                  ),
                                ],
                              )),
                          SizedBox(
                            width: fertilizerSite[fIndex].channel.length * 70,
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: fertilizerSite[fIndex].channel.length,
                              itemBuilder: (BuildContext context, int index) {
                                var fertilizer =
                                    fertilizerSite[fIndex].channel[index];
                                double fertilizerQty = 0.0;
                                var qtyValue = fertilizer.qty;
                                fertilizerQty = double.parse(qtyValue);

                                var fertilizerLeftVal = fertilizer.qtyLeft;
                                fertilizer.qtyLeft = fertilizerLeftVal;

                                return SizedBox(
                                  width: 70,
                                  height: 120,
                                  child: Stack(
                                    children: [
                                      buildFertilizerImage(
                                          index,
                                          fertilizer.status,
                                          fertilizerSite[fIndex].channel.length,
                                          fertilizerSite[fIndex].agitator),
                                      Positioned(
                                        top: 52,
                                        left: 6,
                                        child: CircleAvatar(
                                          radius: 8,
                                          backgroundColor: Colors.teal.shade100,
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 50,
                                        left: 18,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          width: 60,
                                          child: Center(
                                            child: Text(
                                              fertilizer.fertMethod == '1' ||
                                                      fertilizer.fertMethod ==
                                                          '3'
                                                  ? fertilizer.duration
                                                  : '${fertilizerQty.toStringAsFixed(2)} L',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 65,
                                        left: 18,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          width: 60,
                                          child: Center(
                                            child: Text(
                                              '${fertilizer.flowRate_LpH}-lph',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 103,
                                        left: 0,
                                        child: fertilizer.status != 0 &&
                                                fertilizer.selected != '_' &&
                                                fertilizer.durationLeft !=
                                                    '00:00:00'
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.greenAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                width: 50,
                                                child: Center(
                                                  child: Text(
                                                    fertilizer.fertMethod ==
                                                                '1' ||
                                                            fertilizer
                                                                    .fertMethod ==
                                                                '3'
                                                        ? fertilizer
                                                            .durationLeft
                                                        : '${fertilizer.qtyLeft} L',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          fertilizerSite[fIndex].agitator.isNotEmpty
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: fertilizerSite[fIndex]
                                      .agitator
                                      .map<Widget>((agitator) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          width: 59,
                                          height: 34,
                                          child: AppConstants.getAsset(
                                            'agitator',
                                            agitator.status,
                                            '',
                                          ),
                                        ),
                                        Center(
                                            child: Text(
                                          agitator.name,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.black54),
                                        )),
                                      ],
                                    );
                                  }).toList(), // Convert the map result to a list of widgets
                                )
                              : const SizedBox(),
                        ],
                      )),
                ),
                SizedBox(
                  height: 30,
                  width: (fertilizerSite[fIndex].channel.length * 79 +
                          fertilizerSite[fIndex].agitator.length * 59) +
                      50,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                        child: Row(
                          children: [
                            if (fIndex != 0)
                              const Row(
                                children: [
                                  VerticalDivider(
                                      width: 0, color: Colors.black12),
                                  SizedBox(
                                    width: 4.0,
                                  ),
                                  VerticalDivider(
                                      width: 0, color: Colors.black12),
                                ],
                              ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 10.5,
                                ),
                                const VerticalDivider(
                                    width: 0, color: Colors.black12),
                                const SizedBox(
                                  width: 4.0,
                                ),
                                const VerticalDivider(
                                    width: 0, color: Colors.black12),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                fertilizerSite[fIndex].ec!.isNotEmpty ||
                                        fertilizerSite[fIndex].ph!.isNotEmpty
                                    ? SizedBox(
                                        width:
                                            fertilizerSite[fIndex].ec!.length >
                                                    1
                                                ? 110
                                                : 60,
                                        height: 24,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            fertilizerSite[fIndex]
                                                    .ec!
                                                    .isNotEmpty
                                                ? SizedBox(
                                                    height: 12,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          fertilizerSite[fIndex]
                                                              .ec!
                                                              .length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Center(
                                                                child: Text(
                                                              'Ec : ',
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal),
                                                            )),
                                                            Center(
                                                              child: Text(
                                                                double.parse(fertilizerSite[
                                                                            fIndex]
                                                                        .ec![
                                                                            index]
                                                                        .value)
                                                                    .toStringAsFixed(
                                                                        2),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : const SizedBox(),
                                            fertilizerSite[fIndex]
                                                    .ph!
                                                    .isNotEmpty
                                                ? SizedBox(
                                                    height: 12,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          fertilizerSite[fIndex]
                                                              .ph!
                                                              .length,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return Row(
                                                          children: [
                                                            const Center(
                                                                child: Text(
                                                              'pH : ',
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal),
                                                            )),
                                                            Center(
                                                              child: Text(
                                                                double.parse(fertilizerSite[
                                                                            fIndex]
                                                                        .ph![
                                                                            index]
                                                                        .value)
                                                                    .toStringAsFixed(
                                                                        2),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 5,
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      )
                                    : const SizedBox(),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  width: (fertilizerSite[fIndex]
                                              .channel
                                              .length *
                                          67) -
                                      (fertilizerSite[fIndex].ec!.isNotEmpty
                                          ? fertilizerSite[fIndex].ec!.length *
                                              70
                                          : fertilizerSite[fIndex].ph!.length *
                                              70),
                                  child: Center(
                                    child: Text(
                                      fertilizerSite[fIndex].name,
                                      style: TextStyle(
                                          color: primaryDark, fontSize: 11),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex:  0 ,
      // [1, 2].contains(overAllPvd.controllerType) ? !isBottomSheet ? irrigationProgramProvider.selectedIndex > 1
      //     ? irrigationProgramProvider.selectedIndex + 1
      //     : irrigationProgramProvider.selectedIndex
      //     : 2
      //     : irrigationProgramProvider.selectedIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      elevation: 10,
      backgroundColor: cardColor,
      // showUnselectedLabels: false, // Hide labels for unselected items
      onTap: (index) {
        if([1, 2].contains(overAllPvd.controllerType)) {
          if (index == 2) return;
        }
        final actualIndex = index > 2 ? index - 1 : index;
        // isBottomSheet = false;
        // if([3, 4].contains(overAllPvd.controllerType) && !isBottomSheet) {
        //   Provider.of<PreferenceProvider>(context, listen: false).getUserPreference(userId: overAllPvd.takeSharedUserId ? overAllPvd.sharedUserId : overAllPvd.userId, controllerId: overAllPvd.controllerId);
        // }
        // irrigationProgramProvider.updateBottomNavigation([1, 2].contains(overAllPvd.controllerType) ? actualIndex : index);
      },
      items: [
        const BottomNavigationBarItem(activeIcon: Icon(Icons.dashboard), label: "Dashboard", icon: Icon(Icons.dashboard_outlined)),
        BottomNavigationBarItem(
            activeIcon: Icon([1, 2].contains(overAllPvd.controllerType) ? Icons.schedule : Icons.settings),
            label: [1, 2].contains(overAllPvd.controllerType) ? "Program" : "Settings",
            icon: Icon([1, 2].contains(overAllPvd.controllerType) ? Icons.schedule_outlined : Icons.settings_outlined)
        ),
        if([1, 2].contains(overAllPvd.controllerType))
          const BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''), // Placeholder
        BottomNavigationBarItem(
          icon: Icon([1, 2].contains(overAllPvd.controllerType) ? Icons.calendar_month_outlined : Icons.schedule_outlined),
          activeIcon: Icon([1, 2].contains(overAllPvd.controllerType) ? Icons.calendar_month : Icons.schedule),
          label: [1, 2].contains(overAllPvd.controllerType) ? "Schedule" : "View",
        ),
        BottomNavigationBarItem(
            icon: const Icon(Icons.assessment_outlined),
            activeIcon: const Icon(Icons.assessment),
            label: [1, 2].contains(overAllPvd.controllerType) ? "Log" : "Logs"
        ),
      ],
    );
  }

  Widget buildFertilizerImage(
      int cIndex, int status, int cheLength, List agitatorList)
  {
    String imageName;
    if (cIndex == cheLength - 1) {
      if (agitatorList.isNotEmpty) {
        imageName = 'dp_frt_channel_last_aj';
      } else {
        imageName = 'dp_frt_channel_last';
      }
    } else {
      if (agitatorList.isNotEmpty) {
        if (cIndex == 0) {
          imageName = 'dp_frt_channel_first_aj';
        } else {
          imageName = 'dp_frt_channel_center_aj';
        }
      } else {
        imageName = 'dp_frt_channel_center';
      }
    }

    switch (status) {
      case 0:
        imageName += '.png';
        break;
      case 1:
        imageName += '_g.png';
        break;
      case 2:
        imageName += '_y.png';
        break;
      case 3:
        imageName += '_r.png';
        break;
      case 4:
        imageName += '.png';
        break;
      default:
        imageName += '.png';
    }

    return Image.asset('assets/png_images/$imageName');
  }

  void updatePumpStatus(List<WaterSource> waterSource, List<dynamic> filteredPumpStatus) {
    for (var source in waterSource) {
      for (var pump in source.outletPump) {
        int? status = getStatus(filteredPumpStatus, pump.sNo);
        if (status != null) {
          pump.status = status;
        } else {
          print("Serial Number ${pump.sNo} not found");
        }
      }
    }
  }

  void updateValveStatus(List<IrrigationLineData> lineData, List<dynamic> filteredValveStatus) {

    for (var line in lineData) {
      for (var vl in line.valves) {
        int? status = getStatus(filteredValveStatus, vl.sNo);
        if (status != null) {
          vl.status = status;
        } else {
          print("Serial Number ${vl.sNo} not found");
        }
      }
    }
  }

  int? getStatus(List<dynamic> outputOnOffLiveMessage, double serialNumber) {

    for (int i = 0; i < outputOnOffLiveMessage.length; i++) {
      List<String> parts = outputOnOffLiveMessage[i].split(',');
      double? serial = double.tryParse(parts[0]);

      if (serial != null && serial == serialNumber) {
        return int.parse(parts[1]);
      }
    }
    return null;
  }

  Widget getActiveObjects(
      {required BuildContext context,
      required bool active,
      required String title,
      required Function()? onTap,
      required int mode}) {
    List<Color> gradient = active == true
        ? [const Color(0xff22414C), const Color(0xff294C5C)]
        : [];
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        height: (30 * getTextScaleFactor(context)).toDouble(),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(mode == 1 ? 4 : 0),
              bottomLeft: Radius.circular(mode == 1 ? 4 : 0),
              topRight: Radius.circular(mode == 2 ? 4 : 0),
              bottomRight: Radius.circular(mode == 2 ? 4 : 0),
            ),
            gradient: active == true
                ? LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: gradient,
                  )
                : null,
            color: active == false ? const Color(0xffECECEC) : null),
        child: Center(
            child: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active == true ? Colors.white : Colors.black),
        )),
      ),
    );
  }



  getTextScaleFactor(context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  Widget loadingButton() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: const LoadingIndicator(
        colors: [
          Colors.white,
          Colors.white,
        ],
        indicatorType: Indicator.ballPulse,
      ),
    );
  }



  void sideSheet({
    required MqttPayloadProvider payloadProvider,
    required selectedTab,
    required OverAllUse overAllPvd,
    required List<ProgramList>  scheduledPrograms
  })
  {
    showGeneralDialog(
      barrierLabel: "Side sheet",
      barrierDismissible: true,
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
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Scaffold(
                    floatingActionButton: InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: customBoxShadow
                        ),
                        height: 60,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.keyboard_double_arrow_left),
                            Text('Go Back'),
                          ],
                        ),
                      ),
                    ),
                    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                    body: Container(
                      padding: const EdgeInsets.all(3),
                      // margin: EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.zero,
                      ),
                      height: double.infinity,
                      width:  MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if(selectedTab == 0)
                             MobCurrentProgram(scheduledPrograms: scheduledPrograms,deviceId: overAllPvd.imeiNo,),
                            if(selectedTab == 1)
                              // Container(),
                              NextScheduleForMobile(scheduledPrograms: scheduledPrograms,),
                            if(selectedTab == 2)
                               ScheduledProgram(userId: userId, scheduledPrograms: scheduledPrograms, masterInx: payloadProvider.selectedMaster, deviceId: payloadProvider.dashboardLiveInstance!.data[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].deviceId)
                           ],
                        ),
                      ),
                    ),
                  ),
                );
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
  }
}

Widget getLoadingWidget(
    {required BuildContext context, required double controllerValue}) {
  return Container(
    color: Colors.white,
    width: MediaQuery.of(context).size.width - 50,
    height: MediaQuery.of(context).size.height,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text(
          'Loading....',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
        Transform.rotate(
          angle: 6.28 * controllerValue,
          child: const Icon(
            Icons.hourglass_bottom,
            color: Colors.black,
          ),
        )
      ],
    ),
  );
}

void showPasswordDialog(BuildContext context, correctPassword) {
  final TextEditingController _passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter Password'),
        content: TextField(
          controller: _passwordController,
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
              final enteredPassword = _passwordController.text;

              if (enteredPassword == correctPassword) {
                Navigator.of(context).pop(); // Close the dialog
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ResetVerssion()),
                // );
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
void callbackFunction(message)
{
  /*Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 500), () {
      _showSnackBar(message);
    });*/
}
void stayAlert(
    {required BuildContext context,
    required MqttPayloadProvider payloadProvider,
    required String message}) {
  GlobalSnackBar.show(
      context, message, int.parse(payloadProvider.messageFromHw['Code']));
}

dynamic getAlarmMessage = {
  1: 'Low Flow',
  2: 'High Flow',
  3: 'No Flow',
  4: 'Ec High',
  5: 'Ph Low',
  6: 'Ph High',
  7: 'Pressure Low',
  8: 'Pressure High',
  9: 'No Power Supply',
  10: 'No Communication',
  11: 'Wrong Feedback',
  12: 'Sump Tank Empty',
  13: 'Top Tank Full',
  14: 'Low Battery',
  15: 'Ec Difference',
  16: 'Ph Difference',
  17: 'Pump Off Alarm',
  18: 'Pressure Switch High',
};

dynamic pumpAlarmMessage = {
  '1': 'sump empty',
  '2': 'upper tank full',
  '3': 'low voltage',
  '4': 'high voltage',
  '5': 'voltage SPP',
  '6': 'reverse phase',
  '7': 'starter trip',
  '8': 'dry run',
  '9': 'overload',
  '10': 'current SPP',
  '11': 'cyclic trip',
  '12': 'maximum run time',
  '13': 'sump empty',
  '14': 'upper tank full',
  '15': 'RTC 1',
  '16': 'RTC 2',
  '17': 'RTC 3',
  '18': 'RTC 4',
  '19': 'RTC 5',
  '20': 'RTC 6',
  '21': 'auto mobile key off',
  '22': 'cyclic time',
  '23': 'RTC 1',
  '24': 'RTC 2',
  '25': 'RTC 3',
  '26': 'RTC 4',
  '27': 'RTC 5',
  '28': 'RTC 6',
  '29': 'auto mobile key on',
  '30': 'Power off',
  '31': 'Power on',
};

class MarqueeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double containerWidth;
  final double containerHeight;

  MarqueeText({
    required this.text,
    required this.style,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: containerWidth);

        bool isOverflowing = textPainter.didExceedMaxLines;

        return SizedBox(
          width: containerWidth,
          height: containerHeight,
          child: Text(
            text,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
