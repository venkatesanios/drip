import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart' as classic;
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import '../../utils/enums.dart';
import 'model/classic_bluetooth_device_model.dart';


class BluetoothClassicService {
  static BluetoothClassicService? _instance;
  BluetoothClassicService._internal();
  VoidCallback? onDeviceFound;

  // 👇 new callbacks
  Function()? onNoDeviceFound;
  Function(String message)? onConnectionError;

  factory BluetoothClassicService() {
    _instance ??= BluetoothClassicService._internal();
    return _instance!;
  }

  final classic.FlutterBluetoothSerial _bluetooth = classic.FlutterBluetoothSerial.instance;
  final List<classic.BluetoothDevice> _devices = [];
  classic.BluetoothConnection? _connection;
  String? _connectedAddress;
  MqttPayloadProvider? providerState;
  String _buffer = '';
  List<String> traceLog = [];
  bool isLogging = false;
  String traceChunk = '';

  bool get isConnected => _connection != null && _connection!.isConnected;
  StreamSubscription<classic.BluetoothDiscoveryResult>? _scanSubscription;

  Future<void> initializeClassicService({MqttPayloadProvider? state}) async {
    providerState = state;
  }

  Future<void> initPermissions() async {
    try {
      final isEnabled = await _bluetooth.isEnabled;
      if (!(isEnabled ?? false)) {
        await _bluetooth.requestEnable();
      }
    } catch (e) {
      debugPrint('Error enabling Bluetooth: $e');
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
        debugPrint('Permissions not granted');
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
      debugPrint("Location services are OFF. Prompting user...");
      await Geolocator.openLocationSettings();
    }
  }

  int getCurrentChunkSize() {
    return utf8.encode(traceChunk).length;
  }

  Future<void> scanDevices(String deviceId) async {
    try {
      // Permission check up front — fail loudly if denied
      final permissionsGranted = await requestPermissions();
      if (!permissionsGranted) {
        onConnectionError?.call("Bluetooth permissions are required to scan for devices.");
        return;
      }

      await checkLocationServices();

      _devices.clear();
      await classic.FlutterBluetoothSerial.instance.cancelDiscovery();
      await requestPermissions();
      await checkLocationServices();

      _scanSubscription = classic.FlutterBluetoothSerial.instance.startDiscovery().listen(
            (result) {
          final device = result.device;

          if ((device.name?.contains(deviceId) ?? false)) {
            final exists = _devices.any((d) => d.address == device.address);
            if (!exists) {
              _devices.add(device);

              final existing = providerState?.pairedDevicesClassic.firstWhere(
                    (e) => e.device.address == device.address,
                orElse: () => ClassicBluetoothDeviceModel(device: device),
              );

              final updatedDevice = ClassicBluetoothDeviceModel(
                device: device,
                connectionState: existing?.connectionState ?? BlueConnectionState.disconnected,
              );

              final updatedList = [
                ...(providerState?.pairedDevicesClassic
                    .where((d) => d.device.address != device.address)
                    .toList() ??
                    <ClassicBluetoothDeviceModel>[]),
                updatedDevice,
              ];

              providerState?.updateClassicPairedDevices(updatedList);
            }
            onDeviceFound?.call();
          }
        },
        onError: (e) {
          debugPrint("❌ Classic discovery stream error: $e");
          onConnectionError?.call("Bluetooth scan failed: $e");
        },
      );

      await Future.delayed(const Duration(seconds: 10));
      await _scanSubscription?.cancel();
      await classic.FlutterBluetoothSerial.instance.cancelDiscovery();

      // 👇 tell the UI if nothing was found
      if (_devices.isEmpty) {
        debugPrint("⚠️ Classic scan finished — no matching devices found");
        onNoDeviceFound?.call();
      }
    } catch (e) {
      debugPrint("❌ Error during classic scan: $e");
      onConnectionError?.call("Bluetooth scan failed: $e");
    }
  }

