import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CustomGauge extends StatelessWidget {
  final double currentValue;
  final double maxValue;

  const CustomGauge({super.key, required this.currentValue, required this.maxValue});

  @override
  Widget build(BuildContext context) {

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: maxValue > 100 ? maxValue+1 : maxValue+0.1,
          showLabels: true,
          showTicks: true,
          interval: maxValue,
          axisLineStyle: AxisLineStyle(
            thickness: 0.2,
            thicknessUnit: GaugeSizeUnit.factor,
            cornerStyle: CornerStyle.bothCurve,
            color: Colors.grey[300],
          ),
          pointers: <GaugePointer>[
            RangePointer(
              value: currentValue,
              width: 0.2,
              sizeUnit: GaugeSizeUnit.factor,
              enableAnimation: false,
              animationDuration: 1500,
              gradient: SweepGradient(
                colors: [Theme.of(context).primaryColor.withOpacity(0.5), Theme.of(context).primaryColor],
                stops: const [0.2, 0.8],
              ),
              cornerStyle: CornerStyle.bothCurve,
            ),
            MarkerPointer(
              value: currentValue,
              markerOffset: -10,
              enableDragging: true,
              markerType: MarkerType.invertedTriangle,
              color: Theme.of(context).primaryColor,
              markerHeight: 10,
              markerWidth: 10,
            ),
          ],
          majorTickStyle: const MajorTickStyle(
            length: 0.1,
            thickness: 1,
            lengthUnit: GaugeSizeUnit.factor,
            color: Colors.blueGrey,
          ),
          minorTickStyle: MinorTickStyle(
            length: 0.05,
            thickness: 1.5,
            lengthUnit: GaugeSizeUnit.factor,
            color: Colors.blueGrey[300],
          ),
        ),
      ],
    );
  }
}