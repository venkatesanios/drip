
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _roleKey = 'user_role';
  static const String _countryCodeKey = 'country_code';
  static const String _mobileNumberKey = 'mobile_number';
  static const String _emailKey = 'email';

  //customer
  static const String _customerIdKey = 'customer_id';

  static Future<void> saveUserDetails({
    required String token,
    required int userId,
    required String userName,
    required String role,
    required String countryCode,
    required String mobileNumber,
    required String email,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_countryCodeKey, countryCode);
    await prefs.setString(_mobileNumberKey, mobileNumber);
    await prefs.setString(_emailKey, email);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }


  static Future<String?> getUserRole() async { // admin,
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getCountryCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_countryCodeKey);
  }

  static Future<String?> getMobileNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mobileNumberKey);
  }

  static Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<void> clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}