import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../view_models/account_setting_view_model.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedInUser = context.read<UserProvider>().loggedInUser;
    final viewedCustomer = context.read<UserProvider>().viewedCustomer!;

    return ChangeNotifierProvider(
      create: (_) => UserSettingViewModel(Repository(HttpService()),
          viewedCustomer.name, viewedCustomer.countryCode, viewedCustomer.mobileNo,
          viewedCustomer.email, viewedCustomer.role.name)..getLanguage(),
      child: Consumer<UserSettingViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  tileColor: Colors.white,
                  title: Text("Profile Settings", style: TextStyle(fontSize: 20, color: Colors.black),),
                  subtitle: Text('Real-time Information and activity of your property.'),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 220,
                          child: Form(
                            key: viewModel.formKey,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: TextFormField(
                                      controller: viewModel.controllerUsrName,
                                      decoration: const InputDecoration(
                                          labelText: 'Full Name',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.account_circle),
                                          filled: true,
                                          fillColor: Colors.white70
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: IntlPhoneField(
                                      focusNode:  FocusNode(),
                                      decoration: InputDecoration(
                                        labelText: null,
                                        border: const OutlineInputBorder(
                                          borderSide: BorderSide(),
                                        ),
                                        prefixIcon: const Icon(Icons.phone),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.clear, color: Colors.red),
                                          onPressed: () => viewModel.controllerMblNo.clear(),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white70,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                                        counterText: '',
                                      ),
                                      languageCode: "en",
                                      initialCountryCode: 'IN',
                                      controller: viewModel.controllerMblNo,
                                      onChanged: (phone) {
                                        print(phone.completeNumber);
                                      },
                                      onCountryChanged: (country) => viewModel.countryCode = country.dialCode,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: TextFormField(
                                      controller: viewModel.controllerEmail,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                          labelText: 'Email Address',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.email),
                                          filled: true,
                                          fillColor: Colors.white70
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email address';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const ListTile(
                          title: Text("Security", style: TextStyle(fontSize: 20, color: Colors.black)),
                          subtitle: Text('Modify your current password'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left:16, top: 10, right: 16),
                          child: TextFormField(
                            controller: viewModel.controllerNewPwd,
                            obscureText: viewModel.isObscureNpw,
                            decoration: InputDecoration(
                                labelText: 'New Password',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.password),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    viewModel.isObscureNpw ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.black87,
                                  ),
                                  onPressed: () => viewModel.onIsObscureChangedToNpw(),
                                ),
                                filled: true,
                                fillColor: Colors.white70
                            ),
                            autofillHints: const [AutofillHints.newPassword],
                            keyboardType: TextInputType.visiblePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left:16, top: 10, right: 16),
                          child: TextFormField(
                            controller: viewModel.controllerConfirmPwd,
                            obscureText: viewModel.isObscureCpw,
                            decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.password),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    viewModel.isObscureCpw ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.black87,
                                  ),
                                  onPressed: () => viewModel.onIsObscureChangedToCpw(),
                                ),
                                filled: true,
                                fillColor: Colors.white70
                            ),
                            autofillHints: const [AutofillHints.newPassword],
                            keyboardType: TextInputType.visiblePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  width: MediaQuery.sizeOf(context).width,
                  height: 45,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Spacer(),
                      MaterialButton(
                        minWidth:100,
                        height: 40,
                        color: Colors.red,
                        textColor: Colors.white,
                        child: const Text('CANCEL'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      MaterialButton(
                        minWidth:175,
                        height: 40,
                        color: Theme.of(context).primaryColorLight,
                        textColor: Colors.white,
                        child: const Text('SAVE CHANGES'),
                        onPressed: ()=> viewModel.updateUserProfile(context, viewedCustomer.id, loggedInUser.id),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}