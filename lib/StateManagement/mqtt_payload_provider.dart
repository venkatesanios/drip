import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../Constants/data_convertion.dart';
import '../Models/Weather_model.dart';
import '../Models/customer/site_model.dart';
import '../Screens/Map/googlemap_model.dart';
import '../services/bluetooth_sevice.dart';

enum MQTTConnectionState { connected, disconnected, connecting }

class MqttPayloadProvider with ChangeNotifier {
   MQTTConnectionState _appConnectionState = MQTTConnectionState.disconnected;
  // SiteModel dashboardLiveInstance = SiteModel(data: data);
  SiteModel? _dashboardLiveInstance;
  SiteModel? get dashboardLiveInstance => _dashboardLiveInstance;
  dynamic spa = '';
  String dashBoardPayload = '', schedulePayload = '';
  WeatherModel weatherModelinstance = WeatherModel();
  MapConfigModel mapModelInstance = MapConfigModel();

  Map<String, dynamic> pumpControllerPayload = {};
  List viewSettingsList = [];
  List cCList = [];
  Map<String, dynamic> viewSetting = {};
  int dataFetchingStatus = 2;
  List<dynamic> unitList = [];

  //Todo : Dashboard start
  int tryingToGetPayload = 0;
  dynamic listOfSite = [];
  dynamic listOfSharedUser = {};
  bool httpError = false;
  String selectedSiteString = '';
  int selectedSite = 0;
  int selectedMaster = 0;
  int selectedLine = 0;
  List<dynamic> nodeDetails = [];
  dynamic messageFromHw;
  dynamic proogressstatus = '0';
  //List<dynamic> currentSchedule = [];
  List<dynamic> PrsIn = [];
  List<dynamic> PrsOut = [];
  List<dynamic> nextScheduleA = [];
  List<dynamic> upcomingProgram = [];
  List<dynamic> filtersCentral = [];
  List<dynamic> filtersLocal = [];
  List<dynamic> irrigationPump = [];
  List<dynamic> sourcePump = [];
  List<dynamic> sourcetype = [];
  List<dynamic> fertilizerCentral = [];
  List<dynamic> fertilizerLocal = [];
  List<dynamic> flowMeter = [];
  List<dynamic> alarmList = [];
  List<dynamic> waterMeter = [];
  List<dynamic> sensorInLines = [];
  List<dynamic> lineData = [];
  String subscribeTopic = '';
  String publishTopic = '';
  String publishMessage= '';
  bool loading = false;
  int active = 1;
  Timer? timerForIrrigationPump;
  List<dynamic> sensorLogData = [];
  Timer? timerForSourcePump;
  Timer? timerForCentralFiltration;
  Timer? timerForLocalFiltration;
  Timer? timerForCentralFertigation;
  Timer? timerForLocalFertigation;
  Timer? timerForCurrentSchedule;
  int selectedCurrentSchedule = 0;
  int selectedNextSchedule = 0;
  int selectedProgram = 0;
  DateTime lastUpdate = DateTime.now();
  String sheduleLog = '';
  String uardLog = '';
  String uard0Log = '';
  String uard4Log = '';
  String ctrllogtimecheck = '';
  List<dynamic> userPermission = [];
  List<dynamic> units = [];
   Map<String, dynamic> mqttUpdateSettings = {};
   Set<String> scheduleMessagesSet = {};
   Set<String> uardMessagesSet = {};
   Set<String> uard0MessagesSet = {};
   Set<String> uard4MessagesSet = {};
   String Loara1verssion = '';
   String Loara2verssion = '';
   bool ftpLog = false;

  //kamaraj
   String _receivedPayload = '';
   String get receivedPayload => _receivedPayload;

  int powerSupply = 0;
  bool onRefresh = false;
  int wifiStrength = 0;
  String liveDateAndTime = '';
  String activeDeviceId = '';
  String activeDeviceVersion = '0.0.0';
  String activeLoraData = '';


  String liveControllerID = '';
  List<String> nodeLiveMessage = [];
  List<String> outputOnOffPayload = [];
  List<String> currentSchedule = [];
  List<String> nextSchedule = [];
  List<String> scheduledProgramPayload = [];
   List<String> conditionPayload = [];
  List<String> lineLiveMessage = [];
  List<String> alarmDL = [];

