import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Models/customer/site_model.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';

class NextSchedule extends StatelessWidget {
  const NextSchedule({super.key, required this.scheduledPrograms});

  final List<ProgramList> scheduledPrograms;

  @override
  Widget build(BuildContext context) {
    var nextSchedule = context
        .watch<MqttPayloadProvider>()
        .nextSchedule;

    if (nextSchedule.isEmpty || nextSchedule[0].isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  height: (nextSchedule.length * 40) + 55,
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 1000,
                    dataRowHeight: 45,
                    headingRowHeight: 40,
                    headingRowColor: WidgetStateProperty.all(
                        Colors.orange.shade50),
                    columns: const [
                      DataColumn2(
                          label: Text('Name', style: TextStyle(fontSize: 13)),
                          size: ColumnSize.L),
                      DataColumn2(
                          label: Text('Method', style: TextStyle(fontSize: 13)),
                          size: ColumnSize.M),
                      DataColumn2(label: Text(
                          'Location', style: TextStyle(fontSize: 13)),
                          size: ColumnSize.M),
                      DataColumn2(
                          label: Center(child: Text('Zone', style: TextStyle(
                              fontSize: 13))), size: ColumnSize.S),
                      DataColumn2(label: Center(
                          child: Text('Zone Name', style: TextStyle(
                              fontSize: 13))), size: ColumnSize.M),
                      DataColumn2(label: Center(
                          child: Text('Start Time', style: TextStyle(
                              fontSize: 13))), size: ColumnSize.M),
                      DataColumn2(label: Center(
                          child: Text('Set(Duration/Flow)', style: TextStyle(
                              fontSize: 13))), size: ColumnSize.M),
                    ],
                    rows: List.generate(nextSchedule.length, (index) {
                      final values = nextSchedule[index].split(",");
                      final programId = int.tryParse(values[0]) ?? 0;
                      final sequenceId = values[1];
                      final setDuration = values[3];
                      final startTime = convert24HourTo12Hour(values[6]);
                      final zone = values[7];

                      return DataRow(cells: [
                        DataCell(Text(_getProgramNameById(programId))),
                        DataCell(Text(scheduledPrograms[index].selectedSchedule,
                            style: const TextStyle(fontSize: 11))),
                        const DataCell(Text('--')),
                        DataCell(Center(child: Text(zone))),
                        DataCell(Center(child: Text(
                            _getSequenceName(programId, sequenceId) ?? '--'))),
                        DataCell(Center(child: Text(startTime))),
                        DataCell(Center(child: Text(setDuration))),
                      ]);
                    }),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                left: 0,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade200,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(width: 0.5, color: Colors.grey),
                  ),
                  child: const Text('NEXT SCHEDULE IN QUEUE',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getProgramNameById(int id) {
    return scheduledPrograms
        .firstWhere(
          (program) => program.serialNumber == id,
      orElse: () =>
          ProgramList(programName: "Stand Alone",
              serialNumber: 0,
              defaultProgramName: '',
              programType: '',
              sequence: [],
              selectedSchedule: '',
              irrigationLine: []),
    )
        .programName;
  }

  String? _getSequenceName(int programId, String sequenceId) {
    final program = scheduledPrograms.firstWhere(
          (p) => p.serialNumber == programId,
      orElse: () =>
          ProgramList(sequence: [],
              serialNumber: 0,
              programName: '',
              defaultProgramName: '',
              programType: '',
              selectedSchedule: '',
              irrigationLine: []),
    );

    return program.sequence
        .firstWhere(
          (seq) => seq.sNo == sequenceId,
      orElse: () => Sequence(name: "--", sNo: ''),
    )
        .name;
  }

  String convert24HourTo12Hour(String timeString) {
    if (timeString == '-' || timeString
        .trim()
        .isEmpty) return '-';
    try {
      final parsedTime = DateFormat('HH:mm:ss').parseStrict(timeString);
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (_) {
      return timeString;
    }
  }
}