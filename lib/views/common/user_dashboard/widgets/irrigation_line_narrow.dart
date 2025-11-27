import 'package:flutter/cupertino.dart';

import '../../../../models/customer/site_model.dart';
import 'customer_widget_builders.dart';

class IrrigationLineNarrow extends StatelessWidget {
  final int customerId, controllerId, modelId;
  final String deviceId;
  final List<ValveModel> valves;
  final List<ValveModel> mainValves;
  final List<LightModel> lights;
  final List<GateModel> gates;
  final List<SensorModel> pressureIn;
  final List<SensorModel> pressureOut;
  final List<SensorModel> waterMeter;

  const IrrigationLineNarrow({
    super.key,
    required this.valves,
    required this.mainValves,
    required this.lights,
    required this.gates,
    required this.pressureIn,
    required this.pressureOut,
    required this.waterMeter,
    required this.customerId,
    required this.controllerId,
    required this.deviceId,
    required this.modelId,
  });

  @override
  Widget build(BuildContext context) {
    final baseSensors = [
      ...sensorList(sensors: pressureIn, type: 'Pressure Sensor',
          imagePath: 'assets/png/pressure_sensor.png', customerId: customerId, controllerId: controllerId),

      ...sensorList(sensors: waterMeter, type: 'Water Meter',
        imagePath: 'assets/png/water_meter_wj.png', customerId: customerId, controllerId: controllerId),
    ];

    final allItems = [
      ...lightList(list: lights, isWide: false),

      ...mainValveList(list: mainValves, customerId: customerId,
        controllerId: controllerId, modelId: modelId, isNarrow: true),

      ...valveList(valves: valves, customerId: customerId,
        controllerId: controllerId, modelId: modelId, isMobile: true),

      ...sensorList(sensors: pressureOut, type: 'Pressure Sensor',
        imagePath: 'assets/png/pressure_sensor.png', customerId: customerId, controllerId: controllerId),
    ];

    return Column(
      children: [
        if (baseSensors.isNotEmpty) ...baseSensors,
        Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: 0,
            runSpacing: 0,
            children: allItems,
          ),
        ),
      ],
    );
  }
}