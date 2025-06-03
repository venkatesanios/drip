import 'dart:async';
import 'dart:convert';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
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

  final ValueNotifier<List<Map<String, dynamic>>> listOfWifi = ValueNotifier([]);
  ValueNotifier<String?> wifiMessage = ValueNotifier<String?>(null);

  StreamSubscription<Device>? _scanSubscription;
  late final Stream<Device> _deviceStream = _bluetoothClassicPlugin.onDeviceDiscovered().asBroadcastStream();


  void initializeBluService({MqttPayloadProvider? state}) {
    providerState = state;
    initPermissions();
    _listenToBluEvents();
  }

  void _listenToBluEvents() {
    listenToBluDeviceStatus();
    listenToBluData();
  }

  Future<void> initPermissions() async {
    await _bluetoothClassicPlugin.initPermissions();
  }

  void listenToBluDeviceStatus() {
    _bluetoothClassicPlugin.onDeviceStatusChanged().listen((status) {
      if (_connectedAddress == null) {
        return;
      }
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
            print('Parsed jsonStr: $jsonStr');

            try {
              Map<String, dynamic> data = jsonStr.isNotEmpty ? jsonDecode(jsonStr) : {};
              if (data['mC']?.toString() == '7300') {
                final rawList = data["cM"]?["7301"]?["ListOfWifi"];
                if (rawList is List) {
                  final wifiList = rawList
                      .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                      .toList();
                  updateWifiList(wifiList);
                } else {
                  print('ListOfWifi is not a List');
                }
              }
              else if (data['mC']?.toString() == '4200'){
                print('change password.....');
                final cM = data['cM'] as Map<String, dynamic>?;
                if (cM != null && cM.isNotEmpty) {
                  final firstEntry = cM.entries.first.value as Map<String, dynamic>;
                  final message = firstEntry['Message'];
                  print('Message: $message');
                  final cleanedMessage = message?.trim();
                  if (cleanedMessage != null) {
                    wifiMessage.value = cleanedMessage;
                  }else{
                    print('kamaraj password');
                  }
                }
              }
              else{
                print('updateReceivedPayload');
                providerState?.updateReceivedPayload(jsonStr, true);
              }
            } catch (e) {
              print('JSON parsing failed: $e');
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

  void updateWifiList(List<Map<String, dynamic>> newList) {
    providerState?.updateWifiList(newList);
  }

  Future<void> getDevices() async {
    //notifyListeners();
    await _scanSubscription?.cancel();
    await _bluetoothClassicPlugin.startScan();
    _scanSubscription = _deviceStream.listen((device) {
      if (device.name != null && device.name!.startsWith('NIA')) {
        final customDevice = CustomDevice(device: device);

        if (!_devices.any((d) => d.device.address == customDevice.device.address)) {
          _devices.add(customDevice);
          providerState?.updatePairedDevices(List.from(_devices));
          //notifyListeners();
        }
      }
    });

    await Future.delayed(const Duration(seconds: 10));
    await _bluetoothClassicPlugin.stopScan();
    await _scanSubscription?.cancel();
  }

  Future<void> connectToDevice(CustomDevice customDevice) async {
    _connectedAddress = customDevice.device.address;

    customDevice.status = BluDevice.connecting;
    providerState?.updateDeviceStatus(customDevice.device.address, customDevice.status);

    try {
      await _bluetoothClassicPlugin.stopScan();
      await Future.delayed(const Duration(milliseconds: 300));

      await _bluetoothClassicPlugin.connect(
        customDevice.device.address,
        "00001101-0000-1000-8000-00805f9b34fb",
      ).timeout(const Duration(seconds: 5));

      customDevice.status = BluDevice.connected;
      providerState?.updateDeviceStatus(customDevice.device.address, customDevice.status);
    } on TimeoutException {
      customDevice.status = BluDevice.disconnected;
      providerState?.updateDeviceStatus(customDevice.device.address, customDevice.status);
      _connectedAddress = null;
    } catch (e) {
      customDevice.status = BluDevice.disconnected;
      providerState?.updateDeviceStatus(customDevice.device.address, customDevice.status);
      _connectedAddress = null;
    }
  }

  CustomDevice? get connectedDevice {
    try {
      return _devices.firstWhere((device) =>
      device.device.address == _connectedAddress && device.isConnected);
    } catch (e) {
      return null;
    }
  }

  Future<void> write(String payload) async {
    String modifiedPayload = '*$payload#';
    print('payload to bluetooth:$modifiedPayload');
    await _bluetoothClassicPlugin.write(modifiedPayload);
  }

}
