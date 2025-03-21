import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../modules/config_Maker/view/config_web_view.dart';
import 'environment.dart';

enum UserRole { admin, dealer, subUser }

enum GemProgramStartStopReasonCode {
  rs1(1, 'Running As Per Schedule'),
  rs2(2, 'Turned On Manually'),
  rs3(3, 'Started By Condition'),
  rs4(4, 'Turned Off Manually'),
  rs5(5, 'Program Turned Off'),
  rs6(6, 'Zone Turned Off'),
  rs7(7, 'Stopped By Condition'),
  rs8(8, 'Disabled By Condition'),
  rs9(9, 'StandAlone Program Started'),
  rs10(10, 'StandAlone Program Stopped'),
  rs11(11, 'StandAlone Program Stopped After Set Value'),
  rs12(12, 'StandAlone Manual Started'),
  rs13(13, 'StandAlone Manual Stopped'),
  rs14(14, 'StandAlone Manual Stopped After Set Value'),
  rs15(15, 'Started By Day Count Rtc'),
  rs16(16, 'Paused By User'),
  rs17(17, 'Manually Started Paused By User'),
  rs18(18, 'Program Deleted'),
  rs19(19, 'Program Ready'),
  rs20(20, 'Program Completed'),
  rs21(21, 'Resumed By User'),
  rs22(22, 'Paused By Condition'),
  rs23(23, 'Program Ready And Run By Condition'),
  rs24(24, 'Running As Per Schedule And Condition'),
  rs25(25, 'Started By Condition Paused By User'),
  rs26(26, 'Resumed By Condition'),
  rs27(27, 'Bypassed Start Condition Manually'),
  rs28(28, 'Bypassed Stop Condition Manually'),
  rs29(29, 'Continue Manually'),
  rs30(30, '-'),
  rs31(31, 'Program Completed'),
  rs32(32, 'Waiting For Condition'),
  rs33(33, 'Started By Condition and run as per Schedule'),
  unknown(0, 'Unknown content');

  final int code;
  final String content;

  const GemProgramStartStopReasonCode(this.code, this.content);

  static GemProgramStartStopReasonCode fromCode(int code) {
    return GemProgramStartStopReasonCode.values.firstWhere((e) => e.code == code,
      orElse: () => GemProgramStartStopReasonCode.unknown,
    );
  }
}

enum GemLineSSReasonCode {
  lss1(1, 'The Line Paused Manually'),
  lss2(2, 'Scheduled Program paused by Standalone program'),
  lss3(3, 'The Line Paused By System Definition'),
  lss4(4, 'The Line Paused By Low Flow Alarm'),
  lss5(5, 'The Line Paused By High Flow Alarm'),
  lss6(6, 'The Line Paused By No Flow Alarm'),
  lss7(7, 'The Line Paused By Ec High'),
  lss8(8, 'The Line Paused By Ph Low'),
  lss9(9, 'The Line Paused By Ph High'),
  lss10(10, 'The Line Paused By Pressure Low'),
  lss11(11, 'The Line Paused By Pressure High'),
  lss12(12, 'The Line Paused By No Power Supply'),
  lss13(13, 'The Line Paused By No Communication'),
  lss14(14, 'The Line Paused By Pump In Another Irrigation Line'),
  unknown(0, 'Unknown content');

  final int code;
  final String content;

  const GemLineSSReasonCode(this.code, this.content);

  static GemLineSSReasonCode fromCode(int code) {
    return GemLineSSReasonCode.values.firstWhere((e) => e.code == code,
      orElse: () => GemLineSSReasonCode.unknown,
    );
  }
}

class AppConstants {
  static String apiUrl = Environment.apiUrl;
  static const int timeoutDuration = 30;
  static String mqttUrlMobile = Environment.mqttMobileUrl;

  static String mqttUrl = Environment.mqttWebUrl;
  static int mqttWebPort = Environment.mqttWebPort;
  static int mqttMobilePort = Environment.mqttMobilePort;

  static const String publishTopic = 'AppToFirmware';
  static const String subscribeTopic = 'FirmwareToApp';

  static const String appTitle = 'ORO DRIP IRRIGATION';
  static const String appShortContent = 'Drip irrigation is a type of watering system used in agriculture, gardening, and landscaping to efficiently deliver water directly to the roots of plants.';

  static const String formHeaderForAdmin = 'ORO DRIP IRRIGATION';

  static const String fullName = 'Full Name';
  static const String mobileNumber = 'Mobile Number';
  static const String emailAddress = 'Email Address';
  static const String country = 'Country';
  static const String state = 'State';
  static const String city = 'City';
  static const String address = 'Address';
  static const pleaseFillDetails = 'Please fill out all the details correctly.';
  static const enterValidEmail = 'Please enter a valid email';
  static const nameValidationError = 'Name must not contain numbers or special characters';

  static const String pngPath = "assets/png/";
  static const String gifPath = "assets/gif_images/";

