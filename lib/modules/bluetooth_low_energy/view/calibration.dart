import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';
import 'package:provider/provider.dart';

import '../state_management/ble_service.dart';

class Calibration extends StatefulWidget {
  final Map<String, dynamic> nodeData;
  const Calibration({super.key, required this.nodeData});

  @override
  State<Calibration> createState() => _CalibrationState();
}

class _CalibrationState extends State<Calibration> {
  late BleProvider bleService;
  List<dynamic> ecSensorList = [];
  List<dynamic> phSensorList = [];
  List<dynamic> waterMeter = [];

  final inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.black54),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.black54),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
  );

  @override
  void initState() {
    super.initState();
    bleService = Provider.of<BleProvider>(context, listen: false);
    ecSensorList = (bleService.nodeDataFromServer['configObject'] as List<dynamic>).where((e) => e['objectId'] == AppConstants.ecObjectId).toList();
    phSensorList = (bleService.nodeDataFromServer['configObject'] as List<dynamic>).where((e) => e['objectId'] == AppConstants.phObjectId).toList();
    waterMeter = (bleService.nodeDataFromServer['configObject'] as List<dynamic>).where((e) => e['objectId'] == AppConstants.waterMeterObjectId).toList();
  }

  @override
  Widget build(BuildContext context) {
    bleService = Provider.of<BleProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calibration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            spacing: 20,
            children: [
              if(waterMeter.isNotEmpty)
                cumulativeWidget(),
              batteryCalibration(),
              for(int ec = 0;ec < ecSensorList.length;ec++)
                ecSensorWidget(
                    sensorCount: ec,
                    sensorName: ecSensorList[ec]['name']
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget cumulativeWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(5) ,topRight: Radius.circular(27.5), ),
              color: Color(0xff008CD7)
          ),
          child: Center(
            child: Text('${waterMeter[0]['name']}',style: TextStyle(color: Colors.white, fontSize: 14),),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topRight: Radius.circular(5), bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
              border: Border.all(width: 0.5, color: const Color(0xff008CD7)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    spreadRadius: 0,
                    color: const Color(0xff8B8282).withValues(alpha: 0.2)
                )
              ]
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 20,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        controller: bleService.cumulativeController,
                        keyboardType: TextInputType.number,
                        decoration: inputDecoration.copyWith(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              'assets/Images/Svg/objectId_${AppConstants.waterMeterObjectId}.svg',
                              height: 40,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton.icon(
                        onPressed: (){
                          bleService.onRefresh();
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white,),
                        label: const Text("Refresh", style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff005C8E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                    onPressed: (){
                      var payload = '${bleService.nodeDataFromServer['calibrationSetting']['cumulative']}${bleService.cumulativeController.text}:';
                      var sumOfAscii = 0;
                      for(var i in payload.split('')){
                        var bytes = i.codeUnitAt(0);
                        sumOfAscii += bytes;
                      }
                      var addFirst = '';
                      for(var i = 0;i < (3-('${sumOfAscii % 256}'.length));i++){
                        addFirst += '0';
                      }
                      payload += '$addFirst${sumOfAscii % 256}:\r';
                      List<int> fullData = [];
                      for(var i in payload.split('')){
                        var bytes = i.codeUnitAt(0);
                        fullData.add(bytes);
                      }
                      print('sumOfAscii : $sumOfAscii');
                      print('crc : ${sumOfAscii % 256}');
                      print('fullData : ${fullData}');
                      print('payload : ${payload}');
                      bleService.sendDataToHw(fullData);
                    },
                    icon: const Icon(Icons.send, color: Colors.white,),
                    label: const Text("Submit", style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                )

              ],
            ),
          ),
        )
      ],
    );
  }

  Widget batteryCalibration(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(5) ,topRight: Radius.circular(27.5), ),
              color: Color(0xff008CD7)
          ),
          child: Center(
            child: Text('Battery Calibration',style: TextStyle(color: Colors.white, fontSize: 14),),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topRight: Radius.circular(5), bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
              border: Border.all(width: 0.5, color: const Color(0xff008CD7)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    spreadRadius: 0,
                    color: const Color(0xff8B8282).withValues(alpha: 0.2)
                )
              ]
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 20,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        controller: bleService.batteryController,
                        keyboardType: TextInputType.number,
                        decoration: inputDecoration.copyWith(
                          prefixIcon: const Icon(Icons.battery_6_bar),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton.icon(
                        onPressed: (){
                          bleService.onRefresh();
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white,),
                        label: const Text("Refresh", style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff005C8E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                    onPressed: (){
                      var payload = '${bleService.nodeDataFromServer['settingCommand']['sendBatterySettingCommand']}${bleService.batteryController.text}:';
                      var sumOfAscii = 0;
                      for(var i in payload.split('')){
                        var bytes = i.codeUnitAt(0);
                        sumOfAscii += bytes;
                      }
                      var addFirst = '';
                      for(var i = 0;i < (3-('${sumOfAscii % 256}'.length));i++){
                        addFirst += '0';
                      }
                      payload += '$addFirst${sumOfAscii % 256}:\r';
                      List<int> fullData = [];
                      for(var i in payload.split('')){
                        var bytes = i.codeUnitAt(0);
                        fullData.add(bytes);
                      }
                      print('sumOfAscii : $sumOfAscii');
                      print('crc : ${sumOfAscii % 256}');
                      print('fullData : ${fullData}');
                      print('payload : ${payload}');
                      bleService.sendDataToHw(fullData);
                    },
                    icon: const Icon(Icons.send, color: Colors.white,),
                    label: const Text("Submit", style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                )

              ],
            ),
          ),
        )
      ],
    );
  }

  Widget ecSensorWidget({
    required int sensorCount,
    required String sensorName,
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(5) ,topRight: Radius.circular(27.5), ),
              color: Color(0xff008CD7)
          ),
          child: Center(
            child: Text(sensorName,style: TextStyle(color: Colors.white, fontSize: 14),),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topRight: Radius.circular(5), bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
              border: Border.all(width: 0.5, color: const Color(0xff008CD7)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    spreadRadius: 0,
                    color: const Color(0xff8B8282).withValues(alpha: 0.2)
                )
              ]
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 20,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        controller: sensorCount == 0 ? bleService.ec1Controller : bleService.ec2Controller,
                        keyboardType: TextInputType.number,
                        decoration: inputDecoration.copyWith(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              'assets/Images/Svg/objectId_${AppConstants.ecObjectId}.svg',
                              height: 40,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton.icon(
                        onPressed: (){
                          bleService.onRefresh();
                          setState(() {
                            if(sensorCount == 0){
                              bleService.calibrationEc1 = 'ec${sensorCount+1}';
                              bleService.calibrationEc2 = '';
                            }else{
                              print("update ec 2");
                              bleService.calibrationEc2 = 'ec${sensorCount+1}';
                              bleService.calibrationEc1 = '';
                            }
                          });
                          if(sensorCount == 0){
                            print("blePvd.calibrationEc1 : ${bleService.calibrationEc1}");
                          }else{
                            print("blePvd.calibrationEc2 : ${bleService.calibrationEc2}");

                          }

                        },
                        icon: const Icon(Icons.refresh, color: Colors.white,),
                        label: const Text("Get @0", style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff005C8E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextFormField(
                        controller: sensorCount == 0 ? bleService.ec1_Controller : bleService.ec2_Controller,
                        keyboardType: TextInputType.number,
                        decoration: inputDecoration.copyWith(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SvgPicture.asset(
                              'assets/Images/Svg/objectId_${AppConstants.ecObjectId}.svg',
                              height: 40,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton.icon(
                        onPressed: (){
                          bleService.onRefresh();
                          setState(() {
                            if(sensorCount == 0){
                              bleService.calibrationEc1 = 'ec_${sensorCount+1}';
                              bleService.calibrationEc2 = '';

                            }else{
                              bleService.calibrationEc2 = 'ec_${sensorCount+1}';
                              bleService.calibrationEc1 = '';
                            }
                          });
                          if(sensorCount == 0){
                            print("blePvd.calibrationEc1 : ${bleService.calibrationEc1}");
                          }else{
                            print("blePvd.calibrationEc2 : ${bleService.calibrationEc2}");

                          }
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white,),
                        label: const Text("Get @ 1.413", style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff005C8E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton.icon(
                    onPressed: (){

                    },
                    icon: const Icon(Icons.send, color: Colors.white,),
                    label: const Text("Submit", style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColorLight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                )

              ],
            ),
          ),
        )
      ],
    );
  }

}