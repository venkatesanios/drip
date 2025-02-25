import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/admin&dealer/new_stock_model.dart';
import '../../models/admin&dealer/simple_category.dart';
import '../../repository/repository.dart';

class NewStockViewModel extends ChangeNotifier {
  final Repository repository;

  bool isLoading = false;
  String errorMsg = '';

  final TextEditingController modelTextController = TextEditingController();
  final TextEditingController imeiController = TextEditingController();
  final TextEditingController warrantyMonthsController = TextEditingController();
  final TextEditingController manufacturingDateController = TextEditingController();

  List<SimpleCategory> categoryList = [];
  List<DropdownMenuEntry<ProductModel>> modelEntries = [];
  SimpleCategory? selectedCategory;

  int selectedCategoryId = 0;
  int selectedModelId = 0;
  bool isEditing = false;

  List<Map<String, dynamic>> addedProductList = [];

  final Function(Map<String, dynamic>) onStockCreatedCallbackFunction;

  NewStockViewModel(this.repository, {required this.onStockCreatedCallbackFunction}) {
    _setupInitialValues();
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

  Future<void> fetchCategoryList() async {
    setLoading(true);
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
          }
        }
      }
    } catch (error) {
      errorMsg = 'Error fetching category list: $error';
    } finally {
      setLoading(false);
    }
  }

  Future<void> getModelsByCategoryId() async {
    if (selectedCategoryId == 0) return;

    setLoading(true);
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
          }
        }
      }
    } catch (error) {
      errorMsg = 'Error fetching models: $error';
    } finally {
      setLoading(false);
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

    setLoading(true);
    try {
      var response = await repository.checkProduct({"deviceId": imei});
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['code'] == 404) {
          addProductToList();
        } else {
          errorMsg = 'The product ID already exists!';
        }
      }
    } catch (error) {
      errorMsg = 'Error checking product: $error';
    } finally {
      setLoading(false);
    }
  }

  void removeNewStock(int index) {
    addedProductList.removeAt(index);
    notifyListeners();
  }

  Future<void> addProductStock(int userId, context) async {
    Navigator.pop(context);
    setLoading(true);
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
          onStockCreatedCallbackFunction(result);
        }else{
          errorMsg = jsonData["message"];
        }
      }
    } catch (error) {
      debugPrint(error.toString());
    } finally {
      setLoading(false);
    }
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
      "dateOfManufacturing": manufacturingDateController.text,
      "warrantyMonths": warrantyMonthsController.text,
    });
    notifyListeners();
  }

  bool isIMEIAlreadyExists(String newIMEI) {
    return addedProductList.any((product) => product['deviceId'] == newIMEI);
  }

  void _clearForm() {
    imeiController.clear();
    manufacturingDateController.clear();
    warrantyMonthsController.clear();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    modelTextController.dispose();
    imeiController.dispose();
    warrantyMonthsController.dispose();
    manufacturingDateController.dispose();
    super.dispose();
  }
}