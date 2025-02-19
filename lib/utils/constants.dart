import 'dart:convert';
import 'package:flutter/cupertino.dart';

import '../Screens/ConfigMaker/config_web_view.dart';
import 'environment.dart';

enum UserRole { admin, dealer, subUser }

class AppConstants {
  static String apiUrl = Environment.apiUrl;
  static const int timeoutDuration = 30;

  static String mqttUrl = Environment.mqttWebUrl;
  static int mqttPort = Environment.mqttPort;

  static const String  publishTopic = 'AppToFirmware';
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

  static const String pngPath = "assets/png_images/";
  static const String gifPath = "assets/gif_images/";

  static const String pumpOFF = "dp_pump.png";
  static const String pumpON = "dp_irr_pump_g.gif";
  static const String pumpNotON = "dp_irr_pump_y.png";
  static const String pumpNotOFF = "dp_irr_pump_r.png";

  static const String filterOFF = "dp_filter.png";
  static const String filterON = "dp_filter_g.png";
  static const String filterNotON = "dp_filter_y.png";
  static const String filterNotOFF = "dp_filter_r.png";

  static const String boosterPumpOFF = "dp_fert_booster_pump.png";
  static const String boosterPumpON = "dp_fert_booster_pump_g.gif";
  static const String boosterPumpNotON = "dp_fert_booster_pump_y.png";
  static const String boosterPumpNotOFF = "dp_fert_booster_pump_r.png";

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

  static String getNameError(UserRole role) => getErrorMessage(role, nameErrors);

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

    if(imagePathFinal.contains('.gif')){
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
    if(type.contains('SM')){
      return soilMoistureSensor;
    }if(type.contains('LV')){
      return levelSensor;
    }else{
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

  dynamic payloadConversion(data) {
    dynamic dataFormation = {};
    for(var globalKey in data.keys) {
      if(['filterSite', 'fertilizerSite', 'waterSource', 'pump', 'moistureSensor', 'irrigationLine'].contains(globalKey)){
        dataFormation[globalKey] = [];
        for(var site in data[globalKey]){
          dynamic siteFormation = site;
          for(var siteKey in site.keys){
            if(!['objectId', 'sNo', 'name', 'objectName', 'connectionNo', 'type', 'controllerId', 'count', 'siteMode', 'pumpType'].contains(siteKey)){
              siteFormation[siteKey] = siteFormation[siteKey] is List<dynamic>
                  ? (siteFormation[siteKey] as List<dynamic>).map((element) {
                    if(element is double){
                      return (data['configObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == element);
                    }else{
                      var object = (data['configObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == element['sNo']);
                      for(var key in element.keys){
                        if(!(object as Map<String, dynamic>).containsKey(key)){
                          object[key] = element[key];
                        }
                      }
                      return object;
                    }
              }).toList()
                  : (data['listOfGeneratedObject'] as List<dynamic>).firstWhere((object) => object['sNo'] == siteFormation[siteKey], orElse: ()=> {});
            }
          }
          dataFormation[globalKey].add(site);
        }
      }
    }
    // print('dataFormation : ${jsonEncode(dataFormation)}');
    // print('-------------------------------------------');
    return dataFormation;
  }

}