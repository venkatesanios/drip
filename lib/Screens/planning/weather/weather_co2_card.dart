import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CO2Card extends StatelessWidget {
  final int co2Value;
  final int maxValue;
  final String title;
  final String message;
  final Color backgroundColor;

  const CO2Card({
    super.key,
    required this.co2Value,
    this.maxValue = 2000,
    this.title = "CO2 Sensor",
    required this.message,
    this.backgroundColor = const Color(0xFFDDE8FF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            "CO2 Level: $co2Value ppm",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _co2Bar(value: co2Value),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _co2Bar({required int value}) {
    final percent = (value / maxValue).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [Colors.green, Colors.yellow, Colors.red],
                ),
              ),
            ),
            Positioned(
              left: percent * barWidth - 6, // center the knob
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
