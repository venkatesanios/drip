import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:oro_drip_irrigation/modules/config_Maker/view/product_limit.dart';
import 'package:oro_drip_irrigation/modules/config_Maker/view/site_configure.dart';
import 'package:oro_drip_irrigation/Widgets/sized_image.dart';
import 'package:oro_drip_irrigation/utils/environment.dart';
import 'package:provider/provider.dart';
import '../../../Constants/properties.dart';
import '../model/device_model.dart';
import '../model/device_object_model.dart';
import '../model/fertigation_model.dart';
import '../model/filtration_model.dart';
import '../model/irrigationLine_model.dart';
import '../model/moisture_model.dart';
import '../model/pump_model.dart';
import '../model/source_model.dart';
import '../repository/config_maker_repository.dart';
import '../state_management/config_maker_provider.dart';
import '../../../Widgets/custom_buttons.dart';
import '../../../Widgets/custom_side_tab.dart';
import '../../../Widgets/title_with_back_button.dart';
import '../../../services/http_service.dart';
import '../../../utils/Theme/oro_theme.dart';
import '../../../utils/constants.dart';
import 'config_base_page.dart';
import 'config_mobile_view.dart';
import 'connection.dart';
import 'device_list.dart';
import 'package:oro_drip_irrigation/services/mqtt_manager_mobile.dart' if (dart.library.html) 'package:oro_drip_irrigation/services/mqtt_manager_web.dart';


class ConfigWebView extends StatefulWidget {
  List<DeviceModel> listOfDevices;
  ConfigWebView({super.key, required this.listOfDevices});


  @override
  State<ConfigWebView> createState() => _ConfigWebViewState();
}

