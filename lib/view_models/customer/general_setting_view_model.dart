import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;
import '../../Models/admin_dealer/language_list.dart';
import '../../Models/customer/notification_list_model.dart';
import '../../repository/repository.dart';
import '../../utils/snack_bar.dart';

class GeneralSettingViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";

  final List<LanguageList> languageList = <LanguageList>[];


  List<Map<String, dynamic>> subUsers = [];

  String farmName = '', controllerCategory = '', modelName = '', deviceId = '', categoryName = '',
      controllerLocation='', controllerVersion='', newVersion='';
  int groupId = 0;

  String? selectedTimeZone;
  String currentDate = '';
  String currentTime = '';

  double opacity = 1.0;
  Timer? _timer;

  List<NotificationListModel> notifications = [];

  final List<String> timeZones = tz.timeZoneDatabase.locations.keys.toList();


  GeneralSettingViewModel(this.repository);

  void timerFunction(){
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      opacity = opacity == 1.0 ? 0.0 : 1.0;
      notifyListeners();
    });
  }

  void callbackFunction(String message, customerId) {
    Future.delayed(const Duration(milliseconds: 500), () {
      const GlobalSnackBar(code: 200, message: 'Sub user created successfully');
      getSubUserList(customerId);
    });
  }

  Future<void> getLanguage() async
  {
    setLoading(true);
    try {
      var response = await repository.fetchLanguageByActive({"active": "1"});
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          final cntList = jsonData["data"] as List;
          for (int i=0; i < cntList.length; i++) {
            languageList.add(LanguageList.fromJson(cntList[i]));
          }
        }
      }
    } catch (error) {
      debugPrint('Error fetching language list: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> getControllerInfo(customerId, controllerId) async {
    try {
      Map<String, Object> body = {"userId": customerId, "controllerId": controllerId};
      var response = await repository.fetchMasterControllerDetails(body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["code"] == 200) {
          farmName  = data["data"][0]['groupName'];
          controllerCategory = data["data"][0]['deviceName'];
          deviceId = data["data"][0]['deviceId'];
          modelName = data["data"][0]['modelName'];
          categoryName = data["data"][0]['categoryName'];
          groupId = data["data"][0]['groupId'];
          controllerVersion = data["data"][0]['hwVersion'];
          newVersion = data["data"][0]['availableHwVersion'];
          controllerLocation = data["data"][0]['controllerLocation'] ?? '';
          updateCurrentDateTime(data["data"][0]['timeZone']);
          if(controllerVersion!=newVersion){
            timerFunction();
          }else{
            _timer?.cancel();
          }
        }
      }
    } catch (error) {
      debugPrint('Error fetching language list: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> getSubUserList(customerId) async {
    try {
      Map<String, Object> body = {"userId": customerId};
      var response = await repository.fetchSubUserList(body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["code"] == 200) {
          subUsers = List<Map<String, dynamic>>.from(data["data"]);
        }
      }
    } catch (error) {
      debugPrint('Error fetching language list: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> getNotificationList(customerId, controllerId) async {
    try {
      Map<String, Object> body = {"userId": customerId, "controllerId": controllerId};
      var response = await repository.fetchUserPushNotificationType(body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["code"] == 200) {
          notifications = parseNotifications(response.body);
        }
      }
    } catch (error) {
      debugPrint('Error fetching language list: $error');
    } finally {
      setLoading(false);
    }
  }

  List<NotificationListModel> parseNotifications(String responseBody) {
    final parsed = json.decode(responseBody);
    return (parsed['data'] as List)
        .map((notification) => NotificationListModel.fromJson(notification))
        .toList();
  }


  void updateCurrentDateTime(String timeZone) {
    final tz.Location location = tz.getLocation(timeZone);
    final tz.TZDateTime now = tz.TZDateTime.now(location);

    currentDate = DateFormat.yMd().format(now);
    currentTime = DateFormat.jm().format(now);
    selectedTimeZone = timeZone;
    notifyListeners();
  }

  Future<void> updateMasterDetails(BuildContext context, int customerId, int controllerId, int modifyUser) async {
    try {

      Map<String, Object> body = {
        "userId": customerId,
        "controllerId": controllerId,
        "deviceName": controllerCategory,
        "timeZone": selectedTimeZone!,
        "controllerLocation": controllerLocation,
        "groupId": groupId,
        "groupName": farmName,
        "modifyUser": modifyUser,
      };

      var response = await repository.updateMasterDetails(body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["code"] == 200) {
          GlobalSnackBar.show(context, data["message"], 200);
        }else{
          GlobalSnackBar.show(context, data["message"], 400);
        }
      }
    } catch (error) {
      debugPrint('Error fetching language list: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateCustomerList(Map<String, dynamic> json) async {
    if (json['status'] != 'success') return;
    print(json);
  }

  Future<List<dynamic>?> getSubUserSharedDeviceList(Map<String, dynamic> body) async {
    try {
      var response = await repository.getSubUserSharedDeviceList(body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["code"] == 200) {
          var list = data['data'] as List;
          return list;
        }
      }
    } catch (error) {
      debugPrint('Error fetching device list: $error');
    }
    return null;
  }

  Future<void> updatedSubUserPermission(Map<String, dynamic> body, int subUsrId, BuildContext context) async {
    try {
      var response = await repository.updatedSubUserPermission(body);
      print(response.body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        GlobalSnackBar.show(context, data["message"], data["code"]);
        Navigator.pop(context);
      }
    } catch (error) {
      debugPrint('Error fetching device list: $error');
    }
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

}