
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_json_model.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_live_model.dart';

List<WeatherLiveUIModel> parseWeatherLive(
    WeatherJsonModel model,
    int selectedSerial,
    ) {
  print("selectedSerial:$selectedSerial");
  final String raw = model.data.weatherLive.cM.the5101;

  // Maps for quick lookup
  final deviceMap = {for (var d in model.data.deviceList) d.serialNumber: d};
  final configMap = {for (var c in model.data.configObject) c.sNo: c};
  final irrigationMap = {for (var i in model.data.irrigationLine) i.sNo: i};

  final List<WeatherLiveUIModel> result = [];
  final Set<double> addedSensors = {}; // track objectSNo to avoid duplicates

  // Get device once
  final device = deviceMap[selectedSerial];
  if (device == null) return result;

  String commonIrrigationLine = "-";

  // 1️⃣ Split devices by ";" (like parseWeather)
  final devices = raw.contains(";") ? raw.split(';') : [raw];

  for (final deviceBlock in devices) {
    if (deviceBlock.trim().isEmpty) continue;

    final firstColon = deviceBlock.indexOf(':');
    if (firstColon == -1) continue;

    final int? deviceId = int.tryParse(deviceBlock.substring(0, firstColon));
    if (deviceId != selectedSerial) continue; // only selected device

    final sensorPart = deviceBlock.substring(firstColon + 1);
    final sensors = sensorPart.split('_');

    for (final sensor in sensors) {
      final values = sensor.split(',');
      if (values.length < 6) continue; // must have all fields

      final double objectSNo = double.parse(values[0]);

      // skip duplicates
      if (addedSensors.contains(objectSNo)) continue;
      addedSensors.add(objectSNo);

      final String sensorValue = values[1];
      final String errorCode = values[2];

      final config = configMap[objectSNo];
      if (config == null) continue;

      // set irrigation line once
      if (commonIrrigationLine == "-") {
        final irrigation = irrigationMap[config.location];
        commonIrrigationLine = irrigation?.name ?? "-";
      }

      result.add(
        WeatherLiveUIModel(
          deviceName: device.deviceName,
          irrigationLine: commonIrrigationLine,
          objectName: config.name,
          sensorType: config.objectName,
          value: sensorValue,
          errorCode: errorCode,
          minValue: values[3],
          maxValue: values[4],
          otherValue: values[5],
        ),
      );
    }
  }

  print("Total sensors: ${result.length}");
  print(" sensors: ${result}");
  return result;
}
