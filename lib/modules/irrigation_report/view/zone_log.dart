import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/customer/site_model.dart';
import '../repository/irrigation_repository.dart';

class ScheduleItem {
  final int no;
  final String dateStr;
  final String programTitle;
  final Color programColor;
  final Color programTextColor;
  final String startTime;
  final String endTime;
  final String duration;
  final double startHour;
  final double endHour;
  final String startReason;
  final String endReason;
  final String percentage;

  ScheduleItem({
    required this.no,
    required this.dateStr,
    required this.programTitle,
    required this.programColor,
    required this.programTextColor,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.startHour,
    required this.endHour,
    required this.startReason,
    required this.endReason,
    this.percentage = "100%",
  });
}

class ProgramScheduleData {
  final String id;
  final String title;
  final Color headerColor;
  final Color barColor;
  final Color labelColor;
  final Color cardHeaderBg;
  final List<ScheduleItem> items;

  ProgramScheduleData({
    required this.id,
    required this.title,
    required this.headerColor,
    required this.barColor,
    required this.labelColor,
    required this.cardHeaderBg,
    required this.items,
  });
}

class DailyTimelineData {
  final String dateHeader;
  final DateTime date;
  final List<ProgramScheduleData> programs;

  DailyTimelineData({
    required this.dateHeader,
    required this.date,
    required this.programs,
  });
}

class ZoneLog extends StatefulWidget {
  final Map<String, dynamic> userData;
  final MasterControllerModel? masterData;

  const ZoneLog({
    super.key,
    required this.userData,
    this.masterData,
  });

  @override
  State<ZoneLog> createState() => _ZoneLogState();
}

