import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/snackbar.dart';

/// Represents the state of the BLE node connection page.
enum BleNodeState {
  bluetoothOff,
  locationOff,
  idle,
  scanning,
}

class NodeConnectionPage extends StatefulWidget {
  const NodeConnectionPage({super.key});

  @override
  State<NodeConnectionPage> createState() => _NodeConnectionPageState();
}

class _NodeConnectionPageState extends State<NodeConnectionPage> {
  BleNodeState _bleNodeState = BleNodeState.bluetoothOff;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _checkRequirements();
    }
  }

  /// Checks the necessary conditions to start scanning:
  /// Bluetooth ON and Location enabled.
  Future<void> _checkRequirements() async {
    bool isBluetoothOn = await _isBluetoothEnabled();
    if (!isBluetoothOn) {
      setState(() => _bleNodeState = BleNodeState.bluetoothOff);
      return;
    }

    bool isLocationOn = await _isLocationEnabled();
    if (!isLocationOn) {
      setState(() => _bleNodeState = BleNodeState.locationOff);
      return;
    }

    setState(() => _bleNodeState = BleNodeState.scanning);
  }

  /// Checks whether Bluetooth is currently enabled.
  Future<bool> _isBluetoothEnabled() async {
    try {
      final adapterState = await FlutterBluePlus.adapterState.first;
      return adapterState == BluetoothAdapterState.on;
    } catch (e, backtrace) {
      // Snackbar.show(
      //   context,
      //   prettyException("Bluetooth check error:", e),
      //   success: false,
      // );
      if (kDebugMode) {
        print("Bluetooth check error: $e");
        print("Backtrace: $backtrace");
      }
      return false;
    }
  }

  /// Checks whether location services are enabled.
  Future<bool> _isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Niagara BLE Connection'),
      ),
      body: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_bleNodeState) {
      case BleNodeState.bluetoothOff:
        return _bluetoothOffWidget();
      case BleNodeState.locationOff:
        return _locationOffWidget();
      case BleNodeState.idle:
        return _idleWidget();
      case BleNodeState.scanning:
        return _scanningWidget();
      default:
        return const Text('Unknown State');
    }
  }

  Widget _scanningWidget() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Scanning for devices...', style: TextStyle(fontSize: 16)),
        SizedBox(height: 16),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(),
        ),
      ],
    );
  }

  Widget _idleWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Ready to scan.', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            setState(() => _bleNodeState = BleNodeState.scanning);
          },
          child: const Text('Start Scan'),
        ),
      ],
    );
  }

  Widget _bluetoothOffWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.bluetooth_disabled, size: 48, color: Colors.blueGrey),
        const SizedBox(height: 16),
        const Text('Bluetooth is off. Please enable it to continue.'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            try {
              if (!kIsWeb && Platform.isAndroid) {
                await FlutterBluePlus.turnOn();
              }
              await Future.delayed(const Duration(seconds: 2));
              _checkRequirements();
            } catch (e, backtrace) {
              // Snackbar.show(
              //   context,
              //   prettyException("Error Turning On Bluetooth:", e),
              //   success: false,
              // );
              if (kDebugMode) {
                print("Turn on Bluetooth error: $e");
                print("Backtrace: $backtrace");
              }
            }
          },
          child: const Text('Turn On Bluetooth'),
        ),
      ],
    );
  }

  Widget _locationOffWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.location_off, size: 48, color: Colors.redAccent),
        const SizedBox(height: 16),
        const Text('Location is off. Please enable it to continue.'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            bool openedSettings = await Geolocator.openLocationSettings();
            print("openedSettings : $openedSettings");
            if (openedSettings) {
              await Future.delayed(const Duration(seconds: 2));
              _checkRequirements();
            }
          },
          child: const Text('Open Location Settings'),
        ),
      ],
    );
  }
}
