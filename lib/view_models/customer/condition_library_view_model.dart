import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:oro_drip_irrigation/Models/customer/condition_library_model.dart';
import '../../repository/repository.dart';

class ConditionLibraryViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";

  late ConditionLibraryModel conditionLibraryData;
  List<String> selectedComponent = [];
  List<String> selectedSensor = [];
  List<String> selectedLevelParameter = [];
  List<String> selectedValue = [];
  List<String> selectedReason= [];
  List<String> selectedDelayTime= [];
  List<String> selectedAction= [];
  List<String> selectedMessage= [];

  ConditionLibraryViewModel(this.repository);

  Future<void> getConditionLibraryData(int customerId, int controllerId) async
  {
    setLoading(true);
    try {
      var response = await repository.fetchConditionLibrary({"customerId": customerId,"controllerId": controllerId});
      if (response.statusCode == 200) {
        print(response.body);
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          conditionLibraryData = ConditionLibraryModel.fromJson(jsonData['data']);
          print("Parameter List: ${conditionLibraryData.defaultData.parameter}");

          selectedSensor = List.generate(5, (index) => '--');
          selectedLevelParameter = List.generate(conditionLibraryData.defaultData.parameter.length+1, (index) => '--');
          selectedComponent = List.generate(7, (index) => '--');
          selectedValue = List.generate(7, (index) => '--');
          selectedReason = List.generate(11, (index) => '--');
          selectedDelayTime = List.generate(4, (index) => '--');
          selectedAction = List.generate(5, (index) => '--');
          selectedMessage = List.generate(5, (index) => '--');

        }
      }
    } catch (error) {
      debugPrint('Error fetching language list: $error');
    } finally {
      setLoading(false);
    }
  }

  void sensorOnChange(String lvlSensor, int index){
    selectedSensor[index] = lvlSensor;
    notifyListeners();
  }

  void lvlSensorCountOnChange(String lvlSensor, int index){
    selectedLevelParameter[index] = lvlSensor;
    notifyListeners();
  }

  void componentOnChange(String lvlSensor, int index){
    selectedComponent[index] = lvlSensor;
    notifyListeners();
  }

  void valueOnChange(String lvlSensor, int index){
    selectedValue[index] = lvlSensor;
    notifyListeners();
  }

  void reasonOnChange(String lvlSensor, int index){
    selectedReason[index] = lvlSensor;
    notifyListeners();
  }

  void delayTimeOnChange(String lvlSensor, int index){
    selectedDelayTime[index] = lvlSensor;
    notifyListeners();
  }

  void actionOnChange(String lvlSensor, int index){
    selectedAction[index] = lvlSensor;
    notifyListeners();
  }

  void messageOnChange(String lvlSensor, int index){
    selectedMessage[index] = lvlSensor;
    notifyListeners();
  }









  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

}