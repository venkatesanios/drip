import 'dart:convert';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_drip_irrigation/Screens/dashboard/wave_view.dart';
import 'package:oro_drip_irrigation/Screens/dashboard/wave_view_in_alert.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import '../../StateManagement/overall_use.dart';
import '../../Widgets/sensor_graph.dart';
import '../../services/http_service.dart';
import '../../services/mqtt_manager_mobile.dart';
import '../NewIrrigationProgram/preview_screen.dart';
import '../NewIrrigationProgram/schedule_screen.dart';
import 'customerdashboard.dart';
 

double _calculatePosition(int index,double controllerValue) {
  double basePosition = initialPosition + (index * gap);
  double animatedPosition =
      basePosition + (speed * controllerValue);
  return animatedPosition;
}

Widget horizontalPipeRightFlow({required int count,required int mode,required AnimationController controller}){
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      return Stack(
        children: [
          if(mode == 1)
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  right: _calculatePosition(i,controller.value),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/mob_dashboard/horizontal_water_pipe.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
          else if(mode == 2)
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  right: _calculatePosition(i,controller.value),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/mob_dashboard/horizontal_water_fert_pipe.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
          else
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  right: _calculatePosition(i,0),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/mob_dashboard/horizontal_water_pipe_g.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )

        ],
      );
    },
  );
}

Widget horizontalFertPipeRightFlow({required int count,required int mode,required AnimationController controller}){
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      return Stack(
        children: [
          if(mode == 1)
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  right: _calculatePosition(i,controller.value),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/mob_dashboard/horizontal_water_fert_pipe.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
          else
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  right: _calculatePosition(i,0),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/mob_dashboard/horizontal_water_pipe_g.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )

        ],
      );
    },
  );
}

Widget horizontalPipeLeftFlow({required int count,required int mode,required AnimationController controller}){
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      return Stack(
        children: [
          if(mode == 1)
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  left: _calculatePosition(i,controller.value),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/mob_dashboard/horizontal_water_pipe.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
          else if(mode == 2)
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  left: _calculatePosition(i,0),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/mob_dashboard/horizontal_water_fert_pipe.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
          else
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  left: _calculatePosition(i,0),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/mob_dashboard/horizontal_water_pipe_g.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
        ],
      );;
    },
  );
}

Widget horizontalAirPipeLeftFlow({required int count,required int mode,required AnimationController controller}){
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      return Stack(
        children: [
          if(mode == 1)
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  left: _calculatePosition(i,controller.value),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/mob_dashboard/horizontal_air_pipe.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
          else
            for (int i = 0; i < count; i++)
              Positioned(
                  top: 1,
                  left: _calculatePosition(i,0),
                  child: SizedBox(
                    width: 100,
                    height: 10,
                    child:  SvgPicture.asset(
                        'assets/mob_dashboard/horizontal_water_pipe_g.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )
        ],
      );
    },
  );
}

Widget verticalPipeTopFlow({required int count,required int mode,required AnimationController controller}){
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      return Container(
        child: Stack(
          children: [
            if(mode != 0)
              for (int i = 0; i < count; i++)
                Positioned(
                    top: _calculatePosition(i,controller.value),
                    child: SizedBox(
                      width: 10,
                      height: 100,
                      child:  SvgPicture.asset(
                          'assets/mob_dashboard/vertical_water_pipe${mode == 1 ? '' : '_b'}.svg',
                          semanticsLabel: 'Acme Logo'
                      ),
                    )
                )
            else
              for (int i = 0; i < count; i++)
                Positioned(
                    top: _calculatePosition(i,0),
                    child: SizedBox(
                      width: 10,
                      height: 100,
                      child:  SvgPicture.asset(
                            'assets/mob_dashboard/vertical_water_pipe_g.svg',
                          semanticsLabel: 'Acme Logo'
                      ),
                    )
                )
          ],
        ),
      );
    },
  );
}

Widget verticalPipeBottomFlow({required int count,required int mode,required AnimationController controller}){
  return AnimatedBuilder(
    animation: controller,
    builder: (context, child) {
      return Container(
        child: Stack(
          children: [
            if(mode != 0)
              for (int i = 0; i < count; i++)
                Positioned(
                    bottom: _calculatePosition(i,controller.value),
                    child: SizedBox(
                      width: 10,
                      height: 100,
                      child:  SvgPicture.asset(
                          'assets/mob_dashboard/vertical_water_pipe${mode == 1 ? '' : '_b'}.svg',
                          semanticsLabel: 'Acme Logo'
                      ),
                    )
                )
            else
              Positioned(
                  top: 0,
                  child: SizedBox(
                    width: 10,
                    height: 100,
                    child:  SvgPicture.asset(
                        'assets/mob_dashboard/vertical_water_pipe_g.svg',
                        semanticsLabel: 'Acme Logo'
                    ),
                  )
              )

          ],
        ),
      );
    },
  );
}

class GetPumpAlertBox extends StatefulWidget {
  final int index;
  final int pumpMode;
  final AnimationController controller;
  final double controllerValue;
  final bool on;
  final String imeiNo;
  final String delay;
  const GetPumpAlertBox({super.key, required this.index, required this.controller, required this.on, required this.imeiNo, required this.controllerValue, required this.pumpMode, required this.delay});

  @override
  State<GetPumpAlertBox> createState() => _GetPumpAlertBoxState();
}

