
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_drip_irrigation/modules/Logs/view/valve_log.dart';
import 'package:oro_drip_irrigation/modules/PumpController/state_management/pump_controller_provider.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';
import 'package:provider/provider.dart';

import '../../../Models/customer/site_model.dart';
import '../../Preferences/widgets/custom_segmented_control.dart';
import '../widgets/custom_calendar_mobile.dart';
import '../widgets/time_line2.dart';

class PumpLogScreen extends StatefulWidget {
  final int userId,controllerId, nodeControllerId;
  final MasterControllerModel masterData;
  const PumpLogScreen({super.key, required this.userId, required this.controllerId, this.nodeControllerId = 0, required this.masterData});

  @override
  State<PumpLogScreen> createState() => _PumpLogScreenState();
}

class _PumpLogScreenState extends State<PumpLogScreen> {
  int selectedIndex = 0;
  bool showGraph = false;

  @override
  void initState() {
    if(mounted) {
      context.read<PumpControllerProvider>().getUserPumpLog(
          widget.userId,
          widget.controllerId,
          widget.nodeControllerId,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final readProvider = context.read<PumpControllerProvider>();
    final watchProvider = context.watch<PumpControllerProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if(!kIsWeb)
              MobileCustomCalendar(
                focusedDay: readProvider.focusedDay,
                calendarFormat: readProvider.calendarFormat,
                selectedDate: watchProvider.selectedDate,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    readProvider.selectedDate = selectedDay;
                    readProvider.focusedDay = focusedDay;
                  });
                  readProvider.getUserPumpLog(widget.userId, widget.controllerId, widget.nodeControllerId);
                },
                onFormatChanged: (format) {
                  if (readProvider.calendarFormat != format) {
                    setState(() {
                      readProvider.calendarFormat = format;
                    });
                  }
                },
              ),
            const SizedBox(height: 10,),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, ),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if(readProvider.segments.isNotEmpty && readProvider.segments.length != 1)
                    CustomSegmentedControl(
                        segmentTitles: readProvider.segments,
                        groupValue: selectedIndex,
                        onChanged: (newValue) {
                          setState(() {
                            selectedIndex = newValue!;
                            readProvider.scrollController.animateTo(
                                readProvider.scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut
                            );
                          });
                        }
                    )
                  else
                    Container(),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  controller: readProvider.scrollController,
                  itemCount: watchProvider.pumpLogData.isNotEmpty ? watchProvider.pumpLogData.length : 1,
                  itemBuilder: (context, index) {
                    if(watchProvider.pumpLogData.isNotEmpty) {
                      final logData = watchProvider.pumpLogData[index];
                      if(AppConstants.pumpWithValveModelList.contains(widget.masterData.modelId)) {
                        return ValveLog(events: logData.motor1, masterData: widget.masterData,);
                      }
                      return Timeline2(
                        events: selectedIndex == 1 ? logData.motor2 : selectedIndex == 2 ? logData.motor3 : logData.motor1,
                      );
                    } else {
                      return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(readProvider.message),
                              FilledButton(
                                  onPressed: (){
                                    readProvider.getUserPumpLog(widget.userId, widget.controllerId, widget.nodeControllerId);
                                  },
                                  child: const Text("Reload")
                              )
                            ],
                          )
                      );
                    }
                  },
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}

