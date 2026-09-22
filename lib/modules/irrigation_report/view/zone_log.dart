import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/customer/site_model.dart';
import '../repository/irrigation_repository.dart';
import 'zone_log_exporter_stub.dart'
    if (dart.library.html) 'zone_log_exporter_web.dart';

class ScheduleItem {
  final int no;
  final String dateStr;
  final String programTitle;
  final String sequenceTitle;
  final String headUnit;
  final String pump;
  final Color programColor;
  final Color programTextColor;
  final String startTime;
  final String endTime;
  final String duration;
  final double startHour;
  final double endHour;
  final String startReason;
  final String endReason;

  ScheduleItem({
    required this.no,
    required this.dateStr,
    required this.programTitle,
    required this.sequenceTitle,
    required this.headUnit,
    required this.pump,
    required this.programColor,
    required this.programTextColor,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.startHour,
    required this.endHour,
    required this.startReason,
    required this.endReason,
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

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  String _selectedProgramFilter = 'All Programs';

  String? _selectedProgramTitle;
  ScheduleItem? _selectedItem;

  List<DailyTimelineData> _dailyTimelines = [];
  List<String> _programDropdownOptions = ['All Programs'];

  @override
  void initState() {
    super.initState();

    fetchZoneLogApi();
  }

  Future<void> fetchZoneLogApi() async {
    String fromDateStr = DateFormat('yyyy-MM-dd').format(_fromDate);
    String toDateStr = DateFormat('yyyy-MM-dd').format(_toDate);

    Map<String, dynamic> body = {
      "userId": widget.userData['customerId'] ?? 1002,
      "controllerId": widget.userData['controllerId'] ?? 3382,
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
        "ActualEndTime",
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
        _parseZoneApiResponse(jsonData['data']);
      }
    } catch (e, stackTrace) {
      debugPrint('Error in Zone Log API: ${e.toString()}');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _parseZoneApiResponse(Map<String, dynamic> responseData) {
    // 1. Build Sequence SNo -> Name Mapping and Program SNo -> Name Mapping
    Map<String, String> sequenceNameMap = {};
    Map<int, String> programNameMap = {};
    Set<String> uniqueProgNames = {'All Programs'};

    if (responseData['default'] != null) {
      var defaultObj = responseData['default'];

      if (defaultObj['sequence'] != null && defaultObj['sequence'] is List) {
        for (var seq in defaultObj['sequence']) {
          if (seq is Map) {
            var sNo = seq['sNo'];
            String name =
                seq['name'] ?? seq['seqName'] ?? seq['sequenceName'] ?? '';
            if (sNo != null && name.isNotEmpty) {
              sequenceNameMap[sNo.toString()] = name;
              if (sNo is num) {
                sequenceNameMap[sNo.toString()] = name;
                sequenceNameMap[sNo.toInt().toString()] = name;
                sequenceNameMap[sNo.toDouble().toString()] = name;
              }
            }
          }
        }
      }

      if (defaultObj['zone'] != null && defaultObj['zone'] is List) {
        for (var z in defaultObj['zone']) {
          if (z is Map) {
            var sNo = z['sNo'];
            String name = z['name'] ?? z['zoneName'] ?? '';
            if (sNo != null && name.isNotEmpty) {
              sequenceNameMap.putIfAbsent(sNo.toString(), () => name);
            }
          }
        }
      }

      if (defaultObj['program'] != null && defaultObj['program'] is List) {
        for (var p in defaultObj['program']) {
          if (p is Map) {
            int sNo = p['sNo'] is int
                ? p['sNo']
                : int.tryParse(p['sNo'].toString()) ?? 0;
            String name = p['name'] ?? 'Program $sNo';
            programNameMap[sNo] = name;
          }
        }
      }
    }

    List<DailyTimelineData> parsedDailyTimelines = [];
    int itemGlobalNo = 1;

    // 2. Parse log entries date-wise (Grouped by rawLogDate so multiple runs on the same date appear together)
    if (responseData['log'] != null && responseData['log'] is List) {
      List logs = responseData['log'];

      Map<String, Map<String, List<ScheduleItem>>> dateProgramItemsMap = {};
      Map<String, Map<String, int>> dateProgramSNoMap = {};
      Map<String, DateTime> dateParsedMap = {};

      for (var logEntry in logs) {
        String rawLogDate = logEntry['logDate'] ?? '';
        if (rawLogDate.isEmpty) continue;

        DateTime parsedDate;
        try {
          parsedDate = DateFormat('yyyy-MM-dd').parse(rawLogDate);
        } catch (_) {
          parsedDate = DateTime.now();
        }
        dateParsedMap[rawLogDate] = parsedDate;

        var irrigation = logEntry['irrigation'];
        if (irrigation == null) continue;

        List programSNos = irrigation['ProgramS_No'] ?? [];
        List zoneSNos = irrigation['ZoneS_No'] ?? [];
        List headUnits = irrigation['HeadUnit'] ?? [];
        List pumps = irrigation['Pump'] ?? [];
        List actualStopTimes = irrigation['ActualEndTime'] ?? [];
        List actualStartTimes = irrigation['ActualStartTime'] ?? [];
        List actualStartReasons = irrigation['ActualStartReason'] ?? [];
        List actualStopReasons = irrigation['ActualStopReason'] ?? [];

        int baseLength = programSNos.isNotEmpty
            ? programSNos.length
            : (zoneSNos.isNotEmpty ? zoneSNos.length : actualStopTimes.length);

        if (actualStartTimes.length > baseLength &&
            actualStartTimes.where((e) => e != null).length == baseLength) {
          actualStartTimes = actualStartTimes.where((e) => e != null).toList();
        }
        if (actualStopTimes.length > baseLength &&
            actualStopTimes.where((e) => e != null).length == baseLength) {
          actualStopTimes = actualStopTimes.where((e) => e != null).toList();
        }
        if (actualStartReasons.length > baseLength &&
            actualStartReasons.where((e) => e != null).length == baseLength) {
          actualStartReasons =
              actualStartReasons.where((e) => e != null).toList();
        }
        if (actualStopReasons.length > baseLength &&
            actualStopReasons.where((e) => e != null).length == baseLength) {
          actualStopReasons =
              actualStopReasons.where((e) => e != null).toList();
        }

        int lengthToUse = baseLength > 0 ? baseLength : actualStartTimes.length;

        for (int i = 0; i < lengthToUse; i++) {
          int pSNo = (i < programSNos.length)
              ? (programSNos[i] is int
                  ? programSNos[i]
                  : int.tryParse(programSNos[i].toString()) ?? (i + 1))
              : (i + 1);

          String progName = programNameMap[pSNo] ?? 'Program $pSNo';

          var zVal = (i < zoneSNos.length) ? zoneSNos[i] : null;
          String seqName = '';
          if (zVal != null) {
            String zStr = zVal.toString();
            if (sequenceNameMap.containsKey(zStr) &&
                sequenceNameMap[zStr]!.isNotEmpty) {
              seqName = sequenceNameMap[zStr]!;
            } else {
              double? zDouble = double.tryParse(zStr);
              if (zDouble != null) {
                if (sequenceNameMap.containsKey(zDouble.toString()) &&
                    sequenceNameMap[zDouble.toString()]!.isNotEmpty) {
                  seqName = sequenceNameMap[zDouble.toString()]!;
                } else {
                  int zInt = zDouble.toInt();
                  if (sequenceNameMap.containsKey(zInt.toString()) &&
                      sequenceNameMap[zInt.toString()]!.isNotEmpty) {
                    seqName = sequenceNameMap[zInt.toString()]!;
                  } else if (programNameMap.containsKey(zInt) &&
                      programNameMap[zInt]!.isNotEmpty) {
                    seqName = programNameMap[zInt]!;
                  }
                }
              }
            }
          }

          if (seqName.isEmpty &&
              sequenceNameMap.containsKey(pSNo.toString()) &&
              sequenceNameMap[pSNo.toString()]!.isNotEmpty) {
            seqName = sequenceNameMap[pSNo.toString()]!;
          }

          if (seqName.isEmpty) {
            seqName = progName;
          }

          String headUnitStr = (i < headUnits.length &&
                  headUnits[i] != null &&
                  headUnits[i].toString().isNotEmpty)
              ? headUnits[i].toString()
              : '--';
          String pumpStr = (i < pumps.length &&
                  pumps[i] != null &&
                  pumps[i].toString().isNotEmpty)
              ? pumps[i].toString()
              : '--';

          uniqueProgNames.add(progName);

          // Pre-ensure this program row exists
          dateProgramItemsMap
              .putIfAbsent(rawLogDate, () => {})
              .putIfAbsent(progName, () => []);
          dateProgramSNoMap.putIfAbsent(rawLogDate, () => {})[progName] = pSNo;

          String stopTimeRaw =
              (i < actualStopTimes.length && actualStopTimes[i] != null)
                  ? actualStopTimes[i].toString()
                  : '';
          String startTimeRaw =
              (i < actualStartTimes.length && actualStartTimes[i] != null)
                  ? actualStartTimes[i].toString()
                  : '';
          String startReasonRaw =
              (i < actualStartReasons.length && actualStartReasons[i] != null)
                  ? actualStartReasons[i].toString()
                  : '';
          String stopReasonRaw =
              (i < actualStopReasons.length && actualStopReasons[i] != null)
                  ? actualStopReasons[i].toString()
                  : '';

          List<String> subStartTimes =
              startTimeRaw.isNotEmpty ? startTimeRaw.split('_') : [];
          List<String> subStopTimes =
              stopTimeRaw.isNotEmpty ? stopTimeRaw.split('_') : [];
          List<String> subStartReasons =
              startReasonRaw.isNotEmpty ? startReasonRaw.split('_') : [];
          List<String> subStopReasons =
              stopReasonRaw.isNotEmpty ? stopReasonRaw.split('_') : [];

          int subCount = subStartTimes.length;
          if (subStopTimes.length > subCount) subCount = subStopTimes.length;
          if (subCount == 0) subCount = 1;

          for (int s = 0; s < subCount; s++) {
            String startTimeStr =
                (s < subStartTimes.length) ? subStartTimes[s].trim() : '';
            String stopTimeStr =
                (s < subStopTimes.length) ? subStopTimes[s].trim() : '';
            String startReasonStr = (s < subStartReasons.length)
                ? subStartReasons[s].trim()
                : (subStartReasons.isNotEmpty
                    ? subStartReasons.last.trim()
                    : '');
            String stopReasonStr = (s < subStopReasons.length)
                ? subStopReasons[s].trim()
                : (subStopReasons.isNotEmpty ? subStopReasons.last.trim() : '');

            double stopHour = 0.0;
            int stopH = 0, stopM = 0, stopS = 0;
            if (stopTimeStr.isNotEmpty) {
              try {
                var parts = stopTimeStr.split(':');
                stopH = int.parse(parts[0]);
                stopM = int.parse(parts[1]);
                if (parts.length > 2) stopS = int.parse(parts[2]);
                stopHour = stopH + (stopM / 60.0) + (stopS / 3600.0);
              } catch (_) {}
            }

            double startHour = 0.0;
            int startH = 0, startM = 0, startS = 0;
            if (startTimeStr.isNotEmpty) {
              try {
                var parts = startTimeStr.split(':');
                startH = int.parse(parts[0]);
                startM = int.parse(parts[1]);
                if (parts.length > 2) startS = int.parse(parts[2]);
                startHour = startH + (startM / 60.0) + (startS / 3600.0);
              } catch (_) {}
            }

            String durationStr = '';
            if (startTimeStr.isNotEmpty && stopTimeStr.isNotEmpty) {
              try {
                int diffSec = (stopH * 3600 + stopM * 60 + stopS) -
                    (startH * 3600 + startM * 60 + startS);
                if (diffSec > 0) {
                  int min = diffSec ~/ 60;
                  int sec = diffSec % 60;
                  if (min > 0 && sec > 0) {
                    durationStr = "$min m $sec s";
                  } else if (min > 0) {
                    durationStr = "$min min";
                  } else {
                    durationStr = "$sec sec";
                  }
                }
              } catch (_) {}
            }

            int colorIdx = pSNo;
            String dateHeaderStr =
                DateFormat('dd MMM yyyy (E)').format(parsedDate);

            ScheduleItem item = ScheduleItem(
              no: itemGlobalNo++,
              dateStr: dateHeaderStr,
              programTitle: progName,
              sequenceTitle: seqName,
              headUnit: headUnitStr.isNotEmpty ? headUnitStr : '--',
              pump: pumpStr.isNotEmpty ? pumpStr : '--',
              programColor: _getProgramColor(colorIdx),
              programTextColor: _getProgramTextColor(colorIdx),
              startTime: startTimeStr.isNotEmpty ? startTimeStr : '--',
              endTime: stopTimeStr.isNotEmpty ? stopTimeStr : '--',
              duration: durationStr.isNotEmpty ? durationStr : '--',
              startHour: startHour,
              endHour: stopHour,
              startReason: startReasonStr.isNotEmpty ? startReasonStr : '--',
              endReason: stopReasonStr.isNotEmpty ? stopReasonStr : '--',
            );

            dateProgramItemsMap
                .putIfAbsent(rawLogDate, () => {})
                .putIfAbsent(progName, () => [])
                .add(item);
            dateProgramSNoMap.putIfAbsent(rawLogDate, () => {})[progName] =
                colorIdx;
          }
        }
      }

      dateProgramItemsMap.forEach((rawDate, progMap) {
        DateTime pDate = dateParsedMap[rawDate] ?? DateTime.now();
        String dateHeader = DateFormat('dd MMM yyyy (E)').format(pDate);

        List<ProgramScheduleData> programListForDay = [];
        progMap.forEach((progTitle, itemsList) {
          int colorIdx = dateProgramSNoMap[rawDate]?[progTitle] ??
              progTitle.hashCode.abs();
          programListForDay.add(
            ProgramScheduleData(
              id: colorIdx.toString(),
              title: progTitle,
              headerColor: _getProgramColor(colorIdx),
              cardHeaderBg: _getProgramColor(colorIdx),
              barColor: _getProgramBarColor(colorIdx),
              labelColor: _getProgramTextColor(colorIdx),
              items: itemsList,
            ),
          );
        });

        // Sort programs by sNo
        programListForDay.sort((a, b) {
          int idA = int.tryParse(a.id) ?? 0;
          int idB = int.tryParse(b.id) ?? 0;
          if (idA != idB) return idA.compareTo(idB);
          return a.title.compareTo(b.title);
        });

        if (programListForDay.isNotEmpty) {
          parsedDailyTimelines.add(
            DailyTimelineData(
              dateHeader: dateHeader,
              date: pDate,
              programs: programListForDay,
            ),
          );
        }
      });
    }

    // Sort dates chronologically so timeline always shows in correct order
    parsedDailyTimelines.sort((a, b) => a.date.compareTo(b.date));

    if (parsedDailyTimelines.isNotEmpty) {
      setState(() {
        _dailyTimelines = parsedDailyTimelines;
        _programDropdownOptions = uniqueProgNames.toList();
      });
    }
  }

  Color _getProgramColor(int sNo) {
    List<Color> colors = [
      const Color(0xFFDCEDC8),
      const Color(0xFFFFCDD2),
      const Color(0xFFFFF9C4),
      const Color(0xFFE1BEE7),
      const Color(0xFFB2EBF2),
      const Color(0xFFFFE0B2),
      const Color(0xFFD1C4E9),
    ];
    int idx = sNo <= 0 ? 0 : (sNo - 1) % colors.length;
    return colors[idx.abs() % colors.length];
  }

  Color _getProgramBarColor(int sNo) {
    List<Color> colors = [
      const Color(0xFF4CAF50),
      const Color(0xFFE53935),
      const Color(0xFFFB8C00),
      const Color(0xFF8E24AA),
      const Color(0xFF00ACC1),
      const Color(0xFFF57C00),
      const Color(0xFF5E35B1),
    ];
    int idx = sNo <= 0 ? 0 : (sNo - 1) % colors.length;
    return colors[idx.abs() % colors.length];
  }

  Color _getProgramTextColor(int sNo) {
    List<Color> colors = [
      const Color(0xFF2E7D32),
      const Color(0xFFC62828),
      const Color(0xFFEF6C00),
      const Color(0xFF6A1B9A),
      const Color(0xFF006064),
      const Color(0xFFE65100),
      const Color(0xFF4527A0),
    ];
    int idx = sNo <= 0 ? 0 : (sNo - 1) % colors.length;
    return colors[idx.abs() % colors.length];
  }

  List<ScheduleItem> _getFilteredScheduleRecords() {
    List<ScheduleItem> records = [];
    String filterToApply = _selectedProgramTitle ?? _selectedProgramFilter;

    for (var daily in _dailyTimelines) {
      DateTime dailyDay =
          DateTime(daily.date.year, daily.date.month, daily.date.day);
      DateTime startDay =
          DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
      DateTime endDay =
          DateTime(_toDate.year, _toDate.month, _toDate.day, 23, 59, 59);

      if (dailyDay.isBefore(startDay) || dailyDay.isAfter(endDay)) {
        continue;
      }

      for (var prog in daily.programs) {
        for (var item in prog.items) {
          if (filterToApply != 'All Programs') {
            bool matches = (prog.title == filterToApply) ||
                (item.programTitle == filterToApply) ||
                (item.sequenceTitle == filterToApply);
            if (!matches) continue;
          }
          records.add(item);
        }
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
      // endDrawer: _buildRightSideDrawer(context),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: _buildFilterCard(context)),
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
                        value: _programDropdownOptions
                                .contains(_selectedProgramFilter)
                            ? _selectedProgramFilter
                            : 'All Programs',
                        isDense: true,
                        items: _programDropdownOptions
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      setState(() {});
                      fetchZoneLogApi();
                    },
                    icon: const Icon(Icons.filter_alt_outlined,
                        size: 16, color: Colors.white),
                    label: const Text("Filter",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      setState(() {
                        _fromDate = DateTime.now();
                        _toDate = DateTime.now();
                        _selectedProgramFilter = 'All Programs';
                        _selectedProgramTitle = null;
                        _selectedItem = null;
                      });
                      fetchZoneLogApi();
                    },
                    icon: const Icon(Icons.refresh,
                        size: 16, color: Color(0xFF334155)),
                    label: const Text("Clear",
                        style: TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
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
        const SizedBox(height: 10),
        if (_dailyTimelines.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          for (var daily in _dailyTimelines)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildDailyTimelineCard(context, daily),
            ),
      ],
    );
  }

  Widget _buildDailyTimelineCard(
      BuildContext context, DailyTimelineData daily) {
    var filteredPrograms = daily.programs
        .where((p) =>
            _selectedProgramFilter == 'All Programs' ||
            p.title == _selectedProgramFilter)
        .toList();

    // Sort programs by sNo for consistent display order
    filteredPrograms.sort((a, b) {
      int idA = int.tryParse(a.id) ?? 0;
      int idB = int.tryParse(b.id) ?? 0;
      if (idA != idB) return idA.compareTo(idB);
      return a.title.compareTo(b.title);
    });

    return _buildMobileTableCard(context, daily, filteredPrograms);
  }

  /// Mobile-optimized Full-Text Scrollable Table Card (No color bars)
  Widget _buildMobileTableCard(
    BuildContext context,
    DailyTimelineData daily,
    List<ProgramScheduleData> filteredPrograms,
  ) {
    final primaryDark = Theme.of(context).primaryColorDark;

    List<ScheduleItem> allItems = [];
    for (var prog in filteredPrograms) {
      allItems.addAll(prog.items);
    }

    var activePrograms =
        filteredPrograms.where((p) => p.items.isNotEmpty).toList();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Date Badge & Record Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: primaryDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 15, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      daily.dateHeader,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${allItems.length} ${allItems.length == 1 ? 'record' : 'records'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (allItems.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      if (allItems.isEmpty) {
                        messenger.showSnackBar(
                          const SnackBar(
                              content: Text("No records available to export")),
                        );
                        return;
                      }
                      String sanitizeName =
                          (_selectedProgramFilter != 'All Programs'
                                  ? _selectedProgramFilter
                                  : 'ZoneLog_${daily.dateHeader}')
                              .replaceAll(RegExp(r'[^\w\s\-]'), '_');
                      String fileName =
                          "${sanitizeName}_${DateFormat('yyyyMMdd').format(DateTime.now())}";
                      String? res =
                          await exportZoneLogToCSV(allItems, fileName);
                      if (res != null) {
                        messenger.showSnackBar(
                          SnackBar(
                              content: Text("Excel Download Successful: $res")),
                        );
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(
                              content: Text("Failed to export Excel")),
                        );
                      }
                    },
                    icon: const Icon(Icons.download,
                        size: 14, color: Color(0xFF1E88E5)),
                    label: const Text("Excel",
                        style: TextStyle(
                            color: Color(0xFF1E88E5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      if (allItems.isEmpty) {
                        messenger.showSnackBar(
                          const SnackBar(
                              content: Text("No records available to export")),
                        );
                        return;
                      }
                      String sanitizeName =
                          (_selectedProgramFilter != 'All Programs'
                                  ? _selectedProgramFilter
                                  : 'ZoneLog_${daily.dateHeader}')
                              .replaceAll(RegExp(r'[^\w\s\-]'), '_');
                      String fileName =
                          "${sanitizeName}_${DateFormat('yyyyMMdd').format(DateTime.now())}";
                      String? res =
                          await exportZoneLogToPDF(allItems, fileName);
                      if (res != null) {
                        messenger.showSnackBar(
                          SnackBar(
                              content: Text("PDF Download Successful: $res")),
                        );
                      } else {
                        messenger.showSnackBar(
                          const SnackBar(content: Text("Failed to export PDF")),
                        );
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf,
                        size: 14, color: Color(0xFFD32F2F)),
                    label: const Text("PDF",
                        style: TextStyle(
                            color: Color(0xFFD32F2F),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          if (activePrograms.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  "No irrigation records for this date",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          else
            for (var prog in activePrograms)
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      collapsedBackgroundColor: prog.headerColor.withAlpha(50),
                      backgroundColor: Colors.white,
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      childrenPadding: const EdgeInsets.only(bottom: 8),
                      leading: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: prog.barColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            prog.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: prog.labelColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: prog.barColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "${prog.items.length} ${prog.items.length == 1 ? 'record' : 'records'}",
                              style: TextStyle(
                                color: prog.labelColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double availableWidth = constraints.maxWidth;
                            double minTableWidth = 1045;
                            double tableWidth = availableWidth > minTableWidth
                                ? availableWidth
                                : minTableWidth;

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: SizedBox(
                                width: tableWidth,
                                child: Table(
                                  border: TableBorder.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                  defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  columnWidths: const {
                                    0: FlexColumnWidth(1.45), // Sequence Name
                                    1: FlexColumnWidth(0.9), // HeadUnit
                                    2: FlexColumnWidth(0.9), // Pump
                                    3: FlexColumnWidth(1.0), // Start Time
                                    4: FlexColumnWidth(1.0), // End Time
                                    5: FlexColumnWidth(0.95), // Duration
                                    6: FlexColumnWidth(1.65), // Start Reason
                                    7: FlexColumnWidth(2.6), // End Reason
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: primaryDark.withAlpha(20),
                                      ),
                                      children: [
                                        _buildTableHeaderCell(
                                            "Sequence Name", primaryDark),
                                        _buildTableHeaderCell(
                                            "HeadUnit", primaryDark),
                                        _buildTableHeaderCell(
                                            "Pump", primaryDark),
                                        _buildTableHeaderCell(
                                            "Start Time", primaryDark),
                                        _buildTableHeaderCell(
                                            "End Time", primaryDark),
                                        _buildTableHeaderCell(
                                            "Duration", primaryDark),
                                        _buildTableHeaderCell(
                                            "Start Reason", primaryDark),
                                        _buildTableHeaderCell(
                                            "End Reason", primaryDark),
                                      ],
                                    ),
                                    for (var rec in prog.items)
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: _selectedItem == rec
                                              ? primaryDark.withAlpha(25)
                                              : Colors.transparent,
                                        ),
                                        children: [
                                          _buildSequenceBadgeCell(rec),
                                          _buildTableCell(rec.headUnit,
                                              isSemibold: true),
                                          _buildTableCell(rec.pump,
                                              isSemibold: true),
                                          _buildTableCell(rec.startTime),
                                          _buildTableCell(rec.endTime),
                                          _buildTableCell(rec.duration),
                                          _buildTableCell(rec.startReason),
                                          _buildTableCell(rec.endReason),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, Color primaryDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        softWrap: false,
        maxLines: 1,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: primaryDark,
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    bool isBold = false,
    bool isSemibold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        softWrap: false,
        maxLines: 1,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold
              ? FontWeight.bold
              : (isSemibold ? FontWeight.w600 : FontWeight.normal),
          color: const Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildSequenceBadgeCell(ScheduleItem rec) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: Center(
        child: InkWell(
          onTap: () =>
              _openRightSideProgramDetails(rec.programTitle, selectedItem: rec),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: rec.programColor.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: rec.programTextColor.withAlpha(80),
              ),
            ),
            child: Text(
              rec.sequenceTitle,
              textAlign: TextAlign.center,
              softWrap: false,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: rec.programTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRightSideDrawer(BuildContext context) {
    List<ScheduleItem> records = _getFilteredScheduleRecords();
    final primaryDark = Theme.of(context).primaryColorDark;
    double screenWidth = MediaQuery.of(context).size.width;
    double drawerWidth = screenWidth > 800 ? 650 : screenWidth * 0.95;

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
                        Row(
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                side:
                                    const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                if (records.isEmpty) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "No records available to export")),
                                  );
                                  return;
                                }
                                String sanitizeName =
                                    (_selectedProgramTitle ?? 'ZoneLog')
                                        .replaceAll(RegExp(r'[^\w\s\-]'), '_');
                                String fileName =
                                    "${sanitizeName}_${DateFormat('yyyyMMdd').format(DateTime.now())}";
                                String? res =
                                    await exportZoneLogToCSV(records, fileName);
                                if (res != null) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Excel Downloaded: $res")),
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Failed to export Excel")),
                                  );
                                }
                              },
                              icon: const Icon(Icons.download,
                                  size: 14, color: Color(0xFF1E88E5)),
                              label: const Text("Excel",
                                  style: TextStyle(
                                      color: Color(0xFF1E88E5),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                side:
                                    const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                if (records.isEmpty) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "No records available to export")),
                                  );
                                  return;
                                }
                                String sanitizeName =
                                    (_selectedProgramTitle ?? 'ZoneLog')
                                        .replaceAll(RegExp(r'[^\w\s\-]'), '_');
                                String fileName =
                                    "${sanitizeName}_${DateFormat('yyyyMMdd').format(DateTime.now())}";
                                String? res =
                                    await exportZoneLogToPDF(records, fileName);
                                if (res != null) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "PDF Download Successful: $res")),
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                        content: Text("Failed to export PDF")),
                                  );
                                }
                              },
                              icon: const Icon(Icons.picture_as_pdf,
                                  size: 14, color: Color(0xFFD32F2F)),
                              label: const Text("PDF",
                                  style: TextStyle(
                                      color: Color(0xFFD32F2F),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Table(
                        border: TableBorder.all(
                            color: const Color(0xFFE2E8F0), width: 1),
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FixedColumnWidth(130), // Date
                          1: FixedColumnWidth(130), // Program Name
                          2: FixedColumnWidth(145), // Sequence Name
                          3: FixedColumnWidth(90), // HeadUnit
                          4: FixedColumnWidth(90), // Pump
                          5: FixedColumnWidth(100), // Start
                          6: FixedColumnWidth(100), // End
                          7: FixedColumnWidth(95), // Duration
                          8: FixedColumnWidth(165), // Start Reason
                          9: FixedColumnWidth(260), // End Reason
                        },
                        children: [
                          TableRow(
                            decoration:
                                BoxDecoration(color: primaryDark.withAlpha(20)),
                            children: [
                              _buildTableHeaderCell("Date", primaryDark),
                              _buildTableHeaderCell(
                                  "Program Name", primaryDark),
                              _buildTableHeaderCell(
                                  "Sequence Name", primaryDark),
                              _buildTableHeaderCell("HeadUnit", primaryDark),
                              _buildTableHeaderCell("Pump", primaryDark),
                              _buildTableHeaderCell("Start Time", primaryDark),
                              _buildTableHeaderCell("End Time", primaryDark),
                              _buildTableHeaderCell("Duration", primaryDark),
                              _buildTableHeaderCell(
                                  "Start Reason", primaryDark),
                              _buildTableHeaderCell("End Reason", primaryDark),
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
                                _buildTableCell(rec.dateStr),
                                _buildTableCell(rec.programTitle, isBold: true),
                                _buildSequenceBadgeCell(rec),
                                _buildTableCell(rec.headUnit, isSemibold: true),
                                _buildTableCell(rec.pump, isSemibold: true),
                                _buildTableCell(rec.startTime),
                                _buildTableCell(rec.endTime),
                                _buildTableCell(rec.duration),
                                _buildTableCell(rec.startReason),
                                _buildTableCell(rec.endReason),
                              ],
                            ),
                        ],
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
  final int slotIndex;
  final double slotHeight;
  final Function(ScheduleItem) onItemSelected;

  const ScheduleBarWidget({
    super.key,
    required this.item,
    required this.program,
    required this.isSelected,
    required this.totalWidth,
    required this.slotIndex,
    required this.slotHeight,
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
                      Expanded(
                        child: Text(
                          widget.item.programTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
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
                      const SizedBox(
                        width: 80,
                        child: Text(
                          "Start Reason",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      const Text(" : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11)),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(
                        width: 80,
                        child: Text(
                          "End Reason",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Color(0xFFC62828),
                          ),
                        ),
                      ),
                      const Text(" : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11)),
                      Expanded(
                        child: Text(
                          widget.item.endReason,
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(
                        width: 80,
                        child: Text(
                          "Sequence",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Color(0xFF616161),
                          ),
                        ),
                      ),
                      const Text(" : ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 11)),
                      Expanded(
                        child: Text(
                          widget.item.sequenceTitle,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatShortTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    List<String> parts = timeStr.trim().split(':');
    if (parts.length >= 2) {
      return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
    }
    return timeStr;
  }

  @override
  Widget build(BuildContext context) {
    // Compute bar geometry
    double leftPosition = (widget.item.startHour / 24.0) * widget.totalWidth;
    double durationHours = widget.item.endHour - widget.item.startHour;
    double calcWidth = (durationHours / 24.0) * widget.totalWidth;
    double barWidth = calcWidth < 18 ? 18 : calcWidth;

    // Clamp bar so the BAR itself never overflows the timeline width
    double barLeft = leftPosition.clamp(0.0, widget.totalWidth - barWidth);

    // Label floats 82px wide; placed so it's always visible
    const double labelW = 82.0;
    double labelLeft;
    TextAlign labelTextAlign;

    if (barLeft + barWidth > widget.totalWidth - labelW) {
      // Near right edge: label floats LEFT of/over the bar
      labelLeft =
          (barLeft + barWidth - labelW).clamp(0.0, widget.totalWidth - labelW);
      labelTextAlign = TextAlign.right;
    } else if (barLeft < labelW / 2) {
      // Near left edge: label starts at bar left
      labelLeft = barLeft;
      labelTextAlign = TextAlign.left;
    } else {
      // Center: label centered above bar
      labelLeft = (barLeft + barWidth / 2 - labelW / 2)
          .clamp(0.0, widget.totalWidth - labelW);
      labelTextAlign = TextAlign.center;
    }

    // Shorten separator to save space: "HH:mm-HH:mm"
    String displayTimeStr =
        "${_formatShortTime(widget.item.startTime)}-${_formatShortTime(widget.item.endTime)}";

    // Vertical slot positioning: each slot gets slotHeight pixels
    double slotTop = widget.slotIndex * widget.slotHeight;
    double barH = (widget.slotHeight - 18).clamp(12.0, 18.0);
    double labelTop = slotTop + 1;
    double barTopInSlot = slotTop + 16;

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Stack(
        children: [
          // Time label badge — absolutely positioned relative to timeline container
          Positioned(
            left: labelLeft,
            top: labelTop,
            width: labelW,
            child: CompositedTransformTarget(
              link: _layerLink,
              child: MouseRegion(
                onEnter: (_) => _showPopup(),
                onExit: (_) => _hidePopup(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: widget.program.barColor.withAlpha(128),
                      width: 0.8,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    displayTimeStr,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: widget.program.barColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: labelTextAlign,
                  ),
                ),
              ),
            ),
          ),
          // Colored bar — tappable
          Positioned(
            left: barLeft,
            top: barTopInSlot,
            width: barWidth,
            height: barH,
            child: GestureDetector(
              onTap: () => widget.onItemSelected(widget.item),
              child: Container(
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
            ),
          ),
        ],
      ),
    );
  }
}
