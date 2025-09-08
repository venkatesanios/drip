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

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10, right: 8),
              child: Divider(height: 1, thickness: 1, color: Colors.black12),
            ),
            ListTile(
              minVerticalPadding: 0,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: const VisualDensity(vertical: -4),
              leading: Image.asset(imagePath, width: 25, height: 25),
              title: Text(
                sensor.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade200,
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
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, right: 8),
              child: Divider(height: 1, thickness: 1, color: Colors.black12),
            ),
          ],
        );
      },
    );
  }
}