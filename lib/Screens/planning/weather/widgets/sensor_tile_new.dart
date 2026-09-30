import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_rainfall_card.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_wind_card.dart';

import '../view/weather_screen_new.dart';
import '../weather_co2_card.dart';

class SensorTileNew extends StatelessWidget {
  final IconData icon;
  final String title;
  final int statusCode;
  final double value;
  final String unit;
  final double minValue;
  final double maxValue;
  final String otherValue;

  const SensorTileNew({
    super.key,
    required this.icon,
    required this.title,
    required this.statusCode,
    required this.value,
    required this.unit,
    required this.minValue,
    required this.maxValue,
    required this.otherValue,
  });


  @override
  Widget build(BuildContext context) {
if(title.contains('Co2'))
  {
     return CO2Card(icon: icon, co2Value: value.toInt(), maxValue: 2000,title: title,message:'',min: '$minValue',max: '$maxValue',other: otherValue);
  }
if(title.contains('Rain Fall'))
{
  return RainfallCard(icon: icon,rainfallValue: '$value', forecastText: '', description: '',min: '$minValue',max: '$maxValue',other: otherValue);
}
if(title.contains('Wind Direction'))
{
  return WindCard(icon: icon,directionAngle: value);
}
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
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: sensorStatusColor(statusCode),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusCode == 255 ? "Normal" : "Alert",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "${value.toStringAsFixed(2)} $unit",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Text("↓ Min: $minValue     ↑ Max: $maxValue"),
        if (otherValue.isNotEmpty)
          Text("x̄ Average: $otherValue"),
      ],
    );
  }
}