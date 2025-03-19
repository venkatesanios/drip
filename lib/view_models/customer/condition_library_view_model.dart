import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Models/customer/condition_library_model.dart';
import '../../repository/repository.dart';
import '../../utils/snack_bar.dart';

class ConditionLibraryViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";

  late ConditionLibraryModel conditionLibraryData;

  List<String> connectingCondition = [];
  List<List<String>> connectedTo = [];

  String? selectedConditions;

  List<TextEditingController> vtTEVControllers = [];
  List<TextEditingController> amTEVControllers = [];


  ConditionLibraryViewModel(this.repository);

  Future<void> getConditionLibraryData(int customerId, int controllerId) async
  {
    setLoading(true);
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        var response = await repository.fetchConditionLibrary({"userId": customerId,"controllerId": controllerId});
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          if (jsonData["code"] == 200) {
            conditionLibraryData = ConditionLibraryModel.fromJson(jsonData['data']);
            vtTEVControllers = List.generate(conditionLibraryData.conditionLibrary.condition.length, (index) => TextEditingController());
            amTEVControllers = List.generate(conditionLibraryData.conditionLibrary.condition.length, (index) => TextEditingController());
            connectedTo = List.generate(5, (index) => []);
          }
        }
      } catch (error) {
        debugPrint('Error fetching language list: $error');
      } finally {
        setLoading(false);
      }
    });

  }

  void conTypeOnChange(String type, int index){
    conditionLibraryData.conditionLibrary.condition[index].type = type;
    notifyListeners();
  }

  void componentOnChange(String component, int index){
    conditionLibraryData.conditionLibrary.condition[index].component = component;
    conditionLibraryData.conditionLibrary.condition[index].parameter = '--';
    conditionLibraryData.conditionLibrary.condition[index].threshold = '--';
    conditionLibraryData.conditionLibrary.condition[index].value = '--';
    conditionLibraryData.conditionLibrary.condition[index].reason = '--';
    conditionLibraryData.conditionLibrary.condition[index].delayTime = '--';
    conditionLibraryData.conditionLibrary.condition[index].alertMessage = '--';
    notifyListeners();
  }

  void parameterOnChange(String param, int index){
    conditionLibraryData.conditionLibrary.condition[index].parameter = param;
    notifyListeners();

  }

  void thresholdOnChange(String valT, int index){
    conditionLibraryData.conditionLibrary.condition[index].threshold = valT;
    if(valT.contains('Lower')){
      conditionLibraryData.conditionLibrary.condition[index].delayTime = '10 Sec';
    }else{
      conditionLibraryData.conditionLibrary.condition[index].delayTime = '3 Sec';
    }
    notifyListeners();
  }

  void valueOnChange(String val, int index){
    conditionLibraryData.conditionLibrary.condition[index].value = val;
    notifyListeners();
  }

  void reasonOnChange(String reason, int index){
    conditionLibraryData.conditionLibrary.condition[index].reason = reason;

    conditionLibraryData.conditionLibrary.condition[index].alertMessage =
    '${conditionLibraryData.conditionLibrary.condition[index].reason} detected in '
        '${conditionLibraryData.conditionLibrary.condition[index].component}';
    amTEVControllers[index].text = conditionLibraryData.conditionLibrary.condition[index].alertMessage;

    conditionLibraryData.conditionLibrary.condition[index].rule =
    '${conditionLibraryData.conditionLibrary.condition[index].parameter} of '
        '${conditionLibraryData.conditionLibrary.condition[index].component} is '
        '${conditionLibraryData.conditionLibrary.condition[index].threshold} '
        '${conditionLibraryData.conditionLibrary.condition[index].value}';

    amTEVControllers[index].text = conditionLibraryData.conditionLibrary.condition[index].alertMessage;

    notifyListeners();
  }

  void delayTimeOnChange(String delayTime, int index){
    conditionLibraryData.conditionLibrary.condition[index].delayTime = delayTime;
    notifyListeners();
  }

  void switchStateOnChange(bool status, int index){
    conditionLibraryData.conditionLibrary.condition[index].status = status;
    notifyListeners();
  }

  void buildConnectingConditions(int count) {
    connectingCondition = List.generate(count, (index) => "Condition ${index+1}");
    notifyListeners();
  }

  List<String> getAvailableCondition(int index) {
    buildConnectingConditions(conditionLibraryData.conditionLibrary.condition.length);
    if (index >= 0 && index < connectingCondition.length) {
      connectingCondition.removeAt(index);
    }
    List<String> available = List.from(connectingCondition);
    if(conditionLibraryData.conditionLibrary.condition[index].component!='--'){
      List<String> resultList = conditionLibraryData.conditionLibrary.condition[index].component.split(RegExp(r'\s*-\s*'));
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
      conditionLibraryData.conditionLibrary.condition[index].component = result;
    }
    notifyListeners();
  }

  void createNewCondition() {

    Condition newCondition = Condition(
      name: "Condition ${conditionLibraryData.conditionLibrary.condition.length+1}",
      status: false,
      type: "Sensor",
      rule: "--",
      component: "--",
      parameter: "--",
      threshold: "--",
      value: "--",
      reason: "--",
      delayTime: "--",
      alertMessage: "--",
    );

    conditionLibraryData.conditionLibrary.condition.add(newCondition);
    vtTEVControllers = List.generate(conditionLibraryData.conditionLibrary.condition.length, (index) => TextEditingController());
    amTEVControllers = List.generate(conditionLibraryData.conditionLibrary.condition.length, (index) => TextEditingController());
    notifyListeners();
  }

  Future<void> saveConditionLibrary(BuildContext context, int customerId, int controllerId, userId) async
  {
    try {
      Map<String, dynamic> body = {
        "userId": customerId,
        "controllerId": controllerId,
        "condition": conditionLibraryData.conditionLibrary.toJson(),
        "createUser": userId,
      };

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

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

}