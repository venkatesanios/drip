import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:oro_drip_irrigation/services/mqtt_manager_mobile.dart' if (dart.library.html) 'package:oro_drip_irrigation/services/mqtt_manager_web.dart';
import 'package:provider/provider.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import '../../StateManagement/overall_use.dart';
import '../../Widgets/blinking_container.dart';
import '../NewIrrigationProgram/irrigation_program_main.dart';
import '../NewIrrigationProgram/preview_screen.dart';
import '../NewIrrigationProgram/schedule_screen.dart';

class ScheduleProgramForMobile extends StatefulWidget {
  final int selectedLine;
  final MqttManager manager;
  final String deviceId;
  final int userId;
  final int controllerId;
  const ScheduleProgramForMobile({super.key, required this.manager, required this.deviceId, required this.selectedLine, required this.userId, required this.controllerId});

  @override
  State<ScheduleProgramForMobile> createState() => _ScheduleProgramForMobileState();
}

class _ScheduleProgramForMobileState extends State<ScheduleProgramForMobile> {
  String currentZone = '';
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
  @override
  Widget build(BuildContext context) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context,listen: true);
    var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    return  Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(height: 40,),
        Text('List Of Program',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
        SizedBox(height: 20,),
        if(payloadProvider.upcomingProgram.isNotEmpty)
          for(var program in payloadProvider.upcomingProgram)
            if(['All',program['IrrigationLine']].contains(payloadProvider.lineData[widget.selectedLine]['id']))
              Container(
                margin: EdgeInsets.only(bottom: 20,left: 10,right: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: customBoxShadow
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Center(
                          child: Text(program['ProgName'].isNotEmpty ? program['ProgName'].substring(0, 1).toUpperCase() : '',style: TextStyle(color: Colors.white),),
                        ),
                      ),
                      title: Text(program['ProgName'],style: TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Text('${programSchedule[program['SchedulingMethod']]}',style: TextStyle(color: Theme.of(context).primaryColor,overflow: TextOverflow.ellipsis),),
                      trailing: Text('${program['TotalZone']} Zones',style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold,fontSize: 14),),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.grey.shade200,
                            value: (program['ProgramStatusPercentage']/100).toDouble(),
                            color: Colors.green,
                          ),
                        ),
                        Text('  ${program['ProgramStatusPercentage']} %'),
                      ],
                    ),
                    SizedBox(height: 5,),
                    if(program['StartCondition'].isNotEmpty || program['StopCondition'].isNotEmpty)
                      Column(
                        children: [
                          SizedBox(height: 5,),
                          for(var condition in ['StartCondition','StopCondition'])
                            if(program[condition] != null && program[condition].isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${condition.contains('Start') ? 'Start' : 'Stop'} Condition Details',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                                  InkWell(
                                    onTap: (){
                                      int index = payloadProvider.upcomingProgram.indexOf(program);
                                      showDialog(context: context, builder: (context){
                                        return Consumer<MqttPayloadProvider>(builder: (context,payloadProvider,child){
                                          dynamic program = payloadProvider.upcomingProgram[index];
                                          return AlertDialog(
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('${condition.contains('Start') ? 'Start' : 'Stop'} Condition'),
                                                IconButton(
                                                    onPressed: (){
                                                      Navigator.pop(context);
                                                    }, icon: Icon(Icons.cancel,color: Colors.red,)
                                                )
                                              ],
                                            ),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        findNestedLen(
                                                            data: program[condition],
                                                            parentNo: 0
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // actions: [
                                            //   TextButton(
                                            //       onPressed: (){
                                            //         Navigator.pop(context);
                                            //       },
                                            //       child: Text('Ok')
                                            //   )
                                            // ],
                                          );
                                        });
                                      });
                                    },
                                    child: BlinkingContainer(child: getViewButton(),),
                                  ),
                                ],
                              ),
                          SizedBox(height: 5,),
                        ],
                      ),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_month,color: Colors.black,),
                              SizedBox(width: 10,),
                              Text('Start Date to End Date',style: TextStyle(color: Colors.black),)
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('${program['StartDate']}',style: TextStyle(color: Colors.black,),),
                              Text('to',style: TextStyle(color: Colors.black),),
                              Text('${program['EndDate']}',style: TextStyle(color: Colors.black,),),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Text('${program['StartTime'] == '-' ? 'No Schedule' : 'Start Time : ${program['StartTime']}'}',style: TextStyle(color: Colors.pink),),
                          SizedBox(height: 5,),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Stop Reason',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
                        Text('  ${programStartStopReason(code: program['StartStopReason'])}',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pause Resume Reason',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
                        Text('  ${programStartStopReason(code: program['PauseResumeReason'])}',style: TextStyle(color: Theme.of(context).primaryColor,fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 5,),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if(overAllPvd.takeSharedUserId ?  (payloadProvider.userPermission[0]['status'] || payloadProvider.userPermission[2]['status']) : true)
                              InkWell(
                                // onTap: DashboardPayloadHandler(manager: widget.manager, payloadProvider: payloadProvider, overAllPvd: overAllPvd, setState: setState, context: context,index: payloadProvider.upcomingProgram.indexOf(program)).programStartStop,
                                // onTap:()async{
                                //   if(int.parse(program['ProgOnOff']) >= 0){
                                //     if(program['startStopCode'] == null){
                                //       String payload = '${program['SNo']},${program['ProgOnOff']}';
                                //       String payLoadFinal = jsonEncode({
                                //         "2900": [{"2901": payload}]
                                //       });
                                //       widget.manager.publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                //       sentUserOperationToServer('${program['ProgName']} ${programOnOff[program['ProgOnOff']]}', payLoadFinal,context);
                                //       setState(() {
                                //         program['startStopCode'] = true;
                                //         payloadProvider.messageFromHw = '';
                                //       });
                                //       for(var seconds = 0;seconds < 8;seconds++){
                                //         await Future.delayed(Duration(seconds: 1));
                                //         if(payloadProvider.messageFromHw != ''){
                                //           stayAlert(context: context, payloadProvider: payloadProvider, message: 'Hardware recieved successfully');
                                //           break;
                                //         }
                                //         if(seconds == 7){
                                //           setState(() {
                                //             program.remove('startStopCode');
                                //           });
                                //         }
                                //       }
                                //       Future.delayed(Duration(seconds: 8),(){
                                //         setState(() {
                                //           program.remove('startStopCode');
                                //         });
                                //       });
                                //     }
                                //   }
                                // },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: programOnOffColor[program['ProgOnOff']],
                                  ),
                                  child:program['startStopCode'] == null
                                      ? Text('${programOnOff[program['ProgOnOff']]}',style: TextStyle(color: Colors.white),)
                                      : loadingButton(),
                                ),
                              ),
                            SizedBox(width: 10,),
                            if(overAllPvd.takeSharedUserId ?  (payloadProvider.userPermission[0]['status'] || payloadProvider.userPermission[1]['status']) : true)
                              InkWell(
                                // onTap: DashboardPayloadHandler(manager: widget.manager, payloadProvider: payloadProvider, overAllPvd: overAllPvd, setState: setState, context: context,index: payloadProvider.upcomingProgram.indexOf(program)).programPauseResume,
                                // onTap:()async{
                                //   if(program['pauseResumeCode'] == null){
                                //     String payload = '${program['SNo']},${program['ProgPauseResume']}';
                                //     String payLoadFinal = jsonEncode({
                                //       "2900": [{"2901": payload}]
                                //     });
                                //     widget.manager.publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                //     sentUserOperationToServer('${program['ProgName']} ${program['ProgPauseResume'] != '1' ? 'Pause' : 'Resume'} by Manual', payLoadFinal,context);
                                //   }
                                //   setState(() {
                                //     program['pauseResumeCode'] = true;
                                //     payloadProvider.messageFromHw = '';
                                //   });
                                //   for(var seconds = 0;seconds < 8;seconds++){
                                //     await Future.delayed(Duration(seconds: 1));
                                //     if(payloadProvider.messageFromHw != ''){
                                //       stayAlert(context: context, payloadProvider: payloadProvider,message: 'Hardware recieved successfully');
                                //       break;
                                //     }
                                //     if(seconds == 7){
                                //       setState(() {
                                //         program.remove('pauseResumeCode');
                                //       });
                                //     }
                                //   }
                                // },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: programOnOffColor[program['ProgPauseResume']],
                                  ),
                                  child : program['pauseResumeCode'] == null ? Text('${program['ProgPauseResume'] == '2' ? 'Pause' : 'Resume'}',style: TextStyle(color:Colors.black),)
                                      : loadingButton(),
                                ),
                              ),
                          ],
                        ),
                        if(overAllPvd.takeSharedUserId ?  (payloadProvider.userPermission[0]['status'] || payloadProvider.userPermission[8]['status']) : true)
                          InkWell(
                            onTap:()async{
                              var overAllPvd = Provider.of<OverAllUse>(context,listen: false);

                              String prgType = '';
                              bool conditionL = false;
                              if(program['IrrigationLine'].contains('IL')){
                                prgType='Irrigation Program';
                              }else{
                                prgType='Agitator Program';
                              }
                              if((!overAllPvd.takeSharedUserId ? payloadProvider.listOfSite[payloadProvider.selectedSite]['master'][payloadProvider.selectedMaster]['conditionLibraryCount'] : payloadProvider.listOfSharedUser['devices'][payloadProvider.selectedMaster]['conditionLibraryCount']) > 0 ){
                                conditionL = true;
                              }
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(builder: (BuildContext context) {
                              //       return IrrigationProgram(userId: widget.userId, controllerId: widget.controllerId, serialNumber: program['SNo'], deviceId: widget.deviceId,programType: prgType,conditionsLibraryIsNotEmpty: conditionL, fromDealer: false,);
                              //     })
                              // );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).primaryColor,
                              ),
                              child : Text('Edit',style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        if(program.containsKey('ZoneList') && program['ZoneList'] != null)
                          if(overAllPvd.takeSharedUserId ?  (payloadProvider.userPermission[0]['status'] || payloadProvider.userPermission[1]['status']) : true)
                            if(program['ZoneList'].split('_').isNotEmpty)
                              InkWell(
                                onTap:() async{
                                  if(!program['ZoneList'].split('_').contains(currentZone)){
                                    setState(() {
                                      currentZone = program['ZoneList'].split('_')[0];
                                    });
                                  }
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(builder: (context,stateSetter){
                                          return AlertDialog(
                                            title: Text('Change To'),
                                            content: ListTile(
                                              title: Text('Select Zone'),
                                              trailing: IntrinsicWidth(
                                                child: DropdownButton<String>(
                                                  value: currentZone,
                                                  onChanged: (value) {
                                                    stateSetter((){
                                                      setState(() {
                                                        currentZone = value.toString();
                                                      });
                                                    });
                                                  },
                                                  items: program['ZoneList']
                                                      .split('_')
                                                      .map<DropdownMenuItem<String>>((e) {
                                                    return DropdownMenuItem<String>(
                                                      value: e,
                                                      child: Text(e),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: (){
                                                    // DashboardPayloadHandler(manager: widget.manager, payloadProvider: payloadProvider, overAllPvd: overAllPvd, setState: setState, context: context,index: payloadProvider.upcomingProgram.indexOf(program)).sequenceChangeTo(currentZone);
                                                  },
                                                  child: Text('Ok')
                                              )
                                            ],
                                          );
                                        });
                                      }
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child : Icon(Icons.change_circle, color: Colors.white,),
                                ),
                              ),
                      ],
                    ),
                    SizedBox(height: 5,),
                  ],
                ),
              ),
        SizedBox(height: 50,),

      ],
    );
  }
  Widget findNestedLen({
    required data,
    required parentNo,
  })
  {
    List<Widget> list = [];
    if (data['Combined'].isEmpty) {
    } else
    {
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
  Widget getViewButton(){
    return Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Color(0xff69BCFC),

        ),
        child: Text('View',style: TextStyle(color: Colors.yellowAccent,fontWeight: FontWeight.bold),)
    );
  }
}

