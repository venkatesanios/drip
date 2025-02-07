// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:oro_drip_irrigation/Constants/constants.dart';
// import 'package:oro_drip_irrigation/Models/Configuration/device_object_model.dart';
// import 'package:oro_drip_irrigation/StateManagement/config_maker_provider.dart';
// import 'package:provider/provider.dart';
//
// import '../../Models/Configuration/device_model.dart';
//
// class PayloadProcessing extends StatefulWidget {
//   const PayloadProcessing({super.key});
//
//   @override
//   State<PayloadProcessing> createState() => _PayloadProcessingState();
// }
//
// class _PayloadProcessingState extends State<PayloadProcessing> {
//   late Future<List<DeviceModel>> listOfDevices;
//
//   @override
//   void initState() {
//     super.initState();
//     listOfDevices = context.read<ConfigMakerProvider>().fetchData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('Payload Processing'),
//             ElevatedButton(
//               onPressed: () async {
//                 final Map<String, dynamic> deviceListPayload = {
//                   "100": [
//                     {"101": getDeviceListPayload()}
//                   ]
//                 };
//                 final Map<String, dynamic> configMakerPayload = {
//                   "200": [
//                     {"201": getPumpPayload()},
//                     {"202": getIrrigationLinePayload()},
//                     {"203": getFertilizerPayload()},
//                     {"204": getFilterPayload()},
//                     {"205": getWeatherPayload()},
//                     {"206": getObjectPayload()},
//                     {"207": 0},
//                     {"208": '1'}
//                   ]
//                 };
//
//                 /*print("getIrrigationLinePayload ==> ${jsonEncode(configMakerPayload)}");
//                 print("deviceListPayload ==> ${jsonEncode(deviceListPayload)}");*/
//                 print("getOroPumpPayload ==> ${getOroPumpPayload()}");
//               },
//               child: const Text('Continue'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
// }
