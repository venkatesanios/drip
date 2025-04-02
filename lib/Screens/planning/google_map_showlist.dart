import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class GoogleMapShowlist extends StatefulWidget {
  const GoogleMapShowlist({super.key});

  @override
  State<GoogleMapShowlist> createState() => _GoogleMapShowlistState();
}

class _GoogleMapShowlistState extends State<GoogleMapShowlist> {
  GoogleMapController? _controller;
  Set<Marker> _markers = Set<Marker>();

  List<Map<String, dynamic>> mapObjects = [
    {
      "objectId": 1,
      "name": "Gem+",
      "lat": 11.0168,
      "long": 76.9518,
      "status": 1
    },
    {
      "objectId": 2,
      "name": "oro pump",
      "lat": 11.0268,
      "long": 76.9528,
      "status": 1
    },
    {
      "objectId": 3,
      "name": "filter",
      "lat": 11.0368,
      "long": 76.9538,
      "status": 0
    },
    {
      "objectId": 4,
      "name": "irrigation pump",
      "lat": 11.0468,
      "long": 76.9548,
      "status": 0
    },
    {
      "objectId": 5,
      "name": "Source pump",
      "lat": 11.0568,
      "long": 76.9558,
      "status": 0
    },
    {
      "objectId": 6,
      "name": "valve",
      "lat": '',
      "long": '',
      "status": 1
    }
  ];

  @override
  void initState() {
    super.initState();
    // Initialize markers for valid locations
    mapObjects.forEach((object) {
      if (object['lat'] != '' && object['long'] != '') {
        _markers.add(Marker(
          markerId: MarkerId(object['objectId'].toString()),
          position: LatLng(object['lat'], object['long']),
          infoWindow: InfoWindow(title: object['name']),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Maps Example')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(11.0168, 76.9518), // Default position
          zoom: 12.0,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
    );
  }
}
