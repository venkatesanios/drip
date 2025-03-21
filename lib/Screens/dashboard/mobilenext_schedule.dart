import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/Screens/dashboard/schedule_program.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../modules/IrrigationProgram/view/preview_screen.dart';

class NextScheduleForMobile extends StatefulWidget {
  final List<ProgramList> scheduledPrograms;

  // final int selectedLine;
  const NextScheduleForMobile({super.key, required this.scheduledPrograms});

  @override
  State<NextScheduleForMobile> createState() => _NextScheduleForMobileState();
}

class _NextScheduleForMobileState extends State<NextScheduleForMobile>
{

  @override
  Widget build(BuildContext context) {
    var nextSchedule = Provider.of<MqttPayloadProvider>(context).nextSchedule;
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 50),
                  Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Color(0xff95D394),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Next Schedule',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: nextSchedule.length,
                    itemBuilder: (context, index) {
                      List<String> values = nextSchedule[index].split(",");
                      print("values   ${values.isNotEmpty}");
                      return values.length > 1 ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              title: Text(
                                'Name:\t ${getProgramNameById(int.parse(values[0]))}',  // Use appropriate index if needed
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                            Card(
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              title: Text(
                                'Method:\t ${getSchedulingMethodName(widget.scheduledPrograms[index].schedulingMethod)}',  // Adjust to your data structure
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const Card(
                            margin: EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              title: Text(
                                'Location:\t ---',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              title: Text(
                                'Zone:\t ${values[7]}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              title: Text('Zone Name:\t ${getSequenceName(int.parse(values[0]), values[1]) ?? '--'}',  // Dummy logic
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              title: Text(
                                'Start Time:\t ${convert24HourTo12Hour(values[6])}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            child: ListTile(
                              title: Text(
                                'Set(Duration/Flow):\t ${values[3]}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                        ],
                      ) : Container(child: Center(child: Text("There are No Next Scheduled Programs"),),);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  String getProgramNameById(int id) {
    try {
      return widget.scheduledPrograms.firstWhere((program) => program.serialNumber == id).programName;
    } catch (e) {
      return "Stand Alone";
    }
  }

  String getSchedulingMethodName(int code) {
    switch (code) {
      case 1:
        return 'No Schedule';
      case 2:
        return 'Schedule by days';
      case 3:
        return 'Schedule as run list';
      default:
        return 'Day count schedule';
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
      return widget.scheduledPrograms.firstWhere((program) => program.serialNumber == id);
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