   final Map<String, String> _pumpOnOffStatusMap = {};
   final Map<String, String> _pumpOtherDetailMap = {};
   final Map<String, String> _filterOnOffStatusMap = {};
   final Map<String, String> _filterOtherDetailMap = {};
   final Map<String, String> _channelOnOffStatusMap = {};
   final Map<String, String> _channelOtherDetailMap = {};
   final Map<String, String> _valveOnOffStatusMap = {};
   final Map<String, String> _lightOnOffStatusMap = {};
   final Map<String, String> _gateOnOffStatusMap = {};
   final Map<String, String> _sensorValueMap = {};
   final Map<String, String> _boosterPumpOnOffStatusMap = {};
   final Map<String, String> _agitatorOnOffStatusMap = {};


   //for blue repository
   CustomDevice? _connectedDevice;
   CustomDevice? get connectedDevice => _connectedDevice;

   List<CustomDevice> _pairedDevices = [];
   List<CustomDevice> get pairedDevices => _pairedDevices;


   List<Map<String, dynamic>> _wifiList = [];
   List<Map<String, dynamic>> get wifiList => _wifiList;

   String? _wifiMessage;
   String? get wifiMessage => _wifiMessage;

   String? _wifiStatus;
   String? get wifiStatus => _wifiStatus;

   bool wifiStateChanging = false;

   String? _interfaceType;
   String? get interfaceType => _interfaceType;

   String? _ipAddress;
   String? get ipAddress => _ipAddress;
   List<String> traceLog = [];
   bool isTraceLoading = false;
   int traceLogSize = 0;
   int totalTraceLogSize = 0;

   void updateConnectedDeviceStatus(CustomDevice? device) {
     _connectedDevice = device;
     notifyListeners();
   }

   void updatePairedDevices(List<CustomDevice> devices) {
     _pairedDevices = devices;
     notifyListeners();
   }


   void updateDeviceStatus(String address, int status) {
     for (var device in _pairedDevices) {
       if (device.device.address == address) {
         if (status >= 0 && status < BluDevice.values.length) {
           device.status = BluDevice.values[status];
           notifyListeners();
         } else {
           print('Invalid status int: $status');
         }
         break;
       }
     }
   }

   /*void updateDeviceStatus(String address, int status) {
     for (var device in _pairedDevices) {
       if (device.device.address == address) {
         device.status = status;
         notifyListeners();
         break;
       }
     }
   }*/

   void updateWifiList(List<Map<String, dynamic>> list) {
     _wifiList = list;
     notifyListeners();
   }

   void updateInterfaceType(String interfaceType) {
     _interfaceType = interfaceType;
     notifyListeners();
   }

   void updateIpAddress(String ip) {
     _ipAddress = ip;
     notifyListeners();
   }



   void updateWifiStatus(String status, bool loading) {
     _wifiStatus = status;
     wifiStateChanging = loading;
     notifyListeners();
   }


   void updateWifiMessage(String? message) {
     _wifiMessage = message;
     notifyListeners();
   }

   void clearWifiMessage() {
     _wifiMessage = null;
     notifyListeners();
   }

  void updateMapData(data){
     mapModelInstance = MapConfigModel.fromJson(data);
    notifyListeners();
  }

  void editSensorLogData(data){
    sensorLogData = data;
    notifyListeners();
  }

  void editLoading(bool value){
    loading = value;
    notifyListeners();
  }

  void editPublishMessage(String message){
    publishMessage = message;
    notifyListeners();
  }

  void editSubscribeTopic(String topic){
    subscribeTopic = topic;
    notifyListeners();
  }

  void editPublishTopic(String topic){
    publishTopic = topic;
    notifyListeners();
  }
   void setTraceLoading(bool loading) {
     isTraceLoading = loading;
     notifyListeners();
   }
   void setTraceLoadingsize(int size) {
     traceLogSize = size;
      notifyListeners();
   }
   void setTotalTraceSize(int size) {
     totalTraceLogSize = size;
     notifyListeners();
   }


  void editLineData(dynamic data){
    lineData = [];
    for(var i in data){
      lineData.add(i);
    }
    lineData.insert(0,{'id' : 'All','location' : '','mode' : 0,'name' : 'All line','mainValve' : [],'valve' : []});
    for(var i in lineData){
      i['mode'] = 0;
    }
    notifyListeners();
  }

