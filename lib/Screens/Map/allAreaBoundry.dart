import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:oro_drip_irrigation/Screens/Map/MapAreaModel.dart';

class MapScreenAllArea extends StatefulWidget {
  const MapScreenAllArea({super.key});

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
    _loadValvesFromJsonString();
  }

  Future<void> _loadValvesFromJsonString() async {
    const jsonString = '''
    {
      "controllerId": 23,
      "deviceId": "2CCF6773D07D",
      "mapobject": [
          {
              "objectId": 13,
              "sNo": 13.001,
              "name": "V 1",
              "objectName": "Valve",
              "areas": [{"latitude":11.138618620608188,"longitude":76.97570962076003},{"latitude":11.138665990905126,"longitude":76.97593492631728},{"latitude":11.138496247305406,"longitude":76.97597918276603},{"latitude":11.138484404724977,"longitude":76.97579276923949}],
              "status": 1
          },
          {
              "objectId": 13,
              "sNo": 13.002,
              "name": "V 2",
              "objectName": "Valve",
              "areas": [
        {
            "latitude": 11.138431771028399,
            "longitude": 76.97575521831328
        },
        {
            "latitude": 11.138496247305406,
            "longitude": 76.97596711282546
        },
        {
            "latitude": 11.138376505636742,
            "longitude": 76.97601405148322
        },
        {
            "latitude": 11.13833853286429,
            "longitude": 76.97577774524689
        }
    ],
              "status": 1
          },
          {
              "objectId": 13,
              "sNo": 13.003,
              "name": "V 3",
              "objectName": "Valve",
              "areas": [
        {
            "latitude": 11.138234581252254,
            "longitude": 76.97579068061066
        },
        {
            "latitude": 11.13827274070908,
            "longitude": 76.97600793954086
        },
        {
            "latitude": 11.13820036932119,
            "longitude": 76.97607633587074
        },
        {
            "latitude": 11.138130629603094,
            "longitude": 76.97579604502869
        }
    ],
              "status": 0
          }
      ],
      "liveMessage": {
          "cC": "2CCF6773D07D",
          "cM": {
              "2401": "1,19.0,12.4,1,2025-04-17 12:58:49.428749;2,0.0,0.0,1,2025-04-17 12:58:00.174468;3,19.0,6.5,1,2025-04-17 12:58:51.398794;4,19.0,8.0,3,2025-04-17 12:54:58.021312;5,38.0,8.1,1,2025-04-17 12:58:50.611901;6,0.0,100.0,1,2025-04-17 12:58:51.045949",
              "2402": "5.001,3;5.002,2;5.003,0;7.001,0;7.002,0;10.001,0;10.002,0;10.003,0;10.004,0;11.001,0;11.002,0;13.001,0;13.002,0;13.003,0;13.004,1;13.005,1;13.006,1;13.007,0;13.008,0;13.009,0;13.01,0;13.011,0;13.012,0;13.013,0;13.014,0;13.015,0;13.016,0;5.004,0",
              "2403": "24.001,0.00,0;24.002,0.00,0;24.003,0.00,0;24.004,0.00,0;22.001,11.02,879877;23.001,0,0",
              "2404": "5.001,0,0,0,0,228_230_234,1:0.0_2:0.0,00:00:00;5.002,0,0,0,0,228_230_234,3:0.0,00:00:00;5.003,0,0,00:00:00,0,239.0_233.0_234.0,1:0.0_2:0.0,00:00:00;5.004,0,0,00:00:00,0,239.0_233.0_234.0,3:0.0,00:00:00",
              "2405": "2.001,0;2.002,0",
              "2406": "4.001,0,00:02:00,0.0;4.002,0,00:02:00,0.0",
              "2407": "",
              "2408": "1,1.2,2,3000.0,600.0,0,0,0,0,3,2,12:54:32,00:00:00,None,2.001,2,11.02,1,220",
              "2409": "1,1.3,2,3000,2.001,2025-04-17,23:59:59,3",
              "2410": "1,2.001,3,2025-04-17,12:54:32,2025-04-17,60,2,30,1,0,2;2,2.002,3,-,-,2025-04-17,75,4,30,0,1,2;3,2.001_2.002,4,2025-04-17,11:13:19,2025-04-22,91,1,16,0,-1,3",
              "2411": "",
              "2412": "",
              "WifiStrength": 100,
              "Version": "1.1.0:079",
              "PowerSupply": 1
          },
          "cD": "2025-04-17",
          "cT": "12:58:52",
          "mC": "2400"
      }
    }
    ''';

    try {
      final mapAreaModel = mapAreaModelFromJson(jsonString);
      setState(() {
        _valves = {
          for (var mapobject in mapAreaModel.mapobject ?? [])
            mapobject.name!: Valve.fromMapobject(mapobject, mapAreaModel.liveMessage)
        };
        _updatePolygons();
      });
    } catch (e) {
      print('Error parsing JSON: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load valve data')),
      );
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
        polygons: _polygons,
        markers: _markers,
      ),
    );
  }
}
