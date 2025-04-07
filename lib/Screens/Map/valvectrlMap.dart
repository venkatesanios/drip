import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ValveControllerMap extends StatefulWidget {
  @override
  _ValveControllerMapState createState() => _ValveControllerMapState();
}

class _ValveControllerMapState extends State<ValveControllerMap> {
  GoogleMapController? _mapController;
  TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = Set(); // Set to hold all markers
  List<Map<String, dynamic>> valveDataList = [
    {
      'id': 1,
      'lat': 11.1326952,
      'long': 76.9767822,
      'status': 1,
    },
    {
      'id': 2,
      'lat': 12.9716,
      'long': 77.5946,
      'status': 0,
    },
    // You can add more entries here
  ];

  @override
  void initState() {
    super.initState();
    _updateValveMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // Function to update all valve markers
  void _updateValveMarkers() {
    setState(() {
      _markers.clear(); // Clear the existing markers

      // Loop through the valve data list and add each valve's marker
      for (var valve in valveDataList) {
        if (valve['lat'] != null && valve['long'] != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(valve['id'].toString()), // Unique ID for each marker
              position: LatLng(valve['lat'], valve['long']),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                valve['status'] == null
                    ? BitmapDescriptor.hueOrange
                    : valve['status'] == 1
                    ? BitmapDescriptor.hueGreen
                    : BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: 'Valve Controller ${valve['id']}',
                snippet: 'Status: ${valve['status'] ?? 'Unknown'}',
              ),
            ),
          );
        }
      }
    });
  }

  // Function to extract coordinates and handle map markers
  void _searchLocation() {
    try {
      final input = _searchController.text.trim();
      final inoutextract = extractCoordinates(input);
      final coords = inoutextract.split(',');

      if (coords.length == 2) {
        final lat = double.parse(coords[0].trim());
        final long = double.parse(coords[1].trim());

        // Add new valve data
        valveDataList.add({
          'id': valveDataList.length + 1, // Unique ID for the new valve
          'lat': lat,
          'long': long,
          'status': 0, // Default status
        });

        // Update the markers
        _updateValveMarkers();

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, long), 15),
        );
      } else {
        throw Exception('Invalid format');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter coordinates as "lat, long" (e.g., 11.1326952, 76.9767822)')),
      );
    }
  }

  // Extract coordinates either from a URL or a lat, long string
  String extractCoordinates(String input) {
    RegExp regExp = RegExp(r"@(-?\d+\.\d+),(-?\d+\.\d+)");

    // Check if the input is a Google Maps URL
    var match = regExp.firstMatch(input);
    if (match != null) {
      String latitude = match.group(1)!;
      String longitude = match.group(2)!;
      return '$latitude,$longitude'; // Return coordinates as a string
    }

    // If input is a direct latitude,longitude string
    var coords = input.split(",");
    if (coords.length == 2) {
      String latitude = coords[0].trim();
      String longitude = coords[1].trim();
      return '$latitude,$longitude'; // Return coordinates as a string
    }

    return "Invalid coordinates format.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Valve Controller Map'),
      ),
      body: Column(
        children: [
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
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocation,
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
              markers: _markers, // Display all markers
            ),
          ),
        ],
      ),
    );
  }
}
