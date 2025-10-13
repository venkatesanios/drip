
import '../../modules/PumpController/model/pump_controller_data_model.dart';

abstract class FertilizerItem {
  String get name;
  bool get selected;
  set selected(bool value);
}

class SiteModel {
  final List<Group> data;

  SiteModel({
    required this.data,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json, String userType) {
    return SiteModel(
      data: List<Group>.from(json['data'].map((x) => Group.fromJson(x, userType))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}

class Group {
  final int customerId;
  final int groupId;
  final String groupName, customerName;
  final List<MasterControllerModel> master;


  Group({required this.customerId, required this.customerName, required this.groupId,
    required this.groupName, required this.master});

  factory Group.fromJson(Map<String, dynamic> json, String userType) {
    return Group(
      customerId: json['customerId'],
      customerName:  json['customerName'],
      groupId: userType == 'customer'? json['userGroupId'] : json['customerId'],
      groupName: userType == 'customer'? json['groupName'] : json['customerName'],
      master: List<MasterControllerModel>.from(json['master'].map((x) => MasterControllerModel.fromJson(x, userType == 'customer'? false : true))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userGroupId': groupId,
      'groupName': groupName,
    };
  }
}

class MasterControllerModel {
  final int controllerId;
  final String deviceId;
  final String deviceName;
  final int categoryId;
  final String categoryName;
  final int modelId;
  final String modelName;
  final String modelDescription;
  final String interfaceTypeId;
  final String interface;
  final String relayOutput;
  final String latchOutput;
  final String analogInput;
  final String digitalInput;

  int? communicationMode;
  List<ConfigObject> configObjects;
  List<NodeListModel> nodeList;
  final List<IrrigationLineModel> irrigationLine;
  List<ProgramList> programList;
  LiveMessage? live;
  final List<Unit> units;
  final List<UserPermission> userPermission;
  List<RelayStatus> ioConnection;
  final bool isSubUser;

  MasterControllerModel({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.categoryId,
    required this.categoryName,
    required this.modelId,
    required this.modelName,
    required this.modelDescription,

    required this.interfaceTypeId,
    required this.interface,
    required this.relayOutput,
    required this.latchOutput,
    required this.analogInput,
    required this.digitalInput,
    required this.communicationMode,
    required this.units,
    required this.userPermission,
    required this.irrigationLine,
    required this.nodeList,
    required this.programList,
    required this.live,
    required this.configObjects,
    required this.ioConnection,
    required this.isSubUser,

  });

  factory MasterControllerModel.fromJson(Map<String, dynamic> json, bool isSubUser) {

    final config = json['config'] ?? json;

    final configObjectsRaw = (config['configObject'] as List?) ?? [];
    final irrigationLinesRaw = (config['irrigationLine'] as List?) ?? [];

    if(irrigationLinesRaw.isNotEmpty && irrigationLinesRaw.length>1){
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
        "moistureSensor": [],
        "temperature": [],
        "soilTemperature": [],
        "humidity": [],
        "co2": []
      };
      irrigationLinesRaw.insert(0, allLine);
    }

    final waterSourcesRaw = config['waterSource'] as List? ?? [];
    final filterSiteRaw = config['filterSite'] as List? ?? [];
    final fertilizerSiteRaw = config['fertilizerSite'] as List? ?? [];
    final moistureSensorRaw = config['moistureSensor'] as List? ?? [];

    List<ConfigObject> configObjectsR = json["config"] != null &&
        json["config"] is Map<String, dynamic> &&
        json["config"]['configObject'] != null
        ? (json["config"]['configObject'] as List)
        .map((item) => ConfigObject.fromJson(item))
        .toList()
        : [];

    List<ConfigObject> configObjects = configObjectsRaw
        .map((item) => ConfigObject.fromJson(item))
        .toList();

    List<WaterSourceModel> waterSources = waterSourcesRaw
        .map((item) => WaterSourceModel.fromJson(item, configObjects))
        .toList();
    WaterSourceModel.assignFloatSwitchesToWaterSources(waterSources, config, configObjects);

    List<FilterSiteModel> filterSites =
    filterSiteRaw.map((item) => FilterSiteModel.fromJson(item, configObjects)).toList();
    final filterSiteMap = {
      for (var site in filterSites) site.sNo: site,
    };

    List<FertilizerSiteModel> fertilizerSites =
    fertilizerSiteRaw.map((item) => FertilizerSiteModel.fromJson(item, configObjects)).toList();
    final fertilizerSiteMap = {
      for (var site in fertilizerSites) site.sNo: site,
    };

    List<IrrigationLineModel> irrigationLines = irrigationLinesRaw
        .map((item) => IrrigationLineModel.fromJson(item, configObjects, moistureSensorRaw, waterSources))
        .toList();

    for (var line in irrigationLines) {
      final matchedFilterSite = filterSiteMap[line.centralFiltration];
      final matchedFertilizerSite = fertilizerSiteMap[line.centralFertilization];
      line.linkReferences(matchedFilterSite, matchedFertilizerSite);
    }

    List<ConfigObject> filteredConfigObjects =
    configObjects.where((config) => config.controllerId == json['controllerId']).toList();
    List<RelayStatus> ioConnection = filteredConfigObjects.map((config) => RelayStatus.fromJson(config.toJson())).toList();

    return MasterControllerModel(
      controllerId: json['controllerId'] ?? 0,
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      modelId: json['modelId'] ?? 0,
      modelName: json['modelName'] ?? '',
      modelDescription: json['modelDescription'] ?? '',
      interfaceTypeId: json['interfaceTypeId'] ?? '',
      interface: json['interface'] ?? '',
      relayOutput: json['relayOutput'] ?? '',
      latchOutput: json['latchOutput'] ?? '',
      analogInput: json['analogInput'] ?? '',
      digitalInput: json['digitalInput'] ?? '',
      communicationMode: json['communicationMode'] ?? 1,
      configObjects: configObjectsR,
      units: json['units'] != null ? List<Unit>.from(json['units'].map((x) => Unit.fromJson(x)))
          : [],
      userPermission: (json.containsKey('userPermission') && json['userPermission'] is List)
          ? (json['userPermission'] as List)
          .map((e) => UserPermission.fromJson(e))
          .toList()
          : [],
      live: json['liveMessage'] != null ? LiveMessage.fromJson(json['liveMessage']) : null,
      irrigationLine: irrigationLines,
      nodeList: json['nodeList'] != null ? (json['nodeList'] as List)
          .map((item) => NodeListModel.fromJson(item, configObjects)).toList()
          : [],
      programList: json['program'] != null ? (json['program'] as List)
          .map((prgList) => ProgramList.fromJson(prgList))
          .toList()
          : [],

      ioConnection: ioConnection,
      isSubUser: isSubUser,

    );
  }

}

class WaterSourceModel {
  final double sNo;
  final String name;
  final int sourceType;

  final List<double> inletPumpSno;
  final List<double> outletPumpSno;

  final List<PumpModel> inletPump;
  final List<PumpModel> outletPump;

  final bool isWaterInAndOut;
  final List<SensorModel> level;

  final List<SensorModel> floatSwitches;

  WaterSourceModel({
    required this.sNo,
    required this.name,
    required this.sourceType,

    required this.inletPumpSno,
    required this.outletPumpSno,

    required this.inletPump,
    required this.outletPump,
    required this.isWaterInAndOut,
    required this.level,

    required this.floatSwitches,
  });

  factory WaterSourceModel.fromJson(Map<String, dynamic> json, List<ConfigObject> configObjects) {

    final inletPumps = ((json['inletPump'] as List?) ?? []).map((e) => e).toSet();
    final iPumps = configObjects.where((obj) => inletPumps.contains(obj.sNo))
        .map(PumpModel.fromConfigObject)
        .toList();

    final outletPumps = ((json['outletPump'] as List?) ?? []).map((e) => e).toSet();
    final oPumps = configObjects.where((obj) => outletPumps.contains(obj.sNo))
        .map(PumpModel.fromConfigObject)
        .toList();

    final levelSNoSet = (json['level'] is List)
        ? (json['level'] as List).map((e) => (e as num).toDouble()).toSet()
        : (json['level'] is num)
        ? {(json['level'] as num).toDouble()}
        : <double>{};

    final levelSensor = configObjects
        .where((obj) => levelSNoSet.contains(obj.sNo))
        .map(SensorModel.fromConfigObject)
        .toList();

    final sourceCount = configObjects
        .where((obj) => obj.objectId == 1)
        .length;


    return WaterSourceModel(
      sNo: json['sNo']?.toDouble() ?? 0,
      name: json['name'],
      sourceType: json['sourceType'],
      inletPump: iPumps,
      outletPump: oPumps,
      isWaterInAndOut: ((json['inletPump'] as List).isNotEmpty || sourceCount == 1),
      inletPumpSno: List<double>.from(json['inletPump'].map((e) => e.toDouble())),
      outletPumpSno: List<double>.from(json['outletPump'].map((e) => e.toDouble())),
      level: levelSensor,
      floatSwitches: [],
    );
  }

  static void assignFloatSwitchesToWaterSources(
      List<WaterSourceModel> waterSources,
      Map<String, dynamic> config,
      List<ConfigObject> configObjects,
      ) {
    final floatObjects = configObjects
        .where((obj) => obj.objectName == 'Float')
        .toList();

    final waterSourcesRaw = config['waterSource'] as List? ?? [];

    for (final wsJson in waterSourcesRaw) {
      final wsSno = (wsJson['sNo'] as num?)?.toDouble();
      if (wsSno == null) continue;

      final source = waterSources.where((ws) => ws.sNo == wsSno).firstOrNull;
      if (source == null) continue;

      final floatFields = [
        'topFloatForInletPump',
        'bottomFloatForInletPump',
        'topFloatForOutletPump',
        'bottomFloatForOutletPump',
      ];

      final List<SensorModel> assignedFloats = [];

      for (final field in floatFields) {
        final floatSno = wsJson[field];
        if (floatSno != null && floatSno != 0) {
          final match = floatObjects.firstWhere(
                (obj) => obj.sNo == (floatSno as num).toDouble(),
            orElse: () => ConfigObject.empty(),
          );
          if (match.sNo != 0) {
            assignedFloats.add(SensorModel.fromConfigObject(match));
          }
        }
      }

      source.floatSwitches.addAll(assignedFloats);
    }
  }
}

class IrrigationLineModel {
  final double sNo;
  final String name;
  final List<WaterSourceModel> inletSources;
  final List<WaterSourceModel> outletSources;
  final double? centralFiltration;
  final double? centralFertilization;
  FilterSiteModel? centralFilterSite;
  FertilizerSiteModel? centralFertilizerSite;
  final List<ValveModel> valveObjects;
  final List<ValveModel> mainValveObjects;
  final List<LightModel> lightObjects;
  final List<GateModel> gateObjects;
  final List<SensorModel> prsSwitch;
  final List<SensorModel> pressureIn;
  final List<SensorModel> pressureOut;
  final List<SensorModel> waterMeter;
  int? linePauseFlag;

  IrrigationLineModel({
    required this.sNo,
    required this.name,
    required this.inletSources,
    required this.outletSources,
    required this.centralFiltration,
    required this.centralFertilization,
    required this.valveObjects,
    required this.mainValveObjects,
    required this.lightObjects,
    required this.gateObjects,
    required this.prsSwitch,
    required this.pressureIn,
    required this.pressureOut,
    required this.waterMeter,
    this.linePauseFlag = 0,
  });

  factory IrrigationLineModel.fromJson(Map<String, dynamic> json, List<ConfigObject> configObjects, var moistureSensorRaw, List<WaterSourceModel> waterSources) {

    final sourcePumpList = (json['sourcePump'] as List?) ?? [];
    final sourcePumpSet = sourcePumpList.map((e) => (e as num).toDouble()).toSet();
    final matchedInletSources = WaterSourceUtils.getWaterSourcesByOutletPump(
      sourcePumpSet: sourcePumpSet,
      allWaterSources: waterSources,
    );

    final irrPumpList = (json['irrigationPump'] as List?) ?? [];
    final irrPumpSet = irrPumpList.map((e) => (e as num).toDouble()).toSet();
    final matchedOutLetSources = WaterSourceUtils.getWaterSourcesByOutletPump(
      sourcePumpSet: irrPumpSet,
      allWaterSources: waterSources,
    );

    final gateSNoSet = ((json['gate'] as List?) ?? []).map((e) => e).toSet();
    final gates = configObjects
        .where((obj) => gateSNoSet.contains(obj.sNo))
        .map((obj) => GateModel.fromConfigObject(obj))
        .toList();

    final lightSNoSet = ((json['light'] as List?) ?? []).map((e) => e).toSet();
    final lights = configObjects
        .where((obj) => lightSNoSet.contains(obj.sNo))
        .map((obj) => LightModel.fromConfigObject(obj))
        .toList();

    /*if([56, 57, 58, 59].contains(master.modelId)){

    }*/


    final valveSNoSet = ((json['valve'] as List?) ?? []).map((e) => e).toSet();

    /*final valveSNoSet = ((json['valve'] as List?) ?? []).map((e) {
      if (e is num) { return e.toStringAsFixed(3); }
      return e.toString();
    }).toSet();*/


    final valves = configObjects
        .where((obj) => valveSNoSet.contains(obj.sNo))
        .map((obj) => ValveModel.fromConfigObject(obj, waterSources))
        .toList();


    final mainValveSNoSet = ((json['mainValve'] as List?) ?? []).map((e) => e).toSet();
    final mainValves = configObjects
        .where((obj) => mainValveSNoSet.contains(obj.sNo))
        .map((obj) => ValveModel.fromConfigObject(obj, waterSources))
        .toList();

    final Map<double, List<MoistureSensorModel>> valveToMoistureSensors = {};

    for (var sensor in moistureSensorRaw) {
      final sensorSNo = (sensor['sNo'] as num).toDouble();
      final sensorName = sensor['name'] as String;
      final sensorValves = sensor['valves'] as List;

      for (var valve in sensorValves) {
        final valveSNo = (valve as num).toDouble();
        valveToMoistureSensors
            .putIfAbsent(valveSNo, () => [])
            .add(MoistureSensorModel(sNo: sensorSNo, name: sensorName));
      }
    }

    for (var valve in valves) {
      valve.moistureSensors = valveToMoistureSensors[valve.sNo] ?? [];
    }

    final pressureSwitchSNoList = (json['pressureSwitch'] is List)
        ? (json['pressureSwitch'] as List).map((e) => (e as num).toDouble()).toSet()
        : (json['pressureSwitch'] is num)
        ? {(json['pressureSwitch'] as num).toDouble()}
        : <double>{};

    final pressureSwitch = configObjects
        .where((obj) => pressureSwitchSNoList.contains(obj.sNo))
        .map(SensorModel.fromConfigObject)
        .toList();

    final prsInSNoSet = (json['pressureIn'] is List)
        ? (json['pressureIn'] as List).map((e) => (e as num).toDouble()).toSet()
        : (json['pressureIn'] is num)
        ? {(json['pressureIn'] as num).toDouble()}
        : <double>{};

    final pressureIn = configObjects
        .where((obj) => prsInSNoSet.contains(obj.sNo))
        .map(SensorModel.fromConfigObject)
        .toList();

    final prsOutSNoSet = (json['pressureOut'] is List)
        ? (json['pressureOut'] as List).map((e) => (e as num).toDouble()).toSet()
        : (json['pressureOut'] is num)
        ? {(json['pressureOut'] as num).toDouble()}
        : <double>{};

    final pressureOut = configObjects
        .where((obj) => prsOutSNoSet.contains(obj.sNo))
        .map(SensorModel.fromConfigObject)
        .toList();

    final waterMeterSNoSet = (json['waterMeter'] is List)
        ? (json['waterMeter'] as List).map((e) => (e as num).toDouble()).toSet()
        : (json['waterMeter'] is num)
        ? {(json['waterMeter'] as num).toDouble()}
        : <double>{};

    final waterMeter = configObjects
        .where((obj) => waterMeterSNoSet.contains(obj.sNo))
        .map(SensorModel.fromConfigObject)
        .toList();

    return IrrigationLineModel(
      sNo: json['sNo']?.toDouble() ?? 0,
      name: json['name'] ?? '',
      centralFiltration: (json['centralFiltration'] as num?)?.toDouble(),
      centralFertilization: (json['centralFertilization'] as num?)?.toDouble(),
      inletSources: matchedInletSources,
      outletSources: matchedOutLetSources,
      valveObjects: valves,
      mainValveObjects: mainValves,
      lightObjects: lights,
      gateObjects: gates,
      prsSwitch: pressureSwitch,
      pressureIn: pressureIn,
      pressureOut: pressureOut,
      waterMeter: waterMeter,
    );
  }

  void linkReferences(FilterSiteModel? cFilterSite,
      FertilizerSiteModel? cFertilizerSite) {
    centralFilterSite = cFilterSite;
    centralFertilizerSite = cFertilizerSite;
  }

}

class RelayStatus {
  final double? sNo;
  final String? name;
  String? swName;
  final int? rlyNo;
  final String? objType;
  int status;

  RelayStatus({
    required this.sNo,
    required this.name,
    required this.swName,
    required this.rlyNo,
    required this.objType,
    this.status=0,
  });

  factory RelayStatus.fromJson(Map<String, dynamic> json) {
    return RelayStatus(
      sNo: json['sNo'],
      name: json['name'],
      swName: json['name'] ?? json['objectName'],
      rlyNo: json['connectionNo'],
      objType: json['objectType'],
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
  final String objectName;
  final String objectType;
  final int connectionNo;
  final int? controllerId;
  final double? location;
  final List<double> assignObject;
  int status;
  bool selected;
  String onDelayLeft;
  String voltage;
  String current;
  String reason;
  String setValue;
  String actualValue;
  String phase;

  ConfigObject({
    required this.objectId,
    required this.sNo,
    required this.name,
    required this.objectName,
    required this.objectType,
    required this.connectionNo,
    this.controllerId,
    required this.location,
    required this.assignObject,
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

  factory ConfigObject.fromJson(Map<String, dynamic> json) {

    List<double> parsedAssignObject = [];

    if (json.containsKey("assignObject") && json["assignObject"] != null) {
      parsedAssignObject = (json["assignObject"] as List)
          .map((e) => (e as num).toDouble())
          .toList();
    }

    return ConfigObject(
      objectId: json['objectId'],
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'],
      objectName: json['objectName'],
      objectType: json['type'],
      controllerId: json['controllerId'],
      connectionNo: json['connectionNo'] ?? 0,
      location: (json['location'] is! double ? 0.0 : json['location']) ?? 0.0,
      assignObject: parsedAssignObject,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectId': objectId,
      'sNo': sNo,
      'name': name,
      'objectName': objectName,
      'objectType': objectType,
      'controllerId': controllerId,
      'connectionNo': connectionNo,
      'location': location,
    };
  }

  factory ConfigObject.empty() => ConfigObject(
    objectId: 0,
    sNo: 0,
    name: '',
    objectName: '',
    connectionNo: 0,
    assignObject: [],
    location: 0.0,
    objectType: '',
  );

}

class PumpModel {
  final double sNo;
  final String name;
  int status;
  bool selected;
  String onDelayLeft;
  String voltage;
  String current;
  String reason;
  String setValue;
  String actualValue;
  String phase;

  PumpModel({
    required this.sNo,
    required this.name,
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

  factory PumpModel.fromConfigObject(ConfigObject obj) {
    return PumpModel(
      sNo: obj.sNo,
      name: obj.name,
    );
  }

}

class FilterSiteModel {
  final double sNo;
  final String name;
  final int? controllerId;

  final List<Filters> filters;
  final PressureSensor? pressureIn;
  final PressureSensor? pressureOut;

  FilterSiteModel({
    required this.sNo,
    required this.name,
    this.controllerId,
    required this.filters,
    required this.pressureIn,
    required this.pressureOut,
  });

  factory FilterSiteModel.fromJson(Map<String, dynamic> json, List<ConfigObject> configObjects) {

    /*final filterSNoSet = ((json['filters'] as List?) ?? [])
        .map((e) => e.toStringAsFixed(3))
        .toSet();*/

    final filterSNoSet = ((json['filters'] as List?) ?? [])
        .map((e) {
      if (e is Map) {
        // Object case: extract sNo
        return (e['sNo'] as num).toStringAsFixed(3);
      } else if (e is num) {
        // Number case: directly format
        return e.toStringAsFixed(3);
      }
      return null;
    }).where((e) => e != null).toSet();

    final filters = configObjects
        .where((obj) => filterSNoSet.contains(obj.sNo.toStringAsFixed(3)))
        .map(Filters.fromConfigObject)
        .toList();

    final pressureInSNo = (json['pressureIn'] ?? 0) as num;
    PressureSensor? pressureIn;
    try {
      if (pressureInSNo != 0) {
        final match = configObjects.firstWhere((obj) => obj.sNo == pressureInSNo);
        pressureIn = PressureSensor.fromConfigObject(match);
      }
    } catch (_) {
      pressureIn = null;
    }

    final pressureOutSNo = (json['pressureOut'] ?? 0) as num;
    PressureSensor? pressureOut;
    try {
      if (pressureOutSNo != 0) {
        final match = configObjects.firstWhere((obj) => obj.sNo == pressureOutSNo);
        pressureOut = PressureSensor.fromConfigObject(match);
      }
    } catch (_) {
      pressureOut = null;
    }


    return FilterSiteModel(
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'],
      controllerId: json['controllerId'],
      filters: filters,
      pressureIn: pressureIn,
      pressureOut: pressureOut,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
      'controllerId': controllerId,
      'filters': filters,
      'pressureIn': pressureIn,
      'pressureOut': pressureOut,
    };
  }

  List<double> parseFilters(dynamic json) {
    final rawFilters = json['filters'];

    if (rawFilters is List) {
      return rawFilters.map((item) {
        if (item is Map<String, dynamic>) {
          // Case: object with sNo key
          return (item['sNo'] as num).toDouble();
        } else if (item is num) {
          // Case: plain number
          return item.toDouble();
        } else {
          throw FormatException('Unexpected filter format: $item');
        }
      }).toList();
    } else {
      throw FormatException('filters is not a list');
    }
  }

}

class PressureSensor {
  final double sNo;
  final String name;
  String value;

  PressureSensor({
    required this.sNo,
    required this.name,
    this.value='0',
  });

  factory PressureSensor.fromJson(Map<String, dynamic> json) {
    return PressureSensor(
      sNo: (json['sNo'] as num?)?.toDouble() ?? 0.0,
      name: json['name'] ?? '',
    );
  }

  factory PressureSensor.fromConfigObject(ConfigObject obj) {
    return PressureSensor(
      sNo: obj.sNo,
      name: obj.name,
    );
  }

  Map<String, dynamic> toJson() => {
    "sNo": sNo,
    "name": name,
  };
}

class Filters {
  double sNo;
  String name;
  int status;
  bool selected;
  String onDelayLeft;

  Filters({
    required this.sNo,
    required this.name,
    this.status = 0,
    this.selected=false,
    this.onDelayLeft='00:00:00',
  });

  factory Filters.fromConfigObject(ConfigObject obj) {
    return Filters(
      sNo: obj.sNo,
      name: obj.name,
    );
  }

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      sNo: json['sNo'],
      name: json['name'],
    );
  }
}

class FertilizerSiteModel {
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
  final List<CheSelector> selector;

  List<Ec>? ec;
  List<Ph>? ph;

  FertilizerSiteModel({
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

  factory FertilizerSiteModel.fromJson(Map<String, dynamic> json, List<ConfigObject> configObjects) {

    final channelSNoSet = ((json['channel'] as List?) ?? [])
        .map((e) => (e['sNo'] as num).toStringAsFixed(3))
        .toSet();

    final channel = configObjects
        .where((obj) => channelSNoSet.contains(obj.sNo.toStringAsFixed(3)))
        .map(Channel.fromConfigObject)
        .toList();

    final boosterPumpSNo = ((json['boosterPump'] as List?)?.first ?? 0) as num;

    final boosterPump = configObjects
        .where((obj) => boosterPumpSNo == obj.sNo)
        .map(BoosterPump.fromConfigObject)
        .toList();

    final selectorSNos = ((json['selector'] as List?) ?? []).map((e) => e).toSet();


    final cheSelector = configObjects
        .where((obj) => selectorSNos.contains(obj.sNo))
        .map((obj) => CheSelector.fromConfigObject(obj))
        .toList();


    final agitatorList = json['agitator'] as List?;
    final agitatorSNo = (agitatorList != null && agitatorList.isNotEmpty)
        ? agitatorList.first as num
        : 0;
    final agitator = configObjects
        .where((obj) => agitatorSNo == obj.sNo)
        .map(Agitator.fromConfigObject)
        .toList();

    final ecSNoSet = ((json['ec'] as List?) ?? []).map((e) => e).toSet();
    final ecSensor = configObjects.where((obj) => ecSNoSet.contains(obj.sNo))
        .map(Ec.fromConfigObject).toList();

    final phSNoSet = ((json['ph'] as List?) ?? []).map((e) => e).toSet();
    final phSensor = configObjects.where((obj) => phSNoSet.contains(obj.sNo))
        .map(Ph.fromConfigObject).toList();

    return FertilizerSiteModel(
      objectId: json['objectId'],
      sNo: json['sNo'].toDouble(),
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
      siteMode: json['siteMode'],
      channel: channel,
      boosterPump: boosterPump,
      agitator: agitator,
      selector: cheSelector,
      ec: ecSensor,
      ph: phSensor,
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

class Channel implements FertilizerItem {
  final double sNo;
  @override
  final String name;
  @override
  bool selected;

  int status;
  String frtMethod;
  String duration;
  String completedDrQ;
  String flowRateLpH;
  String onTime;
  String offTime;

  Channel({
    required this.sNo,
    required this.name,
    this.status = 0,
    this.selected = false,
    this.frtMethod = '0',
    this.duration = '00:00:00',
    this.completedDrQ = '00:00:00',
    this.flowRateLpH = '-',
    this.onTime = '0',
    this.offTime = '0',
  });

  factory Channel.fromConfigObject(ConfigObject obj) {
    return Channel(
      sNo: obj.sNo,
      name: obj.name,
    );
  }

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'] ?? '',
      status: json['status'] ?? 0,
      selected: json['selected'] ?? false,
      frtMethod: json['frtMethod'] ?? '0',
      duration: json['duration'] ?? '00:00:00',
      completedDrQ: json['completedDrQ'] ?? '00:00:00',
      flowRateLpH: json['flowRateLpH'] ?? '-',
      onTime: json['onTime'] ?? '0',
      offTime: json['offTime'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
      'status': status,
      'selected': selected,
      'frtMethod': frtMethod,
      'duration': duration,
      'completedDrQ': completedDrQ,
      'flowRateLpH': flowRateLpH,
      'onTime': onTime,
      'offTime': offTime,
    };
  }
}

class Ec {
  final double sNo;
  final String name;
  String value;

  Ec({
    required this.sNo,
    required this.name,
    this.value = '0',
  });

  factory Ec.fromConfigObject(ConfigObject obj) {
    return Ec(
      sNo: obj.sNo,
      name: obj.name,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
    };
  }

}

class Ph {
  final double sNo;
  final String name;
  String value;

  Ph({
    required this.sNo,
    required this.name,
    this.value = '0',
  });

  factory Ph.fromConfigObject(ConfigObject obj) {
    return Ph(
      sNo: obj.sNo,
      name: obj.name,
    );
  }

  factory Ph.fromJson(Map<String, dynamic> json) {
    return Ph(
      sNo: json['sNo'].toDouble(),
      name: json['name'],);
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
    };
  }

}

class CheSelector implements FertilizerItem {
  final double sNo;
  @override
  final String name;
  @override
  bool selected;
  int status;

  CheSelector({
    required this.sNo,
    required this.name,
    this.selected = false,
    this.status = 0,
  });

  factory CheSelector.fromConfigObject(ConfigObject obj) {
    return CheSelector(
      sNo: obj.sNo,
      name: obj.name,
    );
  }

  factory CheSelector.fromJson(Map<String, dynamic> json) {
    return CheSelector(
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'] ?? '',
      selected: json['selected'] ?? false,
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
      'selected': selected,
      'status': status,
    };
  }
}

class BoosterPump implements FertilizerItem {
  final double sNo;
  @override
  final String name;
  @override
  bool selected;
  int status;

  BoosterPump({
    required this.sNo,
    required this.name,
    this.selected = false,
    this.status = 0,
  });

  factory BoosterPump.fromConfigObject(ConfigObject obj) {
    return BoosterPump(
      sNo: obj.sNo,
      name: obj.name,
    );
  }

  factory BoosterPump.fromJson(Map<String, dynamic> json) {
    return BoosterPump(
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'] ?? '',
      selected: json['selected'] ?? false,
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
      'selected': selected,
      'status': status,
    };
  }
}

class Agitator implements FertilizerItem {
  final double sNo;
  @override
  final String name;
  @override
  bool selected;
  int status;

  Agitator({
    required this.sNo,
    required this.name,
    this.selected = false,
    this.status = 0,
  });

  factory Agitator.fromConfigObject(ConfigObject obj) {
    return Agitator(
      sNo: obj.sNo,
      name: obj.name,
    );
  }

  factory Agitator.fromJson(Map<String, dynamic> json) {
    return Agitator(
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'] ?? '',
      selected: json['selected'] ?? false,
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
      'selected': selected,
      'status': status,
    };
  }
}

class MoistureSensorModel {
  final double sNo;
  final String name;
  String value;

  MoistureSensorModel({
    required this.sNo,
    required this.name,
    this.value = '0',
  });

  factory MoistureSensorModel.fromJson(Map<String, dynamic> json) {
    return MoistureSensorModel(
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
    };
  }
}

class SensorModel {
  final double sNo;
  final String name;
  int status;
  String value;

  SensorModel({
    required this.sNo,
    required this.name,
    this.status = 0,
    this.value = '0',
  });

  factory SensorModel.fromConfigObject(ConfigObject obj) {
    return SensorModel(
      sNo: obj.sNo,
      name: obj.name,
    );
  }

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      sNo: json['sNo'].toDouble(),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
      "status": status,
      "value": value,
    };
  }
}

class ValveModel {
  final double sNo;
  final String name;
  final List<WaterSourceModel> waterSources;
  int status;
  bool isOn;
  List<MoistureSensorModel> moistureSensors = [];

  ValveModel({
    required this.sNo,
    required this.name,
    required this.waterSources,
    this.status = 0,
    this.isOn = false,
  });

  factory ValveModel.fromConfigObject(ConfigObject obj, List<WaterSourceModel> ws) {

    List<double> assignedSNos = (obj.assignObject ?? [])
        .map((e) => (e as num).toDouble())
        .toList();

    List<WaterSourceModel> sources = [];

    if (assignedSNos.isNotEmpty) {
      for (var val in assignedSNos) {
        int integerPart = val.floor();
        if (integerPart == 1) {
          sources = ws.where((source) => assignedSNos.contains(source.sNo))
              .toList();
          break;
        }
      }
    }

    /*List<WaterSourceModel> sources = configObjects
        .where((source) => assignedSNos.contains(source.sNo))
        .toList();*/


    return ValveModel(
      sNo: obj.sNo,
      name: obj.name,
      waterSources: sources,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
      "status": status,
    };
  }
}

class LightModel {
  final double sNo;
  final String name;
  int status;

  LightModel({
    required this.sNo,
    required this.name,
    this.status = 0,
  });

  factory LightModel.fromConfigObject(ConfigObject obj) {
    return LightModel(
      sNo: obj.sNo,
      name: obj.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
      "status": status,
    };
  }
}

class GateModel {
  final double sNo;
  final String name;
  int status;

  GateModel({
    required this.sNo,
    required this.name,
    this.status = 0,
  });

  factory GateModel.fromConfigObject(ConfigObject obj) {
    return GateModel(
      sNo: obj.sNo,
      name: obj.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
      "status": status,
    };
  }
}

class ValveSA {
  final double sNo;
  final String name;

  ValveSA({
    required this.sNo,
    required this.name,
  });

  factory ValveSA.fromJson(Map<String, dynamic> json) {
    return ValveSA(
      sNo: (json['sNo'] as num).toDouble(),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
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
  String modelDescription;
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
  String version;


  NodeListModel({
    required this.controllerId,
    required this.deviceId,
    required this.deviceName,
    required this.categoryId,
    required this.categoryName,
    required this.modelId,
    required this.modelName,
    required this.modelDescription,
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
    this.version = '0.0.0',

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
      modelDescription: json['modelDescription'],
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
      'deviceId': deviceId,
      'deviceName': deviceName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'modelId': modelId,
      'modelName': modelName,
      'modelDescription': modelDescription,
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
  final List<dynamic> irrigationLine;
  final List<ConditionModel> conditions;

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
    required this.irrigationLine,
    required this.conditions,

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

    List<dynamic> jsonList = json['condition'];
    List<ConditionModel> conditions = jsonList
        .map((item) => ConditionModel.fromJson(item))
        .toList();

    return ProgramList(
      serialNumber: json['serialNumber'],
      programName: json['programName'] ?? '',
      defaultProgramName: json['defaultProgramName'] ?? '',
      programType: json['programType'] ?? '',
      sequence: (json['sequence'] as List<dynamic>)
          .map((e) => Sequence.fromJson(e))
          .toList(),
      selectedSchedule: json['selectedSchedule'] ?? '',
      irrigationLine: json['irrigationLine'] ?? [],
      conditions: conditions,
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
      'irrigationLine': irrigationLine,
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

class ConditionModel {
  final int sNo;
  final String title;
  final ConditionValue value;
  final bool selected;

  int conditionStatus;

  ConditionModel({
    required this.sNo,
    required this.title,
    required this.value,
    required this.selected,
    this.conditionStatus = 0,
  });

  factory ConditionModel.fromJson(Map<String, dynamic> json) {
    return ConditionModel(
      sNo: json['sNo'],
      title: json['title'],
      value: ConditionValue.fromJson(json['value']),
      selected: json['selected'] ?? false,
      conditionStatus: json['conditionStatus'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'title': title,
      'value': value.toJson(),
      'selected': selected,
      'conditionStatus': conditionStatus,
    };
  }
}

class ConditionValue {
  final int sNo;
  final String name;
  final String rule;
  int conditionStatus;
  String actualValue;

  ConditionValue({
    required this.sNo,
    required this.name,
    required this.rule,
    this.conditionStatus = 0,
    this.actualValue = "",
  });

  factory ConditionValue.fromJson(Map<String, dynamic> json) {
    return ConditionValue(
      sNo: json['sNo'],
      name: json['name'],
      rule: json['rule'],
      conditionStatus: json['conditionStatus'] ?? 0,
      actualValue: json['actualValue'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
      'rule': rule,
      'conditionStatus': conditionStatus,
      'actualValue': actualValue,
    };
  }

  /// ✅ Add this factory to fix the error
  factory ConditionValue.defaultValue() {
    return ConditionValue(
      sNo: 0,
      name: '',
      rule: '',
      conditionStatus: 0,
      actualValue: '',
    );
  }
}

class WaterSourceUtils {

  static List<WaterSourceModel> getWaterSourcesByOutletPump({
    required Set<double> sourcePumpSet,
    required List<WaterSourceModel> allWaterSources,
  }) {
    return allWaterSources.map((source) {
      final matchingOutletPumps = source.outletPump
          .where((pump) => sourcePumpSet.contains(pump.sNo))
          .toList();

      if (matchingOutletPumps.isEmpty) return null;

      return WaterSourceModel(
        sNo: source.sNo,
        name: source.name,
        sourceType: source.sourceType,
        inletPumpSno: [],
        outletPumpSno: [],
        inletPump: [],
        outletPump: matchingOutletPumps,
        isWaterInAndOut: false,
        level: source.level,
        floatSwitches: source.floatSwitches,
      );
    }).whereType<WaterSourceModel>().toList();
  }

}

class UserPermission {
  final int sNo;
  final String name;
  final bool status;

  UserPermission({
    required this.sNo,
    required this.name,
    required this.status,
  });

  factory UserPermission.fromJson(Map<String, dynamic> json) {
    return UserPermission(
      sNo: json['sNo'] as int,
      name: json['name'] as String,
      status: json['status'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'name': name,
      'status': status,
    };
  }
}