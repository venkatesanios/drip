import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../services/mqtt_service.dart';
import '../../../utils/environment.dart';

class PayloadProgressDialog extends StatefulWidget {
  final List<String> payloads;
  final String deviceId;
  final bool isToGem;
  final MqttService mqttService;

  const PayloadProgressDialog({
    required this.payloads,
    required this.deviceId,
    required this.isToGem,
    required this.mqttService,
  });

  @override
  _PayloadProgressDialogState createState() => _PayloadProgressDialogState();
}

class _PayloadProgressDialogState extends State<PayloadProgressDialog> {
  late List<Map<String, dynamic>> payloadStatuses;
  bool breakLoop = false;

  @override
  void initState() {
    super.initState();
    payloadStatuses = widget.payloads.map((payload) => {
      'payload': payload,
      'status': 'Pending',
      'reference': widget.isToGem ? 'Device ${payload.split('+')[2]}' : 'Device',
    }).toList();
    _processPayloads();
  }

  Future<void> _processPayloads() async {
    for (int i = 0; i < widget.payloads.length && !breakLoop; i++) {
      var payload = widget.payloads[i];
      var payloadToDecode = widget.isToGem ? payload.split('+')[4] : payload;
      var decodedData = jsonDecode(payloadToDecode);
      var key = decodedData.keys.first;

      setState(() {
        payloadStatuses[i]['status'] = 'Sending';
      });

      bool isAcknowledged = await _waitForControllerResponse(payload, key, i);

      setState(() {
        payloadStatuses[i]['status'] = isAcknowledged ? 'Sent' : 'Failed';
      });

      if (!isAcknowledged) {
        breakLoop = true;
        break;
      }
    }
  }

  Future<bool> _waitForControllerResponse(String payload, String key, int index) async {
    try {
      Map<String, dynamic> gemPayload = {};
      if (widget.isToGem) {
        gemPayload = {
          "5900": [
            {"5901": payload},
            {"5902": "userId"}, // Replace with actual userId
          ]
        };
      }

      await widget.mqttService.topicToPublishAndItsMessage(
        widget.isToGem ? jsonEncode(gemPayload) : jsonDecode(payload)[key],
        "${Environment.mqttPublishTopic}/${widget.deviceId}",
      );

      bool isAcknowledged = false;
      int maxWaitTime = 10;
      int elapsedTime = 0;

      await for (var mqttMessage in widget.mqttService.preferenceAck) {
        if (elapsedTime >= maxWaitTime || breakLoop) break;

        if (mqttMessage['cM'].contains(key) &&
            (widget.isToGem ? mqttMessage['cC'] == payload.split('+')[2] : true)) {
          isAcknowledged = true;
          break;
        }

        await Future.delayed(const Duration(seconds: 1));
        elapsedTime++;
      }

      return isAcknowledged;
    } catch (error) {
      print(error);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Processing Payloads", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 200, // Adjust height as needed
            width: 300,
            child: ListView.builder(
              itemCount: payloadStatuses.length,
              itemBuilder: (context, index) {
                var status = payloadStatuses[index];
                return ListTile(
                  leading: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: status['status'] == 'Sent'
                          ? Colors.green
                          : (status['status'] == 'Failed' ? Colors.red : Colors.blue),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  title: Text("Payload for ${status['reference']}"),
                  subtitle: Text("Status: ${status['status']}"),
                );
              },
            ),
          ),
          LinearProgressIndicator(
            value: payloadStatuses.where((p) => p['status'] != 'Pending').length / payloadStatuses.length,
          ),
          const SizedBox(height: 5),
          Text('${payloadStatuses.where((p) => p['status'] != 'Pending').length}/${payloadStatuses.length}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              breakLoop = true;
            });
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}