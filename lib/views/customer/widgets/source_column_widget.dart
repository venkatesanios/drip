import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../models/customer/site_model.dart';
import '../../../utils/constants.dart';
import '../../../utils/my_function.dart';
import 'float_switch_popover.dart';

class SourceColumnWidget extends StatelessWidget {
  final WaterSourceModel source;
  final bool isInletSource;
  final bool isAvailInlet;
  final int index;
  final int total;
  final ValueNotifier<int> popoverUpdateNotifier;
  final String deviceId;
  final int customerId;
  final int controllerId;
  final int modelId;

  const SourceColumnWidget({
    super.key,
    required this.source,
    required this.isInletSource,
    required this.isAvailInlet,
    required this.index,
    required this.total,
    required this.popoverUpdateNotifier,
    required this.deviceId,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasLevel = source.level.isNotEmpty;
    final bool hasFloatSwitch = source.floatSwitches.isNotEmpty;

    final position = isInletSource ? (index == 0 ? 'First' : 'Center') :
    (index == 0 && isAvailInlet) ? 'Last' :
    (index == 0 && !isAvailInlet) ? 'First' :
    (index == total - 1) ? 'Last' : 'Center';

    return SizedBox(
      width: 70,
      height: 100,
      child: Column(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AppConstants.getAsset('source', source.sourceType, position),
                ),
                if (hasLevel) ..._buildLevelWidgets(context),
                if (hasFloatSwitch) FloatSwitchPopover(source: source, popoverUpdateNotifier: popoverUpdateNotifier),
              ],
            ),
          ),
          Text(source.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }

  List<Widget> _buildLevelWidgets(BuildContext context) {
    return [
      Positioned(
        top: 50,
        left: 2,
        right: 2,
        child: Consumer<MqttPayloadProvider>(
          builder: (_, provider, __) {
            final sensorUpdate = provider.getSensorUpdatedValve(source.level[0].sNo.toString());
            final parts = sensorUpdate?.split(',') ?? [];
            if (parts.length > 1) source.level.first.value = parts[1];
            return _buildLevelDisplay(context, parts.isNotEmpty ? source.level.first.value : '');
          },
        ),
      ),
      Positioned(
        top: 33,
        left: 18,
        right: 18,
        child: Consumer<MqttPayloadProvider>(
          builder: (_, provider, __) {
            final sensorUpdate = provider.getSensorUpdatedValve(source.level[0].sNo.toString());
            final parts = sensorUpdate?.split(',') ?? [];
            if (parts.length > 2) source.level.first.value = parts[2];
            return _buildPercentageDisplay(source.level.first.value);
          },
        ),
      ),
    ];
  }

  Widget _buildLevelDisplay(BuildContext context, String value) => Container(
    height: 17,
    decoration: BoxDecoration(
      color: Colors.yellow,
      borderRadius: BorderRadius.circular(2),
      border: Border.all(color: Colors.grey, width: 0.5),
    ),
    child: Center(
      child: Text(
        MyFunction().getUnitByParameter(context, 'Level Sensor', value) ?? '',
        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    ),
  );

  Widget _buildPercentageDisplay(String value) => Container(
    height: 17,
    decoration: BoxDecoration(
      color: Colors.yellow,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey, width: 0.5),
    ),
    child: Center(
      child: Text('$value%', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
    ),
  );
}


class SourceColumnWidgetMobile extends StatelessWidget {
  final WaterSourceModel source;
  final bool isInletSource;
  final bool isAvailInlet;
  final int index;
  final int total;
  final ValueNotifier<int> popoverUpdateNotifier;
  final String deviceId;
  final int customerId;
  final int controllerId;
  final int modelId;

  const SourceColumnWidgetMobile({
    super.key,
    required this.source,
    required this.isInletSource,
    required this.isAvailInlet,
    required this.index,
    required this.total,
    required this.popoverUpdateNotifier,
    required this.deviceId,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasLevel = source.level.isNotEmpty;
    final bool hasFloatSwitch = source.floatSwitches.isNotEmpty;

    final position = isInletSource ? (index == 0 ? 'First' : 'Center') :
    (index == 0 && isAvailInlet) ? 'Last' :
    (index == 0 && !isAvailInlet) ? 'First' :
    (index == total - 1) ? 'Last' : 'Center';

    return SizedBox(
      width: 70,
      height: 100,
      child: Column(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AppConstants.getAsset('source', source.sourceType, position),
                ),
                if (hasLevel) ..._buildLevelWidgets(context),
                if (hasFloatSwitch) FloatSwitchPopover(source: source, popoverUpdateNotifier: popoverUpdateNotifier),
              ],
            ),
          ),
          Text(source.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ],
      ),
    );
  }

  List<Widget> _buildLevelWidgets(BuildContext context) {
    return [
      Positioned(
        top: 50,
        left: 2,
        right: 2,
        child: Consumer<MqttPayloadProvider>(
          builder: (_, provider, __) {
            final sensorUpdate = provider.getSensorUpdatedValve(source.level[0].sNo.toString());
            final parts = sensorUpdate?.split(',') ?? [];
            if (parts.length > 1) source.level.first.value = parts[1];
            return _buildLevelDisplay(context, parts.isNotEmpty ? source.level.first.value : '');
          },
        ),
      ),
      Positioned(
        top: 33,
        left: 18,
        right: 18,
        child: Consumer<MqttPayloadProvider>(
          builder: (_, provider, __) {
            final sensorUpdate = provider.getSensorUpdatedValve(source.level[0].sNo.toString());
            final parts = sensorUpdate?.split(',') ?? [];
            if (parts.length > 2) source.level.first.value = parts[2];
            return _buildPercentageDisplay(source.level.first.value);
          },
        ),
      ),
    ];
  }

  Widget _buildLevelDisplay(BuildContext context, String value) => Container(
    height: 17,
    decoration: BoxDecoration(
      color: Colors.yellow,
      borderRadius: BorderRadius.circular(2),
      border: Border.all(color: Colors.grey, width: 0.5),
    ),
    child: Center(
      child: Text(
        MyFunction().getUnitByParameter(context, 'Level Sensor', value) ?? '',
        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    ),
  );

  Widget _buildPercentageDisplay(String value) => Container(
    height: 17,
    decoration: BoxDecoration(
      color: Colors.yellow,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey, width: 0.5),
    ),
    child: Center(
      child: Text('$value%', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
    ),
  );
}