import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import 'googlemap_model.dart';

class MapScreendevice extends StatefulWidget {
  const MapScreendevice({Key? key}) : super(key: key);

  @override
  _MapScreendeviceState createState() => _MapScreendeviceState();
}

class _MapScreendeviceState extends State<MapScreendevice> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  LatLng? _selectedPosition;
  DeviceList? _selectedDevice;
  int _selectedDeviceindex = 0;

  late MqttPayloadProvider mqttPayloadProvider;

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final devices = mqttPayloadProvider.mapModelInstance.data?.deviceList ?? [];

      if (devices.isNotEmpty) {
        setState(() {
          _selectedDevice = devices[_selectedDeviceindex];

          if (_selectedDevice!.geography?.lat != null && _selectedDevice!.geography?.long != null) {
            _selectedPosition = LatLng(
              _selectedDevice!.geography!.lat!,
              _selectedDevice!.geography!.long!,
            );

            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(_selectedPosition!, 15),
            );
          }
        });
      }

      _addAllDeviceMarkers();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _addAllDeviceMarkers() {
    final devices = mqttPayloadProvider.mapModelInstance.data?.deviceList ?? [];
    Set<Marker> markers = {};

    for (var device in devices) {
      if (device.geography?.lat != null && device.geography?.long != null) {
        final position = LatLng(device.geography!.lat!, device.geography!.long!);
        final isSelected = device.deviceId == _selectedDevice?.deviceId;

        markers.add(
          Marker(
            markerId: MarkerId(device.deviceId ?? device.controllerId.toString()),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isSelected
                  ? BitmapDescriptor.hueAzure
                  : device.geography!.status == 1
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: device.deviceName ?? 'Device',
              snippet: 'Lat: ${device.geography!.lat}, Long: ${device.geography!.long}',
              onTap: () {
                setState(() {
                  _selectedDevice = device;
                  _selectedPosition = position;
                });
                _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
              },
            ),
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  void _updateMarker(double lat, double long) {
    final deviceList = mqttPayloadProvider.mapModelInstance.data?.deviceList;

    if (deviceList == null || _selectedDeviceindex < 0 || _selectedDeviceindex >= deviceList.length) return;

    final position = LatLng(lat, long);

    setState(() {
      deviceList[_selectedDeviceindex].geography ??= Geography();
      deviceList[_selectedDeviceindex].geography!.lat = lat;
      deviceList[_selectedDeviceindex].geography!.long = long;

      _selectedDevice = deviceList[_selectedDeviceindex]; // Keep local selected device updated
      _selectedPosition = position;
    });

    mqttPayloadProvider.notifyListeners();  // Notify provider changes

    _addAllDeviceMarkers();  // Refresh markers
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
  }

  void _searchLocation() {
    try {
      final input = _searchController.text.trim();
      final extracted = extractCoordinates(input);
      final coords = extracted.split(',');

      if (coords.length == 2) {
        final lat = double.parse(coords[0].trim());
        final long = double.parse(coords[1].trim());
        _updateMarker(lat, long);
      } else {
        throw Exception('Invalid coordinate format');
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter coordinates as "lat, long" (e.g., 11.1326952, 76.9767822)'),
        ),
      );
    }
  }

  String extractCoordinates(String input) {
    final regExp = RegExp(r"@(-?\d+\.\d+),(-?\d+\.\d+)");
    final match = regExp.firstMatch(input);

    if (match != null) {
      return '${match.group(1)},${match.group(2)}';
    }

    var coords = input.split(",");
    if (coords.length == 2) {
      return '${coords[0].trim()},${coords[1].trim()}';
    }

    return "Invalid coordinates format.";
  }

  @override
  Widget build(BuildContext context) {
    final deviceList = mqttPayloadProvider.mapModelInstance.data?.deviceList ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Set Device Locations')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<DeviceList>(
              value: _selectedDevice,
              hint: const Text('Select Device'),
              onChanged: (DeviceList? device) {
                 if (device != null ) {
                   final lat = device.geography!.lat ?? 11.5937;
                  final long = device.geography!.long ?? 78.9629;
                  final position = LatLng(lat, long);

                  final index = deviceList.indexWhere((d) => d.deviceId == device.deviceId);

                  setState(() {
                    _selectedDevice = device;
                    _selectedDeviceindex = index;
                    _selectedPosition = position;
                  });

                  _addAllDeviceMarkers();

                  _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 12));
                }
                else
                  {
                    print("device else ");
                  }

              },
              isExpanded: true,
              items: deviceList.map((device) {
                final lat = device.geography?.lat?.toStringAsFixed(5) ?? 'N/A';
                final long = device.geography?.long?.toStringAsFixed(5) ?? 'N/A';
                return DropdownMenuItem<DeviceList>(
                  value: device,
                  child: Text('${device.deviceName ?? "Device"} (Lat: $lat, Long: $long)'),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Area (e.g., 11.1326952, 76.9767822)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _searchLocation,
                  child: const Text('Search', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.hybrid,
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(target: LatLng(0, 0), zoom: 2),
              markers: _markers,
              onTap: (LatLng latLng) {
                _updateMarker(latLng.latitude, latLng.longitude);
              },
            ),
          ),
        ],
      ),
    );
  }
}
