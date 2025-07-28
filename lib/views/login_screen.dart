import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
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
    final isLargeScreen = MediaQuery.of(context).size.width > 800;

    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(
        repository: RepositoryImpl(HttpService()),
        onLoginSuccess: (pageRoute) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        },
      ),
      child: Consumer<LoginViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: isLargeScreen
                ? _buildDesktopLayout(context, viewModel)
                : _buildMobileLayout(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, LoginViewModel viewModel) {

    return Row(
      children: [
        Expanded(
          child: Container(
            height: double.infinity,
            color: Theme.of(context).primaryColorDark,
            child: F.appFlavor!.name.contains('oro')
                ? Padding(
              padding: const EdgeInsets.all(50.0),
              child: SvgPicture.asset('assets/svg_images/login_left_picture.svg'),
            )
                : const Image(
              image: AssetImage('assets/png/lk_login_left_picture.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
        SizedBox(
          width: 400, // fixed width in pixels
          child: Container(
            color: Colors.white,
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
                              F.appFlavor!.name.contains('oro')
                                  ? SvgPicture.asset('assets/svg_images/oro_logo.svg', fit: BoxFit.cover)
                                  : const SizedBox(),
                              F.appFlavor!.name.contains('oro') ? const SizedBox(height: 10) : const SizedBox(),
                              Padding(
                                padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
                                child: Text(
                                  AppConstants.appShortContent,
                                  style: Theme.of(context).textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 15),
                              IntlPhoneField(
                                focusNode:  FocusNode(),
                                decoration: InputDecoration(
                                  labelText: 'Mobile Number',
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.red),
                                    onPressed: () => viewModel.mobileNoController.clear(),
                                  ),
                                  icon: const Icon(Icons.phone_outlined, color: Colors.black),
                                  filled: true,
                                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                                  counterText: '',
                                ),
                                languageCode: "en",
                                initialCountryCode: 'IN',
                                controller: viewModel.mobileNoController,
                                onChanged: (phone) {
                                  print(phone.completeNumber);
                                },
                                onCountryChanged: (country) => viewModel.countryCode = country.dialCode,
                              ),
                              const SizedBox(height: 15),
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
                                  filled: true,
                                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                                ),
                              ),

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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, LoginViewModel viewModel) {
    return SafeArea(
      child: Center(
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height,
          color: Theme.of(context).primaryColor,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                F.appFlavor!.name.contains('oro')? SizedBox(
                  width: double.infinity,
                  height: (MediaQuery.of(context).size.height / 2)-100,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(),
                      Image(
                        image: AssetImage('assets/png/oro_logo_white.png'),
                        height: 70,
                        fit: BoxFit.fitHeight,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 20),
                        child: Text(AppConstants.appShortContent,
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ):
                Stack(
                  children: [
                    Container(
                      height: (MediaQuery.of(context).size.height / 2),
                      width: double.infinity,
                      color: Theme.of(context).primaryColor,
                      child: const Image(
                        image: AssetImage('assets/png/lk_login_left_picture.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 1,
                      width: 210,
                      height: 130,
                      child: SvgPicture.asset(
                        'assets/svg_images/lk_login_top_corner.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Positioned(
                      bottom: 10,
                      left: 25,
                      right: 25,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
                        child: Text(AppConstants.appShortContent,
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                            textAlign: TextAlign.center),
                      ),
                    )
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IntlPhoneField(
                              focusNode:  FocusNode(),
                              decoration: InputDecoration(
                                labelText: null,
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(),
                                ),
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
                              onChanged: (phone) {
                                if (kDebugMode) {
                                  print(phone.completeNumber);
                                }
                              },
                              onCountryChanged: (country) => viewModel.countryCode = country.dialCode
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: viewModel.passwordController,
                            obscureText: viewModel.isObscure,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                              icon: const Icon(Icons.lock_outline, color: Colors.white), // Left-side icon
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
                          if (viewModel.errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 40, top: 8),
                              child: Text(
                                viewModel.errorMessage,
                                textAlign: TextAlign.left,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 200,
                            height: 45.0,
                            child: MaterialButton(
                              color: Theme.of(context).primaryColorLight,
                              textColor: Colors.white,
                              child: const Text(
                                'CONTINUE',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => viewModel.login(),
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
      ),
    );
  }
}