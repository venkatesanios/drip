import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/enums.dart';

class UserProvider extends ChangeNotifier {
  UserModel _loggedInUser = UserModel.empty();
  UserModel? _viewedCustomer;

  UserModel get loggedInUser => _loggedInUser;
  UserModel? get viewedCustomer => _viewedCustomer;
  UserRole get role => _loggedInUser.role;

  void setLoggedInUser(UserModel user) {
    _loggedInUser = user;
    notifyListeners();
  }

  void setViewedCustomer(UserModel customer) {
    _viewedCustomer = customer;
    notifyListeners();
  }

  void clearViewedCustomer() {
    _viewedCustomer = null;
    notifyListeners();
  }

  void updateUser(UserModel updatedUser) {
    if (_loggedInUser.id == updatedUser.id) {
      _loggedInUser = updatedUser;
      _viewedCustomer = updatedUser;
    } else if (_viewedCustomer?.id == updatedUser.id) {
      _viewedCustomer = updatedUser;
    }
    notifyListeners();
  }
}