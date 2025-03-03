import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
 import '../../../Models/customer/site_model.dart';
import '../../../services/mqtt_manager_mobile.dart';
 import 'package:provider/provider.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';


class WaterSourceDashBoard extends StatefulWidget {
  final List<WaterSource> waterSource;

  const WaterSourceDashBoard({super.key, required this.waterSource});

  @override
  State<WaterSourceDashBoard> createState() => _WaterSourceDashBoardState();
}

class _WaterSourceDashBoardState extends State<WaterSourceDashBoard> with TickerProviderStateMixin{
 
  MqttManager manager = MqttManager();
  // late Timer _timer;
  late Animation<double> _animation;
  @override
  void initState() {
     // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
     // print('source pump true disposing...');
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    return Container(decoration: const BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        children: [
          for (var i = 0;i <widget.waterSource.length;i++)
               WaterSourceWidget(source: widget.waterSource[i])
        ],
      )
    );
  }
}

List<Widget> getLevelSensor({required int lineIndex,required MqttPayloadProvider payloadProvider}){
  List<Widget> listOfWidget = [];
  for(var line = 1;line < payloadProvider.lineData.length;line++){
    if(lineIndex == 0 || lineIndex == line){
      for(var ls in payloadProvider.lineData[line]['levelSensor']){
        listOfWidget.add(
            ListTile(
              // contentPadding: EdgeInsets.zero,
              leading: SizedBox(
                width: 35,
                height: 35,
                child: SvgPicture.asset(
                    'assets/images/level_condition.svg',
                    semanticsLabel: 'Acme Logo'
                ),
              ),
              title: Text('${ls['name']}'),
              trailing: IntrinsicWidth(child: Text(
                '${convertValue(double.parse(ls['value']), payloadProvider.units[3]['value']).toStringAsFixed(2)} ${payloadProvider.units[3]['value']}',
                style: const TextStyle(fontSize: 14, color: Colors.blue),
              )),
              subtitle: Text('Percentage: ${ls['percentage']} %'),
            )
        );
      }
    }
  }
  return listOfWidget;
}

double convertValue(double value, String unit) {
  print(unit);
  switch (unit) {
    case 'inch':
      return value * 39.3701; // 1 meter = 39.3701 inches
    case 'feet':
      return value * 3.28084; // 1 meter = 3.28084 feet
    case 'meter':
    default:
      return value; // Already in meters, no conversion needed
  }
}

void getLevelSensorAlertBox(context,payloadProvider){
  showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text('List of level Sensor'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...getLevelSensor(lineIndex: payloadProvider.selectedLine,payloadProvider: payloadProvider)
                ],
              ),
            ),
          ),
        );
      }
  );
}


class WaterSourceWidget extends StatelessWidget {

   final WaterSource source;

  const WaterSourceWidget({
    Key? key,
    required this.source,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Inlet Pump List in Row
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                // const Text(
                //   "Inlet Pumps",
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                 Row(
                  children: [
                    for (var i = 0;i <source.inletPump!.length;i++)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            GestureDetector(
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: SvgPicture.asset(
                                    'assets/Images/Source/pump_1.svg',
                                    semanticsLabel: 'Acme Logo'),
                              ),
                              onTap: (){
                                showCommonAlertDialog(context,source.inletPump![i].name,source.inletPump![i]);
                              },
                            ),
                            Text("${source.inletPump![i].name}")
                          ],
                        ),
                      ),
                  ]
                ),
              ],
            ),
            const SizedBox(width: 5), // Space between sections
             // Source
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text(
                //   "Source Type",
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                 Row(
                    children: [
                         Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: source.type == "1" ? SvgPicture.asset('assets/Images/Source/well_1.svg', semanticsLabel: 'Acme Logo'
                                  ) :  source.type == "2"  ? SvgPicture.asset('assets/Images/Source/tank_1.svg', semanticsLabel: 'Acme Logo'
                                  ) : source.type == "3"  ? SvgPicture.asset('assets/Images/Source/pond.svg', semanticsLabel: 'Acme Logo'
                                ) : SvgPicture.asset('assets/Images/Source/sump_1.svg', semanticsLabel: 'Acme Logo'),
                                ),
                                onTap: (){
                                  showCommonAlertDialog(context,source.name,source);
                                },
                              ),
                              Text("${source.name}")
                            ],
                          ),
                        ),
                    ]
                ),
              ],
            ),
            const SizedBox(width: 5), // Space between sections
             // Outlet Pump List in Row
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text(
                //   "Outlet Pumps",
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                 // Display the outlet pumps in a Row
                Row(
                    children: [
                      for (var i = 0;i <source.outletPump!.length;i++)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: SvgPicture.asset(
                                      'assets/Images/Source/pump_1.svg',
                                      semanticsLabel: 'Acme Logo'
                                  ),
                                ), onTap: (){
      showCommonAlertDialog(context,source.outletPump![i].name,source.outletPump![i]);
    },
                              ),
                              Text("${source.outletPump![i].name}")
                            ],
                          ),
                        ),
                    ]
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




void showCommonAlertDialog(BuildContext context, String title, dynamic message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title,style: TextStyle(color: Colors.black),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Level:${message.toString()}'),
            Text('pressureIn:${message}'),
            Text('pressureOut:${message}'),
            Text('waterMeter:${message}'),
          ],
        ),
       );
    },
  );
}