  void updateLocalFertigationSite(){
    if(timerForLocalFertigation != null){
      timerForLocalFertigation!.cancel();
    }
    int seconds = 0;
    DataConvert dataConvert = DataConvert();
    timerForLocalFertigation = Timer.periodic(Duration(milliseconds: 100), (Timer timer){
      if(seconds == 1000){
        seconds = 0;
      }else{
        seconds += 100;
      }
      if(fertilizerLocal.any((element) => element['Fertilizer'].any((fert) => dataConvert.parseTimeStringForMilliSeconds(fert['Duration']) != dataConvert.parseTimeStringForMilliSeconds(fert['DurationCompleted'])))){
        for(var i in fertilizerLocal) {
          if (i['Fertilizer'].any((element) => element['Status'] != 0)){
            for(var channel in i['Fertilizer']){
              if(channel['Status'] != 0){
                int onDelay = dataConvert.parseTimeStringForMilliSeconds(channel['Duration']);
                if(channel['DurationCompleted'] == null){
                  channel['DurationCompleted'] = '00:00:00:000';
                }
                int onDelayCompleted = dataConvert.parseTimeStringForMilliSeconds(channel['DurationCompleted']);
                int leftDelay = onDelay - onDelayCompleted;
                channel['DurationLeft'] = dataConvert.formatTimeForMilliSeconds(leftDelay);
                if(leftDelay > 0){
                  onDelayCompleted += 100;
                  if(['1','2'].contains(channel['FertMethod'])){
                    if(channel['Status'] == 1){
                      channel['DurationCompleted'] = dataConvert.formatTimeForMilliSeconds(onDelayCompleted);
                      if(channel['QtyLeft'] > 0.0){
                        channel['QtyLeft'] = double.parse(channel['Qty']) - double.parse(channel['QtyCompleted']);
                        channel['QtyCompleted']  = '${(double.parse(channel['QtyCompleted'])) + (channel['FlowRate'] / 10)}';
                      }
                    }
                  }
                  else if(['3','4','5'].contains(channel['FertMethod'])){
                    if(channel['onOffMode'] == null){
                      channel['onOffMode'] = 1;
                      channel['onOffValue'] = 0;
                    }
                    if(channel['onOffMode'] == 1){
                      channel['onOffValue'] += 100;
                      if(channel['proportionalStatus'] == 1){
                        channel['Status'] = channel['proportionalStatus'];
                      }
                      if(channel['proportionalStatus'] == 1){
                        channel['DurationCompleted'] = dataConvert.formatTimeForMilliSeconds(onDelayCompleted);
                        if(channel['QtyLeft'] > 0.0){
                          channel['QtyLeft'] = double.parse(channel['Qty']) - double.parse(channel['QtyCompleted']);
                          channel['QtyCompleted']  = '${(double.parse(channel['QtyCompleted'])) + (channel['FlowRate'] / 10)}';
                        }
                      }
                      if(channel['onOffValue'] == (double.parse(channel['OnTime']) * 1000)){
                        channel['onOffMode'] = 0;
                        channel['onOffValue'] = 0;
                      }
                    }else{
                      if(channel['proportionalStatus'] == 1){
                        channel['Status'] = 4;
                      }
                      channel['onOffValue'] += 100;
                      if(channel['onOffValue'] == (double.parse(channel['OffTime']) * 1000)){
                        channel['onOffMode'] = 1;
                        channel['onOffValue'] = 0;
                      }
                    }
                  }

                }else{
                  channel['DurationCompleted'] = channel['Duration'];
                }
                notifyListeners();
              }
            }

          }
        }
      }
      // else{
      //   if(timerForLocalFertigation != null){
      //     timerForLocalFertigation!.cancel();
      //   }
      // }
    });
  }

