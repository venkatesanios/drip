import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../layouts/user_layout.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../view_models/login_view_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(
        repository: RepositoryImpl(HttpService()),
        onLoginSuccess: (message) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        },
      ),
      child: const LoginScreenLayout(),
    );
  }
}