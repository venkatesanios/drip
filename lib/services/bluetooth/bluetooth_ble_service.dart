import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:oro_drip_irrigation/services/mqtt_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Constants/constants.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../utils/enums.dart';
import 'helper/bluetooth_helper.dart';
import 'model/ble_bluetooth_device_model.dart';

class BluetoothBleService {
  static BluetoothBleService? _instance;
  BluetoothBleService._internal();
  VoidCallback? onDeviceFound;

  // Callback for pairing instructions
  Function(String message)? onPairingRequired;
  Function(String message)? onConnectionError;
  Function()? onNoDeviceFound;

  factory BluetoothBleService() {
    _instance ??= BluetoothBleService._internal();
    return _instance!;
  }

  /// ---------------- BLE SERVICE / CHARACTERISTIC UUIDS ----------------

  // WLC custom BLE module
  static const String serviceUuid = "12345678-1234-5678-1234-56789abcdef0";
  static const String writeUuid = "12345678-1234-5678-1234-56789abcdef1";
  static const String notifyUuid1 = "12345678-1234-5678-1234-56789abcdef2";
  static const String notifyUuid2 = "12345678-1234-5678-1234-56789abcdef4";
  static const String notifyUuid3 = "12345678-1234-5678-1234-56789abcdef6";

  // WLC / Nordic UART Service
  static const String serviceUuidForWlc = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String writeUuidForWlc = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String notifyUuidForWlc = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E";

// NEW: WINC3400 Transparent UART Service
  static const String transparentUartServiceUuid = "49535343-FE7D-4AE5-8FA9-9FAFD205E455";
// WINC3400: Phone -> WINC3400
  static const String transparentUartRxUuid = "49535343-8841-43F4-A8D4-ECBE34729BB3";
// WINC3400: WINC3400 -> Phone
  static const String transparentUartTxUuid = "49535343-1E4D-4BD9-BA61-23C647249616";

  // All supported services
  static const List<String> supportedServiceUuids = [
    serviceUuid,
    serviceUuidForWlc,
    transparentUartServiceUuid,
  ];

  // All supported write characteristics
  static const List<String> writeUuids = [
    writeUuid,
    "12345678-1234-5678-1234-56789abcdef3",
    "12345678-1234-5678-1234-56789abcdef5",
    writeUuidForWlc,

    // WINC3400 RX
    transparentUartRxUuid,
  ];

  // All supported notify characteristics
  static const List<String> notifyUuids = [
    notifyUuid1,
    notifyUuid2,
    notifyUuid3,
    notifyUuidForWlc,

    // WINC3400 TX
    transparentUartTxUuid,
  ];



  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notifySubscription;

  final List<BleBluetoothDeviceModel> _devices = [];
  MqttPayloadProvider? providerState;

  bool _isScanning = false;
  bool _writeReady = false;
  bool _isConnecting = false;
  bool _isReconnecting = false;
  bool _isAlreadyConnected = false;
  bool _manualDisconnect = false;

  BleBluetoothDeviceModel? _connectedDevice;
  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;

  Timer? _reconnectTimer;
  Timer? _keepAliveTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 3;
  static const int keepAliveInterval = 15;


  DateTime? _lastActivity;
  String? _currentDeviceId;

  // Buffer for parsing incoming data
  String _buffer = '';

  Timer? _bufferStaleTimer;
  static const int bufferStaleTimeoutMS = 5000;
  bool _isReceivingMessage = false;


  /// ---------------- INIT ----------------
  Future<void> initializeBleService({MqttPayloadProvider? state}) async {
    providerState = state;

    _adapterSubscription = FlutterBluePlus.adapterState.listen((adapterState) {
      debugPrint("🔵 BLE Bluetooth State: $adapterState");
      if (adapterState != BluetoothAdapterState.on) {
        debugPrint("⚠️ BLE Bluetooth is not on! State: $adapterState");
        if (_connectedDevice != null) {
          _resetConnection();
          providerState?.updateBleConnectedDeviceStatus(null);
        }
      }
    });

    debugPrint("✅ BLE Service Initialized with provider");
  }

  /// ---------------- PERMISSIONS ----------------
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      debugPrint("📱 Android SDK Version: $sdkInt");

      final List<Permission> permissions = [];

      if (sdkInt >= 31) { // Android 12+
        permissions.addAll([
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
        ]);
      } else if (sdkInt >= 23) { // Android 6-11
        permissions.addAll([
          Permission.bluetooth,
          Permission.location,
        ]);
      } else { // Older Android versions
        permissions.add(Permission.bluetooth);
      }

      debugPrint("🔐 Requesting BLE permissions: ${permissions.map((p) => p.toString()).toList()}");

      final Map<Permission, PermissionStatus> statuses = await permissions.request();

      bool allGranted = true;
      for (var permission in permissions) {
        final status = statuses[permission];
        debugPrint("BLE Permission $permission: $status");

        if (status == null || !status.isGranted) {
          allGranted = false;

          if (status == PermissionStatus.permanentlyDenied) {
            debugPrint("⚠️ BLE Permission $permission is permanently denied");
            await openAppSettings();
            return false;
          }
        } else {
          debugPrint("✅ BLE Permission granted: $permission");
        }
      }

      if (!allGranted) {
        debugPrint("❌ Not all BLE permissions granted");
        return false;
      }