class _GetPumpAlertBoxState extends State<GetPumpAlertBox> {
  @override
  Widget build(BuildContext context) {
    var payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: true);
    return InkWell(
      onTap: (){
        if(mounted) {
          showDialog(
              context: context,
              builder: (context){
                return Consumer<MqttPayloadProvider>(builder: (context,payloadProvider,child) {
                  final bool pumponoffStatuscheck =  '${payloadProvider.sourcePump[widget.index]['Status']}' == '1';
                  final sNo = payloadProvider.sourcePump[widget.index]['S_No'];
                  final imei =  widget.imeiNo ?? '';
                  final setValue =  payloadProvider.sourcePump[widget.index]['SetValue'] ?? '';
                  final actualValue = payloadProvider.sourcePump[widget.index]['ActualValue'] ?? '';
                  final bool checkTimerFormat =  setValue.contains(":");
                  final reasonCode = payloadProvider.sourcePump[widget.index]['OnOffReason'] ?? '';
                  final bool isTripCondition = ['3','4','5','8','9','10','1','2','13','14'].contains(reasonCode);
                  final bool isCyclicOn = (['0', '30', '31'].contains(reasonCode) && pumponoffStatuscheck);
                  final bool isCyclicOf = (['3','4','5','8','9','10','1','2','13','14'].contains(reasonCode) && !pumponoffStatuscheck);
                  final bool isCurrent = ['8'].contains(reasonCode);
                  final bool maximumRun = ['3','4','5','8','9','10','1','2','13','14'].contains(reasonCode);
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    // title: Text('${payloadProvider.sourcePump[widget.index]['Name']}'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: payloadProvider.sourcePump[widget
                                .index]['Version'] != null ? IntrinsicWidth(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: cardColor
                                ),
                                child: Row(
                                  children: [
                                    getIcon(int.parse(
                                        payloadProvider.sourcePump[widget
                                            .index]['SignalStrength'])),
                                    Text('${payloadProvider.sourcePump[widget
                                        .index]['SignalStrength']} %',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),)
                                  ],
                                ),
                              ),
                            ) : null,
                            title: Text(payloadProvider.sourcePump[widget
                                .index]['SW_Name'] ??
                                payloadProvider.sourcePump[widget.index]['Name'],
                                style: TextStyle(color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold)),
                            subtitle: payloadProvider.sourcePump[widget
                                .index]['Version'] != null ? Text(
                                'Version : ${convertVersion(
                                    payloadProvider.sourcePump[widget
                                        .index]['Version'])}') : null,
                            trailing: IconButton(
                              icon: Icon(Icons.cancel, color: Colors.black,),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          if(payloadProvider.sourcePump[widget
                              .index]['Voltage'] != null)
                            if(payloadProvider.sourcePump[widget.index]['Voltage']
                                .isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Voltage'),
                                  SizedBox(height: 8,),
                                  Row(
                                    children: [
                                      for(var index = 0; index < 3; index++)
                                        buildContainer(
                                          title: payloadProvider.sourcePump[widget
                                              .index]['PF'] == null
                                              ? ["RN", "YN", "BN"][index]
                                              : [
                                            "RN ${double.parse(
                                                payloadProvider.sourcePump[widget
                                                    .index]['Voltage'].split(
                                                    ',')[0]).toStringAsFixed(0)}",
                                            "YN ${double.parse(
                                                payloadProvider.sourcePump[widget
                                                    .index]['Voltage'].split(
                                                    ',')[1]).toStringAsFixed(0)}",
                                            "BN ${double.parse(
                                                payloadProvider.sourcePump[widget
                                                    .index]['Voltage'].split(
                                                    ',')[2]).toStringAsFixed(0)}"
                                          ][index],
                                          value: payloadProvider.sourcePump[widget
                                              .index]['PF'] == null
                                              ? double.parse(
                                              payloadProvider.sourcePump[widget
                                                  .index]['Voltage'].split(
                                                  ',')[index]).toStringAsFixed(0)
                                              : [
                                            "RPF ${double.parse(
                                                payloadProvider.sourcePump[widget
                                                    .index]['PF'].split(',')[0])
                                                .toStringAsFixed(0)}",
                                            "YPF ${double.parse(
                                                payloadProvider.sourcePump[widget
                                                    .index]['PF'].split(',')[1])
                                                .toStringAsFixed(0)}",
                                            "BPF ${double.parse(
                                                payloadProvider.sourcePump[widget
                                                    .index]['PF'].split(',')[2])
                                                .toStringAsFixed(0)}"
                                          ][index],
                                          value2: payloadProvider
                                              .sourcePump[widget.index]['P'] !=
                                              null
                                              ? [
                                            "RP ${double.parse(
                                                payloadProvider.sourcePump[widget
                                                    .index]['P'].split(',')[0])
                                                .toStringAsFixed(0)}",
                                            "YP ${double.parse(
                                                payloadProvider.sourcePump[widget
                                                    .index]['P'].split(',')[1])
                                                .toStringAsFixed(0)}",
                                            "BP ${double.parse(
                                                payloadProvider.sourcePump[widget
                                                    .index]['P'].split(',')[2])
                                                .toStringAsFixed(0)}"
                                          ][index]
                                              : null,
                                          // title: ["RN", "YN", "BN"][index],
                                          // value:payloadProvider.sourcePump[widget.index]['Voltage'].split(',')[index],
                                          color1: [
                                            Colors.redAccent.shade100,
                                            Colors.amberAccent.shade400,
                                            Colors.lightBlueAccent.shade100,
                                          ][index],
                                          color2: [
                                            Colors.redAccent.shade700,
                                            Colors.amberAccent.shade700,
                                            Colors.lightBlueAccent.shade700,
                                          ][index],
                                        )
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  if(payloadProvider.sourcePump[widget
                                      .index]['E'] != null &&
                                      payloadProvider.sourcePump[widget
                                          .index]['E'].isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        runAlignment: WrapAlignment.spaceBetween,
                                        spacing: 20,
                                        children: [
                                          RichText(
                                              text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text: "Instant Energy:",
                                                        style: TextStyle(
                                                            color: Theme
                                                                .of(context)
                                                                .primaryColor,
                                                            fontSize: 13,
                                                            fontWeight: FontWeight
                                                                .bold)),
                                                    TextSpan(
                                                        text: " ${payloadProvider
                                                            .sourcePump[widget
                                                            .index]['E'].split(
                                                            ',')[0]}",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight
                                                                .bold)),
                                                  ]
                                              )
                                          ),
                                          RichText(
                                              text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text: "Cumulative Energy:",
                                                        style: TextStyle(
                                                            color: Theme
                                                                .of(context)
                                                                .primaryColor,
                                                            fontSize: 13,
                                                            fontWeight: FontWeight
                                                                .bold)),
                                                    TextSpan(
                                                        text: " ${payloadProvider
                                                            .sourcePump[widget
                                                            .index]['E'].split(
                                                            ',')[1]}",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight
                                                                .bold)),
                                                  ]
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                  if(payloadProvider.sourcePump[widget
                                      .index]['E'] != null &&
                                      payloadProvider.sourcePump[widget
                                          .index]['E'].isNotEmpty)
                                    SizedBox(height: 10,),
                                ],
                              ),
                          if(payloadProvider.sourcePump[widget
                              .index]['Current'] != null)
                            if(payloadProvider.sourcePump[widget.index]['Current']
                                .isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5,),
                                  Text('Current'),
                                  SizedBox(height: 8,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceEvenly,
                                    children: [
                                      for(var c in payloadProvider
                                          .sourcePump[widget.index]['Current']
                                          .split(','))
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 20),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                  5),
                                              gradient: LinearGradient(
                                                colors: currentColor[c.split(
                                                    ':')[0]],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              )
                                            // color: currentColor[c.split(':')[0]]
                                          ),
                                          child: Column(
                                            children: [
                                              Text('${currentName['${c.split(
                                                  ':')[0]}']}'),
                                              Text('${c.split(':')[1]}'),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                          SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            child: Wrap(
                              runSpacing: 10,
                              spacing: 10,
                              children: [
                                if(payloadProvider.sourcePump[widget
                                    .index]['Level'] != null)
                                  if(payloadProvider.sourcePump[widget
                                      .index]['Level'].isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      padding: EdgeInsets.all(5),
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: customBoxShadow,
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceEvenly,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Text('${payloadProvider
                                                .sourcePump[widget
                                                .index]['Level'][0]['SW_Name'] ??
                                                payloadProvider.sourcePump[widget
                                                    .index]['Level'][0]['Name']} '
                                                '\n ${payloadProvider
                                                .sourcePump[widget
                                                .index]['Level'][0]['Value']} Feet'),
                                          ),
                                          Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width * 0.2,
                                            height: 120,
                                            decoration: BoxDecoration(
                                              color: Color(0xffE8EDFE),
                                              borderRadius: const BorderRadius
                                                  .only(
                                                  topLeft: Radius.circular(80.0),
                                                  bottomLeft: Radius.circular(
                                                      80.0),
                                                  bottomRight: Radius.circular(
                                                      80.0),
                                                  topRight: Radius.circular(
                                                      80.0)),
                                              boxShadow: <BoxShadow>[
                                                BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.4),
                                                    offset: const Offset(2, 2),
                                                    blurRadius: 4),
                                              ],
                                            ),
                                            child: WaveViewInAlert(
                                              percentageValue: payloadProvider
                                                  .sourcePump[widget
                                                  .index]['Level'][0]['LevelPercent']
                                                  .toDouble(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                if(payloadProvider.sourcePump[widget
                                    .index]['OnOffReason'] != null &&
                                    payloadProvider.sourcePump[widget
                                        .index]['OnOffReason'] != '0')
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Reason', style: TextStyle(
                                          fontWeight: FontWeight.bold),),
                                      SizedBox(height: 3,),
                                      Text('${payloadProvider.sourcePump[widget
                                          .index]['SW_Name'] } is ${widget
                                          .pumpMode == 1
                                          ? 'on'
                                          : 'off'} due to ${pumpAlarmMessage[payloadProvider
                                          .sourcePump[widget
                                          .index]['OnOffReason']]}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red)),
                                      if(payloadProvider.sourcePump[widget
                                          .index]['OnOffReason'] != null &&
                                          ['3', '4', '5', '8', '9', '10']
                                              .contains(
                                              payloadProvider.sourcePump[widget
                                                  .index]['OnOffReason']))
                                        Text('( set = ${payloadProvider
                                            .sourcePump[widget
                                            .index]['SetValue']} ,'
                                            ' Actual = ${payloadProvider
                                            .sourcePump[widget
                                            .index]['ActualValue']} '
                                            '${pumpAlarmMessage[payloadProvider
                                            .sourcePump[widget
                                            .index]['OnOffReason']].contains(
                                            'voltage')
                                            ? ', Phase = ${payloadProvider
                                            .sourcePump[widget.index]['Phase']}'
                                            : ''})', style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red)),
                                      if(['7', '8', '9', '10'].contains(
                                          payloadProvider.sourcePump[widget
                                              .index]['OnOffReason']))
                                        MaterialButton(
                                          color: Colors.red,
                                          onPressed: () async {
                                            MqttManager().topicToPublishAndItsMessage("AppToFirmware/${widget.imeiNo}", jsonEncode({
                                              "6300": [
                                                {
                                                  "6301": '${payloadProvider
                                                      .sourcePump[widget
                                                      .index]['S_No']},${1}'
                                                }
                                              ]
                                            }));
                                             setState(() {
                                              payloadProvider.sourcePump[widget
                                                  .index]['reset'] = true;
                                            });
                                          },
                                          child: Text('Reset', style: TextStyle(
                                              color: Colors.white),),
                                        )
                                    ],
                                  ),
                                if(payloadProvider.sourcePump[widget
                                    .index]['Pressure'] != null)
                                  if(payloadProvider.sourcePump[widget
                                      .index]['Pressure'].isNotEmpty)
                                    getFloatWidget(context: context,
                                        image: 'pressure_sensor',
                                        value: '${payloadProvider
                                            .sourcePump[widget
                                            .index]['Pressure'][0]['Value']}',
                                        name: '${payloadProvider.sourcePump[widget
                                            .index]['Pressure'][0]['SW_Name'] ??
                                            payloadProvider.sourcePump[widget
                                                .index]['Pressure'][0]['Name']}'),
                                if(payloadProvider.sourcePump[widget
                                    .index]['Watermeter'] != null)
                                  if(payloadProvider.sourcePump[widget
                                      .index]['Watermeter'].isNotEmpty)
                                    getFloatWidget(context: context,
                                        image: 'water_meter',
                                        value: '${payloadProvider
                                            .sourcePump[widget
                                            .index]['Watermeter'][0]['Value']}',
                                        name: '${payloadProvider.sourcePump[widget
                                            .index]['Watermeter'][0]['SW_Name'] ??
                                            payloadProvider.sourcePump[widget
                                                .index]['Watermeter'][0]['Name']}'),
                                if(payloadProvider.sourcePump[widget
                                    .index]['SumpTankLow'] != null)
                                  if(payloadProvider.sourcePump[widget
                                      .index]['SumpTankLow'].isNotEmpty)
                                    getFloatWidget(context: context,
                                        image: 'sump_low',
                                        value: '${payloadProvider
                                            .sourcePump[widget
                                            .index]['SumpTankLow'][0]['Value']}',
                                        name: '${payloadProvider.sourcePump[widget
                                            .index]['SumpTankLow'][0]['SW_Name'] ??
                                            payloadProvider.sourcePump[widget
                                                .index]['SumpTankLow'][0]['Name']}'),
                                if(payloadProvider.sourcePump[widget
                                    .index]['SumpTankHigh'] != null)
                                  if(payloadProvider.sourcePump[widget
                                      .index]['SumpTankHigh'].isNotEmpty)
                                    getFloatWidget(context: context,
                                        image: 'sump_high',
                                        value: '${payloadProvider
                                            .sourcePump[widget
                                            .index]['SumpTankHigh'][0]['Value']}',
                                        name: '${payloadProvider.sourcePump[widget
                                            .index]['SumpTankHigh'][0]['SW_Name'] ??
                                            payloadProvider.sourcePump[widget
                                                .index]['SumpTankHigh'][0]['Name']}'),
                                if(payloadProvider.sourcePump[widget
                                    .index]['TopTankLow'] != null)
                                  if(payloadProvider.sourcePump[widget
                                      .index]['TopTankLow'].isNotEmpty)
                                    getFloatWidget(context: context,
                                        image: 'tank_low',
                                        value: '${payloadProvider
                                            .sourcePump[widget
                                            .index]['TopTankLow'][0]['Value']}',
                                        name: '${payloadProvider.sourcePump[widget
                                            .index]['TopTankLow'][0]['SW_Name'] ??
                                            payloadProvider.sourcePump[widget
                                                .index]['TopTankLow'][0]['Name']}'),
                                if(payloadProvider.sourcePump[widget
                                    .index]['TopTankHigh'] != null)
                                  if(payloadProvider.sourcePump[widget
                                      .index]['TopTankHigh'].isNotEmpty)
                                    getFloatWidget(context: context,
                                        image: 'tank_high',
                                        value: '${payloadProvider
                                            .sourcePump[widget
                                            .index]['TopTankHigh'][0]['Value']}',
                                        name: '${payloadProvider.sourcePump[widget
                                            .index]['TopTankHigh'][0]['SW_Name'] ??
                                            payloadProvider.sourcePump[widget
                                                .index]['TopTankHigh'][0]['Name']}'),
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                          // Card(
                          //   color: Colors.white,
                          //   shadowColor: Colors.grey,
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(4.0),
                          //     child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //        children: [
                          //          Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //            children: [
                          //             Text( ['11','22'].contains(payloadProvider.sourcePump[widget.index]['OnOffReason']) ? "Cyclic Remaining" : payloadProvider.sourcePump[widget.index]['OnOffReason'] == '8' ? "Set Current"  : "Set Value",style: TextStyle(fontWeight: FontWeight.bold),),
                          //              Text( ['11','22'].contains(payloadProvider.sourcePump[widget.index]['OnOffReason']) ? "Max Time" : payloadProvider.sourcePump[widget.index]['OnOffReason'] == '8' ? "Actual Current"  : "Actual Value",style: TextStyle(fontWeight: FontWeight.bold),),
                          //             ],
                          //         ),
                          //         Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                          //           children: [
                          //             Text(payloadProvider.sourcePump[widget.index]['SetValue']),
                          //             Text(payloadProvider.sourcePump[widget.index]['ActualValue'])
                          //           ],
                          //         ),
                          //         Center(
                          //           child:  ['3','4','5','6','21','22','23','24','25','26','27','28','29','30','31'].contains(payloadProvider.sourcePump[widget.index]['OnOffReason']) ?  TextButton(
                          //                onPressed: ()async{
                          //                 MqttManager().publish(
                          //                     jsonEncode({"6300" : [{"6301" : '${payloadProvider.sourcePump[widget.index]['S_No']},${1}'}]}),
                          //                     "AppToFirmware/${widget.imeiNo}");
                          //                 setState(() {
                          //                   payloadProvider.sourcePump[widget.index]['reset'] = true;
                          //                 });
                          //              },
                          //             style: TextButton.styleFrom(
                          //               foregroundColor: Colors.white,
                          //               backgroundColor: Colors.red,
                          //               // White text color
                          //             ),
                          //             child: Text('Reset'),
                          //           ) : Container(),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // setActualwidget(sNo: payloadProvider.sourcePump[widget.index]['S_No'], imei: widget.imeiNo, setValue: payloadProvider.sourcePump[widget.index]['SetValue'], ActualValue: payloadProvider.sourcePump[widget.index]['ActualValue'], pumponoffStatus: payloadProvider.sourcePump[widget.index]['Status'] , reasonCode: payloadProvider.sourcePump[widget.index]['OnOffReason']),
                          (isCyclicOn || isCyclicOf || maximumRun) ?  Card(
                            color: Colors.white,
                            shadowColor: Colors.grey,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text( (checkTimerFormat && !isTripCondition) ? (isCyclicOn || isCyclicOf) ? "Cyclic Remaining" : isCurrent ? "Set Current"  : "Set Value" : "Set Value",style: TextStyle(fontWeight: FontWeight.bold),),
                                      Text( (checkTimerFormat && !isTripCondition) ? (isCyclicOn || isCyclicOf) ? "Max Time" : isCurrent ? "Actual Current"  : "Actual Value" : "Actual Value",style: TextStyle(fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Text("${setValue}-$reasonCode"),
                                      Text(actualValue)
                                    ],
                                  ),
                                  Center(
                                    child:  ['3','4','5','6','21','22','23','24','25','26','27','28','29','30','31'].contains(reasonCode) ?  TextButton(
                                      onPressed: (){
                                        if(mounted) {
                                          MqttManager().topicToPublishAndItsMessage("AppToFirmware/${imei}",
                                              jsonEncode({"6300" : [{"6301" : '${sNo},${1}'}]}));
                                        }
                                        setState(() {
                                          payloadProvider.sourcePump[widget.index]['reset'] = true;
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.purple,
                                        // White text color
                                      ),
                                      child: Text('Reset'),
                                    ) : Container(),
                                  ),
                                ],
                              ),
                            ),
                          ) : Container(),
                          /*setActualwidget(sNo: payloadProvider.sourcePump[widget
                              .index]['S_No'],
                              imei: widget.imeiNo ?? '',
                              setValue: payloadProvider.sourcePump[widget
                                  .index]['SetValue'] ?? '',
                              ActualValue: payloadProvider.sourcePump[widget
                                  .index]['ActualValue'] ?? '',
                              pumponoffStatus: '${payloadProvider
                                  .sourcePump[widget.index]['Status']}',
                              reasonCode: payloadProvider.sourcePump[widget
                                  .index]['OnOffReason'] ?? ''),*/

                          SizedBox(height: 20,),
                          Row(
                            children: [
                              if(overAllPvd.takeSharedUserId
                                  ? (payloadProvider
                                  .userPermission[0]['status'] ||
                                  payloadProvider.userPermission[3]['status'])
                                  : true)
                                for(var on in [1, 0])
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: InkWell(
                                      onTap: () async {
                                        if (payloadProvider.sourcePump[widget
                                            .index]['${on}loading'] == null) {
                                          var payload = {
                                            "6200": [
                                              {
                                                "6201": '${payloadProvider
                                                    .sourcePump[widget
                                                    .index]['S_No']},${on},${1}'
                                              }
                                            ]
                                          };
                                          MqttManager().topicToPublishAndItsMessage("AppToFirmware/${widget.imeiNo}",
                                              jsonEncode(payload));
                                          setState(() {
                                            payloadProvider.sourcePump[widget
                                                .index]['${on}loading'] = true;
                                          });
                                          for (var i = 0; i < 8; i++) {
                                            await Future.delayed(
                                                Duration(seconds: 1));
                                            if (i == 7) {
                                              setState(() {
                                                payloadProvider.sourcePump[widget
                                                    .index].remove(
                                                    '${on}loading');
                                              });
                                            }
                                            if (payloadProvider.sourcePump[widget
                                                .index]['${on}loading'] == null) {
                                              break;
                                            }
                                          }
                                          sentUserOperationToServer(
                                              '${payloadProvider.sourcePump[widget
                                                  .index]['SW_Name'] ??
                                                  payloadProvider
                                                      .sourcePump[widget
                                                      .index]['Name']} ${on == 1
                                                  ? 'Start'
                                                  : 'Stop'} Manually', payload,
                                              context);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 10),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                30),
                                            color: on == 1 ? Colors.green : Colors
                                                .red,
                                            border: Border.all(width: 0.5),
                                            boxShadow: [
                                              BoxShadow(
                                                  offset: const Offset(0, 0),
                                                  blurRadius: 4,
                                                  color: on == 1 ? Colors
                                                      .greenAccent : Colors
                                                      .deepOrange
                                              ),

                                            ]
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 25,
                                              height: 25,
                                              child: Image.asset(
                                                  'assets/mob_dashboard/on_off.png'),
                                            ),
                                            SizedBox(width: 5,),
                                            payloadProvider.sourcePump[widget
                                                .index]['${on}loading'] == null
                                                ? Text(
                                              on == 1 ? 'Motor On' : 'Motor OFF',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),)
                                                : loadingButton()
                                          ],
                                        ),
                                        // child: payloadProvider.sourcePump[widget.index]['${on}loading'] == null ?  Text(on == 1 ? 'Motor On' : 'Motor OFF',style: TextStyle(color: Colors.white,fontSize: 14),) : loadingButtuon()
                                      ),
                                    ),
                                  ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                });
              }
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 5,),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        width: 100,
        height: 100,
        child: Stack(
          children: [
            Positioned(
              top: 10,
              child: Transform.scale(
                scale: 0.8,
                child: getTypesOfPump(mode: widget.pumpMode, controller: widget.controller, animationValue: widget.controllerValue),
              ),
            ),
            if(payloadProvider.sourcePump[widget.index]['OnOffReason'] != null && payloadProvider.sourcePump[widget.index]['OnOffReason'] != '0')
              Positioned(
                  right: 5,
                  top: 10,
                  child: Icon(Icons.info,color: Colors.orange,)
              ),
            if(payloadProvider.sourcePump[widget.index]['Level'] != null)
              if(payloadProvider.sourcePump[widget.index]['Level'].isNotEmpty)
                Positioned(
                    left: 5,
                    top: 20,
                    child: Container(
                      width: 10,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade300
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 10,
                          height: 30 * (payloadProvider.sourcePump[widget.index]['Level'][0]['LevelPercent']/100) as double,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blue.shade300
                          ),
                        ),
                      ),
                    )
                ),
            if(payloadProvider.sourcePump[widget.index]['Level'] != null)
              if(payloadProvider.sourcePump[widget.index]['Level'].isNotEmpty)
                Positioned(
                    left: 2,
                    top: 2,
                    child: Text('${payloadProvider.sourcePump[widget.index]['Level'][0]['LevelPercent']}%',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
                ),
            Positioned(
                left: 2,
                bottom: 5,
                child: Text(payloadProvider.sourcePump[widget.index]['SW_Name'] ?? payloadProvider.sourcePump[widget.index]['Name'],style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
            ),
            if(widget.delay != '00:00:00')
              Positioned(
                  left: 30,
                  top: 15,
                  child: Container(
                      padding: EdgeInsets.all(2),
                      color: Colors.black,
                      child: Text(widget.delay,style: TextStyle(fontSize: 9,fontWeight: FontWeight.bold,color: Colors.white),)
                  )
              ),
          ],
        ),
      ),
    );
  }

  Widget getFloatWidget({
    required BuildContext context,
    required String image,
    required String name,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(5),
      width: MediaQuery
          .of(context)
          .size
          .width * 0.3,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: customBoxShadow,
          borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
              width: 40,
              height: 40,
              child: Image.asset('assets/mob_dashboard/$image.png')
          ),
          Text(name),
          Text(value),
        ],
      ),
    );
  }
  Widget loadingButton(){
    return const SizedBox(
      width: 20,
      height: 20,
      child: LoadingIndicator(
        colors: [
          Colors.white,
          Colors.white,
        ],
        indicatorType: Indicator.ballPulse,
      ),
    );
  }
  Widget setActualwidget({required int sNo,required String imei,required String setValue,required String ActualValue,required String pumponoffStatus,required String reasonCode,}){
    final bool pumponoffStatuscheck =  pumponoffStatus == '1' ? true : false ;
    final bool checkTimerFormat =  setValue.contains(":") ? true : false ;
    final bool isTripCondition = ['3','4','5','8','9','10','1','2','13','14'].contains(reasonCode)  ? true : false ;
    final bool isCyclicOn = (['0', '30', '31'].contains(reasonCode) && pumponoffStatuscheck) ? true : false ;
    final bool isCyclicOf = (['3','4','5','8','9','10','1','2','13','14'].contains(reasonCode) && !pumponoffStatuscheck)  ? true : false ;
    final bool isCurrent = ['8'].contains(reasonCode)  ? true : false ;
    final bool maximumRun = ['3','4','5','8','9','10','1','2','13','14'].contains(reasonCode)  ? true : false ;
    var payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
    return (isCyclicOn || isCyclicOf || maximumRun) ?  Card(
      color: Colors.white,
      shadowColor: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text( (checkTimerFormat && !isTripCondition) ? (isCyclicOn || isCyclicOf) ? "Cyclic Remaining" : isCurrent ? "Set Current"  : "Set Value" : "Set Value",style: TextStyle(fontWeight: FontWeight.bold),),
                Text( (checkTimerFormat && !isTripCondition) ? (isCyclicOn || isCyclicOf) ? "Max Time" : isCurrent ? "Actual Current"  : "Actual Value" : "Actual Value",style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("${setValue}-$reasonCode"),
                Text(ActualValue)
              ],
            ),
            /* Center(
              child:  ['3','4','5','6','21','22','23','24','25','26','27','28','29','30','31'].contains(reasonCode) ?  TextButton(
                onPressed: (){
                  if(mounted) {
                    MqttManager().publish(
                        jsonEncode({"6300" : [{"6301" : '${sNo},${1}'}]}),
                        "AppToFirmware/${imei}");
                  }
                  setState(() {
                  payloadProvider.sourcePump[widget.index]['reset'] = true;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.purple,
                  // White text color
                ),
                child: Text('Reset'),
              ) : Container(),
            ),*/
          ],
        ),
      ),
    ) : Container() ;
  }

}

