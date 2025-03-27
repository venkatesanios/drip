import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:oro_drip_irrigation/modules/constant/model/constant_menu_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/constant_setting_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/ec_ph_in_constant_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/normal_critical_alarm_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/object_in_constant_model.dart';
import 'package:oro_drip_irrigation/modules/constant/widget/arrow_tab.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';

import '../model/constant_setting_type_Model.dart';

class ConstantProvider extends ChangeNotifier{
  Map<String, dynamic> constantDataFromHttp = {
    "constant": {
      "general": [],
      "mainValve": [],
      "valve": [],
      "pump": [],
      "waterMeter": [],
      "filterSite": [],
      "fertilizerSite": [],
      "fertilizerChannel": [],
      "ecPhSensor" : [],
      "analogSensor": [],
      "moistureSensor": [],
      "levelSensor": [],
      "normalCriticalAlarm" : [],
      "globalAlarm": [],
      "controllerReadStatus": "0"
    },
    "default": {
      "alarmOnStatus" : [
        {'sNo' : 1, 'title' : 'Ignore', 'color' : '0xffA5A5A5'},
        {'sNo' : 2, 'title' : 'Stop Irrigation', 'color' : '0xff0070D8'},
        {'sNo' : 3, 'title' : 'Stop Fertigation', 'color' : '0xffEB7C17'},
        {'sNo' : 4, 'title' : 'Skip Schedule', 'color' : '0xffE73250'},
      ],
      "alarmResetAfterIrrigation" : [
        {'sNo' : 1, 'title' : 'Yes', 'color' : '0xff14AE5C'},
        {'sNo' : 2, 'title' : 'No', 'color' : '0xffE73250'},
      ],
      "mainValveMode" : [
        {'sNo' : 1, 'title' : 'No Delay', 'color' : '0xff6B6B6B'},
        {'sNo' : 2, 'title' : 'Open Before', 'color' : '0xff0070D8'},
        {'sNo' : 3, 'title' : 'Open After', 'color' : '0xff14AE5C'},
      ],
      "fertilizerSiteControlFlag" : [
        {'sNo' : 1, 'title' : 'Stop Faulty Fertilizer', 'color' : '0xffEB7C17'},
        {'sNo' : 2, 'title' : 'Stop Fertigation', 'color' : '0xffE73293'},
        {'sNo' : 3, 'title' : 'Stop Irrigation', 'color' : '0xff0070D8'},
        {'sNo' : 4, 'title' : 'Inform Only', 'color' : '0xff14AE5C'},
      ],
      "fertilizerChannelMode" : [
        {'sNo' : 1, 'title' : 'Regular', 'color' : '0xff0070D8'},
        {'sNo' : 2, 'title' : 'Ph Control', 'color' : '0xffEB7C17'},
        {'sNo' : 3, 'title' : 'Ec Control', 'color' : '0xffE73293'},
        {'sNo' : 4, 'title' : 'Concentration', 'color' : '0xff14AE5C'},
      ],
      "filterSiteWhileBackwash": [
        {
          "sNo": 1,
          "title": "Continue Irrigation",
          "color": "0xff0070D8"
        },
        {
          "sNo": 2,
          "title": "Stop Irrigation",
          "color": "0xffE73250"
        },
        {
          "sNo": 3,
          "title": "Stop Fertigation",
          "color": "0xffEB7C17"
        },
        {
          "sNo": 4,
          "title": "Open Valves Only",
          "color": "0xff14AE5C"
        }
      ],

      "globalAlarm" : [
        {"sNo":1,"title":"LowFlow","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":2,"title":"HighFlow","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":3,"title":"NoFlow","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":4,"title":"EcHigh","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":5,"title":"PhLow","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":6,"title":"PhHigh","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":7,"title":"PressureLow","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":8,"title":"PressureHigh","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":9,"title":"NoPowerSupply","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":10,"title":"NoCommunication","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":11,"title":"WrongFeedback","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":12,"title":"SumpTankEmpty","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":13,"title":"TopTankFull","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":14,"title":"LowBattery","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":15,"title":"EcDifference","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":16,"title":"PhDifference","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":17,"title":"PumpOffAlarm","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":18,"title":"PressureSwitch","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":19,"title":"WiredNoCommunication","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
      ],
      "normalCriticalAlarm" : [
        {"sNo":1,"title":"Scan Time","widgetTypeId":3,"dataType":"String","value":"00:00:00","hidden":false,"software":true,"hardware":true},
        {"sNo":2,"title":"Alarm On Status","widgetTypeId":6,"dataType":"int","value":1,"hidden":false,"software":true,"hardware":true},
        {"sNo":3,"title":"Reset After Irrigation","widgetTypeId":6,"dataType":"int","value":1,"hidden":false,"software":true,"hardware":true},
        {"sNo":4,"title":"Auto Reset Duration","widgetTypeId":3,"dataType":"String","value":"00:00:00","hidden":false,"software":true,"hardware":true},
        {"sNo":5,"title":"Threshold Value","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true},
        {"sNo":6,"title":"Units","widgetTypeId":8,"dataType":"String","value":"","hidden":false,"software":true,"hardware":true}
      ],
      "general" : [
        {"sNo":1,"title":"Number of Programs","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":false},
        {"sNo":2,"title":"Number of Valve Groups","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":false},
        {"sNo":3,"title":"Number of Conditions","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":false},
        {"sNo":4,"title":"Run List Limit","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":false},
        {"sNo":5,"title":"Fertilizer Leakage Limit","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":false},
        {"sNo":6,"title":"Reset Time","widgetTypeId":3,"dataType":"String","value":"00:00:00","hidden":false,"software":true,"hardware":false},
        {"sNo":7,"title":"No Pressure Delay","widgetTypeId":3,"dataType":"String","value":"00:00:00","hidden":false,"software":true,"hardware":false},
        {"sNo":8,"title":"Common Dosing Coefficient","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":false},
        {"sNo":9,"title":"Water Pulse Before Dosing","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":false},
        {"sNo":10,"title":"Lora Key 1","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true},
        {"sNo":11,"title":"Lora Key 2","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true},
        {"sNo":12,"title":"Pump On After Valve On","widgetTypeId":2,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true}
      ],
      "pump" : [
        {"sNo":1,"title":"Pump Station","widgetTypeId":7,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":2,"title":"Flow Rate","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true},
        {"sNo":3,"title":"Control by Master","widgetTypeId":7,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true}
      ],
      "mainValve" : [
        {"sNo":1,"title":"Mode of Operation","widgetTypeId":6,"dataType":"int","value":1,"hidden":false,"software":true,"hardware":true},
        {"sNo":2,"title":"Delay","widgetTypeId":3,"dataType":"String","value":"00:00:00","hidden":false,"software":true,"hardware":true}
      ],
      "valve" : [
        {"sNo":1,"title":"Flow Rate","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true}
      ],
      "waterMeter" : [
        {"sNo":1,"title":"Flow Rate","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true}
      ],
      "fertilizerSite" : [
        {"sNo":1,"title":"Minimal On Time","widgetTypeId":3,"dataType":"String","value":"00:00:00","hidden":false,"software":true,"hardware":true},
        {"sNo":2,"title":"Minimal Off Time","widgetTypeId":3,"dataType":"String","value":"00:00:00","hidden":false,"software":true,"hardware":true},
        {"sNo":3,"title":"Booster Off Delay","widgetTypeId":3,"dataType":"String","value":"00:00:00","hidden":false,"software":true,"hardware":true},
        {"sNo":4,"title":"Fertilizer Control Flag","widgetTypeId":6,"dataType":"int","value":1,"hidden":false,"software":true,"hardware":true}
      ],
      "fertilizerChannel" : [
        {"sNo":1,"title":"Flow Rate","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true},
        {"sNo":2,"title":"Injector Mode","widgetTypeId":6,"dataType":"int","value":1,"hidden":false,"software":true,"hardware":true},
        {"sNo":3,"title":"Ratio","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true},
        {"sNo":4,"title":"Shortest Pulse","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true}
      ],
      "ecPhSensor" : [
        {"sNo":1,"title":"Select","widgetTypeId":7,"dataType":"bool","value":false,"hidden":false,"software":true,"hardware":true},
        {"sNo":2,"title":"Control Cycle","widgetTypeId":3,"dataType":"String","value":"00:00:00","hidden":false,"software":true,"hardware":true},
        {"sNo":3,"title":"Delta","widgetTypeId":1,"dataType":"double","value":0.0,"hidden":false,"software":true,"hardware":true},
        {"sNo":4,"title":"Fine Tunning","widgetTypeId":1,"dataType":"double","value":0.0,"hidden":false,"software":true,"hardware":true},
        {"sNo":5,"title":"Coarse Tunning","widgetTypeId":1,"dataType":"double","value":0.0,"hidden":false,"software":true,"hardware":true},
        {"sNo":6,"title":"Deadband","widgetTypeId":1,"dataType":"double","value":0.0,"hidden":false,"software":true,"hardware":true},
        {"sNo":7,"title":"Integ","widgetTypeId":3,"dataType":"String","value":"00:00:00","hidden":false,"software":true,"hardware":true},
        {"sNo":8,"title":"Control Sensor","widgetTypeId":6,"dataType":"double","value":0.0,"hidden":false,"software":true,"hardware":true},
        {"sNo":9,"title":"Average Filter Speed","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true},
        {"sNo":10,"title":"Extra Limit","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true}
      ],
      "moistureSensor" : [
        {"sNo":1,"title":"High Low","widgetTypeId":6,"dataType":"int","value":1,"hidden":false,"software":true,"hardware":false},
      ],
      "moistureMode" : [
        {'sNo' : 1, 'title' : 'High', 'color' : '0xff14AE5C'},
        {'sNo' : 2, 'title' : 'Low', 'color' : '0xffE73250'},
      ],
      "levelSensor" : [
        {"sNo":1,"title":"Tank Height","widgetTypeId":1,"dataType":"double","value":0.0,"hidden":false,"software":true,"hardware":true}
      ],
      "constantMenu": [
        {
          "dealerDefinitionId": 82,
          "parameter": "General",
          "value": "1"
        },
        {
          "dealerDefinitionId": 83,
          "parameter": "Pump",
          "value": "1"
        },
        {
          "dealerDefinitionId": 85,
          "parameter": "Main Valve",
          "value": "1"
        },
        {
          "dealerDefinitionId": 86,
          "parameter": "Valve",
          "value": "1"
        },
        {
          "dealerDefinitionId": 87,
          "parameter": "Water Meter",
          "value": "1"
        },
        {
          "dealerDefinitionId": 88,
          "parameter": "Fertilizer Site",
          "value": "1"
        },
        {
          "dealerDefinitionId": 89,
          "parameter": "Fertilizer Channel",
          "value": "1"
        },
        {
          "dealerDefinitionId": 90,
          "parameter": "EC/PH",
          "value": "1"
        },
        {
          "dealerDefinitionId": 91,
          "parameter": "Moisture Sensor",
          "value": "1"
        },
        {
          "dealerDefinitionId": 92,
          "parameter": "Level Sensor",
          "value": "1"
        },
        {
          "dealerDefinitionId": 93,
          "parameter": "Alarm",
          "value": "1"
        },
        {
          "dealerDefinitionId": 94,
          "parameter": "Global Alarm",
          "value": "1"
        }
      ],
      "configMaker": {
        "isNewConfig": "0",
        "configObject": [
          {
            "objectId": 1,
            "sNo": 1.001,
            "name": "Source 1test",
            "connectionNo": null,
            "objectName": "Source",
            "type": "-",
            "controllerId": null,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 1.001
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
            "location": 1.002
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
            "location": 1.003
          },
          {
            "objectId": 1,
            "sNo": 1.004,
            "name": "Source 4test",
            "connectionNo": null,
            "objectName": "Source",
            "type": "-",
            "controllerId": null,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 1.004
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
            "siteMode": null,
            "location": 2.001
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
            "location": 2.002
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
            "siteMode": null,
            "location": 2.002
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
            "siteMode": null,
            "location": 2.002
          },
          {
            "objectId": 5,
            "sNo": 5.001,
            "name": "Pump 1",
            "connectionNo": 1,
            "objectName": "Pump",
            "type": "1,2",
            "controllerId": 6,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.001
          },
          {
            "objectId": 5,
            "sNo": 5.002,
            "name": "Pump 2",
            "connectionNo": 2,
            "objectName": "Pump",
            "type": "1,2",
            "controllerId": 6,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.001
          },
          {
            "objectId": 5,
            "sNo": 5.003,
            "name": "Pump 3",
            "connectionNo": 1,
            "objectName": "Pump",
            "type": "1,2",
            "controllerId": 11,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.002
          },
          {
            "objectId": 5,
            "sNo": 5.004,
            "name": "Pump 4",
            "connectionNo": 2,
            "objectName": "Pump",
            "type": "1,2",
            "controllerId": 11,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.001
          },
          {
            "objectId": 5,
            "sNo": 5.005,
            "name": "Pump 5",
            "connectionNo": 1,
            "objectName": "Pump",
            "type": "1,2",
            "controllerId": 7,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.002
          },
          {
            "objectId": 7,
            "sNo": 7.001,
            "name": "Booster Pump 1",
            "connectionNo": 1,
            "objectName": "Booster Pump",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 3.001
          },
          {
            "objectId": 9,
            "sNo": 9.001,
            "name": "Agitator 1",
            "connectionNo": 1,
            "objectName": "Agitator",
            "type": "1,2",
            "controllerId": 10,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 3.001
          },
          {
            "objectId": 10,
            "sNo": 10.001,
            "name": "Injector 1",
            "connectionNo": 2,
            "objectName": "Injector",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 3.001
          },
          {
            "objectId": 11,
            "sNo": 11.001,
            "name": "Filter 1",
            "connectionNo": 3,
            "objectName": "Filter",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 4.001
          },
          {
            "objectId": 11,
            "sNo": 11.002,
            "name": "Filter 2",
            "connectionNo": 4,
            "objectName": "Filter",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 4.001
          },
          {
            "objectId": 11,
            "sNo": 11.003,
            "name": "Filter 3",
            "connectionNo": 5,
            "objectName": "Filter",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 4.001
          },
          {
            "objectId": 13,
            "sNo": 13.001,
            "name": "Valve 1",
            "connectionNo": 6,
            "objectName": "Valve",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.001
          },
          {
            "objectId": 13,
            "sNo": 13.002,
            "name": "Valve 2",
            "connectionNo": 7,
            "objectName": "Valve",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.001
          },
          {
            "objectId": 13,
            "sNo": 13.003,
            "name": "Valve 3",
            "connectionNo": 8,
            "objectName": "Valve",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.001
          },
          {
            "objectId": 13,
            "sNo": 13.004,
            "name": "Valve 4",
            "connectionNo": 9,
            "objectName": "Valve",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.001
          },
          {
            "objectId": 13,
            "sNo": 13.005,
            "name": "Valve 5",
            "connectionNo": 10,
            "objectName": "Valve",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.001
          },
          {
            "objectId": 13,
            "sNo": 13.006,
            "name": "Valve 6",
            "connectionNo": 11,
            "objectName": "Valve",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.002
          },
          {
            "objectId": 13,
            "sNo": 13.007,
            "name": "Valve 7",
            "connectionNo": 12,
            "objectName": "Valve",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.002
          },
          {
            "objectId": 13,
            "sNo": 13.008,
            "name": "Valve 8",
            "connectionNo": 13,
            "objectName": "Valve",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.002
          },
          {
            "objectId": 13,
            "sNo": 13.009,
            "name": "Valve 9",
            "connectionNo": 14,
            "objectName": "Valve",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.002
          },
          {
            "objectId": 13,
            "sNo": 13.01,
            "name": "Valve 10",
            "connectionNo": 15,
            "objectName": "Valve",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.002
          },
          {
            "objectId": 14,
            "sNo": 14.001,
            "name": "Main Valve 1",
            "connectionNo": 16,
            "objectName": "Main Valve",
            "type": "1,2",
            "controllerId": 2,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.001
          },
          {
            "objectId": 14,
            "sNo": 14.002,
            "name": "Main Valve 2",
            "connectionNo": 2,
            "objectName": "Main Valve",
            "type": "1,2",
            "controllerId": 10,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 2.001
          },
          {
            "objectId": 24,
            "sNo": 24.001,
            "name": "Pressure Sensor 1",
            "connectionNo": 2,
            "objectName": "Pressure Sensor",
            "type": "3",
            "controllerId": 7,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 4.001
          },
          {
            "objectId": 24,
            "sNo": 24.002,
            "name": "Pressure Sensor 2",
            "connectionNo": 1,
            "objectName": "Pressure Sensor",
            "type": "3",
            "controllerId": 10,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 4.001
          },
          {
            "objectId": 26,
            "sNo": 26.001,
            "name": "Level Sensor 1",
            "connectionNo": 1,
            "objectName": "Level Sensor",
            "type": "3",
            "controllerId": 7,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 1.003
          },
          {
            "objectId": 26,
            "sNo": 26.002,
            "name": "Level Sensor 2",
            "connectionNo": 2,
            "objectName": "Level Sensor",
            "type": "3",
            "controllerId": 10,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 1.004
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
            "siteMode": null,
            "location": 0
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
            "siteMode": null,
            "location": 0
          },
          {
            "objectId": 22,
            "sNo": 22.002,
            "name": "Water Meter 2",
            "connectionNo": 1,
            "objectName": "Water Meter",
            "type": "4",
            "controllerId": 10,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 5.001,
          },
          {
            "objectId": 40,
            "sNo": 40.001,
            "name": "Float 1",
            "connectionNo": 1,
            "objectName": "Float",
            "type": "4",
            "controllerId": 7,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 0
          },
          {
            "objectId": 40,
            "sNo": 40.002,
            "name": "Float 2",
            "connectionNo": 2,
            "objectName": "Float",
            "type": "4",
            "controllerId": 7,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 0
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
            "siteMode": null,
            "location": 2.001
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
            "location": 2.001
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
            "location": 2.002
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
            "location": 2.002
          },
          {
            "objectId": 10,
            "sNo": 10.002,
            "name": "Injector 2",
            "connectionNo": 3,
            "objectName": "Injector",
            "type": "1,2",
            "controllerId": 10,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 3.001
          },
          {
            "objectId": 10,
            "sNo": 10.003,
            "name": "Injector 3",
            "connectionNo": 4,
            "objectName": "Injector",
            "type": "1,2",
            "controllerId": 10,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 3.001
          },
          {
            "objectId": 10,
            "sNo": 10.004,
            "name": "Injector 4",
            "connectionNo": 5,
            "objectName": "Injector",
            "type": "1,2",
            "controllerId": 10,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 3.001
          },
          {
            "objectId": 10,
            "sNo": 10.005,
            "name": "Injector 5",
            "connectionNo": 6,
            "objectName": "Injector",
            "type": "1,2",
            "controllerId": 10,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 3.001
          },
          {
            "objectId": 33,
            "sNo": 33.001,
            "name": "Co2 Sensor 1",
            "connectionNo": 2,
            "objectName": "Co2 Sensor",
            "type": "7",
            "controllerId": 21,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 0
          },
          {
            "objectId": 34,
            "sNo": 34.001,
            "name": "LUX Sensor 1",
            "connectionNo": 3,
            "objectName": "LUX Sensor",
            "type": "7",
            "controllerId": 21,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 0
          },
          {
            "objectId": 36,
            "sNo": 36.001,
            "name": "Humidity Sensor 1",
            "connectionNo": 4,
            "objectName": "Humidity Sensor",
            "type": "7",
            "controllerId": 21,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 0
          },
          {
            "objectId": 29,
            "sNo": 29.001,
            "name": "Temperature Sensor 1",
            "connectionNo": 1,
            "objectName": "Temperature Sensor",
            "type": "7",
            "controllerId": 21,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 0
          },
          {
            "objectId": 25,
            "sNo": 25.005,
            "name": "Moisture Sensor 5",
            "connectionNo": 1,
            "objectName": "Moisture Sensor",
            "type": "5",
            "controllerId": 21,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 25.005
          },
          {
            "objectId": 25,
            "sNo": 25.006,
            "name": "Moisture Sensor 6",
            "connectionNo": 2,
            "objectName": "Moisture Sensor",
            "type": "5",
            "controllerId": 21,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 25.006
          },
          {
            "objectId": 25,
            "sNo": 25.007,
            "name": "Moisture Sensor 7",
            "connectionNo": 3,
            "objectName": "Moisture Sensor",
            "type": "5",
            "controllerId": 21,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 25.007
          },
          {
            "objectId": 25,
            "sNo": 25.008,
            "name": "Moisture Sensor 8",
            "connectionNo": 4,
            "objectName": "Moisture Sensor",
            "type": "5",
            "controllerId": 21,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "location": 25.008
          }
        ],
        "waterSource": [
          {
            "objectId": 1,
            "sNo": 1.001,
            "name": "Source 1test",
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
              5.001,
              5.002
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
              5.003
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
            "sourceType": 1,
            "level": 26.001,
            "topFloat": 0,
            "bottomFloat": 0,
            "inletPump": [
              5.001,
              5.002
            ],
            "outletPump": [
              5.004
            ],
            "valves": []
          },
          {
            "objectId": 1,
            "sNo": 1.004,
            "name": "Source 4test",
            "connectionNo": null,
            "objectName": "Source",
            "type": "-",
            "controllerId": null,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "sourceType": 2,
            "level": 26.002,
            "topFloat": 0,
            "bottomFloat": 0,
            "inletPump": [
              5.003
            ],
            "outletPump": [
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
            "controllerId": 6,
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
            "controllerId": 6,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "level": 0,
            "pressureIn": 24.001,
            "pressureOut": 0,
            "waterMeter": 0,
            "pumpType": 1
          },
          {
            "objectId": 5,
            "sNo": 5.003,
            "name": "Pump 3",
            "connectionNo": 1,
            "objectName": "Pump",
            "type": "1,2",
            "controllerId": 11,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "level": 0,
            "pressureIn": 24.002,
            "pressureOut": 0,
            "waterMeter": 0,
            "pumpType": 1
          },
          {
            "objectId": 5,
            "sNo": 5.004,
            "name": "Pump 4",
            "connectionNo": 2,
            "objectName": "Pump",
            "type": "1,2",
            "controllerId": 11,
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
            "connectionNo": 1,
            "objectName": "Pump",
            "type": "1,2",
            "controllerId": 7,
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
              },
              {
                "sNo": 10.005,
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
            "ec": [],
            "ph": []
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
          },
          {
            "objectId": 25,
            "sNo": 25.005,
            "name": "Moisture Sensor 5",
            "connectionNo": 1,
            "objectName": "Moisture Sensor",
            "type": "5",
            "controllerId": 21,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "valves": []
          },
          {
            "objectId": 25,
            "sNo": 25.006,
            "name": "Moisture Sensor 6",
            "connectionNo": 2,
            "objectName": "Moisture Sensor",
            "type": "5",
            "controllerId": 21,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "valves": []
          },
          {
            "objectId": 25,
            "sNo": 25.007,
            "name": "Moisture Sensor 7",
            "connectionNo": 3,
            "objectName": "Moisture Sensor",
            "type": "5",
            "controllerId": 21,
            "count": null,
            "connectedObject": null,
            "siteMode": null,
            "valves": []
          },
          {
            "objectId": 25,
            "sNo": 25.008,
            "name": "Moisture Sensor 8",
            "connectionNo": 4,
            "objectName": "Moisture Sensor",
            "type": "5",
            "controllerId": 21,
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
            "waterMeter": 22.001,
            "pressureIn": 0,
            "pressureOut": 0,
            "moisture": [
              25.001,
              25.002
            ],
            "temperature": [],
            "soilTemperature": [],
            "humidity": [],
            "co2": [],
            "weatherStation": [
              21
            ]
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
              5.003
            ],
            "irrigationPump": [
              5.005
            ],
            "centralFiltration": 4.001,
            "localFiltration": 0,
            "centralFertilization": 3.001,
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
            "moisture": [
              25.003,
              25.004
            ],
            "temperature": [],
            "soilTemperature": [],
            "humidity": [],
            "co2": [],
            "weatherStation": []
          }
        ],
        "controllerReadStatus": "0"
      }
    }
  };
  List<Map<String, dynamic>> configObjectDataFromHttp = [
    {
      "objectId": 1,
      "sNo": 1.001,
      "name": "Source 1test",
      "connectionNo": null,
      "objectName": "Source",
      "type": "-",
      "controllerId": null,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 1.001
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
      "location": 1.002
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
      "location": 1.003
    },
    {
      "objectId": 1,
      "sNo": 1.004,
      "name": "Source 4test",
      "connectionNo": null,
      "objectName": "Source",
      "type": "-",
      "controllerId": null,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 1.004
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
      "siteMode": null,
      "location": 2.001
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
      "location": 2.002
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
      "siteMode": null,
      "location": 2.002
    },
    {
      "objectId": 3,
      "sNo": 3.002,
      "name": "Fertilization Site 2",
      "connectionNo": null,
      "objectName": "Fertilization Site",
      "type": "-",
      "controllerId": null,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.002
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
      "siteMode": null,
      "location": 2.002
    },
    {
      "objectId": 5,
      "sNo": 5.001,
      "name": "Pump 1",
      "connectionNo": 1,
      "objectName": "Pump",
      "type": "1,2",
      "controllerId": 6,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.001
    },
    {
      "objectId": 5,
      "sNo": 5.002,
      "name": "Pump 2",
      "connectionNo": 2,
      "objectName": "Pump",
      "type": "1,2",
      "controllerId": 6,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.001
    },
    {
      "objectId": 5,
      "sNo": 5.003,
      "name": "Pump 3",
      "connectionNo": 1,
      "objectName": "Pump",
      "type": "1,2",
      "controllerId": 11,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.002
    },
    {
      "objectId": 5,
      "sNo": 5.004,
      "name": "Pump 4",
      "connectionNo": 2,
      "objectName": "Pump",
      "type": "1,2",
      "controllerId": 11,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.001
    },
    {
      "objectId": 5,
      "sNo": 5.005,
      "name": "Pump 5",
      "connectionNo": 1,
      "objectName": "Pump",
      "type": "1,2",
      "controllerId": 7,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.002
    },
    {
      "objectId": 7,
      "sNo": 7.001,
      "name": "Booster Pump 1",
      "connectionNo": 1,
      "objectName": "Booster Pump",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 3.001
    },
    {
      "objectId": 9,
      "sNo": 9.001,
      "name": "Agitator 1",
      "connectionNo": 1,
      "objectName": "Agitator",
      "type": "1,2",
      "controllerId": 10,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 3.001
    },
    {
      "objectId": 10,
      "sNo": 10.001,
      "name": "Injector 1",
      "connectionNo": 2,
      "objectName": "Injector",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 3.001
    },
    {
      "objectId": 11,
      "sNo": 11.001,
      "name": "Filter 1",
      "connectionNo": 3,
      "objectName": "Filter",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 4.001
    },
    {
      "objectId": 11,
      "sNo": 11.002,
      "name": "Filter 2",
      "connectionNo": 4,
      "objectName": "Filter",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 4.001
    },
    {
      "objectId": 11,
      "sNo": 11.003,
      "name": "Filter 3",
      "connectionNo": 5,
      "objectName": "Filter",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 4.001
    },
    {
      "objectId": 14,
      "sNo": 14.001,
      "name": "Main Valve 1",
      "connectionNo": 7,
      "objectName": "Main Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.001
    },
    {
      "objectId": 14,
      "sNo": 14.002,
      "name": "Main Valve 2",
      "connectionNo": 7,
      "objectName": "Main Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.001
    },
    {
      "objectId": 14,
      "sNo": 14.003,
      "name": "Main Valve 3",
      "connectionNo": 7,
      "objectName": "Main Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.002
    },
    {
      "objectId": 14,
      "sNo": 14.004,
      "name": "Main Valve 4",
      "connectionNo": 7,
      "objectName": "Main Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.002
    },
    {
      "objectId": 13,
      "sNo": 13.001,
      "name": "Valve 1",
      "connectionNo": 6,
      "objectName": "Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.001
    },
    {
      "objectId": 13,
      "sNo": 13.002,
      "name": "Valve 2",
      "connectionNo": 7,
      "objectName": "Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.001
    },
    {
      "objectId": 13,
      "sNo": 13.003,
      "name": "Valve 3",
      "connectionNo": 8,
      "objectName": "Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.001
    },
    {
      "objectId": 13,
      "sNo": 13.004,
      "name": "Valve 4",
      "connectionNo": 9,
      "objectName": "Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.001
    },
    {
      "objectId": 13,
      "sNo": 13.005,
      "name": "Valve 5",
      "connectionNo": 10,
      "objectName": "Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.001
    },
    {
      "objectId": 13,
      "sNo": 13.006,
      "name": "Valve 6",
      "connectionNo": 11,
      "objectName": "Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.002
    },
    {
      "objectId": 13,
      "sNo": 13.007,
      "name": "Valve 7",
      "connectionNo": 12,
      "objectName": "Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.002
    },
    {
      "objectId": 13,
      "sNo": 13.008,
      "name": "Valve 8",
      "connectionNo": 13,
      "objectName": "Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.002
    },
    {
      "objectId": 13,
      "sNo": 13.009,
      "name": "Valve 9",
      "connectionNo": 14,
      "objectName": "Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.002
    },
    {
      "objectId": 13,
      "sNo": 13.01,
      "name": "Valve 10",
      "connectionNo": 15,
      "objectName": "Valve",
      "type": "1,2",
      "controllerId": 2,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.002
    },
    {
      "objectId": 24,
      "sNo": 24.001,
      "name": "Pressure Sensor 1",
      "connectionNo": 2,
      "objectName": "Pressure Sensor",
      "type": "3",
      "controllerId": 7,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 4.001
    },
    {
      "objectId": 24,
      "sNo": 24.002,
      "name": "Pressure Sensor 2",
      "connectionNo": 1,
      "objectName": "Pressure Sensor",
      "type": "3",
      "controllerId": 10,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 4.001
    },
    {
      "objectId": 26,
      "sNo": 26.001,
      "name": "Level Sensor 1",
      "connectionNo": 1,
      "objectName": "Level Sensor",
      "type": "3",
      "controllerId": 7,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 1.003
    },
    {
      "objectId": 26,
      "sNo": 26.002,
      "name": "Level Sensor 2",
      "connectionNo": 2,
      "objectName": "Level Sensor",
      "type": "3",
      "controllerId": 10,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 1.004
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
      "siteMode": null,
      "location": 3.001
    },
    {
      "objectId": 27,
      "sNo": 27.002,
      "name": "EC Sensor 2",
      "connectionNo": 7,
      "objectName": "EC Sensor",
      "type": "3",
      "controllerId": 10,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 3.001
    },
    {
      "objectId": 27,
      "sNo": 27.003,
      "name": "EC Sensor 3",
      "connectionNo": 7,
      "objectName": "EC Sensor",
      "type": "3",
      "controllerId": 10,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 3.002
    },
    {
      "objectId": 27,
      "sNo": 27.004,
      "name": "EC Sensor 4",
      "connectionNo": 7,
      "objectName": "EC Sensor",
      "type": "3",
      "controllerId": 10,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 3.002
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
      "siteMode": null,
      "location": 3.001
    },
    {
      "objectId": 28,
      "sNo": 28.002,
      "name": "PH Sensor 2",
      "connectionNo": 5,
      "objectName": "PH Sensor",
      "type": "3",
      "controllerId": 10,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 3.001
    },
    {
      "objectId": 22,
      "sNo": 22.001,
      "name": "Water Meter 1",
      "connectionNo": 1,
      "objectName": "Water Meter",
      "type": "4",
      "controllerId": 10,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 2.001
    },
    {
      "objectId": 40,
      "sNo": 40.001,
      "name": "Float 1",
      "connectionNo": 1,
      "objectName": "Float",
      "type": "4",
      "controllerId": 7,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 0
    },
    {
      "objectId": 40,
      "sNo": 40.002,
      "name": "Float 2",
      "connectionNo": 2,
      "objectName": "Float",
      "type": "4",
      "controllerId": 7,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 0
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
      "siteMode": null,
      "location": 2.001
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
      "location": 2.001
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
      "location": 2.002
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
      "location": 2.002
    },
    {
      "objectId": 10,
      "sNo": 10.002,
      "name": "Injector 2",
      "connectionNo": 3,
      "objectName": "Injector",
      "type": "1,2",
      "controllerId": 10,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 3.001
    },
    {
      "objectId": 10,
      "sNo": 10.003,
      "name": "Injector 3",
      "connectionNo": 4,
      "objectName": "Injector",
      "type": "1,2",
      "controllerId": 10,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 3.001
    },
    {
      "objectId": 10,
      "sNo": 10.004,
      "name": "Injector 4",
      "connectionNo": 5,
      "objectName": "Injector",
      "type": "1,2",
      "controllerId": 10,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 3.001
    },
    {
      "objectId": 10,
      "sNo": 10.005,
      "name": "Injector 5",
      "connectionNo": 6,
      "objectName": "Injector",
      "type": "1,2",
      "controllerId": 10,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 3.001
    },
    {
      "objectId": 33,
      "sNo": 33.001,
      "name": "Co2 Sensor 1",
      "connectionNo": 2,
      "objectName": "Co2 Sensor",
      "type": "7",
      "controllerId": 21,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 0
    },
    {
      "objectId": 34,
      "sNo": 34.001,
      "name": "LUX Sensor 1",
      "connectionNo": 3,
      "objectName": "LUX Sensor",
      "type": "7",
      "controllerId": 21,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 0
    },
    {
      "objectId": 36,
      "sNo": 36.001,
      "name": "Humidity Sensor 1",
      "connectionNo": 4,
      "objectName": "Humidity Sensor",
      "type": "7",
      "controllerId": 21,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 0
    },
    {
      "objectId": 29,
      "sNo": 29.001,
      "name": "Temperature Sensor 1",
      "connectionNo": 1,
      "objectName": "Temperature Sensor",
      "type": "7",
      "controllerId": 21,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 0
    },
    {
      "objectId": 25,
      "sNo": 25.005,
      "name": "Moisture Sensor 5",
      "connectionNo": 1,
      "objectName": "Moisture Sensor",
      "type": "5",
      "controllerId": 21,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 25.005
    },
    {
      "objectId": 25,
      "sNo": 25.006,
      "name": "Moisture Sensor 6",
      "connectionNo": 2,
      "objectName": "Moisture Sensor",
      "type": "5",
      "controllerId": 21,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 25.006
    },
    {
      "objectId": 25,
      "sNo": 25.007,
      "name": "Moisture Sensor 7",
      "connectionNo": 3,
      "objectName": "Moisture Sensor",
      "type": "5",
      "controllerId": 21,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 25.007
    },
    {
      "objectId": 25,
      "sNo": 25.008,
      "name": "Moisture Sensor 8",
      "connectionNo": 4,
      "objectName": "Moisture Sensor",
      "type": "5",
      "controllerId": 21,
      "count": null,
      "connectedObject": null,
      "siteMode": null,
      "location": 25.008
    }
  ];

  List<ConstantMenuModel> listOfConstantMenuModel = [];
  List<ConstantSettingModel> general = [];
  List<ConstantSettingModel> globalAlarm = [];
  List<NormalCriticalAlarmModel> normalCriticalAlarm = [];
  List<ObjectInConstantModel> pump = [];
  List<ObjectInConstantModel> mainValve = [];
  List<ObjectInConstantModel> valve = [];
  List<ObjectInConstantModel> waterMeter = [];
  List<ObjectInConstantModel> fertilizerSite = [];
  List<ObjectInConstantModel> channel = [];
  List<EcPhInConstantModel> ecPhSensor = [];
  List<ObjectInConstantModel> moisture = [];
  List<ObjectInConstantModel> level = [];
  List<ConstantSettingModel> defaultPumpSetting = [];
  List<ConstantSettingModel> defaultMainValveSetting = [];
  List<ConstantSettingModel> defaultValveSetting = [];
  List<ConstantSettingModel> defaultWaterMeterSetting = [];
  List<ConstantSettingModel> defaultFertilizerSiteSetting = [];
  List<ConstantSettingModel> defaultChannelSetting = [];
  List<ConstantSettingModel> defaultEcPhSetting = [];
  List<ConstantSettingModel> defaultMoistureSetting = [];
  List<ConstantSettingModel> defaultLevelSetting = [];
  List<ConstantSettingModel> defaultNormalCriticalAlarmSetting = [];
  List<PopUpItemModel> mainValveMode = [];
  List<PopUpItemModel> fertilizerSiteControlFlag = [];
  List<PopUpItemModel> fertilizerChannelMode = [];
  List<PopUpItemModel> moistureMode = [];
  List<PopUpItemModel> alarmOnStatus = [];
  List<PopUpItemModel> alarmResetAfterIrrigation = [];

  String getName(dynamic sNo){
    var name = '';
    for(var n in configObjectDataFromHttp){
      if(n['sNo'].toString() == sNo.toString()){
        name = n['name'];
      }
    }
    return name.isEmpty ? sNo : name;
  }


  List<PopUpItemModel> generatePopUpItemModel({
    required Map<String, dynamic> defaultData,
    required String keyName
  }){
    return (defaultData[keyName] as List<dynamic>).map((setting) {
      return PopUpItemModel.fromJson(setting);
    }).toList();
  }

  List<ConstantSettingModel> generateDefaultSetting({
        required Map<String, dynamic> defaultData,
        required String keyName
      }){
    return (defaultData[keyName] as List<dynamic>).map((setting) {
      return ConstantSettingModel.fromJson(setting, null);
    }).toList();
  }

  List<ObjectInConstantModel> generateObjectInConstantModel(
      {
        required List<dynamic> listOfObject,
        required Map<String, dynamic> defaultData,
        required Map<String, dynamic> constantOldData,
        required String keyName
      }){
    return listOfObject.map((object){
      List<dynamic> oldSetting = (constantOldData[keyName] as List<dynamic>).where((setting) => setting['sNo'] == object['sNo']).toList();
      return ObjectInConstantModel.fromJson(
          objectData: object,
          defaultSetting: defaultData[keyName] as List<dynamic>,
          oldSetting: oldSetting.isNotEmpty ? oldSetting.first['setting'] : []
      );
    }).toList();
  }

  void updateConstant(){
    try{
      Map<String, dynamic> defaultData = constantDataFromHttp['default'];
      Map<String, dynamic> constantOldData = constantDataFromHttp['constant'];
      Map<String, dynamic> configMakerData = constantDataFromHttp['constant'];

      // update constant menu
      listOfConstantMenuModel = (defaultData['constantMenu'] as List<dynamic>).map((menu){
        return ConstantMenuModel(
            dealerDefinitionId: menu['dealerDefinitionId'],
            parameter: menu['parameter'],
            arrowTabState: ValueNotifier(menu['dealerDefinitionId'] == 82 ? ArrowTabState.onProgress : ArrowTabState.inComplete)
        );
      }).toList();


      //update object
      List<dynamic> listOfPumpObject = [];
      List<dynamic> listOfFilterObject = [];
      List<dynamic> listOfMainValveObject = [];
      List<dynamic> listOfValveObject = [];
      List<dynamic> listOfWaterMeterObject = [];
      List<dynamic> listOfFertilizerSiteObject = [];
      List<dynamic> listOfChannelObject = [];
      List<dynamic> listOfEcObject = [];
      List<dynamic> listOfPhObject = [];
      List<dynamic> listOfMoistureObject = [];
      List<dynamic> listOfLevelObject = [];
      List<dynamic> listOfIrrigationLineObject = [];

      for (var object in configObjectDataFromHttp) {
        if(object['objectId'] == AppConstants.pumpObjectId){
          listOfPumpObject.add(object);
        }else if(object['objectId'] == AppConstants.filterObjectId){
          listOfFilterObject.add(object);
        }else if(object['objectId'] == AppConstants.mainValveObjectId){
          listOfMainValveObject.add(object);
        }else if(object['objectId'] == AppConstants.valveObjectId){
          listOfValveObject.add(object);
        }else if(object['objectId'] == AppConstants.waterMeterObjectId){
          listOfWaterMeterObject.add(object);
        }else if(object['objectId'] == AppConstants.fertilizerSiteObjectId){
          listOfFertilizerSiteObject.add(object);
        }else if(object['objectId'] == AppConstants.channelObjectId){
          listOfChannelObject.add(object);
        }else if(object['objectId'] == AppConstants.ecObjectId){
          listOfEcObject.add(object);
        }else if(object['objectId'] == AppConstants.phObjectId){
          listOfPhObject.add(object);
        }else if(object['objectId'] == AppConstants.moistureObjectId){
          listOfMoistureObject.add(object);
        }else if(object['objectId'] == AppConstants.levelObjectId){
          listOfLevelObject.add(object);
        }else if(object['objectId'] == AppConstants.irrigationLineObjectId){
          listOfIrrigationLineObject.add(object);
        }
      }

      // update general
      general = (defaultData['general'] as List<dynamic>).map((menu){
        dynamic oldValue;
        List<dynamic> generalOldData = constantOldData['general'] as List<dynamic>;
        if(generalOldData.any((oldSetting) => oldSetting['sNo'] == menu['sNo'])){
          oldValue = generalOldData.firstWhere((oldSetting) => oldSetting['sNo'] == menu['sNo'])['value'];
        }
        return ConstantSettingModel.fromJson(menu, oldValue);
      }).toList();

      // update globalAlarm
      globalAlarm = (defaultData['globalAlarm'] as List<dynamic>).map((menu){
        dynamic oldValue;
        List<dynamic> generalOldData = constantOldData['globalAlarm'] as List<dynamic>;
        if(generalOldData.any((oldSetting) => oldSetting['sNo'] == menu['sNo'])){
          oldValue = generalOldData.firstWhere((oldSetting) => oldSetting['sNo'] == menu['sNo'])['value'];
        }
        return ConstantSettingModel.fromJson(menu, oldValue);
      }).toList();
      if (kDebugMode) {
        print('global Alarm updated..');
      }

      // update normal and critical
      alarmOnStatus = generatePopUpItemModel(defaultData: defaultData, keyName: 'alarmOnStatus');
      alarmResetAfterIrrigation = generatePopUpItemModel(defaultData: defaultData, keyName: 'alarmResetAfterIrrigation');
      defaultNormalCriticalAlarmSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'normalCriticalAlarm');
      normalCriticalAlarm = listOfIrrigationLineObject.map((line){
        List<dynamic> lineData = (constantOldData['normalCriticalAlarm'] as List<dynamic>).where((oldLine) => oldLine['sNo'] == line['sNo']).toList();
        return NormalCriticalAlarmModel.fromJson(
            objectData: line,
            defaultSetting: defaultData['normalCriticalAlarm'],
            globalAlarm: defaultData['globalAlarm'],
            oldSetting: lineData.firstOrNull
        );
      }).toList();
      if (kDebugMode) {
        print('normalCriticalAlarm updated..');
    }
      // print("normalCriticalAlarm -- ${normalCriticalAlarm.map((alarm){
      //   return alarm.toJson();
      // }).toList()}");



      //update pump
      defaultPumpSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'pump');
      pump = generateObjectInConstantModel(listOfObject: listOfPumpObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'pump');
      if (kDebugMode) {
        print('pump updated..');
      }

      //update mainValve
      mainValveMode = generatePopUpItemModel(defaultData: defaultData, keyName: 'mainValveMode');
      defaultMainValveSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'mainValve');
      mainValve = generateObjectInConstantModel(listOfObject: listOfMainValveObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'mainValve');
      if (kDebugMode) {
        print('mainValve updated..');
      }

      // update valve
      defaultValveSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'valve');
      valve = generateObjectInConstantModel(listOfObject: listOfValveObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'valve');
      if (kDebugMode) {
        print('valve updated..');
      }

      // update waterMeter
      defaultWaterMeterSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'waterMeter');
      waterMeter = generateObjectInConstantModel(listOfObject: listOfWaterMeterObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'waterMeter');
      if (kDebugMode) {
        print('waterMeter updated..');
      }

      // update fertilizerSite
      fertilizerSiteControlFlag = generatePopUpItemModel(defaultData: defaultData, keyName: 'fertilizerSiteControlFlag');
      defaultFertilizerSiteSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'fertilizerSite');
      fertilizerSite = generateObjectInConstantModel(listOfObject: listOfFertilizerSiteObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'fertilizerSite');
      if (kDebugMode) {
        print('fertilizerSite updated..');
      }

      // update channel
      fertilizerChannelMode = generatePopUpItemModel(defaultData: defaultData, keyName: 'fertilizerChannelMode');
      defaultChannelSetting = generateDefaultSetting(defaultData: defaultData, keyName: "fertilizerChannel");
      channel = generateObjectInConstantModel(listOfObject: listOfChannelObject, defaultData: defaultData, constantOldData: constantOldData, keyName: "fertilizerChannel");
      if (kDebugMode) {
        print('channel updated..');
      }

      // update ec ph
      if(listOfFertilizerSiteObject.isNotEmpty){
        // find out and filter the fertilizer site has ec or ph
        defaultEcPhSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'ecPhSensor');
        List<dynamic> fertilizerSiteWithEcPh = listOfFertilizerSiteObject.where((site){
          bool ecAvailable = listOfEcObject.any((ecSensor) => ecSensor['location'] == site['sNo']);
          bool phAvailable = listOfPhObject.any((phSensor) => phSensor['location'] == site['sNo']);
          if(ecAvailable || phAvailable){
            return true;
          }else{
            return false;
          }
        }).toList();
        ecPhSensor = fertilizerSiteWithEcPh.map((site){
          return EcPhInConstantModel.fromJson(
              objectData: site,
              defaultSetting: defaultData["ecPhSensor"],
              oldSetting: constantOldData["ecPhSensor"],
              ec: listOfEcObject.where((ecSensor) => ecSensor['location'] == site['sNo']).toList(),
              ph: listOfPhObject.where((phSensor) => phSensor['location'] == site['sNo']).toList()
          );
        }).toList();
      }
      if (kDebugMode) {
        print('ecPh updated..');
      }

      // update moisture
      moistureMode = generatePopUpItemModel(defaultData: defaultData, keyName: 'moistureMode');
      defaultMoistureSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'moistureSensor');
      moisture = generateObjectInConstantModel(listOfObject: listOfMoistureObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'moistureSensor');
      if (kDebugMode) {
        print('moisture updated..');
      }

      // update level
      defaultLevelSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'levelSensor');
      level = generateObjectInConstantModel(listOfObject: listOfLevelObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'levelSensor');
      if (kDebugMode) {
        print('level updated..');
      }





    }catch(e, stackTrace){
      print('Error on update constant :: $e');
      print('stackTrace on update constant :: $stackTrace');
    }

    notifyListeners();
  }
}