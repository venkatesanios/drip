import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../../Models/admin_dealer/stock_model.dart';
import '../../repository/repository.dart';

enum MasterController {gem1, gem2, gem3, gem4, gem5, gem6, gem7, gem8, gem9, gem10,}

class SiteConfigViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";

  List<StockModel> myMasterControllerList = <StockModel>[];

  int selectedRadioTile = 0;
  final ValueNotifier<MasterController> selectedItem = ValueNotifier<MasterController>(MasterController.gem1);

  final formKey = GlobalKey<FormState>();
  late TextEditingController siteNameController = TextEditingController();
  late TextEditingController siteAddressController = TextEditingController();
  String siteName = '';
  String siteAddress = '';

  SiteConfigViewModel(this.repository);

  Future<void> getMasterProduct(customerId) async
  {
    Map<String, dynamic> body = {
      "userId": customerId,
      "userType": 3,
    };
    try {
      var response = await repository.fetchMasterProductStock(body);
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if(jsonData["code"] == 200){
          myMasterControllerList.clear();
          final cntList = jsonData["data"] as List;
          for (int i=0; i < cntList.length; i++) {
            myMasterControllerList.add(StockModel.fromJson(cntList[i]));
          }
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Error fetching Product stock: $error');
      debugPrint(stackTrace.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> createNewSite(BuildContext context, customerId) async
  {
    if (formKey.currentState!.validate()) {

      siteName = siteNameController.text;
      siteAddress = siteAddressController.text;

      Map<String, dynamic> body = {
        "userId": customerId,
        "productId": myMasterControllerList[selectedRadioTile].productId,
        "createUser": customerId,
        "groupName": siteNameController.text,
      };

      try {
        var response = await repository.createUserGroupAndDeviceList(body);
        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = jsonDecode(response.body);
          if(jsonData["code"] == 200){
            siteNameController.text = '';
            siteAddressController.text = '';
          }
        }
      } catch (error, stackTrace) {
        debugPrint('Error fetching Product stock: $error');
        debugPrint(stackTrace.toString());
      } finally {
        notifyListeners();
      }
    }
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

}