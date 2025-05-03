import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../repository/repository.dart';
import '../utils/shared_preferences_helper.dart';

class LoginViewModel extends ChangeNotifier {

  bool isLoading = false;
  String errorMessage = "";
  final Repository repository;

  String countryCode = '91';
  late TextEditingController mobileNoController;
  late TextEditingController passwordController;
  bool isObscure = true;

  final Function(String) onLoginSuccess;

  LoginViewModel(this.repository, {required this.onLoginSuccess}){
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

      Map<String, Object> body = {
        'countryCode' : countryCode,
        'mobileNumber': mobileNumber,
        'password': password,
        'isMobile' : kIsWeb? false : true,
      };

      final response = await repository.checkLoginAuth(body);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == 200) {

        final customerData = data["data"];
        final user = customerData["user"];
        print("login user $user");
        String countryCodeFinal = countryCode.replaceAll('+', '');

        await PreferenceHelper.saveUserDetails(
          token: user['accessToken'],
          userId: user['userId'],
          role: user['userType']=='1'? 'admin' : user['userType']=='2' ? 'dealer' :'customer',
          userName: user['userName'],
          countryCode: countryCodeFinal,
          mobileNumber: mobileNumber,
          email: user['email'],
        );

        onLoginSuccess(user['userType']=='1'? 'admin' :
        user['userType']=='2'? 'dealer':'customer');

      } else {
        isLoading = false;
        errorMessage = data['message'];
        notifyListeners();
      }
    } catch (error, stackTrace) {
      isLoading = false;
      errorMessage = "An error occurred: $error";
      notifyListeners();
    }
  }
}