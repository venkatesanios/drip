import 'package:flutter/material.dart';
import '../../../Constants/constants.dart';
import '../model/pump_controller_data_model.dart';
import '../widget/custom_countdown_timer.dart';

class ValveCycleWidget extends StatefulWidget {
  final PumpValveModel valveData;

  const ValveCycleWidget({super.key, required this.valveData});

  @override
  _ValveCycleWidgetState createState() => _ValveCycleWidgetState();
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.valveData.valveOnMode == '1' &&
                    widget.valveData.cyclicRestartFlag == '0' &&
                    widget.valveData.cyclicRestartInterval != '00:00:00')
                  _buildCycleCard(
                    context,
                    title: "Interval",
                    content: CountdownTimerWidget(
                      key: const Key("testing"),
                      initialSeconds: Constants.parseTime(
                          widget.valveData.cyclicRestartInterval)
                          .inSeconds,
                    ),
                  ),
                _buildCycleCard(
                  context,
                  title: "Total",
                  content: Text(
                    widget.valveData.cyclicRestartLimit,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildCycleCard(
                  context,
                  title: "Current",
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