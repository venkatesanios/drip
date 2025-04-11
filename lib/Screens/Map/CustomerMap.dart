import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import 'googlemap_model.dart';


class MapScreenall extends StatefulWidget {
  const MapScreenall({super.key});

  @override
  State<MapScreenall> createState() => _MapScreenallState();
}

class _MapScreenallState extends State<MapScreenall> {
  late GoogleMapController mapController;

   LatLng _center = const LatLng(37.7749, -122.4194);
  List<DeviceList> deviceList = [];
  late MqttPayloadProvider mqttPayloadProvider;

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    deviceList = mqttPayloadProvider.mapModelInstance.data!.deviceList!;


    if (deviceList.isNotEmpty && deviceList[0].geography?.lat != null && deviceList[0].geography?.long != null) {
      _center = LatLng(deviceList[0].geography!.lat!, deviceList[0].geography!.long!);
    }
    else if(deviceList[0].connectedObject!.isNotEmpty)
      {
        _center = LatLng(deviceList[0].connectedObject![0].lat!, deviceList[0].connectedObject![0].long!);
      }
   }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map with Status Markers')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15.0,
        ),
        markers: createMarkersFromDeviceList(deviceList),
      ),
    );
  }

  Set<Marker> createMarkersFromDeviceList(List<DeviceList> devices) {
    Set<Marker> markers = {};

    for (var device in devices) {
      if (device.geography?.lat != null && device.geography?.long != null) {
        markers.add(
          Marker(
            markerId: MarkerId('device-${device.serialNumber}'),
            position: LatLng(device.geography!.lat!, device.geography!.long!),
            icon: _getMarkerIcon(device.geography?.status),
            infoWindow: InfoWindow(
              title: device.deviceName,
              snippet: device.siteName,
            ),
          ),
        );
      }

      for (var obj in device.connectedObject ?? []) {
        if (obj.lat != null && obj.long != null) {
          markers.add(
            Marker(
              markerId: MarkerId('obj-${obj.objectId}'),
              position: LatLng(obj.lat!, obj.long!),
              icon: _getMarkerIcon(obj.status),
              infoWindow: InfoWindow(
                title: obj.name ?? obj.objectName,
                snippet: obj.location,
              ),
            ),
          );
        }
      }
    }

    print('markers.length${markers.length}');
    return markers;
  }

  BitmapDescriptor _getMarkerIcon(int? status) {
    // switch (status) {
      // case 1:
      //   return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      // case 0:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      // default:
      //   return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    // }
  }
}
