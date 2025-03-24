import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../services/mqtt_service.dart';
import '../../utils/constants.dart';

class NodeListViewModel extends ChangeNotifier {

  late MqttPayloadProvider payloadProvider;

  final mqttService = MqttService();
  final List<NodeListModel> nodeList;

  List<dynamic> _previousLiveMessage = [];
  List<dynamic> _previousRelayStatus = [];

  NodeListViewModel(BuildContext context, this.nodeList) {
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
  }

  bool shouldUpdate(List<dynamic> newLiveMessage, List<dynamic> newRelayStatus) {
    if (!listEquals(_previousLiveMessage, newLiveMessage) ||
        !listEquals(_previousRelayStatus, newRelayStatus)) {
      _previousLiveMessage = List.from(newLiveMessage);
      _previousRelayStatus = List.from(newRelayStatus);
      return true;
    }
    return false;
  }

  void onLivePayloadReceived(List<String> nodeLiveMeg, List<String> inputOutputStatus){

    print('node live recived');

    for (String group in nodeLiveMeg) {
      List<String> values = group.split(",");
      int sNo = int.parse(values[0]);
      for (var node in nodeList) {
        if (node.serialNumber == sNo) {
          node.sVolt = double.parse(values[1]);
          node.batVolt = double.parse(values[2]);
          node.status = int.parse(values[3]);
          node.lastFeedbackReceivedTime = values[4];
          break;
        }
      }
    }

    for (String group in inputOutputStatus) {
      List<String> values = group.split(",");
      if (values.length < 2) continue;

      String relaySNo = values[0];
      int relayStatus = int.parse(values[1]);
      for (var node in nodeList) {
        for (var relay in node.rlyStatus) {
          if (relay.sNo.toString() == relaySNo) {
            relay.status = relayStatus;
            break;
          }
        }
      }
    }

    //payloadProvider.nodeLiveMessage.clear();
    //payloadProvider.outputStatusPayload.clear();

    notifyListeners();
  }


  double calculateDynamicHeight(NodeListModel node) {
    double baseHeight = 110;
    double additionalHeight = 0;

    if (node.rlyStatus.isNotEmpty) {
      additionalHeight += calculateGridHeight(node.rlyStatus.length);
    }
    /*if (node.sensor.isNotEmpty) {
      additionalHeight += calculateGridHeight(node.sensor.length);
    }*/
    return baseHeight + additionalHeight;
  }

  double calculateGridHeight(int itemCount) {
    int rows = (itemCount / 5).ceil();
    return rows * 53;
  }

  String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) {
      return "No feedback received";
    }
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return "Invalid date format";
    }
  }

  String mapInterfaceType(String interface) {
    switch (interface) {
      case "RS485":
        return "Wired";
      case "LoRa":
        return "Wireless";
      case "MQTT":
        return "GSM";
      default:
        return interface;
    }
  }

  Future<void> showEditProductDialog(BuildContext context, String nodeName, int nodeId, int index) async {
    final TextEditingController nodeNameController = TextEditingController(text: nodeName);
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Node Name'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nodeNameController,
              maxLength: 15,
              decoration: const InputDecoration(hintText: "Enter node name"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Node name cannot be empty';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  //Map<String, Object> body = {"userId": customerId, "controllerId": controllerId, "nodeControllerId": nodeId, "deviceName": nodeNameController.text, "createUser": userId};
                  /* final response = await HttpService().putRequest("updateUserNodeDetails", body);
                  if (response.statusCode == 200) {
                    setState(() {
                      widget.nodeList[index].deviceName = nodeNameController.text;
                    });
                    GlobalSnackBar.show(context, 'Node name updated successfully', 200);
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                    throw Exception('Failed to load data');
                  }*/
                }
              },
            ),
          ],
        );
      },
    );
  }

  bool getPermissionStatusBySNo(BuildContext context, int sNo) {
    return true;
  }

  void setSerialToAllNodes(deviceId){
    Future.delayed(const Duration(milliseconds: 1000), () {
      String payLoadFinal = jsonEncode({
        "2300": {"2301": ""}
      });
      MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
      //sentToServer('Set serial for all nodes comment sent successfully', payLoadFinal);
    });
  }

  void testCommunication(deviceId){
    Future.delayed(const Duration(milliseconds: 1000), () {
      String payLoadFinal = jsonEncode({
        "4500": {"4501": ""}
      });
      MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
      //sentToServer('Test Communication comment sent successfully', payLoadFinal);
    });
  }

  void actionSerialSet(int index, deviceId){
    Future.delayed(const Duration(milliseconds: 1000), () {
      String payLoadFinal = jsonEncode({
        "2300": {"2301": "${nodeList[index].serialNumber}"}
      });
      MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
      //sentToServer('Serial set for the ${nodeList[index].deviceName} all Relay', payLoadFinal);
    });
  }

}