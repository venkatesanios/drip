import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/views/customer/hourly_log/node_hourly_logs.dart';
import '../../models/customer/site_model.dart';
import '../../repository/repository.dart';

class NodeHourlyLogsVm extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";
  int customerId, controllerId;
  final List<NodeListModel> nodeList;

  Map<String, List<ChartDataLog>> nodeDataMap = {};
  DateTime selectedDate = DateTime.now();

  NodeHourlyLogsVm(this.repository, this.customerId, this.controllerId, this.nodeList);


  Future<void> getNodeLogs(date) async {
    print(nodeList.toList());
    date = DateFormat('yyyy-MM-dd').format(selectedDate);

    Map<String, Object> body = {
      "userId": customerId,
      "controllerId": controllerId,
      "fromDate": date,
      "toDate": date
    };

    var response = await repository.fetchNodeHourlyData(body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["code"] == 200) {
        final jsonData = data["data"] as List;

        try {
          nodeDataMap.clear();

          for (var hourEntry in jsonData[0].entries) {
            String hour = hourEntry.key;
            String value = hourEntry.value;

            if (hour != 'date' && value.isNotEmpty) {
              List<String> nodeStrings = value.split(';');

              for (var nodeStr in nodeStrings) {
                List<String> parts = nodeStr.split(',');
                if (parts.length == 3) {
                  String nodeId = parts[0];
                  double solarVoltage = double.tryParse(parts[1]) ?? 0.0;
                  double batteryVoltage = double.tryParse(parts[2]) ?? 0.0;

                  var matchedNode = nodeList.firstWhere(
                        (node) => node.serialNumber == int.parse(nodeId),
                  );

                  String deviceName = matchedNode.deviceName;
                  String deviceId = matchedNode.deviceId;

                  if (!nodeDataMap.containsKey(deviceId)) {
                    nodeDataMap[deviceId] = [];
                  }

                  nodeDataMap[deviceId]!.add(
                    ChartDataLog(
                      deviceName,
                      hour,
                      batteryVoltage,
                      solarVoltage,
                    ),
                  );
                }
              }
            }
          }

          notifyListeners();

        } catch (e) {
          print('Error parsing node logs: $e');
        }
      }
    } else {
      print('Error fetching data: ${response.body}');
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
      getNodeLogs(selectedDate);
    }
  }

}