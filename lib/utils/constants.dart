import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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

enum PumpReasonCode {
  reason1(1, 'Motor off due to sump empty'),
  reason2(2, 'Motor off due to upper tank full'),
  reason3(3, 'Motor off due to low voltage'),
  reason4(4, 'Motor off due to high voltage'),
  reason5(5, 'Motor off due to voltage SPP'),
  reason6(6, 'Motor off due to reverse phase'),
  reason7(7, 'Motor off due to starter trip'),
  reason8(8, 'Motor off due to dry run'),
  reason9(9, 'Motor off due to overload'),
  reason10(10, 'Motor off due to current SPP'),
  reason11(11, 'Motor off due to cyclic trip'),
  reason12(12, 'Motor off due to maximum run time'),
  reason13(13, 'Motor off due to sump empty'),
  reason14(14, 'Motor off due to upper tank full'),
  reason15(15, 'Motor off due to RTC 1'),
  reason16(16, 'Motor off due to RTC 2'),
  reason17(17, 'Motor off due to RTC 3'),
  reason18(18, 'Motor off due to RTC 4'),
  reason19(19, 'Motor off due to RTC 5'),
  reason20(20, 'Motor off due to RTC 6'),
  reason21(21, 'Motor off due to auto mobile key off'),
  reason22(22, 'Motor on due to cyclic time'),
  reason23(23, 'Motor on due to RTC 1'),
  reason24(24, 'Motor on due to RTC 2'),
  reason25(25, 'Motor on due to RTC 3'),
  reason26(26, 'Motor on due to RTC 4'),
  reason27(27, 'Motor on due to RTC 5'),
  reason28(28, 'Motor on due to RTC 6'),
  reason29(29, 'Motor on due to auto mobile key on'),
  reason30(30, 'Motor off due to Power off'),
  //reason31(31, 'Motor on due to Power on'),
  unknown(0, 'Unknown content');

  final int code;
  final String content;
  final String motorOff = "Motor off due to";
  final String motorOn = "Motor on due to";

  const PumpReasonCode(this.code, this.content);

