import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';
import '../Constants/constants.dart';
import '../StateManagement/mqtt_payload_provider.dart';
import '../utils/constants.dart';

class MqttService {
  static MqttService? _instance;
  MqttPayloadProvider? providerState;
  MqttClient? _client;
  String? currentTopic;
  Map<String, dynamic>? _acknowledgementPayload;
  Map<String, dynamic>? get acknowledgementPayload => _acknowledgementPayload;
  List<Map<String, dynamic>>? _schedulePayload;

  final StreamController<Map<String, dynamic>?> _payloadController = StreamController.broadcast();
  final StreamController<List<Map<String, dynamic>>?> _schedulePayloadController = StreamController.broadcast();
  final StreamController<String> mqttConnectionStreamController = StreamController.broadcast();
  final StreamController<String> connectionStatusController = StreamController.broadcast();

  Stream<List<Map<String, dynamic>>?> get schedulePayloadStream => _schedulePayloadController.stream;
  Stream<String> get mqttConnectionStream => mqttConnectionStreamController.stream;
  List<Map<String, dynamic>>? get schedulePayload => _schedulePayload;


  factory MqttService() {
    _instance ??= MqttService._internal();
    return _instance!;
  }

  MqttService._internal();

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;
  MqttConnectionState get connectionState => _client!.connectionStatus!.state;


  set acknowledgementPayload(Map<String, dynamic>? newPayload) {
    _acknowledgementPayload = newPayload;
    _payloadController.add(_acknowledgementPayload);
  }

  set schedulePayload(List<Map<String, dynamic>>? newPayload) {
    _schedulePayload = newPayload;
    _schedulePayloadController.add(_schedulePayload);
  }

  void initializeMQTTClient({MqttPayloadProvider? state}) {
    providerState = state;
    String uniqueId = const Uuid().v4();
    if (_client == null) {
      providerState = state;
      if (kIsWeb) {
        debugPrint("Initializing MQTT for Web...");
        _client = MqttBrowserClient(AppConstants.mqttUrl, uniqueId);
        (_client as MqttBrowserClient).websocketProtocols = MqttClientConstants.protocolsSingleDefault;
        _client!.port = AppConstants.mqttWebPort;
      } else {
        debugPrint("Initializing MQTT for Mobile...");
        _client = MqttServerClient(AppConstants.mqttUrlMobile, uniqueId);
        _client!.port = AppConstants.mqttMobilePort;
      }

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
          .authenticateAs('imsmqtt', '2L9((WonMr')
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
        providerState?.updateMQTTConnectionState(MQTTConnectionState.connecting);
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
      if (payloadMessage['mC'] == '2400') {
        print(payload);
        providerState?.updateReceivedPayload(payload, false);
      }
      acknowledgementPayload = jsonDecode(payload);
      print('acknowledgementPayload : $acknowledgementPayload');
      if (acknowledgementPayload != null && acknowledgementPayload!['mC'] == '3600') {
        schedulePayload = Constants.dataConversionForScheduleView(acknowledgementPayload!['cM']['3601']);
      }
    } catch (e) {
      debugPrint('Error parsing MQTT payload: $e');
    }
  }

  void topicToPublishAndItsMessage(String message, String topic) {
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
    providerState?.updateMQTTConnectionState(MQTTConnectionState.disconnected);
  }

  void onConnected() {
    assert(isConnected);
    mqttConnectionStreamController.add('Connected');
    providerState?.updateMQTTConnectionState(MQTTConnectionState.connected);
    debugPrint('Mosquitto client connected....');
  }


}