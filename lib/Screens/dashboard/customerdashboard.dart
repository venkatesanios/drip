import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_drip_irrigation/Screens/dashboard/Source%20Type%20Dashboard/WaterSourceCustomerdashboard.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/admin&dealer/product_list_with_node.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../StateManagement/overall_use.dart';
import '../../Widgets/SCustomWidgets/custom_date_picker.dart';
import '../../Widgets/SCustomWidgets/custom_list_tile.dart';
import '../../Widgets/SCustomWidgets/custom_native_time_picker.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../services/mqtt_manager_web.dart';
 import '../../utils/snack_bar.dart';
import '../NewIrrigationProgram/preview_screen.dart';
import '../NewIrrigationProgram/schedule_screen.dart';
 import 'Irrigation Pump Dashboard/irrigation_pump_false.dart';
import 'Irrigation Pump Dashboard/irrigation_pump_true.dart';
import 'Line Dashboard/irrigation_line_false.dart';
import 'Line Dashboard/irrigation_line_true.dart';
import 'Source Type Dashboard/source_type_false.dart';
import 'Source Type Dashboard/source_type_true.dart';

final double speed = 100.0;
final double gap = 100;
final double initialPosition = -100.0;
//siva prakash

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}
class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late MqttPayloadProvider payloadProvider;
  late OverAllUse overAllPvd;
  MqttManager manager = MqttManager();
  bool sourcePumpMode = false;
  bool irrigationLineMode = false;
  bool irrigationPumpMode = false;
  bool filtrationWidgetMode = false;
  bool fertigationWidgetMode = false;
  late Timer _timer;
  int selectedTab = 0;
  int userId = 0;
  double appBarHeight = 105.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _correctPassword = 'Oro@321';
  var liveData;
  Map<String, dynamic> newlivedata = {
    "code": 200,
    "message": "User dashboard listed successfully",
    "data": [
      {
        "customerId": 8,
        "customerName": "Testing",
        "userGroupId": 3,
        "groupName": "Hardware Testing site",
        "groupAddress": "address",
        "master": [
          {
            "controllerId": 13,
            "deviceId": "2CCF674C0F8A",
            "deviceName": "ORO GEM",
            "categoryId": 1,
            "categoryName": "ORO GEM",
            "modelId": 1,
            "modelName": "OGEMR",
            "liveMessage": {
              "cC": "2CCF674C0F8A",
              "cM": {
                "2401": "2,0.0,0.0,3,-;3,0.0,0.0,3,-;1,0.0,0.0,3,-",
                "2402":
                    "5.001,0;5.002,0;13.001,0;13.002,0;13.003,0;13.004,0;13.005,0;9.001,0;7.001,0;10.001,0;10.002,0;10.003,0;10.004,0;14.001,0",
                "2403": "",
                "2404":
                    "5.001,0,0,0,0,000,000,000,1:0.0,2:0.0,3:0.0,00:00:00;5.002,0,0,0,0,000,000,000,1:0.0,2:0.0,3:0.0,00:00:00",
                "2405": "2.001,0",
                "2406": "4.001,0,01:00:00,0.0",
                "2407": "",
                "2408":
                    "0,0,1,00:05:00,00:05:00,0,0,0,0,0,0,13:20:07,0,0,00:00:00,None,1,0,0.00",
                "2409": "",
                "2410": "",
                "2411": "",
                "2412": "",
                "WifiStrength": 100,
                "SentTime": "2025-02-27 12:36:59",
                "Version": "1.1.0:008",
                "PowerSupply": 1,
                "PowerSupplyError": 1
              },
              "cD": "2025-02-27",
              "cT": "12:36:59",
              "mC": "2400"
            },
            "config": {
              "configObject": [
                {
                  "objectId": 1,
                  "sNo": 1.001,
                  "name": "Tank 1",
                  "connectionNo": null,
                  "objectName": "Tank",
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
                  "objectId": 5,
                  "sNo": 5.001,
                  "name": "Pump 1",
                  "connectionNo": 1,
                  "objectName": "Pump",
                  "type": "1,2",
                  "controllerId": 15,
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
                  "controllerId": 15,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 13,
                  "sNo": 13.001,
                  "name": "Valve 1",
                  "connectionNo": 3,
                  "objectName": "Valve",
                  "type": "1,2",
                  "controllerId": 15,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 13,
                  "sNo": 13.002,
                  "name": "Valve 2",
                  "connectionNo": 4,
                  "objectName": "Valve",
                  "type": "1,2",
                  "controllerId": 15,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 13,
                  "sNo": 13.003,
                  "name": "Valve 3",
                  "connectionNo": 5,
                  "objectName": "Valve",
                  "type": "1,2",
                  "controllerId": 15,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 13,
                  "sNo": 13.004,
                  "name": "Valve 4",
                  "connectionNo": 6,
                  "objectName": "Valve",
                  "type": "1,2",
                  "controllerId": 15,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 13,
                  "sNo": 13.005,
                  "name": "Valve 5",
                  "connectionNo": 7,
                  "objectName": "Valve",
                  "type": "1,2",
                  "controllerId": 15,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 3,
                  "sNo": 3.001,
                  "name": "Dosing Site 1",
                  "connectionNo": null,
                  "objectName": "Dosing Site",
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
                  "objectId": 9,
                  "sNo": 9.001,
                  "name": "Agitator 1",
                  "connectionNo": 1,
                  "objectName": "Agitator",
                  "type": "1,2",
                  "controllerId": 20,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 7,
                  "sNo": 7.001,
                  "name": "Booster Pump 1",
                  "connectionNo": 8,
                  "objectName": "Booster Pump",
                  "type": "1,2",
                  "controllerId": 15,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 10,
                  "sNo": 10.001,
                  "name": "Injector 1",
                  "connectionNo": 3,
                  "objectName": "Injector",
                  "type": "1,2",
                  "controllerId": 20,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 10,
                  "sNo": 10.002,
                  "name": "Injector 2",
                  "connectionNo": 4,
                  "objectName": "Injector",
                  "type": "1,2",
                  "controllerId": 20,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 11,
                  "sNo": 11.001,
                  "name": "Filter 1",
                  "connectionNo": null,
                  "objectName": "Filter",
                  "type": "1,2",
                  "controllerId": null,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 11,
                  "sNo": 11.002,
                  "name": "Filter 2",
                  "connectionNo": null,
                  "objectName": "Filter",
                  "type": "1,2",
                  "controllerId": null,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 10,
                  "sNo": 10.003,
                  "name": "Injector 3",
                  "connectionNo": 5,
                  "objectName": "Injector",
                  "type": "1,2",
                  "controllerId": 20,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 10,
                  "sNo": 10.004,
                  "name": "Injector 4",
                  "connectionNo": 6,
                  "objectName": "Injector",
                  "type": "1,2",
                  "controllerId": 20,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 14,
                  "sNo": 14.001,
                  "name": "Main Valve 1",
                  "connectionNo": 2,
                  "objectName": "Main Valve",
                  "type": "1,2",
                  "controllerId": 20,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 3,
                  "sNo": 3.002,
                  "name": "Dosing Site 2",
                  "connectionNo": null,
                  "objectName": "Dosing Site",
                  "type": "-",
                  "controllerId": null,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 10,
                  "sNo": 10.005,
                  "name": "Injector 5",
                  "connectionNo": 9,
                  "objectName": "Injector",
                  "type": "1,2",
                  "controllerId": 20,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 10,
                  "sNo": 10.006,
                  "name": "Injector 6",
                  "connectionNo": 10,
                  "objectName": "Injector",
                  "type": "1,2",
                  "controllerId": 20,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 9,
                  "sNo": 9.002,
                  "name": "Agitator 2",
                  "connectionNo": 8,
                  "objectName": "Agitator",
                  "type": "1,2",
                  "controllerId": 20,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                },
                {
                  "objectId": 7,
                  "sNo": 7.002,
                  "name": "Booster Pump 2",
                  "connectionNo": 7,
                  "objectName": "Booster Pump",
                  "type": "1,2",
                  "controllerId": 20,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null
                }
              ],
              "waterSource": [
                {
                  "objectId": 1,
                  "sNo": 1.001,
                  "name": "Tank 1",
                  "connectionNo": null,
                  "objectName": "Tank",
                  "type": "-",
                  "controllerId": null,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": null,
                  "sourceType": 3,
                  "level": 0,
                  "topFloat": 0,
                  "bottomFloat": 0,
                  "inletPump": [],
                  "outletPump": [5.001, 5.002],
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
                  "controllerId": 15,
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
                  "sNo": 5.002,
                  "name": "Pump 2",
                  "connectionNo": 2,
                  "objectName": "Pump",
                  "type": "1,2",
                  "controllerId": 15,
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
                  "filters": [11.001, 11.002],
                  "pressureIn": 0,
                  "pressureOut": 0,
                  "backWashValve": 0
                }
              ],
              "fertilizerSite": [
                {
                  "objectId": 3,
                  "sNo": 3.001,
                  "name": "Dosing Site 1",
                  "connectionNo": null,
                  "objectName": "Dosing Site",
                  "type": "-",
                  "controllerId": null,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": 1,
                  "channel": [
                    {"sNo": 10.001, "level": 0},
                    {"sNo": 10.002, "level": 0},
                    {"sNo": 10.003, "level": 0},
                    {"sNo": 10.004, "level": 0}
                  ],
                  "boosterPump": [7.001],
                  "agitator": [9.001],
                  "selector": [],
                  "ec": [],
                  "ph": []
                },
                {
                  "objectId": 3,
                  "sNo": 3.002,
                  "name": "Dosing Site 2",
                  "connectionNo": null,
                  "objectName": "Dosing Site",
                  "type": "-",
                  "controllerId": null,
                  "count": null,
                  "connectedObject": null,
                  "siteMode": 2,
                  "channel": [
                    {"sNo": 10.005, "level": 0},
                    {"sNo": 10.006, "level": 0}
                  ],
                  "boosterPump": [7.002],
                  "agitator": [9.002],
                  "selector": [],
                  "ec": [],
                  "ph": []
                }
              ],
              "moistureSensor": [],
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
                  "sourcePump": [],
                  "irrigationPump": [5.001, 5.002],
                  "centralFiltration": 4.001,
                  "localFiltration": 0,
                  "centralFertilization": 3.001,
                  "localFertilization": 3.002,
                  "valve": [13.001, 13.002, 13.003, 13.004, 13.005],
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
              ]
            },
            "nodeList": [
              {
                "controllerId": 21,
                "deviceId": "AABBCC112244",
                "deviceName": "ORO SENSE",
                "categoryId": 9,
                "categoryName": "ORO SENSE",
                "modelId": 24,
                "modelName": "OSMST",
                "referenceNumber": 1,
                "serialNumber": 1,
                "interfaceTypeId": 1,
                "interface": "MQTT",
                "extendControllerId": null
              },
              {
                "controllerId": 15,
                "deviceId": "ABC123456712",
                "deviceName": "ORO SMART+",
                "categoryId": 6,
                "categoryName": "ORO SMART+",
                "modelId": 14,
                "modelName": "OSP8R",
                "referenceNumber": 1,
                "serialNumber": 2,
                "interfaceTypeId": 1,
                "interface": "MQTT",
                "extendControllerId": null
              },
              {
                "controllerId": 20,
                "deviceId": "AABBCC112233",
                "deviceName": "ORO SMART+",
                "categoryId": 6,
                "categoryName": "ORO SMART+",
                "modelId": 16,
                "modelName": "OSP16RADC",
                "referenceNumber": 2,
                "serialNumber": 3,
                "interfaceTypeId": 1,
                "interface": "MQTT",
                "extendControllerId": null
              }
            ],
            "program": [
              {
                "serialNumber": 1,
                "programName": "Program 1",
                "defaultProgramName": "Program 1",
                "programType": "Irrigation Program",
                "sequence": [
                  {"sNo": "1.1", "name": "Sequence 1.1"}
                ],
                "selectedSchedule": "NO SCHEDULE"
              },
              {
                "serialNumber": 2,
                "programName": "Program 2",
                "defaultProgramName": "Program 2",
                "programType": "Irrigation Program",
                "sequence": [
                  {"sNo": "2.1", "name": "Sequence 2.1"}
                ],
                "selectedSchedule": "NO SCHEDULE"
              }
            ],
            "units": [
              {
                "dealerDefinitionId": 114,
                "parameter": "Water Meter",
                "value": "l/s"
              },
              {
                "dealerDefinitionId": 115,
                "parameter": "Pressure Sensor",
                "value": "bar"
              },
              {
                "dealerDefinitionId": 116,
                "parameter": "Moisture Sensor",
                "value": "cb"
              },
              {
                "dealerDefinitionId": 117,
                "parameter": "Level Sensor",
                "value": "feet"
              },
              {
                "dealerDefinitionId": 118,
                "parameter": "Temperature Sensor",
                "value": "°C"
              },
              {
                "dealerDefinitionId": 119,
                "parameter": "Soil Temperature Sensor",
                "value": "°C"
              },
              {
                "dealerDefinitionId": 120,
                "parameter": "Humdity Sensor",
                "value": "%"
              },
              {
                "dealerDefinitionId": 121,
                "parameter": "CO2 Sensor",
                "value": "ppm"
              },
              {
                "dealerDefinitionId": 122,
                "parameter": "LUX Sensor",
                "value": "lux"
              },
              {
                "dealerDefinitionId": 123,
                "parameter": "Leaf Wetness Sensor",
                "value": "%"
              },
              {
                "dealerDefinitionId": 124,
                "parameter": "Rain Fall",
                "value": "mm"
              },
              {
                "dealerDefinitionId": 125,
                "parameter": "Wind Speed",
                "value": "km/h"
              },
              {
                "dealerDefinitionId": 126,
                "parameter": "Wind Direction",
                "value": "°"
              },
              {
                "dealerDefinitionId": 128,
                "parameter": "Atmospheric Pressure Sensor",
                "value": "kPa"
              },
              {
                "dealerDefinitionId": 129,
                "parameter": "LDX Sensor",
                "value": "lux"
              }
            ]
          }
        ]
      }
    ]
  };
  @override
  void initState() {
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    _timer = Timer.periodic(const Duration(seconds: 15), (Timer timer) {
      if (mounted) {
        //
        setState(() {
          irrigationLineMode = !irrigationLineMode;
          sourcePumpMode = !sourcePumpMode;
          irrigationPumpMode = !irrigationPumpMode;
          filtrationWidgetMode = !filtrationWidgetMode;
          fertigationWidgetMode = !fertigationWidgetMode;
        });
      }
    });
    getData();
    super.initState();
  }

  void getData() async {
    print("getData");
    // print('//////////////////////////////////////////get function called//////////////////////////');
    if (payloadProvider.timerForIrrigationPump != null) {
      setState(() {
        payloadProvider.timerForIrrigationPump!.cancel();
        payloadProvider.timerForSourcePump!.cancel();
        payloadProvider.timerForCentralFiltration!.cancel();
        payloadProvider.timerForLocalFiltration!.cancel();
        payloadProvider.timerForCentralFertigation!.cancel();
        payloadProvider.timerForLocalFertigation!.cancel();
        payloadProvider.timerForCurrentSchedule!.cancel();
      });
    }
    // payloadProvider.clearData();
    final prefs = await SharedPreferences.getInstance();
    final userIdFromPref = prefs.getString('userId') ?? '';
    // payloadProvider.editLoading(true);
    try
    {
      final Repository repository = Repository(HttpService());
      var getUserDetails = await repository.fetchAllMySite({
        'userId': 8,
      });

      // final jsonData = jsonDecode(getUserDetails.body);
      final jsonData = newlivedata;
      if (jsonData['code'] == 200) {
        await payloadProvider.updateDashboardPayload(jsonData);
        setState(() {
          liveData = payloadProvider.dashboardLiveInstance!.data;
          overAllPvd.editControllerType(
              (!overAllPvd.takeSharedUserId
                  ? liveData[payloadProvider
                  .selectedSite]
                  .master[payloadProvider
                  .selectedMaster]
                  .categoryId
                  : payloadProvider
                  .listOfSharedUser[
              'devices'][
              payloadProvider
                  .selectedMaster]
              ['categoryId']));
        });
      }
      payloadProvider.httpError = false;
    } catch (e, stackTrace) {
      payloadProvider.httpError = true;
      print(' Error overAll getData => ${e.toString()}');
      print(' trace overAll getData  => ${stackTrace}');
    }
  }

  void mqttConfigureAndConnect() {
    MqttPayloadProvider payloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: false);
    manager.initializeMQTTClient();
    manager.connect();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }

  dynamic getPublishMessage() {
    dynamic refersh = '';
    if (![3, 4].contains(!overAllPvd.takeSharedUserId
        ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master']
            [payloadProvider.selectedMaster]['categoryId']
        : payloadProvider.listOfSharedUser['devices']
            [payloadProvider.selectedMaster]['categoryId'])) {
      refersh = jsonEncode({
        "3000": [
          {"3001": ""}
        ]
      });
    } else {
      refersh = jsonEncode({"sentSms": "#live"});
      if (mounted) {
        setState(() {
          payloadProvider.dataFetchingStatus = 2;
        });
        Future.delayed(const Duration(seconds: 10), () {
          if (payloadProvider.dataFetchingStatus != 1) {
            setState(() {
              payloadProvider.dataFetchingStatus = 3;
            });
          }
        });
      }
    }
    return refersh;
  }

  dynamic getLinePauseResumeMessage(code) {
    var lineMessage = '';
    switch (code) {
      case (0):
        {
          lineMessage = '';
        }
      case (1):
        {
          lineMessage = 'Paused Manually';
        }
      case (2):
        {
          lineMessage = 'Scheduled Program Paused By StandAlone Program';
        }
      case (3):
        {
          lineMessage = 'Paused By System Definition';
        }
      case (4):
        {
          lineMessage = 'Paused By LowFlow Alarm';
        }
      case (5):
        {
          lineMessage = 'Paused By HighFlow Alarm';
        }
      case (6):
        {
          lineMessage = 'Paused By NoFlow Alarm';
        }
      case (7):
        {
          lineMessage = 'Paused By EcHigh';
        }
      case (8):
        {
          lineMessage = 'Paused By PhLow';
        }
      case (9):
        {
          lineMessage = 'Paused By PhHigh';
        }
      case (10):
        {
          lineMessage = 'Paused By PressureLow';
        }
      case (11):
        {
          lineMessage = 'Paused By PressureHigh';
        }
      case (12):
        {
          lineMessage = 'Paused By No Power Supply';
        }
      case (13):
        {
          lineMessage = 'Paused By No Communication';
        }
    }
    return lineMessage;
  }

  @override
  Widget build(BuildContext context) {
    // print("sourcePumpMode$sourcePumpMode");
    var selectedSite = liveData?[payloadProvider.selectedSite];
    var selectedMaster = liveData?[payloadProvider.selectedSite].master[payloadProvider.selectedMaster];
    var selectedLine = liveData?[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].config.lineData[payloadProvider.selectedLine];
    var selectedfiltersite = liveData?[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].config.filterSite;
    var selectedfertilizer = liveData?[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].config.lineData[payloadProvider.selectedLine];
    return ((liveData != null))
        ? Scaffold(
            body: SafeArea(
                child: Center(
                    child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: () {
                              if (overAllPvd.fromDealer) {
                                // MqttManager().onDisconnected();
                                Future.delayed(Duration.zero, () {
                                  payloadProvider.clearData();
                                  overAllPvd.userId = 0;
                                  overAllPvd.controllerId = 0;
                                  overAllPvd.controllerType = 0;
                                  overAllPvd.imeiNo = '';
                                  overAllPvd.customerId = 0;
                                  overAllPvd.sharedUserId = 0;
                                  overAllPvd.takeSharedUserId = false;
                                });
                                Navigator.of(context).pop();
                              } else {
                                _scaffoldKey.currentState?.openDrawer();
                              }
                            },
                            icon: Icon(
                              !overAllPvd.fromDealer
                                  ? Icons.menu
                                  : Icons.arrow_back,
                              size: 25,
                            )),
                        InkWell(
                          onTap: () {
                            // print('liveData!!.length: ${liveData!.length}');
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(builder:
                                      (context, StateSetter stateSetter) {
                                    return Container(
                                      height: 400,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20))),
                                      child: Column(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'List of Site',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  for (var site = 0;
                                                      site < liveData!.length; site++)
                                                    ListTile(
                                                      title: Text(liveData[site]
                                                              .groupName ??
                                                          ''),
                                                      trailing: IntrinsicWidth(
                                                        child: Radio(
                                                          value: 'site-${site}',
                                                          groupValue: payloadProvider.selectedSiteString,
                                                          onChanged: (value) {
                                                            stateSetter(() {
                                                              setState(() {
                                                                var unSubscribeTopic = 'FirmwareToApp/${overAllPvd.imeiNo}';
                                                                payloadProvider.selectedSite =site;
                                                                payloadProvider.selectedSiteString = value!;
                                                                payloadProvider.selectedMaster = 0;
                                                                overAllPvd.takeSharedUserId = false;
                                                                Master selectedMasterData = liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster];
                                                                overAllPvd.imeiNo =selectedMasterData.deviceId;
                                                                overAllPvd.controllerId =selectedMasterData.controllerId;
                                                                overAllPvd.controllerType =selectedMasterData.categoryId;
                                                                /*if(selectedMasterData.config!.irrigationLine != null){
                                                            payloadProvider.editLineData(selectedMasterData.config!.irrigationLine);
                                                          }*/
                                                                manager.topicToUnSubscribe(unSubscribeTopic);

                                                                print("controllerType ==> ${overAllPvd.controllerType}");
                                                                payloadProvider.updateReceivedPayload2(
                                                                    jsonEncode([
                                                                      3,
                                                                      4
                                                                    ].contains(overAllPvd.controllerType)
                                                                        ? {
                                                                            "mC":
                                                                                "LD01",
                                                                            'cM':
                                                                                "selectedMasterData['liveMessage']"
                                                                          }
                                                                        : jsonEncode(selectedMasterData)),
                                                                    true);
                                                                if ([
                                                                  3,
                                                                  4
                                                                ].contains(
                                                                    overAllPvd
                                                                        .controllerType)) {
                                                                  if (payloadProvider
                                                                          .dataFetchingStatus !=
                                                                      1) {
                                                                    // payloadProvider.lastUpdate = DateTime.parse("${selectedMasterData['liveSyncDate']} ${selectedMasterData['liveSyncTime']}");
                                                                    payloadProvider
                                                                            .lastUpdate =
                                                                        DateTime.parse(
                                                                            "12-01-2025 00:00:00}");
                                                                  }
                                                                }
                                                                manager.topicToSubscribe(
                                                                    'FirmwareToApp/${overAllPvd.imeiNo}');

                                                                Future.delayed(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                    () {
                                                                  Navigator.pop(
                                                                      context);
                                                                });
                                                              });
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  if (payloadProvider.listOfSharedUser.isNotEmpty)
                                                    for (var sharedUser = 0; sharedUser < payloadProvider.listOfSharedUser['users'].length; sharedUser++)
                                                      if (payloadProvider.listOfSharedUser['devices'].isNotEmpty)
                                                        ListTile(
                                                          title: Text(payloadProvider
                                                                          .listOfSharedUser[
                                                                      'users']
                                                                  [sharedUser]
                                                              ['userName']),
                                                          trailing:
                                                              IntrinsicWidth(
                                                            child: Radio(
                                                              value:
                                                                  'sharedUser-${sharedUser}',
                                                              groupValue:
                                                                  payloadProvider
                                                                      .selectedSiteString,
                                                              onChanged:
                                                                  (value) async {
                                                                try {
                                                                  HttpService
                                                                      service =
                                                                      HttpService();
                                                                  var getSharedUserDetails =
                                                                      await service
                                                                          .postRequest(
                                                                              'getSharedUserDeviceList',
                                                                              {
                                                                        'userId':
                                                                            overAllPvd.userId,
                                                                        "sharedUser":
                                                                            payloadProvider.listOfSharedUser['users'][sharedUser]['userId']
                                                                      });
                                                                  stateSetter(
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      var unSubscribeTopic =
                                                                          'FirmwareToApp/${overAllPvd.imeiNo}';
                                                                      payloadProvider
                                                                              .selectedSite =
                                                                          sharedUser;
                                                                      payloadProvider
                                                                              .selectedSiteString =
                                                                          value!;
                                                                      payloadProvider
                                                                          .selectedMaster = 0;
                                                                      var jsonDataSharedDevice =
                                                                          jsonDecode(
                                                                              getSharedUserDetails.body);
                                                                      // print('code is =======================       ${jsonDataSharedDevice['code']}      ========================');
                                                                      if (jsonDataSharedDevice[
                                                                              'code'] ==
                                                                          200) {
                                                                        payloadProvider.listOfSharedUser =
                                                                            jsonDataSharedDevice['data'];
                                                                        // print('getSharedUserDeviceList : ${payloadProvider.listOfSharedUser}');
                                                                        if (payloadProvider
                                                                            .listOfSharedUser['devices']
                                                                            .isNotEmpty) {
                                                                          setState(
                                                                              () {
                                                                            payloadProvider.selectedMaster =
                                                                                0;
                                                                            var imeiNo =
                                                                                payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceId'];
                                                                            var controllerId =
                                                                                payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['controllerId'];
                                                                            overAllPvd.sharedUserId =
                                                                                jsonDataSharedDevice['data']['users'][0]['userId'];
                                                                            overAllPvd.takeSharedUserId =
                                                                                true;
                                                                            overAllPvd.imeiNo =
                                                                                imeiNo;
                                                                            overAllPvd.controllerId =
                                                                                controllerId;
                                                                            overAllPvd.controllerType =
                                                                                payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['categoryId'];
                                                                            if (payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['irrigationLine'] !=
                                                                                null) {
                                                                              payloadProvider.editLineData(payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['irrigationLine']);
                                                                            }
                                                                            payloadProvider.updateReceivedPayload2(
                                                                                jsonEncode([3, 4].contains(overAllPvd.controllerType)
                                                                                    ? {
                                                                                        "mC": "LD01",
                                                                                        'cM': payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['liveMessage']
                                                                                      }
                                                                                    : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]),
                                                                                true);
                                                                            if ([
                                                                              3,
                                                                              4
                                                                            ].contains(overAllPvd.controllerType)) {
                                                                              if (payloadProvider.dataFetchingStatus != 1) {
                                                                                payloadProvider.lastUpdate = DateTime.parse("${payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['liveSyncDate']} ${payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['liveSyncTime']}");
                                                                              }
                                                                            }
                                                                            payloadProvider.editSubscribeTopic('FirmwareToApp/$imeiNo');
                                                                            payloadProvider.editPublishTopic('AppToFirmware/$imeiNo');
                                                                            payloadProvider.editPublishMessage(getPublishMessage());
                                                                            manager.topicToUnSubscribe(unSubscribeTopic);
                                                                            manager.topicToSubscribe('FirmwareToApp/${overAllPvd.imeiNo}');
                                                                            Future.delayed(const Duration(milliseconds: 300),
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            });
                                                                          });
                                                                          for (var i = 0;
                                                                              i < 2;
                                                                              i++) {
                                                                            Future.delayed(const Duration(seconds: 3),
                                                                                () {
                                                                              autoRefresh();
                                                                            });
                                                                          }
                                                                        }
                                                                      }
                                                                      overAllPvd.editImeiNo(payloadProvider
                                                                              .listOfSharedUser['devices']
                                                                          [
                                                                          payloadProvider
                                                                              .selectedMaster]['deviceId']);
                                                                      overAllPvd.editControllerId(payloadProvider
                                                                              .listOfSharedUser['devices']
                                                                          [
                                                                          payloadProvider
                                                                              .selectedMaster]['controllerId']);
                                                                      overAllPvd.editControllerType(payloadProvider
                                                                              .listOfSharedUser['devices']
                                                                          [
                                                                          payloadProvider
                                                                              .selectedMaster]['categoryId']);
                                                                    });
                                                                  });
                                                                } catch (e, stackTrace) {
                                                                  setState(() {
                                                                    payloadProvider
                                                                            .httpError =
                                                                        true;
                                                                  });
                                                                  print(
                                                                      ' Site selecting Error getSharedUserDeviceList  => ${e.toString()}');
                                                                  print(
                                                                      ' Site selecting trace getSharedUserDeviceList  => ${stackTrace}');
                                                                }
                                                                // print('after => ${overAllPvd.userId}');
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                                });
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${!overAllPvd.takeSharedUserId ? liveData![0].groupName : 'test'}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Last Sync : \n${payloadProvider.lastUpdate.day}/${payloadProvider.lastUpdate.month}/${payloadProvider.lastUpdate.year} ${payloadProvider.lastUpdate.hour}:${payloadProvider.lastUpdate.minute}:${payloadProvider.lastUpdate.second}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Colors.black,
                                          fontSize: 12,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    width: 15,
                                    child: Icon(Icons.arrow_drop_down_sharp))
                              ],
                            ),
                          ),
                        ),
                        if (payloadProvider.currentSchedule.isNotEmpty)
                          if (payloadProvider.currentSchedule.any((element) =>
                              !element['ProgName'].contains('StandAlone')))
                            Row(
                              children: [
                                getActiveObjects(
                                    context: context,
                                    active: payloadProvider.active == 1
                                        ? true
                                        : false,
                                    title: 'All',
                                    onTap: () {
                                      setState(() {
                                        payloadProvider.active = 1;
                                      });
                                    },
                                    mode: payloadProvider.active),
                                getActiveObjects(
                                    context: context,
                                    active: payloadProvider.active == 2
                                        ? true
                                        : false,
                                    title: 'Active',
                                    onTap: () {
                                      setState(() {
                                        payloadProvider.active = 2;
                                      });
                                    },
                                    mode: payloadProvider.active),
                              ],
                            ),

                        // Modified by saravanan
                        buildPopUpMenuButton(
                            context: context,
                            dataList: ([1, 2].contains(overAllPvd.controllerType) && overAllPvd.fromDealer)
                                ? [
                                    "Standalone",
                                    "Node status",
                                    "Node details",
                                    "Sent and Received",
                                    "Controller Info"
                                  ]
                                : [1, 2].contains(overAllPvd.controllerType)
                                    ? [
                                        "Standalone",
                                        "Node status",
                                        "Node details"
                                      ]
                                    : ["Sent and Received", "Controller Info"],
                            onSelected: (newValue) {
                              if (newValue == "Standalone") {
                                showGeneralDialog(
                                  barrierLabel: "Side sheet",
                                  barrierDismissible: true,
                                  // barrierColor: const Color(0xff6600),
                                  transitionDuration:
                                      const Duration(milliseconds: 300),
                                  context: context,
                                  pageBuilder:
                                      (context, animation1, animation2) {
                                    return Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        // child: ManualOperationScreen(userId: overAllPvd.userId, controllerId: overAllPvd.controllerId, customerId: overAllPvd.customerId, deviceId: overAllPvd.imeiNo,)
                                      ),
                                    );
                                  },
                                  transitionBuilder:
                                      (context, animation1, animation2, child) {
                                    return SlideTransition(
                                      position: Tween(
                                              begin: const Offset(1, 0),
                                              end: const Offset(0, 0))
                                          .animate(animation1),
                                      child: child,
                                    );
                                  },
                                );
                              }
                              // else if(newValue == "Node status") {
                              //   showGeneralDialog(
                              //     barrierLabel: "Side sheet",
                              //     barrierDismissible: true,
                              //     barrierColor: const Color(0xff66000000),
                              //     transitionDuration: const Duration(milliseconds: 300),
                              //     context: context,
                              //     pageBuilder: (context, animation1, animation2) {
                              //       return Align(
                              //         alignment: Alignment.centerRight,
                              //         child: Material(
                              //           elevation: 15,
                              //           color: Colors.transparent,
                              //           borderRadius: BorderRadius.zero,
                              //           child: Consumer<MqttPayloadProvider>(
                              //               builder: (context, mqttPayloadProvider, _) {
                              //                 return NodeStatus();
                              //               }
                              //           ),
                              //         ),
                              //       );
                              //     },
                              //     transitionBuilder: (context, animation1, animation2, child) {
                              //       return SlideTransition(
                              //         position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
                              //         child: child,
                              //       );
                              //     },
                              //   );
                              // }
                              else if (newValue == "Node details") {
                                // showNodeDetailsBottomSheet(context: context);
                              } else if (newValue == "Sent and Received") {
                                // Navigator.push(context, MaterialPageRoute(builder: (context) => SentAndReceived()));
                              } else if (newValue == "Controller Info") {
                                showPasswordDialog(context, _correctPassword);
                              }
                            },
                            child: ([1, 2].contains(overAllPvd.controllerType) || overAllPvd.fromDealer)
                                ? const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Icon(Icons.more_vert),
                                  )
                                : ![1, 2].contains(overAllPvd.controllerType)
                                    ? Container()
                                    : Container())
                      ],
                    ),
                    (payloadProvider.listOfSite.isNotEmpty ? liveData![payloadProvider.selectedSite].master.length > 1 || [1, 2].contains(overAllPvd.controllerType) : true)
                        ? Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20)),
                              // boxShadow: customBoxShadow
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(context).primaryColor),
                                  child: PopupMenuButton<int>(
                                    offset: const Offset(0, 50),
                                    initialValue:
                                        payloadProvider.selectedMaster,
                                    onSelected: (int master) {
                                      setState(() {
                                        payloadProvider.selectedMaster = master;
                                      });
                                    },
                                    //every ternary operator  ? user device : sharedevice details
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<int>>[
                                      for (var master = 0;
                                          master < (!overAllPvd.takeSharedUserId ? liveData[payloadProvider.selectedSite].master : liveData).length;master++)
                                        PopupMenuItem<int>(
                                          value: master,
                                          child: Text(!overAllPvd
                                                  .takeSharedUserId
                                              ? '${liveData[payloadProvider.selectedSite].master[master].deviceName ?? ''}\n${liveData[payloadProvider.selectedSite].master[master].deviceId} ${[
                                                  1,
                                                  2
                                                ].contains(liveData[payloadProvider.selectedSite].master[master].categoryId) ? '(version : ${payloadProvider.version})' : ''}'
                                              : '${liveData[payloadProvider.selectedSite].master[master].deviceName ?? ''}\n ${[
                                                  1,
                                                  2
                                                ].contains(liveData[payloadProvider.selectedSite].master[master].categoryId ?? '') ? '(version : ${payloadProvider.version})' : ''}'),
                                          onTap: () async {
                                            var unSubscribeTopic = 'FirmwareToApp/${overAllPvd.imeiNo}';
                                            payloadProvider.selectedMaster = master;
                                            overAllPvd.editImeiNo((!overAllPvd.takeSharedUserId ? liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].deviceName : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['deviceId']));
                                            overAllPvd.editControllerType((!overAllPvd.takeSharedUserId
                                                    ? liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].categoryId  : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['categoryId']));
                                            overAllPvd.editControllerId(
                                                (!overAllPvd.takeSharedUserId ? liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].controllerId
                                                    : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['controllerId']));
                                            var selectedMaster = !overAllPvd.takeSharedUserId
                                                ? liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster]
                                                : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster];

                                            manager.topicToUnSubscribe('FirmwareToApp/${overAllPvd.imeiNo}');

                                            payloadProvider.updateReceivedPayload2(jsonEncode([3, 4].contains(overAllPvd.controllerType)
                                                        ? {"mC": "LD01", 'cM': selectedMaster['liveMessage']}
                                                        : jsonEncode(selectedMaster)), true);
                                            if ([3, 4].contains(overAllPvd.controllerType)) {
                                              payloadProvider.lastUpdate = DateTime.parse(
                                                      "${selectedMaster['liveSyncDate']}${selectedMaster['liveSyncTime']}");
                                            }
                                            for (var i = 0; i < 1; i++) {
                                              await Future.delayed(
                                                  const Duration(seconds: 3));
                                              autoRefresh();
                                            }
                                          },
                                        ),
                                    ],
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Image.asset(
                                              'assets/png_images/choose_controller.png'),
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.3,
                                              //                 liveData!![payloadProvider.selectedSite].master![payloadProvider.selectedMaster]
                                              child: Text(
                                                '${(!overAllPvd.takeSharedUserId ? liveData![payloadProvider.selectedSite].master[payloadProvider.selectedMaster].config.lineData[payloadProvider.selectedLine].name : liveData![payloadProvider.selectedSite].master[payloadProvider.selectedMaster].deviceName)}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.wifi,
                                                  color: Colors.orange,
                                                  size: 20,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  '${payloadProvider.wifiStrength}',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (![3, 4].contains(overAllPvd.controllerType))
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white),
                                    child: PopupMenuButton<int>(
                                      offset: const Offset(0, 50),
                                      initialValue:
                                          payloadProvider.selectedLine,
                                      onSelected: (int line) {
                                        setState(() {
                                          payloadProvider.selectedLine = line;
                                        });
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<int>>[
                                        for (var line = 0;
                                            line <
                                                liveData[payloadProvider
                                                        .selectedSite]
                                                    .master[payloadProvider
                                                        .selectedMaster]
                                                    .config
                                                    .lineData
                                                    .length;
                                            line++)
                                          PopupMenuItem<int>(
                                            value: line,
                                            child: Row(
                                              children: [
                                                Text(
                                                    '${liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].config.lineData[line].name}'),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                if (payloadProvider
                                                            .lineData[line]
                                                        ['mode'] !=
                                                    0)
                                                  const Icon(
                                                    Icons.info,
                                                    color: Colors.red,
                                                  )
                                              ],
                                            ),
                                            onTap: () {
                                              setState(() {
                                                payloadProvider.selectedLine =
                                                    line;
                                              });
                                            },
                                          ),
                                      ],
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            height: 30,
                                            child: Image.asset(
                                                'assets/png_images/irrigation_line1.png'),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                              child: Text(
                                                '${liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].config.lineData[0].name}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              )),
                                          if (payloadProvider.lineData
                                              .any((line) => line['mode'] != 0))
                                            const Icon(Icons.info, color: Colors.red,)
                                        ],
                                      ),
                                    ),
                                  ),
                                if (![3, 4].contains(overAllPvd.controllerType))
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Consumer<MqttPayloadProvider>(
                                            builder: (context, payloadProvider,
                                                child) {
                                              return Container(
                                                height: 300,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                            'Alarms',
                                                            style: TextStyle(
                                                                fontSize: 20),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          onPressed: () {
                                                            // Close the bottom sheet
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          icon: const Icon(
                                                              Icons.cancel),
                                                        ),
                                                      ],
                                                    ),
                                                    for (var alarm = 0;
                                                        alarm <
                                                            payloadProvider
                                                                .alarmList
                                                                .length;
                                                        alarm++)
                                                      ListTile(
                                                        title: Text(
                                                            '${getAlarmMessage[payloadProvider.alarmList[alarm]['AlarmType']]}'),
                                                        subtitle: Text(
                                                            'Location : ${payloadProvider.alarmList[alarm]['Location']}'),
                                                        trailing: (overAllPvd
                                                                    .takeSharedUserId
                                                                ? (payloadProvider
                                                                            .userPermission[0]
                                                                        [
                                                                        'status'] ||
                                                                    payloadProvider
                                                                            .userPermission[5]
                                                                        [
                                                                        'status'])
                                                                : true)
                                                            ? MaterialButton(
                                                                color: payloadProvider.alarmList[alarm]
                                                                            [
                                                                            'Status'] ==
                                                                        1
                                                                    ? Colors
                                                                        .orange
                                                                    : Colors
                                                                        .red,
                                                                onPressed:
                                                                    () {},
                                                                // onPressed: DashboardPayloadHandler(manager: manager, payloadProvider: payloadProvider, overAllPvd: overAllPvd, setState: setState, context: context,index: alarm).alarmReset,
                                                                // onPressed: () {
                                                                //   String payload =  '${i['S_No']}';
                                                                //   String payLoadFinal = jsonEncode({
                                                                //     "4100": [{"4101": payload}]
                                                                //   });
                                                                //   MqttManager().publish(payLoadFinal, payloadProvider.publishTopic);
                                                                // },
                                                                child:
                                                                    const Text(
                                                                  'Reset',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              )
                                                            : null,
                                                      )
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          const Icon(
                                            Icons.notifications,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                          if (payloadProvider
                                              .alarmList.isNotEmpty)
                                            const Positioned(
                                              top: 0,
                                              left: 10,
                                              child: CircleAvatar(
                                                radius: 8,
                                                backgroundColor: Colors.red,
                                                child: Center(
                                                    child: Text(
                                                  '1',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12),
                                                )),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: onRefresh,
                    child: [1, 2].contains(overAllPvd.controllerType)
                        ? SingleChildScrollView(
                            child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(30),
                                  topLeft: Radius.circular(30)),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (payloadProvider.tryingToGetPayload > 3)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.red),child: const Center(child: Text('Please Check Internet In Your Controller.....',style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold),),
                                    ),
                                  ),
                                // if(payloadProvider.powerSupply == 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.deepOrange),
                                  child: Center(
                                    child: Text(
                                        'No Power To ${!overAllPvd.takeSharedUserId ? liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].deviceName : liveData[payloadProvider.selectedSite].master[payloadProvider.selectedMaster].deviceName}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                // if(![3,4].contains(overAllPvd.controllerType))
                                ListTile(
                                  leading: SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Image.asset(
                                        'assets/png_images/irrigation_line1.png'),
                                  ),
                                  subtitle: getLinePauseResumeMessage(selectedLine!.sNo) == ''
                                      ? null
                                      : Text(
                                          '${getLinePauseResumeMessage(selectedLine!.sNo)}',
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                        ),
                                  title: Text(
                                    '${selectedLine!.name}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black),
                                  ),
                                  trailing: ([0, 1].contains(selectedLine) && (overAllPvd.takeSharedUserId ? (payloadProvider.userPermission[0]['status'] || payloadProvider.userPermission[4]['status']) : true))
                                      ? MaterialButton(
                                          color: selectedLine.sNo == 0
                                              ? Colors.orange
                                              : Colors.yellow,
                                          onPressed: () {},
                                          // onPressed: DashboardPayloadHandler(manager: manager, payloadProvider: payloadProvider, overAllPvd: overAllPvd, setState: setState, context: context).irrigationLinePauseResume,
                                          child: Text(
                                            selectedLine.sNo == 0
                                                ? 'Pause'
                                                : 'Resume',
                                            style: TextStyle(
                                                color: selectedLine!.sNo == 0
                                                    ? Colors.white
                                                    : Colors.black),
                                          )
                                          // : loadingButton(),
                                          )
                                      : null,
                                  // subtitle: Text("subtile"),
                                  // title: Text("title"),
                                  // trailing: Text("trailing"),
                                ),
                                if ([3, 4].contains(overAllPvd.controllerType))
                                  Container(color: Colors.red,child: Text("PumpControllerDashboard",style: TextStyle(color: Colors.white),),) //  PumpControllerDashboard(userId: overAllPvd.takeSharedUserId ? overAllPvd.sharedUserId : userId, deviceId: overAllPvd.imeiNo, controllerId: overAllPvd.controllerId, selectedSite: payloadProvider.selectedSite, selectedMaster: payloadProvider.selectedMaster,)
                                else
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // WaterSourceDashBoard(waterSource: liveData[payloadProvider.selectedMaster].master[payloadProvider.selectedMaster].config.waterSource),
                                   if (sourcePumpMode)
                                        SourceTypeDashBoardTrue(active: payloadProvider.active, selectedLine: payloadProvider.selectedLine,imeiNo: overAllPvd.imeiNo,)
                                      else
                                        SourceTypeDashBoardFalse(active: payloadProvider.active, selectedLine:payloadProvider.selectedLine,imeiNo: overAllPvd.imeiNo,),
                                    if (irrigationPumpMode)
                                        IrrigationPumpDashBoardTrue(active: payloadProvider.active, selectedLine: payloadProvider.selectedLine,imeiNo: overAllPvd.imeiNo,)
                                      else
                                        IrrigationPumpDashBoardFalse(active: payloadProvider.active, selectedLine: payloadProvider.selectedLine, imeiNo: overAllPvd.imeiNo,  ),
                                      for (var i = 0;i < payloadProvider.filtersCentral.length;i++)
                                        filterFertilizerLineFiltering(active: payloadProvider.active,  siteIndex: i,  selectedLine:  payloadProvider.selectedLine, programName: 'program', siteData: payloadProvider.filtersCentral[i],centralOrLocal: 1,filter_Fertilizer_line: 1),
                                      for (var i = 0;i < payloadProvider.filtersLocal.length;i++)
                                        filterFertilizerLineFiltering(active: payloadProvider.active,siteIndex: i,selectedLine: payloadProvider.selectedLine,programName: 'Program',siteData:payloadProvider.filtersLocal[i],centralOrLocal: 2, filter_Fertilizer_line: 1),
                                      for (var i = 0;i < payloadProvider.fertilizerCentral.length;i++)
                                        filterFertilizerLineFiltering( active: payloadProvider.active,  siteIndex: i, selectedLine: payloadProvider.selectedLine, programName: 'Program', siteData: payloadProvider.fertilizerCentral[i],centralOrLocal: 1,filter_Fertilizer_line: 2),
                                      for (var i = 0;i <payloadProvider.fertilizerLocal.length;i++)
                                        filterFertilizerLineFiltering(active: payloadProvider.active, siteIndex: i, selectedLine: payloadProvider.selectedLine, programName: 'Program', siteData: payloadProvider .fertilizerLocal[i], centralOrLocal: 2, filter_Fertilizer_line: 2),
                                      for (var line = 1;line < payloadProvider.lineData.length;line++)
                                        if (payloadProvider.selectedLine == 0 || line ==  payloadProvider.selectedLine)
                                          if (irrigationLineMode)
                                           IrrigationLineTrue(active: payloadProvider.active, selectedLine: payloadProvider.selectedLine, currentLine: line, payloadProvider: payloadProvider)
                                          else
                                         IrrigationLineFalse(active: payloadProvider.active, selectedLine: payloadProvider.selectedLine, currentLine: line, payloadProvider: payloadProvider),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.3,
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ))
                        : Container(
                      color: Colors.red,
                            child: Text(" PumpControllerDashboard",style: TextStyle(color: Colors.white),),
                          ), // PumpControllerDashboard(userId: overAllPvd.takeSharedUserId ? overAllPvd.sharedUserId : userId, deviceId: overAllPvd.imeiNo, controllerId: overAllPvd.controllerId, selectedSite: payloadProvider.selectedSite, selectedMaster: payloadProvider.selectedMaster,),
                  ),
                ),
              ],
            ))),
          )
        : const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget getActiveObjects(
      {required BuildContext context,
      required bool active,
      required String title,
      required Function()? onTap,
      required int mode})
  {
    List<Color> gradient = active == true
        ? [const Color(0xff22414C), const Color(0xff294C5C)]
        : [];
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        height: (30 * getTextScaleFactor(context)).toDouble(),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(mode == 1 ? 4 : 0),
              bottomLeft: Radius.circular(mode == 1 ? 4 : 0),
              topRight: Radius.circular(mode == 2 ? 4 : 0),
              bottomRight: Radius.circular(mode == 2 ? 4 : 0),
            ),
            gradient: active == true
                ? LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: gradient,
                  )
                : null,
            color: active == false ? const Color(0xffECECEC) : null),
        child: Center(
            child: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active == true ? Colors.white : Colors.black),
        )),
      ),
    );
  }

  int getFilter(filterStatus, BuildContext context, programStatus)
  {
    int mode = 0;
    if (filterStatus == 1) {
      mode = 1;
    } else if (filterStatus == 2) {
      mode = 2;
    }
    // else if(getWaterPipeStatus(context) == 0){
    //   mode = 0;
    // }
    else if (filterStatus == 0) {
      mode = 3;
    }
    if (programStatus == '') {
      mode = 0;
    }
    return mode;
  }

  void autoRefresh() async
  {
    // manager.subscribeToTopic('FirmwareToApp/${overAllPvd.imeiNo}');
    // manager.publish(payloadProvider.publishMessage,'AppToFirmware/${overAllPvd.imeiNo}');
    // setState(() {
    //   payloadProvider.tryingToGetPayload += 1;
    // });
  }
  Future onRefresh() async
  {
    if (manager.isConnected) {
      autoRefresh();
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(seconds: 5));
  }

  getTextScaleFactor(context)
  {
    return MediaQuery.of(context).textScaleFactor;
  }

  Widget loadingButton() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: const LoadingIndicator(
        colors: [
          Colors.white,
          Colors.white,
        ],
        indicatorType: Indicator.ballPulse,
      ),
    );
  }

  Widget filterFertilizerLineFiltering({
    required int active,
    required int siteIndex,
    required int selectedLine,
    required int centralOrLocal,
    required int filter_Fertilizer_line,
    required String programName,
    required dynamic siteData,
    dynamic currentLine,
  })
  {
    MqttPayloadProvider payloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: false);
    Widget filterWidget = Container();
    Widget fertilizerWidget = Container();
    // Widget filterWidget = filtrationWidgetMode
    //     ? FiltrationSiteTrue(siteIndex: siteIndex, centralOrLocal: centralOrLocal, selectedLine: selectedLine,)
    //     : FiltrationSiteFalse(siteIndex: siteIndex, centralOrLocal: centralOrLocal, selectedLine: selectedLine,);
    // Widget fertilizerWidget = fertigationWidgetMode
    //     ? FertilizerSiteTrue(siteIndex: siteIndex, centralOrLocal: centralOrLocal,selectedLine: selectedLine,)
    //     : FertilizerSiteFalse(siteIndex: siteIndex, centralOrLocal: centralOrLocal,selectedLine: selectedLine,);
    Widget widget = Container();
    if (active == 1 && selectedLine == 0) {
      widget = filter_Fertilizer_line == 1 ? filterWidget : fertilizerWidget;
    } else if (active == 1 &&
        selectedLine != 0 &&
        (siteData['Location'] ?? siteData['Line'])
            .contains(payloadProvider.lineData[selectedLine]['id'])) {
      widget = filter_Fertilizer_line == 1 ? filterWidget : fertilizerWidget;
    } else if (active == 2 && programName != '' && selectedLine == 0) {
      widget = filter_Fertilizer_line == 1 ? filterWidget : fertilizerWidget;
    } else if (active == 2 &&
        programName != '' &&
        selectedLine != 0 &&
        (siteData['Location'] ?? siteData['Line'])
            .contains(payloadProvider.lineData[selectedLine]['id'])) {
      widget = filter_Fertilizer_line == 1 ? filterWidget : fertilizerWidget;
    }
    return widget;
  }

  void sideSheet(
      {required MqttPayloadProvider payloadProvider,
      required selectedTab,
      required OverAllUse overAllPvd})
  {
    showGeneralDialog(
      barrierLabel: "Side sheet",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 300),
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            elevation: 15,
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Scaffold(
                    floatingActionButton: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white, boxShadow: customBoxShadow),
                        height: 60,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.keyboard_double_arrow_left),
                            Text('Go Back'),
                          ],
                        ),
                      ),
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerDocked,
                    body: Container(
                      padding: const EdgeInsets.all(3),
                      // margin: EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.zero,
                      ),
                      height: double.infinity,
                      width: MediaQuery.of(context).size.width,
                      child: const SingleChildScrollView(
                          // child: Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     if(selectedTab == 0)
                          //       CurrentScheduleForMobile(manager: manager, deviceId: '${overAllPvd.imeiNo}',),
                          //     if(selectedTab == 1)
                          //       NextScheduleForMobile(),
                          //     if(selectedTab == 2)
                          //       ScheduleProgramForMobile(manager: manager, deviceId: '${overAllPvd.imeiNo}', selectedLine: payloadProvider.selectedLine, userId: overAllPvd.userId, controllerId: overAllPvd.controllerId,),
                          //   ],
                          // ),
                          ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0))
              .animate(animation1),
          child: child,
        );
      },
    );
  }
}