  Future<void> connectToDevice(ClassicBluetoothDeviceModel device) async {
    try {
      final permissionsGranted = await requestPermissions();
      if (!permissionsGranted) {
        onConnectionError?.call("Bluetooth permissions are required to connect.");
        return;
      }

      await initPermissions();
      await checkLocationServices();

      providerState?.updateClassicDeviceStatus(device.device.address, BlueConnectionState.connecting.index);

      if (isConnected) {
        await disconnect();
      }

      _connectedAddress = device.device.address;
      final connection = await classic.BluetoothConnection.toAddress(device.device.address);
      _connection = connection;

      providerState?.updateClassicDeviceStatus(device.device.address, BlueConnectionState.connected.index);
      providerState?.updateClassicConnectedDeviceStatus(device);

      connection.input.listen((Uint8List data) {
        _buffer += utf8.decode(data);
        _parseBuffer();
      }).onDone(() {
        final wasConnected = _connection != null;
        _connectedAddress = null;
        _connection = null;
        providerState?.updateClassicDeviceStatus(device.device.address, BlueConnectionState.disconnected.index);
        providerState?.updateClassicConnectedDeviceStatus(null);

        // 👇 if it dropped unexpectedly (not via manual disconnect()), surface it
        if (wasConnected) {
          onConnectionError?.call("Device is disconnected");
        }
      });
    } catch (e) {
      debugPrint("Connection failed: $e");
      providerState?.updateClassicDeviceStatus(device.device.address, BlueConnectionState.disconnected.index);
      providerState?.updateClassicConnectedDeviceStatus(null);
      onConnectionError?.call(e.toString()); // 👈 surface the failure reason
    }
  }

  Future<void> stopDiscovery() async {
    await _scanSubscription?.cancel();
    await classic.FlutterBluetoothSerial.instance.cancelDiscovery();
  }

  Future<void> resetBluetoothState() async {
    await _scanSubscription?.cancel();
    await classic.FlutterBluetoothSerial.instance.cancelDiscovery();
    _devices.clear();
    providerState?.updateClassicPairedDevices([]);
  }

  void _parseBuffer() {
    debugPrint('_buffer----> $_buffer');

    if (_buffer.isEmpty) return;

    if (_buffer.contains('LogFileSentSuccess')) {
      isLogging = false;
      traceLog.add(traceChunk);
      providerState?.updateTraceLogs(traceLog);
      providerState?.setTraceLoading(false);

      int sizeInBytes = getTraceLogSize();
      debugPrint('TraceLog size in bytes: $sizeInBytes');
      providerState?.setTraceLoadingsize(sizeInBytes);

      traceChunk = '';
    }
    if (_buffer.contains('*StartLog')) {
      isLogging = true;
      traceChunk = '';

      final startIndex = _buffer.indexOf('*StartLog');
      traceChunk += _buffer.substring(startIndex);
      int sizeInBytes = getCurrentChunkSize();
      providerState?.setTraceLoadingsize(sizeInBytes);
    }

    if (isLogging && !_buffer.contains('*StartLog')) {
      traceChunk += _buffer;
      int sizeInBytes = getCurrentChunkSize();
      providerState?.setTraceLoadingsize(sizeInBytes);
    }

    final sizeMatch = RegExp(r'LogFileSize:(\d+)').firstMatch(_buffer);
    if (sizeMatch != null) {
      final sizeStr = sizeMatch.group(1);
      final totalSize = int.tryParse(sizeStr ?? '0') ?? 0;
      providerState?.setTotalTraceSize(totalSize);
    }

    if (isLogging) {
      providerState?.setTraceLoading(true);
    }

    while (_buffer.contains('*Start') && _buffer.contains('#End')) {
      final start = _buffer.indexOf('*Start');
      final end = _buffer.indexOf('#End', start);

      if (start != -1 && end != -1 && end > start) {
        final jsonString = _buffer.substring(start + 6, end).trim();
        _processData(jsonString);
        _buffer = _buffer.substring(end + 4);
      } else {
        break;
      }
    }
  }

