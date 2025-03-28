import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../services/http_service.dart';
import '../../Preferences/widgets/custom_segmented_control.dart';
import '../repository/log_repos.dart';
import '../widgets/custom_calendar_mobile.dart';

class PumpVoltageLogScreen extends StatefulWidget {
  final int userId, controllerId, nodeControllerId;
  const PumpVoltageLogScreen({super.key, required this.userId, required this.controllerId, this.nodeControllerId = 0});

  @override
  State<PumpVoltageLogScreen> createState() => _PumpVoltageLogScreenState();
}

class _PumpVoltageLogScreenState extends State<PumpVoltageLogScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String message = "";
  CalendarFormat _calendarFormat = CalendarFormat.week;
  int selectedIndex = 0;
  List<Map<String, dynamic>> voltageData = [];
  final LogRepository repository = LogRepository(HttpService());

  Future<void> getUserVoltageLog() async {
    message = '';
    voltageData.clear();
    Map<String, dynamic> data = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "nodeControllerId": widget.nodeControllerId,
      "fromDate": DateFormat("yyyy-MM-dd").format(selectedDate),
      "toDate": DateFormat("yyyy-MM-dd").format(selectedDate),
    };

    try {
      final getPumpController = await repository.getUserVoltageLog(data, widget.nodeControllerId != 0);
      final response = jsonDecode(getPumpController.body);
      if (getPumpController.statusCode == 200) {
        setState(() {
          if (response['data'] is List) {
            if(DateFormat("yyyy-MM-dd").format(selectedDate) == DateFormat("yyyy-MM-dd").format(DateTime.now())) {
              for(var i in response['data'][0]['voltageDetails']) {
                if(i['hour'] <= DateTime.now().hour) {
                  voltageData.add(i);
                }
              }
            } else {
              voltageData = List<Map<String, dynamic>>.from(response['data'][0]['voltageDetails']);
            }
            message = "";
          } else {
            message = 'No data available for the selected date.';
          }
        });
      } else {
        setState(() {
          message = 'Failed to load data: ${response['message']}';
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        message = 'Error occurred: $e';
      });
      print("$e");
      print("stackTrace ==> $stackTrace");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(mounted) {
      getUserVoltageLog();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredData {
    if (selectedIndex == 0) {
      return voltageData;
    } else if(selectedIndex == 1){
      return voltageData.map((data) {
        return {
          "hour": data['hour'],
          "currentR": data['currentR'],
          "currentY": data['currentY'],
          "currentB": data['currentB'],
        };
      }).toList();
    } else if(selectedIndex == 2){
      return voltageData.map((data) {
        return {
          "hour": data['hour'],
          "powerFactorR": data['powerFactorR'],
          "powerFactorY": data['powerFactorY'],
          "powerFactorB": data['powerFactorB'],
        };
      }).toList();
    } else {
      return voltageData.map((data) {
        return {
          "hour": data['hour'],
          "powerR": data['powerR'],
          "powerY": data['powerY'],
          "powerB": data['powerB'],
        };
      }).toList();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: (voltageData.isNotEmpty || message.isNotEmpty) ? Column(
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
                getUserVoltageLog();
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            if (voltageData.isNotEmpty && message.isEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: CustomSegmentedControl(
                    segmentTitles: voltageData[0]['totalInstantEnergy'] != null ? {
                      0: "Voltage",
                      1: "Current",
                      2: "Power Factor",
                      3: "Power",
                    } : {
                      0: "Voltage",
                      1: "Current",
                    },
                    groupValue: selectedIndex,
                    onChanged: (newValue) {
                      setState(() {
                        selectedIndex = newValue!;
                      });
                      // getUserPumpLog();
                    }
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: getUserVoltageLog,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (message.isNotEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              message,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      else if (voltageData.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: AppProperties.customBoxShadowLiteTheme,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SfCartesianChart(
                            primaryXAxis: const CategoryAxis(
                              labelRotation: 45,
                              majorGridLines: MajorGridLines(width: 0.5),
                            ),
                            primaryYAxis: NumericAxis(
                              labelFormat: selectedIndex == 0 ? '{value}V' : selectedIndex == 1 ?'{value}A' : selectedIndex == 2 ? '{value}' : '{value}kW',
                              majorGridLines: const MajorGridLines(width: 0.5),
                            ),
                            title: ChartTitle(
                              text: selectedIndex == 0 ? 'Voltage Graph' : selectedIndex == 1 ? 'Current Graph' : selectedIndex == 2 ? "Power Factor" : "Power Graph",
                            ),
                            legend: const Legend(
                              isVisible: true,
                              position: LegendPosition.bottom,
                            ),
                            tooltipBehavior: TooltipBehavior(
                              enable: true,
                              header: selectedIndex == 0 ? 'Voltage Info' : selectedIndex == 1 ? 'Current Info' : selectedIndex == 2 ? 'Power Factor Info' : 'Power Info',
                              format: 'point.x: point.y',
                            ),
                            series: <SplineSeries<Map<String, dynamic>, String>>[
                              _buildSplineSeries(
                                dataSource: filteredData,
                                color: Colors.red,
                                phase: 'R',
                                name: selectedIndex == 0 ? 'Voltage R' : selectedIndex == 1 ? 'Current R' : selectedIndex == 2 ? "Power Factor R" : "Power R",
                              ),
                              _buildSplineSeries(
                                dataSource: filteredData,
                                color: Colors.yellow,
                                phase: 'Y',
                                name: selectedIndex == 0 ? 'Voltage Y' : selectedIndex == 1 ? 'Current Y' : selectedIndex == 2 ? "Power Factor Y" : "Power Y",
                              ),
                              _buildSplineSeries(
                                dataSource: filteredData,
                                color: Colors.blue,
                                phase: 'B',
                                name: selectedIndex == 0 ? 'Voltage B' : selectedIndex == 1 ? 'Current B' : selectedIndex == 2 ? "Power Factor B" : "Power B",
                              ),
                            ],
                          ),
                        ),
                      if (message.isEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return _buildVoltageLogCard(voltageData[index]);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ) : const Center(child: SizedBox(
          width: 100,
          height: 50,
          child: LoadingIndicator(colors: [Colors.redAccent,
            Colors.amberAccent,
            Colors.lightBlueAccent,], indicatorType: Indicator.ballPulse,),
        ),),
      ),
    );
  }

  SplineSeries<Map<String, dynamic>, String> _buildSplineSeries({
    required List<Map<String, dynamic>> dataSource,
    required Color color,
    required String phase,
    required String name,
  }) {
    return SplineSeries<Map<String, dynamic>, String>(
      dataSource: dataSource,
      xValueMapper: (data, _) => 'Hour ${data['hour']}',
      yValueMapper: (data, _) {
        final key = selectedIndex == 0 ? 'voltage$phase' : selectedIndex == 1 ? 'current$phase' : selectedIndex == 2 ? 'powerFactor$phase' : 'power$phase';
        return double.tryParse(data[key]) ?? 0.0;
      },
      name: name,
      markerSettings: const MarkerSettings(isVisible: true),
      color: color,
    );
  }

  Widget _buildVoltageLogCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      surfaceTintColor: Colors.white,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Theme.of(context).primaryColor.withOpacity(0.4),
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('Hours', style: TextStyle(fontWeight: FontWeight.bold,)),
                    ),
                    Container(
                      color: Colors.redAccent.shade100,
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('R', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.amberAccent.shade100,
                      child: const Text('Y', style: TextStyle(fontWeight: FontWeight.bold,)),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.lightBlueAccent.shade100,
                      child: const Text('B', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ..._buildDataRows()
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> _buildDataRows() {
    List<TableRow> rows = [];

    for (var entry in voltageData) {
      rows.add(
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${entry['hour']}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                selectedIndex == 0 ? entry['voltageR'] : selectedIndex == 1 ? entry['currentR'] : selectedIndex == 2 ? entry['powerFactorR'] : entry['powerR'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                selectedIndex == 0 ? entry['voltageY'] : selectedIndex == 1 ? entry['currentY'] : selectedIndex == 2 ? entry['powerFactorY'] : entry['powerY'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                selectedIndex == 0 ? entry['voltageB'] : selectedIndex == 1 ? entry['currentB'] : selectedIndex == 2 ? entry['powerFactorB'] : entry['powerB'],
                style: const TextStyle(fontWeight: FontWeight.bold,),
              ),
            ),
          ],
        ),
      );
    }

    return rows;
  }
}
