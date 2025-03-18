import 'package:flutter/cupertino.dart';
import 'package:oro_drip_irrigation/view_models/create_account_view_model.dart';
import 'package:provider/provider.dart';
import '../StateManagement/mqtt_payload_provider.dart';

class MyFunction{

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

  double convertMetersToFeet(double meters) {
    return meters * 3.28084;
  }

  double convertMetersToInches(double meters) {
    return meters * 39.3701;
  }

  double convertBarToKPa(double bar) {
    return bar * 100;
  }

}