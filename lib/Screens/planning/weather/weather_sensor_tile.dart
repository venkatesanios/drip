import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_live_model.dart';

class SensorTile extends StatelessWidget {
  final WeatherLiveUIModel data;
  final IconData icon;
  final String unit;

  const SensorTile({
    super.key,
    required this.data,
    required this.icon,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final isNormal = data.errorCode == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.objectName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sensorStatusColor(data.errorCode),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  data.errorCode == "255" ? "Normal" : "Alert",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "${data.value} $unit",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text("↓ Min: ${data.minValue}     ↑ Max: ${data.maxValue}"),
           if (data.otherValue.isNotEmpty)
            Text("x̄ Average: ${data.otherValue}"),
        ],
      ),
    );
  }
}

Color sensorStatusColor(dynamic val) {
  final code = val.toString();

  if (code == '1') {
    return Colors.red.shade700;
  } else if (code == '2') {
    return Colors.yellow.shade700;
  } else if (code == '3') {
    return Colors.orange.shade700;
  } else {
    return Colors.green.shade700;
  }
}