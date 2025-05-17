import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:intl/intl.dart';
import '../../models/customer/site_model.dart';
import '../../repository/repository.dart';

class SensorHourlyLogsVm extends ChangeNotifier {
  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";
  int customerId, controllerId;

  final Map<String, List<SensorHourlyData>> sensorsBySNo = {};

  final List<ConfigObject> configObjects;

  DateTime selectedDate = DateTime.now();

  SensorHourlyLogsVm(this.repository, this.customerId, this.controllerId, this.configObjects);

  Future<void> getSensorHourlyLogs(date) async {
    sensorsBySNo.clear();
    date = DateFormat('yyyy-MM-dd').format(selectedDate);


    Map<String, Object> body = {
      "userId": customerId,
      "controllerId": controllerId,
      "fromDate": date,
      "toDate": date,
    };

    var response = await repository.fetchSensorHourlyData(body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["code"] == 200) {
        final jsonData = data["data"] as List;

        if (jsonData.isEmpty) return;

        try {
          for (var hourEntry in jsonData[0].entries) {
            final hour = hourEntry.key;
            final value = hourEntry.value;

            if (hour != 'date' && value.isNotEmpty) {
              final sensorStrings = value.split(';');

              for (final sensorStr in sensorStrings) {
                final parts = sensorStr.split(',');
                if (parts.length == 3) {
                  double sNo = double.parse(parts[0]);
                  final val1 = double.tryParse(parts[1]) ?? 0.0;

                  var matchedNode = configObjects.firstWhere(
                        (obj) => obj.sNo == sNo,
                  );

                  String sensorName = matchedNode.name;
                  String objectName = matchedNode.objectName;


                  final sensorData = SensorHourlyData(
                    sNo: sNo,
                    hour: hour,
                    objectName: objectName,
                    value: val1,
                    name: sensorName,
                  );

                  sensorsBySNo.putIfAbsent(sNo.toString(), () => []);
                  sensorsBySNo[sNo.toString()]!.add(sensorData);
                }
              }
            }
          }

          notifyListeners();
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }

  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      getSensorHourlyLogs(selectedDate);
    }
  }

}

class SensorHourlyData {
  final double sNo;
  final String? name;
  final String objectName;
  final double? value;
  final String hour;

  SensorHourlyData({
    required this.objectName,
    required this.value,
    required this.hour,
    required this.name,
    required this.sNo,
  });

  factory SensorHourlyData.fromJson(Map<String, dynamic> json) {
    String snrName;

    if (json['Valve'] == null || json['Valve'].toString().isEmpty) {
      snrName = '${json['Name'] ?? json['Id']}';
    } else {
      snrName = '${json['Name'] ?? json['Id']}(${json['Valve']})';
    }

    return SensorHourlyData(
      sNo: json['SNo'],
      name: snrName,
      objectName: json['objectName'] as String,
      value: (json['Value'] is num)
          ? (json['Value'] as num).toDouble()
          : double.tryParse(json['Value'].toString()) ?? 0.0,
      hour: json['hour'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'objectName': objectName,
      'Value': value,
      'hour': hour,
      'sNo': sNo,
    };
  }
}