  void updateCentralFertigationSite(){
    if(timerForCentralFertigation != null){
      timerForCentralFertigation!.cancel();
    }
    int seconds = 0;
    DataConvert dataConvert = DataConvert();
    timerForCentralFertigation = Timer.periodic(Duration(milliseconds: 100), (Timer timer){
      if(seconds == 1000){
        seconds = 0;
      }else{
        seconds += 100;
      }
      if(fertilizerCentral.any((element) => element['Fertilizer'].any((fert) => dataConvert.parseTimeStringForMilliSeconds(fert['Duration']) != dataConvert.parseTimeStringForMilliSeconds(fert['DurationCompleted'])))){
        for(var i in fertilizerCentral) {
          if (i['Fertilizer'].any((element) => element['Status'] != 0)){
            for(var channel in i['Fertilizer']){
              if(channel['Status'] != 0){
                int onDelay = dataConvert.parseTimeStringForMilliSeconds(channel['Duration']);
                if(channel['DurationCompleted'] == null){
                  channel['DurationCompleted'] = '00:00:00:000';
                }
                int onDelayCompleted = dataConvert.parseTimeStringForMilliSeconds(channel['DurationCompleted']);
                int leftDelay = onDelay - onDelayCompleted;
                channel['DurationLeft'] = dataConvert.formatTimeForMilliSeconds(leftDelay);
                if(leftDelay > 0){
                  onDelayCompleted += 100;
                  if(['1','2'].contains(channel['FertMethod'])){
                    if(channel['Status'] == 1){
                      channel['DurationCompleted'] = dataConvert.formatTimeForMilliSeconds(onDelayCompleted);
                      if(channel['QtyLeft'] > 0.0){
                        channel['QtyLeft'] = double.parse(channel['Qty']) - double.parse(channel['QtyCompleted']);
                        channel['QtyCompleted']  = '${(double.parse(channel['QtyCompleted'])) + (channel['FlowRate'] / 10)}';
                      }
                    }
                  }
                  else if(['3','4','5'].contains(channel['FertMethod'])){
                    if(channel['onOffMode'] == null){
                      channel['onOffMode'] = 1;
                      channel['onOffValue'] = 0;
                    }
                    if(channel['onOffMode'] == 1){
                      channel['onOffValue'] += 100;
                      if(channel['proportionalStatus'] == 1){
                        channel['Status'] = channel['proportionalStatus'];
                      }
                      if(channel['proportionalStatus'] == 1){
                        channel['DurationCompleted'] = dataConvert.formatTimeForMilliSeconds(onDelayCompleted);
                        if(channel['QtyLeft'] > 0.0){
                          channel['QtyLeft'] = double.parse(channel['Qty']) - double.parse(channel['QtyCompleted']);
                          channel['QtyCompleted']  = '${(double.parse(channel['QtyCompleted'])) + (channel['FlowRate'] / 10)}';
                        }
                      }
                      if(channel['onOffValue'] == (double.parse(channel['OnTime']) * 1000)){
                        channel['onOffMode'] = 0;
                        channel['onOffValue'] = 0;
                      }
                    }else{
                      if(channel['proportionalStatus'] == 1){
                        channel['Status'] = 4;
                      }
                      channel['onOffValue'] += 100;
                      if(channel['onOffValue'] == (double.parse(channel['OffTime']) * 1000)){
                        channel['onOffMode'] = 1;
                        channel['onOffValue'] = 0;
                      }
                    }
                  }
                }else{
                  channel['DurationCompleted'] = channel['Duration'];
                }
                notifyListeners();
              }
            }

          }
        }
      }
    });
  }

  void updateCentralFiltrationSite(){
    if(timerForCentralFiltration != null){
      timerForCentralFiltration!.cancel();
    }
    DataConvert dataConvert = DataConvert();
    timerForCentralFiltration = Timer.periodic(Duration(seconds: 1), (Timer timer){
      for(var i in filtersCentral){
        if(i['Status'] != 0 && i['Program'] != ''){
          int onDelay = dataConvert.parseTimeString(i['Duration']);
          if(i['DurationCompleted'] == null){
            i['DurationCompleted'] = '00:00:00';
          }
          int onDelayCompleted = dataConvert.parseTimeString(i['DurationCompleted']);
          int leftDelay = onDelay - onDelayCompleted;
          i['DurationLeft'] = dataConvert.formatTime(leftDelay);
          if(leftDelay > 0){
            onDelayCompleted += 1;
            i['DurationCompleted'] = dataConvert.formatTime(onDelayCompleted);
          }else{
            i['DurationCompleted'] = '00:00:00';
            timerForCentralFiltration!.cancel();
          }
        }
      }

    });
  }

