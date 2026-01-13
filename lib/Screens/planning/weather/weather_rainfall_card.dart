import 'package:flutter/material.dart';

class RainfallCard extends StatelessWidget {
  final String title;
  final String rainfallValue;
  final String forecastText;
  final String description;
  final Color backgroundColor;

  const RainfallCard({
    super.key,
    this.title = "Rainfall",
    required this.rainfallValue,
    required this.forecastText,
    required this.description,
    this.backgroundColor = const Color(0xFF3C4B6C),
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
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Text(
            rainfallValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            forecastText,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
