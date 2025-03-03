import 'dart:math';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import '../../../services/mqtt_manager_mobile.dart';
import '../../NewIrrigationProgram/preview_screen.dart';
import '../Inlet Pump Dashboard/inlet_pump_true.dart';
import '../mobile_dashboard_common_files.dart';
import 'package:provider/provider.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';

import '../waves.dart';

class SourceTypeDashBoardTrue extends StatefulWidget {
  final int active;
  final int selectedLine;
  final String imeiNo;
  const SourceTypeDashBoardTrue({super.key, required this.active, required this.selectedLine, required this.imeiNo});

  @override
  State<SourceTypeDashBoardTrue> createState() => _SourceTypeDashBoardTrueState();
}

class _SourceTypeDashBoardTrueState extends State<SourceTypeDashBoardTrue> with TickerProviderStateMixin{
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
    // print('payloadProvider.sourcePump.length ::: ${payloadProvider.sourcePump.length}');
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
              width: 50,
              height: payloadProvider.sourcePump.isEmpty ? 70 : 110,
              child: Stack(
                children: [
                  Positioned(
                      bottom: 0,
                      child: SizedBox(
                          width: 40,
                          height: (200 * getTextScaleFactor(context)).toDouble(),
                          child: verticalPipeTopFlow(count: 4,mode: getWaterPipeStatus(context,selectedLine: widget.selectedLine), controller: _controller,)
                      )
                  ),
                  Positioned(
                      top: payloadProvider.sourcePump.isEmpty ? 30 :  73,
                      child: SizedBox(
                          width: 50,
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
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: customBoxShadow
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for(var i = 0;i < payloadProvider.sourcePump.length;i++)
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0,right: 10),
                                child:  Container(
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
                                    ],
                                  ),
                                ),
                              ),
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
