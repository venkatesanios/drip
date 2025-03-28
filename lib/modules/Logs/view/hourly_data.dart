import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/modules/Logs/repository/log_repos.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:excel/excel.dart';

import '../../../Constants/constants.dart';
import '../../../services/http_service.dart';
import '../../Preferences/widgets/custom_segmented_control.dart';
import '../../SystemDefinitions/widgets/custom_snack_bar.dart';
import '../model/motor_data.dart';
import '../model/motor_data_hourly.dart';
import '../widgets/custom_calendar_mobile.dart';
import '../widgets/custom_widgets.dart';

class PumpHourlyLog extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int nodeControllerId;
  const PumpHourlyLog({super.key, required this.userId, required this.controllerId, this.nodeControllerId = 0});

  @override
  State<PumpHourlyLog> createState() => _PumpHourlyLogState();
}

class _PumpHourlyLogState extends State<PumpHourlyLog> {
  int selectedIndex = 0;
  DateTime selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  List<MotorDataHourly> motorDataList = [];
  List<PageController> pageController= [];
  List<MotorData> chartData = [];
  List<double> currPageValue = [];
  double scaleFactor = 0.8;
  List<DateTime> dates = List.generate(1, (index) => DateTime.now().subtract(Duration(days: index)));
  final LogRepository repository = LogRepository(HttpService());

  @override
  void initState() {
    super.initState();
    getPumpControllerData();
  }

