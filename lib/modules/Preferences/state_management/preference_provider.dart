import 'dart:convert';

import 'package:flutter/material.dart';

import '../model/preference_data_model.dart';
import '../../../services/http_service.dart';
import '../repository/preferences_repo.dart';

const actionForGeneral = "getUserPreferenceGeneral";
const actionForNotification = "getUserPreferenceNotification";
const actionForSetting = "getUserPreferenceSetting";
const actionForUserPassword = "checkUserUsingUserIdAndPassword";
const actionForCalibration = "getUserPreferenceCalibration";

class PreferenceProvider extends ChangeNotifier {
  final PreferenceRepository repository = PreferenceRepository(HttpService());


  bool notReceivingAck = false;
  bool sending = false;

  int _selectedTabIndex = 0;
  int get selectedTabIndex => _selectedTabIndex;

  void updateTabIndex(int newIndex) {
    _selectedTabIndex = newIndex;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  GeneralData? generalData;
  GeneralData? get generalDataResult => generalData;

  List<IndividualPumpSetting>? individualPumpSetting;
  List<IndividualPumpSetting>? get individualPumpSettingData => individualPumpSetting;

  List<CommonPumpSetting>? commonPumpSettings;
  List<CommonPumpSetting>? get commonPumpSettingsData => commonPumpSettings;

  List<CommonPumpSetting>? calibrationSetting;
  List<CommonPumpSetting>? get calibrationSettingsData => calibrationSetting;

  List<SettingList>? defaultSetting;
  List<SettingList>? get defaultSettingData => defaultSetting;

  List<SettingList>? defaultCalibration;
  List<SettingList>? get defaultCalibrationData => defaultCalibration;

  int passwordValidationCode = 0;

  void updateValidationCode() {
    passwordValidationCode = 0;
    notifyListeners();
  }

  Future<void> getUserPreference({required int userId, required int controllerId}) async {
    final userData = {
      "userId": userId,
      "controllerId": controllerId
    };

    print("userData :: $userData");
    try {
      final response = await repository.getUserPreferenceGeneral(userData);
      if(response.statusCode == 200) {
        final result = jsonDecode(response.body);
        try {
          generalData = GeneralData.fromJson(result['data'][0]);
        } catch(error) {
          print(error);
        }
      } else {
        print("response.body ${response.body}");
      }
    } catch(error, stackTrace) {
      print("Error parsing general data: $error");
      print("Stack trace general data: $stackTrace");
    }
    try {
      final response = await repository.getUserPreferenceSetting(userData);
      if(response.statusCode == 200) {
        final result = jsonDecode(response.body);
        try {
          individualPumpSetting = List.from(result['data']['individualPumpSetting'].map((json) => IndividualPumpSetting.fromJson(json)));
          commonPumpSettings = List.from(result['data']['commonPumpSetting'].map((json) => CommonPumpSetting.fromJson(json)));
        } catch(error, stackTrace) {
          print(error);
          print("stackTrace ==> $stackTrace");
        }
      } else {
        print("response.body ${response.body}");
      }
    } catch(error, stackTrace) {
      print("Error parsing setting data: $error");
      print("Stack trace setting data: $stackTrace");
    }
    try {
      final response = await repository.getUserPreferenceCalibration(userData);
      print("getUserPreferenceCalibration :: ${response.body}");
      if(response.statusCode == 200) {
        final result = jsonDecode(response.body);
        try {
          calibrationSetting = List.from(result['data'].map((json) => CommonPumpSetting.fromJson(json)));
        } catch(error) {
          print(error);
        }
      } else {
        print("response.body ${response.body}");
      }
    } catch(error, stackTrace) {
      print("Error parsing setting data: $error");
      print("Stack trace setting data: $stackTrace");
    }
    notifyListeners();
  }

  Future<void> checkPassword({required int userId, required String password}) async{
    try {
      final userData = {
        'userId': userId,
        "password": password
      };
      final response = await repository.checkPassword(userData);
      final result = jsonDecode(response.body);
      passwordValidationCode = result['code'];
    } catch(error, stackTrace) {
      print("Error parsing setting data: $error");
      print("Stack trace setting data: $stackTrace");
    }
    notifyListeners();
  }

  var temp = [];

  void updateControllerReaStatus({required String key, required int oroPumpIndex, required bool failed}) {
    if(key.contains("100")) {
      commonPumpSettings![oroPumpIndex].settingList[0].controllerReadStatus = "1";
      individualPumpSetting![oroPumpIndex].settingList[0].changed = false;
    }
    if(key.contains("200")) {
      commonPumpSettings![oroPumpIndex].settingList[1].controllerReadStatus = "1";
      individualPumpSetting![oroPumpIndex].settingList[1].changed = false;
    }
    int pumpIndex = 0;
    for (var individualPump in individualPumpSetting ?? []) {
      if (commonPumpSettings![oroPumpIndex].deviceId == individualPump.deviceId) {
        if(individualPump.output != null) {
          pumpIndex = int.parse(RegExp(r'\d+').firstMatch(individualPump.output)!.group(0)!);
        } else {
          pumpIndex++;
        }
        for (var individualPumpSetting in individualPump.settingList) {
          switch (individualPumpSetting.pumpType) {
            case 23:case 203:
              if(key.contains("400-$pumpIndex")) {
                individualPumpSetting.controllerReadStatus= "1";
                individualPumpSetting.changed = false;
                // print("$key acknowledged");
              }
              break;
            case 22:case 202:
              temp.add(key);
              // print("temp variable ==> ${temp.toSet()}");
              if(temp.toSet().contains("300-$pumpIndex") && temp.toSet().contains("500-$pumpIndex")) {
                individualPumpSetting.controllerReadStatus = "1";
                individualPumpSetting.changed = false;
                // print("$key acknowledged");
              }
              break;
            case 25: case 205:
            if(key.contains("600-$pumpIndex")) {
                individualPumpSetting.controllerReadStatus = "1";
                individualPumpSetting.changed = false;
                // print("$key acknowledged");
              };
              break;
          }
        }
      }
    }
    if(passwordValidationCode == 200 && calibrationSetting!.isNotEmpty) {
      if(key.contains("900")) {
        calibrationSetting![oroPumpIndex].settingList[1].controllerReadStatus = "1";
        calibrationSetting![oroPumpIndex].settingList[0].changed = false;
      };
    }
    notifyListeners();
  }

  void clearData() {
    notReceivingAck = false;
    sending = false;
    _selectedTabIndex = 0;
    generalData = null;
    individualPumpSetting = null;
    commonPumpSettings = null;
    calibrationSetting = null;
    passwordValidationCode = 0;
  }
}