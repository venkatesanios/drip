import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import 'googlemap_model.dart';

class MapScreenConnectedObjects extends StatefulWidget {
  const MapScreenConnectedObjects({Key? key}) : super(key: key);

  @override
  _MapScreenConnectedObjectsState createState() =>
      _MapScreenConnectedObjectsState();
}

class _MapScreenConnectedObjectsState extends State<MapScreenConnectedObjects> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  LatLng? _selectedPosition;
  ConnectedObject? _selectedConnectedObject;
  DeviceList? _selectedDevice;
  late MqttPayloadProvider mqttPayloadProvider;

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deviceList = mqttPayloadProvider.mapModelInstance.data?.deviceList ?? [];

      if (deviceList.isNotEmpty) {
        // Default to the first device
        _selectedDevice = deviceList[1];
        _selectedConnectedObject = _selectedDevice?.connectedObject?.first; // Default to first connected object

        setState(() {
          _selectedPosition = LatLng(
            _selectedConnectedObject?.lat ?? 0.0,
            _selectedConnectedObject?.long ?? 0.0,
          );
        });
      }

      _addAllConnectedObjectMarkers();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _addAllConnectedObjectMarkers() {
    final deviceList = mqttPayloadProvider.mapModelInstance.data?.deviceList ?? [];
    Set<Marker> markers = {};

    for (var device in deviceList) {
      for (var connectedObject in device.connectedObject ?? []) {
        if (connectedObject.lat != null && connectedObject.long != null) {
          final position = LatLng(connectedObject.lat!, connectedObject.long!);
          final isSelected = connectedObject.objectId == _selectedConnectedObject?.objectId;

          markers.add(
            Marker(
              markerId: MarkerId(connectedObject.objectId.toString()),
              position: position,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                isSelected
                    ? BitmapDescriptor.hueAzure
                    : connectedObject.status == 1
                    ? BitmapDescriptor.hueGreen
                    : BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: connectedObject.name ?? 'Connected Object',
                snippet: 'Lat: ${connectedObject.lat}, Long: ${connectedObject.long}',
                onTap: () {
                  setState(() {
                    _selectedConnectedObject = connectedObject;
                    _selectedPosition = position;
                  });
                  _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
                },
              ),
            ),
          );
        }
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  void _updateMarker(double lat, double long) {
    if (_selectedDevice == null || _selectedConnectedObject == null) return;

    final position = LatLng(lat, long);

    setState(() {
      _selectedConnectedObject?.lat = lat;
      _selectedConnectedObject?.long = long;
      _selectedPosition = position;
    });

    mqttPayloadProvider.notifyListeners();  // Notify provider changes
    _addAllConnectedObjectMarkers();  // Refresh markers
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
      appBar: AppBar(title: const Text('Select Connected Object Location')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<ConnectedObject>(
              value: _selectedConnectedObject,
              hint: const Text('Select Connected Object'),
              onChanged: (ConnectedObject? connectedObject) {
                if (connectedObject != null) {
                  setState(() {
                    _selectedConnectedObject = connectedObject;
                    _selectedPosition = LatLng(connectedObject.lat!, connectedObject.long!);
                  });
                  _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_selectedPosition!, 15));
                }
              },
              isExpanded: true,
              items: _selectedDevice?.connectedObject?.map((connectedObject) {
                return DropdownMenuItem<ConnectedObject>(
                  value: connectedObject,
                  child: Text('${connectedObject.name ?? "Connected Object"}'),
                );
              }).toList() ?? [],
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
