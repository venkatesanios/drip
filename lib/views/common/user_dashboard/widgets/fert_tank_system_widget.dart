import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oro_drip_irrigation/models/customer/site_model.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../../../StateManagement/mqtt_payload_provider.dart';
import '../../../../repository/repository.dart';
import '../../../../services/http_service.dart';
import '../../../../services/mqtt_service.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';
import '../../../../utils/snack_bar.dart';

/// NEW fertilizer tank concept (shown only when fertilizerChannel exists).
/// Everything flows left -> right:
///
///  [Main source]─[Pump]─┬─[inlet valve]─[Tank 5]─┬─[outlet valve 1]──●──●──●──●
///                       │                        └─[outlet valve 2]──●──●
///                       └─[inlet valve]─[Tank 6]───[outlet valve 3]──●──●──●
///                                                                    I1 I2 I3 I4   (injectors)
///
/// A dot on an injector column means "this valve feeds that injector".
/// Injector columns are joined at the top only.

const _excludedReasons = [
  '3', '4', '5', '6', '21', '22', '23', '24',
  '25', '26', '27', '28', '29', '30', '31'
];

class FertTankSystemWidget extends StatelessWidget {
  final FertTankSystem system;
  final int customerId, controllerId, modelId;
  final String deviceId;

  const FertTankSystemWidget({
    super.key,
    required this.system,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
    required this.deviceId,
  });

  static const double colW = 76;
  static const double connW = 22;
  static const double rowH = 74;
  static const double iconCy = 20;
  static const double injGap = 30;
  static final Color lineColor = Colors.blueGrey.shade100;
  static final Color injColor = Colors.blueGrey.shade100;

  double _cy(int row) => row * rowH + iconCy;

