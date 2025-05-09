import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
 import 'package:provider/provider.dart';

import '../repository/repository.dart';
import '../services/http_service.dart';
import '../view_models/account_setting_view_model.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key, required this.userId, required this.userName, required this.mobileNo, required this.emailId, required this.customerId});
  final int userId, customerId;
  final String userName, mobileNo, emailId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserSettingViewModel(Repository(HttpService()), userName, mobileNo, emailId)..getLanguage(),
      child: Consumer<UserSettingViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Profile')),
            body: kIsWeb?Container(
              color: Colors.blueGrey.shade50,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blueGrey.shade50,
                      child: Row(
                        children: [
                          Flexible(
                            flex :1,
                            fit: FlexFit.loose,
                            child: Container(
                              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.sizeOf(context).height-70,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 50,
                                            decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10.0),
                                                  topRight: Radius.circular(10.0),
                                                )
                                            ),
                                            child: const ListTile(
                                              title: Text("Account Settings", style: TextStyle(fontSize: 20, color: Colors.black),),
                                              trailing: Icon(Icons.more_horiz, color: Colors.blue,),
                                            ),
                                          ),
                                          SizedBox(height: 2,child: Container(color: Colors.grey.shade200,)),
                                          Container(
                                            height: 380,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10.0),
                                                bottomRight: Radius.circular(10.0),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  flex :1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Stack(
                                                          children: [
                                                            const Center(
                                                              child: CircleAvatar(
                                                                radius: 60.0,
                                                                //backgroundImage: image == null? AssetImage('assets/your_image.png') : File(image!.path),
                                                              ),
                                                            ),
                                                            // Positioned button in the bottom-right corner
                                                            Positioned(
                                                              bottom: 10.0,
                                                              right: 50.0,
                                                              child: GestureDetector(
                                                                onTap: () async {
                                                                  print('Button tapped!');
                                                                  //_getFromGallery();
                                                                },
                                                                child: const CircleAvatar(
                                                                  radius: 20.0,
                                                                  backgroundColor: Colors.blue,
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 2,
                                                  child: Form(
                                                    key: viewModel.formKey,
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(height: 20),

                                                        // Mobile Number Field
                                                        TextFormField(
                                                          controller: viewModel.controllerMblNo,
                                                          keyboardType: TextInputType.phone,
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter.digitsOnly,
                                                          ],
                                                          decoration: InputDecoration(
                                                            labelText: 'Mobile Number',
                                                            prefixText: '+91 ', // You can make this dynamic
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(10.0),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null || value.isEmpty) {
                                                              return 'Please enter your mobile number';
                                                            } else if (value.length < 10) {
                                                              return 'Mobile number must be at least 10 digits';
                                                            }
                                                            return null;
                                                          },
                                                        ),

                                                        const SizedBox(height: 20),

                                                        // Name Field
                                                        TextFormField(
                                                          controller: viewModel.controllerUsrName,
                                                          decoration: InputDecoration(
                                                            labelText: 'Name',
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(10.0),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null || value.isEmpty) {
                                                              return 'Please enter your name';
                                                            }
                                                            return null;
                                                          },
                                                        ),

                                                        const SizedBox(height: 20),

                                                        // Password Field
                                                        TextFormField(
                                                          controller: viewModel.controllerPwd,
                                                          obscureText: true,
                                                          decoration: InputDecoration(
                                                            labelText: 'Password',
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(10.0),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null || value.isEmpty) {
                                                              return 'Please enter your password';
                                                            }
                                                            return null;
                                                          },
                                                        ),

                                                        const SizedBox(height: 20),

                                                        // Email Field
                                                        TextFormField(
                                                          controller: viewModel.controllerEmail,
                                                          keyboardType: TextInputType.emailAddress,
                                                          decoration: InputDecoration(
                                                            labelText: 'Email Id',
                                                            border: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(10.0),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value == null || value.isEmpty) {
                                                              return 'Please enter your email id';
                                                            }
                                                            return null;
                                                          },
                                                        ),

                                                        const SizedBox(height: 20),

                                                        // Action Buttons
                                                        Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            MaterialButton(
                                                              color: Colors.grey,
                                                              textColor: Colors.white,
                                                              child: const Text('CANCEL'),
                                                              onPressed: () {
                                                                // handle cancel
                                                              },
                                                            ),
                                                            const SizedBox(width: 20),
                                                            MaterialButton(
                                                              color: Colors.blue,
                                                              textColor: Colors.white,
                                                              child: const Text('SAVE CHANGES'),
                                                              onPressed: () => viewModel.updateUserDetails(context, customerId, userId),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  flex :2,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(10.0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade50,
                                                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                                                      ),
                                                      padding: const EdgeInsets.all(10),
                                                      child: const Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text('When Mobile Number and Email update', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                                          SizedBox(height: 10,),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 5,
                                                                child: Text("OTP (One-Time Password) is crucial when changing your "
                                                                    "mobile number or email associated with the account"
                                                                  , style: TextStyle(fontWeight: FontWeight.normal),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 15,),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 5,
                                                                child: Text("When you initiate such changes, the app often sends"
                                                                    " an OTP to your current registered mobile number or email address."
                                                                    " You need to enter this OTP to confirm and complete the update"
                                                                  , style: TextStyle(fontWeight: FontWeight.normal),
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          SizedBox(height: 20,),
                                                          Text('Password requirement', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                                          SizedBox(height: 10,),
                                                          Row(
                                                            children: [
                                                              Text('1.'),
                                                              SizedBox(width: 10,),
                                                              Text('at least 6 characters password', style: TextStyle(fontWeight: FontWeight.normal),),
                                                            ],
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Row(
                                                            children: [
                                                              Text('2.'),
                                                              SizedBox(width: 10,),
                                                              Text('at least one uppercase letter', style: TextStyle(fontWeight: FontWeight.normal),),
                                                            ],
                                                          ),
                                                          SizedBox(height: 10,),
                                                          Row(
                                                            children: [
                                                              Text('3.'),
                                                              SizedBox(width: 10,),
                                                              Text('at least one number', style: TextStyle(fontWeight: FontWeight.normal),),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 10,child: Container(color: Colors.grey.shade200,)),
                                          Container(
                                            height: 170,
                                            decoration: const BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 44,
                                                        decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.only(
                                                            topRight: Radius.circular(10),
                                                            topLeft: Radius.circular(10),
                                                          ),
                                                        ),
                                                        child: const ListTile(
                                                          title: Text('Other Settings', style: TextStyle(fontSize: 20, color: Colors.black),),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          decoration: const BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.only(
                                                              bottomLeft: Radius.circular(10),
                                                              bottomRight: Radius.circular(10),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Flexible(
                                                                flex :1,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(15.0),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      ListTile(
                                                                        title: const Text('Language'),
                                                                        leading: Icon(Icons.language, color: Theme.of(context).primaryColor),
                                                                        trailing: DropdownButton(
                                                                          items: viewModel.languageList.map((item) {
                                                                            return DropdownMenuItem(
                                                                              value: item.languageName,
                                                                              child: Text(item.languageName),
                                                                            );
                                                                          }).toList(),
                                                                          onChanged: (newVal) {
                                                                            viewModel.mySelection = newVal!;
                                                                          },
                                                                          value: viewModel.mySelection,
                                                                        ),
                                                                      ),
                                                                      ListTile(
                                                                        title: const Text('Theme(Light/Dark)'),
                                                                        leading: Icon(Icons.color_lens_outlined,  color: Theme.of(context).primaryColor),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              Flexible(
                                                                flex :1,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(10.0),
                                                                  child: Container(
                                                                    decoration: const BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                                                    ),
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        SwitchListTile(
                                                                          tileColor: Colors.red,
                                                                          secondary: Icon(Icons.notifications_none, color: Theme.of(context).primaryColor),
                                                                          title:  const Text('Push Notification'),
                                                                          value: true,
                                                                          onChanged:(bool? value) { },
                                                                        ),
                                                                        SwitchListTile(
                                                                          tileColor: Colors.red,
                                                                          secondary: Icon(Icons.volume_up_outlined, color: Theme.of(context).primaryColor),
                                                                          title:  const Text('Sound'),
                                                                          value: true,
                                                                          onChanged:(bool? value) { },
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ):
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  IntlPhoneField(
                    decoration: InputDecoration(
                      labelText: null,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.red),
                        onPressed: () => viewModel.controllerMblNo.clear(),
                      ),
                      icon: const Icon(Icons.phone_outlined, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white,
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
                  Form(
                    key: viewModel.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: viewModel.controllerUsrName,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0), // Border radius
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          onChanged: (value) {
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: viewModel.controllerEmail,
                          decoration: InputDecoration(
                            labelText: 'Email Id',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0), // Border radius
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email id';
                            }
                            return null;
                          },
                          onChanged: (value) {

                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MaterialButton(
                              color: Colors.grey,
                              textColor: Colors.white,
                              child: const Text('CANCEL'),
                              onPressed: () {

                              },
                            ),
                            const SizedBox(width: 20,),
                            MaterialButton(
                              color: Colors.blue,
                              textColor: Colors.white,
                              child: const Text('SAVE CHANGES'),
                              onPressed: ()=> viewModel.updateUserDetails(context, customerId, userId),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}