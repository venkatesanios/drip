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
  int sIndex = 0, mIndex = 0, lIndex = 0, wifiStrength = 0;
  late String myCurrentSite;
  late String myCurrentMaster;
  String fromWhere = '';
  String myCurrentIrrLine= 'No Line Available';
  int controllerId = 0;

  final mqttService = MqttService();
  late MqttPayloadProvider payloadProvider;

  CustomerScreenControllerViewModel(this.repository, context){

    WidgetsBinding.instance.addPostFrameCallback((_) {
      payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
      mqttConfigureAndConnect(context);
      mqttService.mqttConnectionStream.listen((state) {
        onSubscribeTopic();
      });
    });

    var nodeLiveMessage = Provider.of<MqttPayloadProvider>(context).nodeLiveMessage;
    if(nodeLiveMessage.isNotEmpty){
      print('nodeLiveMessage:$nodeLiveMessage');
    }

   // mqttService.initializeMQTTClient(state: this);
    //mqttService.connect();

    /*mqttService.liveMessageStream.listen((liveMsg) {

      Map<String, dynamic> liveMessage = jsonDecode(liveMsg);
      mySiteList.data[sIndex].master[mIndex].live?.cD = liveMessage['cD'];
      mySiteList.data[sIndex].master[mIndex].live?.cT = liveMessage['cT'];
      mySiteList.data[sIndex].master[mIndex].live?.cM = liveMessage['cM'];
      wifiStrength = liveMessage['cM']['WifiStrength'];

      notifyListeners();
    });*/

  }

  void mqttConfigureAndConnect(BuildContext context) {
    mqttService.initializeMQTTClient(state: payloadProvider);
    mqttService.connect();
  }


  void onSubscribeTopic(){
    Future.delayed(const Duration(milliseconds: 2000), () {
      MqttService().topicToSubscribe('${AppConstants.subscribeTopic}/${mySiteList.data[sIndex].master[mIndex].deviceId}');
      onRefreshClicked();
    });
  }



  Future<void> getAllMySites(customerId) async {
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
    /*subscribeCurrentMaster(sIdx, mIdx);
    if(mySiteList[sIdx].master[mIdx].categoryId == 1 ||
        mySiteList[sIdx].master[mIdx].categoryId == 2){
      updateMasterLine(sIdx, mIdx, lIdx);
      displayServerData();
    }else{
      //pump controller
      MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
      payloadProvider.updateLastSync('${mySiteList[siteIndex].master[masterIndex].liveSyncDate} ${mySiteList[siteIndex].master[masterIndex].liveSyncTime}');
    }*/
    notifyListeners();
  }

  void updateMasterLine(sIdx, mIdx, lIdx){
    // if(mySiteList.data[sIdx].master[mIdx].config.lineData.isNotEmpty){
    //   myCurrentIrrLine = mySiteList.data[sIdx].master[mIdx].config.lineData[lIdx].name;
    //   notifyListeners();
    // }
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


}