Map<String,dynamic> oPumpIcon = {
  'SignalStrength' : Icons.signal_cellular_alt_sharp,
  'Battery' : Icons.battery_5_bar,
  'Version' : Icons.insert_drive_file_rounded,
};

Widget getIrrigationPump({required String pumpName,required data,required String delay,required int pumpMode,required BuildContext context,required AnimationController controller,required double animationValue,required Widget resetButton}){
  return InkWell(
    onTap: (){
      showDialog(
          context: context,
          builder: (context){
            return Consumer<MqttPayloadProvider>(builder: (context,payloadProvider,child){
              return AlertDialog(
                backgroundColor: Colors.white,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: data['Version'] != null ? IntrinsicWidth(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: cardColor
                          ),
                          child: Row(
                            children: [
                              getIcon(int.parse(data['SignalStrength'])),
                              Text('${data['SignalStrength']} %',style: TextStyle(fontWeight: FontWeight.bold),)
                            ],
                          ),
                        ),
                      ) : null,
                      title: Text(pumpName,style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold)),
                      subtitle: data['Version'] != null ? Text('Version : ${data['Version']}',) : null,
                    ),
                    if(data['Voltage'] != null)
                      if(data['Voltage'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Voltage'),
                            SizedBox(height: 8,),
                            Row(
                              children: [
                                for(var index = 0; index < 3; index++)
                                  buildContainer(
                                    title: data['PF'] == null
                                        ? ["RN", "YN", "BN"][index]
                                        : ["RN ${double.parse(data['Voltage'].split(',')[0]).toStringAsFixed(0)}",
                                      "YN ${double.parse(data['Voltage'].split(',')[1]).toStringAsFixed(0)}",
                                      "BN ${double.parse(data['Voltage'].split(',')[2]).toStringAsFixed(0)}"][index],
                                    value: data['PF'] == null
                                        ? double.parse(data['Voltage'].split(',')[index]).toStringAsFixed(0)
                                        : ["RPF ${double.parse(data['PF'].split(',')[0]).toStringAsFixed(0)}",
                                      "YPF ${double.parse(data['PF'].split(',')[1]).toStringAsFixed(0)}",
                                      "BPF ${double.parse(data['PF'].split(',')[2]).toStringAsFixed(0)}"][index],
                                    value2: data['P'] != null
                                        ? ["RP ${double.parse(data['P'].split(',')[0]).toStringAsFixed(0)}",
                                      "YP ${double.parse(data['P'].split(',')[1]).toStringAsFixed(0)}",
                                      "BP ${double.parse(data['P'].split(',')[2]).toStringAsFixed(0)}"][index]
                                        : null,
                                    // title: ["RN", "YN", "BN"][index],
                                    // value:data['Voltage'].split(',')[index],
                                    color1: [
                                      Colors.redAccent.shade100,
                                      Colors.amberAccent.shade400,
                                      Colors.lightBlueAccent.shade100,
                                    ][index],
                                    color2: [
                                      Colors.redAccent.shade700,
                                      Colors.amberAccent.shade700,
                                      Colors.lightBlueAccent.shade700,
                                    ][index],
                                  )
                              ],
                            ),
                            SizedBox(height: 5,),
                          ],
                        ),
                    if(data['E'] != null && data['E'].isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          runAlignment: WrapAlignment.spaceBetween,
                          spacing: 20,
                          children: [
                            RichText(
                                text: TextSpan(
                                    children: [
                                      TextSpan(text: "Instant Energy:", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                                      TextSpan(text: " ${data['E'].split(',')[0]}", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                                    ]
                                )
                            ),
                            RichText(
                                text: TextSpan(
                                    children: [
                                      TextSpan(text: "Cumulative Energy:", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                                      TextSpan(text: " ${data['E'].split(',')[1]}", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
                                    ]
                                )
                            ),
                          ],
                        ),
                      ),
                    if(data['E'] != null && data['E'].isNotEmpty)
                      SizedBox(height: 10,),
                    if(data['Current'] != null)
                      if(data['Current'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5,),
                            Text('Current'),
                            SizedBox(height: 8,),
                            if(data['Current'].split(',')[0][1] != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  for(var c in data['Current'].split(','))
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          gradient: LinearGradient(
                                            colors: currentColor[c.split(':')[0]],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          )
                                        // color: currentColor[c.split(':')[0]]
                                      ),
                                      child: Column(
                                        children: [
                                          Text('${currentName['${c.split(':')[0]}']}'),
                                          Text('${c.split(':')[1]}'),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                    SizedBox(height: 10,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Wrap(
                        runSpacing: 10,
                        spacing: 10,
                        children: [
                          // dry run , overload, current spp, started drip
                          if(data['OnOffReason'] != null && data['OnOffReason'] != '0')
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Reason',style: TextStyle(fontWeight: FontWeight.bold),),
                                SizedBox(height: 3,),
                                Text('${pumpName} is ${pumpMode == 1 ? 'on' : 'off'} due to ${pumpAlarmMessage[data['OnOffReason']]}\n '
                                    '( set = ${data['SetValue']} ,'
                                    ' Actual = ${data['ActualValue']} '
                                    '${pumpAlarmMessage[data['OnOffReason']].contains('voltage') ? ', Phase = ${data['Phase']}' : ''})',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                                if(data['OnOffReason'] != null && ['3','4','5','8','9','10'].contains(data['OnOffReason']))
                                  Text('( set = ${data['SetValue']} ,'
                                      ' Actual = ${data['ActualValue']} '
                                      '${pumpAlarmMessage[data['OnOffReason']].contains('voltage') ? ', Phase = ${data['Phase']}' : ''})',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red)),
                                resetButton
                              ],
                            ),
                          if(data['Level'] != null)
                            if(data['Level'].isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(5),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: customBoxShadow,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Text('${data['Level'][0]['SW_Name'] ?? data['Level'][0]['Name']}'
                                          '\n ${data['Level'][0]['Value']} m'),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Color(0xffE8EDFE),
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(80.0),
                                            bottomLeft: Radius.circular(80.0),
                                            bottomRight: Radius.circular(80.0),
                                            topRight: Radius.circular(80.0)),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: Colors.grey.withOpacity(0.4),
                                              offset: const Offset(2, 2),
                                              blurRadius: 4),
                                        ],
                                      ),
                                      child: WaveView(
                                        percentageValue: double.parse(data['Level'][0]['Value']),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          if(data['Pressure'] != null)
                            if(data['Pressure'].isNotEmpty)
                              getFloatWidget(context: context, image: 'pressure_sensor', value: '${data['Pressure'][0]['Value']}', name: '${data['Pressure'][0]['SW_Name'] ?? data['Pressure'][0]['Name']}'),
                          if(data['Watermeter'] != null)
                            if(data['Watermeter'].isNotEmpty)
                              getFloatWidget(context: context, image: 'water_meter', value: '${data['Watermeter'][0]['Value']}', name: '${data['Watermeter'][0]['SW_Name'] ?? data['Watermeter'][0]['Name']}'),
                          if(data['SumpTankLow'] != null)
                            if(data['SumpTankLow'].isNotEmpty)
                              getFloatWidget(context: context, image: 'sump_low', value: '${data['SumpTankLow'][0]['Value']}', name: '${data['SumpTankLow'][0]['SW_Name'] ?? data['SumpTankLow'][0]['Name']}'),
                          if(data['SumpTankHigh'] != null)
                            if(data['SumpTankHigh'].isNotEmpty)
                              getFloatWidget(context: context, image: 'sump_high', value: '${data['SumpTankHigh'][0]['Value']}', name: '${data['SumpTankHigh'][0]['SW_Name'] ?? data['SumpTankHigh'][0]['Name']}'),
                          if(data['TopTankLow'] != null)
                            if(data['TopTankLow'].isNotEmpty)
                              getFloatWidget(context: context, image: 'tank_low', value: '${data['TopTankLow'][0]['Value']}', name: '${data['TopTankLow'][0]['SW_Name'] ?? data['TopTankLow'][0]['Name']}'),
                          if(data['TopTankHigh'] != null)
                            if(data['TopTankHigh'].isNotEmpty)
                              getFloatWidget(context: context, image: 'tank_high', value: '${data['TopTankHigh'][0]['Value']}', name: '${data['TopTankHigh'][0]['SW_Name'] ?? data['TopTankHigh'][0]['Name']}'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
          }
      );
    },
    child: Container(
      margin: EdgeInsets.only(right: 5,),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            child: Transform.scale(
              scale: 0.8,
              child: getTypesOfPump(mode: pumpMode, controller: controller, animationValue: animationValue,),
            ),
          ),
          if(data['OnOffReason'] != null && data['OnOffReason'] != '0')
            Positioned(
                right: 5,
                top: 10,
                child: Icon(Icons.info,color: Colors.orange,)
            ),
          if(data['Level'] != null)
            if(data['Level'].isNotEmpty)
              Positioned(
                  left: 5,
                  top: 20,
                  child: Container(
                    width: 10,
                    height: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade300
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 10,
                        height: 30*(double.parse(data['Level'][0]['Value'])/100),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue.shade300
                        ),
                      ),
                    ),
                  )
              ),
          if(data['Level'] != null)
            if(data['Level'].isNotEmpty)
              Positioned(
                  left: 2,
                  top: 2,
                  child: Text('${data['Level'][0]['Value']}%',style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
              ),
          Positioned(
              left: 2,
              bottom: 1,
              child: Text(pumpName,style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold),)
          ),
          if(delay != '00:00:00')
            Positioned(
                left: 30,
                top: 0,
                child: Container(
                    padding: EdgeInsets.all(2),
                    color: Colors.black,
                    child: Text(delay,style: TextStyle(fontSize: 9,fontWeight: FontWeight.bold,color: Colors.white),)
                )
            ),
        ],
      ),
    ),
  );
}

