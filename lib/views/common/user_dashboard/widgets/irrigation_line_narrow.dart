import 'package:flutter/material.dart';
import '../../../../models/customer/site_model.dart';
import '../../../customer/widgets/valve_widget_mobile.dart';
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

      ...sensorList(sensors: pressureOut, type: 'Pressure Sensor',
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
    ];



    return LayoutBuilder(
      builder: (context, constraints) {
        const itemWidth = 65.0;

        final itemsPerRow =
        (constraints.maxWidth / itemWidth).floor().clamp(1, 100);

        final rowHeight = itemsPerRow == 5 ? 58.0 : 65.0;

        final columns =
        (constraints.maxWidth / itemWidth).floor().clamp(1, 10);

        final rows = (allItems.length / columns).ceil();

        final gridItemWidth = constraints.maxWidth / columns;
        final gridItemHeight =
            gridItemWidth / (itemWidth / rowHeight);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (baseSensors.isNotEmpty) ...baseSensors,
            SizedBox(
              height: rows * gridItemHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: 3,
                    left: 5,
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: Divider(
                        height: 5,
                        thickness: 3,
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),

                  for (int r = 1; r < rows; r++)
                    Positioned(
                      top: r * gridItemHeight + 3,
                      left: 5,
                      right: 0,
                      child: Column(
                        children: [
                          Divider(height: 5, color: Colors.grey.shade200, thickness: 3)
                        ],
                      ),
                    ),

                  Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: allItems.map((item) {
                      final bool hasSource =
                          item is ValveWidgetMobile && item.valve.waterSources.isNotEmpty;

                      return SizedBox(
                        width: hasSource ? gridItemWidth * 2 : gridItemWidth,
                        height: gridItemHeight,
                        child: item,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}