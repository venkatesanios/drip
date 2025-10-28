import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../models/customer/site_model.dart';

class FloatSwitchPopover extends StatelessWidget {
  final WaterSourceModel source;
  final ValueNotifier<int> popoverUpdateNotifier;

  const FloatSwitchPopover({
    super.key,
    required this.source,
    required this.popoverUpdateNotifier,
  });

  @override
  Widget build(BuildContext context) {

    return Consumer<MqttPayloadProvider>(
      builder: (_, provider, __) {

        final floatSwitches = source.floatSwitches;

        return Stack(
          children: floatSwitches.map((fs) {
            final update = provider.getSensorUpdatedValve(fs.sNo.toString());
            final parts = update?.split(',') ?? [];
            final status = parts.length > 2 ? parts[2] : null;
            final text = status == '0' ? 'Low' : 'High';

            if (fs.value == "topFloatForInletPump") {
              return Positioned(
                top: 20,
                left: 13,
                child: _buildFloatSwitchIcon(text),
              );
            }
            else if (fs.value == "bottomFloatForInletPump") {
              return Positioned(
                top: 40,
                left: 17.5,
                child: _buildFloatSwitchIcon(text),
              );
            }
            else if (fs.value == "topFloatForOutletPump") {
              return Positioned(
                top: 20,
                left: 42,
                child: _buildFloatSwitchIcon(text),
              );
            } else {
              return Positioned(
                top: 40,
                left: 37,
                child: _buildFloatSwitchIcon(text),
              );
            }
          }).toList(),
        );
      },
    );

  }

  Widget _buildFloatSwitchIcon(String text) {
    return Image.asset('assets/png/float_switch.png',
      width: 15,
      height: 15,
      color: text == 'Low' ? Colors.red : Colors.green,
    );
  }

}