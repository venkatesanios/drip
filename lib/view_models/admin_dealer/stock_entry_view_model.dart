import 'dart:convert';

import 'package:flutter/cupertino.dart';
import '../../Models/admin_dealer/stock_model.dart';
import '../../repository/repository.dart';

class StockEntryViewModel extends ChangeNotifier {
  final Repository repository;

  List<StockModel> productStockList = <StockModel>[];

  StockEntryViewModel(this.repository);

  Future<void> getMyStock(int userId, int userType) async {
    Map<String, dynamic> body = {
      "userType": userType,
      "userId": userId,
    };
    try {
      var response = await repository.fetchMyStocks(body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if(jsonData["code"] == 200){
          final List<dynamic> stockList = jsonData["data"] ?? [];
          productStockList = stockList.map((item) => StockModel.fromJson(item)).toList();
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Error fetching Product stock: $error');
      debugPrint(stackTrace.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateStockList(Map<String, dynamic> jsonData) async {
    if (jsonData['status'] == 'success') {
      List<dynamic> dataList = jsonData["data"] ?? [];
      List<dynamic> productList = jsonData["products"] ?? [];

      for (var dataItem in dataList) {
        String dataDeviceId = dataItem["deviceId"];
        int productId = dataItem["productId"];

        for (var product in productList) {
          if (product["deviceId"] == dataDeviceId) {
            product["productId"] = productId;
          }
        }
      }

      productStockList.insertAll(0,
        productList.map((product) => StockModel.fromJson(product)).toList(),
      );

      notifyListeners();
    }
  }

  Future<void> removeStockList(Map<String, dynamic> jsonData) async {
    if(jsonData['status']=='success'){
      for (var product in jsonData['products']) {
        productStockList.removeWhere((stockItem) => stockItem.productId == product['productId']);
      }
      notifyListeners();
    }
  }


}