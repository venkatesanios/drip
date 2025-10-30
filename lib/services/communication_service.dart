import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../StateManagement/customer_provider.dart';
import '../repository/repository.dart';
import '../utils/constants.dart';
import '../utils/network_utils.dart';
import '../utils/shared_preferences_helper.dart';
import 'bluetooth_service.dart';
import 'http_service.dart';
import 'mqtt_service.dart';

class CommunicationService {
  final MqttService mqttService;
  final BluService blueService;
  final CustomerProvider customerProvider;

  CommunicationService({
    required this.mqttService,
    required this.blueService,
    required this.customerProvider,
  });

  Future<Map<String, bool>> sendCommand({required String serverMsg,
    required String payload}) async {
    final result = {
      'http': false,
      'mqtt': false,
      'bluetooth': false,
    };

    try {
      if (payload.isEmpty) {
        throw Exception('Payload is empty');
      }

      if (mqttService.isConnected) {
        try {
          final topic = '${AppConstants.publishTopic}/${customerProvider.deviceId}';
          debugPrint('Publishing to topic: $topic with payload: $payload');
          await mqttService.topicToPublishAndItsMessage(payload, topic);
          result['mqtt'] = true;
        } catch (e) {
          debugPrint('Failed to send via MQTT: $e');
        }
      }

      if (NetworkUtils.isOnline && serverMsg.isNotEmpty) {
        try {
          await sendCommandToServer(serverMsg, payload);
          result['http'] = true;
        } catch (e) {
          debugPrint('Failed to send via HTTP: $e');
        }
      }

      if (blueService.isConnected == true) {
        try {
          blueService.write(payload);
          result['bluetooth'] = true;
        } catch (e) {
          debugPrint('Failed to send via Bluetooth: $e');
        }
      }

    } catch (e) {
      debugPrint('Unexpected error during sending command: $e');
    }

    return result;
  }


  Future<void> sendCommandToServer(String msg, String data) async {
    Map<String, dynamic> hardware;
    try {
      hardware = jsonDecode(data);
    } catch (e) {
      throw Exception('Invalid JSON in payload: $e');
    }

    int? userId = await PreferenceHelper.getUserId();


    final body = {
      "userId": customerProvider.customerId,
      "controllerId": customerProvider.controllerId,
      "messageStatus": msg,
      "hardware": hardware,
      "createUser": userId,
    };

    final response = await Repository(HttpService()).sendManualOperationToServer(body);

    if (response.statusCode == 200) {
      debugPrint('HTTP Response: ${response.body}');
    } else {
      debugPrint('HTTP Error (${response.statusCode}): ${response.body}');
      throw Exception('Failed to send via HTTP');
    }
  }
}