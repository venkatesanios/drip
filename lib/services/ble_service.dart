import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/utils/extra.dart';

import '../modules/bluetooth_low_energy/utils/snackbar.dart';

class BleService extends ChangeNotifier {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late BluetoothDevice device;
  int? _rssi;
  int? _mtuSize;
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  bool _isDiscoveringServices = false;
  bool _isConnecting = false;
  bool _isDisconnecting = false;

  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  late StreamSubscription<int> _mtuSubscription;

  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  List<BluetoothDevice> get systemDevices => _systemDevices;
  List<ScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning;
  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  void startListeningBleDevices() {
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      notifyListeners();
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      notifyListeners();
    });
  }

  Future<void> startScan() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices([]);
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e), success: false);
    }
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e), success: false);
    }
  }

  void startListeningBleDeviceState(){
    _connectionStateSubscription = device.connectionState.listen((state) async {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        _services = []; // must rediscover services
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await device.readRssi();
      }
      notifyListeners();
    });

    _mtuSubscription = device.mtu.listen((value) {
      _mtuSize = value;
      notifyListeners();
    });

    _isConnectingSubscription = device.isConnecting.listen((value) {
      _isConnecting = value;
      notifyListeners();
    });

    _isDisconnectingSubscription = device.isDisconnecting.listen((value) {
      _isDisconnecting = value;
      notifyListeners();
    });
  }

  Future onConnectPressed(BluetoothDevice bleDevice) async {
    try {
      device = bleDevice;
      await device.connectAndUpdateStream();
      notifyListeners();
      Snackbar.show(ABC.c, "Connect: Success", success: true);
    } catch (e, backtrace) {
      if (e is FlutterBluePlusException && e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
        print(e);
        print("backtrace: $backtrace");
      }
    }
  }

  Future onCancelPressed() async {
    try {
      await device.disconnectAndUpdateStream(queue: false);
      Snackbar.show(ABC.c, "Cancel: Success", success: true);
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Cancel Error:", e), success: false);
      if (kDebugMode) {
        print("$e");
        print("backtrace: $backtrace");
      }
    }
  }

  Future onDisconnectPressed() async {
    try {
      await device.disconnectAndUpdateStream();
      Snackbar.show(ABC.c, "Disconnect: Success", success: true);
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Disconnect Error:", e), success: false);
      if (kDebugMode) {
        print("$e backtrace: $backtrace");
      }
    }
  }

  Future onDiscoverServicesPressed() async {
    _isDiscoveringServices = true;
    try {
      _services = await device.discoverServices();
      notifyListeners();
      Snackbar.show(ABC.c, "Discover Services: Success", success: true);
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Discover Services Error:", e), success: false);
      if (kDebugMode) {
        print(e);
        print("backtrace: $backtrace");
      }

    }
    _isDiscoveringServices = false;
    notifyListeners();
  }

  Future onRequestMtuPressed() async {
    try {
      await device.requestMtu(223, predelay: 0);
      Snackbar.show(ABC.c, "Request Mtu: Success", success: true);
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Change Mtu Error:", e), success: false);
      if (kDebugMode) {
        print('onRequestMtuPressed Error on :: ${e.toString()}');
        print("onRequestMtuPressed backtrace: $backtrace");
      }

    }
  }

  @override
  void dispose() {
    // scanning subscription
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    // device connection state subscription
    _connectionStateSubscription.cancel();
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    super.dispose();
  }
}