  void updateLocalFiltrationSite(){
    if(timerForLocalFiltration != null){
      timerForLocalFiltration!.cancel();
    }
    DataConvert dataConvert = DataConvert();
    timerForLocalFiltration = Timer.periodic(Duration(seconds: 1), (Timer timer){
      for(var i in filtersLocal){
        if(i['Status'] != 0 && i['Program'] != ''){
          int onDelay = dataConvert.parseTimeString(i['Duration']);
          if(i['DurationCompleted'] == null){
            i['DurationCompleted'] = '00:00:00';
          }
          int onDelayCompleted = dataConvert.parseTimeString(i['DurationCompleted']);
          int leftDelay = onDelay - onDelayCompleted;
          i['DurationLeft'] = dataConvert.formatTime(leftDelay);
          if(leftDelay > 0){
            onDelayCompleted += 1;
            i['DurationCompleted'] = dataConvert.formatTime(onDelayCompleted);
          }else{
            i['DurationCompleted'] = '00:00:00';
            timerForLocalFiltration!.cancel();
          }
        }
      }

    });
  }

  void updateIrrigationPump(){
    if(timerForIrrigationPump != null){
      timerForIrrigationPump!.cancel();
    }
    DataConvert dataConvert = DataConvert();
    timerForIrrigationPump = Timer.periodic(Duration(seconds: 1), (Timer timer){
      for(var i in irrigationPump){
        if(i['Status'] != 1 && i['Program'] != ''){
          if(i['OnDelay'] != i['OnDelayCompleted'] && i['OnDelayLeft'] != '00:00:00'){
            int onDelay = dataConvert.parseTimeString(i['OnDelay']);
            int onDelayCompleted = dataConvert.parseTimeString(i['OnDelayCompleted']);
            int leftDelay = onDelay - onDelayCompleted;
            i['OnDelayLeft'] = dataConvert.formatTime(leftDelay);
            if(leftDelay > 0){
              onDelayCompleted += 1;
              i['OnDelayCompleted'] = dataConvert.formatTime(onDelayCompleted);
            }else{
              i['OnDelayCompleted'] = '00:00:00';
            }
          }
        }
      }
      if(irrigationPump.every((element) => element['OnDelayCompleted'] == '00:00:00')){
        timerForIrrigationPump!.cancel();
      }
    });

  }

  void clearData() {
    listOfSite = [];
    listOfSharedUser = {};
    currentSchedule = [];
      nextSchedule = [];
    selectedLine = 0;
    selectedSite = 0;
    selectedMaster = 0;
     irrigationPump = [];
    sourcePump = [];
     sensorInLines = [];
    lineData = [];
    loading = false;
    active = 1;
    if(timerForIrrigationPump != null){
      timerForIrrigationPump!.cancel();
      timerForSourcePump!.cancel();
      timerForCentralFiltration!.cancel();
      timerForLocalFiltration!.cancel();
      timerForCentralFertigation!.cancel();
      timerForLocalFertigation!.cancel();
      timerForCurrentSchedule!.cancel();
    }

    selectedCurrentSchedule = 0;
    selectedNextSchedule = 0;
    selectedProgram = 0;
    // pumpControllerData = null;
    lastUpdate = DateTime.now();
    notifyListeners();
  }

  void updateSourcePump(){
    if(timerForSourcePump != null){
      timerForSourcePump!.cancel();
    }
    DataConvert dataConvert = DataConvert();
    timerForSourcePump = Timer.periodic(Duration(seconds: 1), (Timer timer){
      for(var i in sourcePump){
        if((i['Status'] != 1 && i['Program'] != '') || (i['Status'] == 2 && i['OnDelayLeft'] != '00:00:00')){
          int onDelay = dataConvert.parseTimeString(i['OnDelay']);
          int onDelayCompleted = dataConvert.parseTimeString(i['OnDelayCompleted']);
          int leftDelay = onDelay - onDelayCompleted;
          i['OnDelayLeft'] = dataConvert.formatTime(leftDelay);
          if(leftDelay > 0){
            onDelayCompleted += 1;
            i['OnDelayCompleted'] = dataConvert.formatTime(onDelayCompleted);
          }else{
            i['OnDelayCompleted'] = '00:00:00';
          }
        }
      }
      if(sourcePump.every((element) => element['OnDelayCompleted'] == '00:00:00')){
        timerForSourcePump!.cancel();
      }
    });

  }

