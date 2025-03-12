import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/Screens/NewIrrigationProgram/selection_screen.dart';
import 'package:provider/provider.dart';

import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../services/mqtt_service.dart';
import '../../utils/constants.dart';
import '../../utils/snack_bar.dart';


class ScheduledProgram extends StatelessWidget {
  const ScheduledProgram({super.key, required this.userId, required this.scheduledPrograms, required this.masterInx, required this.deviceId});
  final int userId, masterInx;
  final String deviceId;
  final List<ProgramList> scheduledPrograms;

  @override
  Widget build(BuildContext context) {

    print("call schedule program ");
    print("call schedule program ");

    final spLive = Provider.of<MqttPayloadProvider>(context).scheduledProgram;
    if(spLive.isNotEmpty){
      for(var sp in spLive){
        List<String> values = sp.split(",");
        int index = scheduledPrograms.indexWhere((program) => program.serialNumber == int.parse(values[0]));
        scheduledPrograms[index].startDate = values[3];
        scheduledPrograms[index].startTime = values[4];
        scheduledPrograms[index].endDate = values[5];
        scheduledPrograms[index].programStatusPercentage = int.parse(values[6]);
        scheduledPrograms[index].startStopReason = int.parse(values[7]);
        scheduledPrograms[index].pauseResumeReason = int.parse(values[8]);
        scheduledPrograms[index].prgOnOff = values[10];
        scheduledPrograms[index].prgPauseResume = values[11];
      }
    }
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              SizedBox(height: 50),
              Container(
                height: 30,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Schedule Program List',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Expanded(
                child: ListView.builder(
                  itemCount: scheduledPrograms.length,
                  itemBuilder: (context, index) {
                    return ProgramCard(context, scheduledPrograms[index]);
                   },
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
       ),
    );
  }

  void updateProgramById(int id, ProgramList updatedProgram) {
    int index = scheduledPrograms.indexWhere((program) => program.serialNumber == id);
    if (index != -1) {
      scheduledPrograms[index] = updatedProgram;
    } else {
      print("Program with ID $id not found");
    }
  }

  String changeDateFormat(String dateString) {
    if(dateString!='-'){
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(date);
    }else{
      return '-';
    }
  }

  String convert24HourTo12Hour(String timeString) {
    if(timeString=='-'){
      return '-';
    }
    final parsedTime = DateFormat('HH:mm:ss').parse(timeString);
    final formattedTime = DateFormat('hh:mm a').format(parsedTime);
    return formattedTime;
  }

  String getSchedulingMethodName(int code) {
    switch (code) {
      case 1:
        return 'No Schedule';
      case 2:
        return 'Schedule by days';
      case 3:
        return 'Schedule as run list';
      default:
        return 'Day count schedule';
    }
  }

  String getButtonName(int code) {
    const Map<int, String> codeDescriptionMap = {
      -1: 'Paused Couldn\'t',
      1: 'Start Manually',
      -2: 'Cond Couldn\'t',
      -3: 'Started By Rtc',
      7: 'Stop Manually',
      13: 'Bypass Start',
      11: 'Bypass Cond',
      12: 'Bypass Stop',
      0: 'Stop Manually',
      2: 'Pause',
      3: 'Resume',
      4: 'Cont Manually',
    };
    return codeDescriptionMap[code] ?? 'Code not found';
  }

  String getDescription(int code) {
    const Map<int, String> codeDescriptionMap = {
      -1: 'Paused Couldn\'t Start',
      1: 'Start Manually',
      -2: 'Started By Condition Couldn\'t Stop',
      -3: 'Started By Rtc Couldn\'t Stop',
      7: 'Stop Manually',
      13: 'Bypass Start Condition',
      11: 'Bypass Condition',
      12: 'Bypass Stop Condition and Start',
      0: 'Stop Manually',
      2: 'Pause',
      3: 'Resume',
      4: 'Continue Manually',
    };
    return codeDescriptionMap[code] ?? 'Code not found';
  }

