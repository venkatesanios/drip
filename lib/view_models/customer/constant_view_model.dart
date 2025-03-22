import 'dart:convert';

import 'package:flutter/material.dart';
import '../../Models/customer/constant_model.dart';
import '../../repository/repository.dart';
import '../../utils/snack_bar.dart';

class ConstantViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";

  late UserConstant userConstant;
  late List<ConstantMenu> filteredMenu = [];

  List<TextEditingController> txtEdControllers = [];
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  List<TextEditingController> txtEdControllersNF = [];


  ConstantViewModel(this.repository);


  Future<void> getConstantData(int customerId, int controllerId) async
  {
    setLoading(true);
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        var response = await repository.fetchConstantData({"userId": customerId, "controllerId": controllerId});
        print(response.body);
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          if (jsonData["code"] == 200) {
            userConstant = UserConstant.fromJson(jsonData['data']);
            filteredMenu = userConstant.defaultData.constantMenus
                .where((item) => item.parameter != "Normal Alarm" && item.value == '1')
                .toList();

            txtEdControllers = List.generate(12, (index) => TextEditingController());
            txtEdControllersNF  = List.generate(userConstant.constant.valveList!.length, (index) => TextEditingController());

            for(int i=0; i < userConstant.constant.generalMenu.length; i++){
              if(userConstant.constant.generalMenu[i].widgetTypeId == 1) {
                txtEdControllers[i].text = userConstant.constant.generalMenu[i].value;
              }
            }

            for(int i=0; i < userConstant.constant.valveList!.length; i++){
              txtEdControllersNF[i].text = userConstant.constant.valveList![i].txtValue;
            }

            menuOnChange(0);

          }
        }
      } catch (error) {
        debugPrint('Error fetching language list: $error');
      } finally {
        setLoading(false);
      }
    });

  }

  void menuOnChange(int index){
    for (var item in filteredMenu) {
      item.isSelected = false;
    }
    filteredMenu[index].isSelected = true;
    notifyListeners();
  }

  void updateGeneralValve(int index, String value, String type){
    String finalVal = value.trim();
    if(type=='value'){
      userConstant.constant.valveList![index].txtValue = finalVal;
    }else{
      userConstant.constant.generalMenu[index].value = finalVal;
    }
  }

  void updateGeneralSwitch(int index, bool status){
    userConstant.constant.generalMenu[index].value = status;
    notifyListeners();
  }

  void showDurationInputDialog(BuildContext context, String durationValue, int index, String cnsType) {
    List<String> timeParts = durationValue.split(':');
    _hoursController.text = timeParts[0];
    _minutesController.text = timeParts[1];
    _secondsController.text = timeParts[2];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('duration'),
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
                  if(cnsType == 'general'){
                    userConstant.constant.generalMenu[index].value = durationValue;
                  }else if(cnsType == 'valve'){
                    userConstant.constant.valveList![index].pickerVal = durationValue;
                  }else if(cnsType == 'mainValve'){
                  userConstant.constant.mainValveList![index].pickerVal = durationValue;
                  }else if(cnsType == 'irrigateLine') {
                    userConstant.constant.irrigationLineList![index].pickerVal =
                        durationValue;
                  }
                  notifyListeners();
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

  void pumpStationOnChange(int index, bool status){
    userConstant.constant.pumpList![index].pumpStation = status;
    notifyListeners();
  }

  void controlGemOnChange(int index, bool status){
    userConstant.constant.pumpList![index].controlGem = status;
    notifyListeners();
  }

  void delay(int index, String selectedValue){
    userConstant.constant.mainValveList![index].delay = selectedValue;
    notifyListeners();
  }
  void lowFlowAction(int index, String selectedValue){
    userConstant.constant.irrigationLineList![index].lowFlowAction = selectedValue;
    notifyListeners();
  }
  void highFlowAction(int index, String selectedValue){
    userConstant.constant.irrigationLineList![index].highFlowAction = selectedValue;
    notifyListeners();
  }

  Future<void> saveConstantData(context, int customerId, int controllerId, int createUserId) async
  {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        Map<String, dynamic> cnsMenu = userConstant.constant.toJson();

        Map<String, dynamic> body = {
          "userId": customerId,
          "controllerId": controllerId,
          "general": cnsMenu['general'],
          "line": cnsMenu['irrigationLineList'],
          "mainValve": cnsMenu['mainValveList'],
          "valve": cnsMenu['valveList'],
          "pump": cnsMenu['pumpList'],
          "waterMeter": [],
          "filtration": [],
          "fertilization": [],
          "ecPh": [],
          "analogSensor": [],
          "moistureSensor": [],
          "levelSensor": [],
          "normalAlarm": [],
          "criticalAlarm": [],
          "globalAlarm": [],
          "controllerReadStatus": '0',
          "createUser": createUserId,

        };

        var response = await repository.saveConstantData(body);
        print(response.body);
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          if (jsonData["code"] == 200) {
            GlobalSnackBar.show(context, jsonData["message"], jsonData["code"]);
          }
        }
      } catch (error) {
        debugPrint('Error fetching language list: $error');
      } finally {
        setLoading(false);
      }
    });

  }


  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}