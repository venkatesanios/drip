import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import 'googlemap_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  LatLng? _objectPosition;

  late MqttPayloadProvider mqttPayloadProvider;
  ConnectedObject? _selectedObject;

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateInitialMarker();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _updateInitialMarker() {
    final device = mqttPayloadProvider.mapModelInstance.data?.deviceList?[widget.index];
    final connectedObj = device?.connectedObject?.isNotEmpty == true
        ? device!.connectedObject!.first
        : null;

    if (connectedObj != null && connectedObj.lat != null && connectedObj.long != null) {
      final position = LatLng(connectedObj.lat!, connectedObj.long!);

      setState(() {
        _objectPosition = position;
        _selectedObject = connectedObj;
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId(connectedObj.name ?? 'connected_object'),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              connectedObj.status == null
                  ? BitmapDescriptor.hueOrange
                  : connectedObj.status == 1
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: connectedObj.name ?? 'Connected Object',
              snippet: 'Status: ${connectedObj.name ?? 'Unknown'}',
            ),
          ),
        );
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
    }
  }

  void _updateMarker(double lat, double long) {
    final position = LatLng(lat, long);

    setState(() {
      _objectPosition = position;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(_selectedObject?.name ?? 'connected_object'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: _selectedObject?.name ?? 'Connected Object',
            snippet: 'Status: ON',
          ),
        ),
      );
    });

    if (_selectedObject != null) {
      _selectedObject!.lat = lat;
      _selectedObject!.long = long;
      _selectedObject!.status = 1;
      mqttPayloadProvider.notifyListeners();
    }

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

  Future<void> _checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status == PermissionStatus.granted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Location')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<ConnectedObject>(
              value: _selectedObject,
              hint: const Text('Select Connected Object'),
              onChanged: (ConnectedObject? newObject) {
                setState(() {
                  _selectedObject = newObject;
                });
                if (newObject != null && newObject.lat != null && newObject.long != null) {
                  _updateMarker(newObject.lat!, newObject.long!);
                }
              },
              items: mqttPayloadProvider
                  .mapModelInstance.data?.deviceList?[widget.index].connectedObject
                  ?.map<DropdownMenuItem<ConnectedObject>>((ConnectedObject object) {
                return DropdownMenuItem<ConnectedObject>(
                  value: object,
                  child: Text(
                    '${object.name ?? object.objectName ?? 'Object'} (Lat: ${object.lat}, Long: ${object.long})',
                  ),
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
                  child: const Text(
                    'Search',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.hybrid,
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 2,
              ),
              markers: _markers,
              onTap: (LatLng latLng) {
                _updateMarker(latLng.latitude, latLng.longitude);
              },
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              compassEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