dynamic currentColor = {
  '1' : [Colors.redAccent.shade100, Colors.redAccent.shade200],
  '2' : [Colors.amber.shade100, Colors.amber.shade200],
  '3' : [Colors.blue.shade100, Colors.blue.shade200],
};

dynamic currentName = {
  '1' : 'RC',
  '2' : 'YC',
  '3' : 'BC',
};

Widget getTypesOfPump({required mode,required AnimationController controller,required double animationValue}){
  return AnimatedBuilder(
    animation: controller,
    builder: (BuildContext context, Widget? child) {
      return CustomPaint(
        painter: Pump(rotationAngle: [1].contains(mode)? animationValue : 0,mode: mode),
        size: const Size(100,80),
      );
    },
  );
}

int getWaterPipeStatus(BuildContext context,{int? selectedLine}){
  MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
  int mode = 0;
  if(payloadProvider.irrigationPump.any((element) => [1].contains(element['Status']))){
    mode = 1;
  }

  if(selectedLine != null){
    if(selectedLine != 0){
      dynamic pumpUsedInLine = payloadProvider.irrigationPump.where((element) => '${element['Location']}'.contains(payloadProvider.lineData[selectedLine]['id'])).toList();
      if(pumpUsedInLine.any((element) => [1].contains(element['Status']))){
        mode = 1;
      }else{
        mode = 0;
      }
    }
  }
  return mode;
}
String convertVersion(String version) {
  List<String> versionParts = version.split(',');

  Map<String, String> mapping = {'1': 'L', '2': 'G', '3': 'W'};

  List<String> updatedVersions = versionParts.map((v) {
    List<String> parts = v.split('.');
    parts[0] = mapping[parts[0]] ?? parts[0];
    return parts.join('.');
  }).toList();

  return updatedVersions.join(',');
}
int getWaterPipeStatusForSourcePump(BuildContext context){
  MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: false);
  int mode = 0;
  if(payloadProvider.sourcePump.any((element) => [1].contains(element['Status']))){
    mode = 1;
  }
  return mode;
}

