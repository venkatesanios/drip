import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/widgets/periodicCard.dart';

class RainfallCard extends StatelessWidget {
  final String title;
  final String rainfallValue;
  final String forecastText;
  final String description;
  final Color backgroundColor;

  final String min;
  final String max;
  final String other;

  final IconData icon;

  // Last 7 days
  final double last7DaysMin;
  final double last7DaysMax;
  final double last7DaysAverage;

  // Last 30 days
  final double last30DaysMin;
  final double last30DaysMax;
  final double last30DaysAverage;

  const RainfallCard({
    super.key,
    this.title = 'Rainfall',
    required this.rainfallValue,
    required this.forecastText,
    required this.description,
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
    this.backgroundColor = const Color(0xFF3C4B6C),
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

        // Rainfall current value
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              rainfallValue,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),

            const SizedBox(width: 5),

            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                'mm',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),

        // Forecast text only when available
        if (forecastText.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            forecastText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],

        // Description only when available
        if (description.trim().isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],

        // Push period cards to bottom
        const Spacer(),

        // Current Day
        SensorPeriodCard(
          title: 'Current Day',
          minValue: min,
          maxValue: max,
          averageValue: other,
        ),

        const SizedBox(height: 10),

        // Last 7 Days
        SensorPeriodCard(
          title: 'Last 7 Days',
          minValue: last7DaysMin.toStringAsFixed(2),
          maxValue: last7DaysMax.toStringAsFixed(2),
          averageValue: last7DaysAverage.toStringAsFixed(2),
        ),

        const SizedBox(height: 10),

        // Last Month
        SensorPeriodCard(
          title: 'Last Month',
          minValue: last30DaysMin.toStringAsFixed(2),
          maxValue: last30DaysMax.toStringAsFixed(2),
          averageValue: last30DaysAverage.toStringAsFixed(2),
        ),
      ],
    );
  }
}