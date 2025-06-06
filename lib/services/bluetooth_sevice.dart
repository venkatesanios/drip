import 'dart:async';
import 'dart:convert';
import 'package:bluetooth_classic/models/device.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Models/customer/blu_device.dart';
import '../StateManagement/mqtt_payload_provider.dart';

class CustomDevice {
  final Device device;
  int status;

  CustomDevice({required this.device, this.status = BluDevice.disconnected});

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

  final _bluetoothClassicPlugin = BluetoothClassic();
  final List<CustomDevice> _devices = [];
  String? _connectedAddress;
  bool get isConnected => connectedDevice != null;

  MqttPayloadProvider? providerState;

  String _buffer = '';

  StreamSubscription<Device>? _scanSubscription;
  late final Stream<Device> _deviceStream = _bluetoothClassicPlugin.onDeviceDiscovered().asBroadcastStream();

  void initializeBluService({MqttPayloadProvider? state}) {
    providerState = state;
    initPermissions();
    _listenToBluEvents();
  }

  Future<void> initPermissions() async {
    await _bluetoothClassicPlugin.initPermissions();
  }

  Future<void> requestPermissions() async {
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }

    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }

    if (await Permission.locationWhenInUse.isDenied) {
      await Permission.locationWhenInUse.request();
    }
  }

  void _listenToBluEvents() {
    listenToBluDeviceStatus();
    listenToBluData();
  }

  void listenToBluDeviceStatus() {
    _bluetoothClassicPlugin.onDeviceStatusChanged().listen((status) {
      if (_connectedAddress == null) return;

      final index = _devices.indexWhere((d) => d.device.address == _connectedAddress);
      if (index != -1) {
        final d = _devices[index];
        d.status = status;
        providerState?.updateDeviceStatus(d.device.address, d.status);

        if (status == BluDevice.connected) {
          providerState?.updateConnectedDeviceStatus(d);
        } else if (status == BluDevice.disconnected) {
          _connectedAddress = null;
          providerState?.updateConnectedDeviceStatus(null);
        }
      }
    });
  }

  void listenToBluData() {
    _bluetoothClassicPlugin.onDeviceDataReceived().listen((event) {
      _buffer += utf8.decode(event);

      while (_buffer.contains('*') && _buffer.contains('#')) {
        int startIndex = _buffer.indexOf('*');
        int endIndex = _buffer.indexOf('#', startIndex);

        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          String jsonString = _buffer.substring(startIndex + 1, endIndex);
          _buffer = _buffer.substring(endIndex + 1);

          try {
            Map<String, dynamic> jsonData = json.decode(jsonString);
            String jsonStr = json.encode(jsonData);

            Map<String, dynamic> data = jsonStr.isNotEmpty ? jsonDecode(jsonStr) : {};

            if (data['mC']?.toString() == '7300') {
              final rawList = data["cM"]?["7301"]?["ListOfWifi"];
              if (rawList is List) {
                final wifiList = rawList.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
                providerState?.updateWifiList(wifiList);
              } else {
                print('ListOfWifi is not a List');
              }
            } else if (data['mC']?.toString() == '4200') {
              final cM = data['cM'] as Map<String, dynamic>?;
              if (cM != null && cM.isNotEmpty) {
                final firstEntry = cM.entries.first.value as Map<String, dynamic>;
                final message = firstEntry['Message'];
                final cleanedMessage = message?.trim();
                if (cleanedMessage != null) {
                  providerState?.updateWifiMessage(cleanedMessage);
                } else {
                  print('Message is null or empty');
                }
              }
            } else {
              providerState?.updateReceivedPayload(jsonStr, true);
            }
          } catch (e) {
            print('JSON parsing failed: $e');
          }
        } else {
          break;
        }
      }
    });
  }

  Future<void> getDevices() async {
    await _scanSubscription?.cancel();
    await _bluetoothClassicPlugin.startScan();

    _scanSubscription = _deviceStream.listen((device) {
      if (device.name != null && device.name!.startsWith('NIA_')) {
        final customDevice = CustomDevice(device: device);
        if (!_devices.any((d) => d.device.address == customDevice.device.address)) {
          _devices.add(customDevice);
          providerState?.updatePairedDevices(List.from(_devices));
        }
      }
    });

    await Future.delayed(const Duration(seconds: 10));
    await _bluetoothClassicPlugin.stopScan();
    await _scanSubscription?.cancel();
  }

  Future<void> connectToDevice(CustomDevice customDevice) async {
    if (customDevice.device.address.isEmpty) {
      print('Invalid device address');
      return;
    }

    requestPermissions();
    _connectedAddress = customDevice.device.address;
    customDevice.status = BluDevice.connecting;
    providerState?.updateDeviceStatus(customDevice.device.address, customDevice.status);

    try {
      await _bluetoothClassicPlugin.stopScan();
      await Future.delayed(const Duration(milliseconds: 300));

      try {
        await _bluetoothClassicPlugin.disconnect();
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        print('Error during pre-disconnect: $e');
      }

      await _bluetoothClassicPlugin
          .connect(
        customDevice.device.address,
        "00001101-0000-1000-8000-00805f9b34fb",
      )
          .timeout(const Duration(seconds: 8));

      customDevice.status = BluDevice.connected;
      providerState?.updateDeviceStatus(customDevice.device.address, customDevice.status);
    } on TimeoutException {
      print("Connection timed out");
      customDevice.status = BluDevice.disconnected;
      providerState?.updateDeviceStatus(customDevice.device.address, customDevice.status);
      _connectedAddress = null;
    } on PlatformException catch (e) {
      print("PlatformException during connect: ${e.message}");
      customDevice.status = BluDevice.disconnected;
      providerState?.updateDeviceStatus(customDevice.device.address, customDevice.status);
      _connectedAddress = null;
    } catch (e) {
      print('Connection error: $e');
      customDevice.status = BluDevice.disconnected;
      providerState?.updateDeviceStatus(customDevice.device.address, customDevice.status);
      _connectedAddress = null;
    }
  }

  CustomDevice? get connectedDevice {
    try {
      return _devices.firstWhere(
            (device) => device.device.address == _connectedAddress && device.isConnected,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String payload) async {
    String modifiedPayload = '*$payload#';
    print('payload to bluetooth: $modifiedPayload');
    try {
      await _bluetoothClassicPlugin.write(modifiedPayload);
    } catch (e) {
      print('Write error: $e');
    }
  }
}
