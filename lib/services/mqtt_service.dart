import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart' if (dart.library.html) 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:oro_drip_irrigation/utils/environment.dart';
import 'package:uuid/uuid.dart';
import '../Constants/constants.dart';
import '../StateManagement/mqtt_payload_provider.dart';
import '../modules/PumpController/model/pump_controller_data_model.dart';
import '../utils/constants.dart';
import 'package:rxdart/rxdart.dart';

class MqttService {
  static MqttService? _instance;
  MqttPayloadProvider? providerState;
  MqttClient? _client;
  String? currentTopic;

  MqttService._internal();

  factory MqttService() {
    _instance ??= MqttService._internal();
    return _instance!;
  }

  // Connection State
  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;
  MqttConnectionState get mqttConnectionState => _client?.connectionStatus?.state ?? MqttConnectionState.disconnected;

  final StreamController<MqttConnectionState> _connectionController = StreamController.broadcast();
  Stream<MqttConnectionState> get mqttConnectionStream => _connectionController.stream;

  // Acknowledgement Payload
  Map<String, dynamic>? _acknowledgementPayload;
  Map<String, dynamic>? get acknowledgementPayload => _acknowledgementPayload;
  final StreamController<Map<String, dynamic>?> _acknowledgementPayloadController = StreamController.broadcast();
  Stream<Map<String, dynamic>?> get payloadController => _acknowledgementPayloadController.stream;

  // Schedule Payload
  List<Map<String, dynamic>>? _schedulePayload;
  List<Map<String, dynamic>>? get schedulePayload => _schedulePayload;
  final StreamController<List<Map<String, dynamic>>?> _schedulePayloadController = StreamController.broadcast();
  Stream<List<Map<String, dynamic>>?> get schedulePayloadStream => _schedulePayloadController.stream;

  set schedulePayload(List<Map<String, dynamic>>? newPayload) {
    if (newPayload != null) {
      _schedulePayload = newPayload;
      _schedulePayloadController.add(_schedulePayload);
    }
  }

  // Pump Dashboard Payload
  PumpControllerData? _pumpDashboardPayload;
  PumpControllerData? get pumpDashboardPayload => _pumpDashboardPayload;
  final BehaviorSubject<PumpControllerData?> _pumpDashboardPayloadController = BehaviorSubject<PumpControllerData?>();
  Stream<PumpControllerData?> get pumpDashboardPayloadStream => _pumpDashboardPayloadController.stream;

  StreamSubscription? _subscription;

  set pumpDashboardPayload(PumpControllerData? newPayload) {
    if (newPayload != null) {
      _pumpDashboardPayload = newPayload;
      _pumpDashboardPayloadController.add(_pumpDashboardPayload);
    }
  }

  // Preference Acknowledgement
  Map<String, dynamic>? _preferenceAck;
  Map<String, dynamic>? get preferenceAck => _preferenceAck;
  final StreamController<Map<String, dynamic>?> _ackController = StreamController.broadcast();
  Stream<Map<String, dynamic>?> get preferenceAckStream => _ackController.stream;

  set preferenceAck(Map<String, dynamic>? newPayload) {
    if (newPayload != null) {
      _preferenceAck = newPayload;
      _ackController.add(_preferenceAck);
    }
  }

  set acknowledgementPayload(Map<String, dynamic>? newPayload) {
    _acknowledgementPayload = newPayload;
    _acknowledgementPayloadController.add(_acknowledgementPayload);
  }

