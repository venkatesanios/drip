import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Constants/data_convertion.dart';
import '../Models/Weather_model.dart';
import '../Models/customer/site_model.dart';
import '../Screens/Map/googlemap_model.dart';

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
  // bool isCommunicatable = false;
  // bool isWaiting = false;
  int dataFetchingStatus = 2;
  List<dynamic> unitList = [];

  //Todo : Dashboard start
  int tryingToGetPayload = 0;

  String version = '';

  dynamic listOfSite = [];
  dynamic listOfSharedUser = {};
  bool httpError = false;
  String selectedSiteString = '';
  int selectedSite = 0;
  int selectedMaster = 0;
  int selectedLine = 0;
  List<dynamic> nodeDetails = [];
  dynamic messageFromHw;
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

  //kamaraj
  int powerSupply = 0;
  bool onRefresh = false;
  bool isLiveSynced = false;
  Duration lastCommunication = Duration.zero;
  int wifiStrength = 0;
  String liveDateAndTime = '';
  List<String> nodeLiveMessage = [];
  List<String> outputOnOffPayload = [];
  List<String> inputPayload = [];
  List<String> pumpPayload = [];
  List<String> filterPayload = [];
  List<String> fertilizerPayload = [];
  List<String> currentSchedule = [];
  List<String> nextSchedule = [];
  List<String> scheduledProgramPayload = [];
  List<String> lineLiveMessage = [];

  // List<WaterSource> waterSourceMobDash = [];
  // List<FilterSite> filterSiteMobDash = [];
  // List<FertilizerSite> fertilizerSiteMobDash = [];
  // List<IrrigationLineData>? irrLineDataMobDash = [];


  void updateMapData(data){
    print("updateMapData $data");
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

  void editLineData(dynamic data){
    // // print('editLineData : ${data}');
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
          // // // print('${i['FilterStatus'][i['Status'] - 1]['Name']} => OnDelayLeft : ${i['DurationLeft']}');
          if(leftDelay > 0){
            onDelayCompleted += 1;
            i['DurationCompleted'] = dataConvert.formatTime(onDelayCompleted);
            // // // print('${i['FilterStatus'][i['Status'] - 1]['Name']} => DurationCompleted : ${i['DurationCompleted']}');
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
          // // // print('${i['FilterStatus'][i['Status'] - 1]['Name']} => OnDelayLeft : ${i['DurationLeft']}');
          if(leftDelay > 0){
            onDelayCompleted += 1;
            i['DurationCompleted'] = dataConvert.formatTime(onDelayCompleted);
            // // // print('${i['FilterStatus'][i['Status'] - 1]['Name']} => DurationCompleted : ${i['DurationCompleted']}');
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
            // // // print('${i['Name']} => OnDelayCompleted : ${i['OnDelayCompleted']}');
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



  void updateReceivedPayload(String payload,bool dataFromHttp) async{
    if (kDebugMode) {
      print("updateReceivedPayload ====$payload");

    }
    if(!dataFromHttp) {
      dataFetchingStatus = 1;
    } else {
      dataFetchingStatus = 3;
    }
    try {
      // Todo : Dashboard payload start
      Map<String, dynamic> data = payload.isNotEmpty? jsonDecode(payload) : {};
      print('\ncheck contain ${data.containsKey('6603')}');
      //live payload
      if(data['mC']=='2400'){
         //liveSyncCall(false);
        isLiveSynced = true;
        liveDateAndTime = '${data['cD']} ${data['cT']}';
        updateLastCommunication(liveDateAndTime);
        wifiStrength = data['cM']['WifiStrength'];
        powerSupply = data['cM']['PowerSupply'];
        updateNodeLiveMessage(data['cM']['2401'].split(";"));
        updateOutputStatusPayload(data['cM']['2402'].split(";"));
        updateInputPayload(data['cM']['2403'].split(";"));
        updatePumpStatusPayload(data['cM']['2404'].split(";"));
        updateFilterStatusPayload(data['cM']['2406'].split(";"));
        updateFertilizerStatusPayload(data['cM']['2407'].split(";"));
        updateLineLiveMessage(data['cM']['2405'].split(";"));
        updateCurrentProgram(data['cM']['2408'].split(";"));
        updateNextProgram(data['cM']['2409'].split(";"));
        updateScheduledProgram(data['cM']['2410'].split(";"));

        notifyListeners();
      }
      else if(data.containsKey('3600') && data['3600'] != null && data['3600'].isNotEmpty){
        // mySchedule.dataFromMqttConversion(payload);
        schedulePayload = payload;
      } else if(data.containsKey('5100') && data['5100'] != null && data['5100'].isNotEmpty){
        weatherModelinstance = WeatherModel.fromJson(data);
      } else if(data['mC'] != null && data["mC"].contains("VIEW")) {
         cCList = {...cCList, data['cC']}.toList();
        viewSetting = data;
        if (!viewSettingsList.contains(jsonEncode(data['cM']))) {
          viewSettingsList.add(jsonEncode(data["cM"]));
          // print("viewSettingsList ==> $viewSettingsList");
        }
      }
      // Check if 'mC' is 4200
      if(data['cM'] is! List<dynamic>) {
        if (data['mC'] != null && data['cM'].containsKey('4201')) {
          messageFromHw = data['cM']['4201'];
        }
        }

           if(data.containsKey("cM") && data["cM"] is! List && (data["cM"] as Map).containsKey("6601")){
              if(ctrllogtimecheck != data['cT']){
               sheduleLog += "\n";
               sheduleLog += data['cM']['6601'];
               ctrllogtimecheck = data['cT'];
             }

           }
          if(data.containsKey("cM") && data["cM"] is! List && (data["cM"] as Map).containsKey("6602")){

            if(ctrllogtimecheck != data['cT']) {
              uardLog += "\n";
              uardLog += data['cM']['6602'];
              ctrllogtimecheck = data['cT'];
            }
          }
          if(data.containsKey("cM") && data["cM"] is! List && (data["cM"] as Map).containsKey("6603")){
             if(ctrllogtimecheck != data['cT']) {
              uard0Log += "\n";
              uard0Log += data['cM']['6603'];
              ctrllogtimecheck = data['cT'];
            }

          }
          if(data.containsKey("cM") && data["cM"] is! List && (data["cM"] as Map).containsKey("6604")){
             if(ctrllogtimecheck != data['cT']) {
              uard4Log += "\n";
              uard4Log += data['cM']['6604'];
              ctrllogtimecheck = data['cT'];
            }

          }



    } catch (e, stackTrace) {
      print('Error parsing JSON: $e');
      print('Stacktrace while parsing json : $stackTrace');
    }
    if(irrigationPump.isEmpty){
      loading = true;
    }else{
      loading = false;
    }
    tryingToGetPayload = 0;
    notifyListeners();


    updateSourcePump();
    updateIrrigationPump();
    updateLocalFertigationSite();
    updateCentralFertigationSite();
    updateCentralFiltrationSite();
    updateLocalFiltrationSite();
    // updateCurrentSchedule();
    notifyListeners();
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

  void updateInputPayload(List<String> message) {
    inputPayload = message;
  }

  void updatePumpStatusPayload(List<String> message) {
    pumpPayload = message;
  }

  void updateFilterStatusPayload(List<String> message) {
    filterPayload = message;
  }

  void updateFertilizerStatusPayload(List<String> message) {
    fertilizerPayload = message;
  }

  void updateCurrentProgram(List<String> program) {
    currentSchedule = program;
  }

  void updateNextProgram(List<String> program) {
    nextSchedule = program;
  }

  void updateScheduledProgram(List<String> program) {
    scheduledProgramPayload = program;
  }

  void saveUnits(List<dynamic> units) {
    unitList = units;
  }

  void updateMQTTConnectionState(MQTTConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  void updateLastCommunication(dt) {
    final String lastSyncString = dt;
    DateTime lastSyncDateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(lastSyncString);
    DateTime currentDateTime = DateTime.now();
    lastCommunication = currentDateTime.difference(lastSyncDateTime);
    notifyListeners();
  }

  String get receivedDashboardPayload => dashBoardPayload;
  String get receivedSchedulePayload => schedulePayload;
  MQTTConnectionState get getAppConnectionState => _appConnectionState;
}