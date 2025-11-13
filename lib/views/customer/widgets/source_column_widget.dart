import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../Widgets/pump_widget.dart';
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
                if (hasFloatSwitch) FloatSwitchPopover(source: source,
                    popoverUpdateNotifier: popoverUpdateNotifier, isMobile: false),
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
      width : (position=='Last') ? (source.outletPump.length * 70) + 70 :
      source.outletPump.length * 70,
      height: 140,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: source.outletPump.asMap().entries.map((entry) {

              final int pumpIndex = entry.key;
              final int lastPumpIndex = source.outletPump.length - 1;
              final pump = entry.value;

              if (position=='Last') {
                return SizedBox(
                  width: 140,
                  height: 140,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: Image.asset(
                              "assets/png/mobile/m_top_pump_line.png",
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: PumpWidget(
                                    pump: pump,
                                    isSourcePump: isInletSource,
                                    deviceId: deviceId,
                                    customerId: customerId,
                                    controllerId: controllerId,
                                    isMobile: true,
                                    modelId: modelId,
                                    pumpPosition: pumpIndex==0 ? "First" : "Last",
                                  ),
                                ),
                                Positioned(
                                  bottom: 3,
                                  left: 0,
                                  right: 0,
                                  child: Text(
                                    pump.name,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if(pumpIndex==0)...[
                                  Positioned.fill(
                                    child: AppConstants.getAsset(
                                      'mobile source',
                                      source.sourceType,
                                      position,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 3,
                                    left: 0,
                                    right: 0,
                                    child: Text(
                                      source.name,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      softWrap: false,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),

                                  if (hasLevel) ..._buildLevelWidgets(context),
                                  if (hasFloatSwitch) FloatSwitchPopover(source: source,
                                    popoverUpdateNotifier: popoverUpdateNotifier, isMobile: true),

                                ]else...[
                                  Positioned.fill(
                                    child: Image.asset(
                                      (pumpIndex == lastPumpIndex) ?
                                      "assets/png/mobile/m_source_line_last.png":
                                      "assets/png/mobile/m_source_line_center.png",
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: Image.asset(
                              (pumpIndex == lastPumpIndex) ?
                              "assets/png/mobile/m_source_line_last.png":
                              "assets/png/mobile/m_source_line_center.png",
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: PumpWidget(
                            pump: pump,
                            isSourcePump: isInletSource,
                            deviceId: deviceId,
                            customerId: customerId,
                            controllerId: controllerId,
                            isMobile: true,
                            modelId: modelId,
                            pumpPosition: pumpIndex == 0 ? position : 'Center',
                          ),
                        ),
                        Positioned(
                          bottom: 3,
                          left: 0,
                          right: 0,
                          child: Text(
                            pump.name,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if(pumpIndex==0)...[
                          Positioned.fill(
                            child: AppConstants.getAsset(
                              'mobile source',
                              source.sourceType,
                              position,
                            ),
                          ),
                          Positioned(
                            bottom: 3,
                            left: 0,
                            right: 0,
                            child: Text(
                              source.name,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ]else...[
                          Positioned.fill(
                            child: Image.asset(
                              (pumpIndex == lastPumpIndex) ?
                              "assets/png/mobile/m_source_line_last.png":
                              "assets/png/mobile/m_source_line_center.png",
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }


  List<Widget> _buildLevelWidgets(BuildContext context) {
    return [
      Positioned(
        top: 33,
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
        top: 5,
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