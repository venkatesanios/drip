import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import '../../../models/customer/site_model.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../modules/IrrigationProgram/view/irrigation_program_main.dart';
import '../../../repository/repository.dart';
import '../../../services/ai_service.dart';
import '../../../services/communication_service.dart';
import '../../../services/http_service.dart';
import '../../../services/weather_service.dart';
import '../../../utils/enums.dart';
import '../../../utils/my_function.dart';
import '../../../utils/snack_bar.dart';

class ScheduledProgram extends StatelessWidget {
  const ScheduledProgram({super.key, required this.userId,
    required this.scheduledPrograms, required this.controllerId,
    required this.deviceId, required this.customerId,
    required this.currentLineSNo, required this.groupId,
    required this.categoryId, required this.modelId,
    required this.deviceName, required this.categoryName});

  final int userId, customerId, controllerId, groupId, categoryId, modelId;
  final String deviceId, deviceName, categoryName;
  final List<ProgramList> scheduledPrograms;
  final double currentLineSNo;

  static const headerStyle = TextStyle(fontSize: 13);
  static final ValueNotifier<Map<String, dynamic>?> aiResponseNotifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {

    final spLive = Provider.of<MqttPayloadProvider>(context).scheduledProgramPayload;
    final conditionPayload = Provider.of<MqttPayloadProvider>(context).conditionPayload;

    if (spLive.isNotEmpty) {
      _updateProgramsFromMqtt(spLive, scheduledPrograms, conditionPayload);
    }

    var filteredScheduleProgram = currentLineSNo == 0 ?
    scheduledPrograms :
    scheduledPrograms.where((program) {
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
                          DataColumn2(label: Text('Name', style: headerStyle), size: ColumnSize.M),
                          DataColumn2(label: Text('Method', style: headerStyle), size: ColumnSize.M),
                          DataColumn2(label: Text('Status or Reason', style: headerStyle), size: ColumnSize.L),
                          DataColumn2(label: Center(child: Text('Zone', style: headerStyle)), fixedWidth: 50),
                          DataColumn2(label: Center(child: Text('Start Date & Time', style: headerStyle)), size: ColumnSize.M),
                          DataColumn2(label: Center(child: Text('End Date', style: headerStyle)), size: ColumnSize.S),
                          DataColumn2(label: Text(''), fixedWidth: 300),
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
                                (filteredScheduleProgram[index].conditions.isNotEmpty &&
                                    filteredScheduleProgram[index].conditions.any((c) => c.selected == true)) // ✅ check if any selected
                                    ? IconButton(
                                  tooltip: 'View Condition',
                                  onPressed: () {
                                    final selectedConditions = filteredScheduleProgram[index]
                                        .conditions
                                        .where((c) => c.selected == true)
                                        .toList();

                                    showConditionDialog(
                                      context,
                                      filteredScheduleProgram[index].programName,
                                      selectedConditions,
                                    );
                                  },
                                  icon: const Icon(Icons.visibility_outlined),
                                )
                                    : const SizedBox(),
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

                                            final commService = Provider.of<CommunicationService>(context, listen: false);
                                            commService.sendCommand(serverMsg: '${filteredScheduleProgram[index].programName} ${getDescription(int.parse(filteredScheduleProgram[index].prgOnOff))}', payload: payLoadFinal);

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
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Are you sure ! you want to ${getButtonName(int.parse(filteredScheduleProgram[index].prgPauseResume))} the ${filteredScheduleProgram[index].programName}'),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () => Navigator.pop(context, false),
                                            ),
                                            TextButton(
                                              child: const Text('Yes'),
                                              onPressed: () {
                                                if(getPermissionStatusBySNo(context, 3)){
                                                  String payload = '${filteredScheduleProgram[index].serialNumber},${filteredScheduleProgram[index].prgPauseResume}';
                                                  String payLoadFinal = jsonEncode({
                                                    "2900": {"2901": payload}
                                                  });

                                                  final commService = Provider.of<CommunicationService>(context, listen: false);
                                                  commService.sendCommand(serverMsg: '${filteredScheduleProgram[index].programName} ${getDescription(int.parse(filteredScheduleProgram[index].prgPauseResume))}', payload: payLoadFinal);

                                                }else{
                                                  GlobalSnackBar.show(context, 'Permission denied', 400);
                                                }
                                                Navigator.pop(context, true);
                                              },
                                            ),
                                          ],
                                        ),
                                      );

                                    },
                                    child: Text(getButtonName(int.parse(filteredScheduleProgram[index].prgPauseResume))),
                                  ),
                                  const Spacer(),
                                  getPermissionStatusBySNo(context, 3) ? PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (String result) {
                                      if(result=='Edit program'){
                                        bool conditionL = false;
                                        if (filteredScheduleProgram[index].conditions.isNotEmpty) {
                                          conditionL = true;
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => IrrigationProgram(
                                              deviceId: deviceId,
                                              userId: userId,
                                              controllerId: controllerId,
                                              serialNumber: scheduledPrograms[index].serialNumber,
                                              programType: filteredScheduleProgram[index].programType,
                                              conditionsLibraryIsNotEmpty: conditionL,
                                              fromDealer: false,
                                              toDashboard: true,
                                              groupId: groupId,
                                              categoryId: categoryId,
                                              customerId: customerId,
                                              modelId: modelId,
                                              deviceName: deviceName,
                                              categoryName: categoryName,
                                            ),
                                          ),
                                        );
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

                                            final commService = Provider.of<CommunicationService>(context, listen: false);
                                            commService.sendCommand(serverMsg: '${filteredScheduleProgram[index].programName} ${'Changed to $selectedItem'}', payload: payLoadFinal);

                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  ):
                                  const IconButton(onPressed: null, icon: Icon(Icons.more_vert, color: Colors.grey,)),
                                  SizedBox(
                                    width:50,
                                    child: Builder(
                                      builder: (buttonContext) => Tooltip(
                                        message: 'View AI Recommendation',
                                        child: ElevatedButton(
                                          onPressed: () {
                                            getAdvisory();
                                            showPopover(
                                              context: buttonContext,
                                              bodyBuilder: (context) {
                                                return ValueListenableBuilder<Map<String, dynamic>?>(
                                                  valueListenable: aiResponseNotifier,
                                                  builder: (context, data, _) {
                                                    if (data == null) {
                                                      return const Padding(
                                                        padding: EdgeInsets.all(12),
                                                        child: Text('🔄 Getting AI advisory...'),
                                                      );
                                                    }

                                                    if (data.containsKey('error')) {
                                                      return Padding(
                                                        padding: const EdgeInsets.all(12),
                                                        child: Text(data['error']),
                                                      );
                                                    }

                                                    final percent = data['percentage'];
                                                    final reason = data['reason'];


                                                    return Padding(
                                                      padding: const EdgeInsets.all(12),
                                                      child: ConstrainedBox(
                                                        constraints: const BoxConstraints(maxWidth: 400),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("✅ Suggested Irrigation Percentage: $percent%",
                                                                style: const TextStyle(fontSize: 16)),
                                                            const SizedBox(height: 8),
                                                            Text(reason, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                                            const SizedBox(height: 12),
                                                            Align(
                                                              alignment: Alignment.centerRight,
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () =>Navigator.of(context).pop(),
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Colors.red,
                                                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                                    ),
                                                                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                                                                  ),
                                                                  const SizedBox(width: 16),
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      print("✔️ Applied $percent%");
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: Theme.of(context).primaryColor,
                                                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                                    ),
                                                                    child: const Text('Apply', style: TextStyle(color: Colors.white)),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              onPop: () => print('Popover was popped!'),
                                              direction: PopoverDirection.bottom,
                                              arrowHeight: 15,
                                              arrowWidth: 30,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(13),
                                            backgroundColor: Theme.of(context).primaryColor,
                                          ),
                                          child: const Text('AI-R',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
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
                                  ),
                                  (filteredScheduleProgram[index].conditions.isNotEmpty &&
                                      filteredScheduleProgram[index].conditions.any((c) => c.selected == true)) // ✅ check if any selected
                                      ? IconButton(
                                    tooltip: 'View Condition',
                                    onPressed: () {
                                      final selectedConditions = filteredScheduleProgram[index]
                                          .conditions
                                          .where((c) => c.selected == true)
                                          .toList();

                                      showConditionDialog(
                                        context,
                                        filteredScheduleProgram[index].programName,
                                        selectedConditions,
                                      );
                                    },
                                    icon: const Icon(Icons.visibility_outlined),
                                  )
                                      : const SizedBox(),
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

                                  final commService = Provider.of<CommunicationService>(context, listen: false);
                                  commService.sendCommand(serverMsg: '${program.programName} ${getDescription(int.parse(program.prgOnOff))}', payload: payLoadFinal);
                                  GlobalSnackBar.show(context, 'Comment sent successfully', 200);
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

                                final commService = Provider.of<CommunicationService>(context, listen: false);
                                commService.sendCommand(serverMsg: '${program.programName} ${getDescription(int.parse(program.prgPauseResume))}', payload: payLoadFinal);
                                GlobalSnackBar.show(context, 'Comment sent successfully', 200);
                              } else {
                                GlobalSnackBar.show(context, 'Permission denied', 400);
                              }
                            },
                            child: Text(getButtonName(int.parse(program.prgPauseResume))),
                          ),
                          const SizedBox(width: 5),
                          getPermissionStatusBySNo(context, 3)? PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (String result) {
                              if (result == 'Edit program') {
                                bool conditionL = false;
                                if (filteredScheduleProgram[index].conditions.isNotEmpty) {
                                  conditionL = true;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IrrigationProgram(
                                      deviceId: deviceId,
                                      userId: userId,
                                      controllerId: controllerId,
                                      serialNumber: scheduledPrograms[index].serialNumber,
                                      programType: filteredScheduleProgram[index].programType,
                                      conditionsLibraryIsNotEmpty: conditionL,
                                      fromDealer: false,
                                      toDashboard: true,
                                      groupId: groupId,
                                      categoryId: categoryId,
                                      customerId: customerId,
                                      modelId: modelId,
                                      deviceName: deviceName,
                                      categoryName: categoryName,
                                    ),
                                  ),
                                );
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

                                    final commService = Provider.of<CommunicationService>(context, listen: false);
                                    commService.sendCommand(serverMsg: '${program.programName} Changed to $selectedItem', payload: payLoadFinal);
                                    GlobalSnackBar.show(context, 'Comment sent successfully', 200);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          )
                              : const Icon(Icons.more_vert, color: Colors.grey),
                          SizedBox(
                            width:50,
                            child: Builder(
                              builder: (buttonContext) => Tooltip(
                                message: 'View AI Recommendation',
                                child: ElevatedButton(
                                  onPressed: () {
                                    getAdvisory();
                                    showPopover(
                                      context: buttonContext,
                                      bodyBuilder: (context) {
                                        return ValueListenableBuilder<Map<String, dynamic>?>(
                                          valueListenable: aiResponseNotifier,
                                          builder: (context, data, _) {
                                            if (data == null) {
                                              return const Padding(
                                                padding: EdgeInsets.all(12),
                                                child: Text('🔄 Getting AI advisory...'),
                                              );
                                            }

                                            if (data.containsKey('error')) {
                                              return Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Text(data['error']),
                                              );
                                            }

                                            final percent = data['percentage'];
                                            final reason = data['reason'];


                                            return Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: ConstrainedBox(
                                                constraints: const BoxConstraints(maxWidth: 350),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("✅ Suggested Irrigation Percentage: $percent%",
                                                        style: const TextStyle(fontSize: 16)),
                                                    const SizedBox(height: 8),
                                                    Text(reason, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                                                    const SizedBox(height: 12),
                                                    Align(
                                                      alignment: Alignment.centerRight,
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          ElevatedButton(
                                                            onPressed: () =>Navigator.of(context).pop(),
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.red,
                                                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                            ),
                                                            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                                                          ),
                                                          const SizedBox(width: 16),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              print("✔️ Applied $percent%");
                                                              Navigator.of(context).pop();
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Theme.of(context).primaryColor,
                                                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                                            ),
                                                            child: const Text('Apply', style: TextStyle(color: Colors.white)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      onPop: () => print('Popover was popped!'),
                                      direction: PopoverDirection.bottom,
                                      arrowHeight: 15,
                                      arrowWidth: 30,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(13),
                                    backgroundColor: Theme.of(context).primaryColor,
                                  ),
                                  child: const Text('AI-R',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                          ),
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

  void _updateProgramsFromMqtt(List<String> spLive,
      List<ProgramList> scheduledPrograms, List<String> conditionPayloadList) {

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

          for (var payload in conditionPayloadList) {
            List<String> parts = payload.split(",");
            if (parts.length > 2) {
              int? conditionSerialNo = int.tryParse(parts[0].trim());
              print(conditionSerialNo);
              int? conditionStatus = int.tryParse(parts[2].trim());
              String? actualValue = parts[4].trim();

              final matches = scheduledPrograms[index]
                  .conditions
                  .where((c) => c.sNo == conditionSerialNo);

              for (var condition in matches) {
                condition.conditionStatus = conditionStatus!;
                condition.actualValue = actualValue;
                print("Updated condition: sNo=${condition.sNo}, "
                    "status=${condition.conditionStatus}, "
                    "value=${condition.actualValue}");
              }
            }
          }
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
      5: 'Bypass Start Rtc',
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
      5: 'ByPass And Start By Rtc',
    };
    return codeDescriptionMap[code] ?? 'Code not found';
  }

  void showConditionDialog(BuildContext context, String prgName,  List<ConditionModel> conditions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(conditions.length>1?'Conditions of $prgName':'Condition of $prgName', style: const TextStyle(fontSize: 17)),
          content: SizedBox(
            width: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: conditions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(conditions[index].title,
                      style: TextStyle(fontWeight: FontWeight.bold,
                          color: conditions[index].conditionStatus==1? Colors.green : Colors.black)),
                  subtitle: Text(conditions[index].value.rule,
                      style: TextStyle(color: conditions[index].conditionStatus==1? Colors.green.shade700 : Colors.black54)),
                  trailing: Text('Actual\n${conditions[index].actualValue}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }


  String getContentByCode(int code) {
    return GemProgramStartStopReasonCode.fromCode(code).content;
  }

  Future<void> sentToServer(String msg, dynamic payLoad, int userId, int controllerId, int customerId) async {
    Map<String, Object> body = {"userId": customerId, "controllerId": controllerId, "messageStatus": msg.isNotEmpty ? msg : 'Just sent without changes', "data": payLoad, "hardware": payLoad, "createUser": userId};
    final response = await Repository(HttpService()).sendManualOperationToServer(body);
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

  void getAdvisory() async {
    try {
      Map<String, Object> body = {
        "userId": userId,
        "controllerId": controllerId,
      };
      final response = await Repository(HttpService()).fetchSiteAiAdvisoryData(body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          final data = jsonData['data'];
          if (data != null || data.isNotEmpty) {

            final weatherData = await WeatherService().fetchWeather(city: data['location']);
            aiResponseNotifier.value = null;

            final params = IrrigationParams(
              cropType: data['cropName'],
              soilType: data['soilType'],
              moistureLevel: 'unknown',
              weather: '${weatherData['rainfall']}',
              area: data['fieldArea'],
              growthStage: data['stage'],
              temperature: '${weatherData['temperature']}',
              humidity: '${weatherData['humidity']}',
              windSpeed: '${weatherData['wind_speed']}',
              windDirection: '${weatherData['wind_direction']}',
              cloudCover: '${weatherData['cloud_cover']}',
              pressure: '${weatherData['pressure']}',
              recentRainfall: '${weatherData['rainfall']}',
              irrigationMethod: data['irrigationType'],
            );

            final prompt = params.toPrompt();
            try {
              final response = await AIService().sendTextToAI(prompt, "English");
              final lines = response.trim().split('\n');
              final percent = extractPercentageOnly(lines[0]);
              final reason = lines.skip(1).join('\n').trim();
              if (percent != null) {
                aiResponseNotifier.value = {
                  'percentage': percent,
                  'reason': reason,
                };
              }
              else {
                aiResponseNotifier.value = {
                  'error': '⚠️Could not extract irrigation percentage.',
                };
              }
            } catch (e) {
              aiResponseNotifier.value = {
                'error': '❌ Error fetching AI advisory.',
              };
            }

          } else {
            print("Data is empty");
          }
        }
      }

    } catch (e) {
      print('Failed to load weather: $e');
    }

  }


  int? extractPercentageOnly(String text) {
    final match = RegExp(r'(\d{1,3})\s?%').firstMatch(text);
    return match != null ? int.parse(match.group(1)!) : null;
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
          value: item.name,
          child: Text(item.name),
        );
      }).toList(),
    ).then((String? selectedItem) {
      if (selectedItem != null) {
        int selectedIndex = submenuItems.indexWhere((item) => item.name == selectedItem);
        if (selectedIndex != -1) {
          onItemSelected(selectedItem, selectedIndex);
        }
      }
    });
  }
}