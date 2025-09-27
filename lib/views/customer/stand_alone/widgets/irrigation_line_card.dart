import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/customer/stand_alone/widgets/valve_card_table.dart';

import '../../../../models/customer/site_model.dart';

class IrrigationLineCard extends StatelessWidget {
  final IrrigationLineModel line;
  final bool showSwitch;
  final void Function(ValveModel mainValve, bool value) onToggleMainValve;
  final void Function(ValveModel valve, bool value) onToggleValve;

  const IrrigationLineCard({
    super.key,
    required this.line,
    required this.showSwitch,
    required this.onToggleMainValve,
    required this.onToggleValve,
  });

  @override
  Widget build(BuildContext context) {
    if (line.name == 'All irrigation line') return const SizedBox();

    final rows = [
      ...line.mainValveObjects.map((mainValve) => DataRow(cells: [
        DataCell(Image.asset('assets/png/m_main_valve_gray.png', width: 40, height: 40)),
        DataCell(Text(mainValve.name)),
        DataCell(Transform.scale(
          scale: 0.7,
          child: Switch(
            activeColor: Colors.teal,
            hoverColor: Colors.pink.shade100,
            value: mainValve.isOn,
            onChanged: (val) => onToggleMainValve(mainValve, val),
          ),
        )),
      ])),
      ...line.valveObjects.map((valve) => DataRow(cells: [
        DataCell(Image.asset('assets/png/m_valve_grey.png', width: 40, height: 40)),
        DataCell(Text(valve.name)),
        DataCell(Transform.scale(
          scale: 0.7,
          child: Switch(
            activeColor: Colors.teal,
            hoverColor: Colors.pink.shade100,
            value: valve.isOn,
            onChanged: (val) => onToggleValve(valve, val),
          ),
        )),
      ])),
    ];

    return ValveCardTable(
      title: line.name,
      showSwitch: showSwitch,
      switchValue: true,
      onSwitchChanged: (_) {},
      rows: rows,
    );
  }
}