   void updateLastSyncDateFromPumpControllerPayload(String payload) async{

     if (_receivedPayload != payload) {
       _receivedPayload = payload;

       try {
         Map<String, dynamic> data = _receivedPayload.isNotEmpty ? jsonDecode(
             _receivedPayload) : {};
         print('_pcReceivedPayload------>:$_receivedPayload');

         liveDateAndTime = '${data['cD']} ${data['cT']}';
         activeDeviceId = data['cC'];

         notifyListeners();
       }
       catch (e, stackTrace) {
         print('Error parsing JSON: $e');
         print('Stacktrace while parsing json : $stackTrace');
       }

     }
   }


  void updateReceivedPayload(String newPayload, bool dataFromHttp) async{
    if (_receivedPayload != newPayload) {
       _receivedPayload = newPayload;
       if(!dataFromHttp) {
        dataFetchingStatus = 1;
      } else {
        dataFetchingStatus = 3;
      }

      try {
        Map<String, dynamic> data = _receivedPayload.isNotEmpty? jsonDecode(_receivedPayload) : {};
        print('_receivedPayload------>:$_receivedPayload');

        if(data['mC']=='2400'){
          liveDateAndTime = '${data['cD']} ${data['cT']}';
          activeDeviceId = data['cC'];
          activeDeviceVersion = data['cM']['Version'];
          if (data['cM'].containsKey('LoraData')) {
            activeLoraData = data['cM']['LoraData'];
          }

          wifiStrength = data['cM']['WifiStrength'];
          powerSupply = data['cM']['PowerSupply'];

          updateNodeLiveMessage(data['cM']['2401'].split(";"));
          updateOutputStatusPayload(data['cM']['2402'].split(";"));

          updateAllPumpPayloads(data['cM']['2402'].split(";"), data['cM']['2404'].split(";"));
          updateFilterSitePayloads(data['cM']['2402'].split(";"), data['cM']['2406'].split(";"));
          updateFertilizerSitePayloads(data['cM']['2402'].split(";"), data['cM']['2407'].split(";"));

          updateValveStatus(data['cM']['2402'].split(";"));
          updateLightStatus(data['cM']['2402'].split(";"));
          updateSensorValue(data['cM']['2403'].split(";"));
          updateBoosterPumpStatus(data['cM']['2402'].split(";"));
          updateAgitatorStatus(data['cM']['2402'].split(";"));

          updateLineLiveMessage(data['cM']['2405'].split(";"));
          updateCurrentProgram(data['cM']['2408'].split(";"));
          updateNextProgram(data['cM']['2409'].split(";"));
          updateScheduledProgram(data['cM']['2410'].split(";"));
          updateCondition(data['cM']['2411'].split(";"));
          updateAlarm(data['cM']['2412'].split(";"));
          notifyListeners();
        }

        else if(data.containsKey('3600') && data['3600'] != null && data['3600'].isNotEmpty){
          schedulePayload = _receivedPayload;
        }
        else if(data.containsKey('5100') && data['5100'] != null && data['5100'].isNotEmpty){
          weatherModelinstance = WeatherModel.fromJson(data);
        }
        else if(data['mC'] != null && data["mC"].contains("VIEW")) {
          cCList = {...cCList, data['cC']}.toList();
          viewSetting = data;
          if (!viewSettingsList.contains(jsonEncode(data['cM']))) {
            viewSettingsList.add(jsonEncode(data["cM"]));
          }
        }
        if(data['cM'] is! List<dynamic>) {
          if (data['mC'] != null && data['cM'].containsKey('4201')) {
            messageFromHw = data['cM']['4201'];
          }
        }
        if(data['cM'] is! List<dynamic>) {
          print('2903 call');
          if (data['mC'] != null && data['cM'].containsKey('4201'))
            {
          if (data['cM']['4201']['PayloadCode'] == '2903') {
            print('2903');
            proogressstatus = data['cM']['4201']['Status'];
            print('2903data:${data['cM']['4201']['Status']}');
          }
        }
        }
        if (data.containsKey("cM") && data["cM"] is! List) {
          Map cM = data["cM"];
          if (cM.containsKey("6601")) {
            String msg = cM["6601"];
            if (!scheduleMessagesSet.contains(msg)) {
              sheduleLog += "\n$msg";
              scheduleMessagesSet.add(msg);
            }
          }

          if (cM.containsKey("6602")) {

            String msg = cM["6602"];
            if (!uardMessagesSet.contains(msg)) {
              uardLog += "\n" + msg;
              uardMessagesSet.add(msg);
            }
          }

          if (cM.containsKey("6603")) {
            String msg = cM["6603"];
            if (!uard0MessagesSet.contains(msg)) {
              uard0Log += "\n" + msg;
              uard0MessagesSet.add(msg);
            }
          }

          if (cM.containsKey("6604")) {
            String msg = cM["6604"];
            if (!uard4MessagesSet.contains(msg)) {
              uard4Log += "\n" + msg;
              uard4MessagesSet.add(msg);
            }
          }

        }

        if(data['mC']=='7400'){

         String Loaraverssion = data['cM']['7401'];
         final parts = Loaraverssion.split(',');
         if(parts[0] == '1')
           {
             final rawFrequency = int.parse(parts[2]);
             final frequency = (rawFrequency / 10).toStringAsFixed(1);

             Loara1verssion = "Verssion:${parts[1]},Frequency:$frequency,SF:${parts[3]}";
           }
         else
           {
             final rawFrequency = int.parse(parts[2]);
             final frequency = (rawFrequency / 10).toStringAsFixed(1);
             Loara2verssion = "Verssion:${parts[1]},Frequency:$frequency,SF:${parts[3]}";
           }

        }

      } catch (e, stackTrace) {
        print('Error parsing JSON: $e');
        print('Stacktrace while parsing json : $stackTrace');
      }
      finally{
        notifyListeners();
      }
    }


    if(irrigationPump.isEmpty){
      loading = true;
    }else{
      loading = false;
    }
    tryingToGetPayload = 0;


    updateSourcePump();
    updateIrrigationPump();
    updateLocalFertigationSite();
    updateCentralFertigationSite();
    updateCentralFiltrationSite();
    updateLocalFiltrationSite();
  }




