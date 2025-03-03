import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import '../../../services/mqtt_manager_mobile.dart';
import '../mobile_dashboard_common_files.dart';
import 'package:provider/provider.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../waves.dart';


class SourcePumpDashBoardTrue extends StatefulWidget {
  final int active;
  final int selectedLine;
  final String imeiNo;
  const SourcePumpDashBoardTrue({super.key, required this.active, required this.selectedLine, required this.imeiNo});

  @override
  State<SourcePumpDashBoardTrue> createState() => _SourcePumpDashBoardTrueState();
}

class _SourcePumpDashBoardTrueState extends State<SourcePumpDashBoardTrue> with TickerProviderStateMixin{
  late AnimationController _controller;
  late AnimationController _controllerReverse;
  MqttManager manager = MqttManager();
  // late Timer _timer;
  late Animation<double> _animation;
  @override
  void initState() {
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);
    // _controller.repeat();

    _controller.addListener(() {
      setState(() {

      });
    });
    _controller.repeat();
    _controllerReverse = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _controllerReverse.repeat(reverse: true);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerReverse.dispose();
    // print('source pump true disposing...');
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    return Padding(
      padding: const EdgeInsets.only(left: 8,right: 8),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              getLevelSensorAlertBox(context,payloadProvider);
            },
            child: Container(
              // color: Colors.green,
              width: 100,
              height: payloadProvider.sourcePump.isEmpty ? 70 : 110,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 15,
                    right: 4,
                    left: 14,
                    child: SizedBox(
                      width: 70,
                      height: 80,
                      child: CustomPaint(
                        painter: WavePainter(_controllerReverse.value),
                        size: Size(70,80),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 0,
                    child: SizedBox(
                      width: 85,
                      height: 80,
                      child: SvgPicture.asset(
                        'assets/mob_dashboard/sump.svg',
                      ),
                    ),
                  ),
                  if(payloadProvider.sourcePump.isNotEmpty && payloadProvider.active == 1)
                    Positioned(
                        top: 12,
                        right: 7,
                        child: SizedBox(
                            width: 20,
                            height: 40,
                            child: verticalPipeTopFlow(count: 2,mode: getWaterPipeStatusForSourcePump(context), controller: _controller)
                        )
                    ),
                  if(payloadProvider.sourcePump.isNotEmpty && payloadProvider.active == 1)
                    Positioned(
                        top: 10,
                        right: 8,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child:  Transform.rotate(
                            angle: 4.71,
                            child: SvgPicture.asset(
                                'assets/mob_dashboard/L_joint.svg',
                                semanticsLabel: 'Acme Logo'
                            ),
                          ),
                        )
                    ),
                  Positioned(
                      left: 0,
                      bottom: 0,
                      child: SizedBox(
                          width: 20,
                          height: 30,
                          child: verticalPipeTopFlow(count: 3,mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine), controller: _controller)
                      )
                  ),
                  Positioned(
                      top: payloadProvider.sourcePump.isEmpty ? 30 :  73,
                      child: SizedBox(
                          width: 30,
                          height: 10,
                          child: horizontalPipeRightFlow(count: 3,mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine), controller: _controller)
                      )
                  ),
                  Positioned(
                      top: payloadProvider.sourcePump.isEmpty ? 30 : 73,
                      left: 0,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child:  Transform.rotate(
                          angle: 4.71,
                          child: SvgPicture.asset(
                              'assets/mob_dashboard/L_joint.svg',
                              semanticsLabel: 'Acme Logo'
                          ),
                        ),
                      )
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 5,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    // boxShadow: customBoxShadow
                  ),
                  // padding: EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for(var i = 0;i < payloadProvider.sourcePump.length;i++)
                          Column(
                            children: [
                              if(widget.active == 1)
                                if(payloadProvider.selectedLine != 0 && '${payloadProvider.sourcePump[i]['Location']}'.contains(payloadProvider.lineData[payloadProvider.selectedLine]['id']) || payloadProvider.selectedLine == 0)
                                  GetPumpAlertBox(index: i, controller: _controller, on: true, imeiNo: widget.imeiNo, controllerValue: _animation.value, pumpMode: payloadProvider.sourcePump[i]['Status'], delay: payloadProvider.sourcePump[i]['OnDelayLeft'],)
                                else
                                  if(payloadProvider.sourcePump[i]['Program'] != '')
                                    if(payloadProvider.selectedLine != 0 && '${payloadProvider.sourcePump[i]['Location']}'.contains(payloadProvider.lineData[payloadProvider.selectedLine]['id']) || payloadProvider.selectedLine == 0)
                                      GetPumpAlertBox(index: i, controller: _controller, on: true, imeiNo: widget.imeiNo, controllerValue: _animation.value, pumpMode: payloadProvider.sourcePump[i]['Status'], delay: payloadProvider.sourcePump[i]['OnDelayLeft'])
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                style: TextStyle(fontSize: 14, color: Colors.blue),
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
          title: Text('List of level Sensor'),
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