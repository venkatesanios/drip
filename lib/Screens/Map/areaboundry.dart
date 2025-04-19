import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oro_drip_irrigation/Screens/Map/MapAreaModel.dart';

import '../../repository/repository.dart';
import '../../services/http_service.dart';


// MapScreenArea widget
class MapScreenArea extends StatefulWidget {
  const MapScreenArea({Key? key,
    required this.userId,
    required this.customerId,
    required this.controllerId,
    required this.imeiNo})
      : super(key: key);
  final int userId, customerId, controllerId;
  final String imeiNo;

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

  ValveResponseModel _valveResponseModel = ValveResponseModel();


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

          _valveResponseModel = valveResponseModelFromJson(jsonData);
          setState(() {
            _valves = {
              for (var mapobject in _valveResponseModel.data?.valveGeographyArea ?? [])
                mapobject.name!: Valve.fromMapobject(mapobject, _valveResponseModel.data?.liveMessage)
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

  List<Map<String, dynamic>> convertValvesToJson() {
    List<Valve> valveList = _valves.values.toList();
    List<Map<String, dynamic>> jsonList = valveList.map((v) => v.toJson()).toList();
    return jsonList;
  }
  Future<void> _sendSelectedValveToServer() async {
    try {

      List<Map<String, dynamic>> jsondata = convertValvesToJson();
      print('\n json: $jsondata');


      Map<String, dynamic> body = {
        "userId": widget.userId,
        "controllerId" : widget.controllerId,
        "valveGeographyArea" : jsondata,
        "modifyUser" : widget.userId
      };
      print('\n body:$body');

        final Repository repository = Repository(HttpService());
         final response = await repository.updategeographyArea(body);
        if (response.statusCode != 200) {
          print('Failed to send valve : ${response.body}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All valves sent successfully!')),
      );
    } catch (e) {
      print('Error sending valves: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send valves')),
      );
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
              mapType: MapType.hybrid,
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