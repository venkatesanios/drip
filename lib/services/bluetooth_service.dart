import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../StateManagement/mqtt_payload_provider.dart';
import 'package:oro_drip_irrigation/plugins/flutter_bluetooth_serial/lib/flutter_bluetooth_serial.dart';
import '../utils/enums.dart';



class CustomDevice {
  final BluetoothDevice device;

  BlueConnectionSate status;

  CustomDevice({
    required this.device,
    this.status = BlueConnectionSate.disconnected,
  });

  bool get isConnected => status == BlueConnectionSate.connected;
  bool get isConnecting => status == BlueConnectionSate.connecting;
  bool get isDisConnected => status == BlueConnectionSate.disconnected;
}

class BluService {
  static BluService? _instance;
  BluService._internal();
  VoidCallback? onDeviceFound;

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
  List<String> traceLog = [];
  bool isLogging = false;
  String traceChunk = '';

  bool get isConnected => _connection != null && _connection!.isConnected;
  StreamSubscription<BluetoothDiscoveryResult>? _scanSubscription;

  Future<void> initializeBluService({MqttPayloadProvider? state}) async {
    providerState = state;
  }

  Future<void> initPermissions() async {
    try {
      final isEnabled = await _bluetooth.isEnabled;
      if (!(isEnabled ?? false)) {
        await _bluetooth.requestEnable();
      }
    } catch (e) {
      print('Error enabling Bluetooth: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      final List<Permission> permissions = [
        if (sdkInt >= 31) ...[
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ] else ...[
          Permission.bluetooth,
        ],
        Permission.locationWhenInUse,
      ];

      final statuses = await permissions.request();
      if (statuses.values.any((status) => status.isDenied || status.isPermanentlyDenied)) {
        print('❌ Permissions not granted');
        return false;
      }
    }
    return true;
  }


  int getTraceLogSize() {
    int totalBytes = 0;
    for (final str in traceLog) {
      totalBytes += utf8.encode(str).length;
    }
    return totalBytes;
  }

