import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/http_service.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin{
  bool _isLoading = true;
  bool _isSucceed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // checkAuthentication();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 400,
          width: 200,
          child: _isLoading ? _buildLoadingWidget() : _isSucceed ? _buildSuccessWidget() : _buildErrorWidget(),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/check.json'),
          LinearProgressIndicator()
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/error.json'),
          Text('Already logged in!')
        ],
      ),
    );
  }

  Widget _buildSuccessWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/success.json'),
        ],
      ),
    );
  }

  /*void checkAuthentication() async{
    final prefs = await SharedPreferences.getInstance();
    final userType =  prefs.getString('userType') ?? '';
    final userIdFromPref = prefs.getString('userId') ?? '';
    final deviceToken = prefs.getString('deviceToken') ?? '';
    Map<String, dynamic> data = {
      'userId': int.parse(userIdFromPref.isNotEmpty ? userIdFromPref : '0'),
      'deviceToken': deviceToken
    };
    try {
      final userVerifyWithDeviceToken = await HttpService().postRequest('userVerifyWithDeviceToken', data);
      final result = jsonDecode(userVerifyWithDeviceToken.body);
      await Future.delayed(Duration(seconds: 4));
      setState(() {
        _isSucceed = result['code'] == 200;
        _isLoading = false;
      });
      await Future.delayed(Duration(seconds: 1));
      if(result['code'] == 200) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) {
              if(userIdFromPref.isEmpty) {
                return LoginScreen();
              } else {
                if(userType == "2") {
                  return DealerDashboard(userName: prefs.getString('userName') ?? "", countryCode:  prefs.getString('countryCode') ?? "", mobileNo:  prefs.getString('mobileNumber') ??"", userId: int.parse(prefs.getString('userId') ?? ''), emailId: prefs.getString('email') ?? '');
                } else if(userType == "3"){
                  return HomeScreen(userId: 0, fromDealer: false,);
                } else {
                  return Container();
                }
              }
            },
            transitionsBuilder: (context, animation1, animation2, child) {
              return FadeTransition(
                opacity: animation1,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      } else {
        setState(() {
          _isSucceed = false;
          _isLoading = false;
        });
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) {
              return LoginScreen();
            },
            transitionsBuilder: (context, animation1, animation2, child) {
              return FadeTransition(
                opacity: animation1,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );
      }
      print(userVerifyWithDeviceToken.body);
    } catch (e) {
      print(e);
    }
    // final authProvider = context.read<AuthenticatorProvider>();
    // bool isUserAuthenticated = await authProvider.checkAuthenticationState();
    //
    // if(isUserAuthenticated){
    //   Navigator.pushReplacementNamed(context, Constants.homeScreen);
    // } else {
    //   Navigator.pushReplacementNamed(context, Constants.loginScreen);
    // }
  }*/
}