import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../Models/customer/site_model.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../services/mqtt_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/snack_bar.dart';

class ScheduledProgram extends StatelessWidget {
  const ScheduledProgram({super.key, required this.userId, required this.scheduledPrograms, required this.masterInx, required this.deviceId});
  final int userId, masterInx;
  final String deviceId;
  final List<ProgramList> scheduledPrograms;

  @override
  Widget build(BuildContext context) {

    final spLive = Provider.of<MqttPayloadProvider>(context).scheduledProgram;
    if(spLive.isNotEmpty){
      for(var sp in spLive){
        List<String> values = sp.split(",");
        if(values.length>1){
          int index = scheduledPrograms.indexWhere((program) => program.serialNumber == int.parse(values[0]));
          scheduledPrograms[index].startDate = values[3];
          scheduledPrograms[index].startTime = values[4];
          scheduledPrograms[index].endDate = values[5];
          scheduledPrograms[index].programStatusPercentage = int.parse(values[6]);
          scheduledPrograms[index].startStopReason = int.parse(values[7]);
          scheduledPrograms[index].pauseResumeReason = int.parse(values[8]);
          scheduledPrograms[index].prgOnOff = values[10];
          scheduledPrograms[index].prgPauseResume = values[11];
          scheduledPrograms[index].status = 1;
        }

      }
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 3, bottom: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 0.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  height: (scheduledPrograms.length * 45) + 45,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 1000,
                      dataRowHeight: 45.0,
                      headingRowHeight: 40.0,
                      headingRowColor: WidgetStateProperty.all<Color>(Colors.yellow.shade50),
                      columns:  const [
                        DataColumn2(
                          label: Text('Line Id', style: TextStyle(fontSize: 13),),
                          fixedWidth: 50,
                        ),
                        DataColumn2(
                          label: Text('Name', style: TextStyle(fontSize: 13),),
                          size: ColumnSize.M,
                        ),
                        DataColumn2(
                          label: Text('Method', style: TextStyle(fontSize: 13)),
                          size: ColumnSize.M,
                        ),
                        DataColumn2(
                          label: Text('Status or Reason', style: TextStyle(fontSize: 13)),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Center(child: Text('Zone', style: TextStyle(fontSize: 13),)),
                          fixedWidth: 50,
                        ),
                        DataColumn2(
                          label: Center(child: Text('Start Date & Time', style: TextStyle(fontSize: 13),)),
                          size: ColumnSize.M,
                        ),
                        DataColumn2(
                          label: Center(child: Text('End Date', style: TextStyle(fontSize: 13),)),
                          size: ColumnSize.S,
                        ),
                        DataColumn2(
                          label: Text(''),
                          fixedWidth: 265,
                        ),
                      ],
                      rows: List<DataRow>.generate(scheduledPrograms.length, (index) {
                        String buttonName = getButtonName(int.parse(scheduledPrograms[index].prgOnOff));
                        bool isStop = buttonName.contains('Stop');
                        bool isBypass = buttonName.contains('Bypass');

                        return DataRow(cells: [
                          DataCell(Text(scheduledPrograms[index].prgCategory)),
                          DataCell(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(scheduledPrograms[index].programName),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: scheduledPrograms[index].programStatusPercentage / 100.0,
                                      borderRadius: const BorderRadius.all(Radius.circular(3)),
                                      color: Colors.blue.shade300,
                                      backgroundColor: Colors.grey.shade200,
                                      minHeight: 2.5,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    '${scheduledPrograms[index].programStatusPercentage}%',
                                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                                  ),
                                ],
                              ),
                            ],
                          )),
                          DataCell(Text(getSchedulingMethodName(scheduledPrograms[index].schedulingMethod))),
                          DataCell(Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Start Stop: ',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                          TextSpan(
                                            text: getContentByCode(scheduledPrograms[index].startStopReason),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    scheduledPrograms[index].pauseResumeReason!=30?RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Pause Resume: ',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                            ),
                                          ),
                                          TextSpan(
                                            text: getContentByCode(scheduledPrograms[index].pauseResumeReason),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ):
                                    const SizedBox(),
                                  ],
                                ),
                              ),
                              /*scheduledPrograms[index].startCondition.condition.isNotEmpty ||
                                  scheduledPrograms[index].stopCondition.condition.isNotEmpty?
                              IconButton(
                                tooltip: 'view condition',
                                onPressed: () {
                                  showAutoUpdateDialog(context,
                                    scheduledPrograms[index].sNo,
                                  );
                                },
                                icon: const Icon(Icons.visibility_outlined, color: Colors.teal,),
                              ):
                              const SizedBox(),*/
                            ],
                          )),
                          DataCell(Center(child: Text('${scheduledPrograms[index].sequence.length}'))),
                          DataCell(Center(child: Text('${changeDateFormat(scheduledPrograms[index].startDate)} : ${convert24HourTo12Hour(scheduledPrograms[index].startTime)}'))),
                          DataCell(Center(child: Text(changeDateFormat(scheduledPrograms[index].endDate)))),
                          DataCell(
                              scheduledPrograms[index].status==1? Row(
                            children: [
                              Tooltip(
                                message: getDescription(int.parse(scheduledPrograms[index].prgOnOff)),
                                child: MaterialButton(
                                  color: int.parse(scheduledPrograms[index].prgOnOff) >= 0? isStop?Colors.red: isBypass?Colors.orange :Colors.green : Colors.grey.shade300,
                                  textColor: Colors.white,
                                  onPressed: () {

                                    if(getPermissionStatusBySNo(context, 3)){
                                      if (int.parse(scheduledPrograms[index].prgOnOff) >= 0) {
                                        String payload = '${scheduledPrograms[index].serialNumber},${scheduledPrograms[index].prgOnOff}';
                                        String payLoadFinal = jsonEncode({
                                          "2900": {"2901": payload}
                                        });
                                        MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                                        sentUserOperationToServer(
                                          '${scheduledPrograms[index].programName} ${getDescription(int.parse(scheduledPrograms[index].prgOnOff))}',
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
                                color: getButtonName(int.parse(scheduledPrograms[index].prgPauseResume)) == 'Pause' ? Colors.orange : Colors.yellow,
                                textColor: getButtonName(int.parse(scheduledPrograms[index].prgPauseResume)) == 'Pause' ? Colors.white : Colors.black,
                                onPressed: () {
                                  if(getPermissionStatusBySNo(context, 3)){
                                    String payload = '${scheduledPrograms[index].serialNumber},${scheduledPrograms[index].prgPauseResume}';
                                    String payLoadFinal = jsonEncode({
                                      "2900": {"2901": payload}
                                    });
                                    MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                                    sentUserOperationToServer(
                                      '${scheduledPrograms[index].programName} ${getDescription(int.parse(scheduledPrograms[index].prgPauseResume))}',
                                      payLoadFinal,
                                    );
                                  }else{
                                    GlobalSnackBar.show(context, 'Permission denied', 400);
                                  }

                                },
                                child: Text(getButtonName(int.parse(scheduledPrograms[index].prgPauseResume))),
                              ),
                              const Spacer(),
                              getPermissionStatusBySNo(context, 3) ?PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (String result) {
                                  if(result=='Edit program'){
                                    String prgType = '';
                                    bool conditionL = false;
                                    if (scheduledPrograms[index].prgCategory.contains('IL')) {
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
                                      submenuItems: scheduledPrograms[index].sequence,
                                      onItemSelected: (selectedItem, selectedIndex) {
                                        String payload = '${scheduledPrograms[index].serialNumber},${selectedIndex+1}';
                                        String payLoadFinal = jsonEncode({
                                          "6700": {"6701": payload}
                                        });
                                        MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                                        sentUserOperationToServer(
                                          '${scheduledPrograms[index].programName} ${'Changed to $selectedItem'}',
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
                          ):
                                  const Center(child: Text('The program is not ready', style: TextStyle(color: Colors.red),)),
                          ),
                        ]);
                      }),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                left: 0,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.yellow.shade200,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(width: 0.5, color: Colors.grey)
                  ),
                  child: const Text('SCHEDULED PROGRAM',  style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
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