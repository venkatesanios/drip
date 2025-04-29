import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/repository/repository.dart';
import 'package:oro_drip_irrigation/services/http_service.dart';
import 'package:oro_drip_irrigation/services/mqtt_service.dart';
import 'package:oro_drip_irrigation/utils/environment.dart';
import '../../../Constants/constants.dart';
import '../model/pump_controller_data_model.dart';
import '../widget/custom_countdown_timer.dart';

class ValveCycleWidget extends StatefulWidget {
  final PumpValveModel valveData;
  final String deviceId;
  final int userId, customerId, controllerId;
  final int dataFetchingStatus;
  const ValveCycleWidget({super.key, required this.valveData, required this.deviceId, required this.userId, required this.customerId, required this.controllerId, required this.dataFetchingStatus});

  @override
  State<ValveCycleWidget> createState() => _ValveCycleWidgetState();
}

class _ValveCycleWidgetState extends State<ValveCycleWidget> {

  @override
  Widget build(BuildContext context) {
    if (widget.valveData.cyclicRestartLimit == '0') {
      return const SizedBox.shrink();
    }
    double current = double.tryParse(widget.valveData.currentCycle) ?? 0;
    double total = double.tryParse(widget.valveData.cyclicRestartLimit) ?? 1;

    double progress = (total > 0) ? (current / total).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        // border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCycleCard(
                context,
                title: "Total Cycles",
                content: Text(
                  widget.valveData.cyclicRestartLimit,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.valveData.valveOnMode == '1' &&
                  widget.valveData.cyclicRestartFlag == '1' &&
                  widget.valveData.cyclicRestartIntervalRem != '00:00:00' && widget.dataFetchingStatus == 1)
                _buildCycleCard(
                  context,
                  title: "Cycle Interval Rem.",
                  content: CountdownTimerWidget(
                    key: Key(widget.valveData.cyclicRestartIntervalRem),
                    initialSeconds: Constants.parseTime(widget.valveData.cyclicRestartIntervalRem).inSeconds,
                  ),
                ),
              _buildCycleCard(
                context,
                title: "Current Cycle",
                content: Text(
                  widget.valveData.currentCycle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
         /* if(widget.dataFetchingStatus == 1)
            SizedBox(
              height: 25,
              child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  )),
                  maximumSize: WidgetStateProperty.all(const Size(100, 40)),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Confirmation'),
                      content: const Text('Are you sure! you want to proceed to reset cycle?'),
                      actions: [
                        MaterialButton(
                          color: Colors.redAccent,
                          textColor: Colors.white,
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        MaterialButton(
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          onPressed: () async{
                            final Repository repository = Repository(HttpService());
                            final payLoadFinal = {'sentSms': 'resetcycle'};
                            MqttService().topicToPublishAndItsMessage(jsonEncode(payLoadFinal), '${Environment.mqttPublishTopic}/${widget.deviceId}');
                            Map<String, dynamic> body = {
                              "userId": widget.userId,
                              "controllerId": widget.controllerId,
                              "hardware": payLoadFinal,
                              "messageStatus": "Cycle reset successfully",
                              "createUser": widget.userId
                            };
                            final result = await repository.createUserSentAndReceivedMessageManually(body);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Reset cycle', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),),
              ),
            ),*/
        ],
      ),
    );
  }

  Widget _buildCycleCard(
      BuildContext context, {
        required String title,
        required Widget content,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          content,
        ],
      ),
    );
  }
}