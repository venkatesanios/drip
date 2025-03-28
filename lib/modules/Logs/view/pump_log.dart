import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../services/http_service.dart';
import '../../Preferences/widgets/custom_segmented_control.dart';
import '../model/pump_log_data.dart';
import '../repository/log_repos.dart';
import '../widgets/custom_calendar_mobile.dart';
import '../widgets/time_line2.dart';

class PumpLogScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int nodeControllerId;
  const PumpLogScreen({super.key, required this.userId, required this.controllerId, this.nodeControllerId = 0});

  @override
  State<PumpLogScreen> createState() => _PumpLogScreenState();
}

class _PumpLogScreenState extends State<PumpLogScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String message = "";
  CalendarFormat _calendarFormat = CalendarFormat.week;
  List<PumpLogData> pumpLogData = [];
  Map<int, String> segments = {};
  int selectedIndex = 0;
  bool showGraph = false;
  final ScrollController _scrollController = ScrollController();
  final LogRepository repository = LogRepository(HttpService());

  Future<void> getUserPumpLog() async {
    Map<String, dynamic> data = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "nodeControllerId": widget.nodeControllerId,
      "fromDate": DateFormat("yyyy-MM-dd").format(selectedDate),
      "toDate": DateFormat("yyyy-MM-dd").format(selectedDate),
    };

    try {
      final getPumpController = await repository.getUserPumpLog(data, widget.nodeControllerId != 0);
      // final getPumpController = await HttpService().postRequest(widget.nodeControllerId == 0 ? "getUserPumpLog" : "getUserNodePumpLog", data);
      final response = jsonDecode(getPumpController.body);
      pumpLogData.clear();
      segments.clear();
      selectedIndex = 0;
      message = "";
      showGraph = false;
      // print(data);
      if (getPumpController.statusCode == 200) {
        await Future.delayed(Duration.zero, () {
          setState(() {
            if (response['data'] is List) {
              pumpLogData = (response['data'] as List).map((i) => PumpLogData.fromJson(i)).toList();
              for(var i = 0; i < pumpLogData.length; i++) {
                if(pumpLogData[i].motor1.isNotEmpty) {
                  segments.addAll({0: "Motor 1"});
                }
                if(pumpLogData[i].motor2.isNotEmpty) {
                  segments.addAll({1: "Motor 2"});
                }
                if(pumpLogData[i].motor3.isNotEmpty) {
                  segments.addAll({2: "Motor 3"});
                }
                if(pumpLogData[i].motor2.isNotEmpty) {
                  selectedIndex = 1;
                } else if(pumpLogData[i].motor3.isNotEmpty) {
                  selectedIndex = 2;
                } else {
                  selectedIndex = 0;
                }
              }
            } else {
              message = '${response['message']}';
              print('Data is not a List');
            }
          });
        });
        setState(() {
          if (pumpLogData.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            });
          }
        });

      } else {
        print('Failed to load data');
      }
    } catch (e, stackTrace) {
      print("$e");
      print("stackTrace ==> $stackTrace");
    }
  }

  @override
  void initState() {
    if(mounted) {
      getUserPumpLog();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: getUserPumpLog,
        child: SafeArea(
          child: Column(
            children: [
              MobileCustomCalendar(
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDate: selectedDate,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  getUserPumpLog();
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
              ),
              const SizedBox(height: 10,),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if(segments.isNotEmpty && segments.length != 1)
                      CustomSegmentedControl(
                          segmentTitles: segments,
                          groupValue: selectedIndex,
                          onChanged: (newValue) {
                            setState(() {
                              selectedIndex = newValue!;
                              _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
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
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: pumpLogData.isNotEmpty ? pumpLogData.length : 1,
                  itemBuilder: (context, index) {
                    if(pumpLogData.isNotEmpty) {
                      final logData = pumpLogData[index];
                      return Timeline2(
                        events: selectedIndex == 1 ? logData.motor2 : selectedIndex == 2 ? logData.motor3 : logData.motor1,
                      );
                    } else {
                      return Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(message),
                          FilledButton(onPressed: (){
                            getUserPumpLog();
                          }, child: const Text("Reload"))
                        ],
                      ));
                    };
                  },
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

