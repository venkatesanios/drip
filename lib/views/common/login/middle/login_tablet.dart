import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../flavors.dart';
import '../../../../view_models/login_view_model.dart';
import '../widgets/continue_button.dart';
import '../widgets/login_header.dart';
import '../widgets/password_input_field.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/wide_layout.dart';

class LoginTablet extends StatelessWidget {
  const LoginTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    final isOro = F.appFlavor!.name.contains('oro');
    return Scaffold(
      body: SafeArea(
        child: WideLayout(isOro: isOro, viewModel: viewModel),
      ),
    );
  }

}