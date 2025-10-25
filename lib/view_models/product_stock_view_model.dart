import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../models/admin_dealer/stock_model.dart';
import '../repository/repository.dart';

class ProductStockViewModel extends ChangeNotifier {
  final Repository repository;
  List<StockModel> productStockList = [];
  bool isLoadingStock = false;

  ProductStockViewModel(this.repository);

  Future<void> getMyStock(int userId, int userType) async {
    setStockLoading(true);

    final body = {"userId": userId, "userType": userType};

    try {
      final response = await repository.fetchMyStocks(body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["code"] == 200) {
          final list = data["data"] as List<dynamic>;
          productStockList = list.map((e) => StockModel.fromJson(e)).toList();
        }
      }
    } catch (e, st) {
      debugPrint('Stock fetch error: $e\n$st');
    } finally {
      setStockLoading(false);
    }
  }

  void removeStockModels(List<StockModel> productsToRemove) {
    final idsToRemove = productsToRemove.map((p) => p.productId).toSet();
    productStockList.removeWhere((p) => idsToRemove.contains(p.productId));
    notifyListeners();
  }

  void addStockModels(List<StockModel> productsToAdd) {
    productStockList.insertAll(0, productsToAdd);
    notifyListeners();
  }

  void setStockLoading(bool loadingState) {
    isLoadingStock = loadingState;
    notifyListeners();
  }
}