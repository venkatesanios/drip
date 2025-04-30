import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
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

    var nextSchedule =  context.watch<MqttPayloadProvider>().nextSchedule;

    return nextSchedule.isNotEmpty && nextSchedule[0].isNotEmpty?
    kIsWeb?
    Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
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
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  height:(nextSchedule.length * 45) + 50,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 1000,
                      dataRowHeight: 45.0,
                      headingRowHeight: 40.0,
                      headingRowColor: WidgetStateProperty.all<Color>(Colors.orange.shade50),
                      columns: const [
                        DataColumn2(
                            label: Text('Name', style: TextStyle(fontSize: 13),),
                            size: ColumnSize.L
                        ),
                        DataColumn2(
                            label: Text('Method', style: TextStyle(fontSize: 13)),
                            size: ColumnSize.M

                        ),
                        DataColumn2(
                            label: Text('Location', style: TextStyle(fontSize: 13),),
                            size: ColumnSize.M
                        ),
                        DataColumn2(
                            label: Center(child: Text('Zone', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.S
                        ),
                        DataColumn2(
                            label: Center(child: Text('Zone Name', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.M
                        ),
                        DataColumn2(
                            label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.M
                        ),
                        DataColumn2(
                            label: Center(child: Text('Set(Duration/Flow)', style: TextStyle(fontSize: 13),)),
                            size: ColumnSize.M
                        ),
                      ],
                      rows: List<DataRow>.generate(nextSchedule.length, (index) {

                        List<String> values = nextSchedule[index].split(",");

                        return DataRow(cells: [
                          DataCell(Text(getProgramNameById(int.parse(values[0])))),
                          DataCell(Text(scheduledPrograms[index].selectedSchedule, style: const TextStyle(fontSize: 11),)),
                          const DataCell(Text('--')),
                          DataCell(Center(child: Text(values[7]))),
                          DataCell(Center(child: Center(child: Text(getSequenceName(int.parse(values[0]), values[1]) ?? '--')))),
                          DataCell(Center(child: Text(convert24HourTo12Hour(values[6])))),
                          DataCell(Center(child: Text(values[3]))),
                          /*DataCell(Text(widget.programQueue[index].schMethod==1?'No Schedule':widget.programQueue[index].schMethod==2?'Schedule by days':
                          widget.programQueue[index].schMethod==3?'Schedule as run list':'Day count schedule')),
                          DataCell(Text(widget.programQueue[index].programCategory)),
                          DataCell(Center(child: Text('${widget.programQueue[index].currentZone}'))),
                          DataCell(Center(child: Center(child: Text(widget.programQueue[index].zoneName)))),
                          DataCell(Center(child: Text(convert24HourTo12Hour(widget.programQueue[index].startTime)))),
                          DataCell(Center(child: Text(widget.programQueue[index].totalDurORQty))),*/
                        ]);
                      }),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                left: 0,
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.orange.shade200,
                      borderRadius: const BorderRadius.all(Radius.circular(2)),
                      border: Border.all(width: 0.5, color: Colors.grey)
                  ),
                  child: const Text('NEXT SCHEDULE IN QUEUE',  style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ],
      ),
    ):
    buildMobileCard(context, nextSchedule):
    const SizedBox();
  }

  Widget buildMobileCard(BuildContext context, List<String> nxtSchedule) {
    return Card(
      color: Colors.orange.shade50,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(),
      child: Column(
        children: List.generate(nxtSchedule.length, (index) {
          List<String> values = nxtSchedule[index].split(',');
          return Column(
            children: [
              buildNextScheduleRow(context, values),
              if (index != nxtSchedule.length - 1) const Padding(
                padding: EdgeInsets.only(left: 10, right: 8),
                child: Divider(height: 2),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget buildNextScheduleRow(BuildContext context, List<String> values) {
    final programName = getProgramNameById(int.parse(values[0]));
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          const Text('NEXT IN QUEUE'),
          Row(
            children: [
              const SizedBox(
                width: 170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Program Name & Method', style: TextStyle(color: Colors.black45)),
                    SizedBox(height: 2),
                    Text('Next Zone & Name', style: TextStyle(color: Colors.black45)),
                    SizedBox(height: 2),
                    Text('Start time & Set (Dur/Flw)', style: TextStyle(color: Colors.black45)),
                    SizedBox(height: 2),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(':'),
                    SizedBox(height: 2),
                    Text(':'),
                    SizedBox(height: 2),
                    Text(':'),
                    SizedBox(height: 2),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$programName - ${scheduledPrograms[0].selectedSchedule}'),
                    const SizedBox(height: 1),
                    Text('${values[7]} - ${getSequenceName(int.parse(values[0]), values[1]) ?? '--'}'),
                    const SizedBox(height: 3),
                    Text('${convert24HourTo12Hour(values[6])} - ${values[3]}'),
                    SizedBox(height: 2),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  String getProgramNameById(int id) {
    try {
      return scheduledPrograms.firstWhere((program) => program.serialNumber == id).programName;
    } catch (e) {
      return "Stand Alone";
    }
  }


  String? getSequenceName(int programId, String sequenceId) {
    ProgramList? program = getProgramById(programId);
    if (program != null) {
      return getSequenceNameById(program, sequenceId);
    }
    return null;
  }

  ProgramList? getProgramById(int id) {
    try {
      return scheduledPrograms.firstWhere((program) => program.serialNumber == id);
    } catch (e) {
      return null;
    }
  }

  String? getSequenceNameById(ProgramList program, String sequenceId) {
    try {
      return program.sequence.firstWhere((seq) => seq.sNo == sequenceId).name;
    } catch (e) {
      return null;
    }
  }

  String convert24HourTo12Hour(String timeString) {
    if(timeString=='-'){
      return '-';
    }
    final parsedTime = DateFormat('HH:mm:ss').parse(timeString);
    final formattedTime = DateFormat('hh:mm a').format(parsedTime);
    return formattedTime;
  }

}

String? getSequenceNameById(ProgramList program, String sequenceId) {
  try {
    return program.sequence.firstWhere((seq) => seq.sNo == sequenceId).name;
  } catch (e) {
    return null;
  }
}

String convert24HourTo12Hour(String timeString) {
  if(timeString=='-'){
    return '-';
  }
  final parsedTime = DateFormat('HH:mm:ss').parse(timeString);
  final formattedTime = DateFormat('hh:mm a').format(parsedTime);
  return formattedTime;
}