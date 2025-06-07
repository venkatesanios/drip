import 'package:flutter/cupertino.dart';

class SearchProvider extends ChangeNotifier {
  bool _isSearchProduct = false;
  bool get isSearchProduct => _isSearchProduct;

  String _searchValue = '';
  String get searchValue => _searchValue;

  int _filteredCatId = 0;
  int get filteredCategoryId => _filteredCatId;

  int _filteredModelId = 0;
  int get filteredModelId => _filteredModelId;

  bool _hasHandledSearch = false;
  bool get hasHandledSearch => _hasHandledSearch;

  void updateSearch(String value) {
    _searchValue = value;
    _hasHandledSearch = false;
    notifyListeners();
  }

  void updateCategoryId(int categoryId) {
    _filteredCatId = categoryId;
    _hasHandledSearch = false;
    notifyListeners();
  }

  void updateModelId(int modelId) {
    _filteredModelId = modelId;
    _hasHandledSearch = false;
    notifyListeners();
  }

  void isSearchingProduct(bool status) {
    _isSearchProduct = status;
    _hasHandledSearch = false;
    notifyListeners();
  }

  void markSearchHandled() {
    _hasHandledSearch = true;
    notifyListeners();
  }

  void clearSearchFilters() {
    _searchValue = '';
    _filteredCatId = 0;
    _filteredModelId = 0;
    _isSearchProduct = false;
    _hasHandledSearch = false;
    notifyListeners();
  }
}