Widget getActiveObjects({required BuildContext context,required bool active,required String title,required Function()? onTap,required int mode}){
  List<Color> gradient = active == true
      ? [Color(0xff22414C),Color(0xff294C5C)]
      : [];
  return  InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 5),
      height: (30 * getTextScaleFactor(context)).toDouble(),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(mode == 1 ? 4 : 0),
            bottomLeft: Radius.circular(mode == 1 ? 4 : 0),
            topRight: Radius.circular(mode == 2 ? 4 : 0),
            bottomRight: Radius.circular(mode == 2 ? 4 : 0),
          ),
          gradient:  active == true ? LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: gradient,
          ) : null,
          color: active == false ? Color(0xffECECEC) : null
      ),
      child: Center(child: Text(title,style: TextStyle(fontWeight: FontWeight.bold,color: active == true ? Colors.white : Colors.black),)),
    ),
  );
}

int getFilter(filterStatus,BuildContext context,programStatus){
  int mode = 0;
  if(filterStatus == 1){
    mode = 1;
  }else if(filterStatus == 2){
    mode = 2;
  }else if(getWaterPipeStatus(context) == 0){
    mode = 0;
  }else if(filterStatus == 0){
    mode = 3;
  }
  if(programStatus == ''){
    mode = 0;
  }
  return mode;
}

