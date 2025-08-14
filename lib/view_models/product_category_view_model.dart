import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../Models/entry_form/product_category_model.dart';
import '../repository/repository.dart';

class ProductCategoryViewModel extends ChangeNotifier {
  final Repository repository;
  List<ProductCategoryModel> categoryList = <ProductCategoryModel>[];
  bool isLoadingCategory = false;

  ProductCategoryViewModel(this.repository);

  Future<void> getProductCategory() async {
    setCategoryLoading(true);
    try {
      var response = await repository.fetchCategory();
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Category:${response.body}');
        if (jsonData["code"] == 200) {
          final cntList = jsonData["data"] as List;
          categoryList.clear();
          for (int i=0; i < cntList.length; i++) {
            categoryList.add(ProductCategoryModel.fromJson(cntList[i]));
          }
          setCategoryLoading(false);
        }
      }
    } catch (error) {
      debugPrint('Error fetching category list: $error');
      setCategoryLoading(false);
    }
  }

  void setCategoryLoading(bool loadingState) {
    isLoadingCategory = loadingState;
    notifyListeners();
  }
}