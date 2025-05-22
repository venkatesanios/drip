import 'dart:convert';
import 'dart:typed_data';
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
}

class BluetoothManager extends ChangeNotifier {
  final _bluetoothClassicPlugin = BluetoothClassic();
  MqttPayloadProvider? providerState;

  List<CustomDevice> _devices = [];
  Uint8List _data = Uint8List.fromList([]);
  String? _connectedAddress;

  List<CustomDevice> get pairedDevices => _devices;
  Uint8List get receivedData => _data;
  bool get isConnected => connectedDevice != null;

  String _buffer = '';
  final ValueNotifier<List<Map<String, dynamic>>> listOfWifi = ValueNotifier([]);
  ValueNotifier<String?> wifiMessage = ValueNotifier<String?>(null);

  BluetoothManager({required MqttPayloadProvider? state}) {
    providerState = state;
    _listenToEvents();
  }

  void _listenToEvents() {
    initPermissions();

    _bluetoothClassicPlugin.onDeviceStatusChanged().listen((status) {
      for (var d in _devices) {
        if (d.device.address == _connectedAddress) {
          d.status = status;
          if (status == BluDevice.disconnected) {
            _connectedAddress = null;
          }
        } else {
          d.status = BluDevice.disconnected;
        }
      }
      notifyListeners();
    });

    listenToBluetoothData();
  }


  Future<void> initPermissions() async {
    await _bluetoothClassicPlugin.initPermissions();
  }


  Future<void> getDevices() async {
    var res = await _bluetoothClassicPlugin.getPairedDevices();
    _devices = res.map((e) => CustomDevice(device: e)).toList();
    notifyListeners();
  }


  Future<void> connectToDevice(CustomDevice customDevice) async {
    _connectedAddress = customDevice.device.address;
    customDevice.status = BluDevice.connecting;
    notifyListeners();

    try {
      await _bluetoothClassicPlugin.connect(
          customDevice.device.address,
          "00001101-0000-1000-8000-00805f9b34fb"
      ).timeout(const Duration(seconds: 5));

      customDevice.status = BluDevice.connected;
    } catch (e) {
      customDevice.status = BluDevice.disconnected;
      _connectedAddress = null;
    }

    notifyListeners();
  }


  CustomDevice? get connectedDevice {
    try {
      return _devices.firstWhere((device) =>
      device.device.address == _connectedAddress && device.isConnected,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> write(String payload) async {
    String modifiedPayload = '*$payload#';
    print('payload to bluetooth:$modifiedPayload');
    await _bluetoothClassicPlugin.write(modifiedPayload);
  }

  void listenToBluetoothData() {
    _bluetoothClassicPlugin.onDeviceDataReceived().listen((event) {
      _buffer += utf8.decode(event); // Append incoming bytes to buffer

      while (_buffer.contains('*') && _buffer.contains('#')) {
        int startIndex = _buffer.indexOf('*');
        int endIndex = _buffer.indexOf('#', startIndex);

        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          String jsonString = _buffer.substring(startIndex + 1, endIndex);
          _buffer = _buffer.substring(endIndex + 1); // Remove processed part

          try {
            Map<String, dynamic> jsonData = json.decode(jsonString);
            String jsonStr = json.encode(jsonData); // Convert to valid JSON string
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
                print('kamaraj.....');
                final cM = data['cM'] as Map<String, dynamic>?;
                if (cM != null && cM.isNotEmpty) {
                  final firstEntry = cM.entries.first.value as Map<String, dynamic>;
                  final message = firstEntry['Message'];
                  print('Message: $message');
                  wifiMessage.value = message;

                }

              }
              else{
                providerState?.updateReceivedPayload(jsonStr, true);
              }
            } catch (e) {
              print('JSON parsing failed: $e');
            }


          } catch (e) {
            print('JSON parsing failed: $e');
          }
        } else {
          // Wait for more data
          break;
        }
      }

      //notifyListeners();
    });
  }

  void updateWifiList(List<Map<String, dynamic>> newList) {
    listOfWifi.value = newList;
  }

  void clearData() {
    _data = Uint8List.fromList([]);
    notifyListeners();
  }
}