import '../utils/enums.dart';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String mobileNo;
  final String countryCode;
  final UserRole role;
  final String token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNo,
    required this.countryCode,
    required this.role,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId'] ?? 0,
      name: json['userName'] ?? '',
      email: json['email'] ?? '',
      mobileNo: json['mobileNumber'] ?? '',
      countryCode: json['countryCode'] ?? '',
      role: _mapRole(json['userType']),
      token: json['accessToken'] ?? '',
    );
  }

  static UserRole _mapRole(String? userType) {
    switch (userType) {
      case '1':
        return UserRole.admin;
      case '2':
        return UserRole.dealer;
      case '3':
      default:
        return UserRole.customer;
    }
  }

  factory UserModel.empty() {
    return UserModel(
      id: 0,
      name: '',
      email: '',
      mobileNo: '',
      countryCode: '',
      role: UserRole.customer,
      token: '',
    );
  }
}