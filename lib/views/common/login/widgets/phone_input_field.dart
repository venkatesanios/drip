import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../../../view_models/login_view_model.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    return IntlPhoneField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.red),
          onPressed: () => viewModel.mobileNoController.clear(),
        ),
        icon: const Icon(Icons.phone_outlined, color: Colors.white),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        counterText: '',
      ),
      languageCode: "en",
      initialCountryCode: 'IN',
      controller: viewModel.mobileNoController,
      onChanged: (phone) {},
      onCountryChanged: (country) => viewModel.countryCode = country.dialCode,
    );
  }
}