Widget getInfoBox(
    {
      required BuildContext context,
      required String title,
      required String value,
      required Color border,
      required Color fillColor,
      Color? circularColor,
      Icon? icon,
    }){
  return Container(
    width: MediaQuery.of(context).size.width / 3,
    height: 80,
    decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: customBoxShadow
      // border: Border.all(color: Colors.black,width: 0.3)
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if(circularColor != null)
          Container(
            margin: EdgeInsets.all(5),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: circularColor
            ),
            child: icon,
          ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(title,style: TextStyle(fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis),
              Text(value,overflow: TextOverflow.ellipsis,),
            ],
          ),
        ),
      ],
    ),
  );
}

String getImage(int code){
  if(code == 0){
    return 'b';
  }else if(code == 1){
    return 'g';
  }else if(code == 2){
    return 'o';
  }else{
    return 'r';
  }
}

getTextScaleFactor(context){
  return MediaQuery.of(context).textScaleFactor;
}

Widget getLineWidget({required BuildContext context,required AnimationController controller,required int selectedLine,required MqttPayloadProvider payloadProvider,required int currentLine}){
  var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
  int waterFlow = 0;
  for(var i in payloadProvider.currentSchedule){
    if(i['ProgCategory'].split('_').contains(payloadProvider.lineData[currentLine]['id'])){
      if(payloadProvider.irrigationPump.any((element) => [1].contains(element['Status']))){
        waterFlow = 1;
      }
      break;
    }
  }
  var joint = 'T_joint';
  if(payloadProvider.selectedLine != 0){
    joint = 'L_joint';
  }
  if(currentLine == payloadProvider.lineData.length - 1){
    joint = 'L_joint';
  }
  num item = 0;
  num screenSize = 0;
  var mainValve = payloadProvider.lineData[currentLine]['mainValve'].length;
  item += mainValve;
  var agitator = payloadProvider.lineData[currentLine]['agitator'].length;
  item += agitator;
  var valve = payloadProvider.lineData[currentLine]['valve'].length;
  // var valve = 20;
  item += valve;

  screenSize = MediaQuery.of(context).size.width - 75;
  var noWidgetInCalculatedWidth = screenSize ~/ 70;
  double calculatedHeight = 20;
  calculatedHeight += payloadProvider.lineData[currentLine]['pressureSensor'].length * 30;
  if(payloadProvider.lineData[currentLine]['waterMeter'] != null){
    calculatedHeight += payloadProvider.lineData[currentLine]['waterMeter'].length * 30;
  }
  if(payloadProvider.lineData[currentLine]['pressureSwitch'] != null){
    calculatedHeight += payloadProvider.lineData[currentLine]['pressureSwitch'].length * 30;
  }
  var pointValue = item~/noWidgetInCalculatedWidth;
  calculatedHeight += pointValue  * 70;

  if(pointValue < item/noWidgetInCalculatedWidth){
    calculatedHeight += 100;
  }


  return Container(
      padding: EdgeInsets.only(left: 8,right: 8),
      width: double.infinity,
      height: calculatedHeight.toDouble(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: calculatedHeight,
            child: Stack(
              children: [
                SizedBox(
                    width: 40,
                    height: joint == 'L_joint' ? calculatedHeight/2 : calculatedHeight.toDouble(),
                    child: verticalPipeTopFlow(count: (calculatedHeight~/100)+2, mode: getWaterPipeStatus(context,selectedLine: selectedLine), controller: controller,)
                ),
                Positioned(
                    top: calculatedHeight/2 + 8,
                    child: SizedBox(
                        width: 40,
                        height: 40,
                        child: horizontalPipeLeftFlow(count: 2,mode: waterFlow, controller: controller,)
                    )
                ),
                Positioned(
                  left: joint == 'L_joint' ? -1 : -3,
                  top: calculatedHeight/2 - (joint == 'L_joint' ? 2 : 0),
                  child: Transform.rotate(
                    angle: joint == 'L_joint' ? 3.14 : 4.71,
                    child: SizedBox(
                      width: 25 - (joint == 'L_joint' ? 5 : 0),
                      height: 25 - (joint == 'L_joint' ? 5 : 0),
                      child: SvgPicture.asset(
                        'assets/mob_dashboard/${joint}.svg',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.bottomCenter,
                    child: Text('${payloadProvider.lineData[currentLine]['name']} ${returnProgramName(payloadProvider: payloadProvider, currentLine: currentLine)}',style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff007988)
                    ),),
                    padding: EdgeInsets.all(2)
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: customBoxShadow
                  ),
                  padding: EdgeInsets.all(8),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runAlignment: WrapAlignment.spaceEvenly,
                    // runSpacing: 10,
                    // spacing: 10.0,
                    children: [

                      if(payloadProvider.lineData[currentLine]['waterMeter'].isNotEmpty || payloadProvider.lineData[currentLine]['pressureSwitch'].isNotEmpty ||payloadProvider.lineData[currentLine]['pressureSensor'].isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.only(bottom: 5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Column(
                            children: [
                              if(payloadProvider.lineData[currentLine]['pressureSwitch'].isNotEmpty)
                                getLineSensorWidget(
                                    context: context,
                                    image: 'assets/mob_dashboard/pressure_switch.png',
                                    name: '${payloadProvider.lineData[currentLine]['pressureSwitch'][0]['name']}',
                                    value: '${payloadProvider.lineData[currentLine]['pressureSwitch'][0]['value']}',
                                    unit: '${payloadProvider.lineData[currentLine]['pressureSwitch'][0]['value'] == 0 ? 'High' : ''}'
                                ),
                              if(payloadProvider.lineData[currentLine]['waterMeter'].isNotEmpty)
                                getLineSensorWidget(
                                    context: context,
                                    image: 'assets/mob_dashboard/water_meter.png',
                                    name: '${payloadProvider.lineData[currentLine]['waterMeter'][0]['name']}',
                                    // value: '${payloadProvider.lineData[currentLine]['waterMeter'][0]['value']}',
                                    value: '${getWaterMeterValue(payloadProvider.units[0]['value'].toString(), payloadProvider.lineData[currentLine]['waterMeter'][0]['value'].toString())}',
                                    unit: '${payloadProvider.units[0]['value']}'
                                ),
                              for(var ps in payloadProvider.lineData[currentLine]['pressureSensor'])
                                getLineSensorWidget(
                                    context: context,
                                    image: 'assets/mob_dashboard/pressure_sensor.png',
                                    name: '${ps['name']}',
                                    value: '${getPressureValue(payloadProvider.units[1]['value'].toString(), ps['value'].toString())}',
                                    unit: '${payloadProvider.units[1]['value']}'
                                ),
                            ],
                          ),
                        ),
                      for(var i = 0 ;i < mainValve;i++)
                        SizedBox(
                          width: 70,
                          height: 50,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 23,
                                height: 23,
                                child: Image.asset('assets/mob_dashboard/main_valve_${getImage(payloadProvider.lineData[currentLine]['mainValve'][i]['status'])}.png'),
                              ),
                              Text('${payloadProvider.lineData[currentLine]['mainValve'][i]['name']}',style: TextStyle(fontSize: 12,overflow: TextOverflow.ellipsis),)
                            ],
                          ),
                        ),
                      for(var i = 0 ;i < agitator;i++)
                        SizedBox(
                          width: 70,
                          height: 50,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 23,
                                height: 23,
                                child: SvgPicture.asset(
                                    'assets/mob_dashboard/agitator_${getImage(payloadProvider.lineData[currentLine]['agitator'][i]['status'])}.svg',
                                    semanticsLabel: 'Acme Logo'
                                ),
                              ),
                              Text('${payloadProvider.lineData[currentLine]['agitator'][i]['name']}',style: TextStyle(fontSize: 12,overflow: TextOverflow.ellipsis),)
                            ],
                          ),
                        ),
                      for(var i = 0 ;i < valve;i++)
                        GestureDetector(
                          onTap: ()async {
                            List<dynamic> moisture = payloadProvider.lineData[currentLine]['moistureSensor'];
                            String valveHid = payloadProvider.lineData[currentLine]['valve'][i]['hid'];
                            var getMoisture = moisture.where((ms)=> ms['valve'].contains(valveHid));
                            sideSheet(payloadProvider: payloadProvider, getMoisture: getMoisture, overAllPvd: overAllPvd, context: context);
                            // showDialog(
                            //     context: context,
                            //     builder: (context){
                            //       return AlertDialog(
                            //         content: MyFutureBuilderForSensorGraph(
                            //             futureData: getSensorHourlyLogs(overAllPvd.userId, overAllPvd.controllerId,payloadProvider),
                            //           listOfSerialNo: getMoistureSno,
                            //           sensorName: 'Moisture Sensor',
                            //         ),
                            //       );
                            //     }
                            // );
                          },
                          child: SizedBox(
                            width: 70,
                            height: 50,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 70,
                                  height: 20,
                                  child: Stack(
                                    children: [
                                      if(payloadProvider.lineData[currentLine]['moistureSensor'].any((e) =>e['valve'].toString().contains(payloadProvider.lineData[currentLine]['valve'][i]['hid'])))
                                        Positioned(
                                          right: 5,
                                          // top: 5,
                                          child: Container(
                                              width: 23,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Colors.green.shade50
                                              ),
                                              child: Center(
                                                child: SizedBox(
                                                    width: 15,
                                                    height: 15,
                                                    child: Image.asset('assets/mob_dashboard/moisture_sensor.png')
                                                ),
                                              )
                                          ),
                                        ),
                                      Positioned(
                                        left: 20,
                                        child: SizedBox(
                                          width: 23,
                                          height: 20,
                                          child: Image.asset('assets/mob_dashboard/valve_${getImage(payloadProvider.lineData[currentLine]['valve'][i]['status'])}.png'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text('${payloadProvider.lineData[currentLine]['valve'][i]['name']}',style: TextStyle(fontSize: 12,overflow: TextOverflow.ellipsis),)
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
  );
}

String getPressureValue(String unit,String value){
  if(unit == 'kPa'){
    return '${double.parse(value) * 100}';
  }else if(value.isNotEmpty){
    return '${double.parse(value).toStringAsFixed(2)}';
  }else{
    return value;
  }
}

String getWaterMeterValue(String unit,String? value){
  if(value == null){
    return value.toString();
  }
  else if(unit == 'm3/h'){
    return '${(double.parse(value) * 3.6).toStringAsFixed(2)}';
  }
  else{
    return value;
  }
}

String returnProgramName({
  required MqttPayloadProvider payloadProvider,
  required int currentLine
}){
  var programName = '';
  for(var i in payloadProvider.currentSchedule){
    if(i['ProgCategory'].contains(payloadProvider.lineData[currentLine]['id'])){
      programName = i['ProgName'];
    }
  }
  return programName != '' ? '($programName)' : programName;
}

dynamic getAlarmMessage = {
  1 : 'Low Flow',
  2 : 'High Flow',
  3 : 'No Flow',
  4 : 'Ec High',
  5 : 'Ph Low',
  6 : 'Ph High',
  7 : 'Pressure Low',
  8 : 'Pressure High',
  9 : 'No Power Supply',
  10 : 'No Communication',
  11 : 'Wrong Feedback',
  12 : 'Sump Tank Empty',
  13 : 'Top Tank Full',
  14 : 'Low Battery',
  15 : 'Ec Difference',
  16 : 'Ph Difference',
  17 : 'Pump Off Alarm',
  18 : 'Pressure Switch High',
};

dynamic pumpAlarmMessage = {
  '1' : 'sump empty',
  '2' : 'upper tank full',
  '3' : 'low voltage',
  '4' : 'high voltage',
  '5' : 'voltage SPP',
  '6' : 'reverse phase',
  '7' : 'starter trip',
  '8' : 'dry run',
  '9' : 'overload',
  '10' : 'current SPP',
  '11' : 'cyclic trip',
  '12' : 'maximum run time',
  '13' : 'sump empty',
  '14' : 'upper tank full',
  '15' : 'RTC 1',
  '16' : 'RTC 2',
  '17' : 'RTC 3',
  '18' : 'RTC 4',
  '19' : 'RTC 5',
  '20' : 'RTC 6',
  '21' : 'auto mobile key off',
  '22' : 'cyclic time',
  '23' : 'RTC 1',
  '24' : 'RTC 2',
  '25' : 'RTC 3',
  '26' : 'RTC 4',
  '27' : 'RTC 5',
  '28' : 'RTC 6',
  '29' : 'auto mobile key on',
  '30' : 'Power off',
  '31' : 'Power on',
};

class MarqueeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double containerWidth;
  final double containerHeight;

  MarqueeText({
    required this.text,
    required this.style,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
        )..layout(maxWidth: containerWidth);

        bool isOverflowing = textPainter.didExceedMaxLines;

        return SizedBox(
          width: containerWidth,
          height: containerHeight,
          child: Text(
            text,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

void sentUserOperationToServer(String msg,dynamic data,BuildContext context) async {
  var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
  Map<String, Object> body = {
    "userId": overAllPvd.getUserId(),
    "controllerId": overAllPvd.controllerId,
    "messageStatus": msg,
    "hardware" : data,
    "createUser": overAllPvd.getUserId(),
  };
  final response = await HttpService().postRequest("createUserSentAndReceivedMessageManually", body);
  if (response.statusCode == 200) {
  } else {
    throw Exception('Failed to load data');
  }
}

Widget findNestedLen({
  required data,
  required parentNo,
}) {
  List<Widget> list = [];
  if (data['Combined'].isEmpty) {
  } else {
    for (var i = 0;i < data['Combined'].length;i++) {
      list.add(
          findNestedLen(
            data: data['Combined'][i],
            parentNo: parentNo + 1,
          )
      );
    }
  }
  return Container(
    margin: EdgeInsets.only(bottom: 10),
    padding: EdgeInsets.only(left: 20,right : 5,top: 10,bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(width: 2,color:flowChatColor[parentNo].withOpacity(data['Status'] == 1 ? 1.0 : 0.2), ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Condition : ${data['S_No']}',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11),),
                SizedBox(width: 30,),
                Icon(Icons.notifications_active,size: 20,color: Color(0xff054750).withOpacity(data['Status'] == 1 ? 1 : 0.3))
              ],
            ),
            SizedBox(height: 3,),
            SizedBox(
                width: 150,
                child: Text('${data['Condition']}',style: TextStyle(fontSize: 10))
            ),
            SizedBox(height: 3,),
          ],
        ),
        ...list,
      ],
    ),
  );
}

Widget buildContainer({
  required String title,
  required String value,
  String? value2,
  required Color color1,
  required Color color2,
}) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color2, width: 0.3),
        boxShadow: [
          BoxShadow(
            color: color2.withOpacity(0.5),
            offset: const Offset(0, 0),
            // blurRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                // fontSize: 1,
              ),
            ),
            // SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if(value2 != null)
              Text(
              value2,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                // fontSize: 1,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget getFloatWidget({
  required BuildContext context,
  required String image,
  required String name,
  required String value,
}){
  return  Container(
    padding: EdgeInsets.all(5),
    width: MediaQuery.of(context).size.width * 0.3,
    decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: customBoxShadow,
        borderRadius: BorderRadius.circular(20)
    ),
    child: Column(
      children: [
        SizedBox(
            width: 40,
            height: 40,
            child: Image.asset('assets/mob_dashboard/$image.png')
        ),
        Text(name),
        Text(value),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    ),
  );
}

Icon getIcon(int value) {
  Color iconColor;
  IconData iconData;

  if (value >= 10 && value <= 30) {
    iconData = MdiIcons.signalCellular1;
    iconColor = Colors.red;
  } else if (value > 30 && value <= 70) {
    iconData = MdiIcons.signalCellular2;
    iconColor = Colors.orange;
  } else if (value > 70 && value <= 100) {
    iconData = MdiIcons.signalCellular3;
    iconColor = Colors.green;
  } else {
    iconData = MdiIcons.signalOff;
    iconColor = Colors.grey;
  }

  return Icon(iconData, color: iconColor);
}

dynamic flowChatColor = {
  0 : Colors.blue,
  1 : Colors.deepOrange,
  2 : Colors.green,
  3 : Colors.purple,
  4 : Colors.grey,
  5 : Colors.blue,
  6 : Colors.deepOrange,
  7 : Colors.green,
  8 : Colors.purple,
  9 : Colors.grey,
  10 : Colors.blue,
  11 : Colors.deepOrange,
  12 : Colors.green,
  13 : Colors.purple,
  14 : Colors.grey,
};

Widget getLineSensorWidget(
    {
      required BuildContext context,
      required String image,
      required String name,
      required String value,
      required String unit,
      Widget? extraParameter
    }){
  return SizedBox(
    height: 30,
    width : MediaQuery.of(context).size.width * 0.8,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 25,
              width: 25,
              child: Image.asset(image),
            ),
            SizedBox(width: 15,),
            Text(name,style: TextStyle(fontWeight: FontWeight.bold),),
          ],
        ),
        Text(value, style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),
        Text(unit, style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.normal),),
      ],
    ),
  );
}