  static const String pumpOFF = "dp_irr_pump.png";
  static const String pumpON = "dp_irr_pump_g.gif";
  static const String pumpNotON = "dp_irr_pump_y.png";
  static const String pumpNotOFF = "dp_irr_pump_r.png";

  static const String filterOFF = "dp_filter.png";
  static const String filterON = "dp_filter_g.png";
  static const String filterNotON = "dp_filter_y.png";
  static const String filterNotOFF = "dp_filter_r.png";

  static const String boosterPumpOFF = "dp_frt_booster_pump.png";
  static const String boosterPumpON = "dp_frt_booster_pump_g.gif";
  static const String boosterPumpNotON = "dp_frt_booster_pump_y.png";
  static const String boosterPumpNotOFF = "dp_frt_booster_pump_r.png";

  static const String soilMoistureSensor = "moisture_sensor.png";
  static const String pressureSensor = "pressure_sensor.png";
  static const String levelSensor = "level_sensor.png";

  static const String agitatorOFF = "dp_agitator_right.png";
  static const String agitatorON = "dp_agitator_right_g.gif";
  static const String agitatorNotON = "dp_agitator_right_y.png";
  static const String agitatorNotOFF = "dp_agitator_right_r.png";

  static const String valveOFF = "valve_gray.png";
  static const String valveON = "valve_green.png";
  static const String valveNotON = "valve_orange.png";
  static const String valveNotOFF = "valve_red.png";

  static const Map<UserRole, String> formTitle = {
    UserRole.admin: "Dealer Account Form",
    UserRole.dealer: "Customer Account Form",
    UserRole.subUser: "Sub User Account Form",
  };

  static const Map<UserRole, String> nameErrors = {
    UserRole.admin: "Please enter your dealer name",
    UserRole.dealer: "Please enter your customer name",
    UserRole.subUser: "Please enter your sub-user name",
  };

  static const Map<UserRole, String> mobileErrors = {
    UserRole.admin: "Please enter your dealer mobile number",
    UserRole.dealer: "Please enter your customer mobile number",
    UserRole.subUser: "Please enter your sub-user mobile number",
  };

  static const Map<UserRole, String> emailErrors = {
    UserRole.admin: "Please enter your dealer email",
    UserRole.dealer: "Please enter your customer email",
    UserRole.subUser: "Please enter your sub-user email",
  };

  static const Map<UserRole, String> countryErrors = {
    UserRole.admin: "Please select your dealer country",
    UserRole.dealer: "Please select your customer country",
    UserRole.subUser: "Please select your sub-user country",
  };

  static const Map<UserRole, String> stateErrors = {
    UserRole.admin: "Please select your dealer state",
    UserRole.dealer: "Please select your customer state",
    UserRole.subUser: "Please select your sub-user state",
  };

  static const Map<UserRole, String> cityErrors = {
    UserRole.admin: "Please enter your dealer city",
    UserRole.dealer: "Please enter your customer city",
    UserRole.subUser: "Please enter your sub-user city",
  };

  static const Map<UserRole, String> addressErrors = {
    UserRole.admin: "Please enter your dealer address",
    UserRole.dealer: "Please enter your customer address",
    UserRole.subUser: "Please enter your sub-user address",
  };

  static String getErrorMessage(UserRole role, Map<UserRole, String> errorMap) {
    return errorMap[role] ?? "Invalid role";
  }

  static String getFormTitle(UserRole role) => getErrorMessage(role, formTitle);

  static String getNameError(UserRole role) =>
      getErrorMessage(role, nameErrors);

  static String getMobileError(UserRole role) =>
      getErrorMessage(role, mobileErrors);

  static String getEmailError(UserRole role) =>
      getErrorMessage(role, emailErrors);

  static String getCountryError(UserRole role) =>
      getErrorMessage(role, countryErrors);

  static String getStateError(UserRole role) =>
      getErrorMessage(role, stateErrors);

  static String getCityError(UserRole role) =>
      getErrorMessage(role, cityErrors);

  static String getAddressError(UserRole role) =>
      getErrorMessage(role, addressErrors);

  static Widget getAsset(String imageKey, int status, String type) {
    String imagePathFinal;
    switch (imageKey) {
      case 'pump':
        imagePathFinal = _getIrrigationPumpImagePath(status);
        break;
      case 'filter':
        imagePathFinal = _getFilterImagePath(status);
        break;
      case 'booster':
        imagePathFinal = _getBoosterImagePath(status);
        break;
      case 'sensor':
        imagePathFinal = _getSensorImagePath(type);
        break;
      case 'agitator':
        imagePathFinal = _getAgitatorImagePath(status);
        break;
      case 'valve':
        imagePathFinal = _getValveImagePath(status);
        break;
      default:
        imagePathFinal = '';
    }

    if (imagePathFinal.contains('.gif')) {
      return Image.asset('$gifPath$imagePathFinal');
    }
    return Image.asset('$pngPath$imagePathFinal');
  }

  static String _getIrrigationPumpImagePath(int status) {
    switch (status) {
      case 0:
        return pumpOFF;
      case 1:
        return pumpON;
      case 2:
        return pumpNotON;
      case 3:
        return pumpNotOFF;
      default:
        return '';
    }
  }

