import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/customer/site_model.dart';
import '../../../services/communication_service.dart';
import '../../../utils/formatters.dart';
import '../../../utils/my_function.dart';

class AlarmListItems extends StatelessWidget {
  const AlarmListItems({super.key, required this.alarm, required this.deviceID,
    required this.customerId, required this.controllerId, required this.irrigationLine, this.show = true});
  final List<String> alarm;
  final List<IrrigationLineModel> irrigationLine;

  final String deviceID;
  final int customerId, controllerId;
  final bool show;

  @override
  Widget build(BuildContext context) {
    return alarm[0].isNotEmpty? DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 600,
      dataRowHeight: 45.0,
      headingRowHeight: 35.0,
      headingRowColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor.withOpacity(0.1)),
      columns: [
        const DataColumn2(
          label: Text('', style: TextStyle(fontSize: 13)),
          fixedWidth: 25,
        ),
        const DataColumn2(
            label: Text('Message', style: TextStyle(fontSize: 13),),
            size: ColumnSize.L
        ),
        const DataColumn2(
            label: Text('Location', style: TextStyle(fontSize: 13),),
            size: ColumnSize.M
        ),
        const DataColumn2(
            label: Text('Time', style: TextStyle(fontSize: 13)),
            size: ColumnSize.S
        ),
        if(show)
          const DataColumn2(
            label: Center(child: Text('', style: TextStyle(fontSize: 13),)),
            fixedWidth: 80,
          ),
      ],
      rows: List<DataRow>.generate(alarm.length, (index) {
        List<String> values = alarm[index].split(',');
        return DataRow(cells: [
          DataCell(Icon(Icons.warning_amber, color: values[7]=='1' ? Colors.orangeAccent : Colors.redAccent,)),
          DataCell(Text(MyFunction().getAlarmMessage(int.parse(values[2])))),
          DataCell(Text(irrigationLine.firstWhere(
                (line) => line.sNo.toString() == values[1],
          ).name)),
          DataCell(Text(Formatters().formatRelativeTime('${values[5]} ${values[6]}'))),
          if(show)
            DataCell(Center(child: MaterialButton(
              color: Colors.redAccent,
              textColor: Colors.white,
              onPressed: () async {
                String finalPayload =  values[0];
                String payLoadFinal = jsonEncode({
                  "4100": {"4101": finalPayload}
                });

                final result = await context.read<CommunicationService>().sendCommand(
                    serverMsg: 'Rested the ${MyFunction().getAlarmMessage(int.parse(values[2]))} alarm',
                    payload: payLoadFinal);

                if (result['http'] == true) {
                  debugPrint("Payload sent to Server");
                }
                if (result['mqtt'] == true) {
                  debugPrint("Payload sent to MQTT Box");
                }
                if (result['bluetooth'] == true) {
                  debugPrint("Payload sent via Bluetooth");
                }

                Navigator.pop(context);

              },
              child: const Text('Reset'),
            ))),
        ]);
      }),
    ):
    const Center(child: Text('Alarm not found'));
  }
}