void sideSheet({
  required MqttPayloadProvider payloadProvider,
  required getMoisture,
  required OverAllUse overAllPvd,
  required BuildContext context,
}) {
  print('getMoisture : $getMoisture');
  var listOfSerialNumber = getMoisture.map((ms) => ms['sNo']).toList();
  var listOfName = getMoisture.map((ms) => '${ms['name']} (${ms['high/low']})').toList();

  (getMoisture.map((ms) => ms['sNo']).toList());
  showGeneralDialog(
    barrierLabel: "Side sheet",
    barrierDismissible: true,
    transitionDuration: const Duration(milliseconds: 300),
    context: context,
    pageBuilder: (context, animation1, animation2) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          elevation: 15,
          color: Colors.transparent,
          borderRadius: BorderRadius.zero,
          child: Scaffold(
            floatingActionButton: InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.keyboard_double_arrow_left),
                  Text('Go Back'),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            body: Container(
              padding: const EdgeInsets.all(3),
              // margin: EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.zero,
              ),
              height: MediaQuery.of(context).size.height,
              width:  MediaQuery.of(context).size.width,
              child: MyFutureBuilderForSensorGraph(
                futureData: getSensorHourlyLogs(overAllPvd.userId, overAllPvd.controllerId,payloadProvider),
                listOfSerialNo: listOfSerialNumber,
                listOfName: listOfName,
                sensorName: 'Moisture Sensor',
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation1, animation2, child) {
      return SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(animation1),
        child: child,
      );
    },
  );
}
class SensorChart {
  final String hour;
  final double value;

