import 'dart:convert';

import 'package:flutter/material.dart';
 import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/snack_bar.dart';
import 'CustomerMap.dart';
import 'MapValveLocationChange.dart';
import 'devicelocationchange.dart';
import 'googlemap_model.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen(
      {Key? key,
        required this.userId,
        required this.customerId,
        required this.controllerId,
        required this.imeiNo})
      : super(key: key);
  final int userId, customerId, controllerId;
  final String imeiNo;

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {


   final Map<String, dynamic> jsonString = {
    "code": 200,
    "message": "User object listed successfully",
    "data": {
      "deviceList": [
        {
          "controllerId": 277,
          "deviceId": "2CCF676089F2",
          "deviceName": "ORO GEM",
          "siteName": "Oro@321",
          "categoryName": "ORO GEM",
          "modelName": "5G",
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": []
        },
        {
          "controllerId": 278,
          "modelName": "Smart RTU-M2",
          "categoryName": "ORO SMART PLUS",
          "deviceId": "E8EB1B04E485",
          "deviceName": "ORO SMART PLUS",
          "referenceNumber": 1,
          "serialNumber": 1,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testiwng",
              "object name": "Valve",
              "location": "Irrigation Line 2",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }, {
              "objectId": 2,
              "sNo": 1.002,
              "name": "Valve 2",
              "object name": "Valve",
              "location": "Irrigation Line 2",
              "lat": 10.0168,
              "long": 76.9518,
              "status": null
            },
            {
              "objectId": 3,
              "sNo": 1.003,
              "name": "Valve 3",
              "object name": "Valve",
              "location": "Irrigation Line 2",
              "lat": 10.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 299,
          "modelName": "pump 4g",
          "categoryName": "ORO PUMP ",
          "deviceId": "9C956EC7B179",
          "deviceName": "ORO PUMP ",
          "referenceNumber": 1,
          "serialNumber": 2,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve ",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 363,
          "modelName": "ORO PUMP PLUS",
          "categoryName": "ORO PUMP PLUS",
          "deviceId": "E8EB1B048DE3",
          "deviceName": "ORO PUMP PLUS",
          "referenceNumber": 1,
          "serialNumber": 3,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testing valve",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 685,
          "modelName": "SMART M1",
          "categoryName": "ORO SMART +",
          "deviceId": "E8EB1B048ABC",
          "deviceName": "ORO SMART +",
          "referenceNumber": 1,
          "serialNumber": 4,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve T2esting",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 696,
          "modelName": "RTU M1",
          "categoryName": "ORO RTU+",
          "deviceId": "80342882AC05",
          "deviceName": "ORO RTU+",
          "referenceNumber": 1,
          "serialNumber": 5,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve 1.1",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 697,
          "modelName": "RTU M1",
          "categoryName": "ORO RTU",
          "deviceId": "E8EB1B048ABA",
          "deviceName": "ORO RTU",
          "referenceNumber": 2,
          "serialNumber": 6,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve1",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 711,
          "modelName": "sense version 1.0.1",
          "categoryName": "ORO SENSE",
          "deviceId": "80342882ABF6",
          "deviceName": "ORO SENSE",
          "referenceNumber": 1,
          "serialNumber": 7,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testing 123",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 850,
          "modelName": "Level sensor M1",
          "categoryName": "ORO LEVEL",
          "deviceId": "80342882D72E",
          "deviceName": "ORO LEVEL",
          "referenceNumber": 1,
          "serialNumber": 8,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testing",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 718,
          "modelName": "Smart RTU-M1",
          "categoryName": "ORO SMART PLUS",
          "deviceId": "E8EB1B04CEB3",
          "deviceName": "ORO SMART PLUS",
          "referenceNumber": 2,
          "serialNumber": 9,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testing",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 717,
          "modelName": "RTU-M1",
          "categoryName": "ORO RTU PLUS",
          "deviceId": "E8EB1B048ABB",
          "deviceName": "ORO RTU PLUS",
          "referenceNumber": 2,
          "serialNumber": 10,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testing",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 727,
          "modelName": "SMART M1",
          "categoryName": "ORO SMART",
          "deviceId": "80342882E34A",
          "deviceName": "ORO SMART",
          "referenceNumber": 2,
          "serialNumber": 11,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testing",
              "object name": "Valve1 ",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 741,
          "modelName": "ORO PUMP PLUS",
          "categoryName": "ORO PUMP PLUS",
          "deviceId": "80342882E900",
          "deviceName": "ORO PUMP PLUS",
          "referenceNumber": 2,
          "serialNumber": 12,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testing",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 744,
          "modelName": "pump 4g",
          "categoryName": "ORO PUMP",
          "deviceId": "E8EB1B050555",
          "deviceName": "ORO PUMP",
          "referenceNumber": 2,
          "serialNumber": 13,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": 0},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve 2",
              "object name": "Valve12",
              "location": "Irrigation Line 3",
              "lat": 11.0168,
              "long": 76.9518,
              "status": 1
            }
          ]
        },
        {
          "controllerId": 745,
          "modelName": "ORO PUMP PLUS",
          "categoryName": "ORO PUMP PLUS",
          "deviceId": "E8EB1B048A32",
          "deviceName": "ORO PUMP PLUS",
          "referenceNumber": 3,
          "serialNumber": 14,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testing",
              "object name": "Valve13",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 795,
          "modelName": "Smart RTU-M1",
          "categoryName": "ORO SMART PLUS",
          "deviceId": "9C956EC7A844",
          "deviceName": "ORO SMART PLUS",
          "referenceNumber": 3,
          "serialNumber": 15,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testing",
              "object name": "Valves",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 816,
          "modelName": "ORO PUMP PLUS",
          "categoryName": "ORO PUMP PLUS",
          "deviceId": "80342882F808",
          "deviceName": "ORO PUMP PLUS",
          "referenceNumber": 4,
          "serialNumber": 16,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": 0},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testing",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": 1
            }
          ]
        },
        {
          "controllerId": 846,
          "modelName": "extend gsm",
          "categoryName": "ORO EXTEND-GSM",
          "deviceId": "ABCD12345679",
          "deviceName": "ORO EXTEND-GSM",
          "referenceNumber": 1,
          "serialNumber": 17,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testing",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": 1
            }
          ]
        },
        {
          "controllerId": 847,
          "modelName": "extend 2-l",
          "categoryName": "ORO EXTEND-2L",
          "deviceId": "ABCD12345678",
          "deviceName": "ORO EXTEND-2L",
          "referenceNumber": 1,
          "serialNumber": 18,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": 0},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve Testing",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": 1
            }
          ]
        },
        {
          "controllerId": 848,
          "modelName": "extend 1-l",
          "categoryName": "ORO EXTEND-1L",
          "deviceId": "ABCD12345677",
          "deviceName": "ORO EXTEND-1L",
          "referenceNumber": 1,
          "serialNumber": 19,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve 12",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 857,
          "modelName": "weather",
          "categoryName": "ORO WEATHER",
          "deviceId": "0B16212C3742",
          "deviceName": "ORO WEATHER",
          "referenceNumber": 1,
          "serialNumber": 20,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve 11",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 865,
          "modelName": "pump 4g",
          "categoryName": "ORO PUMP",
          "deviceId": "80342882B014",
          "deviceName": "ORO PUMP",
          "referenceNumber": 3,
          "serialNumber": 21,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve 21",
              "object name": "Valve",
              "location": "Irrigaion Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 977,
          "modelName": "pump 4g",
          "categoryName": "ORO PUMP",
          "deviceId": "9C956EC77833",
          "deviceName": "ORO PUMP",
          "referenceNumber": 4,
          "serialNumber": 22,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve 12",
              "object name": "Valve",
              "location": "Irrigati Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 1083,
          "modelName": "RTU M1",
          "categoryName": "ORO RTU",
          "deviceId": "9C956EC78631",
          "deviceName": "ORO RTU",
          "referenceNumber": 3,
          "serialNumber": 23,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": null},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve 2",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": null
            }
          ]
        },
        {
          "controllerId": 1200,
          "modelName": "sense version 1.0.1",
          "categoryName": "ORO SENSE",
          "deviceId": "9C956EC777B0",
          "deviceName": "ORO SENSE",
          "referenceNumber": 2,
          "serialNumber": 24,
          "geography": {"lat": 11.0168, "long": 76.9518, "status": 1},
          "connectedObject": [
            {
              "objectId": 1,
              "sNo": 1.001,
              "name": "Valve 3",
              "object name": "Valve",
              "location": "Irrigation Line 1",
              "lat": 11.0168,
              "long": 76.9518,
              "status": 1
            }
          ]
        }
      ],
      "liveMessage": {
        "cC": "2CCF6773D07D",
        "cM": {
          "2401":
              "1,18.0,12.4,1,2025-04-08 11:06:53.592709;2,0.0,0.0,1,2025-04-08 11:06:27.595799;3,18.0,6.5,1,2025-04-08 11:06:51.478076;4,18.0,8.0,1,2025-04-08 11:06:54.307968;5,18.0,8.1,1,2025-04-08 11:06:51.943809;6,0.0,100.0,1,2025-04-08 11:06:52.380892",
          "2402":
              "5.001,3;5.002,3;7.001,0;7.002,0;10.001,0;10.002,0;10.003,0;10.004,0;11.001,0;11.002,0;13.001,0;13.002,0;13.003,0;13.004,0;13.005,0;13.006,0;13.007,0;13.008,0;13.009,0;13.01,0;5.003,3;13.011,0;13.012,0;13.013,0;13.014,0;13.015,0;13.016,0",
          "2403":
              "24.001,0.00,0;24.002,0.00,0;24.003,0.00,0;24.004,0.00,0;22.001,11.02,48899;23.001,0,0",
          "2404":
              "5.001,0,0,0,0,215_216_199,1:0.0_2:0.0,00:00:00;5.002,0,0,0,0,215_216_199,3:0.0,00:00:00;5.003,24,0,00:00:00,0,218.0_215.0_212.0,1:0.0_2:0.0_3:0.0,00:00:00",
          "2405": "2.001,0;2.002,0",
          "2406": "4.001,0,00:02:00,0.0;4.002,0,00:02:00,0.0",
          "2407": "",
          "2408": "",
          "2409": "",
          "2410":
              "1,2.001,3,-,-,2025-04-08,100,19,30,1,1,2;2,2.002,3,-,-,2025-04-08,30,4,30,0,1,2",
          "2411": "",
          "2412": "",
          "WifiStrength": 100,
          "Version": "1.1.0:065",
          "PowerSupply": 1
        },
        "cD": "2025-04-08",
        "cT": "11:06:55",
        "mC": "2400"
      }
    }
  };
  late MqttPayloadProvider mqttPayloadProvider;

  MapConfigModel _mapConfigModel = MapConfigModel();

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData();
      // mqttPayloadProvider.updateMapData(jsonString);
    });

  }


   Future<void> fetchData() async {
     try{
       final Repository repository = Repository(HttpService());
       var getUserDetails = await repository.getgeography({
         "userId": 8,
         "controllerId" : 23
       });
       print('getUserDetails${getUserDetails.body}');
       // final jsonData = jsonDecode(getUserDetails.body);
       if (getUserDetails.statusCode == 200) {
         setState(() {
           var jsonData = jsonDecode(getUserDetails.body);
           print('jsonData$jsonData');
            mqttPayloadProvider.updateMapData(jsonData);
         });
       } else {
         //_showSnackBar(response.body);
       }
     }
     catch (e, stackTrace) {
       mqttPayloadProvider.httpError = true;
       print(' Error overAll getData => ${e.toString()}');
       print(' trace overAll getData  => ${stackTrace}');
     }
    }



   @override
   Widget build(BuildContext context) {
     return Consumer<MqttPayloadProvider>(
       builder: (context, mqttProvider, _) {
         final deviceList = mqttProvider.mapModelInstance.data?.deviceList;

         if (deviceList == null || deviceList.isEmpty) {
           return Scaffold(
             appBar: AppBar(title: const Text('Map Device List')),
             body: const Center(child: Text('Map Device list is empty')),
           );
         }
          return Scaffold(
           appBar: AppBar(title: const Text('Map Device List')),
           body: SingleChildScrollView(
             child: Padding(
               padding: const EdgeInsets.all(10.0),
               child: Column(
                 children: [
                    Row(
                      children: [
                        ///MapScreenall
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MapScreenall(userId: widget.userId, customerId: widget.customerId, controllerId: widget.controllerId, imeiNo: widget.imeiNo,),
                            ));
                          },

                          icon: Icon(Icons.edit_location_alt,color: Colors.white,),
                          label: Text('all'),
                        ),
                        Spacer(),
                        TextButton.icon(
                         onPressed: () {
                           Navigator.of(context).push(MaterialPageRoute(
                             builder: (context) => MapScreendevice(),
                           ));
                         },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,// text color
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                         icon: Icon(Icons.edit_location_alt,color: Colors.white,),
                         label: Text('Edit Node location'),),
                      ],
                    ),
                   Wrap(
                     spacing: 10.0,
                     runSpacing: 10.0,
                     children: List.generate(deviceList.length, (index) {
                       final device = deviceList[index];

                       return InkWell(
                         onTap: () {
                           Navigator.of(context).push(MaterialPageRoute(
                             builder: (context) => MapScreen(index: index),
                           ));
                         },
                         child: Card(
                           margin: const EdgeInsets.all(8.0),
                           elevation: 8,
                           shadowColor: Colors.blue,
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(10.0),
                           ),
                           child: Padding(
                             padding: const EdgeInsets.all(16.0),
                             child: Row(
                               children: [
                                 IconButton(
                                   icon: Image.asset('assets/png/map.png'),
                                   onPressed: () {},
                                 ),
                                 Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       '${device.deviceName ?? "Unknown"} (${device.connectedObject?.length ?? 0})',
                                       style: const TextStyle(
                                         fontSize: 18.0,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                     const SizedBox(height: 8.0),
                                     Text('Device ID: ${device.deviceId ?? "-"}'),
                                     Text('Location: ${device.geography!.lat },${device.geography!.lat }'),
                                     Text('Model: ${device.modelName ?? "-"}'),
                                     Text('Category: ${device.categoryName ?? "-"}'),
                                   ],
                                 ),
                                ],
                             ),
                           ),
                         ),
                       );
                     }),
                   ),
                 ],
               ),
             ),
           ),
           floatingActionButton: FloatingActionButton(
             backgroundColor: Theme.of(context).primaryColorDark,
             foregroundColor: Colors.white,
             onPressed: () async {
               setState(() {
                 updateMapLocation();
               });
             },
             tooltip: 'Send',
             child: const Icon(Icons.send),
           ),
         );
       },
     );
   }

   updateMapLocation() async {

     final Repository repository = Repository(HttpService());
var data = mqttPayloadProvider.mapModelInstance.data?.toJson();
     Map<String, dynamic> body = {
       "userId": widget.userId,
       "controllerId": widget.controllerId,
       "userGeography": data!['deviceList'],
       "createUser": widget.userId
     };
     print(body);
     var getUserDetails = await repository.creategeography(body);
     var jsonDataResponse = jsonDecode(getUserDetails.body);
      print(jsonDataResponse);
      GlobalSnackBar.show(context, jsonDataResponse['message'], 200);
   }
}
