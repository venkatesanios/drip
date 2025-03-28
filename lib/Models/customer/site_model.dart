
import '../../modules/PumpController/model/pump_controller_data_model.dart';
import '../../utils/constants.dart';

class SiteModel {
  final List<Group> data;

  SiteModel({required this.data});

  factory SiteModel.fromJson(Map<String, dynamic> json) {

    return SiteModel(
      data: List<Group>.from(json['data'].map((x) => Group.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}

class Group {
  final int groupId;
  final String groupName;
  final List<Master> master;

  Group({required this.groupId, required this.groupName, required this.master});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupId: json['userGroupId'],
      groupName: json['groupName'],
      master: List<Master>.from(json['master'].map((x) => Master.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userGroupId': groupId,
      'groupName': groupName,
      'master': master.map((x) => x.toJson()).toList(),
    };
  }
}

class Master {
  final int controllerId;
  final String deviceId;
  final String deviceName;
  final int categoryId;
  final String categoryName;
  final int modelId;
  final String modelName;
  final List<Unit> units;
  final Config config;
  List<ConfigObject> configObjects;
  late final LiveMessage? live;
  List<NodeListModel> nodeList;
  List<ProgramList> programList;

  Master({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.categoryId,
    required this.categoryName,
    required this.modelId,
    required this.modelName,
    required this.units,
    required this.config,
    required this.configObjects,
    required this.live,
    required this.nodeList,
    required this.programList,
  });

  factory Master.fromJson(Map<String, dynamic> json) {

    List<ConfigObject> configObjects = json["config"] != null &&
        json["config"] is Map<String, dynamic> &&
        json["config"]['configObject'] != null
        ? (json["config"]['configObject'] as List)
        .map((item) => ConfigObject.fromJson(item))
        .toList()
        : [];

    return Master(
      controllerId: json['controllerId'] ?? 0,
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      modelId: json['modelId'] ?? 0,
      modelName: json['modelName'] ?? '',
      units: json['units'] != null
          ? List<Unit>.from(json['units'].map((x) => Unit.fromJson(x)))
          : [],
      configObjects: configObjects,

      config: (json["config"] != null && json["config"] is Map<String, dynamic> && json["config"].isNotEmpty)
          ? Config.fromJson(Map<String, dynamic>.from(AppConstants.payloadConversion(json["config"])))
          : Config(waterSource: [], pump: [], filterSite: [], fertilizerSite: [], moistureSensor: [], lineData: []),

      live: json['liveMessage'] != null ? LiveMessage.fromJson(json['liveMessage']) : null,
      nodeList: json['nodeList'] != null
          ? (json['nodeList'] as List)
          .map((item) => NodeListModel.fromJson(item, configObjects))
          .toList()
          : [],
      programList: json['program'] != null
          ? (json['program'] as List)
          .map((prgList) => ProgramList.fromJson(prgList))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'controllerId': controllerId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'modelId': modelId,
      'modelName': modelName,
      'units': units.map((x) => x.toJson()).toList(),
      'config': config,
      'liveMessage': live?.toJson(),
    };
  }
}

class RelayStatus {
  final double? sNo;
  final String? name;
  String? swName;
  final int? rlyNo;
  int status;

  RelayStatus({
    required this.sNo,
    required this.name,
    required this.swName,
    required this.rlyNo,
    this.status=0,
  });

  factory RelayStatus.fromJson(Map<String, dynamic> json) {
    return RelayStatus(
      sNo: json['sNo'],
      name: json['name'],
      swName: json['name'] ?? json['objectName'],
      rlyNo: json['connectionNo'],
    );
  }

}

class Unit {
  final int dealerDefinitionId;
  final String parameter;
  final String value;

  Unit({required this.dealerDefinitionId, required this.parameter, required this.value});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      dealerDefinitionId: json['dealerDefinitionId'],
      parameter: json['parameter'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dealerDefinitionId': dealerDefinitionId,
      'parameter': parameter,
      'value': value,
    };
  }

  static List<Map<String, dynamic>> toJsonList(List<Unit> units) {
    return units.map((unit) => unit.toJson()).toList();
  }
}

class ConfigObject {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final int? count;
  final double? location;

  ConfigObject({
    required this.objectId,
    required this.sNo,
    required this.name,
    this.connectionNo,
    required this.objectName,
    required this.type,
    this.controllerId,
    this.count,
    required this.location,
  });

  factory ConfigObject.fromJson(Map<String, dynamic> json) {
    return ConfigObject(
      objectId: json['objectId'],
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
      location: (json['location'] is! double ? 0.0 : json['location']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
      'location': location,
    };
  }
}

class Config {
  final List<WaterSource> waterSource;
  final List<Pump> pump;
  final List<FilterSite> filterSite;
  final List<FertilizerSite> fertilizerSite;
  final List<dynamic> moistureSensor;
  final List<IrrigationLineData> lineData;

  Config({
    required this.waterSource,
    required this.pump,
    required this.filterSite,
    required this.fertilizerSite,
    required this.moistureSensor,
    required this.lineData,
  });

  factory Config.fromJson(Map<String, dynamic> json) {

    var irrigationLine = json['irrigationLine'] as List;
    if(irrigationLine.isNotEmpty && irrigationLine.length>1){
      var allLine = {
        "objectId": 0,
        "sNo": 0,
        "name": "All irrigation line",
        "connectionNo": null,
        "objectName": "All Line",
        "type": "",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "source": [],
        "sourcePump": [],
        "irrigationPump": [],
        "centralFiltration": 0,
        "localFiltration": 0,
        "centralFertilization": 0,
        "localFertilization": 0,
        "valve": [],
        "mainValve": [],
        "fan": [],
        "fogger": [],
        "pesticides": [],
        "heater": [],
        "screen": [],
        "vent": [],
        "powerSupply": 0,
        "pressureSwitch": 0,
        "waterMeter": 0,
        "pressureIn": 0,
        "pressureOut": 0,
        "moisture": [],
        "temperature": [],
        "soilTemperature": [],
        "humidity": [],
        "co2": []
      };
      irrigationLine.insert(0, allLine);
    }

    List<IrrigationLineData> irgLine = irrigationLine.isNotEmpty? irrigationLine.map((irl) => IrrigationLineData.fromJson(irl)).toList() : [];

    return Config(
      waterSource: (json['waterSource'] as List)
          .map((e) => WaterSource.fromJson(e))
          .toList(),
      pump: (json['pump'] as List).map((e) => Pump.fromJson(e)).toList(),
      filterSite: (json['filterSite'] as List)
          .map((e) => FilterSite.fromJson(e))
          .toList(),
      fertilizerSite: (json['fertilizerSite'] as List)
          .map((e) => FertilizerSite.fromJson(e))
          .toList(),
      moistureSensor: json['moistureSensor'] ?? [],
      lineData: irgLine,
    );
  }
}

class WaterSource {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final dynamic count;
  final Level? level;
  final List<Pump> inletPump;
  final List<Pump> outletPump;
  final List<dynamic> valves;

  WaterSource({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    required this.count,
    required this.level,
    required this.inletPump,
    required this.outletPump,
    required this.valves,
  });

  factory WaterSource.fromJson(Map<String, dynamic> json) {
    return WaterSource(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'] ?? 0,
      count: json['count'] ?? 0,
      level: json['level'] != null && json['level'].isNotEmpty
          ? Level.fromJson(json['level'])
          : null,
      outletPump: (json['outletPump'] as List)
          .map((e) => Pump.fromJson(e))
          .toList(),
      inletPump: (json['inletPump'] as List)
          .map((e) => Pump.fromJson(e))
          .toList(),
      valves: json['valves'] ?? [],
    );
  }
}

class Pump {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final dynamic count;
  int status;
  bool selected;
  String onDelayLeft;
  String voltage;
  String current;
  String reason;
  String setValue;
  String actualValue;
  String phase;

  Pump({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    required this.count,
    this.status=0,
    this.selected=false,
    this.onDelayLeft='00:00:00',
    this.voltage='0_0_0',
    this.current='0_0_0',
    this.reason='0',
    this.setValue='0',
    this.actualValue='0',
    this.phase='0',
  });

  factory Pump.fromJson(Map<String, dynamic> json) {
    return Pump(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
    );
  }
}

class FilterSite {
  final int objectId;
  final double sNo;
  final String name;
  final String? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final int? count;
  final int siteMode;
  final List<Filters> filters;
  final PressureSensor? pressureIn;
  final PressureSensor? pressureOut;
  final Map<String, dynamic>? backWashValve;

  FilterSite({
    required this.objectId,
    required this.sNo,
    required this.name,
    this.connectionNo,
    required this.objectName,
    required this.type,
    this.controllerId,
    this.count,
    required this.siteMode,
    required this.filters,
    required this.pressureIn,
    required this.pressureOut,
    required this.backWashValve,
  });

  factory FilterSite.fromJson(Map<String, dynamic> json) {
    print(json);

    var filterList = json['filters'] as List;
    List<Filters> filters = filterList.map((filter) => Filters.fromJson(filter)).toList();

    return FilterSite(
      objectId: json['objectId'],
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
      siteMode: json['siteMode'],
      filters: filters,
      pressureIn: json['pressureIn'] != null
          ? PressureSensor.fromJson(Map<String, dynamic>.from(json['pressureIn']))
          : null,
      pressureOut: json['pressureOut'] != null
          ? PressureSensor.fromJson(Map<String, dynamic>.from(json['pressureOut']))
          : null,
      backWashValve: json['backWashValve'] != null
          ? Map<String, dynamic>.from(json['backWashValve'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
      'siteMode': siteMode,
      'filters': filters,
      'pressureIn': pressureIn,
      'pressureOut': pressureOut,
      'backWashValve': backWashValve,
    };
  }
}

class PressureSensor {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String? objectName;
  final String? type;
  final int? controllerId;
  String value;

  PressureSensor({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.value='0',
  });

  factory PressureSensor.fromJson(Map<String, dynamic> json) {
    return PressureSensor(
      objectId: json['objectId'] ?? 0,
      sNo: (json['sNo'] as num?)?.toDouble() ?? 0.0,
      name: json['name'] ?? '',
      connectionNo: json['connectionNo'] ?? 0,
      objectName: json['objectName'] ?? '',
      type: json['type']?.toString() ?? '', // Handle multiple types
      controllerId: json['controllerId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "objectId": objectId,
    "sNo": sNo,
    "name": name,
    "connectionNo": connectionNo,
    "objectName": objectName,
    "type": type,
    "controllerId": controllerId,
  };
}

class Filters {
  double sNo;
  String name;
  int status;
  bool selected;

  Filters({required this.sNo, required this.name, this.status = 0, this.selected=false});

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      sNo: json['sNo'],
      name: json['name'],
    );
  }
}

class FertilizerSite {
  final int objectId;
  final double sNo;
  final String name;
  final String? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final int? count;
  final int siteMode;
  final List<Channel> channel;
  final List<BoosterPump> boosterPump;
  final List<Agitator> agitator;
  final List<dynamic> selector;

  List<Ec>? ec;
  List<Ph>? ph;


  FertilizerSite({
    required this.objectId,
    required this.sNo,
    required this.name,
    this.connectionNo,
    required this.objectName,
    required this.type,
    this.controllerId,
    this.count,
    required this.siteMode,
    required this.channel,
    required this.boosterPump,
    required this.agitator,
    required this.selector,
    required this.ec,
    required this.ph,

  });

  factory FertilizerSite.fromJson(Map<String, dynamic> json) {
    return FertilizerSite(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
      siteMode: json['siteMode'],
      channel: (json['channel'] as List).map((e) => Channel.fromJson(e)).toList(),
      boosterPump: (json['boosterPump'] as List).map((e) => BoosterPump.fromJson(e)).toList(),
      agitator: (json['agitator'] as List).map((e) => Agitator.fromJson(e)).toList(),
      selector: json['selector'] ?? [],
      ec: (json['ec'] != null && json['ec'] is List && json['ec'].isNotEmpty)
          ? (json['ec'] as List).map((e) => Ec.fromJson(e)).toList()
          : [],
      ph: (json['ph'] != null && json['ph'] is List && json['ph'].isNotEmpty)
          ? (json['ph'] as List).map((e) => Ph.fromJson(e)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
      'siteMode': siteMode,
      'channel': channel.map((e) => e.toJson()).toList(),
      'boosterPump': boosterPump.map((e) => e.toJson()).toList(),
      'agitator': agitator.map((e) => e.toJson()).toList(),
      'selector': selector,
      'ec': ec?.map((e) => e.toJson()).toList(),
      'ph': ph?.map((e) => e.toJson()).toList(),
    };
  }
}

class Channel {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final int? count;
  final double level;
  bool selected;
  int status;
  String qty;
  String qtyLeft;
  String fertMethod;
  String duration;
  String durationLeft;
  String flowRate_LpH;



  Channel({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.count,
    required this.level,
    this.status=0,
    this.selected=false,
    this.qty = '0',
    this.qtyLeft = '0',
    this.fertMethod = '0',
    this.duration = '00:00:00',
    this.durationLeft = '00:00:00',
    this.flowRate_LpH = '-',
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'] ?? 0,
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'] ?? 0,
      count: json['count'] ?? 0,
      level: json['level'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
      'level': level,
    };
  }
}

class Ec {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final int? count;
  String value;

  Ec({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.count,
    this.value = '0',
  });

  factory Ec.fromJson(Map<String, dynamic> json) {
    return Ec(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
    };
  }


}

class Ph {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final int? count;
  String value;

  Ph({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.count,
    this.value = '0',
  });

  factory Ph.fromJson(Map<String, dynamic> json) {
    return Ph(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
    };
  }

}

class BoosterPump {
  final int objectId;
  final double sNo;
  final String name;
  final int connectionNo;
  final String objectName;
  final String type;
  final int controllerId;
  final int? count;
  bool selected;
  int status;

  BoosterPump({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.count,
    this.selected=false,
    this.status = 0,
  });

  factory BoosterPump.fromJson(Map<String, dynamic> json) {
    return BoosterPump(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
    };
  }
}

class Agitator {
  final int objectId;
  final double sNo;
  final String name;
  final int connectionNo;
  final String objectName;
  final String type;
  final int controllerId;
  final int? count;
  bool selected;
  int status;

  Agitator({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.count,
    this.selected=false,
    this.status=0,
  });

  factory Agitator.fromJson(Map<String, dynamic> json) {
    return Agitator(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
    };
  }
}

class IrrigationLineData {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final dynamic count;
  final List<Pump> irrigationPump;
  final List<SensorModel> prsSwitch;
  final List<SensorModel> pressureIn;
  final List<SensorModel> waterMeter;


  final double? centralFiltration;
  //final double? localFiltration;
  final List<Valve> valves;



  IrrigationLineData({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    required this.count,
    required this.irrigationPump,
    required this.prsSwitch,
    required this.pressureIn,
    required this.waterMeter,

    required this.centralFiltration,
    //required this.localFiltration,
    required this.valves,
  });

  factory IrrigationLineData.fromJson(Map<String, dynamic> json) {
    print(json);
    print(json['pressureSwitch']);
    double cFilterSNo = 0.0;
    if (json['centralFiltration'] != null && json['centralFiltration'].toString().trim().isNotEmpty) {
      if (json['centralFiltration'] is int) {
        cFilterSNo = (json['centralFiltration'] as num).toDouble();
      } else if (json['centralFiltration'] is Map && json['centralFiltration'].containsKey('sNo')) {
        cFilterSNo = json['centralFiltration']['sNo'];
      }
    }

    return IrrigationLineData(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
      prsSwitch: (json['pressureSwitch'] == null ||
          json['pressureSwitch'] == 0 ||
          (json['pressureSwitch'] is List && json['pressureSwitch'].isEmpty))
          ? []
          : (json['pressureSwitch'] is List)
          ? (json['pressureSwitch'] as List)
          .where((e) => e != null) // Ensure non-null elements
          .map((e) => SensorModel.fromJson(e))
          .toList()
          : (json['pressureSwitch'] is Map<String, dynamic>)
          ? [SensorModel.fromJson(json['pressureSwitch'])]
          : [],

      pressureIn: (json['pressureIn'] == null ||
          json['pressureIn'] == 0 ||
          (json['pressureIn'] is List && json['pressureIn'].isEmpty))
          ? []
          : (json['pressureIn'] is List)
          ? (json['pressureIn'] as List)
          .where((e) => e != null) // Ensure non-null elements
          .map((e) => SensorModel.fromJson(e))
          .toList()
          : (json['pressureIn'] is Map<String, dynamic>)
          ? [SensorModel.fromJson(json['pressureIn'])]
          : [],

      waterMeter: (json['waterMeter'] == null ||
          json['waterMeter'] == 0 ||
          (json['waterMeter'] is List && json['pressureIn'].isEmpty))
          ? []
          : (json['waterMeter'] is List)
          ? (json['waterMeter'] as List)
          .where((e) => e != null) // Ensure non-null elements
          .map((e) => SensorModel.fromJson(e))
          .toList()
          : (json['waterMeter'] is Map<String, dynamic>)
          ? [SensorModel.fromJson(json['waterMeter'])]
          : [],

      irrigationPump: (json['irrigationPump'] as List)
          .map((e) => Pump.fromJson(e))
          .toList(),
      centralFiltration: cFilterSNo,
      //localFiltration: (json['localFiltration'] as num).toDouble(),
      valves: (json['valve'] as List).map((v) => Valve.fromJson(v))
          .toList(),
    );
  }
}

class SensorModel {
  final int objectId;
  final double sNo;
  final String name;
  int status;
  String value;

  SensorModel({
    required this.objectId,
    required this.sNo,
    required this.name,
    this.status = 0,
    this.value = '0',
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      objectId: json['objectId'],
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      "status": status,
      "value": value,
    };
  }
}

class Valve {
  final int objectId;
  final double sNo;
  final String name;
  final int connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final int? count;
  int status;
  bool isOn;

  Valve({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.connectionNo,
    required this.objectName,
    required this.type,
    required this.controllerId,
    this.count,
    this.status = 0,
    this.isOn = false,
  });

  factory Valve.fromJson(Map<String, dynamic> json) {
    return Valve(
      objectId: json['objectId'],
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId']??0,
      count: json['count']??0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'connectionNo': connectionNo,
      'objectName': objectName,
      'type': type,
      'controllerId': controllerId,
      'count': count,
      "status": status,
    };
  }
}

class Level {
  int? objectId;
  double? sNo;
  String? name;
  String? percentage;
  int? connectionNo;
  int? controllerId;

  Level({
    this.objectId,
    this.sNo,
    this.name,
    this.percentage='0',
    this.connectionNo,
    this.controllerId,
  });

  factory Level.fromJson(Map<String, dynamic> json) => Level(
    objectId: json['objectId'],
    sNo: json['sNo'],
    name: json['name'],
    //percentage: json['percentage'],
    connectionNo: json['connectionNo'],
    controllerId: json['controllerId'],
  );
}

class Item {
  int? objectId;
  double? sNo;
  String? name;
  int status;

  Item({this.objectId, this.sNo, this.name, this.status = 0});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    objectId: json['objectId'],
    sNo: json['sNo'],
    name: json['name'],
  );

  Map<String, dynamic> toJson() => {
    "objectId": objectId,
    "sNo": sNo,
    "name": name,
    "status": status,
  };
}

class LiveMessage {
  String cC;
  dynamic cM;
  String cD;
  String cT;
  String mC;

  LiveMessage({
    required this.cC,
    required this.cM,
    required this.cD,
    required this.cT,
    required this.mC,
  });

  factory LiveMessage.fromJson(Map<String, dynamic> json) {
    return LiveMessage(
      cC: json['cC'],
      cM: json['cM'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['cM'])
          : (json['cM'] is List ? json['mC'] == 'LD01' ? PumpControllerData.fromJson(json, "cM", 2) : <String, dynamic>{} : <String, dynamic>{}),
      cD: json['cD'],
      cT: json['cT'],
      mC: json['mC'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cC': cC,
      'cM': cM,
      'cD': cD,
      'cT': cT,
      'mC': mC,
    };
  }
}

class NodeListModel{
  int controllerId;
  String deviceId;
  String deviceName;
  int categoryId;
  String categoryName;
  int modelId;
  String modelName;
  int serialNumber;
  int referenceNumber;
  int interfaceTypeId;
  String interface;
  int? extendControllerId;
  int status;
  String communicationCount;
  String lastFeedbackReceivedTime;
  double sVolt;
  double batVolt;
  List<RelayStatus> rlyStatus;
  String relayOutput;
  String latchOutput;
  String analogInput;
  String digitalInput;




  NodeListModel({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.categoryId,
    required this.categoryName,
    required this.modelId,
    required this.modelName,
    required this.serialNumber,
    required this.referenceNumber,
    required this.interfaceTypeId,
    required this.interface,
    required this.extendControllerId,
    this.status = 0,
    this.communicationCount = '0,0',
    this.lastFeedbackReceivedTime = '',
    this.sVolt = 0.0,
    this.batVolt = 0.0,
    required this.rlyStatus,
    required this.relayOutput,
    required this.latchOutput,
    required this.analogInput,
    required this.digitalInput,

  });

  factory NodeListModel.fromJson(Map<String, dynamic> json, List<ConfigObject> configObjects) {

    List<ConfigObject> filteredConfigObjects =
    configObjects.where((config) => config.controllerId == json['controllerId']).toList();
    List<RelayStatus> rlyStatus = filteredConfigObjects.map((config) => RelayStatus.fromJson(config.toJson())).toList();

    return NodeListModel(
      controllerId: json['controllerId'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      modelId: json['modelId'],
      modelName: json['modelName'],
      serialNumber: json['serialNumber'],
      referenceNumber: json['referenceNumber'],
      interfaceTypeId: json['interfaceTypeId'] ?? 0,
      interface: json['interface'] ?? '',
      extendControllerId: json['extendControllerId'] ?? 0,
      rlyStatus: rlyStatus,
      relayOutput: json['relayOutput'] ?? '',
      latchOutput: json['latchOutput'] ?? '',
      analogInput: json['analogInput'] ?? '',
      digitalInput: json['digitalInput'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'controllerId': controllerId,
      'DeviceId': deviceId,
      'deviceName': deviceName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'modelId': modelId,
      'modelName': modelName,
      'serialNumber': serialNumber,
      'referenceNumber': referenceNumber,
      'InterfaceType': interfaceTypeId,
      'interface': interface,
      'Status': status,
      'relayOutput': relayOutput,
      'latchOutput': latchOutput,
      'analogInput': analogInput,
      'digitalInput': digitalInput,
    };
  }
}

class ProgramList {
  final int serialNumber;
  final String programName;
  final String defaultProgramName;
  final String programType;
  final List<Sequence> sequence;
  final String selectedSchedule;

  String startDate;
  String endDate;
  String startTime;
  String prgOnOff;
  final String prgCategory;
  int programStatusPercentage;
  final int schedulingMethod;
  int startStopReason;
  int pauseResumeReason;
  String prgPauseResume;
  int status;


  ProgramList({
    required this.serialNumber,
    required this.programName,
    required this.defaultProgramName,
    required this.programType,
    required this.sequence,
    required this.selectedSchedule,

    this.startDate ="-",
    this.endDate ="-",
    this.startTime ="-",
    this.prgOnOff ="0",
    this.prgCategory ="0",
    this.programStatusPercentage = 0,
    this.schedulingMethod = 0,
    this.startStopReason = 0,
    this.pauseResumeReason = 0,
    this.prgPauseResume = '0',
    this.status = 0,
  });

  // Factory method to create an instance from JSON
  factory ProgramList.fromJson(Map<String, dynamic> json) {
    return ProgramList(
      serialNumber: json['serialNumber'],
      programName: json['programName'] ?? '',
      defaultProgramName: json['defaultProgramName'] ?? '',
      programType: json['programType'] ?? '',
      sequence: (json['sequence'] as List<dynamic>)
          .map((e) => Sequence.fromJson(e))
          .toList(),
      selectedSchedule: json['selectedSchedule'] ?? '',
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'serialNumber': serialNumber,
      'programName': programName,
      'defaultProgramName': defaultProgramName,
      'programType': programType,
      'sequence': sequence.map((e) => e.toJson()).toList(),
      'selectedSchedule': selectedSchedule,
    };
  }

  DateTime getDateTime() {
    if (startDate == "-" || startTime == "-") {
      return DateTime(9999);
    }
    return DateTime.parse('$startDate $startTime');
  }
}

class Sequence {
  final String sNo;
  final String name;

  Sequence({
    required this.sNo,
    required this.name,
  });

  factory Sequence.fromJson(Map<String, dynamic> json) {
    return Sequence(
      sNo: json['sNo'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
    };
  }
}