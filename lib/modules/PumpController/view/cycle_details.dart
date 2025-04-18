import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/services/mqtt_service.dart';
import 'package:oro_drip_irrigation/utils/environment.dart';
import '../../../Constants/constants.dart';
import '../model/pump_controller_data_model.dart';
import '../widget/custom_countdown_timer.dart';

class ValveCycleWidget extends StatefulWidget {
  final PumpValveModel valveData;
  final String deviceId;

  const ValveCycleWidget({super.key, required this.valveData, required this.deviceId});

  @override
  State<ValveCycleWidget> createState() => _ValveCycleWidgetState();
}

class _ValveCycleWidgetState extends State<ValveCycleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: (int.parse(widget.valveData.currentCycle) /
          int.parse(widget.valveData.cyclicRestartLimit))
          .clamp(0.0, 1.0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.valveData.cyclicRestartLimit == '0') {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
                    widget.valveData.cyclicRestartInterval != '00:00:00')
                  _buildCycleCard(
                    context,
                    title: "Cycle Interval Rem.",
                    content: CountdownTimerWidget(
                      key: Key(widget.valveData.cyclicRestartInterval),
                      initialSeconds: Constants.parseTime(widget.valveData.cyclicRestartInterval).inSeconds,
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
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                    minHeight: 6,
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
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
                          onPressed: () {
                            MqttService().topicToPublishAndItsMessage(jsonEncode({'sentSms': 'resetcycle'}), '${Environment.mqttPublishTopic}/${widget.deviceId}');
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
            ),
          ],
        ),
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