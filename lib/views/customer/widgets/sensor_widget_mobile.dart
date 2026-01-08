import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/customer/site_model.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../utils/my_function.dart';

class SensorWidgetMobile extends StatelessWidget {
  final SensorModel sensor;
  final String sensorType;
  final String imagePath;
  final int customerId, controllerId;

  const SensorWidgetMobile({
    super.key,
    required this.sensor,
    required this.sensorType,
    required this.imagePath,
    required this.customerId,
    required this.controllerId,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getSensorUpdatedValve(sensor.sNo.toString()),
      builder: (_, status, __) {
        final statusParts = status?.split(',') ?? [];
        if (statusParts.isNotEmpty) {
          sensor.value = statusParts[1];
        }

        return ListTile(
          minVerticalPadding: 0,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          visualDensity: const VisualDensity(vertical: -4),
          title: Text(
            sensor.name,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          trailing: sensorType == 'Pressure Switch' ?
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sensor.value == "1" ? Colors.green.shade300 : Colors.red.shade300,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                child: Text(
                  sensor.value == "1" ? 'Low' : 'High',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: sensorType != 'Pressure Switch' ? Colors.black87 : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const SizedBox(
                width: 25,
                height: 25,
                child: Image(image: AssetImage('assets/png/mobile/m_pressure_switch.png')),
              )
            ],
          ) :
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade400,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                child: Text(
                  MyFunction().getUnitByParameter(context, sensorType, sensor.value.toString(),) ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: 40,
                height: 40,
                child: Image(image: AssetImage( sensorType == 'Pressure Sensor' ?
                'assets/png/mobile/m_pressure_sensor.png' : 'assets/png/mobile/m_water_meter.png'),
                  color: Colors.black),
              )
            ],
          ),
        );
      },
    );
  }
}