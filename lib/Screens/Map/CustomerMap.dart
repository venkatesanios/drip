import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import 'MapDeviceList.dart';
import 'googlemap_model.dart';

class MapScreenall extends StatefulWidget {
  const MapScreenall({
    Key? key,
    required this.userId,
    required this.customerId,
    required this.controllerId,
    required this.imeiNo,
  }) : super(key: key);

  final int userId, customerId, controllerId;
  final String imeiNo;

  @override
  State<MapScreenall> createState() => _MapScreenallState();
}

class _MapScreenallState extends State<MapScreenall> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(11.7749, 78.4194);
  List<DeviceList> deviceList = [];
  late MqttPayloadProvider mqttPayloadProvider;
  Set<Marker> markers = {};

  // Custom marker icons
  late BitmapDescriptor markerGray;
  late BitmapDescriptor markerGreen;
  late BitmapDescriptor markerRed;
  late BitmapDescriptor markerAgitator;
  late BitmapDescriptor markerBlue;
  late BitmapDescriptor markerFert;
  late BitmapDescriptor markerFilter;
  late BitmapDescriptor markerInjector;
  late BitmapDescriptor markerSensor;
  late BitmapDescriptor markerPump;
  late BitmapDescriptor markerxMm1;
  late BitmapDescriptor markerXMp1;
  late BitmapDescriptor markerXMh1;
  late BitmapDescriptor markerXMr1;
  late BitmapDescriptor markerXMs1;
  late BitmapDescriptor markerXMw1;
  late BitmapDescriptor markerXMl1;
  late BitmapDescriptor markerXMe1;

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: false);
    _loadMarkerIcons().then((_) => fetchData());
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _loadMarkerIcons() async {
     markerGray = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markergray.png',);
    markerGreen = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)), 'assets/png/markergreen.png',);
    markerRed = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerred.png',);
    markerSensor = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markersensor.png',);
    markerAgitator = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)), 'assets/png/markeragitator.png',);
    markerBlue = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerblue.png',);
    markerInjector = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerinjector.png',);
    markerFert = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)), 'assets/png/markerfertilizer.png',);
    markerFilter = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerfilter.png',);
    markerPump = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerpump.png',);
    markerxMm1 = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerxmm.png',);
    markerXMp1 = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerxmp.png',);
    markerXMh1 = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerxmh.png',);
    markerXMr1 = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerxmr.png',);
    markerXMs1 = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerxms.png',);
    markerXMw1 = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerxmw.png',);
    markerXMl1 = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerxml.png',);
    markerXMe1 = await BitmapDescriptor.asset(const ImageConfiguration(size: Size(48, 48)),'assets/png/markerxme.png',);

   }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitMapToMarkers(markers);
  }

  Future<void> fetchData() async {
    try {
      final Repository repository = Repository(HttpService());
      var getUserDetails = await repository.getgeography({
        "userId": widget.customerId,
        "controllerId": widget.controllerId,
      });

      if (getUserDetails.statusCode == 200) {
        var jsonData = jsonDecode(getUserDetails.body);
        mqttPayloadProvider.updateMapData(jsonData);

        setState(() {
          deviceList =
              mqttPayloadProvider.mapModelInstance.data?.deviceList ?? [];
          markers = createMarkersFromDeviceList(deviceList);

          LatLng? firstValid = _getFirstLatLng(deviceList);
          if (firstValid != null) {
            _center = firstValid;
          }
        });
      }
    } catch (e, stackTrace) {
      mqttPayloadProvider.httpError = true;
      print('❌ Error fetching data: $e');
      print('🪵 Stack: $stackTrace');
    }
  }

  LatLng? _getFirstLatLng(List<DeviceList> devices) {
    for (var device in devices) {
      if (device.geography?.lat != null && device.geography?.long != null) {
        return LatLng(device.geography!.lat!, device.geography!.long!);
      }
      for (var obj in device.connectedObject ?? []) {
        if (obj.lat != null && obj.long != null) {
          return LatLng(obj.lat!, obj.long!);
        }
      }
    }
    return null;
  }

  Set<Marker> createMarkersFromDeviceList(List<DeviceList> devices) {
    Set<Marker> markers = {};

    for (var device in devices) {
      if (device.geography?.lat != null && device.geography?.long != null) {
        print(
            "✅ Device ${device.deviceName} at ${device.geography!.lat}, ${device.geography!.long}");
        markers.add(
          Marker(
            markerId: MarkerId('device-${device.deviceId}'),
            position: LatLng(
                device.geography!.lat!, device.geography!.long!),
            icon: _getMarkerIcon(device.geography?.status,device.categoryName!,0),
            infoWindow: InfoWindow(
              title: device.deviceName,
              snippet: device.modelName ?? '',
            ),
          ),
        );
      }

      for (var obj in device.connectedObject ?? []) {
        if (obj.lat != null && obj.long != null) {
          print(
              "✅ Object ${obj.name ?? obj.objectName} at ${obj.lat}, ${obj.long}");
          markers.add(
            Marker(
              markerId: MarkerId('object-${obj.sNo}'),
              position: LatLng(obj.lat!, obj.long!),
              icon: _getMarkerIcon(obj.status,obj.objectName,obj.percentage),
              infoWindow: InfoWindow(
                title: obj.name ?? obj.objectName ?? 'Object',
                snippet: 'Irrigation Percentage is💧:${obj.percentage}%',
              ),
            ),
          );
        }
      }
    }

    print('📍 Total markers: ${markers.length}');
    return markers;
  }

  BitmapDescriptor _getMarkerIcon(int? status,String type,int? percentage) {

    if (type.contains('Valve')) {
      print('_getMarkerIcon Status:$status, Percentage:$percentage');

      if (status == 1 || status == 2) {
        if (percentage == 100) {
          return markerGreen;
        } else {
          return markerBlue;
        }
      } else if (status == 0 || status == 3) {
        if (percentage == 0) {
          return markerGray;
        } else {
          return markerRed;
        }
      } else {
        return markerGray; // default
      }
    } else if( type.contains('fertilizer')) {
          return markerFert;
    }else if( type.contains('Filter')) {
     return markerFilter;
   } else if( type.contains('Agitator')) {
     return markerAgitator;
   } else if( type.contains('Pump')) {
     return markerPump;
   } else if( type.contains('Sensor')) {
     return markerSensor;
   }else if( type.contains('Injector')) {
     return markerInjector;
   }else if( type.contains('xMm')) {
     return markerxMm1;
   }else if( type.contains('xMe')) {
     return markerXMe1;
   }else if( type.contains('xMp')) {
     return markerXMp1;
   }else if( type.contains('xMh')) {
     return markerXMh1;
   }else if( type.contains('xMr')) {
     return markerXMr1;
   }else if( type.contains('xMs')) {
     return markerXMs1;
   }else if( type.contains('xMw')) {
     return markerXMw1;
   }else if( type.contains('xMl')) {
     return markerXMl1;
   }
    else
     {
       return markerBlue;
     }

  }

  Future<void> _fitMapToMarkers(Set<Marker> markers) async {
    if (markers.isEmpty) return;

    List<LatLng> positions = markers.map((m) => m.position).toList();

    final southwestLat =
    positions.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final southwestLng =
    positions.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    final northeastLat =
    positions.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final northeastLng =
    positions.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    final bounds = LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );

    await mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geography'),
        actions: [
        IconButton(
          icon: Icon(Icons.map_outlined),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DeviceListScreen(userId: widget.userId, customerId: widget.customerId, controllerId: widget.controllerId, imeiNo: widget.imeiNo,),
            ));
          },
          tooltip: 'Edit',
        ),
      ],),
      body: GoogleMap(
        mapType: MapType.hybrid,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 15.0,
        ),
        markers: markers,
      ),
    );
  }
}
