import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../Models/customer/site_model.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../services/mqtt_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/snack_bar.dart';

class ScheduledProgram extends StatelessWidget {
  const ScheduledProgram({super.key, required this.userId, required this.scheduledPrograms, required this.controllerId, required this.deviceId, required this.customerId, required this.currentLineSNo});
  final int userId, customerId, controllerId;
  final String deviceId;
  final List<ProgramList> scheduledPrograms;
  final double currentLineSNo;

  @override
  Widget build(BuildContext context) {

    final spLive = Provider.of<MqttPayloadProvider>(context).scheduledProgramPayload;
    if (spLive.isNotEmpty) {
      _updateProgramsFromMqtt(spLive, scheduledPrograms);
    }

    var filteredScheduleProgram = currentLineSNo == 0
        ? scheduledPrograms
        : scheduledPrograms.where((program) {
      return program.irrigationLine.contains(currentLineSNo);
    }).toList();

    if(kIsWeb){
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
                    height: (filteredScheduleProgram.length * 45) + 45,
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
                        rows: List<DataRow>.generate(filteredScheduleProgram.length, (index) {
                          String buttonName = getButtonName(int.parse(filteredScheduleProgram[index].prgOnOff));
                          bool isStop = buttonName.contains('Stop');
                          bool isBypass = buttonName.contains('Bypass');

                          return DataRow(cells: [
                            DataCell(Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(filteredScheduleProgram[index].programName),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: filteredScheduleProgram[index].programStatusPercentage / 100.0,
                                        borderRadius: const BorderRadius.all(Radius.circular(3)),
                                        color: Colors.blue.shade300,
                                        backgroundColor: Colors.grey.shade200,
                                        minHeight: 2.5,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      '${filteredScheduleProgram[index].programStatusPercentage}%',
                                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                            DataCell(Text(filteredScheduleProgram[index].selectedSchedule, style: const TextStyle(fontSize: 11))),
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
                                              text: getContentByCode(filteredScheduleProgram[index].startStopReason),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      filteredScheduleProgram[index].pauseResumeReason!=30?RichText(
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
                                              text: getContentByCode(filteredScheduleProgram[index].pauseResumeReason),
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
                                /*filteredScheduleProgram[index].startCondition.condition.isNotEmpty ||
                                  filteredScheduleProgram[index].stopCondition.condition.isNotEmpty?
                              IconButton(
                                tooltip: 'view condition',
                                onPressed: () {
                                  showAutoUpdateDialog(context,
                                    filteredScheduleProgram[index].sNo,
                                  );
                                },
                                icon: const Icon(Icons.visibility_outlined, color: Colors.teal,),
                              ):
                              const SizedBox(),*/
                              ],
                            )),
                            DataCell(Center(child: Text('${filteredScheduleProgram[index].sequence.length}'))),
                            DataCell(Center(child: Text('${changeDateFormat(filteredScheduleProgram[index].startDate)} : ${convert24HourTo12Hour(filteredScheduleProgram[index].startTime)}'))),
                            DataCell(Center(child: Text(changeDateFormat(filteredScheduleProgram[index].endDate)))),
                            DataCell(
                              filteredScheduleProgram[index].status==1? Row(
                                children: [
                                  Tooltip(
                                    message: getDescription(int.parse(filteredScheduleProgram[index].prgOnOff)),
                                    child: MaterialButton(
                                      color: int.parse(filteredScheduleProgram[index].prgOnOff) >= 0? isStop?Colors.red: isBypass?Colors.orange :Colors.green : Colors.grey.shade300,
                                      textColor: Colors.white,
                                      onPressed: () {

                                        if(getPermissionStatusBySNo(context, 3)){
                                          if (int.parse(filteredScheduleProgram[index].prgOnOff) >= 0) {
                                            String payload = '${filteredScheduleProgram[index].serialNumber},${filteredScheduleProgram[index].prgOnOff}';
                                            String payLoadFinal = jsonEncode({
                                              "2900": {"2901": payload}
                                            });
                                            MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                                            sentUserOperationToServer(
                                              '${filteredScheduleProgram[index].programName} ${getDescription(int.parse(filteredScheduleProgram[index].prgOnOff))}',
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
                                    color: getButtonName(int.parse(filteredScheduleProgram[index].prgPauseResume)) == 'Pause' ? Colors.orange : Colors.yellow,
                                    textColor: getButtonName(int.parse(filteredScheduleProgram[index].prgPauseResume)) == 'Pause' ? Colors.white : Colors.black,
                                    onPressed: () {
                                      if(getPermissionStatusBySNo(context, 3)){
                                        String payload = '${filteredScheduleProgram[index].serialNumber},${filteredScheduleProgram[index].prgPauseResume}';
                                        String payLoadFinal = jsonEncode({
                                          "2900": {"2901": payload}
                                        });
                                        MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                                        sentUserOperationToServer(
                                          '${filteredScheduleProgram[index].programName} ${getDescription(int.parse(filteredScheduleProgram[index].prgPauseResume))}',
                                          payLoadFinal,
                                        );
                                      }else{
                                        GlobalSnackBar.show(context, 'Permission denied', 400);
                                      }

                                    },
                                    child: Text(getButtonName(int.parse(filteredScheduleProgram[index].prgPauseResume))),
                                  ),
                                  const Spacer(),
                                  getPermissionStatusBySNo(context, 3) ?PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (String result) {
                                      if(result=='Edit program'){
                                        String prgType = '';
                                        bool conditionL = false;
                                        if (filteredScheduleProgram[index].prgCategory.contains('IL')) {
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
                                          serialNumber: filteredScheduleProgram[index].sNo,
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
                                          submenuItems: filteredScheduleProgram[index].sequence,
                                          onItemSelected: (selectedItem, selectedIndex) {
                                            String payload = '${filteredScheduleProgram[index].serialNumber},${selectedIndex+1}';
                                            String payLoadFinal = jsonEncode({
                                              "6700": {"6701": payload}
                                            });
                                            MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                                            sentUserOperationToServer(
                                              '${filteredScheduleProgram[index].programName} ${'Changed to $selectedItem'}',
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
                        color: Colors.yellow.shade100,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        border: Border.all(width: 0.5, color: Colors.black26)
                    ),
                    child: const Text('SCHEDULED PROGRAM',  style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }else{
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: filteredScheduleProgram.isNotEmpty? ListView.builder(
          itemCount: filteredScheduleProgram.length,
          itemBuilder: (context, index) {
            final program = filteredScheduleProgram[index];
            final buttonName = getButtonName(int.parse(program.prgOnOff));
            final isStop = buttonName.contains('Stop');
            final isBypass = buttonName.contains('Bypass');

            return  Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Flexible(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name & progress', style: TextStyle(fontSize: 13, color: Colors.black54),),
                              SizedBox(height: 10,),
                              Text('Method', style: TextStyle(fontSize: 13, color: Colors.black54)),
                              SizedBox(height: 5,),
                              Text('Status or Reason', style: TextStyle(fontSize: 13, color: Colors.black54)),
                              SizedBox(height: 5,),
                              Text('Total Sequence', style: TextStyle(fontSize: 13, color: Colors.black54),),
                              SizedBox(height: 5,),
                              Text('Start Date & Time', style: TextStyle(fontSize: 13, color: Colors.black54),),
                              SizedBox(height: 5,),
                              Text('End Date', style: TextStyle(fontSize: 13, color: Colors.black54),),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: SizedBox(
                            width: 10,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(':'),
                                SizedBox(height: 10,),
                                Text(':'),
                                SizedBox(height: 5,),
                                Text(':'),
                                SizedBox(height: 5,),
                                Text(':'),
                                SizedBox(height: 5,),
                                Text(':'),
                                SizedBox(height: 5,),
                                Text(':'),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(program.programName),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: program.programStatusPercentage / 100.0,
                                          borderRadius: const BorderRadius.all(Radius.circular(3)),
                                          color: Colors.blue.shade300,
                                          backgroundColor: Colors.grey.shade200,
                                          minHeight: 3,
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        '${program.programStatusPercentage}%',
                                        style: const TextStyle(fontSize: 12, color: Colors.black45),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(filteredScheduleProgram[index].selectedSchedule, style: const TextStyle(fontSize: 11)),
                              const SizedBox(height: 5,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 12, color: Colors.black),
                                      children: [
                                        const TextSpan(text: 'Start Stop: ', style: TextStyle(color: Colors.black54)),
                                        TextSpan(text: getContentByCode(program.startStopReason)),
                                      ],
                                    ),
                                  ),
                                  if (program.pauseResumeReason != 30)
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 12, color: Colors.black),
                                        children: [
                                          const TextSpan(text: 'Pause Resume: ', style: TextStyle(color: Colors.black54)),
                                          TextSpan(text: getContentByCode(program.pauseResumeReason)),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 5,),
                              SizedBox(width: 50, child: Text('${program.sequence.length}')),
                              const SizedBox(height: 5,),
                              Text('${changeDateFormat(program.startDate)} : ${convert24HourTo12Hour(program.startTime)}'),
                              const SizedBox(height: 5,),
                              Text(changeDateFormat(program.endDate)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: program.status == 1? Row(
                        children: [
                          const Spacer(),
                          Tooltip(
                            message: getDescription(int.parse(program.prgOnOff)),
                            child: MaterialButton(
                              color: int.parse(program.prgOnOff) >= 0
                                  ? isStop
                                  ? Colors.red
                                  : isBypass
                                  ? Colors.orange
                                  : Colors.green
                                  : Colors.grey.shade300,
                              textColor: Colors.white,
                              onPressed: () {
                                if (getPermissionStatusBySNo(context, 3)) {
                                  String payload = '${program.serialNumber},${program.prgOnOff}';
                                  String payLoadFinal = jsonEncode({
                                    "2900": {"2901": payload}
                                  });
                                  MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                                  sentUserOperationToServer('${program.programName} ${getDescription(int.parse(program.prgOnOff))}', payLoadFinal);
                                } else {
                                  GlobalSnackBar.show(context, 'Permission denied', 400);
                                }
                              },
                              child: Text(buttonName),
                            ),
                          ),
                          const SizedBox(width: 8),
                          MaterialButton(
                            color: getButtonName(int.parse(program.prgPauseResume)) == 'Pause' ? Colors.orange : Colors.yellow,
                            textColor: getButtonName(int.parse(program.prgPauseResume)) == 'Pause' ? Colors.white : Colors.black,
                            onPressed: () {
                              if (getPermissionStatusBySNo(context, 3)) {
                                String payload = '${program.serialNumber},${program.prgPauseResume}';
                                String payLoadFinal = jsonEncode({
                                  "2900": {"2901": payload}
                                });
                                MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                                sentUserOperationToServer('${program.programName} ${getDescription(int.parse(program.prgPauseResume))}', payLoadFinal);
                              } else {
                                GlobalSnackBar.show(context, 'Permission denied', 400);
                              }
                            },
                            child: Text(getButtonName(int.parse(program.prgPauseResume))),
                          ),
                          const SizedBox(width: 5),
                          getPermissionStatusBySNo(context, 3)
                              ? PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (String result) {
                              if (result == 'Edit program') {
                                // Navigate to edit screen
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
                                    String payload = '${program.serialNumber},${selectedIndex + 1}';
                                    String payLoadFinal = jsonEncode({
                                      "6700": {"6701": payload}
                                    });
                                    MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                                    sentUserOperationToServer('${program.programName} Changed to $selectedItem', payLoadFinal);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          )
                              : const Icon(Icons.more_vert, color: Colors.grey),
                        ],
                      ):
                      const Center(child: Text('The program is not ready', style: TextStyle(color: Colors.red))),
                    ),
                  ],
                ),
              ),
            );

          },
        ):
        const Center(child: Text('Program not found')),
      );
    }

  }

  void _updateProgramsFromMqtt(List<String> spLive, List<ProgramList> scheduledPrograms) {


    for (var sp in spLive) {
      List<String> values = sp.split(",");
      if (values.length > 11) {

        int? serialNumber = int.tryParse(values[0]);
        if (serialNumber == null) continue;
        int index = scheduledPrograms.indexWhere((program) => program.serialNumber == serialNumber);

        if (index != -1) {
          scheduledPrograms[index]
            ..startDate = values[3]
            ..startTime = values[4]
            ..endDate = values[5]
            ..programStatusPercentage = int.tryParse(values[6]) ?? 0
            ..startStopReason = int.tryParse(values[7]) ?? 0
            ..pauseResumeReason = int.tryParse(values[8]) ?? 0
            ..prgOnOff = values[10]
            ..prgPauseResume = values[11]
            ..status = 1;
        }
      }
    }
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

  Future<void> sentToServer(String msg, dynamic payLoad, int userId, int controllerId, int customerId) async {
    Map<String, Object> body = {"userId": customerId, "controllerId": controllerId, "messageStatus": msg.isNotEmpty ? msg : 'Just sent without changes', "data": payLoad, "hardware": payLoad, "createUser": userId};
    final response = await Repository(HttpService()).createUserSentAndReceivedMessageManually(body);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  void sentUserOperationToServer(String msg, String data) async
  {
    Map<String, Object> body = {"userId": customerId, "controllerId": controllerId, "messageStatus": msg, "hardware": jsonDecode(data), "createUser": userId};
    final response = await Repository(HttpService()).createUserSentAndReceivedMessageManually(body);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  bool getPermissionStatusBySNo(BuildContext context, int sNo) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    Map<String, dynamic>? permission = payloadProvider.userPermission
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (element) => element['sNo'] == sNo,
      orElse: () => {},
    );
    return permission['status'] as bool? ?? true;
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