Map<int,String> programSchedule = {
  1 : 'No Schedule',
  2 : 'Schedule by Days',
  3 : 'Schedule as Run List',
  4 : 'Day Count RTC'
};

dynamic programOnOff = {
  '-1' : 'PausedCouldntStart',
  '1' : 'StartManually',
  '-2' : 'StartedByConditionCouldntStop',
  '7' : 'StopManually',
  '13' : 'ByPassStartCondition',
  '11' : 'ByPassCondition',
  '12' : 'BypassStopConditionAndStart',
  '0' : 'StopManually',
  '2' : 'Pause',
  '3' : 'Resume',
  '4' : 'ContinueManually',
  '-3' : 'StartedByRtcCouldntStop',
};

dynamic programOnOffColor = {
  '-1' : Colors.grey.shade200,
  '1' : Colors.green,
  '-2' : Colors.grey.shade200,
  '7' : Colors.red,
  '13' : Colors.green,
  '11' : Colors.green,
  '12' : Colors.red,
  '0' : Colors.red,
  '2' : Colors.orange,
  '3' : Colors.yellow,
  '4' : Colors.green,
  '-3' : Colors.grey.shade200,
};

String programStartStopReason({required int code}){
  switch(code){
    case (1):
      return 'Running As Per Schedule';
    case (2):
      return 'Turned On Manually';
    case (3):
      return 'Started By Condition';
    case (4):
      return 'TurnedOff Manually';
    case (5):
      return 'Program TurnedOff';
    case (6):
      return 'Zone TurnedOff';
    case (7):
      return 'Stopped By Condition';
    case (8):
      return 'Disabled By Condition';
    case (9):
      return 'StandAlone Program Started';
    case (10):
      return 'StandAlone Program Stopped';
    case (11):
      return 'StandAlone Program Stopped After SetValue';
    case (12):
      return 'Stand Alone Manual Started';
    case (13):
      return 'StandAlone Manual Stopped';
    case (14):
      return 'StandAlone Manual Stopped AfterSetValue';
    case (15):
      return 'Started By Day CountRtc';
    case (16):
      return 'Paused By User';
    case (17):
      return 'Manually Started Paused By User';
    case (18):
      return 'Program Deleted';
    case (19):
      return 'Program Ready';
    case (20):
      return 'Program Completed';
    case (21):
      return 'Resumed By User';
    case (22):
      return 'Paused By Condition';
    case (23):
      return 'Program Ready And Run By Condition';
    case (24):
      return 'Running As PerSchedule And Condition';
    case (25):
      return 'Started B yCondition Paused By User';
    case (26):
      return 'Resumed By Condition';
    case (27):
      return 'Bypassed Start ConditionManually';
    case (28):
      return 'Bypassed Stop ConditionManually';
    case (29):
      return 'Continue Manually';
    case (30):
      return '-';
    case (31):
      return 'Program Completed';
    case (32):
      return 'Waiting For Condition';
    case (33):
      return 'Started By Condition And Run As Per Schedule';
    default:
      return 'code : $code';
  }
}

Widget loadingButton(){
  return SizedBox(
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