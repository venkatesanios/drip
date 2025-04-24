
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../Models/customer/site_model.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../services/mqtt_service.dart';
import '../../../utils/constants.dart';
import '../../../view_models/customer/current_program_view_model.dart';

class CurrentProgram extends StatelessWidget {
  const CurrentProgram({super.key, required this.scheduledPrograms, required this.deviceId, required this.customerId, required this.controllerId, required this.currentLineSNo});
  final List<ProgramList> scheduledPrograms;
  final String deviceId;
  final int customerId, controllerId;
  final double currentLineSNo;

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context) => CurrentProgramViewModel(context, currentLineSNo),
      child: Consumer<CurrentProgramViewModel>(
        builder: (context, vm, _) {

          final currentSchedule = context.watch<MqttPayloadProvider>().currentSchedule;

          if(currentSchedule.isNotEmpty){
            WidgetsBinding.instance.addPostFrameCallback((_) {
              vm.updateSchedule(currentSchedule);
            });
          }

          return vm.currentSchedule.isNotEmpty && vm.currentSchedule[0].isNotEmpty?
          kIsWeb? buildWebTable(vm.currentSchedule):
          buildMobileCard(vm.currentSchedule):
          const SizedBox();
        },
      ),
    );

  }

  Widget buildWebTable(List<String> schedule) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 20),
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
                      color: Colors.grey,
                      width: 0.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  height: (schedule.length * 45) + 45,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 1100,
                    dataRowHeight: 45.0,
                    headingRowHeight: 40.0,
                    headingRowColor: WidgetStateProperty.all<Color>(Colors.green.shade50),
                    columns: const [
                      DataColumn2(
                        label: Text('Name', style: TextStyle(fontSize: 13)),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Zone', style: TextStyle(fontSize: 13)),
                        fixedWidth: 75,
                      ),
                      DataColumn2(
                        label: Text('Zone Name', style: TextStyle(fontSize: 13)),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: Center(child: Text('RTC', style: TextStyle(fontSize: 13))),
                        fixedWidth: 75,
                      ),
                      DataColumn2(
                        label: Center(child: Text('Cyclic', style: TextStyle(fontSize: 13))),
                        fixedWidth: 75,
                      ),
                      DataColumn2(
                        label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13))),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: Center(child: Text('Set (Dur/Flw)', style: TextStyle(fontSize: 13))),
                        fixedWidth: 100,
                      ),
                      DataColumn2(
                        label: Center(child: Text('Avg/Flw Rate', style: TextStyle(fontSize: 13))),
                        fixedWidth: 100,
                      ),
                      DataColumn2(
                        label: Center(child: Text('Remaining', style: TextStyle(fontSize: 13))),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: Center(child: Text('')),
                        fixedWidth: 90,
                      ),
                    ],
                    rows: List<DataRow>.generate(schedule.length, (index) {
                      List<String> values = schedule[index].split(",");
                      return DataRow(cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(getProgramNameById(int.parse(values[0]))),
                              Text(
                                getContentByCode(int.parse(values[17])),
                                style: const TextStyle(fontSize: 10, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text('${values[10]}/${values[9]}')),
                        DataCell(Text(
                          getProgramNameById(int.parse(values[0])) == 'StandAlone - Manual'
                              ? '--'
                              : getSequenceName(int.parse(values[0]), values[1]) ?? '--',
                        )),
                        DataCell(Center(child: Text(formatRtcValues(values[6], values[5])))),
                        DataCell(Center(child: Text(formatRtcValues(values[8], values[7])))),
                        DataCell(Center(child: Text(convert24HourTo12Hour(values[11])))),
                        DataCell(Center(child: Text(getProgramNameById(int.parse(values[0])) == 'StandAlone - Manual' &&
                            (values[3] == '00:00:00' || values[3] == '0') ? 'Timeless' : values[3]))),
                        DataCell(Center(child: Text('${values[16]}-L/hr'))),
                        DataCell(Center(child: Text(
                          getProgramNameById(int.parse(values[0])) == 'StandAlone - Manual' &&
                              (values[3] == '00:00:00' || values[3] == '0')
                              ? '----'
                              : values[4],
                          style: const TextStyle(fontSize: 20),
                        ))),
                        DataCell(Center(
                          child: buildActionButton(values),
                        )),
                      ]);
                    }),
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
                      color: Colors.green.shade100,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(width: 0.5, color: Colors.grey)),
                  child: const Text('CURRENT SCHEDULE', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMobileCard(List<String> schedule) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: const RoundedRectangleBorder(),
      child: Column(
        children: schedule.asMap().entries.map((entry) {
          List<String> values = entry.value.split(",");
          return buildScheduleRow(values);
        }).toList(),
      ),
    );
  }

  Widget buildActionButton(List<String> values) {
    final programName = getProgramNameById(int.parse(values[0]));
    if (programName == 'StandAlone - Manual') {
      return MaterialButton(
        color: Colors.redAccent,
        textColor: Colors.white,
        onPressed: values[17]=='1'? (){
          String payLoadFinal = jsonEncode({
            "800": {"801": '0,0,0,0,0'}
          });
          MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
          sentUserOperationToServer('${getProgramNameById(int.parse(values[0]))} Stopped manually', payLoadFinal);
        }: null,
        child: const Text('Stop'),
      );
    } else if (programName.contains('StandAlone'))  {
      return MaterialButton(
        color: Colors.redAccent,
        textColor: Colors.white,
        onPressed: () async {

          String payLoadFinal = jsonEncode({
            "3900": {"3901": '0,${values[3]},${values[0]},'
                '${values[1]},,,,,,,,,0,'}
          });
          MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
          sentUserOperationToServer('${getProgramNameById(int.parse(values[0]))} Stopped manually', payLoadFinal);

        },
        child: const Text('Stop'),
      );
    }else{
      return MaterialButton(
        color: Colors.orange,
        textColor: Colors.white,
        onPressed: values[17]=='1' ? (){
          String payload = '${values[18]},0';
          String payLoadFinal = jsonEncode({
            "3700": {"3701": payload}
          });
          MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
          sentUserOperationToServer('${getProgramNameById(int.parse(values[0]))} - ${getSequenceName(int.parse(values[0]), values[1])} skipped manually', payLoadFinal);
        } : null,
        child: const Text('Skip'),
      );
    }
  }


  Widget buildScheduleRow(List<String> values) {
    final programName = getProgramNameById(int.parse(values[0]));
    return Row(
      children: [
        const SizedBox(width: 8),
        const SizedBox(
          width: 95,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name & reason', style: TextStyle(color: Colors.black45)),
              SizedBox(height: 3),
              Text('Current Zone', style: TextStyle(color: Colors.black45)),
              SizedBox(height: 3),
              Text('RTC & Cyclic', style: TextStyle(color: Colors.black45)),
              SizedBox(height: 3),
              Text('Start Time', style: TextStyle(color: Colors.black45)),
              SizedBox(height: 3),
              Text('Set (Dur/Flw)', style: TextStyle(color: Colors.black45)),
              SizedBox(height: 3),
            ],
          ),
        ),
        const SizedBox(
          width: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(':'),
              SizedBox(height: 3),
              Text(':'),
              SizedBox(height: 3),
              Text(':'),
              SizedBox(height: 3),
              Text(':'),
              SizedBox(height: 3),
              Text(':'),
              SizedBox(height: 3),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$programName - ${getContentByCode(int.parse(values[17]))}'),
              const SizedBox(height: 3),
              Text(
                  '${values[10]}/${values[9]} - ${programName == 'StandAlone - Manual' ? '--' : getSequenceName(int.parse(values[0]), values[1]) ?? '--'}'),
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 3),
                        Text('${formatRtcValues(values[6], values[5])} - ${formatRtcValues(values[8], values[7])}'),
                        const SizedBox(height: 3),
                        Text(convert24HourTo12Hour(values[11])),
                        const SizedBox(height: 3),
                        Text(
                          programName == 'StandAlone - Manual' && (values[3] == '00:00:00' || values[3] == '0')
                              ? 'Timeless'
                              : values[3],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 1,
                      height: 50,
                      color: CupertinoColors.inactiveGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
            ],
          ),
        )
      ],
    );
  }

  String getProgramNameById(int id) {
    try {
      return scheduledPrograms.firstWhere((program) => program.serialNumber == id).programName;
    } catch (e) {
      return "StandAlone - Manual";
    }
  }

  ProgramList? getProgramById(int id) {
    try {
      return scheduledPrograms.firstWhere((program) => program.serialNumber == id);
    } catch (e) {
      return null;
    }
  }

  String? getSequenceName(int programId, String sequenceId) {
    ProgramList? program = getProgramById(programId);
    if (program != null) {
      return getSequenceNameById(program, sequenceId);
    }
    return null;
  }

  String? getSequenceNameById(ProgramList program, String sequenceId) {
    try {
      return program.sequence.firstWhere((seq) => seq.sNo == sequenceId).name;
    } catch (e) {
      return null;
    }
  }

  String formatRtcValues(dynamic value1, dynamic value2) {
    if (value1 == 0 && value2 == 0) {
      return '--';
    } else {
      return '${value1.toString()}/${value2.toString()}';
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

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  String getContentByCode(int code) {
    return GemProgramStartStopReasonCode.fromCode(code).content;
  }

  void sentUserOperationToServer(String msg, String data) async
  {
    Map<String, Object> body = {"userId": customerId, "controllerId": controllerId, "messageStatus": msg, "hardware": jsonDecode(data), "createUser": customerId};
    final response = await Repository(HttpService()).createUserSentAndReceivedMessageManually(body);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

}