class _ConfigWebViewState extends State<ConfigWebView> {
  late ConfigMakerProvider configPvd;
  late Future<List<DeviceModel>> listOfDevices;
  double sideNavigationWidth = 220;
  double sideNavigationBreakPointWidth = 60;
  double sideNavigationTabWidth = 200;
  double sideNavigationTabBreakPointWidth = 50;
  double webBreakPoint = 1000;
  late ThemeData themeData;
  late bool themeMode;
  bool clearOnHover = false;
  bool sendOnHover = false;
  List<Map<String, dynamic>> listOfPayload = [];
  PayloadSendState payloadSendState = PayloadSendState.idle;
  MqttManager mqttManager = MqttManager();
  var data = {
    "isNewConfig": "0",
    "configObject": [
      {
        "objectId": 1,
        "sNo": 1.001,
        "name": "Source 1",
        "connectionNo": null,
        "objectName": "Source",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 1,
        "sNo": 1.002,
        "name": "Source 2",
        "connectionNo": null,
        "objectName": "Source",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 1,
        "sNo": 1.003,
        "name": "Source 3",
        "connectionNo": null,
        "objectName": "Source",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 1,
        "sNo": 1.004,
        "name": "Source 4",
        "connectionNo": null,
        "objectName": "Source",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 2,
        "sNo": 2.001,
        "name": "Irrigation Line 1",
        "connectionNo": null,
        "objectName": "Irrigation Line",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 2,
        "sNo": 2.002,
        "name": "Irrigation Line 2",
        "connectionNo": null,
        "objectName": "Irrigation Line",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 3,
        "sNo": 3.001,
        "name": "Fertilization Site 1",
        "connectionNo": null,
        "objectName": "Fertilization Site",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 4,
        "sNo": 4.001,
        "name": "Filtration Site 1",
        "connectionNo": null,
        "objectName": "Filtration Site",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 5,
        "sNo": 5.001,
        "name": "Pump 1",
        "connectionNo": 1,
        "objectName": "Pump",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 5,
        "sNo": 5.002,
        "name": "Pump 2",
        "connectionNo": 2,
        "objectName": "Pump",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 5,
        "sNo": 5.003,
        "name": "Pump 3",
        "connectionNo": 3,
        "objectName": "Pump",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 5,
        "sNo": 5.004,
        "name": "Pump 4",
        "connectionNo": 1,
        "objectName": "Pump",
        "type": "1,2",
        "controllerId": 6,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 5,
        "sNo": 5.005,
        "name": "Pump 5",
        "connectionNo": 2,
        "objectName": "Pump",
        "type": "1,2",
        "controllerId": 6,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 7,
        "sNo": 7.001,
        "name": "Booster Pump 1",
        "connectionNo": 4,
        "objectName": "Booster Pump",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 9,
        "sNo": 9.001,
        "name": "Agitator 1",
        "connectionNo": 6,
        "objectName": "Agitator",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 8,
        "sNo": 8.001,
        "name": "Selector 1",
        "connectionNo": 5,
        "objectName": "Selector",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 10,
        "sNo": 10.001,
        "name": "Injector 1",
        "connectionNo": 7,
        "objectName": "Injector",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 10,
        "sNo": 10.002,
        "name": "Injector 2",
        "connectionNo": 8,
        "objectName": "Injector",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 10,
        "sNo": 10.003,
        "name": "Injector 3",
        "connectionNo": 9,
        "objectName": "Injector",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 10,
        "sNo": 10.004,
        "name": "Injector 4",
        "connectionNo": 10,
        "objectName": "Injector",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 11,
        "sNo": 11.001,
        "name": "Filter 1",
        "connectionNo": 11,
        "objectName": "Filter",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 11,
        "sNo": 11.002,
        "name": "Filter 2",
        "connectionNo": 12,
        "objectName": "Filter",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 11,
        "sNo": 11.003,
        "name": "Filter 3",
        "connectionNo": 13,
        "objectName": "Filter",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 13,
        "sNo": 13.001,
        "name": "Valve 1",
        "connectionNo": 1,
        "objectName": "Valve",
        "type": "1,2",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 13,
        "sNo": 13.002,
        "name": "Valve 2",
        "connectionNo": 2,
        "objectName": "Valve",
        "type": "1,2",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 13,
        "sNo": 13.003,
        "name": "Valve 3",
        "connectionNo": 3,
        "objectName": "Valve",
        "type": "1,2",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 13,
        "sNo": 13.004,
        "name": "Valve 4",
        "connectionNo": 4,
        "objectName": "Valve",
        "type": "1,2",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 13,
        "sNo": 13.005,
        "name": "Valve 5",
        "connectionNo": 5,
        "objectName": "Valve",
        "type": "1,2",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 13,
        "sNo": 13.006,
        "name": "Valve 6",
        "connectionNo": 6,
        "objectName": "Valve",
        "type": "1,2",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 13,
        "sNo": 13.007,
        "name": "Valve 7",
        "connectionNo": 7,
        "objectName": "Valve",
        "type": "1,2",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 13,
        "sNo": 13.008,
        "name": "Valve 8",
        "connectionNo": 8,
        "objectName": "Valve",
        "type": "1,2",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 13,
        "sNo": 13.009,
        "name": "Valve 9",
        "connectionNo": 9,
        "objectName": "Valve",
        "type": "1,2",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 13,
        "sNo": 13.01,
        "name": "Valve 10",
        "connectionNo": 10,
        "objectName": "Valve",
        "type": "1,2",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 14,
        "sNo": 14.001,
        "name": "Main Valve 1",
        "connectionNo": 14,
        "objectName": "Main Valve",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 14,
        "sNo": 14.002,
        "name": "Main Valve 2",
        "connectionNo": 15,
        "objectName": "Main Valve",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 24,
        "sNo": 24.001,
        "name": "Pressure Sensor 1",
        "connectionNo": 1,
        "objectName": "Pressure Sensor",
        "type": "3",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 24,
        "sNo": 24.002,
        "name": "Pressure Sensor 2",
        "connectionNo": 2,
        "objectName": "Pressure Sensor",
        "type": "3",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 26,
        "sNo": 26.001,
        "name": "Level Sensor 1",
        "connectionNo": 3,
        "objectName": "Level Sensor",
        "type": "3",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 26,
        "sNo": 26.002,
        "name": "Level Sensor 2",
        "connectionNo": 4,
        "objectName": "Level Sensor",
        "type": "3",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 27,
        "sNo": 27.001,
        "name": "EC Sensor 1",
        "connectionNo": 7,
        "objectName": "EC Sensor",
        "type": "3",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 28,
        "sNo": 28.001,
        "name": "PH Sensor 1",
        "connectionNo": 5,
        "objectName": "PH Sensor",
        "type": "3",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 23,
        "sNo": 23.001,
        "name": "Pressure Switch 1",
        "connectionNo": null,
        "objectName": "Pressure Switch",
        "type": "4",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 30,
        "sNo": 30.001,
        "name": "Soil Temperature Sensor 1",
        "connectionNo": 1,
        "objectName": "Soil Temperature Sensor",
        "type": "4",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 40,
        "sNo": 40.001,
        "name": "Float 1",
        "connectionNo": 2,
        "objectName": "Float",
        "type": "4",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 40,
        "sNo": 40.002,
        "name": "Float 2",
        "connectionNo": 1,
        "objectName": "Float",
        "type": "4",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 41,
        "sNo": 41.001,
        "name": "Manual Button 1",
        "connectionNo": null,
        "objectName": "Manual Button",
        "type": "4",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 42,
        "sNo": 42.001,
        "name": "Power Supply 1",
        "connectionNo": null,
        "objectName": "Power Supply",
        "type": "4",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 22,
        "sNo": 22.001,
        "name": "Water Meter 1",
        "connectionNo": 1,
        "objectName": "Water Meter",
        "type": "6",
        "controllerId": 10,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 25,
        "sNo": 25.001,
        "name": "Moisture Sensor 1",
        "connectionNo": 1,
        "objectName": "Moisture Sensor",
        "type": "5",
        "controllerId": 15,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 25,
        "sNo": 25.002,
        "name": "Moisture Sensor 2",
        "connectionNo": 2,
        "objectName": "Moisture Sensor",
        "type": "5",
        "controllerId": 15,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 25,
        "sNo": 25.003,
        "name": "Moisture Sensor 3",
        "connectionNo": 3,
        "objectName": "Moisture Sensor",
        "type": "5",
        "controllerId": 15,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 25,
        "sNo": 25.004,
        "name": "Moisture Sensor 4",
        "connectionNo": 4,
        "objectName": "Moisture Sensor",
        "type": "5",
        "controllerId": 15,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      },
      {
        "objectId": 22,
        "sNo": 22.002,
        "name": "Water Meter 2",
        "connectionNo": 1,
        "objectName": "Water Meter",
        "type": "6",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null
      }
    ],
    "waterSource": [
      {
        "objectId": 1,
        "sNo": 1.001,
        "name": "Source 1",
        "connectionNo": null,
        "objectName": "Source",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "sourceType": 5,
        "level": 0,
        "topFloat": 0,
        "bottomFloat": 0,
        "inletPump": [],
        "outletPump": [
          5.001
        ],
        "valves": []
      },
      {
        "objectId": 1,
        "sNo": 1.002,
        "name": "Source 2",
        "connectionNo": null,
        "objectName": "Source",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "sourceType": 4,
        "level": 0,
        "topFloat": 0,
        "bottomFloat": 0,
        "inletPump": [],
        "outletPump": [
          5.002
        ],
        "valves": []
      },
      {
        "objectId": 1,
        "sNo": 1.003,
        "name": "Source 3",
        "connectionNo": null,
        "objectName": "Source",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "sourceType": 4,
        "level": 0,
        "topFloat": 0,
        "bottomFloat": 0,
        "inletPump": [],
        "outletPump": [
          5.003
        ],
        "valves": []
      },
      {
        "objectId": 1,
        "sNo": 1.004,
        "name": "Source 4",
        "connectionNo": null,
        "objectName": "Source",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "sourceType": 2,
        "level": 26.001,
        "topFloat": 0,
        "bottomFloat": 0,
        "inletPump": [
          5.001,
          5.002,
          5.003
        ],
        "outletPump": [
          5.004,
          5.005
        ],
        "valves": []
      }
    ],
    "pump": [
      {
        "objectId": 5,
        "sNo": 5.001,
        "name": "Pump 1",
        "connectionNo": 1,
        "objectName": "Pump",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "level": 0,
        "pressureIn": 0,
        "pressureOut": 0,
        "waterMeter": 22.001,
        "pumpType": 1
      },
      {
        "objectId": 5,
        "sNo": 5.002,
        "name": "Pump 2",
        "connectionNo": 2,
        "objectName": "Pump",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "level": 0,
        "pressureIn": 0,
        "pressureOut": 0,
        "waterMeter": 0,
        "pumpType": 1
      },
      {
        "objectId": 5,
        "sNo": 5.003,
        "name": "Pump 3",
        "connectionNo": 3,
        "objectName": "Pump",
        "type": "1,2",
        "controllerId": 2,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "level": 0,
        "pressureIn": 0,
        "pressureOut": 0,
        "waterMeter": 0,
        "pumpType": 1
      },
      {
        "objectId": 5,
        "sNo": 5.004,
        "name": "Pump 4",
        "connectionNo": null,
        "objectName": "Pump",
        "type": "1,2",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "level": 0,
        "pressureIn": 0,
        "pressureOut": 0,
        "waterMeter": 0,
        "pumpType": 2
      },
      {
        "objectId": 5,
        "sNo": 5.005,
        "name": "Pump 5",
        "connectionNo": null,
        "objectName": "Pump",
        "type": "1,2",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "level": 0,
        "pressureIn": 0,
        "pressureOut": 0,
        "waterMeter": 0,
        "pumpType": 2
      }
    ],
    "filterSite": [
      {
        "objectId": 4,
        "sNo": 4.001,
        "name": "Filtration Site 1",
        "connectionNo": null,
        "objectName": "Filtration Site",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": 1,
        "filters": [
          11.001,
          11.002,
          11.003
        ],
        "pressureIn": 24.001,
        "pressureOut": 24.002,
        "backWashValve": 0
      }
    ],
    "fertilizerSite": [
      {
        "objectId": 3,
        "sNo": 3.001,
        "name": "Fertilization Site 1",
        "connectionNo": null,
        "objectName": "Fertilization Site",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": 1,
        "channel": [
          {
            "sNo": 10.001,
            "level": 0
          },
          {
            "sNo": 10.002,
            "level": 0
          },
          {
            "sNo": 10.003,
            "level": 0
          },
          {
            "sNo": 10.004,
            "level": 0
          }
        ],
        "boosterPump": [
          7.001
        ],
        "agitator": [
          9.001
        ],
        "selector": [],
        "ec": [
          27.001
        ],
        "ph": [
          28.001
        ]
      }
    ],
    "moistureSensor": [
      {
        "objectId": 25,
        "sNo": 25.001,
        "name": "Moisture Sensor 1",
        "connectionNo": 1,
        "objectName": "Moisture Sensor",
        "type": "5",
        "controllerId": 15,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "valves": []
      },
      {
        "objectId": 25,
        "sNo": 25.002,
        "name": "Moisture Sensor 2",
        "connectionNo": 2,
        "objectName": "Moisture Sensor",
        "type": "5",
        "controllerId": 15,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "valves": []
      },
      {
        "objectId": 25,
        "sNo": 25.003,
        "name": "Moisture Sensor 3",
        "connectionNo": 3,
        "objectName": "Moisture Sensor",
        "type": "5",
        "controllerId": 15,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "valves": []
      },
      {
        "objectId": 25,
        "sNo": 25.004,
        "name": "Moisture Sensor 4",
        "connectionNo": 4,
        "objectName": "Moisture Sensor",
        "type": "5",
        "controllerId": 15,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "valves": []
      }
    ],
    "irrigationLine": [
      {
        "objectId": 2,
        "sNo": 2.001,
        "name": "Irrigation Line 1",
        "connectionNo": null,
        "objectName": "Irrigation Line",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "source": [],
        "sourcePump": [
          5.001,
          5.002,
          5.003
        ],
        "irrigationPump": [
          5.004,
          5.005
        ],
        "centralFiltration": 4.001,
        "localFiltration": 0,
        "centralFertilization": 3.001,
        "localFertilization": 0,
        "valve": [
          13.001,
          13.002,
          13.003,
          13.004,
          13.005
        ],
        "mainValve": [
          14.001,
          14.002
        ],
        "fan": [],
        "fogger": [],
        "pesticides": [],
        "heater": [],
        "screen": [],
        "vent": [],
        "powerSupply": 0,
        "pressureSwitch": 0,
        "waterMeter": 22.002,
        "pressureIn": 0,
        "pressureOut": 0,
        "moisture": [
          25.001,
          25.002,
          25.003,
          25.004
        ],
        "temperature": [],
        "soilTemperature": [],
        "humidity": [],
        "co2": []
      },
      {
        "objectId": 2,
        "sNo": 2.002,
        "name": "Irrigation Line 2",
        "connectionNo": null,
        "objectName": "Irrigation Line",
        "type": "-",
        "controllerId": null,
        "count": null,
        "connectedObject": null,
        "siteMode": null,
        "source": [],
        "sourcePump": [
          5.001,
          5.002,
          5.003
        ],
        "irrigationPump": [
          5.004,
          5.005
        ],
        "centralFiltration": 4.001,
        "localFiltration": 0,
        "centralFertilization": 0,
        "localFertilization": 0,
        "valve": [
          13.006,
          13.007,
          13.008,
          13.009,
          13.01
        ],
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
      }
    ],
    "controllerReadStatus": "0"
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    configPvd = Provider.of<ConfigMakerProvider>(context, listen: false);
    if(mqttManager.connectionState == MqttConnectionState.connected){
      mqttManager.topicToSubscribe('${Environment.mqttSubscribeTopic}/${configPvd.masterData['deviceId']}');
      print('subscribe successfully...........');
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    themeData = Theme.of(context);
    themeMode = themeData.brightness == Brightness.light;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool themeMode = themeData.brightness == Brightness.light;
    return Material(
      color: themeData.primaryColorDark.withOpacity(themeMode ? 1.0 : 0.2),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleWithBackButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  title: 'Config Maker',

                  // titleWidth: screenWidth * sideNavigationTabRatio,
                  titleWidth: sideNavigationTabWidth,
                ),
                Row(
                  spacing:20,
                  children: [
                    StreamBuilder(
                        stream: mqttManager.connectionStatusController.stream,
                        initialData: mqttManager.connectionState,
                        builder: (context, snapShot){
                          return Row(
                            spacing: 10,
                            children: [
                              CircleAvatar(
                                backgroundColor: mqttManager.connectionState == MqttConnectionState.connected ? Colors.greenAccent : Colors.red,
                                radius: 20,
                                child: const Icon(Icons.computer, color: Colors.white,),
                              ),
                              Text('MQTT ${mqttManager.connectionState.name}', style: const TextStyle(color: Colors.white),)

                            ],
                          );
                        }
                    ),
                    InkWell(
                    onHover: (value){
                      setState(() {
                        clearOnHover = value;
                      });
                    },
                    onTap: (){
                      configPvd.clearData();
                    },
                    child:  Row(
                      spacing: 10,
                      children: [
                        CircleAvatar(
                          backgroundColor: clearOnHover ? themeData.primaryColorLight : themeData.primaryColorLight.withOpacity(0.5),
                          radius: 20,
                          child: SizedImageSmall(imagePath: '${AppConstants.svgObjectPath}clear.svg',color:  Colors.white,),
                        ),
                        const Text('Click To Clear Config', style: TextStyle(color: Colors.white),)
                      ],
                    ),
                  ),
                    InkWell(
                      onHover: (value){
                        setState(() {
                          sendOnHover = value;
                        });
                      },
                      onTap: (){
                        setState(() {
                          payloadSendState = PayloadSendState.idle;
                        });
                        sendToMqtt();
                        sendToHttp();
                        },
                      child:  Row(
                        spacing: 10,
                        children: [
                          CircleAvatar(
                            backgroundColor: sendOnHover ? themeData.primaryColorLight : themeData.primaryColorLight.withOpacity(0.5),
                            radius: 20,
                            child: SizedImageSmall(imagePath: '${AppConstants.svgObjectPath}send.svg',color:  Colors.white,),
                          ),
                          const Text('Click To Send Config', style: TextStyle(color: Colors.white),)
                        ],
                      ),
                    ),
                    const SizedBox(width: 10,)
                  ],
                ),


              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                sideNavigationWidget(screenWidth, screenHeight),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10))
                    ),
                      child: configPvd.selectedTab == ConfigMakerTabs.deviceList
                          ? DeviceList(listOfDevices: widget.listOfDevices)
                          : configPvd.selectedTab == ConfigMakerTabs.productLimit
                          ? ProductLimit(listOfDevices: widget.listOfDevices,configPvd: configPvd,)
                          : configPvd.selectedTab == ConfigMakerTabs.connection
                          ? Connection(configPvd: configPvd,) : SiteConfigure(configPvd: configPvd)
                  ),
                )

              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendToMqtt(){
    setState(() {
      listOfPayload.clear();
      listOfPayload.addAll(configPvd.getOroPumpPayload());
    });

    if([1, 2, 4].contains(configPvd.masterData['modelId'])){
      final Map<String, dynamic> configMakerPayload = {
        '100' : {
          '101' : configPvd.getDeviceListPayload(),
          '102' : configPvd.getObjectPayload(),
          '103' : configPvd.getPumpPayload(),
          '104' : configPvd.getFilterPayload(),
          '105' : configPvd.getFertilizerPayload(),
          '106' : configPvd.getFertilizerInjectorPayload(),
          '107' : configPvd.getIrrigationLinePayload(),
        }
      };
      setState(() {
        listOfPayload.insert(0,{
          'title' : '${configPvd.masterData['deviceId']}(gem config)',
          'deviceId' : configPvd.masterData['deviceId'],
          'deviceIdToSend' : configPvd.masterData['deviceId'],
          'payload' : jsonEncode(configMakerPayload),
          'acknowledgementState' : HardwareAcknowledgementSate.notSent,
          'selected' : true,
          'checkingCode' : '100',
          'hardwareType' : HardwareType.master
        });
      });
    }
    // MqttManager().topicToPublishAndItsMessage('${Environment.mqttWebPublishTopic}/${configPvd.masterData['deviceId']}', jsonEncode(configMakerPayload));
    print("listOfPayload ==> $listOfPayload");
    payloadAlertBox();
  }

  void payloadAlertBox(){
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context){
          return StatefulBuilder(
              builder: (context, stateSetter){
                return AlertDialog(
                  title: const Text('Configuration Payload'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        for(var payload in listOfPayload)
                          CheckboxListTile(
                            enabled: (payloadSendState == PayloadSendState.idle || payloadSendState == PayloadSendState.stop),
                            title: Text('${payload['title']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(payload['deviceId']),
                                payloadAcknowledgementWidget(payload['acknowledgementState'] as HardwareAcknowledgementSate),
                              ],
                            ),
                            value: payload['selected'],
                            onChanged: (value){
                              stateSetter((){
                                setState(() {
                                  payload['selected'] = value;
                                });
                              });
                            },
                          )
                      ],
                    ),
                  ),
                  actions: [
                    if(payloadSendState == PayloadSendState.idle && payloadSendState == PayloadSendState.start)
                      CustomMaterialButton( // only show cancel button when payloadState on idle and start
                        outlined: true,
                        title: 'Cancel',
                        onPressed: (){
                          stateSetter((){
                            setState(() {
                              payloadSendState = PayloadSendState.stop;
                            });
                            Navigator.pop(context);
                          });
                        },
                      ),


                    if(payloadSendState == PayloadSendState.idle) // only show send button when payloadState on idle
                      CustomMaterialButton(
                        onPressed: ()async{
                          payloadLoop : for(var payload in listOfPayload){
                            if(!payload['selected']){
                              continue payloadLoop;
                            }
                            bool mqttAttempt = true;
                            int delayDuration = 10;
                            delayLoop : for(var sec = 0;sec < delayDuration;sec++){
                              if(sec == 0){
                                payloadSendState = PayloadSendState.start;
                                payload['acknowledgementState'] = HardwareAcknowledgementSate.sending;
                              }
                              if(sec == delayDuration - 1){
                                payload['acknowledgementState'] = HardwareAcknowledgementSate.failed;
                              }
                              await Future.delayed(const Duration(seconds: 1));
                              print("sec ${sec + 1}   -- ${payload['deviceId']}");
                              if(mqttManager.connectionState == MqttConnectionState.connected && mqttAttempt == true){
                                mqttManager.topicToPublishAndItsMessage('${Environment.mqttPublishTopic}/${configPvd.masterData['deviceId']}', payload['payload']);
                                mqttAttempt = false;

                              }
                              stateSetter((){
                                setState(() {
                                  if(payload['hardwareType'] as HardwareType == HardwareType.master){  // listening acknowledgement from gem
                                    if(mqttManager.payload != null){
                                      if(validatePayloadFromHardware(mqttManager.payload!, ['cC'], payload['deviceIdToSend']) && validatePayloadFromHardware(mqttManager.payload!, ['cM', '4201', 'PayloadCode'], payload['checkingCode'])){
                                        if(mqttManager.payload!['cM']['4201']['Code'] == '200'){
                                          payload['acknowledgementState'] = HardwareAcknowledgementSate.success;
                                        }else if(mqttManager.payload!['cM']['4201']['Code'] == '90'){
                                          payload['acknowledgementState'] = HardwareAcknowledgementSate.programRunning;
                                        }else if(mqttManager.payload!['cM']['4201']['Code'] == '1'){
                                          payload['acknowledgementState'] = HardwareAcknowledgementSate.hardwareUnknownError;
                                          print('successfully!! update status for ${payload['title']}  and its code : ${mqttManager.payload!['cM']['4201']['Code']} -- ${payload['acknowledgementState']}');
                                        }else{
                                          payload['acknowledgementState'] = HardwareAcknowledgementSate.errorOnPayload;
                                        }
                                        mqttManager.payload == null;
                                      }
                                    }
                                  }
                                  else if(payload['hardwareType'] as HardwareType == HardwareType.pump){
                                    if(mqttManager.payload != null){
                                      if(validatePayloadFromHardware(mqttManager.payload!, ['cC'], payload['deviceIdToSend']) && validatePayloadFromHardware(mqttManager.payload!, ['cM'], payload['checkingCode'])){
                                        payload['acknowledgementState'] = HardwareAcknowledgementSate.success;
                                        mqttManager.payload == null;
                                      }
                                    }
                                  }


                                });
                              });
                              if((payload['acknowledgementState'] as HardwareAcknowledgementSate) != HardwareAcknowledgementSate.sending){
                                break delayLoop;
                              }
                            }
                          }

                          if(payloadSendState == PayloadSendState.start){  // only stop if all payload completed
                            stateSetter((){
                              setState(() {
                                payloadSendState = PayloadSendState.stop;
                                mqttManager.payload = null;
                              });
                            });
                          }
                        },
                        title: 'Send',
                      ),

                    if(payloadSendState == PayloadSendState.stop)
                      CustomMaterialButton(),
                  ],
                );
              }
          );
        }
    );
  }


  Widget payloadAcknowledgementWidget(HardwareAcknowledgementSate state){
    print('state : ${state.name}');
    late Color color;
    if(state == HardwareAcknowledgementSate.notSent){
      color = Colors.grey;
      return statusBox(color, Text('not sent', style: TextStyle(color: color, fontSize: 12),));
    }else if(state == HardwareAcknowledgementSate.failed){
      color = Colors.red;
      return statusBox(color, Text('failed...', style: TextStyle(color: color, fontSize: 12),));
    }else if(state == HardwareAcknowledgementSate.success){
      color = Colors.green;
      return statusBox(color, Text('success...', style: TextStyle(color: color, fontSize: 12),));
    }else if(state == HardwareAcknowledgementSate.programRunning){
      color = Colors.red;
      return statusBox(color, Text('Failed - Program Running...', style: TextStyle(color: color, fontSize: 12),));
    }else if(state == HardwareAcknowledgementSate.errorOnPayload){
      color = Colors.red;
      return statusBox(color, Text('Error on payload...', style: TextStyle(color: color, fontSize: 12),));
    }else if(state == HardwareAcknowledgementSate.hardwareUnknownError){
      color = Colors.red;
      return statusBox(color, Text('Unknown error...', style: TextStyle(color: color, fontSize: 12),));
    }else{
      return const SizedBox(
          width: double.infinity,
          height: 5,
          child: LinearProgressIndicator()
      );
    }
  }

  Widget statusBox(Color color, Widget child){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(5)
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10 , vertical: 5),
      child: child,
    );
  }

  void sendToHttp()async{
    var listOfSampleObjectModel = configPvd.listOfSampleObjectModel.map((object){
      return object.toJson();
    }).toList();
    var listOfObjectModelConnection = configPvd.listOfObjectModelConnection.map((object){
      return object.toJson();
    }).toList();
    var listOfGeneratedObject = configPvd.listOfGeneratedObject.map((object){
      return object.toJson();
    }).toList();
    var filtration = configPvd.filtration.cast<FiltrationModel>().map((object){
      return object.toJson();
    }).toList();
    var fertilization = configPvd.fertilization.cast<FertilizationModel>().map((object){
      return object.toJson();
    }).toList();
    var source = configPvd.source.cast<SourceModel>().map((object){
      return object.toJson();
    }).toList();
    var pump = configPvd.pump.cast<PumpModel>().map((object){
      return object.toJson();
    }).toList();
    var moisture = configPvd.moisture.cast<MoistureModel>().map((object){
      return object.toJson();
    }).toList();
    var line = configPvd.line.cast<IrrigationLineModel>().map((object){
      return object.toJson();
    }).toList();

    var body = {
      "userId" : configPvd.masterData['customerId'],
      "controllerId" : configPvd.masterData['controllerId'],
      'groupId' : configPvd.masterData['groupId'],
      "isNewConfig" : '0',
      "productLimit" : listOfSampleObjectModel,
      "connectionCount" : listOfObjectModelConnection,
      "configObject" : listOfGeneratedObject,
      "waterSource" : source,
      "pump" : pump,
      "filterSite" : filtration,
      "fertilizerSite" : fertilization,
      "moistureSensor" : moisture,
      "irrigationLine" : line,
      "deviceList" : ![1, 2, 4].contains(configPvd.masterData['modelId']) ? [] : configPvd.listOfDeviceModel.map((device) {
        return {
          'productId' : device.productId,
          'controllerId' : device.controllerId,
          'masterId' : device.masterId,
          'referenceNumber' : configPvd.findOutReferenceNumber(device),
          'serialNumber' : device.serialNumber,
          'interfaceTypeId' : device.interfaceTypeId,
          'interfaceInterval' : device.masterId == null ? null : device.interfaceInterval,
          'extendControllerId' : device.extendControllerId,
        };
      }).toList(),
      "hardware" : {},
      "controllerReadStatus" : '0',
      "createUser" : configPvd.masterData['userId']
    };
    var response = await ConfigMakerRepository().createUserConfigMaker(body);
    print('body : ${jsonEncode(body)}');
    print('response : ${response.body}');
  }

  Widget sideNavigationWidget(screenWidth, screenHeight){
    return SizedBox(
      width: screenWidth  > webBreakPoint ? sideNavigationWidth : sideNavigationBreakPointWidth,
      height: screenHeight,
      child: Column(
        children: [
          const SizedBox(height: 50,),
          ...getSideNavigationTab(screenWidth)

        ],
      ),
    );
  }

  List<Widget> getSideNavigationTab(screenWidth){
    return [
      for(var i in ConfigMakerTabs.values)
        if(configPvd.masterData['categoryId'] != 2 || (![ConfigMakerTabs.deviceList].contains(i)))
          CustomSideTab(
          width: screenWidth  > webBreakPoint ? sideNavigationTabWidth : sideNavigationTabBreakPointWidth,
          imagePath: '${AppConstants.svgObjectPath}${getTabImage(i)}.svg',
          title: getTabName(i),
          selected: i == configPvd.selectedTab,
          onTap: (){
            updateConfigMakerTabs(
                context: context,
                configPvd: configPvd,
                setState: setState,
                selectedTab: i
            );
          },
        )
    ];
  }

  String getTabImage(ConfigMakerTabs configMakerTabs) {
    switch (configMakerTabs) {
      case ConfigMakerTabs.deviceList:
        return 'device_list';
      case ConfigMakerTabs.productLimit:
        return 'product_limit';
      case ConfigMakerTabs.connection:
        return 'connection';
      case ConfigMakerTabs.siteConfigure:
        return 'site_configure';
      default:
        throw ArgumentError('Invalid ConfigMakerTabs value: $configMakerTabs');
    }
  }
}

bool validatePayloadFromHardware(Map<String, dynamic>? payload, List<String> keys, String checkingValue){
  bool condition = false;
  dynamic checkingNestedData = payload;
  if(payload!.containsKey('cC')){
    for(var key in keys){
      if(checkingNestedData != null && checkingNestedData.containsKey(key)){
        checkingNestedData = checkingNestedData[key];
      }else{
        condition = false;
        break;
      }
    }
  }
  if(checkingNestedData is String){
    if(checkingNestedData.contains(checkingValue)){
      condition = true;
    }else if(checkingNestedData == checkingValue){
      condition = true;
    }
  }

  if(kDebugMode){
    print("checkingNestedData : $checkingNestedData \n checkingValue : $checkingValue \n condition : $condition");
  }
  return condition;
}

enum HardwareAcknowledgementSate{notSent, sending, failed, success, errorOnPayload, hardwareUnknownError, programRunning}
enum PayloadSendState{idle, start, stop}
enum HardwareType{master, pump, economic}
