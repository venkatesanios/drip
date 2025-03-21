import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
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

  late SiteModel mySiteList = SiteModel(data: []);
  int sIndex = 0, mIndex = 0, lIndex = 0;
  late String myCurrentSite;
  late String myCurrentMaster;
  String fromWhere = '';
  String myCurrentIrrLine= 'No Line Available';
  int controllerId = 0;
  int wifiStrength = 0;

  final mqttService = MqttService();
  late MqttPayloadProvider payloadProvider;

  CustomerScreenControllerViewModel(context, this.repository){
    fromWhere='init';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
      mqttConfigureAndConnect(context);
      mqttService.mqttConnectionStream.listen((state) {
        onSubscribeTopic();
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
      MqttService().topicToSubscribe('${AppConstants.subscribeTopic}/${mySiteList.data[sIndex].master[mIndex].deviceId}');
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
          wifiStrength = mySiteList.data[sIndex].master[mIndex].live?.cM['WifiStrength'];
          updateMaster(sIndex, mIndex, 0);
          payloadProvider.saveUnits(Unit.toJsonList(mySiteList.data[0].master[0].units));

          String liveJson = jsonEncode(mySiteList.data[sIndex].master[mIndex].live);
          payloadProvider.updateReceivedPayload(liveJson, true);

        }
      }
    } catch (error) {
      errorMsg = 'Error fetching site list: $error';
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool value) {
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

  void masterOnChanged(categoryName){
    int masterIdx = mySiteList.data[sIndex].master.indexWhere((master)=>
    master.categoryName == categoryName);
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

  void updateLivePayload(int ws, String liveDataAndTime){

    payloadProvider.wifiStrength = 0;
    payloadProvider.liveDateAndTime = '';

    List<String> parts = liveDataAndTime.split(' ');
    String date = parts[0];
    String time = parts[1];
    mySiteList.data[sIndex].master[mIndex].live?.cD = date;
    mySiteList.data[sIndex].master[mIndex].live?.cT = time;
    wifiStrength = ws;

    notifyListeners();
  }

  void onRefreshClicked() {
    String livePayload = '';
    Future.delayed(const Duration(milliseconds: 1000), () {
      //payloadProvider.liveSyncCall(true);
      if(mySiteList.data[sIndex].master[mIndex].categoryId==1 ||
          mySiteList.data[sIndex].master[mIndex].categoryId==2){
        livePayload = jsonEncode({"3000": {"3001": ""}});
      }else{
        livePayload = jsonEncode({"sentSMS": "#live"});
      }
      MqttService().topicToPublishAndItsMessage(livePayload, '${AppConstants.publishTopic}/${mySiteList.data[sIndex].master[mIndex].deviceId}');
    });

    /*Future.delayed(const Duration(milliseconds: 6000), () {
      //payloadProvider.liveSyncCall(false);
    });*/
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


}