  static PumpReasonCode fromCode(int code) {
    return PumpReasonCode.values.firstWhere((e) => e.code == code,
      orElse: () => PumpReasonCode.unknown,
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
  static String mqttUserName = Environment.mqttUserName;
  static String mqttPassword = Environment.mqttPassword;

  static String publishTopic = Environment.mqttPublishTopic;
  static String subscribeTopic = Environment.mqttSubscribeTopic;

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
  static const String gifPath = "assets/gif/";
  static const String svgObjectPath = 'assets/Images/Svg/';

  static const String boreWellFirst = "dp_bore_well_first.png";
  static const String boreWellCenter = "dp_bore_well_center.png";

  static const String wellFirst = "dp_well_first.png";
  static const String wellCenter = "dp_well_center.png";
  static const String wellLast = "dp_well_last.png";

  static const String sumpFirst = "dp_sump_first.png";
  static const String sumpCenter = "dp_sump_center.png";
  static const String sumpLast = "dp_sump_last.png";

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

  static const String valveLjOFF = "valve_gray_lj.png";
  static const String valveLjON = "valve_green_lj.png";
  static const String valveLjNotON = "valve_orange_lj.png";
  static const String valveLjNotOFF = "valve_red_lj.png";

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

  static Widget getAsset(String keyOne, int keyTwo, String keyThree) {
    String imagePathFinal;
    switch (keyOne) {
      case 'source':
        imagePathFinal = _getSourceImagePath(keyTwo, keyThree);
        break;
      case 'pump':
        imagePathFinal = _getIrrigationPumpImagePath(keyTwo);
        break;
      case 'filter':
        imagePathFinal = _getFilterImagePath(keyTwo);
        break;
      case 'booster':
        imagePathFinal = _getBoosterImagePath(keyTwo);
        break;
      case 'sensor':
        imagePathFinal = _getSensorImagePath(keyThree);
        break;
      case 'agitator':
        imagePathFinal = _getAgitatorImagePath(keyTwo);
        break;
      case 'valve':
        imagePathFinal = _getValveImagePath(keyTwo);
        break;
      case 'valve_lj':
        imagePathFinal = _getValveLjImagePath(keyTwo);
        break;

      default:
        imagePathFinal = '';
    }

    if (imagePathFinal.contains('.gif')) {
      return Image.asset(
        '$gifPath$imagePathFinal',
        key: UniqueKey(),
        fit: BoxFit.fill,
      );
    }
    return Image.asset(
      '$pngPath$imagePathFinal',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.fill,
    );
  }

  static String _getSourceImagePath(int type, String position) {
    switch (position) {
      case 'First':
        return type==4?boreWellFirst:type==3?wellFirst:sumpFirst;
      case 'Center':
        return type==4?boreWellCenter:type==3?wellCenter:sumpCenter;
      case 'Last':
        return type==3?wellLast:sumpLast;
      default:
        return '';
    }
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

  static String getFertilizerImage(int cIndex, int status, int cheLength, List agitatorList) {
    String imageName;
    if(cIndex == cheLength - 1){
      if(agitatorList.isNotEmpty){
        imageName='dp_frt_channel_last_aj';
      }else{
        imageName='dp_frt_channel_last';
      }
    }else{
      if(agitatorList.isNotEmpty){
        if(cIndex==0){
          imageName='dp_frt_channel_first_aj';
        }else{
          imageName='dp_frt_channel_center_aj';
        }
      }else{
        imageName='dp_frt_channel_center';
      }
    }

    switch (status) {
      case 0:
        imageName += '.png';
        break;
      case 1:
        imageName += '_g.png';
        break;
      case 2:
        imageName += '_y.png';
        break;
      case 3:
        imageName += '_r.png';
        break;
      case 4:
        imageName += '.png';
        break;
      default:
        imageName += '.png';
    }

    return 'assets/png/$imageName';

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

  static String _getValveLjImagePath(int status) {
    switch (status) {
      case 0:
        return valveLjOFF;
      case 1:
        return valveLjON;
      case 2:
        return valveLjNotON;
      case 3:
        return valveLjNotOFF;
      default:
        return '';
    }
  }

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
  static int generalInConstant = 80;
  static int waterSourceInConstant = 81;
  static int levelSensorInConstant = 82;
  static int pumpInConstant = 83;
  static int filterSiteInConstant = 84;
  static int filterInConstant = 85;
  static int fertilizerSiteInConstant = 86;
  static int fertilizerChannelInConstant = 87;
  static int ecPhInConstant = 88;
  static int waterMeterInConstant = 89;
  static int pressureSensorInConstant = 90;
  static int mainValveInConstant = 91;
  static int valveInConstant = 92;
  static int moistureSensorInConstant = 93;
  static int analogSensorInConstant = 94;
  static int normalCriticalInConstant = 95;
  static int globalAlarmInConstant = 96;
  static int sourceObjectId = 1;
  static int pumpObjectId = 5;
  static int filterSiteObjectId = 4;
  static int filterObjectId = 11;
  static int mainValveObjectId = 14;
  static int valveObjectId = 13;
  static int levelObjectId = 26;
  static int floatObjectId = 40;
  static int irrigationLineObjectId = 2;
  static int waterMeterObjectId = 22;
  static int pressureSensorObjectId = 24;
  static int pressureSwitchObjectId = 23;
  static int fertilizerSiteObjectId = 3;
  static int channelObjectId = 10;
  static int boosterObjectId = 7;
  static int ecObjectId = 27;
  static int phObjectId = 28;
  static int moistureObjectId = 25;
  static int soilTemperatureObjectId = 30;

  static List<int> pumpWithValveModelList = [48, 49];
  static List<int> ecoGemModelList = [3];
  static List<int> gemModelList = [1, 2, 4];
  static List<int> weatherModelList = [13, 14];
  static List<int> pumpModelList = [5, 6, 7, 8, 9, 10];
  static List<int> senseModelList = [41, 42, 43, 44, 45];
  static List<int> ecoNodeList = [36];

}

/*
class GifImageWeb extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final String viewId;

  GifImageWeb({
    super.key,
    required this.imagePath,
    this.width = 70,
    this.height = 70,
  }) : viewId = 'gif_${imagePath.hashCode}' {
    ui.platformViewRegistry.registerViewFactory(
      viewId,
          (int viewId) => html.ImageElement()
        ..src = Uri.base.resolve(imagePath).toString()
        ..style.width = '${width}px'
        ..style.height = '${height}px'
        ..style.objectFit = 'contain',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: viewId),
    );
  }
}*/
