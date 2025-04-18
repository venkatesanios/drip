import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oro_drip_irrigation/Screens/Map/MapAreaModel.dart';


// MapScreenArea widget
class MapScreenArea extends StatefulWidget {
  const MapScreenArea({super.key});

  @override
  State<MapScreenArea> createState() => _MapScreenAreaState();
}

class _MapScreenAreaState extends State<MapScreenArea> {
  late GoogleMapController _mapController;
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.1387361, 76.9764367),
    zoom: 15,
  );

  final Set<Polygon> _polygons = {};
  final Set<Marker> _markers = {};
  Map<String, Valve> _valves = {};
  Valve? selectedValve;

  @override
  void initState() {
    super.initState();
    _loadSavedAreas();
  }

  Future<void> _loadSavedAreas() async {
    await _loadValvesFromJsonString();

    final prefs = await SharedPreferences.getInstance();
    final savedAreas = prefs.getString('saved_areas') ?? '{}';
    try {
      final decoded = jsonDecode(savedAreas) as Map<String, dynamic>;
      if (decoded.isNotEmpty && _valves.isEmpty) {
        setState(() {
          _valves = decoded.map((key, value) {
            final valve = Valve.fromJson(value);
            return MapEntry(valve.name, valve);
          });
          _updatePolygons();
        });
      }
    } catch (e) {
      print('Error loading saved areas: $e');
    }
    if (_valves.isNotEmpty) {
      _zoomToValves();
    }
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
              "areas": [
                  {
                      "latitude": 11.138073534888953,
                      "longitude": 76.97587885707556
                  },
                  {
                      "latitude": 11.137536669979172,
                      "longitude": 76.97601833194433
                  },
                  {
                      "latitude": 11.13769457152603,
                      "longitude": 76.97645821422277
                  },
                  {
                      "latitude": 11.138220909396832,
                      "longitude": 76.97634019702612
                  }
              ],
              "status": 1
          },
          {
              "objectId": 13,
              "sNo": 13.002,
              "name": "V 2",
              "objectName": "Valve",
              "areas": [],
              "status": 1
          },
          {
              "objectId": 13,
              "sNo": 13.003,
              "name": "V 3",
              "objectName": "Valve",
              "areas": [],
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
      await _saveAreas();
    } catch (e) {
      print('Error parsing JSON: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load valve data')),
      );
    }
  }

  Future<void> _saveAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_valves.map((key, valve) {
      return MapEntry(key, valve.toJson());
    }));
    await prefs.setString('saved_areas', encoded);
  }

  void _selectValve(String? valveName) {
    setState(() {
      selectedValve = valveName != null ? _valves[valveName] : null;
      _updatePolygons();
    });
  }

  Future<void> _sendSelectedValveToServer() async {
    if (selectedValve != null) {
      final body = jsonEncode(selectedValve!.toJson());
      print('Sending valve data: $body');
      // Implement HTTP request here
    }
  }

  void _updatePolygons() {
    setState(() {
      _polygons.clear();
      _markers.clear();

      for (var valve in _valves.values) {
        if (valve.area.length >= 3) {
          _polygons.add(Polygon(
            polygonId: PolygonId(valve.name),
            points: valve.area,
            strokeColor: valve.status == 1 ? Colors.green : Colors.red,
            strokeWidth: 2,
            fillColor: valve.status == 1 ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          ));
        }

        if (selectedValve != null && selectedValve!.name == valve.name) {
          valve.area.asMap().forEach((index, point) {
            _markers.add(
              Marker(
                markerId: MarkerId('${valve.name}_point_$index'),
                position: point,
                infoWindow: InfoWindow(title: 'Valve ${valve.name}'),
                draggable: true,
                onDragEnd: (newPosition) => _onMarkerDragEnd(newPosition, index),
              ),
            );
          });
        }
      }
    });
  }

  void _onMapTapped(LatLng position) {
    if (selectedValve == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valve from the dropdown')),
      );
      return;
    }
    setState(() {
      selectedValve!.area.add(position);
      _updatePolygons();
    });
    _saveAreas();
  }

  void _onMarkerDragEnd(LatLng newPosition, int index) {
    if (selectedValve != null && index >= 0 && index < selectedValve!.area.length) {
      setState(() {
        selectedValve!.area[index] = newPosition;
        _updatePolygons();
      });
      _saveAreas();
    }
  }

  void _saveValveArea() {
    if (selectedValve != null) {
      setState(() {
        _valves[selectedValve!.name] = selectedValve!;
      });
      _saveAreas();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Valve "${selectedValve!.name}" saved')),
      );
    }
  }

  void _clearLastPoint() {
    if (selectedValve != null && selectedValve!.area.isNotEmpty) {
      setState(() {
        selectedValve!.area.removeLast();
        _updatePolygons();
      });
      _saveAreas();
    }
  }

  void _clearBoundary() {
    if (selectedValve != null) {
      setState(() {
        selectedValve!.area.clear();
        _updatePolygons();
      });
      _saveAreas();
    }
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
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
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
          IconButton(icon: const Icon(Icons.undo), onPressed: _clearLastPoint),
          IconButton(icon: const Icon(Icons.clear), onPressed: _clearBoundary),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveValveArea),
          IconButton(icon: const Icon(Icons.cloud_upload), onPressed: _sendSelectedValveToServer),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<String>(
              hint: const Text('Select Valve'),
              value: selectedValve?.name,
              isExpanded: true,
              items: _valves.keys.map((valveName) {
                return DropdownMenuItem<String>(
                  value: valveName,
                  child: Text(valveName),
                );
              }).toList(),
              onChanged: _selectValve,
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                if (_valves.isNotEmpty) {
                  _zoomToValves();
                }
              },
              markers: _markers,
              polygons: _polygons,
              onTap: _onMapTapped,
            ),
          ),

        ],
      ),
    );
  }
}