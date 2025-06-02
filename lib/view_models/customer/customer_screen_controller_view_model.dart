import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/customer_provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../repository/repository.dart';
import '../../services/bluetooth_sevice.dart';
import '../../services/communication_service.dart';
import '../../services/mqtt_service.dart';
import '../../utils/constants.dart';

class CustomerScreenControllerViewModel extends ChangeNotifier {
  final Repository repository;
  final BuildContext context;
  final MqttService mqttService = MqttService();
  final BluService blueService = BluService();

  late MqttPayloadProvider mqttProvider;

  bool isLoading = false;
  String errorMsg = '';
  bool programRunning = false;
  bool isChanged = true;

  int selectedIndex = 0;
  int unreadAlarmCount = 2;
  int sIndex = 0, mIndex = 0, lIndex = 0;
  int wifiStrength = 0;
  int powerSupply = 0;
  bool isLiveSynced = false;
  List<String> alarmDL = [];
  List<String> lineLiveMessage = [];

  late String myCurrentSite;
  String fromWhere = '';
  String myCurrentIrrLine = 'No Line Available';

  late SiteModel mySiteList = SiteModel(data: []);
  StreamSubscription<MqttConnectionState>? mqttSubscription;

  List<String> pairedDevices = ['Device A', 'Device B', 'Device C'];

  CustomerScreenControllerViewModel(this.context, this.repository, this.mqttProvider) {
    fromWhere = 'init';
    _initializeMqttConnection();
    mqttProvider.addListener(_onPayloadReceived);
  }


  void _onPayloadReceived() {
    final mqttProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    final liveDateAndTime = mqttProvider.liveDateAndTime;
    final wifiStrength = mqttProvider.wifiStrength;
    final currentSchedule = mqttProvider.currentSchedule;
    lineLiveMessage = mqttProvider.lineLiveMessage;
    powerSupply = mqttProvider.powerSupply;
    isLiveSynced = mqttProvider.isLiveSynced;
    alarmDL = mqttProvider.alarmDL;

    updateLivePayload(wifiStrength, liveDateAndTime, currentSchedule, lineLiveMessage);
  }

  void _initializeMqttConnection() {
    mqttService.initializeMQTTClient(state: mqttProvider);
    mqttService.connect();
    if(!kIsWeb){
      blueService.initializeBluService(state: mqttProvider);
    }

    mqttSubscription = mqttService.mqttConnectionStream.listen((state) {
      switch (state) {
        case MqttConnectionState.connected:
          debugPrint("MQTT Connected! Callback");
          _subscribeToTopic();
          break;
        case MqttConnectionState.connecting:
          debugPrint("MQTT Connecting... Callback");
          break;
        case MqttConnectionState.disconnected:
        default:
          debugPrint("MQTT Disconnected Callback");
          mqttService.connect();
      }
    });
  }

  void _subscribeToTopic() async{
    await Future.delayed(Duration(seconds: 1));
    final deviceId = mySiteList.data[sIndex].master[mIndex].deviceId;
    await mqttService.topicToSubscribe('${AppConstants.subscribeTopic}/$deviceId');
    Future.delayed(const Duration(seconds: 2), () {
      onRefreshClicked();
    });
  }

