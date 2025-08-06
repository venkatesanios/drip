import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../flavors.dart';
import '../../../../view_models/login_view_model.dart';
import '../widgets/continue_button.dart';
import '../widgets/login_header.dart';
import '../widgets/password_input_field.dart';
import '../widgets/phone_input_field.dart';

class LoginTablet extends StatelessWidget {
  const LoginTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    final isOro = F.appFlavor!.name.contains('oro');

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).primaryColor,
          child: SingleChildScrollView(
            child: Column(
              children: [
                isOro ? const OroLoginHeader() : const LkLoginHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PhoneInputField(),
                        const SizedBox(height: 15),
                        const PasswordInputField(isWeb: false),
                        if (viewModel.errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 40, top: 8),
                            child: Text(
                              viewModel.errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 20),
                        const ContinueButton(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}