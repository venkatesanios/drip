import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/customer_provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../repository/repository.dart';
import '../../services/communication_service.dart';
import '../../services/http_service.dart';
import '../../services/mqtt_service.dart';
import '../../utils/constants.dart';

class CustomerScreenControllerViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMsg = '';

  int selectedIndex = 0, unreadAlarmCount = 2;

  late SiteModel mySiteList = SiteModel(data: []);
  int sIndex = 0, mIndex = 0, lIndex = 0;
  late String myCurrentSite;
  String fromWhere = '';
  String myCurrentIrrLine= 'No Line Available';
  int wifiStrength = 0;

  late MqttPayloadProvider payloadProvider;
  final MqttService mqttService = MqttService();
  final BuildContext context;
  StreamSubscription<MqttConnectionState>? mqttSubscription;

  bool programRunning = false;

  List<String> pairedDevices = [
    'Device A',
    'Device B',
    'Device C',
  ];

  CustomerScreenControllerViewModel(this.context, this.repository){
    fromWhere='init';
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    mqttConnectionCallbackMethod();
  }

  void mqttConnectionCallbackMethod() {
    mqttConfigureAndConnect(context);
    MqttService().mqttConnectionStream.listen((state) {
      if (state == MqttConnectionState.connected) {
        print("MQTT Connected! Callback");
        onSubscribeTopic();
      } else if (state == MqttConnectionState.connecting) {
        print("MQTT Connecting... Callback");
      } else {
        print("MQTT Disconnected Callback");
      }
    });

  }

  void mqttConfigureAndConnect(BuildContext context) {
    mqttService.initializeMQTTClient(state: payloadProvider);
    mqttService.connect();
  }

  void onSubscribeTopic(){
    Future.delayed(const Duration(milliseconds: 2000), () {
      mqttService.topicToSubscribe('${AppConstants.subscribeTopic}/${mySiteList.data[sIndex].master[mIndex].deviceId}');
      onRefreshClicked();
    });
  }

  Future<void> getAllMySites(context, int customerId) async {
    setLoading(true);
    try {
      Map<String, dynamic> body = {"userId": customerId};
      final response = await repository.fetchAllMySite(body);
      print(response.body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          mySiteList = SiteModel.fromJson(jsonData);

          updateSite(sIndex, mIndex, 0);
          payloadProvider.saveUnits(Unit.toJsonList(mySiteList.data[0].master[0].units));
          var live = mySiteList.data[sIndex].master[mIndex].live;

          final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
          customerProvider.updateCustomerInfo(customerId: customerId);
          customerProvider.updateControllerCommunicationMode(cmmMode: mySiteList.data[sIndex].master[mIndex].communicationMode!);

          if (live != null) {
            String liveJson = jsonEncode(live);
            payloadProvider.updateReceivedPayload(liveJson, true);
          } else {
            payloadProvider.updateReceivedPayload('''{  "cC": "00000000",
            "cM": {"2401": "","2402": "","2403": "","2404": "", "2405": "", "2406": "", "2407": "", "2408": "",  "2409": "",
            "2410": "",  "2411": "",  "2412": "",  "WifiStrength": 0, "Version": "",  "PowerSupply": 0 },
            "cD": "0000-00-00", "cT": "00:00:00",  "mC": "2400" }''', true);
          }

          wifiStrength = mySiteList.data[sIndex].master[mIndex].live?.cM['WifiStrength'];

        }
      }
    } catch (error) {
      errorMsg = 'Error fetching site list: $error';
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool value) {
    //if (!hasListeners) return;
    isLoading = value;
    notifyListeners();
  }

  void siteOnChanged(String siteName) {
    if (mySiteList.data.isEmpty) return;
    int index = mySiteList.data.indexWhere((site) => site.groupName == siteName);
    if (index != -1) {
      sIndex = index;
      fromWhere='site';
      updateSite(index, 0, 0);
    }
  }

  bool isChanged = true;

  void masterOnChanged(index) async{
    if (mySiteList.data[sIndex].master.length > 1) {
      mIndex = index;
      lIndex = 0;
      fromWhere='master';
      updateMaster(sIndex, index, 0);
      onSubscribeTopic();
    }
    isChanged = false;
    await Future.delayed(const Duration(seconds: 1));
    isChanged = true;
    notifyListeners();
  }

  void lineOnChanged(int lInx){
    if (mySiteList.data[sIndex].master[mIndex].irrigationLine.length > 1) {
      lIndex = lInx;
      fromWhere='line';
      updateMasterLine(sIndex, mIndex, lInx);
    }
  }

  void updateSite(sIdx, mIdx, lIdx){
    myCurrentSite = mySiteList.data[sIdx].groupName;
    updateMaster(sIdx, mIdx, lIdx);
  }

  void updateMaster(sIdx, mIdx, lIdx){
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    customerProvider.updateControllerInfo(
        controllerId: mySiteList.data[sIdx].master[mIdx].controllerId,
        device: mySiteList.data[sIdx].master[mIdx].deviceId);

    //subscribeCurrentMaster(sIdx, mIdx);
    if(mySiteList.data[sIdx].master[mIdx].categoryId == 1){
      updateMasterLine(sIdx, mIdx, lIdx);
      //displayServerData();
    }else{
      //pump controller
      //MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
      //payloadProvider.updateLastSync('${mySiteList[siteIndex].master[masterIndex].liveSyncDate} ${mySiteList[siteIndex].master[masterIndex].liveSyncTime}');
    }
    notifyListeners();
  }

  void updateMasterLine(sIdx, mIdx, lIdx){
    if(mySiteList.data[sIdx].master[mIdx].irrigationLine.isNotEmpty){
      myCurrentIrrLine = mySiteList.data[sIdx].master[mIdx].irrigationLine[lIdx].name;
      notifyListeners();
    }
  }

  void updateLivePayload(int ws, String liveDataAndTime, List<String> cProgram) {
    payloadProvider.wifiStrength = 0;
    payloadProvider.liveDateAndTime = '';

    List<String> parts = liveDataAndTime.split(' ');
    String date = parts[0];
    String time = parts[1];

    mySiteList.data[sIndex].master[mIndex].live?.cD = date;
    mySiteList.data[sIndex].master[mIndex].live?.cT = time;

    wifiStrength = ws;

    programRunning = cProgram[0].isNotEmpty;
    if(programRunning){
      payloadProvider.currentSchedule = cProgram;
    }

    notifyListeners();
  }

  Future<void>  onRefreshClicked() async {

    String livePayload = '';
    print(mySiteList.data[sIndex].master[mIndex].categoryId);
    if (mySiteList.data[sIndex].master[mIndex].categoryId == 1) {
      livePayload = jsonEncode({"3000": {"3001": ""}});
    } else {
      livePayload = jsonEncode({"sentSms": "#live"});
    }



    payloadProvider.liveSyncCall(true);
    final communicationService = context.read<CommunicationService>();
    final result = await communicationService.sendCommand(serverMsg:'', payload: livePayload);

    if (result['http'] == true) {
      debugPrint("Payload sent to Server");
    }
    if (result['mqtt'] == true) {
      debugPrint("Payload sent to MQTT Box");
    }
    if (result['bluetooth'] == true) {
      debugPrint("Payload sent via Bluetooth");
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    payloadProvider.liveSyncCall(false);

    /*if (mqttService.connectionState != MqttConnectionState.connected) {
      mqttConnectionCallbackMethod();
      return;
    }

    int attempts = 0;
    bool responseReceived = false;

    payloadProvider.liveSyncCall(true);
    payloadProvider.isLiveSynced = true;

    await Future.delayed(const Duration(milliseconds: 1000)); // Optional wait

    while (attempts < 3 && !responseReceived) {
      print("Attempt ${attempts + 1}: Sending live request...");
      mqttService.topicToPublishAndItsMessage(livePayload, topic);

      for (int i = 0; i < 30; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (payloadProvider.isLiveSynced) {
          responseReceived = true;
          break;
        }
      }

      if (!responseReceived) {
        print("No response in attempt ${attempts + 1}");
        attempts++;
      }
    }

    if (!responseReceived) {
      print("No communication after 3 attempts.");
      payloadProvider.isLiveSynced = false;
    }

    payloadProvider.liveSyncCall(false);*/
  }

  bool getPermissionStatusBySNo(BuildContext context, int sNo) {
    return true;
  }

  Future<void> linePauseOrResume(var lineLiveMgs) async {
    String strPRPayload = '';
    bool allPaused = lineLiveMgs.every((line) => line.split(',')[1] == '1');
    for (int i = 0; i < lineLiveMgs.length; i++) {
      final parts = lineLiveMgs[i].split(',');
      final id = parts[0];
      final newValue = allPaused ? '0' : '1';
      strPRPayload += '$id,$newValue;';
    }

    String payloadFinal = jsonEncode({
      "4900": {"4901": strPRPayload}
    });

    final result = await context.read<CommunicationService>().sendCommand(
        serverMsg: allPaused? 'Resumed all line':'Paused all line', payload: payloadFinal);
    if (result['http'] == true) {
      debugPrint("Payload sent to Server");
    }
    if (result['mqtt'] == true) {
      debugPrint("Payload sent to MQTT Box");
    }
    if (result['bluetooth'] == true) {
      debugPrint("Payload sent via Bluetooth");
    }

  }

  Future<void> updateCommunicationMode(int communicationMode, int customerId) async {
    try {
      Map<String, dynamic> body = {
        "userId": customerId,
        "controllerId": mySiteList.data[sIndex].master[mIndex].controllerId,
        "communicationMode": communicationMode,
        "modifyUser": customerId
      };
      final response = await repository.updateControllerCommunicationMode(body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
          customerProvider.updateControllerCommunicationMode(cmmMode: communicationMode);
        }
      }
    } catch (error) {
      errorMsg = 'Error fetching site list: $error';
    }
  }

  @override
  void dispose() {
    super.dispose();
    mqttSubscription?.cancel();
  }

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void onAlarmClicked() {
    //selectedIndex = index;
    //notifyListeners();
  }

}