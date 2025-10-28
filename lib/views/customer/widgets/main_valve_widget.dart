import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../models/customer/site_model.dart';
import '../../../utils/constants.dart';

class BuildMainValve extends StatelessWidget {
  final ValveModel valve;
  final int customerId, controllerId, modelId;
  final bool isNarrow;

  const BuildMainValve({
    super.key,
    required this.valve,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
    this.isNarrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getValveOnOffStatus(
        [56, 57, 58, 59].contains(modelId)
            ? double.parse(valve.sNo.toString()).toStringAsFixed(3)
            : valve.sNo.toString(),
      ),
      builder: (_, status, __) {
        final statusParts = status?.split(',') ?? [];
        if (statusParts.isNotEmpty) {
          valve.status = int.parse(statusParts[1]);
        }

        final width = isNarrow ? 70.0 : 70.0;
        final height = isNarrow ? 60.0 : 100.0;
        final iconSize = isNarrow ? 40.0 : 70.0;

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: isNarrow ? Image.asset('assets/png/m_main_valve_gray.png',
                      color: valve.status == 0 ? Colors.grey : valve.status == 1 ? Colors.green
                          : valve.status == 1 ? Colors.orange : Colors.red,
                    ) : AppConstants.getAsset('main_valve', valve.status, ''),
                  ),
                  Text(
                    valve.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}