      debugPrint("✅ All BLE permissions granted successfully");
      return true;

    } catch (e) {
      debugPrint("❌ Error requesting BLE permissions: $e");
      return false;
    }
  }

  // Add this method to your BluetoothBleService class
  Future<void> prepareDeviceForConnection(BleBluetoothDeviceModel d) async {
    debugPrint("🔧 Preparing device for connection: ${d.deviceId}");

    if (Platform.isAndroid) {
      try {
        // Clear GATT cache
        await BluetoothHelper.clearGattCache(d.deviceId);
        debugPrint("✅ GATT cache cleared");
        await Future.delayed(const Duration(milliseconds: 500));

        // Refresh device cache
        await BluetoothHelper.refreshDeviceCache(d.deviceId);
        debugPrint("✅ Device cache refreshed");
        await Future.delayed(const Duration(milliseconds: 500));

      } catch (e) {
        debugPrint("⚠️ Error preparing device: $e");
      }
    }
  }

  /// ---------------- CHECK BLUETOOTH ----------------
  Future<bool> checkBluetooth() async {
    if (!await FlutterBluePlus.isSupported) {
      debugPrint("❌ BLE not supported on this device");
      return false;
    }

    final state = await FlutterBluePlus.adapterState.first;
    debugPrint("📱 BLE Adapter State: $state");

    if (state != BluetoothAdapterState.on) {
      debugPrint("❌ BLE Bluetooth is not ON. Please enable Bluetooth");
      return false;
    }

    return true;
  }

  /// ---------------- START SCAN ----------------
  Future<void> startScan({String? deviceId}) async {
    debugPrint("🔍 Starting BLE scan process...");
    debugPrint("deviceNameFilter:$deviceId");

    if (_isScanning) {
      debugPrint("⚠️ BLE Scan already in progress");
      return;
    }

    debugPrint("📱 Requesting BLE permissions...");
    if (!await requestPermissions()) {
      debugPrint("❌ BLE Permissions not granted");
      return;
    }

    debugPrint("📱 Checking BLE Bluetooth...");
    if (!await checkBluetooth()) {
      debugPrint("❌ BLE Bluetooth not available");
      return;
    }

    debugPrint("🧹 Clearing previous BLE devices...");
    _devices.clear();
    try {
      providerState?.updateBlePairedDevices([]);
    } catch (e) {
      debugPrint("⚠️ Error updating BLE provider: $e");
    }

    debugPrint("🛑 Stopping any existing BLE scan...");
    await stopScan();

    _isScanning = true;
    debugPrint("🔍 BLE Scan Started - Looking for devices...");

    try {
      // Include ALL supported service UUIDs in the scan filter
      await FlutterBluePlus.startScan(
        withServices: [
          Guid(serviceUuid),
          Guid(serviceUuidForWlc),
          Guid(transparentUartServiceUuid), // ADD THIS - WINC3400 service
        ],
        timeout: const Duration(seconds: 20),
      );

      debugPrint("✅ BLE Scan started successfully");

      _scanSubscription = FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
        debugPrint("📡 Received ${results.length} BLE scan results");

        for (final r in results) {
          final device = r.device;
          final name = device.platformName;

          // Get advertisement data
          final advertisementData = r.advertisementData;
          final localName = advertisementData.localName;
          final serviceUuids = advertisementData.serviceUuids;

          debugPrint("============ BLE DEVICE FOUND ============");
          debugPrint("Name: $name");
          debugPrint("Local Name: $localName");
          debugPrint("ID: ${device.remoteId}");
          debugPrint("RSSI: ${r.rssi}");
          debugPrint("Advertised Services: $serviceUuids");
          debugPrint("Manufacturer Data: ${advertisementData.manufacturerData}");
          debugPrint("Service Data: ${advertisementData.serviceData}");
          debugPrint("======================================");

          bool shouldAddDevice = false;

          // Check for WINC3400 devices (they may have specific naming patterns)
          bool isWincDevice = false;
          if (name.isNotEmpty) {
            // WINC3400 typically has names like "WINC3400", "WINC", or custom names
            isWincDevice = name.contains('WINC') ||
                name.startsWith('NIA_') ||
                name.startsWith('WIFI_') ||
                (localName.contains('WINC'));
          }

          if (deviceId != null && deviceId.isNotEmpty) {
            // Your existing filter logic
            if (name.startsWith("NIA_")) {
              final deviceIdFromName = name.substring(4);
              if (deviceIdFromName == deviceId) {
                shouldAddDevice = true;
                debugPrint("✅ BLE Device matches filter: $deviceIdFromName == $deviceId");
              } else {
                debugPrint("❌ BLE Device filtered out: $deviceIdFromName != $deviceId");
              }
            } else {
              if (name == deviceId) {
                shouldAddDevice = true;
                debugPrint("✅ BLE Device matches direct filter: $name == $deviceId");
              } else {
                debugPrint("❌ BLE Device filtered out: $name != $deviceId");
              }
            }
          } else {
            // Add any device with a name, or WINC devices even without name
            shouldAddDevice = name.isNotEmpty || isWincDevice;
            debugPrint("ℹ️ No filter applied, adding BLE device if name exists or is WINC device");
          }

          final exists = _devices.any((d) => d.deviceId == device.remoteId.str);

          if (!exists && shouldAddDevice) {
            debugPrint("➕ Adding new BLE device: $name");
            final newDevice = BleBluetoothDeviceModel(
              device: device,
              connectionState: BlueConnectionState.disconnected,
              rssi: r.rssi,
              name: name,
            );
            _devices.add(newDevice);
            final updatedDevices = List<BleBluetoothDeviceModel>.from(_devices);
            try {
              providerState?.updateBlePairedDevices(updatedDevices);
            } catch (e) {
              debugPrint("⚠️ Error updating BLE provider: $e");
            }
            onDeviceFound?.call();
            debugPrint("✅ BLE Device added successfully. Total devices: ${_devices.length}");
          }
        }
      });

      // Wait for scan to finish
      await FlutterBluePlus.isScanning.where((scanning) => scanning == false).first;

      _isScanning = false;

      if (_devices.isEmpty) {
        debugPrint("⚠️ BLE scan finished — no matching devices found");
        onNoDeviceFound?.call();
      }

    } catch (e) {
      debugPrint("❌ Error starting BLE scan: $e");
      _isScanning = false;
      rethrow;
    }
  }

  /*Future<void> startScan({String? deviceId}) async {
    debugPrint("🔍 Starting BLE scan process...");
    debugPrint("deviceNameFilter:$deviceId");

    if (_isScanning) {
      debugPrint("⚠️ BLE Scan already in progress");
      return;
    }

    debugPrint("📱 Requesting BLE permissions...");
    if (!await requestPermissions()) {
      debugPrint("❌ BLE Permissions not granted");
      return;
    }

    debugPrint("📱 Checking BLE Bluetooth...");
    if (!await checkBluetooth()) {
      debugPrint("❌ BLE Bluetooth not available");
      return;
    }

    debugPrint("🧹 Clearing previous BLE devices...");
    _devices.clear();
    try {
      providerState?.updateBlePairedDevices([]);
    } catch (e) {
      debugPrint("⚠️ Error updating BLE provider: $e");
    }

    debugPrint("🛑 Stopping any existing BLE scan...");
    await stopScan();

    _isScanning = true;
    debugPrint("🔍 BLE Scan Started - Looking for WINC3400 devices...");

    try {
      // REMOVE the withServices filter to detect all devices
      await FlutterBluePlus.startScan(
        // withServices: [Guid(serviceUuid), Guid(serviceUuidForWlc)], // <-- COMMENT THIS OUT
        timeout: const Duration(seconds: 20),
      );
      debugPrint("✅ BLE Scan started successfully");

      _scanSubscription = FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
        debugPrint("📡 Received ${results.length} BLE scan results");

        for (final r in results) {
          final device = r.device;
          final name = device.platformName;

          // Get advertisement data from ScanResult
          final advertisementData = r.advertisementData;
          final localName = advertisementData.localName;
          final serviceUuids = advertisementData.serviceUuids;
          final manufacturerData = advertisementData.manufacturerData;
          final serviceData = advertisementData.serviceData;
          final txPowerLevel = advertisementData.txPowerLevel;

          debugPrint("============ BLE DEVICE FOUND ============");
          debugPrint("Name: $name");
          debugPrint("Local Name (adv): $localName");
          debugPrint("ID: ${device.remoteId}");
          debugPrint("RSSI: ${r.rssi}");
          debugPrint("Manufacturer Data: $manufacturerData");
          debugPrint("Service Data: $serviceData");
          debugPrint("Service UUIDs: $serviceUuids");
          debugPrint("TX Power: $txPowerLevel");
          debugPrint("======================================");

          bool shouldAddDevice = false;

          // Check for WINC3400 naming patterns
          bool isWincDevice = false;
          if (name.isNotEmpty) {
            // WINC3400 typically has names like "WINC3400", "WINC", or custom names
            isWincDevice = name.contains('WINC') ||
                name.startsWith('NIA_') ||
                name.startsWith('WIFI_') ||
                (localName != null && localName.contains('WINC'));
          }

          if (deviceId != null && deviceId.isNotEmpty) {
            // Your existing filter logic
            if (name.startsWith("NIA_")) {
              final deviceIdFromName = name.substring(4);
              if (deviceIdFromName == deviceId) {
                shouldAddDevice = true;
                debugPrint("✅ BLE Device matches filter: $deviceIdFromName == $deviceId");
              }
            } else {
              if (name == deviceId) {
                shouldAddDevice = true;
                debugPrint("✅ BLE Device matches direct filter: $name == $deviceId");
              }
            }
          } else {
            // Add any device with a name (less restrictive)
            shouldAddDevice = name.isNotEmpty;
            debugPrint("ℹ️ No filter applied, adding BLE device if name exists");
          }

          final exists = _devices.any((d) => d.deviceId == device.remoteId.str);

          if (!exists && shouldAddDevice) {
            debugPrint("➕ Adding new BLE device: $name");
            final newDevice = BleBluetoothDeviceModel(
              device: device,
              connectionState: BlueConnectionState.disconnected,
              rssi: r.rssi,
              name: name,
            );
            _devices.add(newDevice);
            final updatedDevices = List<BleBluetoothDeviceModel>.from(_devices);
            try {
              providerState?.updateBlePairedDevices(updatedDevices);
            } catch (e) {
              debugPrint("⚠️ Error updating BLE provider: $e");
            }
            onDeviceFound?.call();
            debugPrint("✅ BLE Device added successfully. Total devices: ${_devices.length}");
          }
        }
      });

      await FlutterBluePlus.isScanning.where((scanning) => scanning == false).first;

      _isScanning = false;

      if (_devices.isEmpty) {
        debugPrint("⚠️ BLE scan finished — no matching devices found");
        onNoDeviceFound?.call();
      }

    } catch (e) {
      debugPrint("❌ Error starting BLE scan: $e");
      _isScanning = false;
      rethrow;
    }
  }*/

  /// ---------------- STOP SCAN ----------------
  Future<void> stopScan() async {
    if (!_isScanning) {
      debugPrint("ℹ️ No active BLE scan to stop");
      return;
    }

    _isScanning = false;
    debugPrint("🛑 Stopping BLE Scan...");

    try {
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      await FlutterBluePlus.stopScan();
      debugPrint("✅ BLE Scan stopped successfully");
    } catch (e) {
      debugPrint("❌ Error stopping BLE scan: $e");
    }
  }

  /// ---------------- CONNECT TO DEVICE ----------------
  Future<bool> connectToDevice(BleBluetoothDeviceModel d) async {
    if (_isConnecting || _isReconnecting) {
      debugPrint("⚠️ BLE Connection already in progress");
      return false;
    }

    debugPrint("🔌 Attempting to connect to BLE device: ${d.deviceName} (ID: ${d.deviceId})");
    _currentDeviceId = d.deviceId;

    _isConnecting = true;
    _reconnectAttempts = 0;

    try {
      // Step 1: Request permissions
      if (!await requestPermissions()) {
        debugPrint("❌ BLE Permissions not granted");
        _isConnecting = false;
        return false;
      }

      // Step 2: Stop scanning BEFORE connecting
      await stopScan();
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Clear any existing connection state
      await _clearConnectionState();

      // Step 4: Try to force disconnect the device
      try {
        debugPrint("🔧 Attempting to force disconnect the device...");
        await d.device.disconnect();
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint("Force disconnect error (expected): $e");
      }

      // Step 5: Update UI state to CONNECTING
      d.connectionState = BlueConnectionState.connecting;
      try {
        providerState?.updateBleDeviceStatus(
            d.deviceId, BlueConnectionState.connecting.index);
        providerState?.updateBleConnectedDeviceStatus(null);
      } catch (e) {
        debugPrint("⚠️ Error updating BLE status: $e");
      }

      // Step 6: Connect WITHOUT autoConnect to prevent automatic bonding
      debugPrint("🔗 Connecting to BLE ${d.deviceId} with autoConnect=false...");

      await d.device.connect(
        timeout: const Duration(seconds: 30),
        autoConnect: false, // Critical: false prevents auto bonding
        license: License.free,
      );

      // Verify connection
      await Future.delayed(const Duration(milliseconds: 500));
      if (!d.device.isConnected) {
        throw Exception("Device not connected after connect call");
      }

      debugPrint("✅ BLE Connected successfully");
      _lastActivity = DateTime.now();
      _isAlreadyConnected = true;

      // Step 7: Set up connection monitoring
      await _setupConnectionMonitoring(d);

      // Step 8: Wait for connection to stabilize (critical delay)
      await Future.delayed(const Duration(seconds: 1));

      // Step 9: Discover services (do this BEFORE any bonding attempt)
      _connectedDevice = d;
      _writeReady = false;

      debugPrint("🔍 Discovering BLE services...");
      bool servicesFound = await _discoverServicesWithRetry(d, maxRetries: 3);

      if (!servicesFound) {
        debugPrint("⚠️ BLE Custom service not found after retries");
        _showConfigurationInstructions();
        d.connectionState = BlueConnectionState.disconnected;
        providerState?.updateBleDeviceStatus(
            d.deviceId, BlueConnectionState.disconnected.index);
        providerState?.updateBleConnectedDeviceStatus(null);
        _isConnecting = false;
        _isAlreadyConnected = false;

        onConnectionError?.call(
          "Device disconnected during setup. Please ensure it's in configuration mode and try again.",
        );

        return false;
      }

      // 👇 NEW: request tighter connection interval to reduce notification drops
      try {
        await d.device.requestConnectionPriority(connectionPriorityRequest: ConnectionPriority.high);
        debugPrint("✅ Requested high connection priority");
      } catch (e) {
        debugPrint("⚠️ Could not request connection priority: $e");
      }

      // Step 10: Skip MTU request entirely for this device
      // Many BLE devices don't need MTU change and it can cause issues
      debugPrint("⚠️ Skipping MTU request to avoid bonding issues");


      // Step 11: Update final status to CONNECTED
      d.connectionState = BlueConnectionState.connected;
      try {
        providerState?.updateBleDeviceStatus(d.deviceId,
            BlueConnectionState.connected.index);
        providerState?.updateBleConnectedDeviceStatus(d);
      } catch (e) {
        debugPrint("⚠️ Error updating BLE final status: $e");
      }

      // Step 12: Start keep-alive to prevent disconnection
      _startKeepAlive();

      debugPrint("✅ BLE Connection complete - Write: ${_writeChar != null}, Notify: ${_notifyChar != null}");
      _isConnecting = false;
      return true;

    } catch (e) {
      debugPrint("❌ BLE Connection Failed: $e");

      String errorMessage = e.toString();

      if (errorMessage.contains('AUTHENTICATION_FAILURE') ||
          errorMessage.contains('status=5')) {

        const message = "⚠️ Bluetooth Connection Issue\n\n"
            "The device connects but fails during automatic pairing.\n\n"
            "This device may not require pairing/bonding.\n\n"
            "Please try these steps:\n\n"
            "1️⃣ FORGET THE DEVICE:\n"
            "   • Go to Settings → Connected devices → Bluetooth\n"
            "   • Find 'NIA_2CCF674C0F8A' and tap 'Forget'\n\n"
            "2️⃣ RESTART BLUETOOTH:\n"
            "   • Turn Bluetooth OFF\n"
            "   • Wait 5 seconds\n"
            "   • Turn Bluetooth ON\n\n"
            "3️⃣ POWER CYCLE THE DEVICE:\n"
            "   • Unplug the device\n"
            "   • Wait 30 seconds\n"
            "   • Plug it back in\n\n"
            "4️⃣ Try connecting again\n\n"
            "If the issue persists, the device may need a factory reset.";

        debugPrint(message);

        if (onPairingRequired != null) {
          onPairingRequired!(message);
        }
      } else if (onConnectionError != null) {
        onConnectionError!(errorMessage);
      }

      d.connectionState = BlueConnectionState.disconnected;
      try {
        providerState?.updateBleDeviceStatus(
            d.deviceId,
            BlueConnectionState.disconnected.index);
        providerState?.updateBleConnectedDeviceStatus(null);
      } catch (e) {
        debugPrint("⚠️ Error updating BLE status: $e");
      }

      _resetConnection();
      _isConnecting = false;
      _isAlreadyConnected = false;
      return false;
    }
  }

  /// ---------------- SETUP CONNECTION MONITORING ----------------
  Future<void> _setupConnectionMonitoring(BleBluetoothDeviceModel d) async {
    _connectionSubscription = d.device.connectionState.listen((state) {
      debugPrint("📱 BLE Connection State: $state at ${DateTime.now()}");

      if (state == BluetoothConnectionState.disconnected) {
        debugPrint("🔌 BLE Device disconnected");
        _lastActivity = null;
        _isAlreadyConnected = false;

        // Update to disconnected state
        d.connectionState = BlueConnectionState.disconnected;
        _resetConnection();

        try {
          providerState?.updateBleDeviceStatus(
              d.deviceId,
              BlueConnectionState.disconnected.index);
          providerState?.updateBleConnectedDeviceStatus(null);
        } catch (e) {
          debugPrint("⚠️ Error updating BLE status: $e");
        }

        // Only attempt reconnect if we weren't manually disconnected
        if (_currentDeviceId != null && !_isConnecting && !_isReconnecting && !_manualDisconnect) {
          _attemptReconnect(d);
        }

      } else if (state == BluetoothConnectionState.connected) {
        debugPrint("✅ BLE Device connected and stable");
        d.connectionState = BlueConnectionState.connected;
        _isAlreadyConnected = true;
      }
    });
  }

  /// ---------------- START ALIVE ----------------
  void _startKeepAlive() {
    _stopKeepAlive(); // Stop any existing timer

    debugPrint("💓 Starting BLE keep-alive (every $keepAliveInterval seconds)");

    _keepAliveTimer = Timer.periodic(
      const Duration(seconds: keepAliveInterval),
          (timer) async {
        if (_isReceivingMessage) {
          debugPrint("⏸️ Skipping keep-alive — message assembly in progress");
          return;
        }
        if (_connectedDevice != null &&
            _connectedDevice!.connectionState == BlueConnectionState.connected &&
            _writeChar != null) {
          debugPrint("💓 Sending keep-alive ping...");
          final success = await _sendKeepAlive();
          if (!success) {
            debugPrint("⚠️ Keep-alive failed, device might be disconnected");
          }
        } else {
          _stopKeepAlive();
        }
      },
    );
  }

  /// ---------------- STOP ALIVE ----------------
  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  /// ---------------- SENT ----------------

  Future<bool> _sendKeepAlive() async {
    if (_writeChar == null) return false;

    try {
      const keepAlivePayload = "*STATUS#\r\n";
      final bytes = utf8.encode(keepAlivePayload);

      await _writeChar!.write(bytes, withoutResponse: false); // 👈 match characteristic's actual capability
      _lastActivity = DateTime.now();
      return true;
    } catch (e) {
      debugPrint("❌ Keep-alive failed: $e");
      return false;
    }
  }

  /// ---------------- WRITE METHOD ----------------
  Future<bool> write(String payload, {bool silent = false, int maxRetries = 3}) async {
    if (_writeChar == null) {
      if (!silent) debugPrint("❌ BLE write characteristic not available");
      return false;
    }

    if (!_writeReady) {
      if (!silent) debugPrint("⚠️ BLE write not ready, waiting...");
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (_connectedDevice == null ||
        _connectedDevice!.connectionState != BlueConnectionState.connected) {
      if (!silent) debugPrint("❌ BLE device not connected");
      return false;
    }

    final finalPayload = payload;
    final dataWithTerminator = '$finalPayload\r\n';
    final bytes = utf8.encode(dataWithTerminator);

    const int chunkSize = 20; // safe default-MTU-23 usable payload size

    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        if (!silent) debugPrint("📤 [BLE] Sending: $finalPayload (Attempt ${attempts + 1})");

        // Split into chunks and write each sequentially
        for (int i = 0; i < bytes.length; i += chunkSize) {
          final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
          final chunk = bytes.sublist(i, end);

          await _writeChar!.write(chunk, withoutResponse: false); // matches char's actual capability
          await Future.delayed(const Duration(milliseconds: 30)); // small gap between chunks
        }

        if (!silent) debugPrint("✅ [BLE] Sent successfully");
        _lastActivity = DateTime.now();
        await Future.delayed(const Duration(milliseconds: 100));
        return true;

      } catch (e) {
        attempts++;
        if (!silent) debugPrint("❌ [BLE] Write Error (Attempt $attempts): $e");

        if (attempts < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
          await _refreshCharacteristics();
        }
      }
    }

    if (!silent) debugPrint("❌ [BLE] Failed to write after $maxRetries attempts");
    return false;
  }

  /// ---------------- AUTO RECONNECT ----------------
  void _attemptReconnect(BleBluetoothDeviceModel d) {
    if (_reconnectTimer != null || _isReconnecting) return;

    if (_reconnectAttempts < maxReconnectAttempts) {
      _reconnectAttempts++;
      _isReconnecting = true;
      debugPrint("🔄 BLE Auto-reconnect attempt $_reconnectAttempts/$maxReconnectAttempts in 5 seconds...");

      _reconnectTimer = Timer(const Duration(seconds: 5), () async {
        _reconnectTimer = null;

        if (_connectedDevice == null && !_isConnecting) {
          await Future.delayed(const Duration(seconds: 2));

          final success = await connectToDevice(d);
          _isReconnecting = false;

          if (!success && _reconnectAttempts < maxReconnectAttempts) {
            debugPrint("⚠️ BLE Reconnect failed, will retry on next disconnect");
          } else if (!success) {
            debugPrint("❌ BLE All reconnect attempts failed");
            _reconnectAttempts = 0;
            _currentDeviceId = null;
            _isAlreadyConnected = false;
          }
        } else {
          _isReconnecting = false;
        }
      });
    } else {
      debugPrint("❌ BLE Max reconnect attempts reached. Manual reconnect required.");
      _reconnectAttempts = 0;
      _currentDeviceId = null;
      _isReconnecting = false;
      _isAlreadyConnected = false;
    }
  }

  /// ---------------- CLEAR CONNECTION STATE ----------------
  Future<void> _clearConnectionState() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _notifySubscription?.cancel();
    _notifySubscription = null;

    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    _writeChar = null;
    _notifyChar = null;
    _writeReady = false;

    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.device.disconnect();
        await Future.delayed(const Duration(milliseconds: 1000));
      } catch (e) {
        debugPrint("⚠️ Error disconnecting BLE: $e");
      }
      _connectedDevice = null;
    }

    _isAlreadyConnected = false;
  }

  /// ---------------- DISCOVER SERVICES WITH RETRY ----------------

  /// ---------------- DISCOVER SERVICES WITH RETRY ----------------

  Future<bool> _discoverServicesWithRetry(BleBluetoothDeviceModel d, {int maxRetries = 3,}) async {

    for (int attempt = 1; attempt <= maxRetries; attempt++) {

      debugPrint(
        "🔍 BLE Service discovery attempt "
            "$attempt/$maxRetries",
      );

      try {

        // --------------------------------------
        // CHECK CONNECTION
        // --------------------------------------

        final isConnected =
        d.device.isConnected;

        if (!isConnected) {

          debugPrint(
            "❌ Device not connected "
                "during service discovery",
          );

          return false;
        }


        // --------------------------------------
        // DISCOVER SERVICES
        // --------------------------------------

        final services =
        await d.device.discoverServices();

        debugPrint(
          "📋 Found ${services.length} BLE services",
        );


        // --------------------------------------
        // PRINT ALL SERVICES
        // --------------------------------------

        for (final service in services) {

          debugPrint(
            "🔹 BLE Service: ${service.uuid}",
          );

          for (final characteristic
          in service.characteristics) {

            debugPrint(
              "   └── Characteristic: "
                  "${characteristic.uuid}",
            );

            debugPrint(
              "       Properties: "
                  "${characteristic.properties}",
            );
          }
        }


        // --------------------------------------
        // CHECK SUPPORTED SERVICE
        // --------------------------------------

        final targetServiceUuids =
        supportedServiceUuids.map((uuid) => uuid.toLowerCase(),
        ).toList();

        final foundCustomService = services.any((service) {
            final discoveredUuid = service.uuid.toString().toLowerCase();
            return targetServiceUuids.contains(discoveredUuid);
          },
        );


        // --------------------------------------
        // SERVICE FOUND
        // --------------------------------------

        if (foundCustomService) {

          debugPrint("✅ Supported BLE service found",);

          await _processServices(services);

          // Verify that communication
          // characteristics were found.
          debugPrint("📌 Write Characteristic: ""${_writeChar?.uuid}");

          debugPrint("📌 Notify Characteristic: ""${_notifyChar?.uuid}",);

          debugPrint("📌 Write Ready: $_writeReady",);


          if (_writeChar != null ||
              _notifyChar != null) {

            debugPrint(
              "✅ BLE communication "
                  "characteristics configured",
            );

            return true;
          }

          debugPrint(
            "⚠️ Service found but "
                "communication characteristics "
                "were not found",
          );

        } else {

          debugPrint(
            "⚠️ Supported BLE service not found",
          );
        }


        // --------------------------------------
        // RETRY
        // --------------------------------------

        if (attempt < maxRetries) {

          debugPrint(
            "🔄 Retrying service discovery "
                "in 500ms...",
          );

          await Future.delayed(
            const Duration(
              milliseconds: 500,
            ),
          );
        }

      } catch (e) {

        debugPrint(
          "❌ BLE Service discovery "
              "attempt $attempt failed: $e",
        );

        if (attempt < maxRetries) {

          await Future.delayed(
            const Duration(
              milliseconds: 500,
            ),
          );

        } else {

          return false;
        }
      }
    }


    debugPrint(
      "❌ Supported BLE service not found "
          "after $maxRetries attempts",
    );

    return false;
  }

  /*Future<bool> _discoverServicesWithRetry(BleBluetoothDeviceModel d, {int maxRetries = 3}) async {

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      debugPrint("🔍 BLE Service discovery attempt $attempt/$maxRetries");

      try {
        // Check if still connected
        final isConnected = d.device.isConnected;
        if (!isConnected) {
          debugPrint("❌ Device not connected during service discovery");
          // Don't try to reconnect, just return false
          return false;
        }

        // Discover services
        final services = await d.device.discoverServices();
        debugPrint("📋 Found ${services.length} BLE services");


        for (var service in services) {
          debugPrint("BLE Service: ${service.uuid}");
        }

        bool foundCustomService = services.any(
                (s) => [serviceUuid.toLowerCase(),
                  serviceUuidForWlc.toLowerCase()].contains(s.uuid.toString().toLowerCase())
        );

        if (foundCustomService) {
          debugPrint("✅ Found BLE custom service on attempt $attempt");
          await _processServices(services);
          return true;
        }

        if (attempt < maxRetries) {
          debugPrint("⚠️ BLE Custom service not found, retrying in 500ms...");
          await Future.delayed(const Duration(milliseconds: 500));
        }

      } catch (e) {
        debugPrint("❌ BLE Service discovery attempt $attempt failed: $e");
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          // Last attempt failed, return false
          return false;
        }
      }
    }

    debugPrint("❌ BLE Custom service not found after $maxRetries attempts");
    return false;
  }*/

  /// ---------------- PROCESS SERVICES ----------------

  Future<void> _processServices(List<BluetoothService> services,) async {

    debugPrint(
      "🔧 Processing BLE services...",
    );


    for (final service in services) {

      final serviceUuidLower =
      service.uuid
          .toString()
          .toLowerCase();


      // ------------------------------------------
      // CHECK IF SUPPORTED SERVICE
      // ------------------------------------------

      if (!supportedServiceUuids
          .map(
            (uuid) => uuid.toLowerCase(),
      )
          .contains(serviceUuidLower)) {

        debugPrint(
          "⏭️ Ignoring unsupported service: "
              "${service.uuid}",
        );

        continue;
      }


      debugPrint(
        "✅ Supported BLE Service Found: "
            "${service.uuid}",
      );

      debugPrint(
        "📊 Characteristics: "
            "${service.characteristics.length}",
      );


      // ------------------------------------------
      // PROCESS CHARACTERISTICS
      // ------------------------------------------

      for (final char
      in service.characteristics) {

        final uuid =
        char.uuid
            .toString()
            .toLowerCase();


        debugPrint(
          "  🔹 Characteristic: $uuid",
        );

        debugPrint(
          "     Properties: "
              "${char.properties}",
        );


        // ========================================
        // WRITE CHARACTERISTIC
        // ========================================

        if (writeUuids
            .map(
              (uuid) =>
              uuid.toLowerCase(),
        )
            .contains(uuid) &&
            (char.properties.write ||
                char.properties.writeWithoutResponse)) {

          if (_writeChar == null) {

            _writeChar = char;

            _writeReady = true;

            debugPrint(
              "✅ BLE WRITE characteristic ready: "
                  "$uuid",
            );
          }
        }


        // ========================================
        // NOTIFY CHARACTERISTIC
        // ========================================

        if (notifyUuids
            .map(
              (uuid) =>
              uuid.toLowerCase(),
        )
            .contains(uuid) &&
            char.properties.notify) {

          if (_notifyChar == null) {

            _notifyChar = char;

            debugPrint(
              "✅ BLE NOTIFY characteristic found: "
                  "$uuid",
            );


            try {

              // Enable notifications
              await _notifyChar!
                  .setNotifyValue(true);

              debugPrint(
                "✅ BLE Notify enabled successfully",
              );


              // Listen for incoming data
              _notifySubscription =
                  _notifyChar!
                      .onValueReceived
                      .listen(
                        (value) {

                      debugPrint(
                        "📩 BLE RAW DATA: "
                            "$value",
                      );

                      debugPrint(
                        "📩 BLE DATA LENGTH: "
                            "${value.length}",
                      );


                      // Convert bytes to string
                      final response =
                      String.fromCharCodes(
                        value,
                      );


                      debugPrint(
                        "📩 BLE Device Response: "
                            "$response",
                      );


                      // Process response
                      _handleDeviceResponse(
                        response,
                      );
                    },
                  );

            } catch (e) {

              debugPrint(
                "⚠️ Could not enable BLE "
                    "notifications: $e",
              );
            }
          }
        }
      }
    }


    // ------------------------------------------
    // FINAL STATUS
    // ------------------------------------------

    debugPrint(
      "==========================================",
    );

    debugPrint(
      "🔧 BLE CHARACTERISTIC SETUP COMPLETE",
    );

    debugPrint(
      "✏️ Write Characteristic: "
          "${_writeChar?.uuid}",
    );

    debugPrint(
      "📡 Notify Characteristic: "
          "${_notifyChar?.uuid}",
    );

    debugPrint(
      "✏️ Write Ready: $_writeReady",
    );

    debugPrint(
      "==========================================",
    );
  }

