import 'package:flutter/cupertino.dart';
import 'package:oro_drip_irrigation/view_models/create_account_view_model.dart';
import 'package:provider/provider.dart';
import '../StateManagement/mqtt_payload_provider.dart';

class MyFunction {

  String? getUnitByParameter(BuildContext context, String parameter, String value) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    try {
      Map<String, dynamic>? unitMap = payloadProvider.unitList.firstWhereOrNull(
            (unit) => unit['parameter'] == parameter,
      );

      if (unitMap == null) return '';

      double parsedValue = double.tryParse(value) ?? 0.0;

      if (parameter == 'Level Sensor') {
        switch (unitMap['value']) {
          case 'm':
            return 'meter: $value';
          case 'feet':
            return '${convertMetersToFeet(parsedValue).toStringAsFixed(2)} feet';
          default:
            return '${convertMetersToInches(parsedValue).toStringAsFixed(2)} inches';
        }
      }
      else if (unitMap['parameter'] == 'Pressure Sensor') {
        double barValue = double.tryParse(value) ?? 0.0;
        if (unitMap['value'] == 'bar') {
          return '$value ${unitMap['value']}';
        } else if (unitMap['value'] == 'kPa') {
          double convertedValue = convertBarToKPa(barValue);
          return '${convertedValue.toStringAsFixed(2)} kPa';
        }
      }
      else if (parameter == 'Water Meter') {
        double lps = parsedValue;
        switch (unitMap['value']) {
          case 'l/s':
            return '$value l/s';
          case 'l/h':
            return '${(lps * 3600).toStringAsFixed(2)} l/h';
          case 'm3/h':
            return '${(lps *3.6).toStringAsFixed(2)} m³/h';
          default:
            return '$value l/s';
        }
      }
      return '$parsedValue ${unitMap['value']}';
    } catch (e) {
      print('Error: $e');
      return 'Error: $e';
    }
  }

  String? getUnitValue(BuildContext context, String parameter, String value) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    try {
      Map<String, dynamic>? unitMap = payloadProvider.unitList.firstWhereOrNull(
            (unit) => unit['parameter'] == parameter,
      );
      if (unitMap == null) return '';
      return unitMap['value'];
    } catch (e) {
      print('Error: $e');
      return 'Error: $e';
    }
  }

  String getSensorUnit(String type, BuildContext context) {
    if(type.contains('Moisture')||type.contains('SM')){
      return 'Values in Cb';
    }
    else if(type.contains('Pressure')){
      return 'Values in bar';
    }
    else if(type.contains('Level')){
      MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
      Map<String, dynamic>? unitMap = payloadProvider.unitList.firstWhereOrNull(
            (unit) => unit['parameter'] == 'Level Sensor',
      );
      if (unitMap == null) return '';
      return 'Values in ${unitMap['value']}';
    }
    else if(type.contains('Humidity')){
      return 'Percentage (%)';
    }
    else if(type.contains('Co2')){
      return 'Parts per million(ppm)';
    }else if(type.contains('Temperature')){
      return 'Celsius (°C)';
    }else if(type.contains('EC')||type.contains('PH')){
      return 'Siemens per meter (S/m)';
    }else if(type.contains('Power')){
      return 'Volts';
    }else if(type.contains('Water')){
      return 'Cubic Meters (m³)';
    }else{
      return 'Sensor value';
    }
  }

  double convertMetersToFeet(double meters) {
    return meters * 3.28084;
  }

  double convertMetersToInches(double meters) {
    return meters * 39.3701;
  }

  double convertBarToKPa(double bar) {
    return bar * 100;
  }

  String getAlarmMessage(int alarmType) {
    String msg = '';
    switch (alarmType) {
      case 1:
        msg ='Low Flow';
        break;
      case 2:
        msg ='High Flow';
        break;
      case 3:
        msg ='No Flow';
        break;
      case 4:
        msg ='Ec High';
        break;
      case 5:
        msg ='Ph Low';
        break;
      case 6:
        msg ='Ph High';
        break;
      case 7:
        msg ='Pressure Low';
        break;
      case 8:
        msg ='Pressure High';
        break;
      case 9:
        msg ='No Power Supply';
        break;
      case 10:
        msg ='No Communication';
        break;
      case 11:
        msg ='Wrong Feedback';
        break;
      case 12:
        msg ='Sump Tank Empty';
        break;
      case 13:
        msg ='Top Tank Full';
        break;
      case 14:
        msg ='Low Battery';
        break;
      case 15:
        msg ='Ec Difference';
        break;
      case 16:
        msg ='Ph Difference';
        break;
      case 17:
        msg ='Pump Off Alarm';
        break;
      case 18:
        msg ='Pressure Switch high';
        break;
      default:
        msg ='alarmType default';
    }
    return msg;
  }

  //my spacial function--------------------------------------------------------------
  //---------------------------------------------------------------------------------
  Set<String> items = {};
  void addItem(String item) {
    items.add(item); // Set automatically handles uniqueness.
  }

  final Map<IrrigationParams, double> _irrigationCache = {};

  double calculateIrrigationTime(IrrigationParams params) {
    if (_irrigationCache.containsKey(params)) {
      return _irrigationCache[params]!; // Return cached
    }

    // Simulated complex calculation
    double cropFactor = params.cropType == 'Rice' ? 1.5 : 1.0;
    double soilFactor = params.soilType == 'Clay' ? 0.8 : 1.2;
    double weatherFactor = params.weather == 'Hot' ? 1.4 : 1.0;
    double moistureFactor = (100 - params.moistureLevel) / 100;

    double time = params.area * cropFactor * soilFactor * weatherFactor * moistureFactor;

    _irrigationCache[params] = time; // Store result
    return time;
  }

}

class IrrigationParams {
  final String cropType;
  final String soilType;
  final double moistureLevel;
  final String weather;
  final double area;

  IrrigationParams({
    required this.cropType,
    required this.soilType,
    required this.moistureLevel,
    required this.weather,
    required this.area,
  });

  // To use as a Map key, we need proper equality and hashCode
  @override
  bool operator ==(Object other) =>
      other is IrrigationParams &&
          cropType == other.cropType &&
          soilType == other.soilType &&
          moistureLevel == other.moistureLevel &&
          weather == other.weather &&
          area == other.area;

  @override
  int get hashCode =>
      cropType.hashCode ^
      soilType.hashCode ^
      moistureLevel.hashCode ^
      weather.hashCode ^
      area.hashCode;
}