  void _processData(String jsonString) {
    debugPrint("_processData call $jsonString");
    try {
      final data = json.decode(jsonString);
      final jsonStr = json.encode(data);

      providerState?.updateReceivedPayload(jsonStr, false);

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
      debugPrint("Error parsing: $e");
    }
  }

  Future<void> write(String payload) async {
    if (_connection != null && _connection!.isConnected) {
      final finalPayload = '*$payload#';
      debugPrint("Sending: $finalPayload");
      _connection!.output.add(Uint8List.fromList(utf8.encode("$finalPayload\r\n")));
    }
  }

  Future<void> writeFW(List<int> data) async {
    if (_connection != null && _connection!.isConnected) {
      debugPrint("Sending ${data.length} bytes over Bluetooth...");
      _connection!.output.add(Uint8List.fromList(data));
      await _connection!.output.allSent;
    } else {
      debugPrint("Not connected");
    }
  }

  Future<void> disconnect() async {
    try {
      await _connection?.close();
    } catch (e) {
      debugPrint("Disconnect failed: $e");
    } finally {
      _connection = null;
      _connectedAddress = null;
      providerState?.updateClassicConnectedDeviceStatus(null);
    }
  }

  classic.BluetoothDevice? get connectedDevice {
    return _devices.firstWhere((d) => d.address == _connectedAddress);
  }
}


