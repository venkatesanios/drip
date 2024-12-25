
// Todo interface
import 'dart:ui';

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
    default :
      return 0;
  }
}
String getInterfaceCodeToString(int code){
  switch(code){
    case 1 :
      return 'MQTT';
    case 2 :
      return 'LoRa';
    case 3 :
      return 'RS485';
    case 4 :
      return 'Wi-Fi';
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
