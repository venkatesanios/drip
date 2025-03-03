import 'dart:math';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/services/mqtt_manager_mobile.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../NewIrrigationProgram/preview_screen.dart';
import '../mobile_dashboard_common_files.dart';
import 'package:provider/provider.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';


import '../waves.dart';

class inletPumpDashBoardFalse extends StatefulWidget {
  final int active;
  final int selectedLine;
  final String imeiNo;
  const inletPumpDashBoardFalse({super.key, required this.active, required this.selectedLine, required this.imeiNo});

  @override
  State<inletPumpDashBoardFalse> createState() => _inletPumpDashBoardFalseState();
}

class _inletPumpDashBoardFalseState extends State<inletPumpDashBoardFalse> with TickerProviderStateMixin{
  late AnimationController _controller;
  late AnimationController _controllerReverse;
  MqttManager manager = MqttManager();
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
    // print('source pump false disposing...');
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
          Container(
            width: 40,
            height: (145 * getTextScaleFactor(context)).toDouble(),
            child: Stack(
              children: [
                Positioned(
                    top: 95,
                    child: SizedBox(
                        width: 40,
                        height: 10,
                        child: horizontalPipeRightFlow(count: 2,mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine), controller: _controller, )
                    )
                ),
                Positioned(
                    top: 100,
                    // top: 100,
                    child: SizedBox(
                        width: 40,
                        height: (300 * getTextScaleFactor(context)).toDouble(),
                        child: verticalPipeTopFlow(count: 4,mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine), controller: _controller,)
                    )
                ),

                Positioned(
                    top: 93,
                    left: -3,
                    child: SizedBox(
                      width: 25,
                      height: 25,
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
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 5,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: customBoxShadow
                  ),
                  padding: EdgeInsets.all(10),
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