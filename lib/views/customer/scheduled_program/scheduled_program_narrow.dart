import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/utils/formatters.dart';
import 'package:oro_drip_irrigation/views/customer/scheduled_program/widgets/ai_recommendation_button.dart';
import 'package:oro_drip_irrigation/views/customer/scheduled_program/widgets/clickable_submenu.dart';
import 'package:oro_drip_irrigation/views/customer/scheduled_program/widgets/program_updater.dart';
import 'package:provider/provider.dart';

import '../../../models/customer/site_model.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../modules/IrrigationProgram/view/irrigation_program_main.dart';
import '../../../services/ai_advisory_service.dart';
import '../../../services/communication_service.dart';
import '../../../utils/helpers/program_code_helper.dart';
import '../../../utils/my_function.dart';
import '../../../utils/snack_bar.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';

class ScheduledProgramNarrow extends StatefulWidget {
  const ScheduledProgramNarrow({super.key, required this.userId,
    required this.customerId, required this.currentLineSNo, required this.groupId,
    required this.master});

  final int userId, customerId, groupId;
  final double currentLineSNo;
  final MasterControllerModel master;

  static const headerStyle = TextStyle(fontSize: 13);

  @override
  State<ScheduledProgramNarrow> createState() => _ScheduledProgramNarrowState();
}

class _ScheduledProgramNarrowState extends State<ScheduledProgramNarrow> {

  late final AiAdvisoryService aiService;

  @override
  void initState() {
    super.initState();
    aiService = AiAdvisoryService();
  }

  @override
  Widget build(BuildContext context) {

    // Watch viewModel to rebuild when notifyListeners() is called
    final viewModel = context.watch<CustomerScreenControllerViewModel>();

    // Get updated master every time from viewModel
    final master = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex];

    final spLive = context.watch<MqttPayloadProvider>().scheduledProgramPayload;
    final conditionPayload = context.watch<MqttPayloadProvider>().conditionPayload;

    if (spLive.isNotEmpty) {
      ProgramUpdater.updateProgramsFromMqtt(spLive, master.programList, conditionPayload);
    }

    var filteredScheduleProgram = widget.currentLineSNo == 0 ? master.programList :
    master.programList.where((program) {
      return program.irrigationLine.contains(widget.currentLineSNo);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: filteredScheduleProgram.isNotEmpty? ListView.builder(
        itemCount: filteredScheduleProgram.length,
        itemBuilder: (context, index) {
          final program = filteredScheduleProgram[index];
          final buttonName = ProgramCodeHelper.getButtonName(int.parse(program.prgOnOff));
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
                                      TextSpan(text: MyFunction().getContentByCode(program.startStopReason)),
                                    ],
                                  ),
                                ),
                                if (program.pauseResumeReason != 30)
                                  RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 12, color: Colors.black),
                                      children: [
                                        const TextSpan(text: 'Pause Resume: ', style: TextStyle(color: Colors.black54)),
                                        TextSpan(text: MyFunction().getContentByCode(program.pauseResumeReason)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5,),
                            SizedBox(width: 50, child: Text('${program.sequence.length}')),
                            const SizedBox(height: 5,),
                            Text('${Formatters().changeDateFormat(program.startDate)} : ${MyFunction().convert24HourTo12Hour(program.startTime)}'),
                            const SizedBox(height: 5,),
                            Text(Formatters().changeDateFormat(program.endDate)),
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
                          message: ProgramCodeHelper.getDescription(int.parse(program.prgOnOff)),
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
                                commService.sendCommand(serverMsg: '${program.programName} ${ProgramCodeHelper.getDescription(int.parse(program.prgOnOff))}', payload: payLoadFinal);
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
                          color: ProgramCodeHelper.getButtonName(int.parse(program.prgPauseResume)) == 'Pause' ? Colors.orange : Colors.yellow,
                          textColor: ProgramCodeHelper.getButtonName(int.parse(program.prgPauseResume)) == 'Pause' ? Colors.white : Colors.black,
                          onPressed: () {
                            if (getPermissionStatusBySNo(context, 3)) {
                              String payload = '${program.serialNumber},${program.prgPauseResume}';
                              String payLoadFinal = jsonEncode({
                                "2900": {"2901": payload}
                              });

                              final commService = Provider.of<CommunicationService>(context, listen: false);
                              commService.sendCommand(serverMsg: '${program.programName} ${ProgramCodeHelper.getDescription(int.parse(program.prgPauseResume))}', payload: payLoadFinal);
                              GlobalSnackBar.show(context, 'Comment sent successfully', 200);
                            } else {
                              GlobalSnackBar.show(context, 'Permission denied', 400);
                            }
                          },
                          child: Text(ProgramCodeHelper.getButtonName(int.parse(program.prgPauseResume))),
                        ),
                        const SizedBox(width: 5),

                        getPermissionStatusBySNo(context, 3) ? PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (result) {
                            if (result == 'Edit program') {
                              bool hasConditions = program.conditions.isNotEmpty;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IrrigationProgram(
                                    deviceId: widget.master.deviceId,
                                    userId: widget.userId,
                                    controllerId: widget.master.controllerId,
                                    serialNumber: widget.master.programList[index].serialNumber,
                                    programType: filteredScheduleProgram[index].programType,
                                    conditionsLibraryIsNotEmpty: hasConditions,
                                    fromDealer: false,
                                    toDashboard: true,
                                    groupId: widget.groupId,
                                    categoryId: widget.master.categoryId,
                                    customerId: widget.customerId,
                                    modelId: widget.master.modelId,
                                    deviceName: widget.master.deviceName,
                                    categoryName: widget.master.categoryName,
                                  ),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'Edit program', child: Text('Edit program')),
                            PopupMenuItem(
                                value: 'Change to',
                                child: ClickableSubmenu(
                                    title: 'Change to',
                                    submenuItems: program.sequence,
                                    onItemSelected: (selectedItem, selectedIndex) {
                                      final payload = '${program.serialNumber},${selectedIndex + 1}';
                                      final payLoadFinal = jsonEncode({"6700": {"6701": payload}});
                                      Provider.of<CommunicationService>(context, listen: false).sendCommand(
                                          serverMsg: '${program.programName} Changed to $selectedItem',
                                          payload: payLoadFinal);
                                      Navigator.pop(context);
                                    })),
                          ],
                        ) :
                        const Icon(Icons.more_vert, color: Colors.grey),

                        AiRecommendationButton(aiService: aiService, userId: widget.userId, controllerId: widget.master.controllerId),
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

  bool getPermissionStatusBySNo(BuildContext context, int sNo) {
    MqttPayloadProvider payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    Map<String, dynamic>? permission = payloadProvider.userPermission.cast<Map<String, dynamic>>().firstWhere((element) =>
    element['sNo'] == sNo,
      orElse: () => {},
    );
    return permission['status'] as bool? ?? true;
  }

}