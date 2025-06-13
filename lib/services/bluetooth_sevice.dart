import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../StateManagement/mqtt_payload_provider.dart';
import 'package:oro_drip_irrigation/plugins/flutter_bluetooth_serial/lib/flutter_bluetooth_serial.dart';


enum BluDevice {
  connected,
  connecting,
  disconnected
}

class CustomDevice {
  final BluetoothDevice device;

  BluDevice status;

  CustomDevice({
    required this.device,
    this.status = BluDevice.disconnected,
  });

  bool get isConnected => status == BluDevice.connected;
  bool get isConnecting => status == BluDevice.connecting;
  bool get isDisConnected => status == BluDevice.disconnected;
}

class BluService {
  static BluService? _instance;
  BluService._internal();

  factory BluService() {
    _instance ??= BluService._internal();
    return _instance!;
  }

  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  final List<BluetoothDevice> _devices = [];
  BluetoothConnection? _connection;
  String? _connectedAddress;
  MqttPayloadProvider? providerState;
  String _buffer = '';

  bool get isConnected => _connection != null && _connection!.isConnected;

  StreamSubscription<BluetoothDiscoveryResult>? _scanSubscription;

  void initializeBluService({MqttPayloadProvider? state}) {
    providerState = state;
    initPermissions();
    _listenToData();
  }

  Future<void> initPermissions() async {
    await _bluetooth.requestEnable();
  }


  Future<void> getDevices() async {
    _devices.clear();

    final completer = Completer<void>();

    _scanSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      final device = result.device;

      if ((device.name?.startsWith('NIA_') ?? false)) {
        final exists = _devices.any((d) => d.address == device.address);
        if (!exists) {
          _devices.add(device);

          final existing = providerState?.pairedDevices.firstWhere(
                (e) => e.device.address == device.address,
            orElse: () => CustomDevice(device: device),
          );

          final updatedDevice = CustomDevice(
            device: device,
            status: existing?.status ?? BluDevice.disconnected,
          );

          final List<CustomDevice> updatedList = [
            ...(providerState?.pairedDevices
                .where((d) => d.device.address != device.address)
                .toList() ??
                <CustomDevice>[]),
            updatedDevice,
          ];

          providerState?.updatePairedDevices(updatedList);
        }
      }
    });

    // Cancel after 10 seconds and complete the future
    Future.delayed(const Duration(seconds: 10)).then((_) async {
      await _scanSubscription?.cancel();
      FlutterBluetoothSerial.instance.cancelDiscovery();
      print("Discovery stopped.");
      completer.complete();
    });

    return completer.future;
  }


  Future<void> startScan() async {
    _scanSubscription?.cancel();
    _scanSubscription = _bluetooth.startDiscovery().listen((result) {
      if (result.device.name?.startsWith('NIA_') ?? false) {
        final exists = _devices.any((d) => d.address == result.device.address);
        if (!exists) {
          _devices.add(result.device);
          providerState?.updatePairedDevices(
            _devices.map((d) => CustomDevice(device: d)).toList(),
          );
        }
      }
    });

    // Stop scan after timeout
    Future.delayed(const Duration(seconds: 10)).then((_) async {
      await _scanSubscription?.cancel();
    });
  }

  Future<void> connectToDevice(CustomDevice device) async {
    try {
      // Update to connecting
      providerState?.updateDeviceStatus(device.device.address, BluDevice.connecting.index);

      // Disconnect any existing connection
      if (isConnected) {
        await disconnect();
      }

      _connectedAddress = device.device.address;

      final connection = await BluetoothConnection.toAddress(device.device.address);
      _connection = connection;

      //  Update to connected
      providerState?.updateDeviceStatus(device.device.address, BluDevice.connected.index);
      providerState?.updateConnectedDeviceStatus(device);

      connection.input?.listen((Uint8List data) {
        _buffer += utf8.decode(data);
        _parseBuffer();
      }).onDone(() {
        _connectedAddress = null;
        _connection = null;

        // Update to disconnected when done
        providerState?.updateDeviceStatus(device.device.address, BluDevice.disconnected.index);
        providerState?.updateConnectedDeviceStatus(null);
      });
    } catch (e) {
      print("Connection failed: $e");

      // Update to disconnected on error
      providerState?.updateDeviceStatus(device.device.address, BluDevice.disconnected.index);
      providerState?.updateConnectedDeviceStatus(null);
    }
  }

  void _parseBuffer() {
    while (_buffer.contains('*Start') && _buffer.contains('#End')) {
      final start = _buffer.indexOf('*Start');
      final end = _buffer.indexOf('#End', start);

      if (start != -1 && end != -1 && end > start) {
        final jsonString = _buffer.substring(start + 6, end).trim();
        _buffer = _buffer.substring(end + 4); // skip past #End
        _processData(jsonString);
      } else {
        break;
      }
    }
  }

  void _processData(String jsonString) {
    try {
      final data = json.decode(jsonString);
      final jsonStr = json.encode(data);

      switch (data['mC'].toString()) {
        case '7300':
          final rawList = data["cM"]?["7301"]?["ListOfWifi"];
          final wifiStatus = data["cM"]?["7301"]?["Status"];
          final interfaceType = data["cM"]?["7301"]?["InterfaceType"];
          final ipAddress = data["cM"]?["7301"]?["IpAddress"];

          providerState?.updateWifiStatus(wifiStatus, false);
          providerState?.updateInterfaceType(interfaceType);
          providerState?.updateIpAddress(ipAddress);

          if (rawList is List) {
            final wifiList = rawList.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
            providerState?.updateWifiList(wifiList);
          }
          break;
        case '4200':
          final message = data['cM']?.entries.first.value['Message']?.trim();
          if (message != null) {
            providerState?.updateWifiMessage(message);
          }
          break;
        case '6600':
          providerState?.updateReceivedPayload(jsonStr, false);
          break;
        default:
          providerState?.updateReceivedPayload(jsonStr, true);
          break;
      }
    } catch (e) {
      print("Error parsing: $e");
    }
  }

  Future<void> write(String payload) async {
    if (_connection != null && _connection!.isConnected) {
      final finalPayload = '*$payload#';
      print("Sending: $finalPayload");
      _connection!.output.add(Uint8List.fromList(utf8.encode(finalPayload + "\r\n")));
    }
  }

  Future<void> disconnect() async {
    try {
      await _connection?.close();
    } catch (e) {
      print("Disconnect failed: $e");
    } finally {
      _connection = null;
      _connectedAddress = null;
      providerState?.updateConnectedDeviceStatus(null);
    }
  }

  void _listenToData() {
    // This method was merged into connectToDevice logic
  }

  BluetoothDevice? get connectedDevice {
    return _devices.firstWhere((d) => d.address == _connectedAddress);
  }
}