  void showAutoUpdateDialog(BuildContext context, int prmSNo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container();
        /*return ConditionDialog(
          prmSNo: prmSNo,
        );*/
      },
    );
  }

  String getContentByCode(int code) {
    return GemProgramStartStopReasonCode.fromCode(code).content;
  }

  void sentUserOperationToServer(String msg, String data) async
  {
    /*Map<String, Object> body = {"userId": siteData.customerId, "controllerId": siteData.master[masterInx].controllerId, "messageStatus": msg, "hardware": jsonDecode(data), "createUser": userId};
    final response = await HttpService().postRequest("createUserSentAndReceivedMessageManually", body);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }*/
  }

  bool getPermissionStatusBySNo(BuildContext context, int sNo) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    final permission = payloadProvider.userPermission.firstWhere(
          (element) => element['sNo'] == sNo,
      orElse: () => null,
    );
    return permission?['status'] as bool? ?? true;
  }
  Widget ProgramCard(BuildContext context,ProgramList program) {
    String buttonName = getButtonName(int.parse(program.prgOnOff));
    bool isStop = buttonName.contains('Stop');
    bool isBypass = buttonName.contains('Bypass');
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, spreadRadius: 1, blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(0),
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(program.programName[0].toUpperCase(), style: TextStyle(color: Colors.white)),
            ),
            title: Text(program.programName, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${program.schedulingMethod}', style: TextStyle(color: Colors.blue)),
            trailing: Text('${program.sequence.length} Zones', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: program.programStatusPercentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: Colors.green,
                ),
              ),
              Text('  ${program.programStatusPercentage} %'),
            ],
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3), // Color with opacity of 50%
              borderRadius: BorderRadius.circular(15), // Rounded corners with radius of 15
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('Start Date: ${changeDateFormat(program.startDate)} - End Date: ${program.endDate}', style: TextStyle(color: Colors.black)),
                  SizedBox(height: 5),
                  Center(child: Text('Start Time: ${program.startTime}', style: TextStyle(color: Colors.pink))),
                ],
              ),
            ),
          ),
          // SizedBox(height: 10),
          // Text('Start Condition: ${program}', style: TextStyle(color: Colors.black)),
          // Text('Stop Condition: ${program}', style: TextStyle(color: Colors.black)),
          SizedBox(height: 10),
          Text('Start/Stop Reason:', style: TextStyle(color: Colors.red)),
          Text('${program.startStopReason}', style: TextStyle(color: Colors.black)),
          Text('Pause/Resume Reason:', style: TextStyle(color: Colors.red)),
          Text('${program.pauseResumeReason}', style: TextStyle(color: Colors.black)),
          SizedBox(height: 20),
       /*   Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(120, 30),),
                onPressed: () {
                  // Start/Stop action
                },
                child: Text('Start Manually',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Pause/Resume action
                },
                child: Text('Pause',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style:  ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: Size(80, 30),),
              ),
              ElevatedButton(
                onPressed: () {
                  // Pause/Resume action
                },
                child: Text('Resume',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

                style:  ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: Size(80, 30),),
              ),
              ElevatedButton(
                onPressed: () {
                  // Pause/Resume action
                },
                child: Text('Edit',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style:  ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColorDark,
                  minimumSize: Size(70, 30),),

              ),
              ElevatedButton(
                onPressed: () {
                  // Pause/Resume action
                },
                child : Icon(Icons.change_circle, color: Colors.white,),
                style:  ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColorDark,

                  minimumSize: Size(50, 30),),
              ),
            ],
          ),*/
          Row(
            children: [
              Tooltip(
                message: getDescription(int.parse(program.prgOnOff)),
                child: MaterialButton(
                  color: int.parse(program.prgOnOff) >= 0? isStop?Colors.red: isBypass?Colors.orange :Colors.green : Colors.grey.shade300,
                  textColor: Colors.white,
                  onPressed: () {

                    if(getPermissionStatusBySNo(context, 3)){
                      if (int.parse(program.prgOnOff) >= 0) {
                        String payload = '${program.serialNumber},${program.prgOnOff}';
                        String payLoadFinal = jsonEncode({
                          "2900": {"2901": payload}
                        });
                        MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                        sentUserOperationToServer(
                          '${program.programName} ${getDescription(int.parse(program.prgOnOff))}',
                          payLoadFinal,
                        );
                      }
                    }else{
                      GlobalSnackBar.show(context, 'Permission denied', 400);
                    }
                  },
                  child: Text(
                    buttonName,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              MaterialButton(
                color: getButtonName(int.parse(program.prgPauseResume)) == 'Pause' ? Colors.orange : Colors.yellow,
                textColor: getButtonName(int.parse(program.prgPauseResume)) == 'Pause' ? Colors.white : Colors.black,
                onPressed: () {
                  if(getPermissionStatusBySNo(context, 3)){
                    String payload = '${program.serialNumber},${program.prgPauseResume}';
                    String payLoadFinal = jsonEncode({
                      "2900": {"2901": payload}
                    });
                    MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                    sentUserOperationToServer(
                      '${program.programName} ${getDescription(int.parse(program.prgPauseResume))}',
                      payLoadFinal,
                    );
                  }else{
                    GlobalSnackBar.show(context, 'Permission denied', 400);
                  }

                },
                child: Text(getButtonName(int.parse(program.prgPauseResume))),
              ),
              const Spacer(),
              getPermissionStatusBySNo(context, 3) ?PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String result) {
                  if(result=='Edit program'){
                    String prgType = '';
                    bool conditionL = false;
                    if (program.prgCategory.contains('IL')) {
                      prgType = 'Irrigation Program';
                    } else {
                      prgType = 'Agitator Program';
                    }
                    /*if (siteData.master[masterInx].conditionLibraryCount > 0) {
                                      conditionL = true;
                                    }*/
                    /* Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => IrrigationProgram(
                                          deviceId: siteData.master[masterInx].deviceId,
                                          userId: siteData.customerId,
                                          controllerId: siteData.master[masterInx].controllerId,
                                          serialNumber: scheduledPrograms[index].sNo,
                                          programType: prgType,
                                          conditionsLibraryIsNotEmpty: conditionL,
                                        ),
                                      ),
                                    );*/
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Edit program',
                    child: Text('Edit program'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Change to',
                    child: ClickableSubmenu(
                      title: 'Change to',
                      submenuItems: program.sequence,
                      onItemSelected: (selectedItem, selectedIndex) {
                        String payload = '${program.serialNumber},${selectedIndex+1}';
                        String payLoadFinal = jsonEncode({
                          "6700": {"6701": payload}
                        });
                        MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                        sentUserOperationToServer(
                          '${program.programName} ${'Changed to $selectedItem'}',
                          payLoadFinal,
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ):
              const IconButton(onPressed: null, icon: Icon(Icons.more_vert, color: Colors.grey,)),
            ],
          )
        ],
      ),
    );
  }
}

class ClickableSubmenu extends StatelessWidget {
  final String title;
  final List<Sequence> submenuItems;
  final Function(String selectedItem, int selectedIndex) onItemSelected;

  const ClickableSubmenu({super.key,
    required this.title,
    required this.submenuItems,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showSubmenu(context);
      },
      child: Row(
        children: [
          Text(title),
          const Icon(Icons.arrow_right),
        ],
      ),
    );
  }



  void _showSubmenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(button.size.width, 0), ancestor: overlay),
        button.localToGlobal(Offset(button.size.width, button.size.height), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      items: submenuItems.map((Sequence item) {
        return PopupMenuItem<String>(
          value: item.name, // Ensure unique values
          child: Text(item.name),
        );
      }).toList(),
    ).then((String? selectedItem) {
      if (selectedItem != null) {
        int selectedIndex = submenuItems.indexWhere((item) => item.name == selectedItem);

        // Ensure selectedItem exists before calling callback
        if (selectedIndex != -1) {
          onItemSelected(selectedItem, selectedIndex);
        }
      }
    });
  }
}






