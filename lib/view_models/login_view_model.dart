import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../repository/repository.dart';
import '../utils/enums.dart';
import '../utils/shared_preferences_helper.dart';

class LoginViewModel extends ChangeNotifier {

  bool isLoading = false;
  String errorMessage = "";

  String countryCode = '91';
  late TextEditingController mobileNoController;
  late TextEditingController passwordController;
  bool isObscure = true;

  final ApiRepository repository;
  final Function(String) onLoginSuccess;

  LoginViewModel({required this.repository, required this.onLoginSuccess}) {
    initState();
  }

  void initState() {
    mobileNoController = TextEditingController();
    passwordController = TextEditingController();
  }

  void onIsObscureChanged() {
    isObscure = !isObscure;
    notifyListeners();
  }

  Future<void> login() async {
    isLoading = true;
    errorMessage = "";
    notifyListeners();

    try {
      String mobileNumber = mobileNoController.text.trim();
      String password = passwordController.text.trim();

      if (mobileNumber.isEmpty || password.isEmpty) {
        isLoading = false;
        errorMessage = "Both fields are required!";
        notifyListeners();
        return;
      }else if(mobileNumber.length < 6 || password.length < 5) {
        isLoading = false;
        errorMessage = "Invalid Mobile number or Password!";
        notifyListeners();
        return;
      }

      String cleanedCountryCode = countryCode.replaceAll("+", "");
      Map<String, Object> body = {
        'countryCode' : cleanedCountryCode,
        'mobileNumber': mobileNumber,
        'password': password,
        'isMobile' : kIsWeb? false : true,
      };

      final response = await repository.checkLoginAuth(body);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {
        final userData = data['data']['user'];
        await PreferenceHelper.saveUserDetails(
          token: userData['accessToken'],
          userId: userData['userId'],
          userName: userData['userName'],
          role: userData['userType'],
          countryCode: cleanedCountryCode,
          mobileNumber: mobileNumber,
          email: userData['email'],
        );
        onLoginSuccess(data['message']);
      } else {
        isLoading = false;
        errorMessage = data['message'];
        notifyListeners();
      }
    } catch (error) {
      isLoading = false;
      errorMessage = "An error occurred: $error";
      notifyListeners();
    }
  }

}