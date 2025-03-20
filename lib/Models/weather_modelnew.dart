

// Data Models
class WeatherStation {
  final int id;
  final String deviceName;
  final List<Sensor> sensors;

  WeatherStation({
    required this.id,
    required this.deviceName,
    required this.sensors,
  });

  factory WeatherStation.fromString(String data) {
    final parts = data.split(',');
    final id = int.parse(parts[0]);
    final deviceName = parts[1];
    final sensors = <Sensor>[];

    // Start at index 2, step by 3, ensure we have full triplets
    for (int i = 2; i < parts.length - 2; i += 3) {
      try {
        final errorStatus = int.parse(parts[i]);
        final value = double.parse(parts[i + 2]);
        sensors.add(Sensor(
          id: (i - 2) ~/ 3 + 1, // Sensor S_No (1 to 16)
          value: value,
          errorStatus: errorStatus,
        ));
      } catch (e) {
        print('Error parsing sensor at index $i: $e');
        break; // Stop if we hit invalid data
      }
    }

    return WeatherStation(id: id, deviceName: deviceName, sensors: sensors);
  }
}

class Sensor {
  final int id; // S_No
  final double value;
  final int errorStatus;

  Sensor({
    required this.id,
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