import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/widgets/periodicCard.dart';

class CO2Card extends StatelessWidget {
  final IconData icon;
  final int co2Value;
  final int maxValue;
  final String title;
  final String message;

  // Current day values
  final String min;
  final String max;
  final String other;

  // Last 7 days
  final double last7DaysMin;
  final double last7DaysMax;
  final double last7DaysAverage;

  // Last 30 days
  final double last30DaysMin;
  final double last30DaysMax;
  final double last30DaysAverage;

  const CO2Card({
    super.key,
    required this.co2Value,
    this.maxValue = 2000,
    this.title = 'CO2 Sensor',
    required this.message,
    required this.min,
    required this.max,
    required this.other,
    required this.icon,
    required this.last7DaysMin,
    required this.last7DaysMax,
    required this.last7DaysAverage,
    required this.last30DaysMin,
    required this.last30DaysMax,
    required this.last30DaysAverage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 21,
                color: Colors.black87,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // CO2 value
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              co2Value.toString(),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),

            const SizedBox(width: 5),

            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                'ppm',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // CO2 level bar
        _co2Bar(value: co2Value),

        if (message.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],

        // Important:
        // Push all period cards to the bottom
        // so CO2 matches other sensor card heights.
        const Spacer(),

        SensorPeriodCard(
          title: 'Current Day',
          minValue: min,
          maxValue: max,
          averageValue: other,
        ),

        const SizedBox(height: 10),

        SensorPeriodCard(
          title: 'Last 7 Days',
          minValue: last7DaysMin.toStringAsFixed(2),
          maxValue: last7DaysMax.toStringAsFixed(2),
          averageValue: last7DaysAverage.toStringAsFixed(2),
        ),

        const SizedBox(height: 10),

        SensorPeriodCard(
          title: 'Last Month',
          minValue: last30DaysMin.toStringAsFixed(2),
          maxValue: last30DaysMax.toStringAsFixed(2),
          averageValue: last30DaysAverage.toStringAsFixed(2),
        ),
      ],
    );
  }

  Widget _co2Bar({
    required int value,
  }) {
    final safeMaxValue = maxValue <= 0 ? 1 : maxValue;

    final percent = (value / safeMaxValue)
        .clamp(0.0, 1.0)
        .toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;

        final maxLeft =
        (barWidth - 12).clamp(0.0, barWidth).toDouble();

        final indicatorLeft =
        (percent * barWidth - 6)
            .clamp(0.0, maxLeft)
            .toDouble();

        return SizedBox(
          height: 16,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.green,
                      Colors.yellow,
                      Colors.red,
                    ],
                  ),
                ),
              ),

              Positioned(
                left: indicatorLeft,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}