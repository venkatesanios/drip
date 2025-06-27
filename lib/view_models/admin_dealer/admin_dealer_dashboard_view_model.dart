import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../../Models/entry_form/product_category_model.dart';
import '../../models/admin_dealer/customer_list_model.dart';
import '../../models/admin_dealer/stock_model.dart';
import '../../models/sales_data_model.dart';
import '../../repository/repository.dart';
import '../../views/admin_dealer/admin_dashboard.dart';
import 'package:flutter/material.dart';

class AdminAndDealerDashboardViewModel extends ChangeNotifier {
  final Repository repository;

  final int userId, userType;
  List<StockModel> productStockList = [];
  List<CustomerListModel> myCustomerList = [];
  List<CustomerListModel> filteredCustomerList = [];

  SalesDataModel mySalesData = SalesDataModel(graph: {}, total: []);
  int totalSales = 0;

  bool isLoadingSalesData = false;
  bool isLoadingCustomerData = false;
  bool accountCreated = false;
  bool searched = false;

  String responseMsg = '';
  MySegment segmentView = MySegment.all;

  final TextEditingController txtFldSearch = TextEditingController();

  List<ProductCategoryModel> categoryList = <ProductCategoryModel>[];

  AdminAndDealerDashboardViewModel(this.repository, this.userId, this.userType) {
    getCategoryList();
  }

  @override
  void dispose() {
    txtFldSearch.dispose();
    super.dispose();
  }

  Future<void> getCategoryList() async {
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
          notifyListeners();
        }
      }
    } catch (error) {
      debugPrint('Error fetching category list: $error');
    }
  }

  // ------------------ SALES ------------------

  Future<void> getMySalesData(int userId, MySegment segment) async {
    _setLoadingSales(true);

    final body = {
      "userId": userId,
      "userType": 1,
      "type": segment == MySegment.all ? 'All' : 'Year',
      "year": 2024,
    };

    try {
      final response = await repository.fetchAllMySalesReports(body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["code"] == 200 && data.containsKey("data")) {
          mySalesData = SalesDataModel.fromJson(data);
          totalSales = mySalesData.total?.fold(0, (sum, e) => sum! + e.totalProduct) ?? 0;
        } else {
          debugPrint("API Error: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
      }
    } catch (e, st) {
      debugPrint('Error: $e\n$st');
    } finally {
      _setLoadingSales(false);
    }
  }

  // ------------------ STOCK ------------------

  Future<void> getMyStock() async {
    _setLoadingSales(true);

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
      _setLoadingSales(false);
    }
  }

  Future<void> updateStockList(Map<String, dynamic> json) async {
    if (json['status'] != 'success') return;

    final dataList = json["data"] ?? [];
    final products = json["products"] ?? [];

    for (var d in dataList) {
      for (var p in products) {
        if (p["deviceId"] == d["deviceId"]) {
          p["productId"] = d["productId"];
        }
      }
    }

    final newStocks = products.map((e) => StockModel.fromJson(e)).toList();
    productStockList.insertAll(0, newStocks);

    notifyListeners();
  }

  Future<void> removeStockList(Map<String, dynamic> json) async {
    if (json['status'] != 'success') return;

    for (var p in json['products']) {
      productStockList.removeWhere((item) => item.productId == p['productId']);
    }

    notifyListeners();
  }

  // ------------------ CUSTOMERS ------------------

  Future<void> getMyCustomers() async {
    _setLoadingCustomer(true);

    final body = {"userId": userId, "userType": userType};

    try {
      final response = await repository.fetchMyCustomerList(body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(response.body);
        if (data["code"] == 200) {
          final list = data["data"];
          if (list is List) {
            myCustomerList = list.map((e) => CustomerListModel.fromJson(e)).toList();
            _refreshFilter();
          }
        } else {
          debugPrint("API Error: ${data['message']}");
        }
      }
    } catch (e, st) {
      debugPrint('Customer fetch error: $e\n$st');
    } finally {
      _setLoadingCustomer(false);
    }
  }

  Future<void> updateCustomerList(Map<String, dynamic> json) async {
    if (json['status'] != 'success') return;

    final newCustomer = CustomerListModel(
      userId: json['userId'],
      userName: json['userName'],
      countryCode: json['countryCode'],
      mobileNumber: json['mobileNumber'],
      emailId: json['emailId'],
      serviceRequestCount: json['serviceRequestCount'],
      criticalAlarmCount: json['criticalAlarmCount'],
    );

    if (!myCustomerList.any((c) => c.userId == newCustomer.userId)) {
      myCustomerList.add(newCustomer);
      _refreshFilter();
      accountCreated = true;
      responseMsg = json['message'];
      notifyListeners();
    }
  }

  // ------------------ FILTER / SEARCH ------------------

  void filterCustomer(String query) {
    filteredCustomerList = myCustomerList.where((customer) {
      final q = query.toLowerCase();
      return customer.userName.toLowerCase().contains(q) || customer.mobileNumber.toLowerCase().contains(q);
    }).toList();

    notifyListeners();
  }

  void searchCustomer() {
    searched = true;
    filterCustomer(txtFldSearch.text);
  }

  void clearSearch() {
    searched = false;
    txtFldSearch.clear();
    _refreshFilter();
    notifyListeners();
  }

  void _refreshFilter() {
    filteredCustomerList = searched
        ? myCustomerList.where((customer) {
      final q = txtFldSearch.text.toLowerCase();
      return customer.userName.toLowerCase().contains(q) || customer.mobileNumber.toLowerCase().contains(q);
    }).toList()
        : List.from(myCustomerList);
  }

  // ------------------ UTILITY ------------------

  void updateSegmentView(MySegment newSegment) {
    segmentView = newSegment;
    notifyListeners();
  }

  void _setLoadingSales(bool loading) {
    isLoadingSalesData = loading;
    notifyListeners();
  }

  void _setLoadingCustomer(bool loading) {
    isLoadingCustomerData = loading;
    notifyListeners();
  }

  void onCustomerProductChanged(String action) {
    print(action);
    switch (action) {
      case 'added'||'removed':
        getMyStock();
        break;
      case 'delete':
        break;
    }
  }
}