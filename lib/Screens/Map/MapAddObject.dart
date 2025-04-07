import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timezone/browser.dart'as tz;
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  LatLng? _valvePosition;

  // Sample valve data
  Map<String, dynamic> valveData = {
    'lat': null,
    'long': null,
    'status': null, // null, 0, or 1
  };

  @override
  void initState() {
    super.initState();
    _updateValveMarker();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _updateValveMarker() {
    setState(() {
      _markers.clear();
      if (valveData['lat'] != null && valveData['long'] != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('valve'),
            position: LatLng(valveData['lat'], valveData['long']),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              valveData['status'] == null
                  ? BitmapDescriptor.hueOrange
                  : valveData['status'] == 1
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'Valve Controller',
              snippet: 'Status: ${valveData['status'] ?? 'Unknown'}',
            ),
          ),
        );
      }
    });
  }
  // Future<void> _searchLocation() async {
  //   final query = _searchController.text.trim();
  //   print("query:$query");
  //   if (query.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Please enter a city name')),
  //     );
  //     return;
  //   }
  //
  //   try {
  //     print('try');
  //     // List<Location> locations = await locationFromAddress(query);
  //     List<Location> locations = await locationFromAddress("Gronausestraat 710, Enschede");
  //
  //     print("locations:$locations");
  //     if (locations.isNotEmpty) {
  //       final location = locations.first;
  //       _valvePosition = LatLng(location.latitude, location.longitude);
  //
  //       // Update the valveData safely
  //       valveData['lat'] = location.latitude;
  //       valveData['long'] = location.longitude;
  //
  //       // Default the status to 0 if null
  //       if (valveData['status'] == null) valveData['status'] = 0;
  //
  //       _updateValveMarker();
  //
  //       _mapController?.animateCamera(
  //         CameraUpdate.newLatLngZoom(_valvePosition!, 15),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('No location found for "$query"')),
  //       );
  //     }
  //   } catch (e) {
  //     String errorMessage;
  //     if (e.toString().contains('null')) {
  //       errorMessage = 'Geocoding failed: Check API key or network connection';
  //     } else {
  //       errorMessage = 'Error finding location: $e';
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(errorMessage)),
  //     );
  //     print('Error: $e');
  //   }
  // }

  void _searchLocation() {
    try {
      // Expecting input in format "lat, long" (e.g., "11.1326952, 76.9767822")
      final input = _searchController.text.trim();
     final inoutextract =  extractCoordinates(input);
      final coords = inoutextract.split(',');
      if (coords.length == 2) {
        final lat = double.parse(coords[0].trim());
        final long = double.parse(coords[1].trim());

        _valvePosition = LatLng(lat, long);
        valveData['lat'] = lat;
        valveData['long'] = long;
        if (valveData['status'] == null) valveData['status'] = 0; // Default status

        _updateValveMarker();

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(_valvePosition!, 15),
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
  String extractCoordinates(String input) {
    // Regular expression to extract coordinates from the Google Maps URL
    RegExp regExp = RegExp(r"@(-?\d+\.\d+),(-?\d+\.\d+)");

    // Check if the input is a Google Maps URL
    var match = regExp.firstMatch(input);
    if (match != null) {
      // Extract latitude and longitude from the URL
      String latitude = match.group(1)!;
      String longitude = match.group(2)!;
      return '$latitude,$longitude'; // Return coordinates as a string
    }

    // If the input is not a URL, check if it's a direct latitude,longitude string
    var coords = input.split(",");
    if (coords.length == 2) {
      String latitude = coords[0].trim();
      String longitude = coords[1].trim();
      return '$latitude,$longitude'; // Return coordinates as a string
    }

    // Return an error message if input is invalid
    return "Invalid coordinates format.";
  }
  int getValueOfSerial(Map<String, dynamic> liveMessage, String serialNumber)
  {
    try {
      Map<String, dynamic> cM = liveMessage['cM'] as Map<String, dynamic>;

      // Iterate through all fields (2401 to 2412)
      for (String key in cM.keys) {
        if (key.startsWith('24')) {
          String data = cM[key] as String;
          List<String> values = data.split(';');
          for (int i = 0; i < values.length; i++) {
            if (values[i].startsWith(serialNumber)) {
              List<String> parts = values[i].split(',');
              return int.parse(parts[1]);
            }
          }

        }
      }
      // Return -1 if serial number not found
      return -1;
    } catch (e) {
      print('Error parsing data: $e');
      return -1;
    }
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
            child: GoogleMap(mapType: MapType.hybrid,
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0),
                zoom: 2,
              ),
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }
}