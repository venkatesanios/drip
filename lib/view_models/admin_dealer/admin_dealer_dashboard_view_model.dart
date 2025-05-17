import 'dart:convert';

import 'package:flutter/cupertino.dart';
import '../../models/admin_dealer/customer_list_model.dart';
import '../../models/admin_dealer/stock_model.dart';
import '../../models/sales_data_model.dart';
import '../../repository/repository.dart';
import '../../views/admin_dealer/admin_dashboard.dart';

class AdminAndDealerDashboardViewModel extends ChangeNotifier {

  final Repository repository;

  List<StockModel> productStockList = <StockModel>[];
  List<CustomerListModel> myCustomerList = <CustomerListModel>[];
  bool accountCreated = false;
  String responseMsg = '';

  late SalesDataModel mySalesData;
  int totalSales = 0;
  bool isLoadingSalesData = false;
  bool isLoadingCustomerData = false;
  MySegment segmentView = MySegment.all;

  TextEditingController txtFldSearch = TextEditingController();
  bool searched = false;
  List<CustomerListModel> filteredCustomerList = [];


  AdminAndDealerDashboardViewModel(this.repository){
    mySalesData = SalesDataModel(graph: {}, total: []);
    MySegment.all;

  }

  @override
  void dispose() {
    txtFldSearch.dispose();
    super.dispose();
  }

  Future<void> getMySalesData(int userId, MySegment segment) async {
    isLoadingSalesData = true;
    notifyListeners();

    Map<String, Object> body = {
      "userId": userId,
      "userType": 1,
      "type": segment.index == 0 ? 'All' : 'Year',
      "year": 2024,
    };

    try {
      var response = await repository.fetchAllMySalesReports(body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200 && jsonData.containsKey("data")) {
          mySalesData = SalesDataModel.fromJson(jsonData);
          totalSales = mySalesData.total?.fold<int>(0, (sum, item) => sum + item.totalProduct) ?? 0;
        } else {
          debugPrint("API Error: ${jsonData['message'] ?? 'Unknown error'}");
        }
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
      }
    } catch (error, stackTrace) {
      debugPrint('Error fetching sales data: $error');
      debugPrint(stackTrace.toString());
    } finally {
      isLoadingSalesData = false;
      notifyListeners();
    }
  }

  Future<void> getMyStock(int userId, int userType) async {
    isLoadingSalesData = true;
    notifyListeners();

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
      isLoadingSalesData = false;
      notifyListeners();
    }
  }

  Future<void> getMyCustomers(int userId, int userType) async {
    isLoadingCustomerData = true;
    notifyListeners();

    Map<String, dynamic> body = {
      "userType": userType,
      "userId": userId,
    };

    try {
      var response = await repository.fetchMyCustomerList(body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          final customerList = jsonData["data"];
          if (customerList is List) {
            myCustomerList = customerList.map((item) => CustomerListModel.fromJson(item)).toList();
            filteredCustomerList = myCustomerList;
          } else {
            debugPrint("Unexpected data format: 'data' is not a List");
          }
        } else {
          debugPrint("API Error: ${jsonData['message']}");
        }
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
      }
    } catch (error, stackTrace) {
      debugPrint('Error fetching customers: $error');
      debugPrint(stackTrace.toString());
    } finally {
      isLoadingCustomerData = false;
      notifyListeners();
    }
  }

  void updateSegmentView(MySegment newSegment) {
    segmentView = newSegment;
    notifyListeners();
  }

  Future<void> updateCustomerList(Map<String, dynamic> jsonData) async {
    if(jsonData['status']=='success'){
      myCustomerList.add(CustomerListModel(userId: jsonData['userId'], userName: jsonData['userName'],
          countryCode : jsonData['countryCode'], mobileNumber : jsonData['mobileNumber'],
          emailId : jsonData['emailId'], serviceRequestCount : jsonData['serviceRequestCount'],
          criticalAlarmCount : jsonData['criticalAlarmCount']));
      responseMsg = jsonData['message'];
      accountCreated = true;
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

  void filterCustomer(value){
    filteredCustomerList = myCustomerList.where((customer) {
      return customer.userName.toLowerCase().contains(value.toLowerCase()) ||
          customer.mobileNumber.toLowerCase().contains(value.toLowerCase());
    }).toList();
    notifyListeners();
  }

  void searchCustomer() {
    searched = true;
    notifyListeners();
  }

  void clearSearch() {
    searched = false;
    filteredCustomerList = myCustomerList;
    txtFldSearch.clear();
    notifyListeners();
  }
}