/*
class BluetoothClassicService {
  static BluetoothClassicService? _instance;
  BluetoothClassicService._internal();
  VoidCallback? onDeviceFound;

  factory BluetoothClassicService() {
    _instance ??= BluetoothClassicService._internal();
    return _instance!;
  }

  final classic.FlutterBluetoothSerial _bluetooth = classic.FlutterBluetoothSerial.instance;
  final List<classic.BluetoothDevice> _devices = [];
  classic.BluetoothConnection? _connection;
  String? _connectedAddress;
  MqttPayloadProvider? providerState;
  String _buffer = '';
  List<String> traceLog = [];
  bool isLogging = false;
  String traceChunk = '';

  bool get isConnected => _connection != null && _connection!.isConnected;
  StreamSubscription<classic.BluetoothDiscoveryResult>? _scanSubscription;

  Future<void> initializeClassicService({MqttPayloadProvider? state}) async {
    providerState = state;
  }

  Future<void> initPermissions() async {
    try {
      final isEnabled = await _bluetooth.isEnabled;
      if (!(isEnabled ?? false)) {
        await _bluetooth.requestEnable();
      }
    } catch (e) {
      debugPrint('Error enabling Bluetooth: $e');
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
        debugPrint('Permissions not granted');
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
      debugPrint("Location services are OFF. Prompting user...");
      await Geolocator.openLocationSettings();
    }
  }

  int getCurrentChunkSize() {
    return utf8.encode(traceChunk).length;
  }

  Future<void> scanDevices(String deviceId) async {

    await requestPermissions();
    await checkLocationServices();

    _devices.clear();
    await classic.FlutterBluetoothSerial.instance.cancelDiscovery();
    await requestPermissions();
    await checkLocationServices();

    _scanSubscription = classic.FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      final device = result.device;

      if ((device.name?.contains(deviceId) ?? false)) {
        final exists = _devices.any((d) => d.address == device.address);
        if (!exists) {
          _devices.add(device);

          final existing = providerState?.pairedDevicesClassic.firstWhere(
                (e) => e.device.address == device.address,
            orElse: () => ClassicBluetoothDeviceModel(device: device),
          );

          final updatedDevice = ClassicBluetoothDeviceModel(
            device: device,
            connectionState: existing?.connectionState ?? BlueConnectionState.disconnected,
          );

          final updatedList = [
            ...(providerState?.pairedDevicesClassic
                .where((d) => d.device.address != device.address)
                .toList() ??
                <ClassicBluetoothDeviceModel>[]),
            updatedDevice,
          ];

          providerState?.updateClassicPairedDevices(updatedList);
        }
        onDeviceFound?.call();
      }
    });

    await Future.delayed(const Duration(seconds: 10));
    await _scanSubscription?.cancel();
    await classic.FlutterBluetoothSerial.instance.cancelDiscovery();
  }

  Future<void> connectToDevice(ClassicBluetoothDeviceModel device) async {
    try {
      await requestPermissions();
      await initPermissions();
      await checkLocationServices();

      providerState?.updateClassicDeviceStatus(device.device.address, BlueConnectionState.connecting.index);

      if (isConnected) {
        await disconnect();
      }

      _connectedAddress = device.device.address;
      final connection = await classic.BluetoothConnection.toAddress(device.device.address);
      _connection = connection;

      providerState?.updateClassicDeviceStatus(device.device.address, BlueConnectionState.connected.index);
      providerState?.updateClassicConnectedDeviceStatus(device);

      connection.input?.listen((Uint8List data) {
        _buffer += utf8.decode(data);
        _parseBuffer();
      }).onDone(() {
        _connectedAddress = null;
        _connection = null;
        providerState?.updateClassicDeviceStatus(device.device.address, BlueConnectionState.disconnected.index);
        providerState?.updateClassicConnectedDeviceStatus(null);
      });
    } catch (e) {
      debugPrint("Connection failed: $e");
      providerState?.updateClassicDeviceStatus(device.device.address, BlueConnectionState.disconnected.index);
      providerState?.updateClassicConnectedDeviceStatus(null);
    }
  }

  Future<void> stopDiscovery() async {
    await _scanSubscription?.cancel();
    await classic.FlutterBluetoothSerial.instance.cancelDiscovery();
  }

  Future<void> resetBluetoothState() async {
    // stop scan
    await _scanSubscription?.cancel();
    await classic.FlutterBluetoothSerial.instance.cancelDiscovery();
    _devices.clear();
    providerState?.updateClassicPairedDevices([]);
  }

  void _parseBuffer() {
    debugPrint('_buffer----> $_buffer');

    if (_buffer.isEmpty) return;

    // Start logging when *StartLog appears
    if (_buffer.contains('LogFileSentSuccess')) {
      isLogging = false;

      traceLog.add(traceChunk); // Add collected chunk to log
      providerState?.updateTraceLogs(traceLog);

      providerState?.setTraceLoading(false);

      int sizeInBytes = getTraceLogSize();
      debugPrint('TraceLog size in bytes: $sizeInBytes');
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
    debugPrint("_processData call $jsonString");
    try {
      final data = json.decode(jsonString);
      final jsonStr = json.encode(data);

      providerState?.updateReceivedPayload(jsonStr, false);

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
      debugPrint("Error parsing: $e");
    }
  }

  Future<void> write(String payload) async {
    if (_connection != null && _connection!.isConnected) {
      final finalPayload = '*$payload#';
      debugPrint("Sending: $finalPayload");
      _connection!.output.add(Uint8List.fromList(utf8.encode("$finalPayload\r\n")));
    }
  }

  Future<void> writeFW(List<int> data) async {
    if (_connection != null && _connection!.isConnected) {
      debugPrint("Sending ${data.length} bytes over Bluetooth...");
      _connection!.output.add(Uint8List.fromList(data)); // send raw bytes
      await _connection!.output.allSent; // ensure it's flushed
    } else {
      debugPrint("Not connected");
    }
  }

  Future<void> disconnect() async {
    try {
      await _connection?.close();
    } catch (e) {
      debugPrint("Disconnect failed: $e");
    } finally {
      _connection = null;
      _connectedAddress = null;
      providerState?.updateClassicConnectedDeviceStatus(null);
    }
  }

  classic.BluetoothDevice? get connectedDevice {
    return _devices.firstWhere((d) => d.address == _connectedAddress);
  }
}*/