  SensorChart({required this.hour, required this.value});
}

Future<dynamic> getSensorHourlyLogs(userId, controllerId, MqttPayloadProvider payloadProvider) async {
  if(payloadProvider.sensorLogData.isEmpty){
    print('getSensorHourlyLogs called...................');
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Map<String, Object> body = {
      "userId": userId,
      "controllerId": controllerId,
      "fromDate": date,
      "toDate": date
    };
    final response = await HttpService().postRequest("getUserSensorHourlyLog", body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data["code"] == 200) {
        try {
          payloadProvider.editSensorLogData(data['data']);
          return data['data'];
        } catch (e) {
          print('Error on sensorLogData: $e');
        }
      }
    }
  }else{
    return payloadProvider.sensorLogData;
  }

}
class MyFutureBuilderForSensorGraph extends StatelessWidget {
  final Future<dynamic> futureData;
  final List<dynamic> listOfSerialNo;
  final List<dynamic> listOfName;
  final String sensorName;

  const MyFutureBuilderForSensorGraph({super.key, required this.futureData, required this.listOfSerialNo, required this.sensorName, required this.listOfName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureData,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20,),
                Text('Loading......')
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var particularSensorData = snapshot.data!.where((sensor) => sensor['name'] == sensorName).toList();
            particularSensorData = particularSensorData[0]['data'];
            print('particularSensorData :: ${particularSensorData}');
            List<List<SensorChart>> graphList = [];
            print('listOfSerialNo :: $listOfSerialNo');
            for(var sNo = 0;sNo < listOfSerialNo.length;sNo++){
              graphList.add([]);
              for(var hourKey in particularSensorData.keys){
                for(var hourKeyValue in particularSensorData[hourKey]){
                  if(hourKeyValue['S_No'] == listOfSerialNo[sNo]){
                    graphList[sNo].add(SensorChart(hour: hourKey, value: double.parse(hourKeyValue['Value'])));
                  }
                }
              }
            }
            print('graphList :: $graphList');
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 50,),
                  // for(var sd = 0;sd < graphList.length;sd++)
                  //   SensorGraph(list: graphList[sd], sensorName: listOfName[sd],)
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        }
    );
  }

}