  //Todo : Dashboard stop

  Future<void> updateDashboardPayload(Map<String, dynamic> payload) async{
    _dashboardLiveInstance = SiteModel.fromJson(payload);

    notifyListeners();
  }

  Timer? _timerForPumpController;

  void updatePumpController(){
    if(_timerForPumpController != null){
      _timerForPumpController!.cancel();
    }
    _timerForPumpController = Timer.periodic(const Duration(seconds: 1), (Timer timer){
     });
  }
   void updatetracelog(status){

     traceLog = status;
     notifyListeners();
   }


  void liveSyncCall(status){
    onRefresh = status;
    notifyListeners();
  }

  void updateNodeLiveMessage(List<String> message) {
    nodeLiveMessage = message;
  }

  void updateLineLiveMessage(List<String> message) {
    lineLiveMessage = message;
  }

  void updateOutputStatusPayload(List<String> message) {
    outputOnOffPayload = message;
  }


   void updateAllPumpPayloads(List<String> pumpStatusPayload, List<String> pumpOtherPayload) {
     for (final entry in pumpStatusPayload) {
       if (!entry.startsWith('5.')) continue;
       final parts = entry.split(',');
       if (parts.isEmpty || parts[0].trim().isEmpty) continue;
       final sNo = parts[0].trim();
       _pumpOnOffStatusMap[sNo] = entry;
     }

     for (final entry in pumpOtherPayload) {
       final parts = entry.split(',');
       if (parts.isEmpty || parts[0].trim().isEmpty) continue;
       final sNo = parts[0].trim();
       _pumpOtherDetailMap[sNo] = entry;
     }
   }

   void updateFilterSitePayloads(List<String> filterStatusPayload, List<String> filterOtherPayload) {
     for (final entry in filterStatusPayload) {
       if (!entry.startsWith('11.')) continue;
       final parts = entry.split(',');
       if (parts.isEmpty || parts[0].trim().isEmpty) continue;
       final sNo = parts[0].trim();
       _filterOnOffStatusMap[sNo] = entry;
     }

     for (final entry in filterOtherPayload) {
       final parts = entry.split(',');
       if (parts.isEmpty || parts[0].trim().isEmpty) continue;
       final sNo = parts[0].trim();
       _filterOtherDetailMap[sNo] = entry;
     }
   }

