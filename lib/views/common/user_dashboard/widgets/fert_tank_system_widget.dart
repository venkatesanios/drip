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
              colorFilter:
                  const ColorFilter.mode(Colors.black54, BlendMode.srcIn),
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
    final level = t.source.level.isNotEmpty ? t.source.level.first.value : '-';
    return _box(
      icon: FontAwesomeIcons.faucetDrip,
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
        final int onOffStatus =
            parts.length > 1 ? (int.tryParse(parts[1]) ?? v.status) : v.status;
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
    required dynamic icon,
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
          child: Center(
            child: icon is IconData
                ? Icon(icon, size: 22, color: iconColor)
                : FaIcon(icon, size: 22, color: iconColor),
          ),
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
          Text(sub, style: const TextStyle(fontSize: 9, color: Colors.black54)),
      ],
    );
  }
}

class _Group {
  final FertTank tank;
  final int row;
  final int rows;
  final double tankX, tankRight, forkX, valveX;
  _Group(this.tank, this.row, this.rows, this.tankX, this.tankRight, this.forkX,
      this.valveX);
}
