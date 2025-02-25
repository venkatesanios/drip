import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

import '../repository/repository.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../view_models/create_account_view_model.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount({super.key, required this.userId, required this.role, required this.customerId, required this.onAccountCreated});
  final int userId, customerId;
  final UserRole role;
  final Function(Map<String, dynamic>) onAccountCreated;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = CreateAccountViewModel(Repository(HttpService()), onAccountCreatedSuccess: (result) async {
          await onAccountCreated(result);
          Navigator.pop(context);
        });
        viewModel.getCountryList();
        return viewModel;
      },
      child: Consumer<CreateAccountViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2,right: 2, top: 2),
                child: ListTile(
                  title: Text(AppConstants.getFormTitle(role), style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark)),
                  subtitle: const Text(AppConstants.pleaseFillDetails, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                ),
              ),
              const Divider(height: 0),
              viewModel.errorMsg!=''?Container(
                width: MediaQuery.sizeOf(context).width,
                color: Colors.redAccent,
                child: Text(viewModel.errorMsg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal), textAlign: TextAlign.center,)
              ):
              const SizedBox(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: viewModel.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              labelText: AppConstants.fullName,
                              icon: Icon(Icons.text_fields, color: Theme.of(context).primaryColor),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppConstants.getNameError(role);
                              }
                              final regex = RegExp(r'^[a-zA-Z ]+$');
                              if (!regex.hasMatch(value)) {
                                return AppConstants.nameValidationError;
                              }
                              return null;
                            },
                            onSaved: (value) => viewModel.name = value,
                            inputFormatters: [
                              Formatters.capitalizeFirstLetter(),
                            ],
                          ),
                          const SizedBox(height: 15),
                          InternationalPhoneNumberInput(
                            validator: (value){
                              if(value==null ||value.isEmpty){
                                return AppConstants.getMobileError(role);
                              }
                              return null;
                            },
                            inputDecoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                              icon:  Icon(Icons.phone_outlined, color: Theme.of(context).primaryColor),
                              labelText: AppConstants.mobileNumber,
                            ),
                            onInputChanged: (PhoneNumber number) {
                            },
                            selectorConfig: const SelectorConfig(
                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                              setSelectorButtonAsPrefixIcon: true,
                              leadingPadding: 10,
                              useEmoji: true,
                            ),
                            ignoreBlank: false,
                            autoValidateMode: AutovalidateMode.disabled,
                            //selectorTextStyle: myTheme.textTheme.titleMedium,
                            initialValue: PhoneNumber(isoCode: 'IN'),
                            textFieldController: viewModel.mobileNoController,
                            formatInput: false,
                            keyboardType:
                            const TextInputType.numberWithOptions(signed: true, decimal: true),
                            onSaved: (PhoneNumber number) {
                              viewModel.dialCode = number.dialCode.toString();
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: AppConstants.emailAddress,
                              icon: Icon(Icons.email_outlined, color: Theme.of(context).primaryColor),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppConstants.getEmailError(role);
                              }
                              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                                return AppConstants.enterValidEmail;
                              }
                              return null;
                            },
                            onSaved: (email) => viewModel.email = email,
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: AppConstants.country,
                              icon: Icon(CupertinoIcons.globe, color: Theme.of(context).primaryColor),
                            ),
                            value: viewModel.country,
                            items: viewModel.countries.map((countryItem) {
                              return DropdownMenuItem(
                                value: countryItem,
                                child: Text(countryItem),
                              );
                            }).toList(),
                            onChanged: (value) {
                              viewModel.country = value;
                              viewModel.state = null;
                              viewModel.states.clear();
                              viewModel.selectedCountryID = viewModel.getCountryIdByName(value.toString())!;
                              viewModel.getStateList(viewModel.selectedCountryID.toString());
                            },
                            validator: (value) {
                              if (value == null) {
                                return AppConstants.getCountryError(role);
                              }
                              return null;
                            },
                            onSaved: (value) => viewModel.country = value,
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: AppConstants.state,
                              icon: Icon(CupertinoIcons.placemark, color: Theme.of(context).primaryColor),
                            ),
                            value: viewModel.state,
                            items: viewModel.states.map((stateItem) {
                              return DropdownMenuItem(
                                value: stateItem,
                                child: Text(stateItem),
                              );
                            }).toList(),
                            onChanged: (value) {
                              viewModel.state = value;
                              viewModel.selectedStateID = viewModel.getStateIdByName(value.toString())!;
                            },
                            validator: (value) {
                              if (value == null) {
                                return AppConstants.getStateError(role);
                              }
                              return null;
                            },
                            onSaved: (value) => viewModel.state = value,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: AppConstants.city,
                              icon: Icon(Icons.location_city, color: Theme.of(context).primaryColor),
                            ),
                            keyboardType: TextInputType.name,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppConstants.getCityError(role);
                              }
                              return null;
                            },
                            onSaved: (value) => viewModel.city = value,
                            inputFormatters: [
                              Formatters.capitalizeFirstLetter(),
                            ],
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: AppConstants.address,
                              icon: Icon(Icons.linear_scale, color: Theme.of(context).primaryColor,),
                            ),
                            keyboardType: TextInputType.streetAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppConstants.getAddressError(role);
                              }
                              return null;
                            },
                            onSaved: (value) => viewModel.address = value,
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: Column(
                  children: [
                    ListTile(
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MaterialButton(
                            onPressed:() {
                              Navigator.pop(context);
                            },
                            textColor: Colors.white,
                            color: Colors.redAccent,
                            child: const Text('Cancel',style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 10),
                          MaterialButton(
                            onPressed: () => viewModel.createAccount(userId, role, customerId),
                            textColor: Colors.white,
                            color: Theme.of(context).primaryColor,
                            child: const Text('Create Account',style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
