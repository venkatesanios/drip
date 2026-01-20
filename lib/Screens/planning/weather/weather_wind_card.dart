
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/svg.dart';

class WindCard extends StatelessWidget {
  final String windSpeed;
  final String gusts;
  final String directionText;
  final double directionAngle;

  const WindCard({
    super.key,
    required this.windSpeed,
    required this.gusts,
    required this.directionText,
    required this.directionAngle,
  });

  @override
  Widget build(BuildContext context) {
    return _baseCard(
      title: "Wind",
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _KeyValueRow("Wind Speed", windSpeed),
                // const SizedBox(height: 8),
                // _KeyValueRow("Gusts", gusts),
                const SizedBox(height: 8),
                _KeyValueRow("Wind Direction ", directionText),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _WindCompass(angle: directionAngle),
        ],
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final String keyText;
  final String value;

  const _KeyValueRow(this.keyText, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(keyText, style: const TextStyle(fontSize: 13)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

class _WindCompass extends StatelessWidget {
  final double angle;
  const _WindCompass({required this.angle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background SVG
          SvgPicture.asset(
            'assets/Images/Svg/winddirection.svg',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),

          // ✅ Center text (degree value)
          Text(
            "${angle.toInt()}°",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
           // ✅ Arrow on edge, rotating around center
          Transform.rotate(
            angle: angle * math.pi / 180,
            child: Transform.translate(
              offset: const Offset(0, -22),
              child: const Icon(
                Icons.navigation,
                size: 18,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _baseCard({required String title, required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