  Future<void> getAllMySites(BuildContext context, int customerId) async {
    setLoading(true);
    try {
      final response = await repository.fetchAllMySite({"userId": customerId});
      if (response.statusCode == 200) {
        print(response.body);
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          mySiteList = SiteModel.fromJson(jsonData);
          updateSite(sIndex, mIndex, lIndex);

          mqttProvider.saveUnits(Unit.toJsonList(mySiteList.data[sIndex].master[mIndex].units));

          final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
          customerProvider.updateCustomerInfo(customerId: customerId);
          customerProvider.updateControllerCommunicationMode(
            cmmMode: mySiteList.data[sIndex].master[mIndex].communicationMode!,
          );

          final live = mySiteList.data[sIndex].master[mIndex].live;
          mqttProvider.updateReceivedPayload(
            live != null ? jsonEncode(live) : _defaultPayload(),
            true,
          );

          wifiStrength = live?.cM['WifiStrength'] ?? 0;
        }
      }
    } catch (error) {
      errorMsg = 'Error fetching site list: $error';
      debugPrint(errorMsg);
    } finally {
      setLoading(false);
    }
  }

  String _defaultPayload() => '''
  {
    "cC": "00000000",
    "cM": {
      "2401": "", "2402": "", "2403": "", "2404": "", "2405": "", "2406": "", "2407": "", "2408": "",
      "2409": "", "2410": "", "2411": "", "2412": "", "WifiStrength": 0, "Version": "", "PowerSupply": 0
    },
    "cD": "0000-00-00", "cT": "00:00:00", "mC": "2400"
  }''';

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> siteOnChanged(String siteName) async{
    int index = mySiteList.data.indexWhere((site) => site.groupName == siteName);
    if (index != -1) {
      sIndex = index;
      fromWhere = 'site';
      updateSite(index, 0, 0);
    }
    isChanged = false;
    await Future.delayed(const Duration(seconds: 1));
    isChanged = true;
  }

  Future<void> masterOnChanged(int index) async {
    mIndex = index;
    lIndex = 0;
    fromWhere = 'master';
    updateMaster(sIndex, index, lIndex);

    isChanged = false;
    await Future.delayed(const Duration(seconds: 1));
    isChanged = true;
    notifyListeners();
  }

  void lineOnChanged(int lInx) {
    if (mySiteList.data[sIndex].master[mIndex].irrigationLine.length > 1) {
      lIndex = lInx;
      fromWhere = 'line';
      updateMasterLine(sIndex, mIndex, lInx);
    }
  }

  void updateSite(int sIdx, int mIdx, int lIdx) {
    myCurrentSite = mySiteList.data[sIdx].groupName;
    updateMaster(sIdx, mIdx, lIdx);
  }

  void updateMaster(int sIdx, int mIdx, int lIdx) {
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
    customerProvider.updateControllerInfo(
      controllerId: mySiteList.data[sIdx].master[mIdx].controllerId,
      device: mySiteList.data[sIdx].master[mIdx].deviceId,
    );

    if (mySiteList.data[sIdx].master[mIdx].categoryId == 1) {
      updateMasterLine(sIdx, mIdx, lIdx);
    }
    _subscribeToTopic();
    notifyListeners();
  }

  void updateMasterLine(int sIdx, int mIdx, int lIdx) {
    if (mySiteList.data[sIdx].master[mIdx].irrigationLine.isNotEmpty) {
      myCurrentIrrLine = mySiteList.data[sIdx].master[mIdx].irrigationLine[lIdx].name;
      notifyListeners();
    }
  }

  void updateLivePayload(int ws, String liveDataAndTime, List<String> cProgram, List<String> linePauseResume) {

    final parts = liveDataAndTime.split(' ');
    if (parts.length == 2) {
      mySiteList.data[sIndex].master[mIndex].live?.cD = parts[0];
      mySiteList.data[sIndex].master[mIndex].live?.cT = parts[1];
    }

    wifiStrength = ws;
    programRunning = cProgram.isNotEmpty && cProgram[0].isNotEmpty;
    if (programRunning) {
      mqttProvider.currentSchedule = cProgram;
    }

    for (final entry in linePauseResume) {
      final parts = entry.split(',');
      if (parts.length == 2) {
        final serialNo = double.tryParse(parts[0]);
        final flag = int.tryParse(parts[1]);
        if (serialNo != null && flag != null) {
          for (var line in mySiteList.data[sIndex].master[mIndex].irrigationLine) {
            if (line.sNo == serialNo) {
              line.linePauseFlag = flag;
              break;
            }
          }
        }
      }
    }

    notifyListeners();
  }


  Future<void> onRefreshClicked() async {
    final isCategory1 = mySiteList.data[sIndex].master[mIndex].categoryId == 1;
    final payload = isCategory1
        ? jsonEncode({"3000": {"3001": ""}})
        : jsonEncode({"sentSms": "#live"});

    mqttProvider.liveSyncCall(true);

    final result = await context.read<CommunicationService>().sendCommand(serverMsg: '', payload: payload,);

    if (result['http'] == true) debugPrint("Payload sent to Server");
    if (result['mqtt'] == true) debugPrint("Payload sent to MQTT Box");
    if (result['bluetooth'] == true) debugPrint("Payload sent via Bluetooth");

    await Future.delayed(const Duration(seconds: 1));
    mqttProvider.liveSyncCall(false);
  }

  Future<void> linePauseOrResume(List<String> lineLiveMsg) async {
    final allPaused = lineLiveMsg.every((line) => line.split(',')[1] == '1');
    final strPRPayload = '${lineLiveMsg.map((msg) {
      final parts = msg.split(',');
      return '${parts[0]},${allPaused ? '0' : '1'}';
    }).join(';')};';

    final payload = jsonEncode({"4900": {"4901": strPRPayload}});
    final result = await context.read<CommunicationService>().sendCommand(
      serverMsg: allPaused ? 'Resumed all line' : 'Paused all line',
      payload: payload,
    );

    if (result['http'] == true) debugPrint("Payload sent to Server");
    if (result['mqtt'] == true) debugPrint("Payload sent to MQTT Box");
    if (result['bluetooth'] == true) debugPrint("Payload sent via Bluetooth");
  }

  bool getPermissionStatusBySNo(BuildContext context, int sNo) {
    return true;
  }

  void onItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
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

  void disposeMqtt() {
    mqttSubscription?.cancel();
    mqttService.disConnect();
  }


  @override
  void dispose() {
    mqttProvider.removeListener(_onPayloadReceived);
    disposeMqtt();
    super.dispose();
  }
}

/*
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

  void updateLivePayload(int ws, String liveDataAndTime, List<String> cProgram, List<String> linePauseResume) {
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

    for (String entry in linePauseResume) {
      List<String> parts = entry.split(',');
      if (parts.length == 2) {
        double? serialNo = double.tryParse(parts[0]);
        int? flag = int.tryParse(parts[1]);

        if (serialNo != null && flag != null) {
          for (var line in mySiteList.data[sIndex].master[mIndex].irrigationLine) {
            if (line.sNo == serialNo) {
              line.linePauseFlag = flag;
              break;
            }
          }
        }
      }
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

}*/
