class WeatherStation {
  final int deviceId; // Device ID (S_No for the weather station)
  final List<Sensor> sensors;

  WeatherStation({
    required this.deviceId,
    required this.sensors,
  });

  factory WeatherStation.fromString(String data) {
    final parts = data.split(',');
    final deviceId = int.parse(parts[0]); // First index is device ID
    final sensors = <Sensor>[];

    // Start at index 1, step by 3, ensure we have full triplets
    for (int i = 1; i < parts.length - 2; i += 3) {
      try {
        final sensorSno = double.parse(parts[i]); // Sensor S_No
        final value = double.parse(parts[i + 1]); // Sensor Value
        final errorStatus = int.parse(parts[i + 2]); // Sensor Error Status
        sensors.add(Sensor(
          sno: sensorSno,
          value: value,
          errorStatus: errorStatus,
        ));
      } catch (e) {
        print('Error parsing sensor at index $i: $e');
        break; // Stop if we hit invalid data
      }
    }

    return WeatherStation(deviceId: deviceId, sensors: sensors);
  }
}

class Sensor {
  final double sno; // Sensor S_No (using double as per your data)
  final double value; // Sensor Value
  final int errorStatus; // Sensor Error Status

  Sensor({
    required this.sno,
    required this.value,
    required this.errorStatus,
  });
}

class WeatherData {
  final String cC;
  final String cT;
  final String cD;
  final List<WeatherStation> stations;

  WeatherData({
    required this.cC,
    required this.cT,
    required this.cD,
    required this.stations,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weatherLive = json['data']['weatherLive'];
    final cMString = weatherLive['cM']['5101'] as String;
    final stationsData = cMString.split(';');
    final stations = stationsData
        .where((data) => data.isNotEmpty)
        .map((data) => WeatherStation.fromString(data))
        .toList();

    return WeatherData(
      cC: weatherLive['cC'],
      cT: weatherLive['cT'],
      cD: weatherLive['cD'],
      stations: stations,
    );
  }
}