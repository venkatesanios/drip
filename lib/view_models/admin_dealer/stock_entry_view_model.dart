import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/admin_dealer/stock_model.dart';
import '../../models/admin_dealer/new_stock_model.dart';
import '../../models/admin_dealer/simple_category.dart';
import '../../repository/repository.dart';

class StockEntryViewModel extends ChangeNotifier {
  final Repository repository;

  List<StockModel> productStockList = <StockModel>[];

  final TextEditingController modelTextController = TextEditingController();
  final TextEditingController imeiController = TextEditingController();
  final TextEditingController warrantyMonthsController = TextEditingController();
  final TextEditingController manufacturingDateController = TextEditingController();
  String errorMsg = '';

  List<SimpleCategory> categoryList = [];
  List<DropdownMenuEntry<ProductModel>> modelEntries = [];
  SimpleCategory? selectedCategory;

  int selectedCategoryId = 0;
  int selectedModelId = 0;

  List<Map<String, dynamic>> addedProductList = [];

  StockEntryViewModel(this.repository) {
    _setupInitialValues();
    fetchCategoryList();
  }

  void _setupInitialValues() {
    imeiController.addListener(() {
      imeiController.value = imeiController.value.copyWith(
        text: imeiController.text.toUpperCase(),
        selection: TextSelection.collapsed(offset: imeiController.text.length),
      );
    });
    warrantyMonthsController.text = '12';
    manufacturingDateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

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

  //for stock form
  Future<void> fetchCategoryList() async {
    try {
      var response = await repository.fetchActiveCategory({"active": "1"});
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          final categories = jsonData["data"] as List?;
          if (categories != null) {
            categoryList = categories.map((item) => SimpleCategory(
              id: item["categoryId"],
              name: item["categoryName"],
            )).toList();
            notifyListeners();
          }
        }
      }
    } catch (error) {
      errorMsg = 'Error fetching category list: $error';
    }
  }

  Future<void> getModelsByCategoryId() async {
    if (selectedCategoryId == 0) return;
    try {
      var response = await repository.fetchModelByCategoryId({"categoryId": selectedCategoryId});
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          final models = jsonData["data"] as List?;
          if (models != null) {
            modelEntries = models.map((item) {
              final model = ProductModel.fromJson(item);
              return DropdownMenuEntry<ProductModel>(
                value: model,
                label: model.modelName,
              );
            }).toList();
            notifyListeners();
          }
        }
      }
    } catch (error) {
      errorMsg = 'Error fetching models: $error';
    }
  }

  Future<void> saveStockListToLocal() async {
    errorMsg = '';
    if (selectedCategoryId == 0 || selectedModelId == 0) {
      errorMsg = 'Category and Model must be selected!';
      notifyListeners();
      return;
    }

    if (_isAnyFieldEmpty()) {
      errorMsg = 'All fields are required!';
      notifyListeners();
      return;
    }

    String imei = imeiController.text.trim();
    if (isIMEIAlreadyExists(imei)) {
      errorMsg = 'Device ID already exists!';
      notifyListeners();
      return;
    }

    try {
      var response = await repository.checkProduct({"deviceId": imei});
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['code'] == 404) {
          addProductToList();
        } else {
          errorMsg = 'The product ID already exists!';
          notifyListeners();
        }
      }
    } catch (error) {
      errorMsg = 'Error checking product: $error';
      notifyListeners();
    }
  }

  void removeNewStock(int index) {
    addedProductList.removeAt(index);
    notifyListeners();
  }

  Future<void> addProductStock(int userId, context) async {
    Navigator.pop(context);
    try {
      var response = await repository.createProduct({
        'products': addedProductList,
        'createUser': userId,
      });

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          _clearForm();
          Map<String, dynamic> result = {
            'status': 'success',
            'message': 'Stock Added successfully',
            'data': jsonData["data"],
            'products': addedProductList,
          };
          addedProductList.clear();
          notifyListeners();
        }else{
          errorMsg = jsonData["message"];
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  void _clearForm() {
    imeiController.clear();
    manufacturingDateController.clear();
    warrantyMonthsController.clear();
  }

  bool _isAnyFieldEmpty() {
    return imeiController.text.trim().isEmpty ||
        manufacturingDateController.text.trim().isEmpty ||
        warrantyMonthsController.text.trim().isEmpty;
  }

  void addProductToList() {
    addedProductList.add({
      "categoryName": selectedCategory!.name,
      "categoryId": selectedCategoryId.toString(),
      "modelName": modelTextController.text,
      "modelId": selectedModelId.toString(),
      "deviceId": imeiController.text.trim(),
      "productDescription": '',
      "dateOfManufacturing": manufacturingDateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').format(
          DateTime.tryParse(manufacturingDateController.text) ?? DateTime.now())
          : "",
      "warrantyMonths": warrantyMonthsController.text,
    });
    notifyListeners();
  }

  bool isIMEIAlreadyExists(String newIMEI) {
    return addedProductList.any((product) => product['deviceId'] == newIMEI);
  }


}