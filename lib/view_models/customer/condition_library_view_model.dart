import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Models/customer/condition_library_model.dart';
import '../../repository/repository.dart';
import '../../services/mqtt_service.dart';
import '../../utils/constants.dart';
import '../../utils/snack_bar.dart';

class ConditionLibraryViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";

  late ConditionLibraryModel clData;

  List<String> connectingCondition = [];
  List<List<String>> connectedTo = [];

  String? selectedConditions;

  List<TextEditingController> vtTEVControllers = [];
  List<TextEditingController> amTEVControllers = [];


  ConditionLibraryViewModel(this.repository);

  Future<void> getConditionLibraryData(int customerId, int controllerId) async {
    setLoading(true);
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        var response = await repository.fetchConditionLibrary({
          "userId": customerId,
          "controllerId": controllerId,
        });

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);

          if (jsonData["code"] == 200) {
            clData = ConditionLibraryModel.fromJson(jsonData['data']);
            clData.cnLibrary.condition.sort((a, b) => (a.sNo).compareTo(b.sNo));
            vtTEVControllers = List.generate(
              clData.cnLibrary.condition.length,
                  (index) => TextEditingController(),
            );
            amTEVControllers = List.generate(
              clData.cnLibrary.condition.length,
                  (index) => TextEditingController(),
            );
            connectedTo = List.generate(5, (index) => []);
          }
        }
      } catch (error) {
        debugPrint('Error fetching condition library: $error');
      } finally {
        setLoading(false);
      }
    });
  }

  void conTypeOnChange(String type, int index){
    clData.cnLibrary.condition[index].type = type;
    clData.cnLibrary.condition[index].component = '--';
    clData.cnLibrary.condition[index].parameter = '--';
    clData.cnLibrary.condition[index].threshold = '--';
    clData.cnLibrary.condition[index].value = '--';
    clData.cnLibrary.condition[index].reason = '--';
    clData.cnLibrary.condition[index].delayTime = '--';
    clData.cnLibrary.condition[index].alertMessage = '--';
    notifyListeners();
  }

  void componentOnChange(String component, int index, String serialNo){
    clData.cnLibrary.condition[index].component = component;
    clData.cnLibrary.condition[index].componentSNo = serialNo;
    clData.cnLibrary.condition[index].parameter = '--';
    clData.cnLibrary.condition[index].threshold = '--';
    clData.cnLibrary.condition[index].value = '--';
    clData.cnLibrary.condition[index].reason = '--';
    clData.cnLibrary.condition[index].delayTime = '--';
    clData.cnLibrary.condition[index].alertMessage = '--';
    updateRule(index);
    notifyListeners();
  }

  void parameterOnChange(String param, int index){
    clData.cnLibrary.condition[index].parameter = param;
    updateRule(index);
    notifyListeners();

  }

  void thresholdOnChange(String valT, int index){
    clData.cnLibrary.condition[index].threshold = valT;
    updateRule(index);
    if(valT.contains('Lower')){
      clData.cnLibrary.condition[index].delayTime = '10 Sec';
    }else{
      clData.cnLibrary.condition[index].delayTime = '3 Sec';
    }
    notifyListeners();
  }

  void valueOnChange(String val, int index){
    clData.cnLibrary.condition[index].value = val;
    updateRule(index);
    notifyListeners();
  }

  void reasonOnChange(String reason, int index){
    clData.cnLibrary.condition[index].reason = reason;

    clData.cnLibrary.condition[index].alertMessage =
    '${clData.cnLibrary.condition[index].reason} detected in '
        '${clData.cnLibrary.condition[index].component}';
    amTEVControllers[index].text = clData.cnLibrary.condition[index].alertMessage;

    updateRule(index);

    amTEVControllers[index].text = clData.cnLibrary.condition[index].alertMessage;

    notifyListeners();
  }

  void delayTimeOnChange(String delayTime, int index){
    clData.cnLibrary.condition[index].delayTime = delayTime;
    notifyListeners();
  }

  void switchStateOnChange(bool status, int index){
    clData.cnLibrary.condition[index].status = status;
    notifyListeners();
  }

  void buildConnectingConditions(int count) {
    connectingCondition = List.generate(count, (index) => "Condition ${index+1}");
    notifyListeners();
  }

  List<String> getAvailableCondition(int index) {
    buildConnectingConditions(clData.cnLibrary.condition.length);
    if (index >= 0 && index < connectingCondition.length) {
      connectingCondition.removeAt(index);
    }
    List<String> available = List.from(connectingCondition);
    if(clData.cnLibrary.condition[index].component!='--'){
      List<String> resultList = clData.cnLibrary.condition[index].component.split(RegExp(r'\s*-\s*'));
      connectedTo[index] = resultList;
    }
    available.removeWhere((source) => connectedTo[index].contains(source));
    return available;
  }

  void combinedTO(int index, String source) {
    if (connectedTo[index].contains(source)) {
      connectedTo[index].remove(source);
    } else {
      connectedTo[index].add(source);
      List<String> cc = connectedTo[index];
      String result = cc.join(" - ");
      clData.cnLibrary.condition[index].component = result;
    }
    notifyListeners();
  }

  void updateRule(int index){
    if(clData.cnLibrary.condition[index].parameter!='--'){
      clData.cnLibrary.condition[index].rule =
      '${clData.cnLibrary.condition[index].parameter} of '
          '${clData.cnLibrary.condition[index].component} is '
          '${clData.cnLibrary.condition[index].threshold} '
          '${clData.cnLibrary.condition[index].value}';
    }else{
      clData.cnLibrary.condition[index].rule = '';
    }
    notifyListeners();
  }

  void createNewCondition() {
    List<int> existingSerials = clData.cnLibrary.condition
        .map((c) => c.sNo ?? 0)
        .toList()
      ..sort();

    int newSerial = 1;
    for (int i = 0; i < existingSerials.length; i++) {
      if (existingSerials[i] != i + 1) {
        newSerial = i + 1;
        break;
      }
      newSerial = existingSerials.length + 1;
    }

    Condition newCondition = Condition(
      sNo: newSerial,
      name: "Condition $newSerial",
      status: false,
      type: "Sensor",
      rule: "--",
      component: "--",
      componentSNo: '0',
      parameter: "--",
      threshold: "--",
      value: "--",
      reason: "--",
      delayTime: "--",
      alertMessage: "--",
    );

    clData.cnLibrary.condition.add(newCondition);

    vtTEVControllers = List.generate(
      clData.cnLibrary.condition.length,
          (index) => TextEditingController(),
    );
    amTEVControllers = List.generate(
      clData.cnLibrary.condition.length,
          (index) => TextEditingController(),
    );

    notifyListeners();
  }

  Future<void> saveConditionLibrary(BuildContext context, int customerId, int controllerId, userId, deviceId) async
  {
    try {
      Map<String, dynamic> body = {
        "userId": customerId,
        "controllerId": controllerId,
        "condition": clData.cnLibrary.toJson(),
        "createUser": userId,
      };

      print(clData.cnLibrary.toJson());

      List<Map<String, dynamic>> payloadList = [];

      for (var condition in clData.cnLibrary.condition) {
        String input = condition.value;
        final match = RegExp(r'[\d.]+').firstMatch(input);
        String? numberOnly = match?.group(0);

        payloadList.add({
          'sNo': condition.sNo ?? 0,
          'name': condition.name,
          'status': condition.status ? 1 : 0,
          'delayTime': formatTime(condition.delayTime),
          'StartTime': '00:01:00',
          'StopTime': '23:59:00',
          'notify': 1,
          'category': condition.type == 'Program' ? 1 : condition.type == 'Sensor' && condition.parameter=='Level'? 9:
          condition.type == 'Sensor' && condition.parameter=='Moisture'? 8:5,
          'object': condition.componentSNo,
          'operator': condition.threshold == 'Higher than'? 4 : condition.threshold == 'Lower than'? 5 : 6,
          'setValue': numberOnly,
          'Bypass': 0,
        });
      }

      String payloadString = payloadList.map((e) => e.values.join(',')).join(';');

      String payLoadFinal = jsonEncode({
        "1000": {"1001": payloadString}
      });
      MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');

      var response = await repository.saveConditionLibrary(body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        GlobalSnackBar.show(context, jsonData["message"], jsonData["code"]);
      }
    } catch (error) {
      debugPrint('Error fetching language list: $error');
    } finally {
      setLoading(false);
    }
  }

  void removeCondition(int index) {
    clData.cnLibrary.condition.removeAt(index);
    notifyListeners();
  }

  String formatTime(String time) {
    if (time.contains("Sec")) {
      int seconds = int.parse(time.replaceAll(RegExp(r'[^0-9]'), ''));
      int hours = seconds ~/ 3600;
      int minutes = (seconds % 3600) ~/ 60;
      int secs = seconds % 60;
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${secs.toString().padLeft(2, '0')}';
    }
    return time;
  }


  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

}