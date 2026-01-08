class WeatherLiveUIModel {
  final String deviceName;
  final String irrigationLine;
  final String objectName;
  final String sensorType;
  final String value;
  final String errorCode;
  final String minValue;
  final String maxValue;
  final String otherValue;

  WeatherLiveUIModel({
    required this.deviceName,
    required this.irrigationLine,
    required this.objectName,
    required this.sensorType,
    required this.value,
    required this.errorCode,
    required this.minValue,
    required this.maxValue,
    required this.otherValue,
  });

  @override
  String toString() {
    return '''
Device       : $deviceName
Irrigation   : $irrigationLine
Sensor       : $objectName
Type         : $sensorType
Value        : $value
Error Code   : $errorCode
minValue     : $minValue
maxValue     : $maxValue
otherValue   : $otherValue
---------------------------
''';
  }
}


Map<int, Map<String, dynamic>> deviceBySerial(List devices) {
  return {
    for (final d in devices)
      d['serialNumber']: Map<String, dynamic>.from(d),
  };
}

Map<double, Map<String, dynamic>> configBySNo(List configs) {
  return {
    for (final c in configs)
      (c['sNo'] as num).toDouble(): Map<String, dynamic>.from(c),
  };
}

Map<double, Map<String, dynamic>> irrigationBySNo(List irrigation) {
  return {
    for (final i in irrigation)
      (i['sNo'] as num).toDouble(): Map<String, dynamic>.from(i),
  };
}


class WeatherDevice {
  final int controllerId;
  final String deviceName;

  WeatherDevice({
    required this.controllerId,
    required this.deviceName,
  });
}