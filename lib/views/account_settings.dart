import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
 import 'package:provider/provider.dart';

import '../repository/repository.dart';
import '../services/http_service.dart';
import '../view_models/account_setting_view_model.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key, required this.userId, required this.userName, required this.mobileNo,
    required this.emailId, required this.customerId, required this.hideAppbar});
  final int userId, customerId;
  final String userName, mobileNo, emailId;
  final bool hideAppbar;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserSettingViewModel(Repository(HttpService()), userName, mobileNo, emailId)..getLanguage(),
      child: Consumer<UserSettingViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: !hideAppbar? AppBar(
              title: const Text('Account Settings'),
              actions: [
                IconButton(onPressed: (){
                  Navigator.pop(context);
                },icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'Close'),
                const SizedBox(width: 16),
              ],
            ) :
            null,
            body: kIsWeb?Container(
              color: Colors.blueGrey.shade50,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      title: Text("Profile Settings", style: TextStyle(fontSize: 20, color: Colors.black),),
                      subtitle: Text('Real-time Information and activity of your property.'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: SizedBox(
                        height: 135,
                        child: Form(
                          key: viewModel.formKey,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        flex:1,
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
                                      const SizedBox(width: 8),
                                      Flexible(
                                        flex:1,
                                        child: TextFormField(
                                          controller: viewModel.controllerUsrName,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            labelText: 'Account type',
                                            border: OutlineInputBorder(),
                                              filled: true,
                                              fillColor: Colors.white70
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        flex:1,
                                        child: IntlPhoneField(
                                          focusNode:  FocusNode(),
                                          decoration: InputDecoration(
                                            labelText: null,
                                            border: const OutlineInputBorder(
                                              borderSide: BorderSide(),
                                            ),
                                            prefixIcon: Icon(Icons.phone),
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
                                      SizedBox(width: 8),
                                      Flexible(
                                        flex:1,
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text('When Mobile Number and Email update', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 8, top: 5),
                      child: Text("OTP (One-Time Password) is crucial when changing your "
                          "mobile number or email associated with the account"
                        , style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 8, top: 5),
                      child: Text("When you initiate such changes, the app often sends"
                          " an OTP to your current registered mobile number or email address."
                          " You need to enter this OTP to confirm and complete the update"
                        , style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ),

                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: 50,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Spacer(),
                          MaterialButton(
                            minWidth:200,
                            height: 45,
                            color: Colors.green,
                            textColor: Colors.white,
                            child: const Text('SAVE CHANGES'),
                            onPressed: ()=> viewModel.updateUserProfile(context, customerId, userId),
                          ),
                          SizedBox(width: 16),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Divider(height: 2, color: Colors.black12),
                    ),

                    ListTile(
                      title: Text("Security", style: TextStyle(fontSize: 20, color: Colors.black)),
                      subtitle: Text('Modify your current password'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: SizedBox(
                        height: 60,
                        child: Form(
                          key: viewModel.formSKey,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Flexible(
                                  flex:1,
                                  child: TextField(
                                    controller: viewModel.controllerOldPwd,
                                    obscureText: viewModel.isObscure,
                                    decoration: InputDecoration(
                                      filled: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                      labelText: 'Password',
                                      labelStyle: const TextStyle(color: Colors.black), // Optional: label text color
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          viewModel.isObscure ? Icons.visibility : Icons.visibility_off,
                                          color: Colors.black87,
                                        ),
                                        onPressed: () => viewModel.onIsObscureChanged(),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.black), // Text color inside TextField
                                  ),
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  flex:1,
                                  child: TextField(
                                    controller: viewModel.controllerNewPwd,
                                    obscureText: viewModel.isObscure,
                                    decoration: InputDecoration(
                                      filled: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                      labelText: 'Password',
                                      labelStyle: const TextStyle(color: Colors.black), // Optional: label text color
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          viewModel.isObscure ? Icons.visibility : Icons.visibility_off,
                                          color: Colors.black87,
                                        ),
                                        onPressed: () => viewModel.onIsObscureChanged(),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.black), // Text color inside TextField
                                  ),
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  flex:1,
                                  child: TextField(
                                    controller: viewModel.controllerConfirmPwd,
                                    obscureText: viewModel.isObscure,
                                    decoration: InputDecoration(
                                      filled: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                      labelText: 'Password',
                                      labelStyle: const TextStyle(color: Colors.black),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          viewModel.isObscure ? Icons.visibility : Icons.visibility_off,
                                          color: Colors.black87,
                                        ),
                                        onPressed: () => viewModel.onIsObscureChanged(),
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.black), // Text color inside TextField
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 8),
                      child: Text('Password requirement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, top: 10),
                      child: Row(
                        children: [
                          Text('1.', style: TextStyle(color: Colors.black54)),
                          SizedBox(width: 10),
                          Text('at least 6 characters password', style: TextStyle(fontSize:12, color: Colors.black45)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, top: 5),
                      child: Row(
                        children: [
                          Text('2.', style: TextStyle(color: Colors.black54)),
                          SizedBox(width: 10,),
                          Text('at least one uppercase letter', style: TextStyle(fontSize:12, color: Colors.black45)),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, top: 5),
                      child: Row(
                        children: [
                          Text('3.', style: TextStyle(color: Colors.black54)),
                          SizedBox(width: 10,),
                          Text('at least one number', style: TextStyle(fontSize:12, color: Colors.black45)),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: 50,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Spacer(),
                          MaterialButton(
                            minWidth:200,
                            height: 45,
                            color: Colors.green,
                            textColor: Colors.white,
                            child: const Text('SAVE CHANGES'),
                            onPressed: ()=> viewModel.updateUserProfile(context, customerId, userId),
                          ),
                          SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ):
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      title: Text("Profile Settings", style: TextStyle(fontSize: 20, color: Colors.black),),
                      subtitle: Text('Real-time Information and activity of your property.'),
                    ),
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
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text('When Mobile Number and Email update', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20, right: 8, top: 5),
                      child: Text("OTP (One-Time Password) is crucial when changing your "
                          "mobile number or email associated with the account"
                        , style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20, right: 8, top: 5, bottom: 8),
                      child: Text("When you initiate such changes, the app often sends"
                          " an OTP to your current registered mobile number or email address."
                          " You need to enter this OTP to confirm and complete the update"
                        , style: TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ),

                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: 50,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Spacer(),
                          MaterialButton(
                            minWidth:175,
                            height: 45,
                            color: Theme.of(context).primaryColorLight,
                            textColor: Colors.white,
                            child: const Text('SAVE CHANGES'),
                            onPressed: ()=> viewModel.updateUserProfile(context, customerId, userId),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 5),
                      child: Divider(height: 2, color: Colors.black12),
                    ),

                    const ListTile(
                      title: Text("Security", style: TextStyle(fontSize: 20, color: Colors.black)),
                      subtitle: Text('Modify your current password'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: SizedBox(
                        height: 200,
                        child: Form(
                          key: viewModel.formSKey,
                          child: Column(
                            children: [
                              TextField(
                                controller: viewModel.controllerOldPwd,
                                obscureText: viewModel.isObscure,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white70,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                  labelText: 'Old Password',
                                  labelStyle: const TextStyle(color: Colors.black), // Optional: label text color
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      viewModel.isObscure ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.black87,
                                    ),
                                    onPressed: () => viewModel.onIsObscureChanged(),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black), // Text color inside TextField
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: viewModel.controllerNewPwd,
                                obscureText: viewModel.isObscure,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white70,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                  labelText: 'New Password',
                                  labelStyle: const TextStyle(color: Colors.black), // Optional: label text color
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      viewModel.isObscure ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.black87,
                                    ),
                                    onPressed: () => viewModel.onIsObscureChanged(),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black), // Text color inside TextField
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: viewModel.controllerConfirmPwd,
                                obscureText: viewModel.isObscure,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white70,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                  labelText: 'Confirm Password',
                                  labelStyle: const TextStyle(color: Colors.black),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      viewModel.isObscure ? Icons.visibility : Icons.visibility_off,
                                      color: Colors.black87,
                                    ),
                                    onPressed: () => viewModel.onIsObscureChanged(),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black), // Text color inside TextField
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(left: 20, top: 8),
                      child: Text('Password requirement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 25, top: 10),
                      child: Row(
                        children: [
                          Text('1.', style: TextStyle(color: Colors.black54)),
                          SizedBox(width: 10),
                          Text('at least 6 characters password', style: TextStyle(fontSize:12, color: Colors.black45)),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 25, top: 5),
                      child: Row(
                        children: [
                          Text('2.', style: TextStyle(color: Colors.black54)),
                          SizedBox(width: 10,),
                          Text('at least one uppercase letter', style: TextStyle(fontSize:12, color: Colors.black45)),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 25, top: 5),
                      child: Row(
                        children: [
                          Text('3.', style: TextStyle(color: Colors.black54)),
                          SizedBox(width: 10,),
                          Text('at least one number', style: TextStyle(fontSize:12, color: Colors.black45)),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 50,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Spacer(),
                            MaterialButton(
                              minWidth:175,
                              height: 45,
                              color: Theme.of(context).primaryColorLight,
                              textColor: Colors.white,
                              child: const Text('SAVE CHANGES'),
                              onPressed: ()=> viewModel.updateUserProfile(context, customerId, userId),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}