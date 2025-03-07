import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:uuid/uuid.dart';

import '../utils/environment.dart';

class MqttManager {
  static MqttManager? _instance;
  MqttServerClient? _client;
  final StreamController<Map<String, dynamic>?> _payloadController = StreamController.broadcast();

  Map<String, dynamic>? _payload;
  Map<String, dynamic>? get payload => _payload;
  Stream<Map<String, dynamic>?> get payloadStream => _payloadController.stream;

  set payload(Map<String, dynamic>? newPayload) {
    _payload = newPayload;
    _payloadController.add(_payload);
  }

  factory MqttManager() {
    _instance ??= MqttManager._internal();
    return _instance!;
  }

  MqttManager._internal();

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;
  MqttConnectionState get connectionState => _client!.connectionStatus!.state;

  String? currentSubscribedTopic;

  void initializeMQTTClient() {
    print('mobile mqtt manager is initialized');

    String uniqueId = const Uuid().v4();

    int port = Environment.mqttMobilePort;
    String baseURL = Environment.mqttMobileUrl;

    if (_client == null) {
      _client = MqttServerClient(baseURL, uniqueId);
      _client!.port = port;
      _client!.keepAlivePeriod = 60;
      _client!.onDisconnected = onDisconnected;
      _client!.logging(on: false);
      _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
      _client!.onConnected = onConnected;
      _client!.onSubscribed = onSubscribed;
      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(uniqueId)
          .withWillTopic('will-topic')
          .withWillMessage('My Will message')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      print('Mosquitto client connecting....');
      _client!.connectionMessage = connMess;

    }
  }

  Future<void> connect() async {
    print('connect function called.....');
    assert(_client != null);
    if (!isConnected) {
      try {
        if (kDebugMode) {
          print('Mosquitto start client connecting....');
        }
        await Future.delayed(Duration.zero);
        await _client!.connect();
        _client?.updates!.listen(_onMessageReceived);
      } on Exception catch (e, stackTrace) {
        if (kDebugMode) {
          print('Client exception - $e');
          print('StackTrace: $stackTrace');
        }
        disconnect();
      }
    }
    else{
      if (kDebugMode) {
        print('Mosquitto already connected....');
      }
    }
  }

  void disconnect() {
    if (kDebugMode) {
      print('Disconnected');
    }
    _client!.disconnect();
  }

  void _onMessageReceived(List<MqttReceivedMessage<MqttMessage?>>? c) async {
    final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
    final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    payload = jsonDecode(pt);
    print('Received message: $pt');
    // providerState?.updateReceivedPayload(pt,false);
  }

  Future<void> topicToSubscribe(String topic) async {
    if (isConnected) {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
      if (kDebugMode) {
        print("topic to subscribe: $topic");
      }
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        topicToSubscribe(topic);
      });
    }
  }

  void topicToUnSubscribe(String topic){
    if(isConnected){
      _client!.unsubscribe(topic);
      if (kDebugMode) {
        print('topic to unSubscribe:  $topic');
      }
    }else{
      Future.delayed(const Duration(seconds: 1),(){
        topicToUnSubscribe(topic);
      });
    }
  }

  Future<void> topicToPublishAndItsMessage(String topic, String message) async{
    if (kDebugMode) {
      print('publish topic : $topic');
      print('publish message : $message');
    }
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    if (kDebugMode) {
      print('Subscription confirmed for topic $topic');
    }
  }

  /// The unsolicited disconnect callback
  void onDisconnected() async{
    await Future.delayed(const Duration(seconds: 5,));
    try{
      if (kDebugMode) {
        print('OnDisconnected client callback - Client disconnection');
      }
      if (_client!.connectionStatus!.returnCode == MqttConnectReturnCode.noneSpecified) {
        if (kDebugMode) {
          print('OnDisconnected callback is solicited, this is correct');
        }
      }
      await Future.delayed(Duration.zero);
      connect();
    }catch(e){
      if (kDebugMode) {
        print('Mqtt connectivity issue => ${e.toString()}');
      }
    }
  }

  void onConnected() async{
    assert(isConnected);
    await Future.delayed(Duration.zero);
    if (kDebugMode) {
      print('Mosquitto client connected....');
    }
  }
}
