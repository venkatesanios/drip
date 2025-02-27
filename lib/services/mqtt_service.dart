import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../utils/constants.dart';
import '../view_models/customer/customer_screen_controller_view_model.dart';

enum MQTTConnectionState {connected, disconnected, connecting}

class MqttService {
  static MqttService? _instance;
  CustomerScreenControllerViewModel? viewModelState;
  MqttBrowserClient? _client;
  String? currentTopic;


  factory MqttService() {
    _instance ??= MqttService._internal();
    return _instance!;
  }

  final StreamController<String> liveMessageStreamController = StreamController.broadcast();
  Stream<String> get liveMessageStream => liveMessageStreamController.stream;

  MqttService._internal();
  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;

  void initializeMQTTClient({CustomerScreenControllerViewModel? state}) {

    String uniqueId = 'uniqueId1234567890';//const Uuid().v4();

    if (_client == null) {
      viewModelState = state;
      _client = MqttBrowserClient(AppConstants.mqttUrl, uniqueId);
      _client!.port = AppConstants.mqttPort;
      _client!.keepAlivePeriod = 30;
      _client!.onDisconnected = onDisconnected;
      _client!.logging(on: false);
      _client!.onConnected = onConnected;
      _client!.onSubscribed = onSubscribed;
      _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(uniqueId)
          .withWillTopic('will-topic')
          .withWillMessage('My Will message')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      debugPrint('Mosquitto client connecting....');
      _client!.connectionMessage = connMess;
    }
  }

  void connect() async {
    assert(_client != null);
    if (!isConnected) {
      try {
        debugPrint('Mosquitto start client connecting....');
        viewModelState?.changeMQTTConnectionState(MQTTConnectionState.connecting);
        await _client!.connect();
      } on Exception catch (e, stackTrace) {
        debugPrint('Client exception - $e');
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  void topicToSubscribe(String topic) {

    if (currentTopic != null) {
      _client!.unsubscribe(currentTopic!);
    }

    Future.delayed(const Duration(milliseconds: 1000), () {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
      currentTopic = topic;
    });

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      onMqttPayloadReceived(pt);
    });
  }

  void onMqttPayloadReceived(String payload) {
    try {
      Map<String, dynamic> payloadMessage = jsonDecode(payload);
      if (payloadMessage['mC']=='2400') {
        liveMessageStreamController.add(payload);
      }
    } catch (e) {
      debugPrint('Error parsing MQTT payload: $e');
    }
  }

  topicToPublishAndItsMessage(String message, String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void onSubscribed(String topic) {
    debugPrint('Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    debugPrint('OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode == MqttConnectReturnCode.noneSpecified) {
      debugPrint('OnDisconnected callback is solicited, this is correct');
    }
    viewModelState?.changeMQTTConnectionState(MQTTConnectionState.disconnected);
  }

  void onConnected() {
    assert(isConnected);
    viewModelState?.changeMQTTConnectionState(MQTTConnectionState.connected);
    debugPrint('Mosquitto client connected....');
  }

}