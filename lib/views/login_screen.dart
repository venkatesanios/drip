import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import '../repository/repository.dart';
import '../services/http_service.dart';
import '../utils/constants.dart';
import '../view_models/login_view_model.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(Repository(HttpService()), onLoginSuccess: (pageRoute) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Row(
              children: [
                Expanded(
                  flex:2,
                  child: Container(
                      width: double.infinity, height: double.infinity,
                      color: Theme.of(context).primaryColor,
                      child: Padding(
                        padding: const EdgeInsets.all(50.0),
                        child: SvgPicture.asset('assets/svg_images/login_left_picture.svg'),
                      )
                  ),
                ),
                Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                                color: Colors.white,
                                child: Row(
                                  children: [
                                    Expanded(flex: 3, child: Container()),
                                    const Image(image: AssetImage('assets/png_images/login_top_corner.png')),
                                  ],
                                ),
                              ),
                          ),
                          Expanded(
                              flex:5,
                              child:
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20, right: 40),
                                    child: Column(
                                      children: [
                                        SvgPicture.asset('assets/svg_images/oro_logo.svg', fit: BoxFit.cover),
                                        const SizedBox(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                                          child: Text(AppConstants.appShortContent, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center,),
                                        ),
                                        const SizedBox(height: 15,),
                                        SizedBox(height: 50,
                                          child: InternationalPhoneNumberInput(
                                            inputDecoration: InputDecoration(
                                              border: const OutlineInputBorder(),
                                              icon: const Icon(Icons.phone_outlined),
                                              labelText: 'Phone Number',
                                              suffixIcon: IconButton(icon: const Icon(Icons.clear, color: Colors.red,),
                                                  onPressed: () {
                                                    viewModel.mobileNoController.clear();
                                                  }),
                                            ),
                                            onInputChanged: (PhoneNumber number) {
                                              viewModel.countryCode = number.dialCode ?? '';
                                            },
                                            selectorConfig: const SelectorConfig(
                                              selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                                              setSelectorButtonAsPrefixIcon: true,
                                              leadingPadding: 10,
                                              useEmoji: true,
                                            ),
                                            ignoreBlank: false,
                                            autoValidateMode: AutovalidateMode.disabled,
                                            initialValue: PhoneNumber(isoCode: 'IN'),
                                            textFieldController: viewModel.mobileNoController,
                                            formatInput: false,
                                            keyboardType:
                                            const TextInputType.numberWithOptions(signed: true, decimal: true),
                                            onSaved: (PhoneNumber number) {
                                              //print('On Saved: $number');
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 15,),
                                        TextField(
                                          controller: viewModel.passwordController,
                                          obscureText: viewModel.isObscure,
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                            border: const OutlineInputBorder(),
                                            icon: const Icon(Icons.lock_outline),
                                            labelText: 'Password',
                                            suffixIcon: IconButton(icon: Icon(viewModel.isObscure ? Icons.visibility : Icons.visibility_off),
                                                onPressed: () {
                                                  viewModel.onIsObscureChanged();
                                                }),
                                          ),
                                        ),
                                        viewModel.errorMessage.isNotEmpty?SizedBox(
                                          width: 400,
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 40, top: 4),
                                              child: Text(viewModel.errorMessage, textAlign: TextAlign.left,style: const TextStyle(color: Colors.red),),
                                            )
                                        ):
                                        const SizedBox(),
                                        const SizedBox(height: 20,),
                                        SizedBox(
                                          width: 200,
                                          height: 45.0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 40),
                                            child: MaterialButton(
                                              color: Theme.of(context).primaryColor,
                                              textColor: Colors.white,
                                              child: const Text('CONTINUE', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                              onPressed: () async {
                                                viewModel.login();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                    )
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}