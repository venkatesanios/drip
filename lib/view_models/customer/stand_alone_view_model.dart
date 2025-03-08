import 'dart:convert';
import 'package:flutter/material.dart';
import '../../Models/customer/program_model.dart';
import '../../Models/customer/site_model.dart';
import '../../Models/customer/stand_alone_model.dart';
import '../../repository/repository.dart';
import '../../services/mqtt_service.dart';
import '../../utils/constants.dart';

enum SegmentWithFlow {manual, duration, flow}

class StandAloneViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";

  SegmentWithFlow segmentWithFlow = SegmentWithFlow.manual;
  String durationValue = '00:00:00';
  String selectedIrLine = '0';

  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  final TextEditingController flowLiter = TextEditingController();

  List<ProgramModel> programList = [];
  bool visibleLoading = false;
  int ddCurrentPosition = 0;
  int serialNumber = 0;
  int standAloneMethod = 0;
  int startFlag = 0;
  String strFlow = '0';
  String strDuration = '00:00:00';
  String strSelectedLineOfProgram = '0';

  late List<Map<String, dynamic>> standaloneSelection  = [];

  final int userId, customerId, controllerId;
  final String deviceId;

  Config configData;

  StandAloneViewModel(this.repository, this.configData, this.userId, this.customerId, this.controllerId, this.deviceId);

  Future<void> getProgramList() async {
    setLoading(true);
    programList.clear();
    try {
      Map<String, Object> body = {"userId": customerId, "controllerId": controllerId};
      final response = await repository.fetchCustomerProgramList(body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          List<dynamic> programsJson = jsonData['data'];
          programList = [...programsJson.map((programJson) => ProgramModel.fromJson(programJson))];

          ProgramModel defaultProgram = ProgramModel(
            programId: 0,
            serialNumber: 0,
            programName: 'Default',
            defaultProgramName: '',
            programType: '',
            priority: '',
            startDate: '',
            startTime: '',
            sequenceCount: 0,
            scheduleType: '',
            firstSequence: '',
            duration: '',
            programCategory: '',
          );

          bool programWithNameExists = false;
          for (ProgramModel program in programList) {
            if (program.programName == 'Default') {
              programWithNameExists = true;
              break;
            }
          }

          if (!programWithNameExists) {
            programList.insert(0, defaultProgram);
          } else {
            debugPrint('Program with name \'Default\' already exists in widget.programList.');
          }
          getExitManualOperation();
        }
      }
    } catch (error) {
      debugPrint('Error fetching country list: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> getExitManualOperation() async
  {
    try {
      Map<String, Object> body = {"userId": customerId, "controllerId": controllerId};
      final response = await repository.fetchUserManualOperation(body);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null){
          try{
            dynamic data = jsonResponse['data'];
            startFlag = data['startFlag'];
            serialNumber = data['serialNumber'];
            try {
              standAloneMethod = data['method'];
              if (standAloneMethod == 0){
                standAloneMethod = 3;
              }
            } catch (e) {
              debugPrint('Error: $e');
            }
            strFlow = data['flow'];
            strDuration = data['duration'];

            int position = findPositionByName(serialNumber, programList);
            if (position != -1) {
              ddCurrentPosition = position;
            }else {
              debugPrint("'$serialNumber' not found in the list.");
            }

            if(standAloneMethod == 3){
              segmentWithFlow = SegmentWithFlow.manual;
            }else if(standAloneMethod == 1){
              segmentWithFlow = SegmentWithFlow.duration;
            }else{
              segmentWithFlow = SegmentWithFlow.flow;
            }

            int count = strDuration.split(':').length - 1;
            if(count>1){
              durationValue = strDuration;
            }else{
              durationValue = '$strDuration:00';
            }
            flowLiter.text = strFlow;

            await Future.delayed(const Duration(milliseconds: 500));
            fetchStandAloneSelection(serialNumber, ddCurrentPosition);

          }catch(e){
            debugPrint(e.toString());
          }
        } else {
          throw Exception('Invalid response format: "data" is null');
        }
      }
    } catch (error) {
      debugPrint('Error fetching country list: $error');
    } finally {
      setLoading(false);
    }

  }


  Future<void> fetchStandAloneSelection(int sNo, value) async {

    int newIndex = programList.indexOf(value!);
    if (newIndex != -1) {
      ddCurrentPosition = newIndex;
    }

    Map<String, Object> body = {
      "userId": customerId,
      "controllerId": controllerId,
      "serialNumber": sNo
    };

    try {
      var response = await repository.fetchStandAloneData(body);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(response.body);
        if (jsonResponse['data'] != null) {
          dynamic data = jsonResponse['data'];
          StandAloneModel dashBoardData = StandAloneModel.fromJson(data);

          if(ddCurrentPosition==0){
            for (var item in dashBoardData.selection) {
              int serialNo = item.sNo.toInt();

              if (serialNo == 5) {
                configData.pump
                    .where((pump) => pump.sNo == item.sNo)
                    .forEach((pump) => pump.selected = true);
              }

              if (serialNo == 7) {
                for (var fertilizerSite in configData.fertilizerSite) {
                  fertilizerSite.boosterPump
                      .where((boosterPump) => boosterPump.sNo == item.sNo)
                      .forEach((boosterPump) => boosterPump.selected = true);
                }
              }

              if (serialNo == 9) {
                for (var fertilizerSite in configData.fertilizerSite) {
                  fertilizerSite.agitator
                      .where((agitator) => agitator.sNo == item.sNo)
                      .forEach((agitator) => agitator.selected = true);
                }
              }

              if (serialNo == 10) {
                for (var fertilizerSite in configData.fertilizerSite) {
                  fertilizerSite.channel
                      .where((channel) => channel.sNo == item.sNo)
                      .forEach((channel) => channel.selected = true);
                }
              }

              if (serialNo == 11) {
                for (var filterSite in configData.filterSite) {
                  filterSite.filters
                      .where((filter) => filter.sNo == item.sNo)
                      .forEach((filter) => filter.selected = true);
                }
              }

              if (serialNo == 13) {
                for (var line in configData.lineData) {
                  line.valves
                      .where((valve) => valve.sNo == item.sNo)
                      .forEach((valve) => valve.isOn = true);
                }
              }
            }
          }
          else{
            //program
            //fetchStandAloneSelection
          }
        } else {
          debugPrint('Invalid response format: "data" is null');
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Error fetching Product stock: $error');
      debugPrint(stackTrace.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> segmentSelectionCallbackFunction(segIndex, value, sldIrLine) async
  {
    if (value.contains(':')) {
      strDuration = value;
    } else {
      strFlow = value;
    }
    strSelectedLineOfProgram = sldIrLine;
    if(segIndex==0){
      standAloneMethod = 3;
    }else{
      standAloneMethod = segIndex;
    }
    notifyListeners();
  }


  int findPositionByName(int sNo, List<ProgramModel> programList) {
    for (int i = 0; i < programList.length; i++) {
      if (programList[i].serialNumber == sNo) {
        return i;
      }
    }
    return -1;
  }


  void showDurationInputDialog(BuildContext context) {
    List<String> timeParts = durationValue.split(':');
    _hoursController.text = timeParts[0];
    _minutesController.text = timeParts[1];
    _secondsController.text = timeParts[2];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Standalone duration'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 23),
                  decoration: const InputDecoration(
                    labelText: 'Hours',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 23),
                  decoration: const InputDecoration(
                    labelText: 'Minutes',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _secondsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 23),
                  decoration: const InputDecoration(
                    labelText: 'Seconds',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            MaterialButton(
              color: Colors.redAccent,
              textColor: Colors.white,
              onPressed:() async {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            MaterialButton(
              color: Colors.teal,
              textColor: Colors.white,
              onPressed:() async {
                if (_validateTime(_hoursController.text, 'hours') &&
                    _validateTime(_minutesController.text, 'minutes') &&
                    _validateTime(_secondsController.text, 'seconds')) {
                  durationValue = '${_hoursController.text}:${_minutesController.text}:${_secondsController.text}';
                  segmentSelectionCallbackFunction(segmentWithFlow.index, durationValue , selectedIrLine);
                  Navigator.of(context).pop();
                }
                else{
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Invalid time formed'),
                        content: const Text('Please fill correct time format and try again.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Set duration'),
            ),
          ],
        );
      },
    );
  }

  bool _validateTime(String value, String fieldType) {
    if (value.isEmpty) {
      return false;
    }
    int intValue = int.tryParse(value) ?? -1;
    if (intValue < 0) {
      return false;
    }
    switch (fieldType) {
      case 'hours':
        return intValue >= 0 && intValue <= 23;
      case 'minutes':
      case 'seconds':
        return intValue >= 0 && intValue <= 59;
      default:
        return false;
    }
  }

  void stopAllManualOperation() {
    if(ddCurrentPosition==0){
      String payLoadFinal = jsonEncode({
        "800": {"801": '0,0,0,0,0'}
      });
      MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');

    }
  }

  void startManualOperation(context){

    standaloneSelection.clear();
    if(ddCurrentPosition==0) {
      List<String> allRelaySrlNo = [];
      String strSldValveOrLineSrlNo = '';
      String strSldPumpSrlNo = '',
          strSldMainValveSrlNo = '',
          strSldCtrlFilterSrlNo = '',
          strSldLocFilterSrlNo = '',
          strSldCrlFetFilterSrlNo = '',
          strSldLocFetFilterSrlNo = '',
          strSldAgitatorSrlNo = '',
          strSldFanSrlNo = '',
          strSldFoggerSrlNo = ''      ,
          strSldBoosterPumpSrlNo = '',
          strSldSelectorSrlNo = '';

      /*if(config.pump.isNotEmpty){
        strSldSourcePumpSrlNo = getSelectedRelaySrlNo(config.pump);
      }*/

      if (configData.pump.isNotEmpty) {
        strSldPumpSrlNo = getSelectedRelaySrlNo(configData.pump);
      }

      for (var line in configData.lineData) {
        for (int j = 0; j < line.valves.length; j++) {
          if (line.valves[j].isOn) {
            strSldValveOrLineSrlNo += '${line.valves[j].sNo}_';
            standaloneSelection.add({
              'sNo': line.valves[j].sNo,
              'selected': line.valves[j].isOn,
            });
          }
        }
      }

      strSldValveOrLineSrlNo = strSldValveOrLineSrlNo.isNotEmpty ? strSldValveOrLineSrlNo.substring(
          0, strSldValveOrLineSrlNo.length - 1) : '';

      allRelaySrlNo = [
        strSldMainValveSrlNo,
        strSldCtrlFilterSrlNo,
        strSldValveOrLineSrlNo,
        strSldLocFilterSrlNo,
        strSldCrlFetFilterSrlNo,
        strSldLocFetFilterSrlNo,
        strSldAgitatorSrlNo,
        strSldFanSrlNo,
        strSldFoggerSrlNo,
        strSldBoosterPumpSrlNo,
        strSldSelectorSrlNo,
      ];

      if (strSldPumpSrlNo.isNotEmpty && strSldValveOrLineSrlNo.isEmpty)
      {
        showDialog<String>(
            context: context,
            builder: (BuildContext dgContext) =>
                AlertDialog(
                  title: const Text('StandAlone'),
                  content: const Text(
                      'Valve is not open! Are you sure! You want to Start the Selected Pump?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(dgContext, 'Cancel'),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        startByStandaloneDefault(context, allRelaySrlNo, strSldPumpSrlNo);
                        Navigator.pop(dgContext, 'OK');
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                )
        );
      }
      else {
        startByStandaloneDefault(context, allRelaySrlNo, strSldPumpSrlNo);
        Navigator.pop(context, 'OK');
      }
    }
    /*else {
      Map<String, List<DashBoardValve>> groupedValves = {};
      String strSldSqnNo = '';
      //String strSldSqnLocation = '';

      String strSldIrrigationPumpId = '';
      if(dashBoardData[0].irrigationPump.isNotEmpty){
        strSldIrrigationPumpId = getSelectedRelayId(dashBoardData[0].irrigationPump);
      }

      String strSldMainValveId = '';
      if(dashBoardData[0].mainValve.isNotEmpty){
        strSldMainValveId = getSelectedRelayId(dashBoardData[0].mainValve);
      }

      String strSldCtrlFilterId = '';
      String sldCtrlFilterRelayOnOffStatus = '';
      if(dashBoardData[0].centralFilterSite.isNotEmpty){
        for(int i=0; i<dashBoardData[0].centralFilterSite.length; i++){
          String concatenatedString = getSelectedRelaySrlNo(dashBoardData[0].centralFilterSite[i].filter);
          if(concatenatedString.isNotEmpty){
            strSldCtrlFilterId += '${dashBoardData[0].centralFilterSite[i].id};';
            sldCtrlFilterRelayOnOffStatus += '${getRelayOnOffStatus(dashBoardData[0].centralFilterSite[i].filter)};';
          }
        }
        if (strSldCtrlFilterId.isNotEmpty && strSldCtrlFilterId.endsWith(';')) {
          strSldCtrlFilterId = strSldCtrlFilterId.replaceRange(strSldCtrlFilterId.length - 1, strSldCtrlFilterId.length, '');
        }
        if (sldCtrlFilterRelayOnOffStatus.isNotEmpty && sldCtrlFilterRelayOnOffStatus.endsWith(';')) {
          sldCtrlFilterRelayOnOffStatus = sldCtrlFilterRelayOnOffStatus.replaceRange(sldCtrlFilterRelayOnOffStatus.length - 1, sldCtrlFilterRelayOnOffStatus.length, '');
        }
      }

      String strSldLocFilterId = '';
      String sldLocFilterRelayOnOffStatus = '';
      if(dashBoardData[0].localFilterSite.isNotEmpty){
        for(int i=0; i<dashBoardData[0].localFilterSite.length; i++){
          String concatenatedString = getSelectedRelaySrlNo(dashBoardData[0].localFilterSite[i].filter);
          if(concatenatedString.isNotEmpty){
            strSldLocFilterId += '${dashBoardData[0].localFilterSite[i].id};';
            sldLocFilterRelayOnOffStatus += '${getRelayOnOffStatus(dashBoardData[0].localFilterSite[i].filter)};';
          }
        }
        if (strSldLocFilterId.isNotEmpty && strSldLocFilterId.endsWith(';')) {
          strSldLocFilterId = strSldLocFilterId.replaceRange(strSldLocFilterId.length - 1, strSldLocFilterId.length, '');
        }
        if (sldLocFilterRelayOnOffStatus.isNotEmpty && sldLocFilterRelayOnOffStatus.endsWith(';')) {
          sldLocFilterRelayOnOffStatus = sldLocFilterRelayOnOffStatus.replaceRange(sldLocFilterRelayOnOffStatus.length - 1, sldLocFilterRelayOnOffStatus.length, '');
        }
      }

      String  strSldFanId = '';
      if(dashBoardData[0].fan.isNotEmpty){
        strSldFanId = getSelectedRelayId(dashBoardData[0].fan);
      }

      String  strSldFgrId = '';
      if(dashBoardData[0].fogger.isNotEmpty){
        strSldFgrId = getSelectedRelayId(dashBoardData[0].fogger);
      }

      for (var lineOrSq in dashBoardData[0].lineOrSequence) {
        if(lineOrSq.selected){
          strSldSqnNo = lineOrSq.sNo;
          standaloneSelection.add({
            'id': lineOrSq.id,
            'sNo': lineOrSq.sNo,
            'name': lineOrSq.name,
            'location': lineOrSq.location,
            'selected': lineOrSq.selected,
          });
          break;
        }
      }

      if (strSldSqnNo.isEmpty) {
        displayAlert(context, 'You must select an zone.');
      }else if (strSldIrrigationPumpId.isEmpty) {
        displayAlert(context, 'You must select an irrigation pump.');
      }else{
        sendCommandToControllerAndMqttProgram(dashBoardData[0].headUnits,strSldSqnNo,strSldIrrigationPumpId,strSldMainValveId,strSldCtrlFilterId,
            sldCtrlFilterRelayOnOffStatus,strSldLocFilterId,sldLocFilterRelayOnOffStatus,strSldFanId,strSldFgrId);
      }
    }*/

  }

  String getSelectedRelaySrlNo(itemList) {
    String result = '';
    for (int i = 0; i < itemList.length; i++) {
      if (itemList[i].selected) {
        result += '${itemList[i].sNo}_';
        standaloneSelection.add({
          'sNo': itemList[i].sNo,
          'selected': itemList[i].selected,
        });
      }
    }
    return result.isNotEmpty ? result.substring(0, result.length - 1) : '';
  }

  void startByStandaloneDefault(context, List<String> allRelaySrlNo, String pumpRelay){
    String finalResult = allRelaySrlNo.where((s) => s.isNotEmpty).join('_');
    String payload = '';
    String payLoadFinal = '';

    if(standAloneMethod==1 && strDuration=='00:00:00'){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Duration input'),
          duration: Duration(seconds: 3),
        ),
      );
    }else{
      payload = '${finalResult==''?0:1},$pumpRelay,${finalResult==''?0:finalResult},$standAloneMethod,${standAloneMethod==3?'0':standAloneMethod==1?strDuration:strFlow}';
      payLoadFinal = jsonEncode({
        "800": {"801": payload}
      });

      MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
      sentManualModeToServer(0, 1, standAloneMethod, strDuration, strFlow, standaloneSelection, payLoadFinal);
    }
  }

  Future<void> sentManualModeToServer(int sNo, int sFlag, int method, String dur, String flow, List<Map<String, dynamic>> selection, String payLoad) async {
    try {

      final body = {
        "userId": customerId,
        "controllerId": controllerId,
        "serialNumber": sNo,
        "programName": programList[ddCurrentPosition].programName,
        "sequenceName": sNo==0 ? null : selection.isNotEmpty ? selection.last['name'] : '',
        "startFlag": sFlag,
        "method": method,
        "duration": dur,
        "flow": flow,
        "fromDashboard":false,
        "selection": selection,
        "createUser": userId,
        "hardware": jsonDecode(payLoad),
      };

      try {
        var response = await repository.updateStandAloneData(body);
        if (response.statusCode == 200) {
          standaloneSelection.clear();
          //callbackFunction(jsonResponse['message']);
        }
      } catch (error, stackTrace) {
        debugPrint('Error fetching Product stock: $error');
        debugPrint(stackTrace.toString());
      } finally {
        notifyListeners();
      }

    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

}