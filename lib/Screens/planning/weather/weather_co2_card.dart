import 'package:flutter/material.dart';

class CO2Card extends StatelessWidget {
  final IconData icon;
  final int co2Value;
  final int maxValue;
  final String title;
  final String message;
  final String min;
  final String max;
  final String other;

  const CO2Card({
    super.key,
    required this.co2Value,
    this.maxValue = 2000,
    this.title = "CO2 Sensor",
    required this.message,
    required this.min,
    required this.max,
    required this.other,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
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
        const SizedBox(height: 20),
        Text("↓ Min: $min     ↑ Max: $max"),
        if (other.isNotEmpty)
          Text("x̄ Average: $other"),
      ],
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
                  color: Colors.black,
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