class _ZoneLogState extends State<ZoneLog> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime _fromDate = DateTime(2026, 9, 8);
  DateTime _toDate = DateTime(2026, 9, 10);
  String _selectedProgramFilter = 'All Programs';
  String _selectedViewMode = 'Multi-Day';

  String? _selectedProgramTitle;
  ScheduleItem? _selectedItem;

  late List<DailyTimelineData> _dailyTimelines;

  @override
  void initState() {
    super.initState();
    _initDefaultData();
    fetchZoneLogApi();
  }

  Future<void> fetchZoneLogApi() async {
    String fromDateStr = DateFormat('yyyy-MM-dd').format(_fromDate);
    String toDateStr = DateFormat('yyyy-MM-dd').format(_toDate);

    Map<String, dynamic> body = {
      "userId": widget.userData['customerId'],
      "controllerId": widget.userData['controllerId'],
      "logType": "Irrigation",
      "fromDate": fromDateStr,
      "toDate": toDateStr,
      "parameters": [
        "Date",
        "ProgramS_No",
        "ZoneS_No",
        "HeadUnit",
        "Pump",
        "ActualStartTime",
        "ActualStopTime",
        "ActualStartReason",
        "ActualStopReason"
      ]
    };

    debugPrint('====================================');
    debugPrint('ZONE LOG API REQUEST BODY:');
    debugPrint(jsonEncode(body));
    debugPrint('====================================');

    try {
      var response = await IrrigationRepository().getLogDateWise(body);
      debugPrint('ZONE LOG API RESPONSE STATUS CODE: ${response.statusCode}');
      debugPrint('ZONE LOG API RESPONSE BODY: ${response.body}');

      Map<String, dynamic> jsonData = jsonDecode(response.body);
      if (jsonData['code'] == 200 && jsonData['data'] != null) {
        debugPrint('ZONE LOG DATA FETCH SUCCESS: ${jsonData['data']}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error in Zone Log API: ${e.toString()}');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _initDefaultData() {
    _dailyTimelines = [
      DailyTimelineData(
        dateHeader: "08 Sep 2026 (Tue)",
        date: DateTime(2026, 9, 8),
        programs: [
          ProgramScheduleData(
            id: '1',
            title: 'Program 1',
            headerColor: const Color(0xFFE8F5E9),
            cardHeaderBg: const Color(0xFFDCEDC8),
            barColor: const Color(0xFF4CAF50),
            labelColor: const Color(0xFF2E7D32),
            items: [
              ScheduleItem(
                no: 1,
                dateStr: '08 Sep 2026 (Tue)',
                programTitle: 'Program 1',
                programColor: const Color(0xFFDCEDC8),
                programTextColor: const Color(0xFF2E7D32),
                startTime: '08:00',
                endTime: '08:05',
                duration: '5 min',
                startHour: 8.0,
                endHour: 8.0833,
                startReason: 'Scheduled Start',
                endReason: 'Temperature Reached',
              ),
              ScheduleItem(
                no: 2,
                dateStr: '08 Sep 2026 (Tue)',
                programTitle: 'Program 1',
                programColor: const Color(0xFFDCEDC8),
                programTextColor: const Color(0xFF2E7D32),
                startTime: '14:00',
                endTime: '14:10',
                duration: '10 min',
                startHour: 14.0,
                endHour: 14.1667,
                startReason: 'Manual Start',
                endReason: 'User Stop',
              ),
            ],
          ),
          ProgramScheduleData(
            id: '2',
            title: 'Program 2',
            headerColor: const Color(0xFFFFEBEE),
            cardHeaderBg: const Color(0xFFFFCDD2),
            barColor: const Color(0xFFE53935),
            labelColor: const Color(0xFFC62828),
            items: [
              ScheduleItem(
                no: 3,
                dateStr: '08 Sep 2026 (Tue)',
                programTitle: 'Program 2',
                programColor: const Color(0xFFFFCDD2),
                programTextColor: const Color(0xFFC62828),
                startTime: '09:30',
                endTime: '09:35',
                duration: '5 min',
                startHour: 9.5,
                endHour: 9.5833,
                startReason: 'Manual Start',
                endReason: 'User Stop',
              ),
              ScheduleItem(
                no: 4,
                dateStr: '08 Sep 2026 (Tue)',
                programTitle: 'Program 2',
                programColor: const Color(0xFFFFCDD2),
                programTextColor: const Color(0xFFC62828),
                startTime: '18:00',
                endTime: '18:15',
                duration: '15 min',
                startHour: 18.0,
                endHour: 18.25,
                startReason: 'Auto Start',
                endReason: 'Sensor Off',
              ),
            ],
          ),
          ProgramScheduleData(
            id: '3',
            title: 'Program 3',
            headerColor: const Color(0xFFFFF8E1),
            cardHeaderBg: const Color(0xFFFFF9C4),
            barColor: const Color(0xFFFB8C00),
            labelColor: const Color(0xFFEF6C00),
            items: [],
          ),
          ProgramScheduleData(
            id: '4',
            title: 'Program 4',
            headerColor: const Color(0xFFF3E5F5),
            cardHeaderBg: const Color(0xFFE1BEE7),
            barColor: const Color(0xFF8E24AA),
            labelColor: const Color(0xFF6A1B9A),
            items: [
              ScheduleItem(
                no: 5,
                dateStr: '08 Sep 2026 (Tue)',
                programTitle: 'Program 4',
                programColor: const Color(0xFFE1BEE7),
                programTextColor: const Color(0xFF6A1B9A),
                startTime: '10:15',
                endTime: '10:30',
                duration: '15 min',
                startHour: 10.25,
                endHour: 10.5,
                startReason: 'Auto Start',
                endReason: 'Sensor Off',
              ),
            ],
          ),
        ],
      ),
      DailyTimelineData(
        dateHeader: "09 Sep 2026 (Wed)",
        date: DateTime(2026, 9, 9),
        programs: [
          ProgramScheduleData(
            id: '1',
            title: 'Program 1',
            headerColor: const Color(0xFFE8F5E9),
            cardHeaderBg: const Color(0xFFDCEDC8),
            barColor: const Color(0xFF4CAF50),
            labelColor: const Color(0xFF2E7D32),
            items: [
              ScheduleItem(
                no: 6,
                dateStr: '09 Sep 2026 (Wed)',
                programTitle: 'Program 1',
                programColor: const Color(0xFFDCEDC8),
                programTextColor: const Color(0xFF2E7D32),
                startTime: '07:30',
                endTime: '07:40',
                duration: '10 min',
                startHour: 7.5,
                endHour: 7.6667,
                startReason: 'Scheduled Start',
                endReason: 'User Stop',
              ),
            ],
          ),
          ProgramScheduleData(
            id: '2',
            title: 'Program 2',
            headerColor: const Color(0xFFFFEBEE),
            cardHeaderBg: const Color(0xFFFFCDD2),
            barColor: const Color(0xFFE53935),
            labelColor: const Color(0xFFC62828),
            items: [
              ScheduleItem(
                no: 7,
                dateStr: '09 Sep 2026 (Wed)',
                programTitle: 'Program 2',
                programColor: const Color(0xFFFFCDD2),
                programTextColor: const Color(0xFFC62828),
                startTime: '11:00',
                endTime: '11:10',
                duration: '10 min',
                startHour: 11.0,
                endHour: 11.1667,
                startReason: 'Auto Start',
                endReason: 'Sensor Off',
              ),
            ],
          ),
          ProgramScheduleData(
            id: '3',
            title: 'Program 3',
            headerColor: const Color(0xFFFFF8E1),
            cardHeaderBg: const Color(0xFFFFF9C4),
            barColor: const Color(0xFFFB8C00),
            labelColor: const Color(0xFFEF6C00),
            items: [
              ScheduleItem(
                no: 8,
                dateStr: '09 Sep 2026 (Wed)',
                programTitle: 'Program 3',
                programColor: const Color(0xFFFFF9C4),
                programTextColor: const Color(0xFFEF6C00),
                startTime: '15:00',
                endTime: '15:20',
                duration: '20 min',
                startHour: 15.0,
                endHour: 15.3333,
                startReason: 'Manual Start',
                endReason: 'User Stop',
              ),
            ],
          ),
          ProgramScheduleData(
            id: '4',
            title: 'Program 4',
            headerColor: const Color(0xFFF3E5F5),
            cardHeaderBg: const Color(0xFFE1BEE7),
            barColor: const Color(0xFF8E24AA),
            labelColor: const Color(0xFF6A1B9A),
            items: [],
          ),
        ],
      ),
      DailyTimelineData(
        dateHeader: "10 Sep 2026 (Thu)",
        date: DateTime(2026, 9, 10),
        programs: [
          ProgramScheduleData(
            id: '1',
            title: 'Program 1',
            headerColor: const Color(0xFFE8F5E9),
            cardHeaderBg: const Color(0xFFDCEDC8),
            barColor: const Color(0xFF4CAF50),
            labelColor: const Color(0xFF2E7D32),
            items: [
              ScheduleItem(
                no: 9,
                dateStr: '10 Sep 2026 (Thu)',
                programTitle: 'Program 1',
                programColor: const Color(0xFFDCEDC8),
                programTextColor: const Color(0xFF2E7D32),
                startTime: '08:00',
                endTime: '08:05',
                duration: '5 min',
                startHour: 8.0,
                endHour: 8.0833,
                startReason: 'Scheduled Start',
                endReason: 'Temperature Reached',
              ),
            ],
          ),
          ProgramScheduleData(
            id: '2',
            title: 'Program 2',
            headerColor: const Color(0xFFFFEBEE),
            cardHeaderBg: const Color(0xFFFFCDD2),
            barColor: const Color(0xFFE53935),
            labelColor: const Color(0xFFC62828),
            items: [],
          ),
          ProgramScheduleData(
            id: '3',
            title: 'Program 3',
            headerColor: const Color(0xFFFFF8E1),
            cardHeaderBg: const Color(0xFFFFF9C4),
            barColor: const Color(0xFFFB8C00),
            labelColor: const Color(0xFFEF6C00),
            items: [
              ScheduleItem(
                no: 10,
                dateStr: '10 Sep 2026 (Thu)',
                programTitle: 'Program 3',
                programColor: const Color(0xFFFFF9C4),
                programTextColor: const Color(0xFFEF6C00),
                startTime: '14:00',
                endTime: '14:20',
                duration: '20 min',
                startHour: 14.0,
                endHour: 14.3333,
                startReason: 'Scheduled Start',
                endReason: 'User Stop',
              ),
            ],
          ),
          ProgramScheduleData(
            id: '4',
            title: 'Program 4',
            headerColor: const Color(0xFFF3E5F5),
            cardHeaderBg: const Color(0xFFE1BEE7),
            barColor: const Color(0xFF8E24AA),
            labelColor: const Color(0xFF6A1B9A),
            items: [
              ScheduleItem(
                no: 11,
                dateStr: '10 Sep 2026 (Thu)',
                programTitle: 'Program 4',
                programColor: const Color(0xFFE1BEE7),
                programTextColor: const Color(0xFF6A1B9A),
                startTime: '16:45',
                endTime: '17:00',
                duration: '15 min',
                startHour: 16.75,
                endHour: 17.0,
                startReason: 'Auto Start',
                endReason: 'Sensor Off',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  List<ScheduleItem> _getFilteredScheduleRecords() {
    List<ScheduleItem> records = [];
    for (var daily in _dailyTimelines) {
      if (daily.date.isBefore(_fromDate) ||
          daily.date.isAfter(_toDate.add(const Duration(days: 1)))) {
        continue;
      }
      for (var prog in daily.programs) {
        String filterToApply = _selectedProgramTitle ?? _selectedProgramFilter;
        if (filterToApply != 'All Programs' && prog.title != filterToApply) {
          continue;
        }
        records.addAll(prog.items);
      }
    }
    return records;
  }

  void _openRightSideProgramDetails(String programTitle,
      {ScheduleItem? selectedItem}) {
    setState(() {
      _selectedProgramTitle = programTitle;
      _selectedItem = selectedItem;
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildRightSideDrawer(context),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterCard(context),
                    const SizedBox(height: 14),
                    _buildTimelineSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    String dateRangeStr =
        "${DateFormat('dd MMM yyyy').format(_fromDate)} - ${DateFormat('dd MMM yyyy').format(_toDate)}";
    final theme = Theme.of(context);
    final primaryDark = theme.primaryColorDark;
    final primary = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: primaryDark,
        gradient: LinearGradient(
          colors: [primaryDark, primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 650;
          if (isMobile) {
            return Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Program Time Schedule",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "View and monitor program running history",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHeaderBadge(Icons.calendar_today, dateRangeStr),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              const Icon(Icons.settings, color: Colors.white, size: 26),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Program Time Schedule",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildHeaderBadge(Icons.calendar_today, dateRangeStr),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("From Date",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fromDate,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _fromDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Text(DateFormat('dd MMM yyyy').format(_fromDate),
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_today,
                              size: 16, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("To Date",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _toDate,
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _toDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Text(DateFormat('dd MMM yyyy').format(_toDate),
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 8),
                          const Icon(Icons.calendar_today,
                              size: 16, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Program",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedProgramFilter,
                        isDense: true,
                        items: [
                          'All Programs',
                          'Program 1',
                          'Program 2',
                          'Program 3',
                          'Program 4'
                        ]
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e,
                                    style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedProgramFilter = val;
                              _selectedProgramTitle =
                                  val == 'All Programs' ? null : val;
                              _selectedItem = null;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  setState(() {});
                  fetchZoneLogApi();
                },
                icon: const Icon(Icons.filter_alt_outlined,
                    size: 16, color: Colors.white),
                label: const Text("Apply",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  setState(() {
                    _fromDate = DateTime(2026, 9, 8);
                    _toDate = DateTime(2026, 9, 10);
                    _selectedProgramFilter = 'All Programs';
                    _selectedProgramTitle = null;
                    _selectedItem = null;
                  });
                },
                icon: const Icon(Icons.refresh,
                    size: 16, color: Color(0xFF334155)),
                label: const Text("Clear",
                    style: TextStyle(
                        color: Color(0xFF334155), fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Timeline View",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var daily in _dailyTimelines)
          if (!daily.date.isBefore(_fromDate) && !daily.date.isAfter(_toDate))
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildDailyTimelineCard(context, daily),
            ),
      ],
    );
  }

  Widget _buildViewModeButton(String mode) {
    bool isSelected = _selectedViewMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedViewMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          mode,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyTimelineCard(
      BuildContext context, DailyTimelineData daily) {
    final primaryDark = Theme.of(context).primaryColorDark;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double availableWidth = constraints.maxWidth;
          double leftColWidth = availableWidth < 600 ? 140 : 160;
          double timelineWidth = availableWidth - leftColWidth;

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: leftColWidth,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: primaryDark,
                      borderRadius:
                          const BorderRadius.only(topLeft: Radius.circular(7)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          daily.dateHeader,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: primaryDark.withAlpha(15),
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(7)),
                        border: Border(
                            bottom:
                                BorderSide(color: primaryDark.withAlpha(30))),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: timelineWidth < 700
                            ? const AlwaysScrollableScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        child: SizedBox(
                          width: timelineWidth < 700 ? 700 : timelineWidth,
                          child: _buildTimeScaleHeader(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              for (int i = 0; i < daily.programs.length; i++)
                if (_selectedProgramFilter == 'All Programs' ||
                    daily.programs[i].title == _selectedProgramFilter)
                  _buildProgramRow(
                    daily.programs[i],
                    leftColWidth,
                    timelineWidth < 700 ? 700 : timelineWidth,
                    i == daily.programs.length - 1,
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeScaleHeader(BuildContext context) {
    List<String> timeLabels = [
      "00:00",
      "02:00",
      "04:00",
      "06:00",
      "08:00",
      "10:00",
      "12:00",
      "14:00",
      "16:00",
      "18:00",
      "20:00",
      "22:00",
      "24:00"
    ];
    final primaryDark = Theme.of(context).primaryColorDark;

    return Row(
      children: [
        for (int i = 0; i < timeLabels.length; i++)
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                timeLabels[i],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: primaryDark,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgramRow(
    ProgramScheduleData program,
    double leftColWidth,
    double timelineContentWidth,
    bool isLast,
  ) {
    return InkWell(
      onTap: () => _openRightSideProgramDetails(program.title),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: leftColWidth,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: program.headerColor,
                border:
                    const Border(right: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      program.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: program.labelColor,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: timelineContentWidth > 600
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  width: timelineContentWidth,
                  height: 48,
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          for (int i = 0; i < 12; i++)
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                      right:
                                          BorderSide(color: Color(0xFFEDF2F7))),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Center(
                        child: Container(
                          height: 18,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x99E2E8F0),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      for (var item in program.items)
                        ScheduleBarWidget(
                          item: item,
                          program: program,
                          isSelected: _selectedItem == item,
                          totalWidth: timelineContentWidth,
                          onItemSelected: (selected) {
                            _openRightSideProgramDetails(program.title,
                                selectedItem: selected);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSideDrawer(BuildContext context) {
    List<ScheduleItem> records = _getFilteredScheduleRecords();
    final primaryDark = Theme.of(context).primaryColorDark;
    double drawerWidth = MediaQuery.of(context).size.width > 800
        ? 550
        : MediaQuery.of(context).size.width * 0.85;

    return Drawer(
      width: drawerWidth,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: primaryDark,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.table_chart_outlined,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "${_selectedProgramTitle ?? 'Program'} Records",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Records: ${records.length}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF334155)),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Exporting Records to CSV...")),
                            );
                          },
                          icon: const Icon(Icons.download,
                              size: 14, color: Color(0xFF1E88E5)),
                          label: const Text("CSV",
                              style: TextStyle(
                                  color: Color(0xFF1E88E5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: drawerWidth - 30),
                        child: Table(
                          border: TableBorder.all(
                              color: const Color(0xFFE2E8F0), width: 1),
                          columnWidths: const {
                            0: FlexColumnWidth(1.4),
                            1: FlexColumnWidth(1.1),
                            2: FlexColumnWidth(1.0),
                            3: FlexColumnWidth(1.0),
                            4: FlexColumnWidth(1.0),
                            5: FlexColumnWidth(1.8),
                            6: FlexColumnWidth(1.8),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                  color: primaryDark.withAlpha(20)),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                  child: Text("Date",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: primaryDark)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                  child: Text("Program",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: primaryDark)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                  child: Text("Start",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: primaryDark)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                  child: Text("End",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: primaryDark)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                  child: Text("Duration",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: primaryDark)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                  child: Text("Start Reason",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: primaryDark)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 4),
                                  child: Text("End Reason",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: primaryDark)),
                                ),
                              ],
                            ),
                            for (var rec in records)
                              TableRow(
                                decoration: BoxDecoration(
                                  color: _selectedItem == rec
                                      ? primaryDark.withAlpha(25)
                                      : Colors.transparent,
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    child: Text(rec.dateStr,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF334155))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 4),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: rec.programColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          rec.programTitle,
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: rec.programTextColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    child: Text(rec.startTime,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF334155))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    child: Text(rec.endTime,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF334155))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    child: Text(rec.duration,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF334155))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    child: Text(rec.startReason,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF334155))),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    child: Text(rec.endReason,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF334155))),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleBarWidget extends StatefulWidget {
  final ScheduleItem item;
  final ProgramScheduleData program;
  final bool isSelected;
  final double totalWidth;
  final Function(ScheduleItem) onItemSelected;

  const ScheduleBarWidget({
    super.key,
    required this.item,
    required this.program,
    required this.isSelected,
    required this.totalWidth,
    required this.onItemSelected,
  });

  @override
  State<ScheduleBarWidget> createState() => _ScheduleBarWidgetState();
}

class _ScheduleBarWidgetState extends State<ScheduleBarWidget> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showPopup() {
    _hidePopup();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hidePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hidePopup();
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 230,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(-80, -125),
          child: Material(
            elevation: 6,
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6F3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF80CBC4)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.program.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.item.startTime} - ${widget.item.endTime}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xFF475569),
                        ),
                      ),
                      Text(
                        "(${widget.item.duration})",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                      height: 10, thickness: 0.8, color: Color(0xFFB2DFDB)),
                  Row(
                    children: [
                      const Text(
                        "Start Reason",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(":",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.item.startReason,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Text(
                        "End Reason",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFFC62828),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(":",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.item.startReason,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Text(
                        "Percentage",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(":",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.item.percentage,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double leftPosition = (widget.item.startHour / 24.0) * widget.totalWidth;
    double durationHours = widget.item.endHour - widget.item.startHour;
    double calcWidth = (durationHours / 24.0) * widget.totalWidth;
    double barWidth = calcWidth < 18 ? 18 : calcWidth;

    return Positioned(
      left: leftPosition.clamp(0, widget.totalWidth - barWidth),
      top: 4,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: MouseRegion(
          onEnter: (_) => _showPopup(),
          onExit: (_) => _hidePopup(),
          child: GestureDetector(
            onTap: () {
              widget.onItemSelected(widget.item);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "${widget.item.startTime} - ${widget.item.endTime}",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: widget.program.barColor,
                  ),
                ),
                const SizedBox(height: 1),
                Container(
                  width: barWidth,
                  height: 22,
                  decoration: BoxDecoration(
                    color: widget.program.barColor,
                    borderRadius: BorderRadius.circular(3),
                    border: widget.isSelected
                        ? Border.all(color: Colors.black, width: 1.5)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: widget.program.barColor.withAlpha(102),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
