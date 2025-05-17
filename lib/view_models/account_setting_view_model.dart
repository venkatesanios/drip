import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../models/admin_dealer/language_list.dart';
import '../repository/repository.dart';
import '../utils/snack_bar.dart';

class UserSettingViewModel extends ChangeNotifier {
  final Repository repository;

  bool isLoading = false;
  String errorMsg = '';

  final List<LanguageList> languageList = <LanguageList>[];
  String mySelection = 'English';

  String userName, mobileNo, emailId;
  String countryCode = '91';

  final TextEditingController controllerMblNo = TextEditingController();
  final TextEditingController controllerUsrName = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPwd = TextEditingController();

  final formKey = GlobalKey<FormState>();

  UserSettingViewModel(this.repository, this.userName, this.mobileNo, this.emailId) {
    _setupInitialValues();
  }

  void _setupInitialValues() {
    controllerUsrName.text = userName;
    controllerEmail.text = emailId;
    controllerPwd.text = '123456';
    countryCode = getCountryCode(mobileNo);
    String phoneWithoutCountryCode = removeCountryCode(mobileNo);
    controllerMblNo.text = phoneWithoutCountryCode;
  }

  String getCountryCode(String phoneNumber) {
    RegExp regExp = RegExp(r'^\+(\d{1,4})');
    Match? match = regExp.firstMatch(phoneNumber);

    if (match != null) {
      return match.group(0) ?? '';
    } else {
      return '';
    }
  }

  String removeCountryCode(String phoneNumber) {
    RegExp regExp = RegExp(r'^\+\d{1,4}\s?');  // Matches the country code (e.g., +91 or +1) and optional space
    return phoneNumber.replaceAll(regExp, '');  // Removes the matched country code
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
      errorMsg = 'Error fetching category list: $error';
    } finally {
      setLoading(false);
    }
  }

  Future<void> updateUserDetails(BuildContext context, int customerId, userId) async
  {
    if (formKey.currentState!.validate()) {
      final body = {"userId": customerId, "userName": controllerUsrName.text, "countryCode": countryCode, "mobileNumber": controllerMblNo.text,
        "emailAddress": controllerEmail.text,"password": controllerPwd.text, "modifyUser": userId};
      setLoading(true);
      try {
        var response = await repository.updateUserDetails(body);
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          if (jsonData["code"] == 200) {
            GlobalSnackBar.show(context, jsonData["message"], jsonData["code"]);
          }
        }
      } catch (error) {
        errorMsg = 'Error fetching category list: $error';
      } finally {
        setLoading(false);
      }
    }

  }


  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    controllerMblNo.dispose();
    controllerUsrName.dispose();
    controllerEmail.dispose();
    controllerPwd.dispose();
    super.dispose();
  }

}