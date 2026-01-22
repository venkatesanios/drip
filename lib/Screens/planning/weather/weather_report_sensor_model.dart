class SensorHourReport {
  final String hour;
  final String deviceSrNo;
  final String sensorSrNo;
  final String value;
  final String errorCode;
  final String minValue;
  final String maxValue;
  final String averageValue;

  SensorHourReport({
    required this.hour,
    required this.deviceSrNo,
    required this.sensorSrNo,
    required this.value,
    required this.errorCode,
    required this.minValue,
    required this.maxValue,
    required this.averageValue,
  });

  @override
  String toString() {
    return '$hour → value:$value min:$minValue max:$maxValue avg:$averageValue error:$errorCode';
  }
}
SensorHourReport? parseSensorRecord({
  required String raw,
  required String hour,
  required String targetDevice,
  required String targetSensor,
})
{
  final parts = raw.split(',');
  if (parts.length < 6) return null;

  final deviceSensor = parts[0].split(':');
  if (deviceSensor.length != 2) return null;

  final deviceSrNo = deviceSensor[0];
  final sensorSrNo = deviceSensor[1];

  // 🔴 FILTER CONDITION
  if (deviceSrNo != targetDevice || sensorSrNo != targetSensor) {
    return null;
  }

  return SensorHourReport(
    hour: hour,
    deviceSrNo: deviceSrNo,
    sensorSrNo: sensorSrNo,
    value: parts[1],
    errorCode: parts[2],
    minValue: parts[3],
    maxValue: parts[4],
    averageValue: parts[5],
  );
}
List<SensorHourReport> getSingleSensorReport({
  required Map<String, dynamic> apiResponse,
  required String deviceSrNo,
  required String sensorSrNo,
})
{
  final List<SensorHourReport> report = [];

  if (apiResponse['data'] == null || apiResponse['data'].isEmpty) {
    return report;
  }

  final Map<String, dynamic> dayData = apiResponse['data'][0];

  dayData.forEach((key, value) {
    // skip date & invalid keys
    if (key == 'date' || !key.contains(':')) return;

    if (value == null || value.toString().isEmpty) return;

    final String hour = key;

    // Step 1: split by time blocks (;)
    final timeBlocks = value.toString().split(';');

    for (final block in timeBlocks) {
      // Step 2: split sensors (_)
      final sensors = block.split('_');

      for (final sensorRaw in sensors) {
        final parsed = parseSensorRecord(
          raw: sensorRaw,
          hour: hour,
          targetDevice: deviceSrNo,
          targetSensor: sensorSrNo,
        );

        if (parsed != null) {
          report.add(parsed);
        }
      }
    }
  });

  return report;
}