  void initializeMQTTClient({MqttPayloadProvider? state}) {
    providerState = state;
    String uniqueId = const Uuid().v4();

    if (_client == null) {
      if (kIsWeb) {
        _client = MqttBrowserClient(Environment.mqttWebUrl, uniqueId);
        (_client as MqttBrowserClient).websocketProtocols = MqttClientConstants.protocolsSingleDefault;
        _client!.port = AppConstants.mqttWebPort;
      } else {
        _client = MqttServerClient(Environment.mqttMobileUrl, uniqueId);
        _client!.port = AppConstants.mqttMobilePort;
      }

      _client!.keepAlivePeriod = 30;
      _client!.logging(on: false);
      _client!.onDisconnected = onDisconnected;
      _client!.onConnected = onConnected;
      _client!.onSubscribed = onSubscribed;
      _client!.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

      final connMess = MqttConnectMessage()
          .withClientIdentifier(uniqueId)
          .withWillTopic('will-topic')
          .withWillMessage('My Will message')
          .authenticateAs(AppConstants.mqttUserName, AppConstants.mqttPassword)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      _client!.connectionMessage = connMess;
    }
  }

  Future<void> connect() async {
    if (_client == null || isConnected || _client!.connectionStatus!.state == MqttConnectionState.connecting) {
      return;
    }
    try {
      _connectionController.add(MqttConnectionState.connecting);
      await _client!.connect();
    } catch (e, stackTrace) {
      debugPrint('MQTT Connect Exception: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }


  Future<void> disConnect() async {
    assert(_client != null);
    if (isConnected) {
      try {
        _client!.disconnect();
      } catch (e, stackTrace) {
        debugPrint('MQTT Disconnect Exception: $e');
        debugPrint('$stackTrace');
      }
    }
  }

  Future<void> topicToSubscribe(String topic) async {

    try {
      int retries = 0;
      while (!isConnected && retries < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        retries++;
      }

      if (!isConnected) {
        debugPrint('MQTT not connected. Cannot subscribe to topic: $topic');
        return;
      }

      if (currentTopic != null && currentTopic != topic) {
        _client?.unsubscribe(currentTopic!);
      }

      await _subscription?.cancel();
      await Future.delayed(const Duration(milliseconds: 200));

      _client?.subscribe(topic, MqttQos.atLeastOnce);
      currentTopic = topic;

      _subscription = _client?.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        if (c != null && c.isNotEmpty) {
          final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
          final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          onMqttPayloadReceived(pt);
        }
      });
    } catch (e, stacktrace) {
      print('MQTT subscribe error: $e\n$stacktrace');
    }
  }


  void topicToUnSubscribe(String topic) {
    if (_client == null) return;
    _subscription?.cancel();
    _subscription = null;
    if (currentTopic != null && currentTopic == topic) {
      _client!.unsubscribe(currentTopic!);
      currentTopic = null;
    } else {
      _client!.unsubscribe(topic);
    }
  }

  void onMqttPayloadReceived(String payload) {
    try {
      final payloadMessage = jsonDecode(payload);
      acknowledgementPayload = payloadMessage;

      // print("payloadMessage :: ${payloadMessage['mC']}");
      switch (payloadMessage['mC']) {
        case 'SMS':
          preferenceAck = payloadMessage;
          break;
        case 'LD01':
          pumpDashboardPayload = PumpControllerData.fromJson(payloadMessage, "cM", 1);
          providerState?.updateLastSyncDateFromPumpControllerPayload(payload);
          break;
        case '3600':
          schedulePayload = Constants.dataConversionForScheduleView(payloadMessage['cM']['3601']);
          break;
        default:
          providerState?.updateReceivedPayload(payload, true);
      }
    } catch (e, stackTrace) {
      debugPrint('MQTT Payload Parsing Error: $e\n$stackTrace');
    }
  }

  Future<void> topicToPublishAndItsMessage(String message, String topic) async {
    final builder = MqttClientPayloadBuilder()..addString(message);
    _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void onSubscribed(String topic) {
    debugPrint('Subscribed to topic: $topic');
  }

  void onDisconnected() {

    debugPrint('MQTT disconnected');
    _connectionController.add(MqttConnectionState.disconnected);
  }

  void onConnected() {
    debugPrint('MQTT connected');
    _connectionController.add(MqttConnectionState.connected);
  }
}