import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../flavors.dart';
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
                kIsWeb? Expanded(
                  flex:2,
                  child: Container(
                    width: double.infinity, height: double.infinity,
                    color: Theme.of(context).primaryColorDark,
                    child: F.appFlavor!.name.contains('oro')?
                    Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: SvgPicture.asset('assets/svg_images/login_left_picture.svg'),
                    ):
                    const Image(image: AssetImage('assets/png/lk_login_left_picture.png'), fit: BoxFit.fill),
                  ),
                ):
                Container(),
                Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          F.appFlavor!.name.contains('oro')?Expanded(
                            child: Container(
                              color: Colors.white,
                              child: Row(
                                children: [
                                  Expanded(flex: 3, child: Container()),
                                  const Image(image: AssetImage('assets/png/login_top_corner.png')),
                                ],
                              ),
                            ),
                          ):
                          Padding(
                            padding: const EdgeInsets.only(left: 150, top: 40),
                            child: SvgPicture.asset('assets/svg_images/lk_login_top_corner.svg', fit: BoxFit.fitWidth),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 40),
                                  child: Column(
                                    children: [

                                      // Logo (only for oro flavor)
                                      F.appFlavor!.name.contains('oro')
                                          ? SvgPicture.asset('assets/svg_images/oro_logo.svg', fit: BoxFit.cover)
                                          : const SizedBox(),
                                      F.appFlavor!.name.contains('oro') ? const SizedBox(height: 10) : const SizedBox(),

                                      // Intro text
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                                        child: Text(
                                          AppConstants.appShortContent,
                                          style: Theme.of(context).textTheme.titleMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      // Mobile Number Input (replacing InternationalPhoneNumberInput)
                                      SizedBox(
                                        height: 50,
                                        child: TextField(
                                          controller: viewModel.mobileNoController,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            icon: const Icon(Icons.phone_outlined),
                                            labelText: 'Phone Number',
                                            prefixText: '+91 ',
                                            suffixIcon: IconButton(
                                              icon: const Icon(Icons.clear, color: Colors.red),
                                              onPressed: () {
                                                viewModel.mobileNoController.clear();
                                              },
                                            ),
                                          ),
                                          onChanged: (value) {
                                            viewModel.countryCode = '+91'; // Manually set; or use logic if needed
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 15),

                                      // Password Input
                                      TextField(
                                        controller: viewModel.passwordController,
                                        obscureText: viewModel.isObscure,
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                          border: const OutlineInputBorder(),
                                          icon: const Icon(Icons.lock_outline),
                                          labelText: 'Password',
                                          suffixIcon: IconButton(
                                            icon: Icon(viewModel.isObscure ? Icons.visibility : Icons.visibility_off),
                                            onPressed: () {
                                              viewModel.onIsObscureChanged();
                                            },
                                          ),
                                        ),
                                      ),

                                      // Error Message
                                      viewModel.errorMessage.isNotEmpty
                                          ? SizedBox(
                                        width: 400,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 40, top: 4),
                                          child: Text(
                                            viewModel.errorMessage,
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      )
                                          : const SizedBox(),

                                      const SizedBox(height: 20),

                                      // CONTINUE Button
                                      SizedBox(
                                        width: 200,
                                        height: 45.0,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 40),
                                          child: MaterialButton(
                                            color: Theme.of(context).primaryColor,
                                            textColor: Colors.white,
                                            child: const Text(
                                              'CONTINUE',
                                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () => viewModel.login(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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