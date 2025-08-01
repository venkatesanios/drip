import '../utils/enums.dart';

class UserModel {
  final int userId;
  final String userName;
  final String email;
  final String mobileNumber;
  final String countryCode;
  final UserRole role;
  final String token;

  UserModel({
    required this.userId,
    required this.userName,
    required this.email,
    required this.mobileNumber,
    required this.countryCode,
    required this.role,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
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
      userId: 0,
      userName: '',
      email: '',
      mobileNumber: '',
      countryCode: '',
      role: UserRole.customer,
      token: '',
    );
  }
}