/*  Future<void> _processServices(List<BluetoothService> services) async {

    print("_processServices : $_processServices");

    for (var service in services) {

      if ([serviceUuid.toLowerCase(), serviceUuidForWlc.toLowerCase()].contains(service.uuid.toString().toLowerCase())) {
        debugPrint("✅ BLE Target Service Found: ${service.uuid}");
        debugPrint("📊 Found ${service.characteristics.length} BLE characteristics");
        for (var char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();
          debugPrint("  BLE Characteristic: $uuid");
          debugPrint("    Properties: ${char.properties}");

          if (writeUuids.contains(uuid) && (char.properties.write || char.properties.writeWithoutResponse)) {
            if (_writeChar == null) {
              _writeChar = char;
              _writeReady = true;
              debugPrint("✅ BLE Write characteristic ready: $uuid");
            }
          }

          if (notifyUuids.contains(uuid) && char.properties.notify) {
            if (_notifyChar == null) {
              _notifyChar = char;
              debugPrint("✅ BLE Notify characteristic found: $uuid");

              try {
                await _notifyChar!.setNotifyValue(true);
                debugPrint("✅ BLE Notify enabled successfully");

                _notifySubscription = _notifyChar!.onValueReceived.listen((value) {
                  print("value => $value | ${value.length}");
                  final response = String.fromCharCodes(value);
                  debugPrint("📩 BLE Device Response: $response");
                  _handleDeviceResponse(response);
                });
              } catch (e) {
                debugPrint("⚠️ Could not enable BLE notifications: $e");
              }
            }
          }
        }
      }
      if (service.uuid.toString().toLowerCase() == serviceUuidForWlc.toLowerCase()) {
        debugPrint("✅ BLE Target Service Found For WLC: ${service.uuid}");
        debugPrint("📊 Found ${service.characteristics.length} BLE characteristics");

        for (var char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();
          debugPrint("  BLE Characteristic: $uuid");
          debugPrint("    Properties: ${char.properties}");

          if (writeUuids.contains(uuid) && (char.properties.write || char.properties.writeWithoutResponse)) {
            if (_writeChar == null) {
              _writeChar = char;
              _writeReady = true;
              debugPrint("✅ BLE Write characteristic ready: $uuid");
            }
          }

          if (notifyUuids.contains(uuid) && char.properties.notify) {
            if (_notifyChar == null) {
              _notifyChar = char;
              debugPrint("✅ BLE Notify characteristic found: $uuid");

              try {
                await _notifyChar!.setNotifyValue(true);
                debugPrint("✅ BLE Notify enabled successfully");

                _notifySubscription = _notifyChar!.onValueReceived.listen((value) {
                  final response = String.fromCharCodes(value);
                  debugPrint("📩 BLE Device Response: $response");
                  _handleDeviceResponse(response);
                });
              } catch (e) {
                debugPrint("⚠️ Could not enable BLE notifications: $e");
              }
            }
          }
        }
      }

      if (service.uuid.toString().toLowerCase() == transparentUartServiceUuid.toLowerCase()) {

        for (final char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();

          if (uuid == transparentUartRxUuid.toLowerCase()) {
            if (char.properties.write ||
                char.properties.writeWithoutResponse) {
              _writeChar = char;
              _writeReady = true;

              debugPrint('✅ UART RX Write characteristic found');
            }
          }

          if (uuid == transparentUartTxUuid.toLowerCase()) {
            if (char.properties.notify) {
              _notifyChar = char;

              await _notifyChar!.setNotifyValue(true);

              _notifySubscription =
                  _notifyChar!.onValueReceived.listen((value) {
                    final response = String.fromCharCodes(value);

                    debugPrint(
                      '📩 UART TX received: $response',
                    );

                    _handleDeviceResponse(response);
                  });

              debugPrint('✅ UART TX Notify enabled');
            }
          }
        }
      }
    }
  }*/

  /// ---------------- REFRESH CHARACTERISTICS ----------------
  Future<void> _refreshCharacteristics() async {
    if (_connectedDevice != null) {
      try {
        final services = await _connectedDevice!.device.discoverServices();
        await _processServices(services);
      } catch (e) {
        debugPrint("⚠️ Error refreshing BLE characteristics: $e");
      }
    }
  }

  /// ---------------- HANDLE DEVICE RESPONSE ----------------

  void _handleDeviceResponse(String response) {
    debugPrint("📱 Processing BLE device response: $response");
    _lastActivity = DateTime.now();
    _isReceivingMessage = true; // 👈 mark as busy

    if (!_isAlreadyConnected && _connectedDevice != null) {
      _isAlreadyConnected = true;
      _connectedDevice!.connectionState = BlueConnectionState.connected;
    }

    if (response.isNotEmpty && response[0] == '*' && _buffer.isNotEmpty) {
      debugPrint("⚠️ New message started while old buffer was incomplete — discarding stale buffer");
      _buffer = '';
    }

    _buffer += response;

    _bufferStaleTimer?.cancel();
    _bufferStaleTimer = Timer(const Duration(milliseconds: bufferStaleTimeoutMS), () {
      if (_buffer.isNotEmpty) {
        debugPrint("⏱️ Buffer stale — clearing: $_buffer");
        _buffer = '';
      }
      _isReceivingMessage = false; // 👈 clear busy flag
    });

    _parseBuffer();
  }

  /// ---------------- PARSE BUFFER ----------------
  void _parseBuffer() {
    debugPrint('BLE _buffer----> $_buffer');

    if (_buffer.isEmpty) return;

    if (_buffer.isNotEmpty && _buffer[0] == '*' && _buffer[_buffer.length - 1] == '#') {
      String sliced = _buffer.substring(1, _buffer.length - 1);
      debugPrint("sliced : $sliced");
      final result = Constants.validatePayloadWithCrc(sliced);
      debugPrint("wlc ble result => $result");
      if (result != null) {
        _processData(result);
        _isReceivingMessage = false; // 👈 clear on success too
      } else {
        debugPrint('⚠️ CRC mismatch — likely dropped BLE packet(s). Discarding buffer.');
      }
      _buffer = ''; // 👈 ALWAYS clear here, success or failure — prevents permanent lockup
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


  /// ---------------- PROCESS DATA ----------------
  void _processData(String jsonString) {
    debugPrint("BLE _processData call $jsonString");
    try {
      final data = json.decode(jsonString);
      final jsonStr = json.encode(data);

      MqttService().onMqttPayloadReceived(jsonString);

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
      debugPrint("Error parsing BLE JSON: $e");
    }
  }

  /// ---------------- SHOW CONFIGURATION INSTRUCTIONS ----------------
  void _showConfigurationInstructions() {
    debugPrint("""
  ═══════════════════════════════════════════════════════════
  📱 BLE DEVICE CONFIGURATION MODE REQUIRED
  ═══════════════════════════════════════════════════════════
  Please ensure your device is in configuration mode.
  """);
  }

  /// ---------------- DISCONNECT ----------------
  Future<void> disconnect(BleBluetoothDeviceModel d) async {
    debugPrint("🔌 Manually disconnecting from BLE device");
    _manualDisconnect = true;

    _stopKeepAlive(); // Stop keep-alive
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _isConnecting = false;
    _isReconnecting = false;
    _currentDeviceId = null;
    _lastActivity = null;
    _buffer = '';
    _isAlreadyConnected = false;

    try {
      await d.device.disconnect();
    } catch (e) {
      debugPrint("⚠️ Error during BLE disconnect: $e");
    }

    d.connectionState = BlueConnectionState.disconnected;
    _resetConnection();
    try {
      providerState?.updateBleConnectedDeviceStatus(null);
    } catch (e) {
      debugPrint("⚠️ Error updating BLE status: $e");
    }

    Future.delayed(const Duration(seconds: 2), () {
      _manualDisconnect = false;
    });
  }

  /// ---------------- RESET ----------------
  void _resetConnection() {
    _stopKeepAlive();
    _bufferStaleTimer?.cancel();      // 👈 add
    _bufferStaleTimer = null;         // 👈 add
    _writeReady = false;
    _writeChar = null;
    _notifyChar = null;
    _connectedDevice = null;
    _buffer = '';
    _notifySubscription?.cancel();
    _notifySubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _isAlreadyConnected = false;
  }

  /// ---------------- DISPOSE ----------------
  Future<void> dispose() async {
    _reconnectTimer?.cancel();
    await stopScan();
    await _adapterSubscription?.cancel();
    _resetConnection();
    onPairingRequired = null;
    onConnectionError = null;
  }

  /// ---------------- GETTERS ----------------
  List<BleBluetoothDeviceModel> get devices => _devices;

  bool get isConnected => _connectedDevice != null &&
      _writeChar != null &&
      _notifyChar != null &&
      _connectedDevice!.connectionState == BlueConnectionState.connected;

  bool get isWriteReady => _writeReady;
  BleBluetoothDeviceModel? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isReconnecting => _isReconnecting;
  String? get currentDeviceId => _currentDeviceId;
  DateTime? get lastActivity => _lastActivity;
  bool get isAlreadyConnected => _isAlreadyConnected;
}


/*
class BluetoothBleService {
  static BluetoothBleService? _instance;
  BluetoothBleService._internal();
  VoidCallback? onDeviceFound;

  // Callback for pairing instructions
  Function(String message)? onPairingRequired;
  Function(String message)? onConnectionError;

  factory BluetoothBleService() {
    _instance ??= BluetoothBleService._internal();
    return _instance!;
  }

  /// ---------------- VARIABLES ----------------
  static const String serviceUuidForWlc = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
  static const String serviceUuid = "12345678-1234-5678-1234-56789abcdef0";
  static const String writeUuid = "12345678-1234-5678-1234-56789abcdef1";
  static const String writeUuidForWlc = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  static const String notifyUuid1 = "12345678-1234-5678-1234-56789abcdef2";
  static const String notifyUuid2 = "12345678-1234-5678-1234-56789abcdef4";
  static const String notifyUuid3 = "12345678-1234-5678-1234-56789abcdef6";
  static const String notifyUuidForWlc = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

  static const List<String> notifyUuids = [
    notifyUuidForWlc,
    notifyUuid1,
    notifyUuid2,
    notifyUuid3,
  ];

  static const List<String> writeUuids = [
    writeUuidForWlc,
    writeUuid,
    "12345678-1234-5678-1234-56789abcdef3",
    "12345678-1234-5678-1234-56789abcdef5",
  ];

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notifySubscription;

  final List<BleBluetoothDeviceModel> _devices = [];
  MqttPayloadProvider? providerState;

  bool _isScanning = false;
  bool _writeReady = false;
  bool _isConnecting = false;
  bool _isReconnecting = false;
  bool _isAlreadyConnected = false;
  bool _manualDisconnect = false;

  BleBluetoothDeviceModel? _connectedDevice;
  BluetoothCharacteristic? _writeChar;
  BluetoothCharacteristic? _notifyChar;

  Timer? _reconnectTimer;
  Timer? _keepAliveTimer;
  int _reconnectAttempts = 0;
  static const int MAX_RECONNECT_ATTEMPTS = 3;
  static const int KEEP_ALIVE_INTERVAL = 15;


  DateTime? _lastActivity;
  String? _currentDeviceId;

  // Buffer for parsing incoming data
  String _buffer = '';

  /// ---------------- INIT ----------------
  Future<void> initializeBleService({MqttPayloadProvider? state}) async {
    providerState = state;

    _adapterSubscription = FlutterBluePlus.adapterState.listen((adapterState) {
      debugPrint("🔵 BLE Bluetooth State: $adapterState");
      if (adapterState != BluetoothAdapterState.on) {
        debugPrint("⚠️ BLE Bluetooth is not on! State: $adapterState");
        if (_connectedDevice != null) {
          _resetConnection();
          providerState?.updateBleConnectedDeviceStatus(null);
        }
      }
    });

    debugPrint("✅ BLE Service Initialized with provider");
  }

  /// ---------------- PERMISSIONS ----------------
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      debugPrint("📱 Android SDK Version: $sdkInt");

      final List<Permission> permissions = [];

      if (sdkInt >= 31) { // Android 12+
        permissions.addAll([
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
        ]);
      } else if (sdkInt >= 23) { // Android 6-11
        permissions.addAll([
          Permission.bluetooth,
          Permission.location,
        ]);
      } else { // Older Android versions
        permissions.add(Permission.bluetooth);
      }

      debugPrint("🔐 Requesting BLE permissions: ${permissions.map((p) => p.toString()).toList()}");

      final Map<Permission, PermissionStatus> statuses = await permissions.request();

      bool allGranted = true;
      for (var permission in permissions) {
        final status = statuses[permission];
        debugPrint("BLE Permission $permission: $status");

        if (status == null || !status.isGranted) {
          allGranted = false;

          if (status == PermissionStatus.permanentlyDenied) {
            debugPrint("⚠️ BLE Permission $permission is permanently denied");
            await openAppSettings();
            return false;
          }
        } else {
          debugPrint("✅ BLE Permission granted: $permission");
        }
      }

      if (!allGranted) {
        debugPrint("❌ Not all BLE permissions granted");
        return false;
      }

      debugPrint("✅ All BLE permissions granted successfully");
      return true;

    } catch (e) {
      debugPrint("❌ Error requesting BLE permissions: $e");
      return false;
    }
  }

  // Add this method to your BluetoothBleService class
  Future<void> prepareDeviceForConnection(BleBluetoothDeviceModel d) async {
    debugPrint("🔧 Preparing device for connection: ${d.deviceId}");

    if (Platform.isAndroid) {
      try {
        // Clear GATT cache
        await BluetoothHelper.clearGattCache(d.deviceId);
        debugPrint("✅ GATT cache cleared");
        await Future.delayed(const Duration(milliseconds: 500));

        // Refresh device cache
        await BluetoothHelper.refreshDeviceCache(d.deviceId);
        debugPrint("✅ Device cache refreshed");
        await Future.delayed(const Duration(milliseconds: 500));

      } catch (e) {
        debugPrint("⚠️ Error preparing device: $e");
      }
    }
  }

  /// ---------------- CHECK BLUETOOTH ----------------
  Future<bool> checkBluetooth() async {
    if (!await FlutterBluePlus.isSupported) {
      debugPrint("❌ BLE not supported on this device");
      return false;
    }

    final state = await FlutterBluePlus.adapterState.first;
    debugPrint("📱 BLE Adapter State: $state");

    if (state != BluetoothAdapterState.on) {
      debugPrint("❌ BLE Bluetooth is not ON. Please enable Bluetooth");
      return false;
    }

    return true;
  }

  /// ---------------- START SCAN ----------------
  Future<void> startScan({String? deviceId}) async {
    debugPrint("🔍 Starting BLE scan process...");
    debugPrint("deviceNameFilter:$deviceId");

    if (_isScanning) {
      debugPrint("⚠️ BLE Scan already in progress");
      return;
    }

    debugPrint("📱 Requesting BLE permissions...");
    if (!await requestPermissions()) {
      debugPrint("❌ BLE Permissions not granted");
      return;
    }

    debugPrint("📱 Checking BLE Bluetooth...");
    if (!await checkBluetooth()) {
      debugPrint("❌ BLE Bluetooth not available");
      return;
    }

    debugPrint("🧹 Clearing previous BLE devices...");
    _devices.clear();
    try {
      providerState?.updateBlePairedDevices([]);
    } catch (e) {
      debugPrint("⚠️ Error updating BLE provider: $e");
    }

    debugPrint("🛑 Stopping any existing BLE scan...");
    await stopScan();

    _isScanning = true;
    debugPrint("🔍 BLE Scan Started - Looking for devices with service: $serviceUuid");

    try {
      await FlutterBluePlus.startScan(
        withServices: [Guid(serviceUuid), Guid(serviceUuidForWlc)],
        timeout: const Duration(seconds: 20),
      );
      debugPrint("✅ BLE Scan started successfully");

      _scanSubscription = FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
        debugPrint("📡 Received ${results.length} BLE scan results");

        for (final r in results) {
          final device = r.device;
          final name = device.platformName;

          debugPrint("============ BLE DEVICE FOUND ============");
          debugPrint("Name: $name");
          debugPrint("ID: ${device.remoteId}");
          debugPrint("RSSI: ${r.rssi}");
          debugPrint("======================================");

          bool shouldAddDevice = false;

          if (deviceId != null && deviceId.isNotEmpty) {
            if (name.startsWith("NIA_")) {
              final deviceIdFromName = name.substring(4);
              if (deviceIdFromName == deviceId) {
                shouldAddDevice = true;
                debugPrint("✅ BLE Device matches filter: $deviceIdFromName == $deviceId");
              } else {
                debugPrint("❌ BLE Device filtered out: $deviceIdFromName != $deviceId");
              }
            } else {
              if (name == deviceId) {
                shouldAddDevice = true;
                debugPrint("✅ BLE Device matches direct filter: $name == $deviceId");
              } else {
                debugPrint("❌ BLE Device filtered out: $name != $deviceId");
              }
            }
          } else {
            shouldAddDevice = name.isNotEmpty;
            debugPrint("ℹ️ No filter applied, adding BLE device if name exists");
          }

          final exists = _devices.any((d) => d.deviceId == device.remoteId.str);

          if (!exists && shouldAddDevice) {
            debugPrint("➕ Adding new BLE device: $name");
            final newDevice = BleBluetoothDeviceModel(
              device: device,
              connectionState: BlueConnectionState.disconnected,
              rssi: r.rssi,
              name: name,
            );
            _devices.add(newDevice);
            final updatedDevices = List<BleBluetoothDeviceModel>.from(_devices);
            try {
              providerState?.updateBlePairedDevices(updatedDevices);
            } catch (e) {
              debugPrint("⚠️ Error updating BLE provider: $e");
            }
            onDeviceFound?.call();
            debugPrint("✅ BLE Device added successfully. Total devices: ${_devices.length}");
          }
        }
      });

      // await Future.delayed(const Duration(seconds: 10));
      // stopScan();

    } catch (e) {
      debugPrint("❌ Error starting BLE scan: $e");
      _isScanning = false;
      rethrow;
    }
  }

  /// ---------------- STOP SCAN ----------------
  Future<void> stopScan() async {
    if (!_isScanning) {
      debugPrint("ℹ️ No active BLE scan to stop");
      return;
    }

    _isScanning = false;
    debugPrint("🛑 Stopping BLE Scan...");

    try {
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      await FlutterBluePlus.stopScan();
      debugPrint("✅ BLE Scan stopped successfully");
    } catch (e) {
      debugPrint("❌ Error stopping BLE scan: $e");
    }
  }

  /// ---------------- CONNECT TO DEVICE ----------------
  Future<bool> connectToDevice(BleBluetoothDeviceModel d) async {
    if (_isConnecting || _isReconnecting) {
      debugPrint("⚠️ BLE Connection already in progress");
      return false;
    }

    debugPrint("🔌 Attempting to connect to BLE device: ${d.deviceName} (ID: ${d.deviceId})");
    _currentDeviceId = d.deviceId;

    _isConnecting = true;
    _reconnectAttempts = 0;

    try {
      // Step 1: Request permissions
      if (!await requestPermissions()) {
        debugPrint("❌ BLE Permissions not granted");
        _isConnecting = false;
        return false;
      }

      // Step 2: Stop scanning BEFORE connecting
      await stopScan();
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Clear any existing connection state
      await _clearConnectionState();

      // Step 4: Try to force disconnect the device
      try {
        debugPrint("🔧 Attempting to force disconnect the device...");
        await d.device.disconnect();
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint("Force disconnect error (expected): $e");
      }

      // Step 5: Update UI state to CONNECTING
      d.connectionState = BlueConnectionState.connecting;
      try {
        providerState?.updateBleDeviceStatus(
            d.deviceId, BlueConnectionState.connecting.index);
        providerState?.updateBleConnectedDeviceStatus(null);
      } catch (e) {
        debugPrint("⚠️ Error updating BLE status: $e");
      }

      // Step 6: Connect WITHOUT autoConnect to prevent automatic bonding
      debugPrint("🔗 Connecting to BLE ${d.deviceId} with autoConnect=false...");

      await d.device.connect(
        timeout: const Duration(seconds: 30),
        autoConnect: false, // Critical: false prevents auto bonding
        license: License.free,
      );

      // Verify connection
      await Future.delayed(const Duration(milliseconds: 500));
      if (!await d.device.isConnected) {
        throw Exception("Device not connected after connect call");
      }

      debugPrint("✅ BLE Connected successfully");
      _lastActivity = DateTime.now();
      _isAlreadyConnected = true;

      // Step 7: Set up connection monitoring
      await _setupConnectionMonitoring(d);

      // Step 8: Wait for connection to stabilize (critical delay)
      await Future.delayed(const Duration(seconds: 1));

      // Step 9: Discover services (do this BEFORE any bonding attempt)
      _connectedDevice = d;
      _writeReady = false;

      debugPrint("🔍 Discovering BLE services...");
      bool servicesFound = await _discoverServicesWithRetry(d, maxRetries: 3);

      if (!servicesFound) {
        debugPrint("⚠️ BLE Custom service not found after retries");
        _showConfigurationInstructions();
        d.connectionState = BlueConnectionState.disconnected;
        providerState?.updateBleDeviceStatus(
            d.deviceId, BlueConnectionState.disconnected.index);
        providerState?.updateBleConnectedDeviceStatus(null);
        _isConnecting = false;
        _isAlreadyConnected = false;
        return false;
      }

      // Step 10: Skip MTU request entirely for this device
      // Many BLE devices don't need MTU change and it can cause issues
      debugPrint("⚠️ Skipping MTU request to avoid bonding issues");


      // Step 11: Update final status to CONNECTED
      d.connectionState = BlueConnectionState.connected;
      try {
        providerState?.updateBleDeviceStatus(d.deviceId,
            BlueConnectionState.connected.index);
        providerState?.updateBleConnectedDeviceStatus(d);
      } catch (e) {
        debugPrint("⚠️ Error updating BLE final status: $e");
      }

      // Step 12: Start keep-alive to prevent disconnection
      _startKeepAlive();

      debugPrint("✅ BLE Connection complete - Write: ${_writeChar != null}, Notify: ${_notifyChar != null}");
      _isConnecting = false;
      return true;

    } catch (e) {
      debugPrint("❌ BLE Connection Failed: $e");

      String errorMessage = e.toString();

      if (errorMessage.contains('AUTHENTICATION_FAILURE') ||
          errorMessage.contains('status=5')) {

        const message = "⚠️ Bluetooth Connection Issue\n\n"
            "The device connects but fails during automatic pairing.\n\n"
            "This device may not require pairing/bonding.\n\n"
            "Please try these steps:\n\n"
            "1️⃣ FORGET THE DEVICE:\n"
            "   • Go to Settings → Connected devices → Bluetooth\n"
            "   • Find 'NIA_2CCF674C0F8A' and tap 'Forget'\n\n"
            "2️⃣ RESTART BLUETOOTH:\n"
            "   • Turn Bluetooth OFF\n"
            "   • Wait 5 seconds\n"
            "   • Turn Bluetooth ON\n\n"
            "3️⃣ POWER CYCLE THE DEVICE:\n"
            "   • Unplug the device\n"
            "   • Wait 30 seconds\n"
            "   • Plug it back in\n\n"
            "4️⃣ Try connecting again\n\n"
            "If the issue persists, the device may need a factory reset.";

        debugPrint(message);

        if (onPairingRequired != null) {
          onPairingRequired!(message);
        }
      } else if (onConnectionError != null) {
        onConnectionError!(errorMessage);
      }

      d.connectionState = BlueConnectionState.disconnected;
      try {
        providerState?.updateBleDeviceStatus(
            d.deviceId,
            BlueConnectionState.disconnected.index);
        providerState?.updateBleConnectedDeviceStatus(null);
      } catch (e) {
        debugPrint("⚠️ Error updating BLE status: $e");
      }

      _resetConnection();
      _isConnecting = false;
      _isAlreadyConnected = false;
      return false;
    }
  }

  /// ---------------- SETUP CONNECTION MONITORING ----------------
  Future<void> _setupConnectionMonitoring(BleBluetoothDeviceModel d) async {
    _connectionSubscription = d.device.connectionState.listen((state) {
      debugPrint("📱 BLE Connection State: $state at ${DateTime.now()}");

      if (state == BluetoothConnectionState.disconnected) {
        debugPrint("🔌 BLE Device disconnected");
        _lastActivity = null;
        _isAlreadyConnected = false;

        // Update to disconnected state
        d.connectionState = BlueConnectionState.disconnected;
        _resetConnection();

        try {
          providerState?.updateBleDeviceStatus(
              d.deviceId,
              BlueConnectionState.disconnected.index);
          providerState?.updateBleConnectedDeviceStatus(null);
        } catch (e) {
          debugPrint("⚠️ Error updating BLE status: $e");
        }

        // Only attempt reconnect if we weren't manually disconnected
        if (_currentDeviceId != null && !_isConnecting && !_isReconnecting && !_manualDisconnect) {
          _attemptReconnect(d);
        }

      } else if (state == BluetoothConnectionState.connected) {
        debugPrint("✅ BLE Device connected and stable");
        d.connectionState = BlueConnectionState.connected;
        _isAlreadyConnected = true;
      } else if (state == BluetoothConnectionState.connecting) {
        d.connectionState = BlueConnectionState.connecting;
      }
    });
  }

  /// ---------------- START ALIVE ----------------
  void _startKeepAlive() {
    _stopKeepAlive(); // Stop any existing timer

    debugPrint("💓 Starting BLE keep-alive (every $KEEP_ALIVE_INTERVAL seconds)");

    _keepAliveTimer = Timer.periodic(
      const Duration(seconds: KEEP_ALIVE_INTERVAL),
          (timer) async {
        if (_connectedDevice != null &&
            _connectedDevice!.connectionState == BlueConnectionState.connected &&
            _writeChar != null) {

          debugPrint("💓 Sending keep-alive ping...");

          // Send a simple keep-alive command
          // Adjust this based on your device's protocol
          final success = await _sendKeepAlive();

          if (!success) {
            debugPrint("⚠️ Keep-alive failed, device might be disconnected");
          }
        } else {
          debugPrint("⚠️ Not connected, stopping keep-alive");
          _stopKeepAlive();
        }
      },
    );
  }

  /// ---------------- STOP ALIVE ----------------
  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  /// ---------------- SENT ----------------
  Future<bool> _sendKeepAlive() async {
    if (_writeChar == null) return false;

    try {
      // Send a simple keep-alive command
      // Option 1: Send empty or ping command
      // final keepAlivePayload = "PING"; // Adjust based on your device

      // Option 2: Send a status request (adjust based on your protocol)
      const keepAlivePayload = "*STATUS#\r\n";
      final bytes = utf8.encode(keepAlivePayload);

      await _writeChar!.write(bytes, withoutResponse: true);
      _lastActivity = DateTime.now();
      return true;
    } catch (e) {
      debugPrint("❌ Keep-alive failed: $e");
      return false;
    }
  }

  /// ---------------- WRITE METHOD ----------------
  Future<bool> write(String payload, {bool silent = false, int maxRetries = 3}) async {
    if (_writeChar == null) {
      if (!silent) debugPrint("❌ BLE write characteristic not available");
      return false;
    }

    if (!_writeReady) {
      if (!silent) debugPrint("⚠️ BLE write not ready, waiting...");
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (_connectedDevice == null ||
        _connectedDevice!.connectionState != BlueConnectionState.connected) {
      if (!silent) debugPrint("❌ BLE device not connected");
      return false;
    }

    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final finalPayload = payload;
        final dataWithTerminator = '$finalPayload\r\n';
        final bytes = utf8.encode(dataWithTerminator);

        if (!silent) debugPrint("📤 [BLE] Sending: $finalPayload (Attempt ${attempts + 1})");

        await _writeChar!.write(bytes, withoutResponse: false);
        if (!silent) debugPrint("✅ [BLE] Sent successfully");

        _lastActivity = DateTime.now();
        await Future.delayed(const Duration(milliseconds: 100));
        return true;

      } catch (e) {
        attempts++;
        if (!silent) debugPrint("❌ [BLE] Write Error (Attempt $attempts): $e");

        if (attempts < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
          await _refreshCharacteristics();
        }
      }
    }

    if (!silent) debugPrint("❌ [BLE] Failed to write after $maxRetries attempts");
    return false;
  }

  /// ---------------- AUTO RECONNECT ----------------
  void _attemptReconnect(BleBluetoothDeviceModel d) {
    if (_reconnectTimer != null || _isReconnecting) return;

    if (_reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
      _reconnectAttempts++;
      _isReconnecting = true;
      debugPrint("🔄 BLE Auto-reconnect attempt $_reconnectAttempts/$MAX_RECONNECT_ATTEMPTS in 5 seconds...");

      _reconnectTimer = Timer(const Duration(seconds: 5), () async {
        _reconnectTimer = null;

        if (_connectedDevice == null && !_isConnecting) {
          await Future.delayed(const Duration(seconds: 2));

          final success = await connectToDevice(d);
          _isReconnecting = false;

          if (!success && _reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
            debugPrint("⚠️ BLE Reconnect failed, will retry on next disconnect");
          } else if (!success) {
            debugPrint("❌ BLE All reconnect attempts failed");
            _reconnectAttempts = 0;
            _currentDeviceId = null;
            _isAlreadyConnected = false;
          }
        } else {
          _isReconnecting = false;
        }
      });
    } else {
      debugPrint("❌ BLE Max reconnect attempts reached. Manual reconnect required.");
      _reconnectAttempts = 0;
      _currentDeviceId = null;
      _isReconnecting = false;
      _isAlreadyConnected = false;
    }
  }

  /// ---------------- CLEAR CONNECTION STATE ----------------
  Future<void> _clearConnectionState() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _notifySubscription?.cancel();
    _notifySubscription = null;

    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    _writeChar = null;
    _notifyChar = null;
    _writeReady = false;

    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.device.disconnect();
        await Future.delayed(const Duration(milliseconds: 1000));
      } catch (e) {
        debugPrint("⚠️ Error disconnecting BLE: $e");
      }
      _connectedDevice = null;
    }

    _isAlreadyConnected = false;
  }

  /// ---------------- DISCOVER SERVICES WITH RETRY ----------------
  Future<bool> _discoverServicesWithRetry(BleBluetoothDeviceModel d, {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      debugPrint("🔍 BLE Service discovery attempt $attempt/$maxRetries");

      try {
        // Check if still connected
        final isConnected = await d.device.isConnected;
        if (!isConnected) {
          debugPrint("❌ Device not connected during service discovery");
          // Don't try to reconnect, just return false
          return false;
        }

        // Discover services
        final services = await d.device.discoverServices();
        debugPrint("📋 Found ${services.length} BLE services");

        for (var service in services) {
          debugPrint("BLE Service: ${service.uuid}");
        }

        bool foundCustomService = services.any(
                (s) => [serviceUuid.toLowerCase(), serviceUuidForWlc.toLowerCase()].contains(s.uuid.toString().toLowerCase())
        );

        if (foundCustomService) {
          debugPrint("✅ Found BLE custom service on attempt $attempt");
          await _processServices(services);
          return true;
        }

        if (attempt < maxRetries) {
          debugPrint("⚠️ BLE Custom service not found, retrying in 500ms...");
          await Future.delayed(const Duration(milliseconds: 500));
        }

      } catch (e) {
        debugPrint("❌ BLE Service discovery attempt $attempt failed: $e");
        if (attempt < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          // Last attempt failed, return false
          return false;
        }
      }
    }

    debugPrint("❌ BLE Custom service not found after $maxRetries attempts");
    return false;
  }

  /// ---------------- PROCESS SERVICES ----------------
  Future<void> _processServices(List<BluetoothService> services) async {
    print("_processServices : $_processServices");
    for (var service in services) {
      if ([serviceUuid.toLowerCase(), serviceUuidForWlc.toLowerCase()].contains(service.uuid.toString().toLowerCase())) {
        debugPrint("✅ BLE Target Service Found: ${service.uuid}");
        debugPrint("📊 Found ${service.characteristics.length} BLE characteristics");
        for (var char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();
          debugPrint("  BLE Characteristic: $uuid");
          debugPrint("    Properties: ${char.properties}");

          if (writeUuids.contains(uuid) && (char.properties.write || char.properties.writeWithoutResponse)) {
            if (_writeChar == null) {
              _writeChar = char;
              _writeReady = true;
              debugPrint("✅ BLE Write characteristic ready: $uuid");
            }
          }

          if (notifyUuids.contains(uuid) && char.properties.notify) {
            if (_notifyChar == null) {
              _notifyChar = char;
              debugPrint("✅ BLE Notify characteristic found: $uuid");

              try {
                await _notifyChar!.setNotifyValue(true);
                debugPrint("✅ BLE Notify enabled successfully");

                _notifySubscription = _notifyChar!.onValueReceived.listen((value) {
                  print("value => $value | ${value.length}");
                  final response = String.fromCharCodes(value);
                  debugPrint("📩 BLE Device Response: $response");
                  _handleDeviceResponse(response);
                });
              } catch (e) {
                debugPrint("⚠️ Could not enable BLE notifications: $e");
              }
            }
          }
        }
      }
      if (service.uuid.toString().toLowerCase() == serviceUuidForWlc.toLowerCase()) {
        debugPrint("✅ BLE Target Service Found For WLC: ${service.uuid}");
        debugPrint("📊 Found ${service.characteristics.length} BLE characteristics");

        for (var char in service.characteristics) {
          final uuid = char.uuid.toString().toLowerCase();
          debugPrint("  BLE Characteristic: $uuid");
          debugPrint("    Properties: ${char.properties}");

          if (writeUuids.contains(uuid) && (char.properties.write || char.properties.writeWithoutResponse)) {
            if (_writeChar == null) {
              _writeChar = char;
              _writeReady = true;
              debugPrint("✅ BLE Write characteristic ready: $uuid");
            }
          }

          if (notifyUuids.contains(uuid) && char.properties.notify) {
            if (_notifyChar == null) {
              _notifyChar = char;
              debugPrint("✅ BLE Notify characteristic found: $uuid");

              try {
                await _notifyChar!.setNotifyValue(true);
                debugPrint("✅ BLE Notify enabled successfully");

                _notifySubscription = _notifyChar!.onValueReceived.listen((value) {
                  final response = String.fromCharCodes(value);
                  debugPrint("📩 BLE Device Response: $response");
                  _handleDeviceResponse(response);
                });
              } catch (e) {
                debugPrint("⚠️ Could not enable BLE notifications: $e");
              }
            }
          }
        }
      }
    }
  }

  /// ---------------- REFRESH CHARACTERISTICS ----------------
  Future<void> _refreshCharacteristics() async {
    if (_connectedDevice != null) {
      try {
        final services = await _connectedDevice!.device.discoverServices();
        await _processServices(services);
      } catch (e) {
        debugPrint("⚠️ Error refreshing BLE characteristics: $e");
      }
    }
  }

  /// ---------------- HANDLE DEVICE RESPONSE ----------------
  void _handleDeviceResponse(String response) {
    debugPrint("📱 Processing BLE device response: $response");
    _lastActivity = DateTime.now();

    // If we're receiving data, we must be connected
    if (!_isAlreadyConnected && _connectedDevice != null) {
      debugPrint("✅ Received data - marking as connected");
      _isAlreadyConnected = true;
      _connectedDevice!.connectionState = BlueConnectionState.connected;
    }
    if(response[0] =='*' && _buffer.isNotEmpty){
      _buffer = '';
    }
    _buffer += response;
    _parseBuffer();
  }

  /// ---------------- PARSE BUFFER ----------------
  void _parseBuffer() {
    debugPrint('BLE _buffer----> $_buffer');

    if (_buffer.isEmpty) return;
    if(_buffer.isNotEmpty && _buffer[0] =='*' && _buffer[_buffer.length-1] == '#'){
      String sliced = _buffer.substring(1, _buffer.length - 1);
      debugPrint("sliced : $sliced");
      final result = Constants.validatePayloadWithCrc(sliced);
      debugPrint("wlc ble result => $result");
      if(result != null){
        _processData(result);
        _buffer = '';
      }else{
        debugPrint('Crc not match in ble ....');
      }
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

  /// ---------------- PROCESS DATA ----------------
  void _processData(String jsonString) {
    debugPrint("BLE _processData call $jsonString");
    try {
      final data = json.decode(jsonString);
      final jsonStr = json.encode(data);

      MqttService().onMqttPayloadReceived(jsonString);

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
      debugPrint("Error parsing BLE JSON: $e");
    }
  }

  /// ---------------- SHOW CONFIGURATION INSTRUCTIONS ----------------
  void _showConfigurationInstructions() {
    debugPrint("""
  ═══════════════════════════════════════════════════════════
  📱 BLE DEVICE CONFIGURATION MODE REQUIRED
  ═══════════════════════════════════════════════════════════
  Please ensure your device is in configuration mode.
  """);
  }

  /// ---------------- DISCONNECT ----------------
  Future<void> disconnect(BleBluetoothDeviceModel d) async {
    debugPrint("🔌 Manually disconnecting from BLE device");
    _manualDisconnect = true;

    _stopKeepAlive(); // Stop keep-alive
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _isConnecting = false;
    _isReconnecting = false;
    _currentDeviceId = null;
    _lastActivity = null;
    _buffer = '';
    _isAlreadyConnected = false;

    try {
      await d.device.disconnect();
    } catch (e) {
      debugPrint("⚠️ Error during BLE disconnect: $e");
    }

    d.connectionState = BlueConnectionState.disconnected;
    _resetConnection();
    try {
      providerState?.updateBleConnectedDeviceStatus(null);
    } catch (e) {
      debugPrint("⚠️ Error updating BLE status: $e");
    }

    Future.delayed(const Duration(seconds: 2), () {
      _manualDisconnect = false;
    });
  }

  /// ---------------- RESET ----------------
  void _resetConnection() {
    _stopKeepAlive(); // Stop keep-alive
    _writeReady = false;
    _writeChar = null;
    _notifyChar = null;
    _connectedDevice = null;
    _buffer = '';
    _notifySubscription?.cancel();
    _notifySubscription = null;
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _isAlreadyConnected = false;
  }

  /// ---------------- DISPOSE ----------------
  Future<void> dispose() async {
    _reconnectTimer?.cancel();
    await stopScan();
    await _adapterSubscription?.cancel();
    _resetConnection();
    onPairingRequired = null;
    onConnectionError = null;
  }

  /// ---------------- GETTERS ----------------
  List<BleBluetoothDeviceModel> get devices => _devices;

  bool get isConnected => _connectedDevice != null &&
      _writeChar != null &&
      _notifyChar != null &&
      _connectedDevice!.connectionState == BlueConnectionState.connected;

  bool get isWriteReady => _writeReady;
  BleBluetoothDeviceModel? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isReconnecting => _isReconnecting;
  String? get currentDeviceId => _currentDeviceId;
  DateTime? get lastActivity => _lastActivity;
  bool get isAlreadyConnected => _isAlreadyConnected;
}*/