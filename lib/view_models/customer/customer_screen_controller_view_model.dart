import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../repository/repository.dart';
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
  late String myCurrentMaster;
  String fromWhere = '';
  String myCurrentIrrLine= 'No Line Available';
  int controllerId = 0;
  int wifiStrength = 0;

  late MqttPayloadProvider payloadProvider;
  final MqttService mqttService = MqttService();
  final BuildContext context;
  StreamSubscription<MqttConnectionState>? mqttSubscription;

  bool programRunning = false;

  CustomerScreenControllerViewModel(this.context, this.repository){
    fromWhere='init';
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    mqttConnectionCallbackMethod();
  }

  void mqttConnectionCallbackMethod() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      mqttConfigureAndConnect(context);
      await Future.delayed(const Duration(milliseconds: 300));
      final state = mqttService.isConnected;
      if (state) {
        onSubscribeTopic();
      }
      mqttSubscription ??= mqttService.mqttConnectionStream.listen((state) {
        debugPrint("MQTT Connection Stream: $state");
        if (state == MqttConnectionState.connected) {
          onSubscribeTopic();
        }
      });
    });
  }

  void mqttConfigureAndConnect(BuildContext context) {
    mqttService.initializeMQTTClient(state: payloadProvider);
    mqttService.connect();
  }

  void onSubscribeTopic(){
    Future.delayed(const Duration(milliseconds: 2000), () {
      print("device id :: ${mySiteList.data[sIndex].master[mIndex].deviceId}");
      mqttService.topicToSubscribe('${AppConstants.subscribeTopic}/${mySiteList.data[sIndex].master[mIndex].deviceId}');
      onRefreshClicked();
    });
  }

  Future<void> getAllMySites(context, customerId) async {
    setLoading(true);
    try {
      Map<String, dynamic> body = {"userId": customerId};
      final response = await repository.fetchAllMySite(body);
      print(response.body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          mySiteList = SiteModel.fromJson(jsonData);

          updateMaster(sIndex, mIndex, 0);
          payloadProvider.saveUnits(Unit.toJsonList(mySiteList.data[0].master[0].units));

          var live = mySiteList.data[sIndex].master[mIndex].live;

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

  void masterOnChanged(categoryName, model, index){
   /* int masterIdx = mySiteList.data[sIndex].master.indexWhere((master)=>
    master.categoryName == categoryName && master.modelName == model);*/
    int masterIdx = int.parse(index);
    print("masterIdx :: $masterIdx");
    if (masterIdx != -1 && mySiteList.data[sIndex].master.length > 1) {
      mIndex = masterIdx;
      lIndex = 0;
      fromWhere='master';
      updateMaster(sIndex, masterIdx, 0);
      onSubscribeTopic();
    }
  }

  void lineOnChanged(lineName){
    int lInx = mySiteList.data[sIndex].master[mIndex].config.lineData.indexWhere((line)
    => line.name == lineName);
    if (lInx != -1 && mySiteList.data[sIndex].master[mIndex].config.lineData.length > 1) {
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
    myCurrentMaster = mySiteList.data[sIdx].master[mIdx].categoryName;
    //subscribeCurrentMaster(sIdx, mIdx);
    if(mySiteList.data[sIdx].master[mIdx].categoryId == 1){
      updateMasterLine(sIdx, mIdx, lIdx);
      //displayServerData();
    }else{
      // updateMasterLine(sIdx, mIdx, 0);
      //pump controller
      //MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
      //payloadProvider.updateLastSync('${mySiteList[siteIndex].master[masterIndex].liveSyncDate} ${mySiteList[siteIndex].master[masterIndex].liveSyncTime}');
    }
    notifyListeners();
  }

  void updateMasterLine(sIdx, mIdx, lIdx){
    if(mySiteList.data[sIdx].master[mIdx].config.lineData.isNotEmpty){
      myCurrentIrrLine = mySiteList.data[sIdx].master[mIdx].config.lineData[lIdx].name;
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
    payloadProvider.currentSchedule = cProgram;

    notifyListeners();
  }

  void onRefreshClicked() async {
    if (mqttService.connectionState != MqttConnectionState.connected) {
      mqttConnectionCallbackMethod();
    }else{
      String livePayload = '';
      int attempts = 0;
      payloadProvider.isLiveSynced = false;
      payloadProvider.liveSyncCall(true);

      if (mySiteList.data[sIndex].master[mIndex].categoryId == 1) {
        livePayload = jsonEncode({"3000": {"3001": ""}});
      } else {
        if(attempts != 0) await Future.delayed(const Duration(seconds: 2));
        livePayload = jsonEncode({"sentSms": "#live"});
      }

      final deviceId = mySiteList.data[sIndex].master[mIndex].deviceId;
      final topic = '${AppConstants.publishTopic}/$deviceId';

      Future.delayed(const Duration(milliseconds: 1000), () async {
        while (attempts < 3 && ! payloadProvider.isLiveSynced) {
          print("Attempt ${attempts + 1}: Sent live request");
          mqttService.topicToPublishAndItsMessage(livePayload, topic);
          await Future.delayed(const Duration(seconds: 3));
          if (payloadProvider.isLiveSynced) {
            print("Live response received.");
            payloadProvider.liveSyncCall(false);
          } else {
            attempts++;
          }
        }
      });

      Future.delayed(const Duration(milliseconds: 3000), () {
        payloadProvider.liveSyncCall(false);
      });

      if (!payloadProvider.isLiveSynced) {

      }
    }

  }


  bool getPermissionStatusBySNo(BuildContext context, int sNo) {
    return true;
  }

  void linePauseOrResume(var lineLiveMgs) {
    String strPRPayload = '';

    for (int i = 0; i <lineLiveMgs.length; i++) {
      if (lineLiveMgs.every((line) => line[1] == '1')) {
        strPRPayload += '${lineLiveMgs[i].split(',')[0]},0;';
      } else {
        strPRPayload += '${lineLiveMgs[i].split(',')[0]},1;';
      }
    }
    String payloadFinal = jsonEncode({
      "4900": {"4901": strPRPayload}
    });

    MqttService().topicToPublishAndItsMessage(payloadFinal, '${AppConstants.publishTopic}/${mySiteList.data[sIndex].master[mIndex].deviceId}');

    /*if (payload.payloadIrrLine.every((record) => record.irrigationPauseFlag == 1)) {
      sentToServer('Resumed all line', payloadFinal);
    } else {
      sentToServer('Paused all line', payloadFinal);
    }*/

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