  Future<void> checkLocationServices() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      print("Location services are OFF. Prompting user...");
      await Geolocator.openLocationSettings();
    }
  }

  int getCurrentChunkSize() {
    return utf8.encode(traceChunk).length;
  }

  Future<void> getDevices(String deviceId) async {

    await requestPermissions();
    await checkLocationServices();

    _devices.clear();
    await FlutterBluetoothSerial.instance.cancelDiscovery();
    await requestPermissions();
    await checkLocationServices();

    _scanSubscription = FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      final device = result.device;

      if ((device.name?.contains(deviceId) ?? false)) {
        final exists = _devices.any((d) => d.address == device.address);
        if (!exists) {
          _devices.add(device);

          final existing = providerState?.pairedDevices.firstWhere(
                (e) => e.device.address == device.address,
            orElse: () => CustomDevice(device: device),
          );

          final updatedDevice = CustomDevice(
            device: device,
            status: existing?.status ?? BlueConnectionSate.disconnected,
          );

          final updatedList = [
            ...(providerState?.pairedDevices
                .where((d) => d.device.address != device.address)
                .toList() ??
                <CustomDevice>[]),
            updatedDevice,
          ];

          providerState?.updatePairedDevices(updatedList);
        }
        onDeviceFound?.call();
      }
    });

    await Future.delayed(const Duration(seconds: 10));
    await _scanSubscription?.cancel();
    await FlutterBluetoothSerial.instance.cancelDiscovery();
  }

  Future<void> connectToDevice(CustomDevice device) async {
    try {
      await requestPermissions();
      await initPermissions();
      await checkLocationServices();

      providerState?.updateDeviceStatus(device.device.address, BlueConnectionSate.connecting.index);

      if (isConnected) {
        await disconnect();
      }

      _connectedAddress = device.device.address;
      final connection = await BluetoothConnection.toAddress(device.device.address);
      _connection = connection;

      providerState?.updateDeviceStatus(device.device.address, BlueConnectionSate.connected.index);
      providerState?.updateConnectedDeviceStatus(device);

      connection.input?.listen((Uint8List data) {
        _buffer += utf8.decode(data);
        _parseBuffer();
      }).onDone(() {
        _connectedAddress = null;
        _connection = null;
        providerState?.updateDeviceStatus(device.device.address, BlueConnectionSate.disconnected.index);
        providerState?.updateConnectedDeviceStatus(null);
      });
    } catch (e) {
      print("Connection failed: $e");
      providerState?.updateDeviceStatus(device.device.address, BlueConnectionSate.disconnected.index);
      providerState?.updateConnectedDeviceStatus(null);
    }
  }

  Future<void> stopDiscovery() async {
    await _scanSubscription?.cancel();
    await FlutterBluetoothSerial.instance.cancelDiscovery();
  }

  Future<void> resetBluetoothState() async {
    // stop scan
    await _scanSubscription?.cancel();
    await FlutterBluetoothSerial.instance.cancelDiscovery();
    _devices.clear();
    providerState?.updatePairedDevices([]);
    print("Bluetooth state cleared");
  }

  void _parseBuffer() {
    print('_buffer----> $_buffer');

    if (_buffer.isEmpty) return;

    // Start logging when *StartLog appears
    if (_buffer.contains('LogFileSentSuccess')) {
      isLogging = false;

      traceLog.add(traceChunk); // Add collected chunk to log
      providerState?.updatetracelog(traceLog);

      providerState?.setTraceLoading(false);

      int sizeInBytes = getTraceLogSize();
      print('TraceLog size in bytes: $sizeInBytes');
      providerState?.setTraceLoadingsize(sizeInBytes);

      traceChunk = ''; // Clear buffer for next round
    }
    if (_buffer.contains('*StartLog')) {
      isLogging = true;
      traceChunk = ''; // Reset previous chunk

      final startIndex = _buffer.indexOf('*StartLog');
      traceChunk += _buffer.substring(startIndex);
      int sizeInBytes = getCurrentChunkSize();
       providerState?.setTraceLoadingsize(sizeInBytes);
      // Start collecting from *StartLog
    }

    // Continue logging: append new data to traceChunk
    if (isLogging && !_buffer.contains('*StartLog')) {
      traceChunk += _buffer;
      int sizeInBytes = getCurrentChunkSize();
       providerState?.setTraceLoadingsize(sizeInBytes);
    }

    // Extract and set LogFileSize if available
    final sizeMatch = RegExp(r'LogFileSize:(\d+)').firstMatch(_buffer);
    if (sizeMatch != null) {
      final sizeStr = sizeMatch.group(1);
      final totalSize = int.tryParse(sizeStr ?? '0') ?? 0;
      providerState?.setTotalTraceSize(totalSize);
    }

    // Stop logging when LogFileSentSuccess appears


    // While logging, show loading
    if (isLogging) {
      providerState?.setTraceLoading(true);
    }

    // Handle JSON packets between *Start and #End
    while (_buffer.contains('*Start') && _buffer.contains('#End')) {
      final start = _buffer.indexOf('*Start');
      final end = _buffer.indexOf('#End', start);

      if (start != -1 && end != -1 && end > start) {
        final jsonString = _buffer.substring(start + 6, end).trim();
        _processData(jsonString);
        _buffer = _buffer.substring(end + 4); // skip past '#End'
      } else {
        break;
      }
    }

    // Do NOT clear _buffer fully—let it continue accumulating partial data
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

  Future<void> writeFW(List<int> data) async {
    if (_connection != null && _connection!.isConnected) {
      print("🔄 Sending ${data.length} bytes over Bluetooth...");
      _connection!.output.add(Uint8List.fromList(data)); // ✅ send raw bytes
      await _connection!.output.allSent; // ✅ ensure it's flushed
    } else {
      print("❌ Not connected");
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


  BluetoothDevice? get connectedDevice {
    return _devices.firstWhere((d) => d.address == _connectedAddress);
  }
}