  @override
  Widget build(BuildContext context) {
    final tanks = system.tanks;
    final mains = system.mainSources;

    // ---------- main section ----------
    final mainWidths =
    mains.map((m) => colW + m.pumps.length * (connW + colW)).toList();
    final maxMainW = mainWidths.isEmpty ? 0.0 : mainWidths.reduce(math.max);
    final collectorX = maxMainW + 16;

    // ---------- tank groups ----------
    final groups = <_Group>[];
    int row = 0;
    for (final t in tanks) {
      final k = math.max(1, t.outletValves.length);
      final inletW =
      t.inletValves.isEmpty ? 0.0 : t.inletValves.length * colW + connW;
      final tankX = collectorX + connW + inletW;
      final tankRight = tankX + colW;
      final forkX = tankRight + 12;
      final valveX = forkX + 12;
      groups.add(_Group(t, row, k, tankX, tankRight, forkX, valveX));
      row += k;
    }
    final totalRows = math.max(row, mains.length);

    // ---------- injector columns ----------
    final injNames = <double, String>{};
    for (final t in tanks) {
      for (final v in t.outletValves) {
        for (int i = 0; i < v.channelSNos.length; i++) {
          injNames[v.channelSNos[i]] = v.channelNames[i];
        }
      }
    }
    final injSNos = injNames.keys.toList()..sort();

    double crossStart = 0;
    for (final g in groups) {
      if (g.tank.outletValves.isNotEmpty) {
        crossStart = math.max(crossStart, g.valveX + colW);
      }
    }
    double injX(int j) => crossStart + 16 + j * injGap;
    final crossEnd =
    injSNos.isEmpty ? crossStart : injX(injSNos.length - 1) + 18;

    final tanksEnd = groups.isEmpty
        ? collectorX
        : groups.map((g) => g.tankRight).reduce(math.max);
    final width = math.max(crossEnd, tanksEnd) + 6;

    // ---------- vertical layout ----------
    final chipTop = _cy(totalRows - 1) + 26;
    final joinTopY = _cy(0) - 20;
    final height = injSNos.isEmpty ? totalRows * rowH : chipTop + 24;

    // ---------- build drawing ----------
    final c = <Widget>[];

    c.add(Positioned(left: 0, top: -14, child: _caption('FERT MAIN SOURCE')));
    c.add(Positioned(
        left: collectorX, top: -14, child: _caption('FERTILIZER TANKS')));
    if (injSNos.isNotEmpty) {
      c.add(Positioned(
          left: crossStart + 4, top: -14, child: _caption('INJECTORS')));
    }

    // ---------- main source rows ----------
    for (int i = 0; i < mains.length; i++) {
      c.add(Positioned(
          left: 0, top: i * rowH, child: _mainRow(context, mains[i])));
      c.add(_h(mainWidths[i], _cy(i), collectorX - mainWidths[i]));
    }

    // ---------- collector ----------
    final lastGroupRow = groups.isEmpty ? 0 : groups.last.row;
    final collectorBottom = _cy(math.max(lastGroupRow, mains.length - 1));
    if (collectorBottom > _cy(0)) {
      c.add(_v(collectorX, _cy(0), collectorBottom));
    }

    // ---------- tank groups ----------
    for (final g in groups) {
      final t = g.tank;
      final y = _cy(g.row);

      c.add(_h(collectorX, y, g.tankX - collectorX));
      for (int i = 0; i < t.inletValves.length; i++) {
        c.add(Positioned(
          left: collectorX + connW + i * colW,
          top: g.row * rowH,
          width: colW,
          child: _valveChip(context, t.inletValves[i], isInlet: true),
        ));
      }
      c.add(Positioned(
        left: g.tankX,
        top: g.row * rowH,
        width: colW,
        child: _tankBox(t),
      ));

      if (t.outletValves.isEmpty) continue;

      c.add(_h(g.tankRight, y, g.forkX - g.tankRight));
      if (g.rows > 1) c.add(_v(g.forkX, y, _cy(g.row + g.rows - 1)));

      for (int s = 0; s < t.outletValves.length; s++) {
        final v = t.outletValves[s];
        final r = g.row + s;
        final vy = _cy(r);
        c.add(_h(g.forkX, vy, g.valveX - g.forkX));
        c.add(Positioned(
          left: g.valveX,
          top: r * rowH,
          width: colW,
          child: _valveChip(context, v, isInlet: false),
        ));

        // valve -> injectors (crossbar)
        final feeds = <int>[];
        for (int j = 0; j < injSNos.length; j++) {
          if (v.channelSNos.contains(injSNos[j])) feeds.add(j);
        }
        c.add(_h(
            g.valveX + colW,
            vy,
            (feeds.isEmpty ? crossStart : injX(feeds.last)) -
                (g.valveX + colW)));
        for (final j in feeds) {
          c.add(Positioned(
            left: injX(j) - 5,
            top: vy - 5,
            width: 10,
            height: 10,
            child: DecoratedBox(
              decoration:
              BoxDecoration(color: injColor, shape: BoxShape.circle),
            ),
          ));
        }
      }
    }

    // ---------- injector columns + chips (top join only) ----------
    if (injSNos.isNotEmpty) {
      final firstX = injX(0);
      final lastX = injX(injSNos.length - 1);

      // top rail only
      c.add(_h(firstX - 0, joinTopY, (lastX + 20) - (firstX - 8)));

      for (int j = 0; j < injSNos.length; j++) {
        // vertical column from top rail down to chip
        c.add(_v(injX(j), joinTopY, chipTop));

        // injector chip
        c.add(Positioned(
          left: injX(j) - 14,
          top: chipTop,
          width: 28,
          height: 20,
          child: Tooltip(
            message: injNames[injSNos[j]] ?? '',
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: injColor, width: 1),
              ),
              child: Center(
                child: Text(
                  _shortNo(injNames[injSNos[j]] ?? ''),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 42, left: 4, right: 4, bottom: 8),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(clipBehavior: Clip.none, children: c),
      ),
    );
  }

  // ---------- drawing helpers ----------
  Widget _h(double left, double y, double w) => Positioned(
    left: left,
    top: y - 1,
    width: math.max(0, w),
    height: 2,
    child: ColoredBox(color: lineColor),
  );

  Widget _v(double x, double y1, double y2) => Positioned(
    left: x - 1,
    top: y1 - 1,
    width: 2,
    height: (y2 - y1) + 2,
    child: ColoredBox(color: lineColor),
  );

  Widget _caption(String t) => Text(
    t,
    style: TextStyle(
      fontSize: 8,
      letterSpacing: 0.6,
      color: Colors.blueGrey.shade400,
      fontWeight: FontWeight.w600,
    ),
  );

  String _shortNo(String name) {
    final m = RegExp(r'(\d+)\s*$').firstMatch(name);
    return m == null ? name : m.group(1)!;
  }

  // ------------------------------------------------------------
  // Main source (sourceType 6) ── pump ── pump
  // ------------------------------------------------------------
  Widget _mainRow(BuildContext context, FertMainSource m) {
    final src = m.source;
    final level = src.level.isNotEmpty ? src.level.first.value : '-';
    return SizedBox(
      height: rowH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: colW,
            child: _box(
              icon: Icons.water,
              color: Colors.black54,
              border: Colors.black12,
              iconColor: Colors.white,
              name: src.name,
              sub: level == '-' ? null : 'L: $level',
            ),
          ),
          for (final pump in m.pumps) ...[
            Padding(
              padding: const EdgeInsets.only(top: iconCy - 1),
              child: Container(width: connW, height: 2, color: lineColor),
            ),
            SizedBox(width: colW, child: _pumpChip(context, pump)),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // Pump chip: color by ON/OFF, tooltip on hover, popover on tap
  // ------------------------------------------------------------
  Widget _pumpChip(BuildContext context, PumpModel pump) {
    return Selector<MqttPayloadProvider, Tuple2<String?, String?>>(
      selector: (_, p) => Tuple2(
        p.getPumpOnOffStatus(pump.sNo.toString()),
        p.getPumpOtherData(pump.sNo.toString()),
      ),
      builder: (_, data, __) {
        _applyPumpPayload(pump, data.item1, data.item2);
        final bool on = pump.status == 1;
        final int? reason = int.tryParse(pump.reason);
        final bool hasReason = reason != null && reason > 0 && reason != 31;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (buttonContext) => Tooltip(
                message: '${pump.name}\n'
                    '${on ? 'ON' : 'OFF'}'
                    '${hasReason ? '\n${PumpReasonCode.fromCode(reason).content}' : ''}'
                    '\nTap for details',
                child: GestureDetector(
                  onTap: () => _showPumpPopover(buttonContext, pump),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: on
                              ? Colors.green.shade400
                              : Colors.grey.shade300,
                          border: Border.all(
                            color: on ? Colors.green.shade700 : Colors.black38,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/svg_images/pump.svg',
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                            colorFilter: ColorFilter.mode(
                              on ? Colors.white : Colors.black54,
                              BlendMode.srcIn,
                            ),
                            placeholderBuilder: (_) => const Icon(
                                Icons.error, size: 20, color: Colors.red),
                          ),
                        ),
                      ),
                      // small warning dot when the pump has a fault/reason
                      if (hasReason)
                        const Positioned(
                          right: -3,
                          top: -3,
                          child: CircleAvatar(
                            radius: 6,
                            backgroundColor: Colors.deepOrangeAccent,
                            child: Icon(Icons.priority_high,
                                size: 9, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: colW - 6,
              child: Text(
                pump.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // same parsing as PumpWidget
  void _applyPumpPayload(PumpModel pump, String? status, String? other) {
    final sp = status?.split(',') ?? [];
    if (sp.length > 1) pump.status = int.tryParse(sp[1]) ?? pump.status;

    final op = other?.split(',') ?? [];
    if (op.length >= 8) {
      pump.reason = op[1];
      pump.setValue = op[2];
      pump.actualValue = op[3];
      pump.phase = op[4];
      pump.voltage = op[5];
      pump.current = op[6];
      pump.onDelayLeft = op[7];
    }
  }

  void _showPumpPopover(BuildContext buttonContext, PumpModel pump) {
    showPopover(
      context: buttonContext,
      direction: PopoverDirection.bottom,
      width: 325,
      arrowHeight: 15,
      arrowWidth: 30,
      bodyBuilder: (popCtx) {
        // live: popover refreshes while MQTT data changes
        return Selector<MqttPayloadProvider, Tuple2<String?, String?>>(
          selector: (_, p) => Tuple2(
            p.getPumpOnOffStatus(pump.sNo.toString()),
            p.getPumpOtherData(pump.sNo.toString()),
          ),
          builder: (_, data, __) {
            _applyPumpPayload(pump, data.item1, data.item2);
            return Material(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pumpPopoverBody(popCtx, pump),
                  _pumpControlButtons(popCtx, pump),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _pumpPopoverBody(BuildContext ctx, PumpModel pump) {
    final reason = int.tryParse(pump.reason);
    final hasVoltage = pump.voltage.isNotEmpty;
    final voltages = hasVoltage ? pump.voltage.split('_') : <String>[];

    // current format: "1:2.5_2:2.4_3:2.6"
    final columns = ['-', '-', '-'];
    if (hasVoltage) {
      for (final pair in pump.current.split('_')) {
        final p = pair.trim().replaceAll('"', '').split(':');
        if (p.length == 2) {
          final i = int.tryParse(p[0].trim());
          if (i != null && i >= 1 && i <= 3) columns[i - 1] = p[1].trim();
        }
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reason != null && reason > 0 && reason != 31)
          _pumpReasonBar(ctx, pump, reason),
        const SizedBox(height: 8),
        if (voltages.length >= 6) ...[
          _vcRow(voltages.sublist(0, 3), ['RN', 'YN', 'BN']),
          const SizedBox(height: 5),
          _vcRow(voltages.sublist(3, 6), ['RY', 'YB', 'BR']),
        ] else if (voltages.length >= 3)
          _vcRow(voltages.sublist(0, 3), ['RN', 'YN', 'BN'])
        else
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text('No voltage data yet',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
          ),
        const SizedBox(height: 8),
        _vcRow(columns, ['RC', 'YC', 'BC']),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _pumpReasonBar(BuildContext ctx, PumpModel pump, int reason) {
    final restartTime = pump.actualValue.split('_').last;
    final restartOk = pump.reason == '8' &&
        RegExp(r'^([0-1]?\d|2[0-3]):[0-5]\d:[0-5]\d$').hasMatch(restartTime);

    return Container(
      width: 325,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
      ),
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              restartOk
                  ? '${PumpReasonCode.fromCode(reason).content}, It will be restart automatically within $restartTime (hh:mm:ss)'
                  : PumpReasonCode.fromCode(reason).content,
              style: const TextStyle(fontSize: 11, color: Colors.deepOrange),
            ),
          ),
          if (!_excludedReasons.contains(pump.reason))
            SizedBox(
              height: 23,
              child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.redAccent.shade200),
                onPressed: () {
                  final payload = jsonEncode({
                    "6300": {"6301": '${pump.sNo},1'}
                  });
                  _publishPump('${pump.name} Reset Manually', payload);
                  GlobalSnackBar.show(
                      ctx, 'Reset comment sent successfully', 200);
                  Navigator.pop(ctx);
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

  Widget _vcRow(List<String> values, List<String> prefixes) {
    const colors = [
      [Color(0xFFFFCDD2), Color(0xFFE57373)], // R
      [Color(0xFFFFF9C4), Color(0xFFFFEB3B)], // Y
      [Color(0xFFBBDEFB), Color(0xFF64B5F6)], // B
    ];
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: List.generate(3, (i) {
          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: Container(
              width: 95,
              height: 32,
              decoration: BoxDecoration(
                color: colors[i][0],
                border: Border.all(color: colors[i][1], width: 0.7),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: Text('${prefixes[i]} : ${values[i]}',
                    style: const TextStyle(fontSize: 11)),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _pumpControlButtons(BuildContext ctx, PumpModel pump) {
    void send(int onOff) {
      String payload = '${pump.sNo},$onOff,1';
      if (AppConstants.ecoGemModelList.contains(modelId)) {
        payload = payload.replaceAll(RegExp(r'[.]'), ',');
      }
      final finalPayload = jsonEncode({
        "6200": {"6201": payload}
      });
      _publishPump('${pump.name} ${onOff == 1 ? 'Start' : 'Stop'} Manually',
          finalPayload);
      GlobalSnackBar.show(
          ctx,
          'Pump ${onOff == 1 ? 'start' : 'stop'} comment sent successfully',
          200);
      Navigator.pop(ctx);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MaterialButton(
            color: Colors.green,
            textColor: Colors.white,
            onPressed: () => send(1),
            child: const Text('Start Manually'),
          ),
          const SizedBox(width: 8),
          MaterialButton(
            color: Colors.redAccent,
            textColor: Colors.white,
            onPressed: () => send(0),
            child: const Text('Stop Manually'),
          ),
        ],
      ),
    );
  }

  Future<void> _publishPump(String msg, String payload) async {
    MqttService().topicToPublishAndItsMessage(
        payload, '${AppConstants.publishTopic}/$deviceId');
    final body = <String, Object>{
      "userId": customerId,
      "controllerId": controllerId,
      "messageStatus": msg,
      "hardware": jsonDecode(payload),
      "createUser": customerId,
    };
    final response =
    await Repository(HttpService()).sendManualOperationToServer(body);
    if (response.statusCode != 200) {
      debugPrint('Failed to log manual operation: ${response.statusCode}');
    }
  }

  Widget _tankBox(FertTank t) {
    final level =
    t.source.level.isNotEmpty ? t.source.level.first.value : '-';
    return _box(
      icon: FontAwesomeIcons.arrowUpFromWaterPump,
      color: Colors.black54,
      border: Colors.black12,
      iconColor: Colors.white,
      name: t.name,
      sub: level == '-' ? null : 'L: $level',
    );
  }

  Widget _valveChip(BuildContext context, TankValveModel v,
      {bool isInlet = false}) {
    final rawKey = v.sNo.toString();
    final paddedKey = v.sNo.toStringAsFixed(3);

    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) =>
      provider.getTankValveOnOffStatus(rawKey) ??
          provider.getTankValveOnOffStatus(paddedKey),
      builder: (_, status, __) {
        final parts = status?.split(',') ?? [];
        final int onOffStatus = parts.length > 1
            ? (int.tryParse(parts[1]) ?? v.status)
            : v.status;
        final int percent = parts.length > 2
            ? (int.tryParse(parts[2]) ?? v.completePercent)
            : v.completePercent;

        // ---- Color mapping by status ----
        Color statusColor;
        switch (onOffStatus) {
          case 1:
            statusColor = Colors.green;
            break;
          case 2:
            statusColor = Colors.blue;
            break;
          case 3:
            statusColor = Colors.yellow;
            break;
          case 4:
            statusColor = Colors.orange;
            break;
          case 5:
            statusColor = Colors.red;
            break;
          default:
            statusColor = Colors.black54;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 9),
            Tooltip(
              message: '${v.name}\n'
                  '${isInlet ? 'Inlet' : 'Outlet'}\n'
                  'status: $onOffStatus'
                  '${percent > 0 ? ' • $percent%' : ''}',
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                      border: Border.all(
                        color: Colors.black26,
                        width: 0.6,
                      ),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.faucetDrip,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (percent > 0 && percent < 100)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 7,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: colW - 6,
              child: Text(
                v.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: statusColor == Colors.yellow
                      ? Colors.black87
                      : statusColor,
                  fontWeight: isInlet ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _box({
    required IconData icon,
    required Color color,
    required Color border,
    required Color iconColor,
    required String name,
    String? sub,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: border, width: 1),
          ),
          child: Icon(icon, size: 22, color: iconColor),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: colW - 6,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
        if (sub != null)
          Text(sub,
              style: const TextStyle(fontSize: 9, color: Colors.black54)),
      ],
    );
  }
}

class _Group {
  final FertTank tank;
  final int row;
  final int rows;
  final double tankX, tankRight, forkX, valveX;
  _Group(this.tank, this.row, this.rows, this.tankX, this.tankRight,
      this.forkX, this.valveX);
}

/*
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oro_drip_irrigation/models/customer/site_model.dart';
import 'package:provider/provider.dart';

import '../../../../StateManagement/mqtt_payload_provider.dart';

/// NEW fertilizer tank concept (shown only when fertilizerChannel exists).
/// Everything flows left -> right:
///
///  [Main source]─[Pump]─┬─[inlet valve]─[Tank 5]─┬─[outlet valve 1]──●──●──●──●
///                       │                        └─[outlet valve 2]──●──●
///                       └─[inlet valve]─[Tank 6]───[outlet valve 3]──●──●──●
///                                                                    I1 I2 I3 I4   (injectors)
///
/// A dot on an injector column means "this valve feeds that injector".
/// Injector columns are joined at the top only.
class FertTankSystemWidget extends StatelessWidget {
  final FertTankSystem system;
  final int customerId, controllerId, modelId;
  final String deviceId;

  const FertTankSystemWidget({
    super.key,
    required this.system,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
    required this.deviceId,
  });

  static const double colW = 76;
  static const double connW = 22;
  static const double rowH = 74;
  static const double iconCy = 20;
  static const double injGap = 30;
  static final Color lineColor = Colors.blueGrey.shade100;
  static final Color injColor = Colors.blueGrey.shade100;

  double _cy(int row) => row * rowH + iconCy;

  @override
  Widget build(BuildContext context) {
    final tanks = system.tanks;
    final mains = system.mainSources;

    // ---------- main section ----------
    final mainWidths =
    mains.map((m) => colW + m.pumps.length * (connW + colW)).toList();
    final maxMainW = mainWidths.isEmpty ? 0.0 : mainWidths.reduce(math.max);
    final collectorX = maxMainW + 16;

    // ---------- tank groups ----------
    final groups = <_Group>[];
    int row = 0;
    for (final t in tanks) {
      final k = math.max(1, t.outletValves.length);
      final inletW =
      t.inletValves.isEmpty ? 0.0 : t.inletValves.length * colW + connW;
      final tankX = collectorX + connW + inletW;
      final tankRight = tankX + colW;
      final forkX = tankRight + 12;
      final valveX = forkX + 12;
      groups.add(_Group(t, row, k, tankX, tankRight, forkX, valveX));
      row += k;
    }
    final totalRows = math.max(row, mains.length);

    // ---------- injector columns ----------
    final injNames = <double, String>{};
    for (final t in tanks) {
      for (final v in t.outletValves) {
        for (int i = 0; i < v.channelSNos.length; i++) {
          injNames[v.channelSNos[i]] = v.channelNames[i];
        }
      }
    }
    final injSNos = injNames.keys.toList()..sort();

    double crossStart = 0;
    for (final g in groups) {
      if (g.tank.outletValves.isNotEmpty) {
        crossStart = math.max(crossStart, g.valveX + colW);
      }
    }
    double injX(int j) => crossStart + 16 + j * injGap;
    final crossEnd =
    injSNos.isEmpty ? crossStart : injX(injSNos.length - 1) + 18;

    final tanksEnd = groups.isEmpty
        ? collectorX
        : groups.map((g) => g.tankRight).reduce(math.max);
    final width = math.max(crossEnd, tanksEnd) + 6;

    // ---------- vertical layout ----------
    final chipTop = _cy(totalRows - 1) + 26;
    final joinTopY = _cy(0) - 20;
    final height = injSNos.isEmpty ? totalRows * rowH : chipTop + 24;

    // ---------- build drawing ----------
    final c = <Widget>[];

    c.add(Positioned(left: 0, top: -14, child: _caption('FERT MAIN SOURCE')));
    c.add(Positioned(
        left: collectorX, top: -14, child: _caption('FERTILIZER TANKS')));
    if (injSNos.isNotEmpty) {
      c.add(Positioned(
          left: crossStart + 4, top: -14, child: _caption('INJECTORS')));
    }

    // ---------- main source rows ----------
    for (int i = 0; i < mains.length; i++) {
      c.add(Positioned(left: 0, top: i * rowH, child: _mainRow(mains[i])));
      c.add(_h(mainWidths[i], _cy(i), collectorX - mainWidths[i]));
    }

    // ---------- collector ----------
    final lastGroupRow = groups.isEmpty ? 0 : groups.last.row;
    final collectorBottom = _cy(math.max(lastGroupRow, mains.length - 1));
    if (collectorBottom > _cy(0)) {
      c.add(_v(collectorX, _cy(0), collectorBottom));
    }

    // ---------- tank groups ----------
    for (final g in groups) {
      final t = g.tank;
      final y = _cy(g.row);

      c.add(_h(collectorX, y, g.tankX - collectorX));
      for (int i = 0; i < t.inletValves.length; i++) {
        c.add(Positioned(
          left: collectorX + connW + i * colW,
          top: g.row * rowH,
          width: colW,
          child: _valveChip(context, t.inletValves[i], isInlet: true),
        ));
      }
      c.add(Positioned(
        left: g.tankX,
        top: g.row * rowH,
        width: colW,
        child: _tankBox(t),
      ));

      if (t.outletValves.isEmpty) continue;

      c.add(_h(g.tankRight, y, g.forkX - g.tankRight));
      if (g.rows > 1) c.add(_v(g.forkX, y, _cy(g.row + g.rows - 1)));

      for (int s = 0; s < t.outletValves.length; s++) {
        final v = t.outletValves[s];
        final r = g.row + s;
        final vy = _cy(r);
        c.add(_h(g.forkX, vy, g.valveX - g.forkX));
        c.add(Positioned(
          left: g.valveX,
          top: r * rowH,
          width: colW,
          child: _valveChip(context, v, isInlet: false),
        ));

        // valve -> injectors (crossbar)
        final feeds = <int>[];
        for (int j = 0; j < injSNos.length; j++) {
          if (v.channelSNos.contains(injSNos[j])) feeds.add(j);
        }
        c.add(_h(
            g.valveX + colW,
            vy,
            (feeds.isEmpty ? crossStart : injX(feeds.last)) -
                (g.valveX + colW)));
        for (final j in feeds) {
          c.add(Positioned(
            left: injX(j) - 5,
            top: vy - 5,
            width: 10,
            height: 10,
            child: DecoratedBox(
              decoration:
              BoxDecoration(color: injColor, shape: BoxShape.circle),
            ),
          ));
        }
      }
    }

    // ---------- injector columns + chips (top join only) ----------
    if (injSNos.isNotEmpty) {
      final firstX = injX(0);
      final lastX = injX(injSNos.length - 1);

      // top rail only
      c.add(_h(firstX - 0, joinTopY, (lastX + 20) - (firstX - 8)));

      for (int j = 0; j < injSNos.length; j++) {
        // vertical column from top rail down to chip
        c.add(_v(injX(j), joinTopY, chipTop));

        // injector chip
        c.add(Positioned(
          left: injX(j) - 14,
          top: chipTop,
          width: 28,
          height: 20,
          child: Tooltip(
            message: injNames[injSNos[j]] ?? '',
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: injColor, width: 1),
              ),
              child: Center(
                child: Text(
                  _shortNo(injNames[injSNos[j]] ?? ''),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 42, left: 4, right: 4, bottom: 8),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(clipBehavior: Clip.none, children: c),
      ),
    );
  }

  // ---------- drawing helpers ----------
  Widget _h(double left, double y, double w) => Positioned(
    left: left,
    top: y - 1,
    width: math.max(0, w),
    height: 2,
    child: ColoredBox(color: lineColor),
  );

  Widget _v(double x, double y1, double y2) => Positioned(
    left: x - 1,
    top: y1 - 1,
    width: 2,
    height: (y2 - y1) + 2,
    child: ColoredBox(color: lineColor),
  );

  Widget _caption(String t) => Text(
    t,
    style: TextStyle(
      fontSize: 8,
      letterSpacing: 0.6,
      color: Colors.blueGrey.shade400,
      fontWeight: FontWeight.w600,
    ),
  );

  String _shortNo(String name) {
    final m = RegExp(r'(\d+)\s*$').firstMatch(name);
    return m == null ? name : m.group(1)!;
  }

  // ------------------------------------------------------------
  // Main source (sourceType 6) ── pump ── pump
  // ------------------------------------------------------------
  Widget _mainRow(FertMainSource m) {
    final src = m.source;
    final level = src.level.isNotEmpty ? src.level.first.value : '-';
    return SizedBox(
      height: rowH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: colW,
            child: _box(
              icon: Icons.water,
              color: Colors.black54,
              border: Colors.black12,
              iconColor: Colors.white,
              name: src.name,
              sub: level == '-' ? null : 'L: $level',
            ),
          ),
          for (final pump in m.pumps) ...[
            Padding(
              padding: const EdgeInsets.only(top: iconCy - 1),
              child: Container(width: connW, height: 2, color: lineColor),
            ),
            SizedBox(width: colW, child: _pumpChip(pump)),
          ],
        ],
      ),
    );
  }

  Widget _pumpChip(PumpModel pump) {
    final on = pump.status == 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? Colors.green.shade400 : Colors.grey.shade300,
            border: Border.all(
              color: Colors.black38,
              width: 1,
            ),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/svg_images/pump.svg',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.srcIn),
              placeholderBuilder: (_) =>
              const Icon(Icons.error, size: 20, color: Colors.red),
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: colW - 6,
          child: Text(
            pump.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _tankBox(FertTank t) {
    final level =
    t.source.level.isNotEmpty ? t.source.level.first.value : '-';
    return _box(
      icon: FontAwesomeIcons.arrowUpFromWaterPump,
      color: Colors.black54,
      border: Colors.black12,
      iconColor: Colors.white,
      name: t.name,
      sub: level == '-' ? null : 'L: $level',
    );
  }

  Widget _valveChip(BuildContext context, TankValveModel v,
      {bool isInlet = false}) {
    final rawKey = v.sNo.toString();
    final paddedKey = v.sNo.toStringAsFixed(3);

    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) =>
      provider.getTankValveOnOffStatus(rawKey) ??
          provider.getTankValveOnOffStatus(paddedKey),
      builder: (_, status, __) {
        final parts = status?.split(',') ?? [];
        final int onOffStatus = parts.length > 1
            ? (int.tryParse(parts[1]) ?? v.status)
            : v.status;
        final int percent = parts.length > 2
            ? (int.tryParse(parts[2]) ?? v.completePercent)
            : v.completePercent;

        // ---- Color mapping by status ----
        Color statusColor;
        switch (onOffStatus) {
          case 1:
            statusColor = Colors.green;
            break;
          case 2:
            statusColor = Colors.blue;
            break;
          case 3:
            statusColor = Colors.yellow;
            break;
          case 4:
            statusColor = Colors.orange;
            break;
          case 5:
            statusColor = Colors.red;
            break;
          default:
            statusColor = Colors.black54;
        }

        final Color iconColor =
        (onOffStatus == 3) ? Colors.black87 : Colors.white;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 9),
            Tooltip(
              message: '${v.name}\n'
                  '${isInlet ? 'Inlet' : 'Outlet'}\n'
                  'status: $onOffStatus'
                  '${percent > 0 ? ' • $percent%' : ''}',
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                      border: Border.all(
                        color: Colors.black26,
                        width: 0.6,
                      ),
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.faucetDrip,   // ✅ same icon for both
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (percent > 0 && percent < 100)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 7,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              width: colW - 6,
              child: Text(
                v.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  color: statusColor == Colors.yellow
                      ? Colors.black87
                      : statusColor,
                  fontWeight: isInlet ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _box({
    required IconData icon,
    required Color color,
    required Color border,
    required Color iconColor,
    required String name,
    String? sub,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: border, width: 1),
          ),
          child: Icon(icon, size: 22, color: iconColor),
        ),
        const SizedBox(height: 2),
        SizedBox(
          width: colW - 6,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
        if (sub != null)
          Text(sub,
              style: const TextStyle(fontSize: 9, color: Colors.black54)),
      ],
    );
  }
}

class _Group {
  final FertTank tank;
  final int row;
  final int rows;
  final double tankX, tankRight, forkX, valveX;
  _Group(this.tank, this.row, this.rows, this.tankX, this.tankRight,
      this.forkX, this.valveX);
}*/