   void updateFertilizerSitePayloads(List<String> channelStatusPayload, List<String> channelOtherPayload) {
     for (final entry in channelStatusPayload) {
       if (!entry.startsWith('10.')) continue;
       final parts = entry.split(',');
       if (parts.isEmpty || parts[0].isEmpty) continue;
       final sNo = parts[0];
       _channelOnOffStatusMap[sNo] = entry;
     }

     for (final entry in channelOtherPayload) {
       final parts = entry.split(',');
       if (parts.isEmpty || parts[0].isEmpty) continue;
       final sNo = parts[0];
       _channelOtherDetailMap[sNo] = entry;
     }
   }

   void updateValveStatus(List<String> valveOnOffPayload) {
     for (final entry in valveOnOffPayload) {
       if (!entry.startsWith('13.')) continue;
       final parts = entry.split(',');
       if (parts.isEmpty || parts[0].isEmpty) continue;
       final sNo = parts[0];
       _valveOnOffStatusMap[sNo] = entry;
     }
   }

   void updateGateStatus(List<String> gateOnOffPayload) {
     for (final entry in gateOnOffPayload) {
       if (!entry.startsWith('43.')) continue;
       final parts = entry.split(',');
       if (parts.isEmpty || parts[0].isEmpty) continue;
       final sNo = parts[0];
       _gateOnOffStatusMap[sNo] = entry;
     }
   }

   void updateLightStatus(List<String> lightOnOffPayload) {
     for (final entry in lightOnOffPayload) {
       if (!entry.startsWith('19.')) continue;
       final parts = entry.split(',');
       if (parts.isEmpty || parts[0].isEmpty) continue;
       final sNo = parts[0];
       _lightOnOffStatusMap[sNo] = entry;
     }
   }

   void updateSensorValue(List<String> sensorValuePayload) {
     for (final entry in sensorValuePayload) {
       final parts = entry.split(',');
       if (parts.isEmpty || parts[0].isEmpty) continue;
       final sNo = parts[0];
       _sensorValueMap[sNo] = entry;
     }
   }

   void updateBoosterPumpStatus(List<String> valveOnOffPayload) {
     for (final entry in valveOnOffPayload) {
       if (!entry.startsWith('7.')) continue;
       final parts = entry.split(',');
       if (parts.isEmpty || parts[0].isEmpty) continue;
       final sNo = parts[0];
       _boosterPumpOnOffStatusMap[sNo] = entry;
     }
   }

   void updateAgitatorStatus(List<String> status) {
     for (final entry in status) {
       if (!entry.startsWith('9.')) continue;
       final parts = entry.split(',');
       if (parts.isEmpty || parts[0].isEmpty) continue;
       final sNo = parts[0];
       _agitatorOnOffStatusMap[sNo] = entry;
     }
   }

  void updateCurrentProgram(List<String> program) {
    currentSchedule = program;
  }

  void updateNextProgram(List<String> program) {
    nextSchedule = program;
  }

   void updateAlarm(List<String> alm) {
     alarmDL = alm;
   }

  void updateScheduledProgram(List<String> program) {
    scheduledProgramPayload = program;
  }

   void updateCondition(List<String> con) {
     conditionPayload = con;
   }

  void saveUnits(List<dynamic> units) {
    unitList = units;
  }


   String? getPumpOnOffStatus(String sNo) => _pumpOnOffStatusMap[sNo];
   String? getPumpOtherData(String sNo) => _pumpOtherDetailMap[sNo];
   String? getFilterOnOffStatus(String sNo) => _filterOnOffStatusMap[sNo];
   String? getFilterOtherData(String sNo) => _filterOtherDetailMap[sNo];
   String? getChannelOnOffStatus(String sNo) => _channelOnOffStatusMap[sNo];
   String? getChannelOtherData(String sNo) => _channelOtherDetailMap[sNo];
   String? getValveOnOffStatus(String sNo) => _valveOnOffStatusMap[sNo];
   String? getLightOnOffStatus(String sNo) => _lightOnOffStatusMap[sNo];
   String? getGateOnOffStatus(String sNo) => _gateOnOffStatusMap[sNo];
   String? getSensorUpdatedValve(String sNo) => _sensorValueMap[sNo];
   String? getBoosterPumpOnOffStatus(String sNo) => _boosterPumpOnOffStatusMap[sNo];
   String? getAgitatorOnOffStatus(String sNo) => _agitatorOnOffStatusMap[sNo];

  String get receivedDashboardPayload => dashBoardPayload;
  String get receivedSchedulePayload => schedulePayload;
  MQTTConnectionState get getAppConnectionState => _appConnectionState;
}