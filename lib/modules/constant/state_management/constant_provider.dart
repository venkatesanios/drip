import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:oro_drip_irrigation/modules/constant/model/constant_menu_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/constant_setting_model.dart';
import 'package:oro_drip_irrigation/modules/constant/model/ec_ph_in_constant_model.dart';
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
      "filtration": [],
      "fertilizerSite": [],
      "channel": [],
      "ecPh" : [],
      "analogSensor": [],
      "moistureSensor": [
        {
          "objectId": 25,
          "objectIds": 0,
          "sNo": 25.001,
          "name": "Moisture Sensor 1",
          "connectionNo": 1,
          "objectName": "Moisture Sensor",
          "type": "5",
          "controllerId": 15,
          "count": 0,
          "connectedObject": {},
          "siteMode": "",
          "valves": [],
          "highLow": "Primary",
          "units": "Bar",
          "base": "Current",
          "min": 5,
          "max": 10
        },
        {
          "objectId": 25,
          "objectIds": 0,
          "sNo": 25.002,
          "name": "Moisture Sensor 2",
          "connectionNo": 2,
          "objectName": "Moisture Sensor",
          "type": "5",
          "controllerId": 15,
          "count": 0,
          "connectedObject": {},
          "siteMode": "",
          "valves": [],
          "highLow": "Secondary",
          "units": "Bar",
          "base": "Current",
          "min": 5,
          "max": 10
        },
        {
          "objectId": 25,
          "objectIds": 0,
          "sNo": 25.003,
          "name": "Moisture Sensor 3",
          "connectionNo": 3,
          "objectName": "Moisture Sensor",
          "type": "5",
          "controllerId": 15,
          "count": 0,
          "connectedObject": {},
          "siteMode": "",
          "valves": [],
          "highLow": "Primary",
          "units": "Bar",
          "base": "Current",
          "min": 5,
          "max": 10
        },
        {
          "objectId": 25,
          "objectIds": 0,
          "sNo": 25.004,
          "name": "Moisture Sensor 4",
          "connectionNo": 4,
          "objectName": "Moisture Sensor",
          "type": "5",
          "controllerId": 15,
          "count": 0,
          "connectedObject": {},
          "siteMode": "",
          "valves": [],
          "highLow": "Secondary",
          "units": "Bar",
          "base": "Current",
          "min": 0,
          "max": 0
        },
        {
          "objectId": 25,
          "objectIds": 0,
          "sNo": 25.005,
          "name": "Moisture Sensor 5",
          "connectionNo": 1,
          "objectName": "Moisture Sensor",
          "type": "5",
          "controllerId": 21,
          "count": 0,
          "connectedObject": {},
          "siteMode": "",
          "valves": [],
          "highLow": "-",
          "units": "Bar",
          "base": "Current",
          "min": 0,
          "max": 0
        },
        {
          "objectId": 25,
          "objectIds": 0,
          "sNo": 25.006,
          "name": "Moisture Sensor 6",
          "connectionNo": 2,
          "objectName": "Moisture Sensor",
          "type": "5",
          "controllerId": 21,
          "count": 0,
          "connectedObject": {},
          "siteMode": "",
          "valves": [],
          "highLow": "-",
          "units": "Bar",
          "base": "Current",
          "min": 0,
          "max": 0
        },
        {
          "objectId": 25,
          "objectIds": 0,
          "sNo": 25.007,
          "name": "Moisture Sensor 7",
          "connectionNo": 3,
          "objectName": "Moisture Sensor",
          "type": "5",
          "controllerId": 21,
          "count": 0,
          "connectedObject": {},
          "siteMode": "",
          "valves": [],
          "highLow": "-",
          "units": "Bar",
          "base": "Current",
          "min": 0,
          "max": 0
        },
        {
          "objectId": 25,
          "objectIds": 0,
          "sNo": 25.008,
          "name": "Moisture Sensor 8",
          "connectionNo": 4,
          "objectName": "Moisture Sensor",
          "type": "5",
          "controllerId": 21,
          "count": 0,
          "connectedObject": {},
          "siteMode": "",
          "valves": [],
          "highLow": "-",
          "units": "Bar",
          "base": "Current",
          "min": 0,
          "max": 0
        }
      ],
      "levelSensor": [
        {
          "objectId": 26,
          "sensorId": 0,
          "sNo": 26.001,
          "name": "Level Sensor 1",
          "connectionNo": 1,
          "objectName": "Level Sensor",
          "type": "3",
          "controllerId": 7,
          "highLow": "Primary",
          "units": "Bar",
          "base": "Current",
          "min": 5,
          "max": 0,
          "height": 5
        },
        {
          "objectId": 26,
          "sensorId": 0,
          "sNo": 26.002,
          "name": "Level Sensor 2",
          "connectionNo": 2,
          "objectName": "Level Sensor",
          "type": "3",
          "controllerId": 10,
          "highLow": "Secondary",
          "units": "ds/m",
          "base": "Voltage",
          "min": 10,
          "max": 0,
          "height": 10
        }
      ],
      "normalAlarm": [],
      "criticalAlarm": [
        {
          "name": "LOW FLOW",
          "scanTime": "00:05:00",
          "alarmOnStatus": "Skip Irrigation",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "10",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "LOW FLOW",
          "scanTime": "00:01:00",
          "alarmOnStatus": "Stop Irrigation",
          "resetAfterIrrigation": "Yes",
          "autoResetDuration": "00:00:50",
          "threshold": "20",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "HIGH FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "HIGH FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "NO FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "NO FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "EC HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "EC HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PH LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PH LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PRESSURE LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PRESSURE LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PRESSURE HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PRESSURE HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "NO POWER SUPPLY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "NO POWER SUPPLY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "WRONG FEEDBACK",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "WRONG FEEDBACK",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "SUMP EMPTY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "SUMP EMPTY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "TANK FULL",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "TANK FULL",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "LOW BATTERY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "LOW BATTERY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "EC DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "EC DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PH DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PH DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PUMP OFF ALARM",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PUMP OFF ALARM",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PRESSURE SWITCH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PRESSURE SWITCH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "WIRED NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "WIRED NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "100",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "LOW FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "LOW FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "HIGH FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "HIGH FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "NO FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "NO FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "EC HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "EC HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PH LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PH LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PRESSURE LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PRESSURE LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PRESSURE HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PRESSURE HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "NO POWER SUPPLY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "NO POWER SUPPLY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "WRONG FEEDBACK",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "WRONG FEEDBACK",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "SUMP EMPTY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "SUMP EMPTY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "TANK FULL",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "TANK FULL",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "LOW BATTERY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "LOW BATTERY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "EC DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "EC DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PH DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PH DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PUMP OFF ALARM",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PUMP OFF ALARM",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PRESSURE SWITCH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PRESSURE SWITCH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "WIRED NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "WIRED NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "LOW FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "LOW FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "HIGH FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "HIGH FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "NO FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "NO FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "EC HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "EC HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PH LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PH LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PRESSURE LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PRESSURE LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PRESSURE HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PRESSURE HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "NO POWER SUPPLY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "NO POWER SUPPLY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "WRONG FEEDBACK",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "WRONG FEEDBACK",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "SUMP EMPTY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "SUMP EMPTY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "TANK FULL",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "TANK FULL",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "LOW BATTERY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "LOW BATTERY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "EC DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "EC DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PH DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PH DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PUMP OFF ALARM",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PUMP OFF ALARM",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PRESSURE SWITCH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PRESSURE SWITCH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "WIRED NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "WIRED NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "LOW FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "LOW FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "HIGH FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "HIGH FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "NO FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "NO FLOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "EC HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "EC HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PH LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PH LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PRESSURE LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PRESSURE LOW",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PRESSURE HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PRESSURE HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "NO POWER SUPPLY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "NO POWER SUPPLY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "WRONG FEEDBACK",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "WRONG FEEDBACK",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "SUMP EMPTY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "SUMP EMPTY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "TANK FULL",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "TANK FULL",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "LOW BATTERY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "LOW BATTERY",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "EC DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "EC DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PH DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PH DIFFERENCE",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PUMP OFF ALARM",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PUMP OFF ALARM",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "PRESSURE SWITCH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "PRESSURE SWITCH HIGH",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        },
        {
          "name": "WIRED NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Normal"
        },
        {
          "name": "WIRED NO COMMUNICATION",
          "scanTime": "00:00:00",
          "alarmOnStatus": "Do Nothing",
          "resetAfterIrrigation": "No",
          "autoResetDuration": "00:00:00",
          "threshold": "0",
          "unit": "%",
          "type": "Critical"
        }
      ],
      "globalAlarm": [
        {
          "name": "LOW FLOW",
          "value": false
        },
        {
          "name": "HIGH FLOW",
          "value": false
        },
        {
          "name": "NO FLOW",
          "value": false
        },
        {
          "name": "EC HIGH",
          "value": false
        },
        {
          "name": "PH LOW",
          "value": true
        },
        {
          "name": "PH HIGH",
          "value": true
        },
        {
          "name": "PRESSURE LOW",
          "value": true
        },
        {
          "name": "PRESSURE HIGH",
          "value": false
        },
        {
          "name": "NO POWER SUPPLY",
          "value": true
        },
        {
          "name": "NO COMMUNICATION",
          "value": false
        },
        {
          "name": "WRONG FEEDBACK",
          "value": false
        },
        {
          "name": "SUMP EMPTY",
          "value": false
        },
        {
          "name": "TANK FULL",
          "value": false
        },
        {
          "name": "LOW BATTERY",
          "value": false
        },
        {
          "name": "EC DIFFERENCE",
          "value": false
        },
        {
          "name": "PH DIFFERENCE",
          "value": false
        },
        {
          "name": "PUMP OFF ALARM",
          "value": false
        },
        {
          "name": "PRESSURE SWITCH HIGH",
          "value": false
        },
        {
          "name": "WIRED NO COMMUNICATION",
          "value": false
        },
        {
          "name": "LOW FLOW",
          "value": false
        },
        {
          "name": "HIGH FLOW",
          "value": false
        },
        {
          "name": "NO FLOW",
          "value": false
        },
        {
          "name": "EC HIGH",
          "value": false
        },
        {
          "name": "PH LOW",
          "value": false
        },
        {
          "name": "PH HIGH",
          "value": false
        },
        {
          "name": "PRESSURE LOW",
          "value": false
        },
        {
          "name": "PRESSURE HIGH",
          "value": false
        },
        {
          "name": "NO POWER SUPPLY",
          "value": false
        },
        {
          "name": "NO COMMUNICATION",
          "value": false
        },
        {
          "name": "WRONG FEEDBACK",
          "value": false
        },
        {
          "name": "SUMP EMPTY",
          "value": false
        },
        {
          "name": "TANK FULL",
          "value": false
        },
        {
          "name": "LOW BATTERY",
          "value": false
        },
        {
          "name": "EC DIFFERENCE",
          "value": false
        },
        {
          "name": "PH DIFFERENCE",
          "value": false
        },
        {
          "name": "PUMP OFF ALARM",
          "value": false
        },
        {
          "name": "PRESSURE SWITCH HIGH",
          "value": false
        },
        {
          "name": "WIRED NO COMMUNICATION",
          "value": false
        },
        {
          "name": "LOW FLOW",
          "value": false
        },
        {
          "name": "HIGH FLOW",
          "value": false
        },
        {
          "name": "NO FLOW",
          "value": false
        },
        {
          "name": "EC HIGH",
          "value": false
        },
        {
          "name": "PH LOW",
          "value": false
        },
        {
          "name": "PH HIGH",
          "value": false
        },
        {
          "name": "PRESSURE LOW",
          "value": false
        },
        {
          "name": "PRESSURE HIGH",
          "value": false
        },
        {
          "name": "NO POWER SUPPLY",
          "value": false
        },
        {
          "name": "NO COMMUNICATION",
          "value": false
        },
        {
          "name": "WRONG FEEDBACK",
          "value": false
        },
        {
          "name": "SUMP EMPTY",
          "value": false
        },
        {
          "name": "TANK FULL",
          "value": false
        },
        {
          "name": "LOW BATTERY",
          "value": false
        },
        {
          "name": "EC DIFFERENCE",
          "value": false
        },
        {
          "name": "PH DIFFERENCE",
          "value": false
        },
        {
          "name": "PUMP OFF ALARM",
          "value": false
        },
        {
          "name": "PRESSURE SWITCH HIGH",
          "value": false
        },
        {
          "name": "WIRED NO COMMUNICATION",
          "value": false
        }
      ],
      "controllerReadStatus": "0"
    },
    "default": {
      "alarm": [
        {
          "sNo": 1,
          "title": "LOW FLOW",
          "unit": "%",
          "value": false
        },
        {
          "sNo": 2,
          "title": "HIGH FLOW",
          "unit": "%",
          "value": false
        },
        {
          "sNo": 3,
          "title": "NO FLOW",
          "unit": "",
          "value": false
        },
        {
          "sNo": 4,
          "title": "EC HIGH",
          "unit": "delta",
          "value": false
        },
        {
          "sNo": 5,
          "title": "PH LOW",
          "unit": "delta",
          "value": false
        },
        {
          "sNo": 6,
          "title": "PH HIGH",
          "unit": "delta",
          "value": false
        },
        {
          "sNo": 7,
          "title": "PRESSURE LOW",
          "unit": "bar",
          "value": false
        },
        {
          "sNo": 8,
          "title": "PRESSURE HIGH",
          "unit": "bar",
          "value": false
        },
        {
          "sNo": 9,
          "title": "NO POWER SUPPLY",
          "unit": "",
          "value": false
        },
        {
          "sNo": 10,
          "title": "NO COMMUNICATION",
          "unit": "",
          "value": false
        },
        {
          "sNo": 11,
          "title": "WRONG FEEDBACK",
          "unit": "",
          "value": false
        },
        {
          "sNo": 12,
          "title": "SUMP EMPTY",
          "unit": "",
          "value": false
        },
        {
          "sNo": 13,
          "title": "TANK FULL",
          "unit": "",
          "value": false
        },
        {
          "sNo": 14,
          "title": "LOW BATTERY",
          "unit": "",
          "value": false
        },
        {
          "sNo": 15,
          "title": "EC DIFFERENCE",
          "unit": "",
          "value": false
        },
        {
          "sNo": 16,
          "title": "PH DIFFERENCE",
          "unit": "",
          "value": false
        },
        {
          "sNo": 17,
          "title": "PUMP OFF ALARM",
          "unit": "",
          "value": false
        },
        {
          "sNo": 18,
          "title": "PRESSURE SWITCH HIGH",
          "unit": "",
          "value": false
        },
        {
          "sNo": 19,
          "title": "WIRED NO COMMUNICATION",
          "unit": "",
          "value": false
        }
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
      "mainValveMode" : [
        {'sNo' : 1, 'title' : 'No Delay', 'color' : '0xff6B6B6B'},
        {'sNo' : 2, 'title' : 'Open Before', 'color' : '0xff0070D8'},
        {'sNo' : 3, 'title' : 'Open After', 'color' : '0xff14AE5C'},
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
      "fertilizerControlFlag" : [
        {'sNo' : 1, 'title' : 'Stop Faulty Fertilizer', 'color' : '0xffEB7C17'},
        {'sNo' : 2, 'title' : 'Stop Fertigation', 'color' : '0xffE73293'},
        {'sNo' : 3, 'title' : 'Stop Irrigation', 'color' : '0xff0070D8'},
        {'sNo' : 4, 'title' : 'Inform Only', 'color' : '0xff14AE5C'},
      ],
      "channel" : [
        {"sNo":1,"title":"Flow Rate","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true},
        {"sNo":2,"title":"Injector Mode","widgetTypeId":6,"dataType":"int","value":1,"hidden":false,"software":true,"hardware":true},
        {"sNo":3,"title":"Ratio","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true},
        {"sNo":4,"title":"Shortest Pulse","widgetTypeId":1,"dataType":"int","value":0,"hidden":false,"software":true,"hardware":true}
      ],
      "channelMode" : [
        {'sNo' : 1, 'title' : 'Regular', 'color' : '0xff0070D8'},
        {'sNo' : 2, 'title' : 'Ph Control', 'color' : '0xffEB7C17'},
        {'sNo' : 3, 'title' : 'Ec Control', 'color' : '0xffE73293'},
        {'sNo' : 4, 'title' : 'Concentration', 'color' : '0xff14AE5C'},
      ],
      "ecPh" : [
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
          "parameter": "Channel",
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
  List<ObjectInConstantModel> pump = [];
  List<ObjectInConstantModel> mainValve = [];
  List<ObjectInConstantModel> valve = [];
  List<ObjectInConstantModel> waterMeter = [];
  List<ObjectInConstantModel> fertilizerSite = [];
  List<ObjectInConstantModel> channel = [];
  List<EcPhInConstantModel> ecPh = [];
  List<ConstantSettingModel> defaultPumpSetting = [];
  List<ConstantSettingModel> defaultMainValveSetting = [];
  List<ConstantSettingModel> defaultValveSetting = [];
  List<ConstantSettingModel> defaultWaterMeterSetting = [];
  List<ConstantSettingModel> defaultFertilizerSiteSetting = [];
  List<ConstantSettingModel> defaultChannelSetting = [];
  List<ConstantSettingModel> defaultEcPhSetting = [];
  List<PopUpItemModel> mainValveMode = [];
  List<PopUpItemModel> fertilizerControlFlag = [];
  List<PopUpItemModel> channelMode = [];

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
            arrowTabState: menu['dealerDefinitionId'] == 82 ? ArrowTabState.onProgress : ArrowTabState.inComplete
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
      fertilizerControlFlag = generatePopUpItemModel(defaultData: defaultData, keyName: 'fertilizerControlFlag');
      defaultFertilizerSiteSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'fertilizerSite');
      fertilizerSite = generateObjectInConstantModel(listOfObject: listOfFertilizerSiteObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'fertilizerSite');
      if (kDebugMode) {
        print('fertilizerSite updated..');
      }

      // update channel
      channelMode = generatePopUpItemModel(defaultData: defaultData, keyName: 'channelMode');
      defaultChannelSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'channel');
      channel = generateObjectInConstantModel(listOfObject: listOfChannelObject, defaultData: defaultData, constantOldData: constantOldData, keyName: 'channel');
      if (kDebugMode) {
        print('channel updated..');
      }

      // update ec ph
      if(listOfFertilizerSiteObject.isNotEmpty){
        // find out and filter the fertilizer site has ec or ph
        defaultEcPhSetting = generateDefaultSetting(defaultData: defaultData, keyName: 'ecPh');
        List<dynamic> fertilizerSiteWithEcPh = listOfFertilizerSiteObject.where((site){
          bool ecAvailable = listOfEcObject.any((ecSensor) => ecSensor['location'] == site['sNo']);
          bool phAvailable = listOfPhObject.any((phSensor) => phSensor['location'] == site['sNo']);
          if(ecAvailable || phAvailable){
            return true;
          }else{
            return false;
          }
        }).toList();
        print("defaultData['ecPh'] : ${defaultData['ecPh']}");
        print("constantOldData['ecPh'] : ${constantOldData['ecPh']}");
        ecPh = fertilizerSiteWithEcPh.map((site){
          return EcPhInConstantModel.fromJson(
              objectData: site,
              defaultSetting: defaultData['ecPh'],
              oldSetting: constantOldData['ecPh'],
              ec: listOfEcObject.where((ecSensor) => ecSensor['location'] == site['sNo']).toList(),
              ph: listOfPhObject.where((phSensor) => phSensor['location'] == site['sNo']).toList()
          );
        }).toList();
      }
      var printEcPhList = ecPh.map((ecPhSetting) => ecPhSetting.toJson()).toList();
      print('ecPh data :: ${jsonEncode(printEcPhList)}');
      if (kDebugMode) {
        print('ecPh updated..');
      }



    }catch(e, stackTrace){
      print('Error on update constant :: $e');
      print('stackTrace on update constant :: $stackTrace');
    }

    notifyListeners();
  }
}