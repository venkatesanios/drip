import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import 'googlemap_model.dart';

class MapScreenall extends StatefulWidget {
  const MapScreenall({
    Key? key,
    required this.userId,
    required this.customerId,
    required this.controllerId,
    required this.imeiNo,
  }) : super(key: key);

  final int userId, customerId, controllerId;
  final String imeiNo;

  @override
  State<MapScreenall> createState() => _MapScreenallState();
}

class _MapScreenallState extends State<MapScreenall> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(11.7749, 78.4194);
  List<DeviceList> deviceList = [];
  late MqttPayloadProvider mqttPayloadProvider;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: false);
    fetchData();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitMapToMarkers(markers);
  }

  Future<void> fetchData() async {
    try {
      final Repository repository = Repository(HttpService());
      var getUserDetails = await repository.getgeography({
        "userId": widget.userId,
        "controllerId": widget.controllerId,
      });

      if (getUserDetails.statusCode == 200) {
        var jsonData = jsonDecode(getUserDetails.body);
        mqttPayloadProvider.updateMapData(jsonData);

        setState(() {
          deviceList =
              mqttPayloadProvider.mapModelInstance.data?.deviceList ?? [];
          markers = createMarkersFromDeviceList(deviceList);

          // Use first available location to center map
          LatLng? firstValid = _getFirstLatLng(deviceList);
          if (firstValid != null) {
            _center = firstValid;
          }
        });
      }
    } catch (e, stackTrace) {
      mqttPayloadProvider.httpError = true;
      print('❌ Error fetching data: $e');
      print('🪵 Stack: $stackTrace');
    }
  }

  LatLng? _getFirstLatLng(List<DeviceList> devices) {
    for (var device in devices) {
      if (device.geography?.lat != null && device.geography?.long != null) {
        return LatLng(device.geography!.lat!, device.geography!.long!);
      }
      for (var obj in device.connectedObject ?? []) {
        if (obj.lat != null && obj.long != null) {
          return LatLng(obj.lat!, obj.long!);
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geography')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15.0,
        ),
        markers: markers,
      ),
    );
  }

  Set<Marker> createMarkersFromDeviceList(List<DeviceList> devices) {
    Set<Marker> markers = {};

    for (var device in devices) {
      if (device.geography?.lat != null && device.geography?.long != null) {
        print(
            "✅ Device ${device.deviceName} at ${device.geography!.lat}, ${device.geography!.long}");
        markers.add(
          Marker(
            markerId: MarkerId('device-${device.deviceId}'),
            position: LatLng(
                device.geography!.lat!, device.geography!.long!),
            icon: _getMarkerIcon(device.geography?.status),
            infoWindow: InfoWindow(
              title: device.deviceName,
              snippet: device.modelName ?? '',
            ),
          ),
        );
      }

      for (var obj in device.connectedObject ?? []) {
        if (obj.lat != null && obj.long != null) {
          print(
              "✅ Object ${obj.name ?? obj.objectName} at ${obj.lat}, ${obj.long}");
          markers.add(
            Marker(
              markerId: MarkerId('object-${obj.sNo}'),
              position: LatLng(obj.lat!, obj.long!),
              icon: _getMarkerIcon(obj.status),
              infoWindow: InfoWindow(
                title: obj.name ?? obj.objectName ?? 'Object',
                snippet: 'Location: ${obj.location}',
              ),
            ),
          );
        }
      }
    }

    print('📍 Total markers: ${markers.length}');
    return markers;
  }

  BitmapDescriptor _getMarkerIcon(int? status) {
    switch (status) {
      case 1:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 0:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  Future<void> _fitMapToMarkers(Set<Marker> markers) async {
    if (markers.isEmpty) return;

    List<LatLng> positions = markers.map((m) => m.position).toList();

    final southwestLat =
    positions.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final southwestLng =
    positions.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    final northeastLat =
    positions.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final northeastLng =
    positions.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    final bounds = LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );

    await mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }
}
