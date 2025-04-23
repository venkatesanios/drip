import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../Models/customer/site_model.dart';
import '../StateManagement/duration_notifier.dart';
import '../StateManagement/mqtt_payload_provider.dart';
import '../repository/repository.dart';
import '../services/http_service.dart';
import '../services/mqtt_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../utils/snack_bar.dart';

class PumpWidget extends StatelessWidget {
  final PumpModel pump;
  final bool isSourcePump;
  final String deviceId;
  final int customerId, controllerId;
  PumpWidget({super.key, required this.pump, required this.isSourcePump,
    required this.deviceId, required this.customerId, required this.controllerId});

  final ValueNotifier<int> popoverUpdateNotifier = ValueNotifier<int>(0);

  static const excludedReasons = [
    '3', '4', '5', '6', '21', '22', '23', '24',
    '25', '26', '27', '28', '29', '30', '31'
  ];

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, Tuple2<String?, String?>>(
      selector: (_, provider) => Tuple2(
        provider.getPumpOnOffStatus(pump.sNo.toString()),
        provider.getPumpOtherData(pump.sNo.toString()),
      ),
      builder: (_, data, __) {
        final status = data.item1;
        final other = data.item2;

        final statusParts = status?.split(',') ?? [];
        if (statusParts.length > 1) {
          pump.status = int.tryParse(statusParts[1]) ?? 0;
        }

        final otherParts = other?.split(',') ?? [];
        if (otherParts.length >= 8) {
          pump.reason = otherParts[1];
          pump.setValue = otherParts[2];
          pump.actualValue = otherParts[3];
          pump.phase = otherParts[4];
          pump.voltage = otherParts[5];
          pump.current = otherParts[6];
          pump.onDelayLeft = otherParts[7];
        }

        final hasVoltage = pump.voltage.isNotEmpty;
        final voltages = hasVoltage ? pump.voltage.split('_') : [];
        final currents = hasVoltage ? pump.current.split('_') : [];

        final List<String> columns = ['-', '-', '-'];
        if (hasVoltage) {
          for (var pair in currents) {
            final parts = pair.trim().replaceAll('"', '').split(':');
            if (parts.length == 2) {
              final index = int.tryParse(parts[0].trim());
              if (index != null && index >= 1 && index <= columns.length) {
                columns[index - 1] = parts[1].trim();
              }
            }
          }
        }

        return Stack(
          children: [
            SizedBox(
              width: 70,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Builder(
                    builder: (buttonContext) => Tooltip(
                      message: 'View more details',
                      child: TextButton(
                        onPressed: () {
                          showPopover(
                            context: buttonContext,
                            bodyBuilder: (context) {
                              return ValueListenableBuilder<int>(
                                valueListenable: popoverUpdateNotifier,
                                builder: (context, _, __) {
                                  return Material(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        hasVoltage
                                            ? _buildVoltagePopoverContent(context, voltages, columns)
                                            : _buildManualControlButtons(context),
                                        if (isSourcePump) _buildBottomControlButtons(context),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            onPop: () => print('Popover was popped!'),
                            direction: PopoverDirection.bottom,
                            width: 325,
                            arrowHeight: 15,
                            arrowWidth: 30,
                          );
                        },
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                          minimumSize: WidgetStateProperty.all(Size.zero),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: WidgetStateProperty.all(Colors.transparent),
                        ),
                        child: kIsWeb && pump.status == 1?
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: Stack(
                            children: [
                              GifImageWeb(imagePath: 'assets/gif/dp_irr_pump_g.gif'),
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () {
                                    showPopover(
                                      context: buttonContext,
                                      bodyBuilder: (context) {
                                        return ValueListenableBuilder<int>(
                                          valueListenable: popoverUpdateNotifier,
                                          builder: (context, _, __) {
                                            return Material(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  hasVoltage
                                                      ? _buildVoltagePopoverContent(context, voltages, columns)
                                                      : _buildManualControlButtons(context),
                                                  if (isSourcePump) _buildBottomControlButtons(context),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      onPop: () => print('Popover was popped!'),
                                      direction: PopoverDirection.bottom,
                                      width: 325,
                                      arrowHeight: 15,
                                      arrowWidth: 30,
                                    );
                                  },
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ) :
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: AppConstants.getAsset('pump', pump.status, ''),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pump.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),

            if (pump.onDelayLeft != '00:00:00' && Formatters().isValidTimeFormat(pump.onDelayLeft))
              Positioned(
                top: 40,
                left: 7.5,
                child: Container(
                  width: 55,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                    border: Border.all(color: Colors.green, width: 0.5),
                  ),
                  child: ChangeNotifierProvider(
                    create: (_) => DecreaseDurationNotifier(pump.onDelayLeft),
                    child: Consumer<DecreaseDurationNotifier>(
                      builder: (context, notifier, _) {
                        return Center(
                          child: Column(
                            children: [
                              const Text("On delay", style: TextStyle(fontSize: 10, color: Colors.black)),
                              const Divider(height: 0, color: Colors.grey),
                              Text(notifier.onDelayLeft, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            if (int.tryParse(pump.reason) case final reason? when reason > 0 && reason != 31)
              Positioned(
                top: 1,
                left: 37.5,
                child: Tooltip(
                  message: getContentByCode(reason),
                  textStyle: const TextStyle(color: Colors.black54),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const CircleAvatar(
                    radius: 11,
                    backgroundColor: Colors.deepOrangeAccent,
                    child: Icon(Icons.info_outline, size: 17, color: Colors.white),
                  ),
                ),
              ),

            if (pump.reason == '11' || pump.reason == '22')
              Positioned(
                top: 40,
                left: 0,
                child: Container(
                  width: 67,
                  decoration: BoxDecoration(
                    color: pump.status == 1 ? Colors.greenAccent : Colors.yellowAccent,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text('Max: ${pump.actualValue}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        const Divider(height: 0, color: Colors.grey, thickness: 0.5),
                        Text(
                          pump.status == 1 ? 'cRm: ${pump.setValue}' : 'Brk: ${pump.setValue}',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              )

            else if (pump.reason == '8' && isTimeFormat(pump.actualValue.split('_').last))
              Positioned(
                top: 40,
                left: 0,
                child: Container(
                  width: 67,
                  decoration: BoxDecoration(
                    color: pump.status == 1 ? Colors.greenAccent : Colors.yellowAccent,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('Restart within', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        const Divider(height: 0, color: Colors.grey, thickness: 0.5),
                        Text(
                          pump.actualValue.split('_').last,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildVoltagePopoverContent(BuildContext context, voltages, columns) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const Divider(height: 0),
        if (int.tryParse(pump.reason) != null &&
            int.parse(pump.reason) > 0 &&
            int.parse(pump.reason) != 31)
          _buildReasonContainer(context),
        const SizedBox(height: 5),
        _buildPhaseInfo(),
        const SizedBox(height: 7),
        _buildVoltageCurrentInfo('Voltage', voltages, ['RY', 'YB', 'BR']),
        const SizedBox(height: 7),
        _buildVoltageCurrentInfo('Current', columns, ['RC', 'YC', 'BC']),
        const SizedBox(height: 7),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: 300,
      height: 35,
      color: Colors.white,
      child: const Row(
        children: [
          SizedBox(width: 8),
          Text.rich(
            TextSpan(
              text: 'Version : ',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          Spacer(),
          SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildReasonContainer(BuildContext context) {
    return Container(
      width: 315,
      height: 33,
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                pump.reason == '8' &&
                    isTimeFormat(pump.actualValue.split('_').last)
                    ? '${getContentByCode(int.parse(pump.reason))}, It will be restart automatically within ${pump.actualValue.split('_').last} (hh:mm:ss)'
                    : getContentByCode(int.parse(pump.reason)),
                style: const TextStyle(
                    fontSize: 11, color: Colors.black87, fontWeight: FontWeight.normal),
              ),
            ),
          ),
          if (!excludedReasons.contains(pump.reason))
            SizedBox(
              height: 23,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.redAccent.shade200,
                ),
                onPressed: () {
                  // Add reset logic
                },
                child: const Text('Reset',
                    style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Widget _buildPhaseInfo() {
    int phase = int.tryParse(pump.phase) ?? 0;
    return Container(
      width: 300,
      height: 25,
      color: Colors.transparent,
      child: Row(
        children: [
          const SizedBox(width: 100, child: Text('Phase', style: TextStyle(color: Colors.black54))),
          const Spacer(),
          for (int i = 0; i < 3; i++)
            Row(
              children: [
                CircleAvatar(
                  radius: 7,
                  backgroundColor: phase > i ? Colors.green : Colors.red.shade100,
                ),
                const VerticalDivider(color: Colors.transparent),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildVoltageCurrentInfo(String label, List<String> values, List<String> prefixes) {
    return Container(
      width: 310,
      height: 25,
      color: Colors.transparent,
      child: Row(
        children: [
          SizedBox(
              width: 85,
              child: Text(label, style: const TextStyle(color: Colors.black54))),
          ...List.generate(3, (index) {
            Color bgColor, borderColor;
            switch (index) {
              case 0:
                bgColor = Colors.red.shade50;
                borderColor = Colors.red.shade200;
                break;
              case 1:
                bgColor = Colors.yellow.shade50;
                borderColor = Colors.yellow.shade500;
                break;
              case 2:
                bgColor = Colors.blue.shade50;
                borderColor = Colors.blue.shade300;
                break;
              default:
                bgColor = Colors.white;
                borderColor = Colors.grey;
            }
            return Padding(
              padding: const EdgeInsets.only(left: 7),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 0.7),
                  borderRadius: BorderRadius.circular(3.0),
                ),
                width: 65,
                height: 40,
                child: Center(
                  child: Text(
                    '${prefixes[index]} : ${values[index]}',
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildManualControlButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        MaterialButton(
          color: Colors.green,
          textColor: Colors.white,
          onPressed: () {
            // Start logic
          },
          child: const Text('Start Manually'),
        ),
        const SizedBox(height: 8),
        MaterialButton(
          color: Colors.redAccent,
          textColor: Colors.white,
          onPressed: () {
            // Stop logic
          },
          child: const Text('Stop Manually'),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildBottomControlButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Spacer(),
          MaterialButton(
            color: Colors.green,
            textColor: Colors.white,
            onPressed: () {
              final payload = '${pump.sNo},1,1';
              final payLoadFinal = jsonEncode({"6200": {"6201": payload}});
               MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
              sentUserOperationToServer('${pump.name} Start Manually', payLoadFinal);
              GlobalSnackBar.show(context, 'Pump start comment sent successfully', 200);
              Navigator.pop(context);
            },
            child: const Text('Start Manually'),
          ),
          const SizedBox(width: 8),
          MaterialButton(
            color: Colors.redAccent,
            textColor: Colors.white,
            onPressed: () {
              final payload = '${pump.sNo},0,1';
              final payLoadFinal = jsonEncode({"6200": {"6201": payload}});
               MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
              sentUserOperationToServer('${pump.name} Stop Manually', payLoadFinal);
              GlobalSnackBar.show(context, 'Pump stop comment sent successfully', 200);
              Navigator.pop(context);
            },
            child: const Text('Stop Manually'),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  bool isTimeFormat(String value) {
    final timeRegExp = RegExp(r'^([0-1]?\d|2[0-3]):[0-5]\d:[0-5]\d$');
    return timeRegExp.hasMatch(value);
  }

  String getContentByCode(int code) {
    return PumpReasonCode.fromCode(code).content;
  }

  void sentUserOperationToServer(String msg, String data) async
  {
    Map<String, Object> body = {"userId": customerId, "controllerId": controllerId, "messageStatus": msg, "hardware": jsonDecode(data), "createUser": customerId};
    final response = await Repository(HttpService()).createUserSentAndReceivedMessageManually(body);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}