import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/admin_dealer/language_list.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../repository/repository.dart';
import '../utils/enums.dart';
import '../utils/snack_bar.dart';

class UserSettingViewModel extends ChangeNotifier {
  final Repository repository;

  bool isLoading = false;
  String errorMsg = '';

  final List<LanguageList> languageList = <LanguageList>[];
  String mySelection = 'English';

  String userName, mobileNo, emailId;
  String countryCode;

  final TextEditingController controllerMblNo = TextEditingController();
  final TextEditingController controllerUsrName = TextEditingController();
  final TextEditingController controllerAccountTye = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();

  final TextEditingController controllerOldPwd = TextEditingController();
  final TextEditingController controllerNewPwd = TextEditingController();
  final TextEditingController controllerConfirmPwd = TextEditingController();
  bool isObscure = true;

  final formKey = GlobalKey<FormState>();
  final formSKey = GlobalKey<FormState>();

  UserSettingViewModel(this.repository, this.userName, this.countryCode, this.mobileNo, this.emailId, String role) {
    print('countryCode:$countryCode');
    _setupInitialValues(role);
  }

  void _setupInitialValues(String role) {
    controllerUsrName.text = userName;
    controllerAccountTye.text = role;
    controllerEmail.text = emailId;
    controllerMblNo.text = mobileNo;
  }

  String removeCountryCode(String phoneNumber) {
    RegExp regExp = RegExp(r'^\+\d{1,4}\s?');
    return phoneNumber.replaceAll(regExp, '');
  }

  void onIsObscureChanged() {
    isObscure = !isObscure;
    notifyListeners();
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

  Future<void> updateUserProfile(BuildContext context, int customerId, userId) async
  {
    if (formKey.currentState!.validate()) {
      String cleanedCode = countryCode.replaceAll('+', '');
      final body = {"userId": customerId, "userName": controllerUsrName.text, "countryCode": cleanedCode, "mobileNumber": controllerMblNo.text,
        "emailAddress": controllerEmail.text, "modifyUser": userId};
      setLoading(true);
      print(body);
      try {
        var response = await repository.updateUserDetails(body);
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          print(response.body);
          if (jsonData["code"] == 200) {
            GlobalSnackBar.show(context, jsonData["message"], jsonData["code"]);

            final userProvider = context.read<UserProvider>();
            final updatedUser = UserModel(
              id: customerId,
              name: controllerUsrName.text,
              mobileNo: controllerMblNo.text,
              countryCode: countryCode.replaceAll('+', ''),
              email: controllerEmail.text,
              token: userProvider.loggedInUser.token,
              role: userProvider.loggedInUser.id == customerId ?
              userProvider.loggedInUser.role :
              userProvider.viewedCustomer?.role ?? UserRole.customer,
            );
            userProvider.updateUser(updatedUser);

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
    controllerAccountTye.dispose();
    controllerEmail.dispose();
    controllerOldPwd.dispose();
    controllerNewPwd.dispose();
    controllerConfirmPwd.dispose();
    super.dispose();
  }

}