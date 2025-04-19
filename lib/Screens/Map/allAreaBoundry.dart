import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oro_drip_irrigation/Screens/Map/MapAreaModel.dart';

import '../../repository/repository.dart';
import '../../services/http_service.dart';
import 'areaboundry.dart';

class MapScreenAllArea extends StatefulWidget {
  const MapScreenAllArea({Key? key,
      required this.userId,
  required this.customerId,
  required this.controllerId,
  required this.imeiNo})
: super(key: key);
final int userId, customerId, controllerId;
final String imeiNo;

  @override
  State<MapScreenAllArea> createState() => _MapScreenAllAreaState();
}

class _MapScreenAllAreaState extends State<MapScreenAllArea> {
  late GoogleMapController _mapController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.1387361, 76.9764367),
    zoom: 15,
  );

  final Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {};
  Map<String, Valve> _valves = {};

  final List<Color> _areaColors = [
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.cyan,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }


  Future<void> fetchData() async {
    print('fetchData');
    try{
      final Repository repository = Repository(HttpService());
      var getUserDetails = await repository.getgeographyArea({
        "userId": widget.userId,
        "controllerId" : widget.controllerId
      });
      print('getUserDetails${getUserDetails.body.runtimeType}');
      // final jsonData = jsonDecode(getUserDetails.body);
      if (getUserDetails.statusCode == 200) {
        setState(() {
          var jsonData = getUserDetails.body;
          print('jsonData${jsonData.runtimeType}');

          final mapAreaModel = valveResponseModelFromJson(jsonData);
          setState(() {
            _valves = {
              for (var mapobject in mapAreaModel.data?.valveGeographyArea ?? [])
                mapobject.name!: Valve.fromMapobject(mapobject, mapAreaModel.data?.liveMessage)
            };
            _updatePolygons();
          });
         });
      } else {
        //_showSnackBar(response.body);
      }
    }
    catch (e, stackTrace) {
       print(' Error overAll getData => ${e.toString()}');
      print(' trace overAll getData  => ${stackTrace}');
    }
  }



  void _updatePolygons() {
    setState(() {
      _polygons.clear();
      _markers.clear();

      int colorIndex = 0;

      for (var valve in _valves.values) {
        if (valve.area.length >= 3) {
          final strokeColor = _areaColors[colorIndex % _areaColors.length];
          colorIndex++;

          _polygons.add(
            Polygon(
              polygonId: PolygonId(valve.name),
              points: valve.area,
              strokeColor: strokeColor,
              strokeWidth: 3,
              fillColor: valve.status == 1 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            ),
          );

          final center = _getPolygonCenter(valve.area);

          _markers.add(
            Marker(
              markerId: MarkerId(valve.name),
              position: center,
              infoWindow: InfoWindow(title: valve.name),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          );
        }
      }
    });
  }

  LatLng _getPolygonCenter(List<LatLng> points) {
    double lat = 0.0;
    double lng = 0.0;
    for (var point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  void _zoomToValves() {
    if (_valves.isEmpty) return;
    final allPoints = _valves.values.expand((v) => v.area).toList();
    if (allPoints.isEmpty) return;
    final bounds = _calculateBounds(allPoints);
    _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points[0].latitude, maxLat = points[0].latitude;
    double minLng = points[0].longitude, maxLng = points[0].longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Area with Valves'),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            onPressed: _zoomToValves,
          ),
          IconButton(
            icon: const Icon(Icons.edit_location_alt),
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MapScreenArea(userId: widget.userId, customerId: widget.customerId, controllerId: widget.controllerId, imeiNo: widget.imeiNo,),
              ));
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          if (_valves.isNotEmpty) {
            _zoomToValves();
          }
        },
        mapType: MapType.hybrid,
        polygons: _polygons,
        markers: _markers,
      ),
    );
  }
}