  Future<void> getPumpControllerData({int selectedIndex = 0}) async {
    setState(() {
      if (selectedIndex == 1) {
        dates = List.generate(7, (index) => DateTime.now().subtract(Duration(days: index)));
      } else if (selectedIndex == 2) {
        dates = List.generate(30, (index) => DateTime.now().subtract(Duration(days: index)));
      } else if(selectedIndex == 0){
        dates.last = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      } else {
        dates.last = DateTime.parse(dates.last.toString().split(' ')[0]);
      }
    });

    var data = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "nodeControllerId": widget.nodeControllerId,
      "fromDate": DateFormat("yyyy-MM-dd").format(selectedIndex == 0 ? selectedDate : dates.last),
      "toDate": DateFormat("yyyy-MM-dd").format(selectedIndex == 0 ? selectedDate : dates.first),
      "needSum" : selectedIndex != 0
    };
    try {
      final getPumpController = await repository.getUserPumpHourlyLog(data, widget.nodeControllerId != 0);
      final response = jsonDecode(getPumpController.body);
      if (getPumpController.statusCode == 200) {
        // print(response);
        // print(data);
        Future.delayed(const Duration(microseconds: 1000));
        setState(() {
          chartData.clear();
          if (response['data'] is List) {
            List<dynamic> dataList = response['data'];
            motorDataList = dataList.map((item) => MotorDataHourly.fromJson(item)).toList();
            for (var i = 0; i < motorDataList[0].numberOfPumps; i++) {
              List<Color> colors = [Colors.lightBlueAccent.shade100.withOpacity(0.6), Colors.lightGreenAccent.withOpacity(0.6), Colors.greenAccent.withOpacity(0.6)];
              chartData.add(
                  MotorData(
                      "M${i + 1}",
                      [motorDataList[0].motorRunTime1, motorDataList[0].motorRunTime2, motorDataList[0].motorRunTime3][i],
                      colors[i]
                  )
              );
            }

          } else {
            motorDataList = [];
            chartData = [];
            log('Data is not a List');
          }
        });
      } else {
        chartData.clear();
        log('Failed to load data');
      }
    } catch (e, stackTrace) {
      chartData.clear();
      log("Error ==> $e");
      log("StackTrace ==> $stackTrace");
    }
  }

  Future<void> showSnackBar({required String message}) async{
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message:  message));
  }

  Future<void> exportMotorDataToExcel(List<MotorDataHourly> motorDataList, name, context) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    sheet.appendRow([
      TextCellValue('Date'),
      // TextCellValue('Number of Pumps'),
      TextCellValue('Two Phase Power On Time'),
      TextCellValue('Overall Cumulative Flow'),
      TextCellValue('Flow Rate'),
      TextCellValue('Pressure'),
      TextCellValue('Level'),
      TextCellValue('Two Phase Last Power On Time'),
      TextCellValue('Three Phase Power On Time'),
      TextCellValue('Three Phase Last Power On Time'),
      TextCellValue('Power Off Time'),
      TextCellValue('Last Power On Time'),
      TextCellValue('Total Power On Time'),
      TextCellValue('Total Power Off Time'),
      TextCellValue('Motor Run Time 1'),
      TextCellValue('Motor Idle Time 1'),
      TextCellValue('Last Date Run Time 1'),
      TextCellValue('Last Date Run Flow 1'),
      TextCellValue('Dry Run Trip Time 1'),
      TextCellValue('Cyclic Trip Time 1'),
      TextCellValue('Other Trip Time 1'),
      TextCellValue('Total Flow Today 1'),
      TextCellValue('Motor Run Time 2'),
      TextCellValue('Motor Idle Time 2'),
      TextCellValue('Last Date Run Time 2'),
      TextCellValue('Last Date Run Flow 2'),
      TextCellValue('Dry Run Trip Time 2'),
      TextCellValue('Cyclic Trip Time 2'),
      TextCellValue('Other Trip Time 2'),
      TextCellValue('Total Flow Today 2'),
      TextCellValue('Motor Run Time 3'),
      TextCellValue('Motor Idle Time 3'),
      TextCellValue('Last Date Run Time 3'),
      TextCellValue('Last Date Run Flow 3'),
      TextCellValue('Dry Run Trip Time 3'),
      TextCellValue('Cyclic Trip Time 3'),
      TextCellValue('Other Trip Time 3'),
      TextCellValue('Total Flow Today 3'),
    ]);

    // Append rows of data
    for (var data in motorDataList) {
      sheet.appendRow([
        TextCellValue(data.date),
        // TextCellValue(data.numberOfPumps.toString()),
        TextCellValue(data.twoPhasePowerOnTime),
        TextCellValue(data.overAllCumulativeFlow),
        TextCellValue(data.flowRate),
        TextCellValue(data.pressure),
        TextCellValue(data.level),
        TextCellValue(data.twoPhaseLastPowerOnTime),
        TextCellValue(data.threePhasePowerOnTime),
        TextCellValue(data.threePhaseLastPowerOnTime),
        TextCellValue(data.powerOffTime),
        TextCellValue(data.lastPowerOnTime),
        TextCellValue(data.totalPowerOnTime),
        TextCellValue(data.totalPowerOffTime),
        TextCellValue(data.motorRunTime1),
        TextCellValue(data.motorIdleTime1),
        TextCellValue(data.lastDateRunTime1),
        TextCellValue(data.lastDateRunFlow1),
        TextCellValue(data.dryRunTripTime1),
        TextCellValue(data.cyclicTripTime1),
        TextCellValue(data.otherTripTime1),
        TextCellValue(data.totalFlowToday1),
        TextCellValue(data.motorRunTime2),
        TextCellValue(data.motorIdleTime2),
        TextCellValue(data.lastDateRunTime2),
        TextCellValue(data.lastDateRunFlow2),
        TextCellValue(data.dryRunTripTime2),
        TextCellValue(data.cyclicTripTime2),
        TextCellValue(data.otherTripTime2),
        TextCellValue(data.totalFlowToday2),
        TextCellValue(data.motorRunTime3),
        TextCellValue(data.motorIdleTime3),
        TextCellValue(data.lastDateRunTime3),
        TextCellValue(data.lastDateRunFlow3),
        TextCellValue(data.dryRunTripTime3),
        TextCellValue(data.cyclicTripTime3),
        TextCellValue(data.otherTripTime3),
        TextCellValue(data.totalFlowToday3),
      ]);
    }

    // Save the file
    var fileBytes = excel.encode();
    if (fileBytes != null) {
      try {
        String downloadsDirectoryPath = "/storage/emulated/0/Download";
        String filePath = "$downloadsDirectoryPath/$name.xlsx";
        File file = File(filePath);
        await file.create(recursive: true);
        await file.writeAsBytes(fileBytes);
        // Check if file exists
        if (await file.exists()) {
          // Scaffold.of(context).showSnackBar()
          Navigator.pop(context);
          showDialog(context: context, builder: (context){
            return AlertDialog(
              title: Text('$name Download Successfully at'),
              content: Text('$filePath'),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: const Text('Ok')
                )
              ],
            );
          });

          showSnackBar(message: "Excel file saved successfully at $filePath");

          print("Excel file saved successfully at $filePath");
        } else {
          Navigator.pop(context);
          showDialog(context: context, builder: (context){
            return AlertDialog(
              title: Text('$name Download failed..'),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: const Text('Ok')
                )
              ],
            );
          });
          log("Failed to save the Excel file.");
        }
      } catch (e) {
        log("Error saving the Excel file: $e");
      }
    } else {
      log("Error encoding the Excel file.");
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: const Color(0xffF9FEFF),
      body: SafeArea(
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                children: [
                  if(selectedIndex == 0)
                    MobileCustomCalendar(
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDate: selectedDate,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          selectedDate = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        getPumpControllerData();
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: AppProperties.customBoxShadowLiteTheme
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          selectedIndex == 0
                              ? "${Constants.getWeekdayName(DateTime.now().weekday)}, ${Constants.getMonthName(DateTime.now().month)} ${DateTime.now().day}"
                              : selectedIndex == 1
                              ? "Last 7 days"
                              : "Last 30 days",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          selectedIndex == 0
                              ? "Today"
                              : "${DateFormat('MMM d yyyy').format(dates.first)} - ${DateFormat('MMM d yyyy').format(dates.last)}",
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                        tileColor: Colors.white,
                        trailing: IconButton(
                          onPressed: (){
                            showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2024),
                                lastDate: DateTime.now()
                            ).then((pickedDateRange) {
                              if (pickedDateRange != null) {
                                setState(() {
                                  dates.first = pickedDateRange.start;
                                  dates.last = pickedDateRange.end;
                                  dates = List.generate(pickedDateRange.end.difference(pickedDateRange.start).inDays, (index) => pickedDateRange.start.add(Duration(days: index)));
                                });
                              } else {
                                print('Date range picker was canceled');
                              }
                            }).whenComplete(() {
                              getPumpControllerData();
                            });
                          },
                          icon: const Icon(Icons.calendar_month, color: Colors.white,),
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Theme.of(context).primaryColor)
                          ),
                        ),
                      ),
                    ),
                  CustomSegmentedControl(
                      segmentTitles: const {
                        0: "Daily",
                        1: "Weekly",
                        2: "Monthly",
                      },
                      groupValue: selectedIndex,
                      onChanged: (newValue) {
                        setState(() {
                          selectedIndex = newValue!;
                        });
                        getPumpControllerData(selectedIndex: newValue!);
                      }
                  ),
                  const SizedBox(height: 10),
                  buildDailyDataView(constraints: constraints),
                ],
              );
            }
        ),
      ),
      floatingActionButton: MaterialButton(
          onPressed: (){
            showDialog(
                context: context,
                builder: (dialogContext){
                  var fileName = 'Power graph';
                  return AlertDialog(
                    title: const Text('File name'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          initialValue: fileName,
                          onChanged: (value){
                            fileName = value;
                          },
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () async{
                            await exportMotorDataToExcel(motorDataList,fileName,dialogContext);
                            Navigator.pop(context);
                          },
                          child: const Text('Click to download')
                      )
                    ],
                  );
                }
            );
          },
        child: const Icon(Icons.download, color: Colors.white,),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: EdgeInsets.zero,
        minWidth: 40,
        height: 40,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget buildDailyDataView({required BoxConstraints constraints}) {
    final selectedCondition = selectedIndex == 0;
    return Expanded(
      child: motorDataList.isNotEmpty ? ListView.builder(
          itemCount: selectedCondition ? motorDataList.length : 1,
          itemBuilder: (BuildContext context, int index) {
            if(motorDataList[index].numberOfPumps != 0) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: AppProperties.customBoxShadowLiteTheme
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(selectedCondition)
                          buildHeader(index),
                        const SizedBox(height: 10,),
                        buildScale(scale: Constants.generateScale(selectedCondition
                            ? const Duration(hours: 24)
                            : Constants.parseTime(motorDataList[index].totalPowerOnTime.toString()))
                        ),
                        const SizedBox(height: 10,),
                        buildAnimatedContainer(
                            color: const Color(0xff15C0E6),
                            value: Constants.parseTime(motorDataList[index].totalPowerOnTime.toString()),
                            motor: "Total Power -",
                            highestValue: selectedIndex == 0 ? const Duration(hours: 24) : Constants.parseTime(motorDataList[index].totalPowerOnTime.toString())
                        ),
                        const SizedBox(height: 10,),
                        buildMotorStatusContainers(index: index, numberOfPumps: motorDataList[index].numberOfPumps),
                        const SizedBox(height: 10,),
                        // buildLegend(),
                        // const SizedBox(height: 10,),
                        // DoughnutChart(
                        //   chartData: chartData,
                        //   totalPowerDuration: Constants.parseTime(motorDataList[index].totalPowerOnTime),
                        // ),
                        buildFooter(motorDataList[index]),
                        // if(motorDataList[index].numberOfPumps == 1)
                        //   buildMotorDetails(motorIndex: 0, dayIndex: index)
                        // else
                        buildPageView(dayIndex: index, constraints: constraints, numberOfPumps: motorDataList[index].numberOfPumps)
                      ],
                    ),
                  ),
                  const SizedBox(height: 70,)
                ],
              );
            } else {
              return Container();
            }
          }
      ) : const Center(child: Text("Data not found"),),
    );
  }

  Widget buildMotorDetails({required int motorIndex, required int dayIndex,}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildItemContainer(
          title1: 'Motor run time',
          title2: "Motor idle time",
          value1: [motorDataList[dayIndex].motorRunTime1, motorDataList[dayIndex].motorRunTime2, motorDataList[dayIndex].motorRunTime3][motorIndex],
          value2: [motorDataList[dayIndex].motorIdleTime1, motorDataList[dayIndex].motorIdleTime2, motorDataList[dayIndex].motorIdleTime3][motorIndex],
        ),
        buildItemContainer(
          title1: 'Dry run trip time',
          title2: 'Cyclic trip time',
          value1: [motorDataList[dayIndex].dryRunTripTime1, motorDataList[dayIndex].dryRunTripTime2, motorDataList[dayIndex].dryRunTripTime3][motorIndex],
          value2: [motorDataList[dayIndex].cyclicTripTime1, motorDataList[dayIndex].cyclicTripTime2, motorDataList[dayIndex].cyclicTripTime3][motorIndex],
        ),
        buildItemContainer(
          title1: 'Other trip time',
          title2: 'Total flow today',
          value1: [motorDataList[dayIndex].dryRunTripTime1, motorDataList[dayIndex].dryRunTripTime2, motorDataList[dayIndex].dryRunTripTime3][motorIndex],
          value2: "${[motorDataList[dayIndex].totalFlowToday1, motorDataList[dayIndex].totalFlowToday2, motorDataList[dayIndex].totalFlowToday3][motorIndex]} Litres",
        ),
      ],
    );
  }

  Widget buildItemContainer2({
    required String title1,
    required String title2,
    required int index,
    required int numberOfPumps,
    List<String>? value1,
    List<String>? value2,
    required String unit1,
    required String unit2
  }) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
          // border: Border(
          //   top: BorderSide(color: Theme.of(context).primaryColor, width: 0.5),
          // )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: Text(title1, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.start)),
              for(var i = 0; i < numberOfPumps; i++)
                Expanded(flex: 2, child: Text(value1![i], style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              if(numberOfPumps != 3)
                Expanded(flex: 2, child: Text(unit1, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center))
            ],
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: Text(title2, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.start)),
              for(var i = 0; i < numberOfPumps; i++)
                Expanded(flex: 2, child: Text(value2![i], style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
              if(numberOfPumps != 3)
                Expanded(flex: 2, child: Text(unit2, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center))
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPageView({required int dayIndex, required BoxConstraints constraints, required int numberOfPumps}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: double.maxFinite,
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: Container()),
                        for(var i = 0; i < numberOfPumps; i++)
                          Expanded(flex: 2, child: Text("Motor ${i+1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                        if(numberOfPumps != 3)
                          const Expanded(flex: 2, child: Text("Unit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                      ],
                    ),
                  )
              ),
              buildItemContainer2(
                  title1: 'Motor run time',
                  title2: "Motor idle time",
                  index: dayIndex,
                  numberOfPumps: numberOfPumps,
                  value1: [Constants.changeFormat(motorDataList[dayIndex].motorRunTime1), Constants.changeFormat(motorDataList[dayIndex].motorRunTime2), Constants.changeFormat(motorDataList[dayIndex].motorRunTime3)],
                  value2: [Constants.changeFormat(motorDataList[dayIndex].motorIdleTime1), Constants.changeFormat(motorDataList[dayIndex].motorIdleTime2), Constants.changeFormat(motorDataList[dayIndex].motorIdleTime3)],
                  unit1: "HH:MM",
                  unit2: "HH:MM"
              ),
              buildItemContainer2(
                  title1: 'Dry run trip time',
                  title2: 'Cyclic trip time',
                  index: dayIndex,
                  numberOfPumps: numberOfPumps,
                  value1: [Constants.changeFormat(motorDataList[dayIndex].dryRunTripTime1), Constants.changeFormat(motorDataList[dayIndex].dryRunTripTime2), Constants.changeFormat(motorDataList[dayIndex].dryRunTripTime3)],
                  value2: [Constants.changeFormat(motorDataList[dayIndex].cyclicTripTime1), Constants.changeFormat(motorDataList[dayIndex].cyclicTripTime2), Constants.changeFormat(motorDataList[dayIndex].cyclicTripTime3)],
                  unit1: "HH:MM",
                  unit2: "HH:MM"
              ),
              buildItemContainer2(
                  title1: 'Other trip time',
                  title2: 'Total flow today',
                  index: dayIndex,
                  numberOfPumps: numberOfPumps,
                  value1: [Constants.changeFormat(motorDataList[dayIndex].dryRunTripTime1), Constants.changeFormat(motorDataList[dayIndex].dryRunTripTime2), Constants.changeFormat(motorDataList[dayIndex].dryRunTripTime3)],
                  value2: [motorDataList[dayIndex].totalFlowToday1, motorDataList[dayIndex].totalFlowToday2, motorDataList[dayIndex].totalFlowToday3],
                  unit1: "HH:MM",
                  unit2: "Litres"
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildHeader(int index) {
    return Card(
        surfaceTintColor: const Color(0xffb6f6e5),
        color: const Color(0xffb4e3ed),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0)
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Text(
                DateFormat('MMM d yyyy').format(motorDataList[index].date != "" ? DateTime.parse(motorDataList[index].date) : DateTime.now()),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )
          ),
        )
    );
  }

  Widget buildMotorStatusContainers({required int index, required int numberOfPumps}) {
    List<Widget> containers = [];
    for (var i = 0; i < numberOfPumps; i++) {
      // print(motorDataList[index].totalPowerOnTime);
      containers.add(
          Column(
            children: [
              buildAnimatedContainer(
                  color: [Colors.lightBlueAccent.shade100.withOpacity(0.6), Colors.lightGreenAccent.withOpacity(0.6), Colors.greenAccent.withOpacity(0.6)][i],
                  value: [Constants.parseTime(motorDataList[index].motorRunTime1), Constants.parseTime(motorDataList[index].motorRunTime2), Constants.parseTime(motorDataList[index].motorRunTime3)][i],
                  motor: "Motor ${i + 1} consumed",
                  highestValue: selectedIndex == 0 ? const Duration(hours: 24): Constants.parseTime(motorDataList[index].totalPowerOnTime)
              ),
              const SizedBox(height: 10,)
            ],
          )
      );
    }
    return Column(children: containers);
  }

  Widget buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            buildLegendItem(color: const Color(0xff15C0E6), label: "Power Status"),
            const SizedBox(width: 30,),
            buildLegendItem(color: const Color(0xff10E196), label: "Motor Status"),
          ],
        )
      ],
    );
  }

  Widget buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color)),
        const SizedBox(width: 10,),
        Text(label, style: const TextStyle(color: Color(0xff9291A5), fontSize: 14))
      ],
    );
  }

  Widget buildFooter(MotorDataHourly motorDataHourly) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildFooterItem("Cumulative flow", "Litres", motorDataHourly.overAllCumulativeFlow, "Pressure", motorDataHourly.pressure != "-" ? motorDataHourly.pressure : "", motorDataHourly.pressure != "-" ? "bar" : ""),
            const SizedBox(height: 7,),
            buildFooterItem("Flow rate", "Lps", motorDataHourly.flowRate, "Level", motorDataHourly.level != "-" ? motorDataHourly.level : "", motorDataHourly.level != "-" ? "feet" : ""),
            const SizedBox(height: 7,),
            buildFooterItem("Total power on time", "(HH:MM)", Constants.changeFormat(motorDataHourly.totalPowerOnTime), "Total power off time", Constants.changeFormat(motorDataHourly.totalPowerOffTime), "(HH:MM)"),
            if(motorDataHourly.totalInstantEnergy != null && selectedIndex == 0)
              const SizedBox(height: 7,),
            if(motorDataHourly.totalInstantEnergy != null && selectedIndex == 0)
              buildFooterItem("Instant energy", "kW", motorDataHourly.totalInstantEnergy ?? '', "Cumulative energy", motorDataHourly.cumulativeEnergy ?? '', "kW")
          ],
        )
    );
  }

  Widget buildFooterItem(String label1, String unit1, String value1, String label2, String value2, String unit2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Column(
            children: [
              Text(label1, style: const TextStyle(color: Color(0xff9291A5), fontSize: 14)),
              Text("$value1 $unit1", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 10,),
        Expanded(
          child: Column(
            children: [
              Text(label2, style: const TextStyle(color: Color(0xff9291A5), fontSize: 14)),
              Text("$value2 $unit2", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
            ],
          ),
        )
      ],
    );
  }

  Widget buildItemContainer({
    required String title1,
    required String title2,
    required String value1,
    required String value2
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          buildItemRow(
              title1: title1,
              title2: title2,
              value1: value1,
              value2: value2
          )
        ],
      ),
    );
  }

  Widget buildItemRow({required String title1, required String title2, required String value1, required String value2}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildItem(title: title1, value: value1, color: Theme.of(context).primaryColor),
          buildItem(title: title2, value: value2, color: Colors.red)
        ],
      ),
    );
  }

  Widget buildItem({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Color(0xff9291A5), fontSize: 14)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