  static String _getFilterImagePath(int status) {
    switch (status) {
      case 0:
        return filterOFF;
      case 1:
        return filterON;
      case 2:
        return filterNotON;
      case 3:
        return filterNotOFF;
      default:
        return '';
    }
  }

  static String _getBoosterImagePath(int status) {
    switch (status) {
      case 0:
        return boosterPumpOFF;
      case 1:
        return boosterPumpON;
      case 2:
        return boosterPumpNotON;
      case 3:
        return boosterPumpNotOFF;
      default:
        return '';
    }
  }

  static String _getSensorImagePath(String type) {
    if (type.contains('SM')) {
      return soilMoistureSensor;
    }
    if (type.contains('LV')) {
      return levelSensor;
    } else {
      return pressureSensor;
    }
  }

  static String _getAgitatorImagePath(int status) {
    switch (status) {
      case 0:
        return agitatorOFF;
      case 1:
        return agitatorON;
      case 2:
        return agitatorNotON;
      case 3:
        return agitatorNotOFF;
      default:
        return '';
    }
  }

  static String _getValveImagePath(int status) {
    switch (status) {
      case 0:
        return valveOFF;
      case 1:
        return valveON;
      case 2:
        return valveNotON;
      case 3:
        return valveNotOFF;
      default:
        return '';
    }
  }

  static const String svgObjectPath = 'assets/Images/Svg/';

  static dynamic payloadConversion(data) {
    dynamic dataFormation = {};

    try
    {
      for(var globalKey in data.keys) {
        if(['filterSite', 'fertilizerSite', 'waterSource', 'pump', 'moistureSensor', 'irrigationLine'].contains(globalKey)){
          dataFormation[globalKey] = [];
          for(var site in data[globalKey]){
            dynamic siteFormation = site;
            for(var siteKey in site.keys){
              if(!['objectId', 'sNo', 'name', 'objectName', 'connectionNo', 'type', 'controllerId', 'count', 'siteMode', 'pumpType', 'connectedObject', 'weatherStation'].contains(siteKey)){
                siteFormation[siteKey] = siteFormation[siteKey] is List<dynamic>
                    ? (siteFormation[siteKey] as List<dynamic>).map((element) {
                  if(element is double){
                    return (data['configObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == element);
                  }else{
                    print('element[sNo] == ${element['sNo']}');
                    var object = (data['configObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == element['sNo']);
                    for(var key in element.keys){
                      if(!(object as Map<String, dynamic>).containsKey(key)){
                        object[key] = element[key];
                      }
                    }
                    return object;
                  }
                }).toList()
                    : (data['configObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == siteFormation[siteKey], orElse: ()=> {});
              }
            }
            dataFormation[globalKey].add(site);
          }
        }
      }
      // print('dataFormation : ${jsonEncode(dataFormation)}');
      // print('-------------------------------------------');
    }
    catch(e,stackTrace){
      print('Error on payloadConversion :: $e');
      print('stackTrace on payloadConversion :: $stackTrace');
    }
    return dataFormation;

  }

  static dynamic findLocation({required data, required double objectSno, required String key}) {
    String name = '';
    double sNo = 0.0;
    try {
      for (var key in data.keys) {
        if (![
          'isNewConfig',
          'controllerReadStatus',
          'configObject',
          'connectionCount',
          'productLimit',
          'userId',
          'controllerId',
          'groupId',
          'isNewConfig',
          'productLimit',
          'connectionCount',
          'deviceList',
          'hardware',
          'controllerReadStatus',
          'createUser',
        ].contains(key)) {
          for (var place in data[key]) {
            for (var placeKey in place.keys) {
              if (place[placeKey] is double) {
                if (place[placeKey] == objectSno) {
                  if(key == 'name'){
                    name = place['name'];
                  }else{
                    sNo = place['sNo'];
                  }
                  break;
                }
              }
              else if (place[placeKey] is List<double>) {
                if (place[placeKey].contains(objectSno)) {
                  if(key == 'name'){
                    name = place['name'];
                  }else{
                    sNo = place['sNo'];
                  }
                  break;
                }
              }else if(place[placeKey] is List<Map<String, dynamic>>){
                if(place[placeKey].any((obj) => obj['sNo'] == objectSno)){
                  if(key == 'name'){
                    name = place['name'];
                  }else{
                    sNo = place['sNo'];
                  }
                  break;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('error : $e');
    }

    if(key == 'name'){
      return name;
    }else{
      return sNo;
    }
  }


  static Color outputColor = const Color(0xff14AE5C);
  static Color commonObjectColor = const Color(0xff0070D8);
  static String analogCode = '3';
  static String digitalCode = '4';
  static String moistureCode = '5';
  static String pulseCode = '6';
  static String i2cCode = '7';
  static List<int> pumpModelList = [5, 6, 7, 8, 9, 10];
  static int levelObjectId = 26;
  static int waterMeterObjectId = 22;
  static int pressureSensorObjectId = 24;
}