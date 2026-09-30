import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/view/weather_Gsm.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/widgets/sensor_tile_new.dart';

class SensorChipGsm extends StatelessWidget {
    final SensorDisplayModel device;
  final bool isNarrow;

  const SensorChipGsm({super.key,
     required this.device,
    required this.isNarrow,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: isNarrow ? double.infinity : 230,
      height: 210,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SensorTileNew(
        icon: Icons.sensors,
        title: device.name,
        statusCode: device.status,
        value: device.value,
        unit: unit(device.name),
        minValue: device.min,
        maxValue: device.max,
        otherValue: "${device.value}",
      ),
    );
  }

  String unit(String type) {
    type = type.toLowerCase();
    if (type.contains('moisture')) return 'CB';
    if (type.contains('temperature')) return '°C';
    if (type.contains('humidity')) return '%';
    if (type.contains('co2')) return 'ppm';
    if (type.contains('direction')) return '°';
    if (type.contains('wind')) return 'km/h';
    if (type.contains('rain')) return 'mm';
    if (type.contains('lux')) return 'Lu';
    if (type.contains('ldr')) return 'Ω';
    if (type.contains('leaf')) return '%';
    return '';
  }
}