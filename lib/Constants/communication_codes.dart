import 'dart:ui';



// Todo interface
int getInterfaceStringToCode(String title){
  switch(title){
    case 'MQTT' :
      return 1;
    case 'LoRa' :
      return 2;
    case 'RS485' :
      return 3;
    case 'Wi-Fi' :
      return 4;
    case 'Extend' :
      return 5;
    default :
      return 0;
  }
}
String getInterfaceCodeToString(int? code){
  switch(code){
    case 1 :
      return 'MQTT';
    case 2 :
      return 'LoRa';
    case 3 :
      return 'RS485';
    case 4 :
      return 'Wi-Fi';
    case 5 :
      return 'Extend';
    default :
      return '-';
  }
}

//Todo interval
int getIntervalStringToCode(String title){
  String val = title;
  List<String> stringToList = val.split(' ');
  return int.parse(stringToList[0]);
}
String getIntervalCodeToString(int code, String mergeParameter){
  return '$code $mergeParameter';
}

//Todo objectType
String getObjectTypeCodeToString(int code){
  switch(code){
    case 1 :
      return 'Relay';
    case 2 :
      return 'Latch';
    case 3 :
      return 'Analog Input';
    case 4 :
      return 'Digital Input';
    case 5 :
      return 'Moisture Input';
    case 6 :
      return 'Pulse Input';
    case 7:
      return 'I2C Input';
    default :
      return 'I2C Input';
  }
}
Color getObjectTypeCodeToColor(int code){
  switch(code){
    case 1 :
      return const Color(0xffD2EAFF);
    case 2 :
      return const Color(0xffD2EAFF);
    case 3 :
      return const Color(0xffFFFCDE);
    case 4 :
      return const Color(0xffDBFFC3);
    case 5 :
      return const Color(0xffFDBEFF);
    case 6 :
      return const Color(0xffFFEDEB);
    case 7 :
      return const Color(0xffEDC9B1);
    default :
      return const Color(0xffDBDEFF);
  }
}

//Todo deviceType
String getDeviceCodeToString(int code){
  switch(code){
    case 1 :
      return 'GEM';
    case 2 :
      return 'PUMP';
    case 3 :
      return 'LEVEL';
    case 4 :
      return 'WEATHER';
    case 5 :
      return 'SMART';
    case 6 :
      return 'SMART PLUS';
    case 7:
      return 'RTU';
    case 8:
      return 'RTU PLUS';
    case 9:
      return 'SENSE';
    case 10:
      return 'EXTEND';
    default :
      return '-';
  }
}

// Todo: tankType
String getTankCodeToString(int code){
  switch(code){
    case 1 :
      return 'Tank';
    case 2 :
      return 'Sump';
    case 3 :
      return 'Well';
    case 4 :
      return 'Bore';
    case 5 :
      return 'Others';
    default :
      return '-';
  }
}
int getTankStringToCode(String type){
  switch(type){
    case 'Tank' :
      return 1;
    case 'Sump' :
      return 2;
    case 'Well' :
      return 3;
    case 'Bore' :
      return 4;
    case 'Others' :
      return 5;
    default :
      return 0;
  }
}

// Todo: tankType
String getPumpTypeCodeToString(int code){
  switch(code){
    case 1 :
      return 'source';
    case 2 :
      return 'irrigation';
    default :
      return '-';
  }
}
int getPumpTypeStringToCode(String type){
  switch(type){
    case 'source' :
      return 1;
    case 'irrigation' :
      return 2;
    default :
      return 0;
  }
}