Widget getLoadingWidget(
    {required BuildContext context, required double controllerValue})
{
  return Container(
    color: Colors.white,
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Text(
          'Loading....',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
        Transform.rotate(
          angle: 6.28 * controllerValue,
          child: const Icon(
            Icons.hourglass_bottom,
            color: Colors.black,
          ),
        )
      ],
    ),
  );
}

void showPasswordDialog(BuildContext context, correctPassword) {
  final TextEditingController _passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter Password'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final enteredPassword = _passwordController.text;

              if (enteredPassword == correctPassword) {
                Navigator.of(context).pop(); // Close the dialog
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => ResetVerssion()),
                // );
              } else {
                Navigator.of(context).pop(); // Close the dialog
                showErrorDialog(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}

void showErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text('Incorrect password. Please try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void stayAlert(
    {required BuildContext context,
    required MqttPayloadProvider payloadProvider,
    required String message}) {
  GlobalSnackBar.show(
      context, message, int.parse(payloadProvider.messageFromHw['Code']));
  // showDialog(context: context, builder: (context){
  //   return AlertDialog(
  //     title: Text('Message From Hardware'),
  //     content: Text('${payloadProvider.messageFromHw}'),
  //     actions: [
  //       TextButton(
  //           onPressed: (){
  //             Navigator.pop(context);
  //           },
  //           child: Text('OK')
  //       )
  //     ],
  //   );
  // });
}

class Pump extends CustomPainter {
  final double rotationAngle;
  final int mode;
  Pump({required this.rotationAngle, required this.mode});

  List<Color> pipeColor = const [
    Color(0xff166890),
    Color(0xff45C9FA),
    Color(0xff166890)
  ];
  List<Color> bodyColor = const [
    Color(0xffC7BEBE),
    Colors.white,
    Color(0xffC7BEBE)
  ];
  List<Color> headColorOn = const [
    Color(0xff097E54),
    Color(0xff10E196),
    Color(0xff097E54)
  ];
  List<Color> headColorOff = const [
    Color(0xff540000),
    Color(0xffB90000),
    Color(0xff540000)
  ];
  List<Color> headColorFault = const [
    Color(0xffF66E21),
    Color(0xffFFA06B),
    Color(0xffF66E21)
  ];
  List<Color> headColorIdle = [Colors.grey, Colors.grey.shade300, Colors.grey];

  List<Color> getMotorColor() {
    if (mode == 1) {
      return headColorOn;
    } else if (mode == 3) {
      return headColorOff;
    } else if (mode == 2) {
      return headColorFault;
    } else {
      return headColorIdle;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint motorHead = Paint();
    Radius headRadius = const Radius.circular(5);
    motorHead.color = const Color(0xff097B52);
    motorHead.style = PaintingStyle.fill;
    motorHead.shader = getLinearShaderHor(getMotorColor(),
        Rect.fromCenter(center: const Offset(50, 18), width: 35, height: 35));
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromCenter(
                center: const Offset(50, 20), width: 45, height: 40),
            topLeft: headRadius,
            topRight: headRadius,
            bottomRight: headRadius,
            bottomLeft: headRadius),
        motorHead);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromCenter(
                center: const Offset(50, 20), width: 45, height: 40),
            topLeft: headRadius,
            topRight: headRadius,
            bottomRight: headRadius,
            bottomLeft: headRadius),
        motorHead);
    Paint line = Paint();
    line.color = Colors.white;
    line.strokeWidth = 1;
    line.style = PaintingStyle.fill;
    double startingPosition = 26;
    double lineGap = 8;
    for (var i = 0; i < 7; i++)
      canvas.drawLine(Offset(startingPosition + (i * lineGap), 5),
          Offset(startingPosition + (i * lineGap), 35), line);
    canvas.drawLine(const Offset(28, 5), const Offset(72, 5), line);
    canvas.drawLine(const Offset(28, 35), const Offset(72, 35), line);

    Paint neck = Paint();
    neck.shader = getLinearShaderHor(bodyColor,
        Rect.fromCenter(center: const Offset(50, 45), width: 20, height: 10));
    neck.strokeWidth = 0.5;
    neck.style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromCenter(center: const Offset(50, 45), width: 20, height: 10),
        neck);

    Paint body = Paint();
    body.style = PaintingStyle.fill;
    body.shader = getLinearShaderHor(bodyColor,
        Rect.fromCenter(center: const Offset(50, 64), width: 35, height: 28));
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromCenter(
                center: const Offset(50, 64), width: 35, height: 28),
            topLeft: headRadius,
            topRight: headRadius,
            bottomRight: headRadius,
            bottomLeft: headRadius),
        body);

    Paint joint = Paint();
    joint.shader = getLinearShaderVert(bodyColor,
        Rect.fromCenter(center: const Offset(30, 64), width: 6, height: 15));
    joint.strokeWidth = 0.5;
    joint.style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromCenter(center: const Offset(30, 64), width: 6, height: 15),
        joint);
    canvas.drawRect(
        Rect.fromCenter(center: const Offset(70, 64), width: 6, height: 15),
        joint);

    Paint sholder1 = Paint();
    sholder1.shader = getLinearShaderVert(bodyColor,
        Rect.fromCenter(center: const Offset(24, 64), width: 6, height: 20));
    sholder1.strokeWidth = 0.5;
    sholder1.style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromCenter(center: const Offset(24, 64), width: 6, height: 20),
        sholder1);
    canvas.drawRect(
        Rect.fromCenter(center: const Offset(75, 64), width: 6, height: 20),
        sholder1);

    Paint sholder2 = Paint();
    sholder2.shader = getLinearShaderVert(pipeColor,
        Rect.fromCenter(center: const Offset(30, 64), width: 6, height: 15));
    sholder2.strokeWidth = 0.5;
    sholder2.style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromCenter(center: const Offset(20, 64), width: 6, height: 20),
        sholder2);
    canvas.drawRect(
        Rect.fromCenter(center: const Offset(80, 64), width: 6, height: 20),
        sholder2);

    Paint hand = Paint();
    hand.shader = getLinearShaderVert(pipeColor,
        Rect.fromCenter(center: const Offset(30, 64), width: 6, height: 15));
    hand.strokeWidth = 0.5;
    hand.style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromCenter(center: const Offset(10, 64), width: 18, height: 15),
        hand);
    canvas.drawRect(
        Rect.fromCenter(center: const Offset(90, 64), width: 18, height: 15),
        hand);

    Paint paint = Paint()..color = Colors.blueGrey;
    double centerX = 50;
    double centerY = 65;
    double radius = 8;
    double angle = (2 * pi) / 4; // Angle between each rectangle
    double rectangleWidth = 8;
    double rectangleHeight = 10;

    for (int i = 0; i < 4; i++) {
      double x = centerX + radius * cos(i * angle + rotationAngle / 2);
      double y = centerY + radius * sin(i * angle + rotationAngle / 2);
      double rotation = i * angle -
          pi / 2 +
          rotationAngle; // Rotate rectangles to fit the circle

      canvas.save(); // Save canvas state before rotation
      canvas.translate(x, y); // Translate to the position
      canvas.rotate(rotation);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(-rectangleWidth / 2, -rectangleHeight / 2,
              rectangleWidth, rectangleHeight),
          bottomLeft: const Radius.circular(20),
          bottomRight: const Radius.circular(80),
          topLeft: const Radius.circular(40),
          topRight: const Radius.circular(40),
        ),
        paint,
      );
      canvas.restore(); // Restore canvas state after rotation
    }
    Paint smallCircle = Paint();
    smallCircle.color = Colors.black;
    smallCircle.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 4, smallCircle);
  }

  dynamic getLinearShaderVert(List<Color> colors, Rect rect) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    ).createShader(rect);
  }

  dynamic getLinearShaderHor(List<Color> colors, Rect rect) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: colors,
    ).createShader(rect);
  }

  Widget buildPopUpMenuButton(
      {required BuildContext context,
      selected,
      required List<String> dataList,
      required void Function(String) onSelected,
      required Widget child,
      Offset offset = Offset.zero}) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      surfaceTintColor: Colors.white,
      itemBuilder: (context) {
        return dataList.map((String value) {
          return PopupMenuItem<String>(
            value: value,
            child: Center(
                child: Text(
              value,
              style: TextStyle(
                  color: selected == value
                      ? Theme.of(context).primaryColor
                      : null),
            )),
          );
        }).toList();
      },
      onSelected: onSelected,
      offset: offset,
      child: child,
    );
  }

  Widget buildCustomListTile(
      {required BuildContext context,
      required String title,
      daysType,
      void Function(String)? onChanged,
      bool isTextForm = false,
      bool isTimePicker = false,
      bool isDatePicker = false,
      bool isCheckBox = false,
      bool isSwitch = false,
      initialValue,
      dateType,
      firstDate,
      EdgeInsets? padding,
      void Function(DateTime)? onDateChanged,
      void Function(String)? onTimeChanged,
      bool checkBoxValue = false,
      void Function(bool?)? onCheckBoxChanged,
      bool switchValue = false,
      void Function(bool)? onSwitchChanged,
      required icon}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: customBoxShadow),
      child: isTextForm
          ? CustomTextFormTile(
              subtitle: title,
              hintText: '00',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                LengthLimitingTextInputFormatter(2),
              ],
              initialValue: daysType ?? initialValue,
              onChanged: onChanged ?? (newValue) {},
              icon: icon,
            )
          : CustomTile(
              title: title,
              content: icon,
              trailing: IntrinsicWidth(
                child: isTimePicker
                    ? CustomNativeTimePicker(
                        initialValue: initialValue,
                        is24HourMode: false,
                        // style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
                        onChanged: onTimeChanged ?? (newValue) {})
                    : isDatePicker
                        ? DatePickerField(
                            value: dateType,
                            firstDate: firstDate,
                            onChanged: onDateChanged ?? (DateTime dateTime) {},
                          )
                        : isCheckBox
                            ? Checkbox(
                                value: checkBoxValue,
                                onChanged:
                                    onCheckBoxChanged ?? (bool? value) {})
                            : isSwitch
                                ? Switch(
                                    value: switchValue,
                                    onChanged: onSwitchChanged)
                                : const SizedBox(),
              ),
            ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

dynamic getAlarmMessage = {
  1: 'Low Flow',
  2: 'High Flow',
  3: 'No Flow',
  4: 'Ec High',
  5: 'Ph Low',
  6: 'Ph High',
  7: 'Pressure Low',
  8: 'Pressure High',
  9: 'No Power Supply',
  10: 'No Communication',
  11: 'Wrong Feedback',
  12: 'Sump Tank Empty',
  13: 'Top Tank Full',
  14: 'Low Battery',
  15: 'Ec Difference',
  16: 'Ph Difference',
  17: 'Pump Off Alarm',
  18: 'Pressure Switch High',
};

dynamic pumpAlarmMessage = {
  '1': 'sump empty',
  '2': 'upper tank full',
  '3': 'low voltage',
  '4': 'high voltage',
  '5': 'voltage SPP',
  '6': 'reverse phase',
  '7': 'starter trip',
  '8': 'dry run',
  '9': 'overload',
  '10': 'current SPP',
  '11': 'cyclic trip',
  '12': 'maximum run time',
  '13': 'sump empty',
  '14': 'upper tank full',
  '15': 'RTC 1',
  '16': 'RTC 2',
  '17': 'RTC 3',
  '18': 'RTC 4',
  '19': 'RTC 5',
  '20': 'RTC 6',
  '21': 'auto mobile key off',
  '22': 'cyclic time',
  '23': 'RTC 1',
  '24': 'RTC 2',
  '25': 'RTC 3',
  '26': 'RTC 4',
  '27': 'RTC 5',
  '28': 'RTC 6',
  '29': 'auto mobile key on',
  '30': 'Power off',
  '31': 'Power on',
};

class MarqueeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double containerWidth;
  final double containerHeight;

  MarqueeText({
    required this.text,
    required this.style,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: containerWidth);

        bool isOverflowing = textPainter.didExceedMaxLines;

        return SizedBox(
          width: containerWidth,
          height: containerHeight,
          child: Text(
            text,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
