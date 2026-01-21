import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
        const itemWidth = 70.0;
        const rowHeight = 65.0;

        final columns =
        (constraints.maxWidth / itemWidth).floor().clamp(1, 10);

        final rows = (allItems.length / columns).ceil();

        final gridItemWidth = constraints.maxWidth / columns;
        final gridItemHeight =
            gridItemWidth / (itemWidth / rowHeight);

        return Column(
          children: [
            if (baseSensors.isNotEmpty) ...baseSensors,
            SizedBox(
              height: rows * gridItemHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Divider(height: 0,)
                      ],
                    ),
                  ),
                  // horizontal row lines
                  for (int r = 1; r < rows; r++)
                    Positioned(
                      top: r * gridItemHeight - 1,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Divider(height: 0,)
                        ],
                      ),
                    ),

                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: itemWidth / rowHeight,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                    ),
                    itemCount: allItems.length,
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.centerLeft, // LEFT aligned
                        child: allItems[index],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );


    return LayoutBuilder(
      builder: (context, constraints) {
        const itemWidth = 70;
        const rowHeight = 65;

        final columns = (constraints.maxWidth / itemWidth).floor().clamp(1, 10);

        final rows = (allItems.length / columns).ceil();

        return Column(
          children: [
            if (baseSensors.isNotEmpty) ...baseSensors,
            SizedBox(
              height: rows * rowHeight.toDouble(),
              child: Stack(
                children: [
                  for (int r = 0; r < rows; r++)...[
                    Positioned(
                      top: r * (rowHeight+1.5) + 1,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        color: Colors.grey.shade200,
                      ),
                    ),
                    Positioned(
                      top: r * (rowHeight+1.5) + 4,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ],


                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      childAspectRatio: itemWidth / rowHeight,
                    ),
                    itemCount: allItems.length,
                    itemBuilder: (context, index) {
                      return allItems[index];
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

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