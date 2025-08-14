import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../models/admin_dealer/customer_list_model.dart';
import '../repository/repository.dart';

class CustomerListViewModel extends ChangeNotifier {
  final Repository repository;
  final int userId;
  List<CustomerListModel> myCustomerList = [];
  List<CustomerListModel> filteredCustomerList = [];

  bool isLoadingCustomer = false;
  bool accountCreated = false;
  String responseMsg = '';

  bool searched = false;
  final TextEditingController txtFldSearch = TextEditingController();

  CustomerListViewModel(this.repository, this.userId);

  Future<void> getMyCustomers(int userType) async {
    setCustomerLoading(true);

    final body = {"userId": userId, "userType": userType};

    try {
      final response = await repository.fetchMyCustomerList(body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["code"] == 200) {
          final list = data["data"];
          if (list is List) {
            myCustomerList = list.map((e) => CustomerListModel.fromJson(e)).toList();
            refreshFilter();
          }
        } else {
          debugPrint("API Error: ${data['message']}");
        }
      }
    } catch (e, st) {
      debugPrint('Customer fetch error: $e\n$st');
    } finally {
      setCustomerLoading(false);
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
      refreshFilter();
      accountCreated = true;
      responseMsg = json['message'];
      notifyListeners();
    }
  }

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
    refreshFilter();
    notifyListeners();
  }

  void refreshFilter() {
    filteredCustomerList = searched ? myCustomerList.where((customer) {
      final q = txtFldSearch.text.toLowerCase();
      return customer.userName.toLowerCase().contains(q) || customer.mobileNumber.toLowerCase().contains(q);
    }).toList() : List.from(myCustomerList);
  }

  void setCustomerLoading(bool loadingState) {
    isLoadingCustomer = loadingState;
    notifyListeners();
  }

}