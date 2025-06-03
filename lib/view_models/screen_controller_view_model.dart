import 'dart:async';
import 'dart:core';
import 'package:flutter/cupertino.dart';
import '../utils/network_utils.dart';
import '../utils/shared_preferences_helper.dart';

class ScreenControllerViewModel extends ChangeNotifier {
  late StreamSubscription<bool> _connectionSubscription;
  bool isNetworkConnected = true;
  int? userId;
  String? userRole, userName, mobileNo, emailId;

  ScreenControllerViewModel(){
    initState();
    fetchUserPreferences();
  }

  void initState() {
    _connectionSubscription = NetworkUtils.connectionStream.listen((status) {
      isNetworkConnected = status;
      notifyListeners();
    });
  }

  Future<void> fetchUserPreferences() async {
    userId = await PreferenceHelper.getUserId();
    userName = await PreferenceHelper.getUserName();
    userRole = await PreferenceHelper.getUserRole();
    String? countyCode = await PreferenceHelper.getCountryCode();
    mobileNo = await PreferenceHelper.getMobileNumber();
    mobileNo = countyCode != null ? "+$countyCode $mobileNo":mobileNo;
    emailId = await PreferenceHelper.getEmail();
    notifyListeners();
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    super.dispose();
  }
}