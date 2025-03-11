import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Models/customer/site_model.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../services/mqtt_service.dart';
import '../../utils/constants.dart';
 import 'package:intl/intl.dart';


class MobCurrentProgram extends StatefulWidget {
  const MobCurrentProgram({super.key, required this.scheduledPrograms, required this.deviceId});
   final List<ProgramList> scheduledPrograms;
  final String deviceId;

  @override
  State<MobCurrentProgram> createState() => _MobCurrentProgramState();
}

class _MobCurrentProgramState extends State<MobCurrentProgram> {
   @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var currentSchedule = Provider.of<MqttPayloadProvider>(context).currentSchedule;

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
                  'Current Schedule',
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
                itemCount: currentSchedule.length,
                itemBuilder: (context, index) {

                   List<String> values = currentSchedule[index].split(",");
print("values   ${values.isNotEmpty}");
                   return values.length > 1 ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          title: Text(
                            'Program:\t ${getProgramNameById(int.parse(values[0]))}',  // Use appropriate index if needed
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ListTile(
                        trailing: getProgramNameById(int.parse(values[0]))=='StandAlone - Manual'?
                        MaterialButton(
                          color: Colors.redAccent,
                          textColor: Colors.white,
                          onPressed: values[19]=='1'? (){
                            String payLoadFinal = jsonEncode({
                              "800": {"801": '0,0,0,0,0'}
                            });
                            MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/${widget.deviceId}');
                          }: null,
                          child: const Text('Stop'),
                        ):
                        getProgramNameById(int.parse(values[0])).contains('StandAlone')?
                        MaterialButton(
                          color: Colors.redAccent,
                          textColor: Colors.white,
                          onPressed: () async {


                          },
                          child: const Text('Stop'),
                        ):
                        MaterialButton(
                          color: Colors.orange,
                          textColor: Colors.white,
                          onPressed: values[19]=='1' ? (){
                            String payload = '${values[0]},0';
                            String payLoadFinal = jsonEncode({
                              "3700": {"3701": payload}
                            });
                            MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/${widget.deviceId}');

                          } : null,
                          child: const Text('Skip'),
                        ),

                      ),
                      const Card(
                        margin: EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          title: Text(
                            'Location:\t ---',  // Adjust to your data structure
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          title: Text(
                            'Zone:\t ${values[10]}/${values[9]}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          title: Text(
                            getProgramNameById(int.parse(values[0])) == 'StandAlone - Manual'
                                ? '--'
                                : getSequenceName(int.parse(values[0]), values[1]) ?? '--',  // Dummy logic
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          title: Text(
                            'RTC:\t ${formatRtcValues(values[6], values[5])}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          title: Text(
                            'Cyclic:\t ${formatRtcValues(values[8], values[7])}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          title: Text(
                            'Start Time::\t ${convert24HourTo12Hour(values[11])}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          title: Text(
                            'Set (Dur/Flw):\t ${getProgramNameById(int.parse(values[0]))=='StandAlone - Manual' &&
                                (values[3]=='00:00:00'||values[3]=='0')?
                            'Timeless': values[3]}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          title: Text(
                            'Avg/Flw Rate:\t ${'0'}/hr',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          title: Text(
                            'Remaining:\t ${getProgramNameById(int.parse(values[0]))=='StandAlone - Manual' &&
                  (values[3]=='00:00:00'||values[3]=='0')? '----': values[4]}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ) : Container(child: Center(child: Text("There are No Currently Scheduled Programs"),),);
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

  ProgramList? getProgramById(int id) {
    try {
      return widget.scheduledPrograms.firstWhere((program) => program.serialNumber == id);
    } catch (e) {
      return null;
    }
  }

  String? getSequenceName(int programId, String sequenceId) {
    ProgramList? program = getProgramById(programId);
    if (program != null) {
      return getSequenceNameById(program, sequenceId);
    }
    return null;
  }

  String? getSequenceNameById(ProgramList program, String sequenceId) {
    try {
      return program.sequence.firstWhere((seq) => seq.sNo == sequenceId).name;
    } catch (e) {
      return null;
    }
  }

  String formatRtcValues(dynamic value1, dynamic value2) {
    if (value1 == 0 && value2 == 0) {
      return '--';
    } else {
      return '${value1.toString()}/${value2.toString()}';
    }
  }

  String convert24HourTo12Hour(String timeString) {
    if (timeString == '-') {
      return '-';
    }
    final parsedTime = DateFormat('HH:mm:ss').parse(timeString);
    final formattedTime = DateFormat('hh:mm a').format(parsedTime);
    return formattedTime;
  }
}
