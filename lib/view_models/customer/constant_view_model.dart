import 'dart:convert';

import 'package:flutter/cupertino.dart';
import '../../Models/customer/constant_model.dart';
import '../../repository/repository.dart';

class ConstantViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";

  late UserConstant userConstant;
  late List<ConstantMenu> filteredMenu = [];


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
            menuOnChange();

          }
        }
      } catch (error) {
        debugPrint('Error fetching language list: $error');
      } finally {
        setLoading(false);
      }
    });

  }

  void menuOnChange(){
    filteredMenu[0].isSelected = true;
  }


  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

}