class WeatherModelNew {
  final WeatherLive weatherLive;
  final List<WeatherDeviceList> deviceList;
  final List<IrrigationLine> irrigationLine;
  final List<ConfigObjectNew> configObject;

  WeatherModelNew({
    required this.weatherLive,
    required this.deviceList,
    required this.irrigationLine,
    required this.configObject,
  });

  factory WeatherModelNew.fromJson(Map<String, dynamic> json) {
    return WeatherModelNew(
      weatherLive: WeatherLive.fromJson(json["weatherLive"] ?? {}),
      deviceList: List<WeatherDeviceList>.from(
        (json["deviceList"] as List? ?? []).map((x) => WeatherDeviceList.fromJson(x ?? {})),
      ),
      irrigationLine: List<IrrigationLine>.from(
        (json["irrigationLine"] as List? ?? []).map((x) => IrrigationLine.fromJson(x ?? {})),
      ),
      configObject: List<ConfigObjectNew>.from(
        (json["configObject"] as List? ?? []).map((x) => ConfigObjectNew.fromJson(x ?? {})),
      ),
    );
  }
}

class WeatherLive {
  final String cC;
  final CM cM;
  final DateTime cD;
  final String cT;
  final String mC;

  WeatherLive({
    required this.cC,
    required this.cM,
    required this.cD,
    required this.cT,
    required this.mC,
  });

  factory WeatherLive.fromJson(Map<String, dynamic> json) {
    return WeatherLive(
      cC: json["cC"] ?? "",
      cM: CM.fromJson(json["cM"] ?? {}),
      cD: DateTime.tryParse(json["cD"] ?? "") ?? DateTime.now(),
      cT: json["cT"] ?? "00:00",
      mC: json["mC"] ?? "",
    );
  }
}

class CM {
  final Map<String, dynamic> raw;

  CM({required this.raw});

  factory CM.fromJson(Map<String, dynamic> json) {
    return CM(raw: Map<String, dynamic>.from(json));
  }

  String get5101() => raw["5101"]?.toString() ?? "";
}

class WeatherDeviceList {
  final int controllerId;
  final String deviceId;
  final String deviceName;
  final int serialNumber;

  WeatherDeviceList({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.serialNumber,
  });

  factory WeatherDeviceList.fromJson(Map<String, dynamic> json) {
    return WeatherDeviceList(
      controllerId: json["controllerId"] ?? 0,
      deviceId: json["deviceId"] ?? "",
      deviceName: json["deviceName"] ?? "",
      serialNumber: json["serialNumber"] ?? 0,
    );
  }
}

class IrrigationLine {
  final int objectId;
  final double sNo;
  final String name;
  final String objectName;
  final List<int> weatherStation;

  IrrigationLine({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.objectName,
    required this.weatherStation,
  });

  factory IrrigationLine.fromJson(Map<String, dynamic> json) {
    return IrrigationLine(
      objectId: json["objectId"] ?? 0,
      sNo: (json["sNo"] as num?)?.toDouble() ?? 0,
      name: json["name"] ?? "",
      objectName: json["objectName"] ?? "",
      weatherStation:
      List<int>.from((json["weatherStation"] as List?) ?? const []),
    );
  }
}

class ConfigObjectNew {
  final int objectId;
  final double sNo;
  final String name;
  final String objectName;
  final int? controllerId;
  final double location;

  ConfigObjectNew({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.objectName,
    required this.controllerId,
    required this.location,
  });

  factory ConfigObjectNew.fromJson(Map<String, dynamic> json) {
    return ConfigObjectNew(
      objectId: json["objectId"] ?? 0,
      sNo: (json["sNo"] as num?)?.toDouble() ?? 0,
      name: json["name"] ?? "",
      objectName: json["objectName"] ?? "",
      controllerId: json["controllerId"],
      location: (json["location"] as num?)?.toDouble() ?? 0,
    );
  }
}

class WeatherStationWithSensors {
  final WeatherDeviceList device;
  final List<ConfigObjectNew> sensors;

  WeatherStationWithSensors({
    required this.device,
    required this.sensors,
  });
}

class IrrigationLineExpanded {
  final IrrigationLine line;
  final List<WeatherStationWithSensors> stations;

  IrrigationLineExpanded({
    required this.line,
    required this.stations,
  });
}

class LiveSensorValue {
  final double sNo;
  final double value;
  final int status;
  final double min;
  final double max;
  final double avg;

  LiveSensorValue({
    required this.sNo,
    required this.value,
    required this.status,
    required this.min,
    required this.max,
    required this.avg,
  });
}

extension WeatherModelTreeBuilder on WeatherModelNew {

  List<IrrigationLineExpanded> buildIrrigationLineTree() {
    final result = <IrrigationLineExpanded>[];
    
    final currentDeviceList = deviceList;
    final currentConfigObject = configObject;

    for (final line in irrigationLine) {
      final stations = <WeatherStationWithSensors>[];

      for (final controllerId in line.weatherStation) {
        final device = currentDeviceList.firstWhere(
              (d) => d.controllerId == controllerId,
          orElse: () =>
              WeatherDeviceList(
                controllerId: controllerId,
                deviceId: "",
                deviceName: "Unknown Device",
                serialNumber: -1,
              ),
        );

        final sensors = currentConfigObject.where((c) {
          return c.controllerId == controllerId;
        }).toList();

        stations.add(
          WeatherStationWithSensors(
            device: device,
            sensors: sensors,
          ),
        );
      }

      result.add(
        IrrigationLineExpanded(
          line: line,
          stations: stations,
        ),
      );
    }

    return result;
  }

  Map<int, List<LiveSensorValue>> parseLive5101() {
    final raw = weatherLive.cM.get5101();
    final result = <int, List<LiveSensorValue>>{};

    if (raw.isEmpty) return result;

    for (final part in raw.split(';')) {
      if (!part.contains(':')) continue;

      final split = part.split(':');
      if (split.length < 2) continue;
      
      // Handle "1,8.10,36.00" format where serial is the first element
      final header = split[0].split(',');
      final serial = int.tryParse(header[0]);
      if (serial == null) continue;

      final sensors = <LiveSensorValue>[];

      for (final block in split[1].split('_')) {
        final f = block.split(',');
        if (f.length < 5) continue;

        sensors.add(
          LiveSensorValue(
            sNo: double.tryParse(f[0] ?? "") ?? 0,
            value: double.tryParse(f[1] ?? "") ?? 0,
            status: int.tryParse(f[2] ?? "") ?? 0,
            min: double.tryParse(f[3] ?? "") ?? 0,
            max: double.tryParse(f[4] ?? "") ?? 0,
            avg: f.length > 5 ? (double.tryParse(f[5] ?? "") ?? 0) : 0,
          ),
        );
      }

      result[serial] = sensors;
    }

    return result;
  }
}