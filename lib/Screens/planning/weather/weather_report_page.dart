import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:oro_drip_irrigation/Screens/planning/weather/weather_report_model.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_report_sensor_model.dart' hide parseSensorHourData;
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_report_sensor_modelGsm.dart';

import '../../../repository/repository.dart';
import '../../../services/http_service.dart';

class SensorHourlyReportPage extends StatefulWidget {
  final String deviceSrNo;
  final String sensorSrNo;
  final String sensorName;
  final String userId;
  final String unit;
  final String controllerId;

  const SensorHourlyReportPage({
    super.key,
    required this.deviceSrNo,
    required this.sensorSrNo,
    required this.sensorName,
    required this.userId,
    required this.controllerId,
    required this.unit,
  });

  @override
  State<SensorHourlyReportPage> createState() => _SensorHourlyReportPageState();
}

class _SensorHourlyReportPageState extends State<SensorHourlyReportPage> {
  List<SensorHourReportGsm> report = [];
  bool isLoading = false;
  bool isGraphView = false;

  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchHourlyData();
  }

  double _parseHour(String timeString) {
    return double.tryParse(timeString.split(':').first) ?? 0.0;
  }

  Future<void> fetchHourlyData() async {
    setState(() {
      isLoading = true;
      report = [];
    });
    try {
      final repository = Repository(HttpService());
      final response = await repository.getweatherReport({
        "userId": widget.userId,
        "controllerId": widget.controllerId,
        "fromDate": selectedDate,
        "toDate": selectedDate,
      });
      final model = weatherReportModelFromJson(response.body);

      if (model.data.isEmpty) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        return;
      }

      final datum = model.data.first;

      final Map<String, String> hours = {
        "01:00": datum.the0100,
        "02:00": datum.the0200,
        "03:00": datum.the0300,
        "04:00": datum.the0400,
        "05:00": datum.the0500,
        "06:00": datum.the0600,
        "07:00": datum.the0700,
        "08:00": datum.the0800,
        "09:00": datum.the0900,
        "10:00": datum.the1000,
        "11:00": datum.the1100,
        "12:00": datum.the1200,
        "13:00": datum.the1300,
        "14:00": datum.the1400,
        "15:00": datum.the1500,
        "16:00": datum.the1600,
        "17:00": datum.the1700,
        "18:00": datum.the1800,
        "19:00": datum.the1900,
        "20:00": datum.the2000,
        "21:00": datum.the2100,
        "22:00": datum.the2200,
        "23:00": datum.the2300,
        "00:00": datum.the0000,
      };
      final List<SensorHourReportGsm> temp = [];

      hours.forEach((hour, raw) {
        final data = parseSensorHourData(
          hour: hour,
          raw: raw,
          deviceSrNo: widget.deviceSrNo,
          targetSensor: widget.sensorSrNo,
        );
        if (data != null) temp.add(data);
      });

      if (mounted) {
        setState(() {
          report = temp;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      debugPrint('Hourly Report Error: $e');
    }
  }

  // ------------------ DATE PICKER ------------------

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(selectedDate),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
      fetchHourlyData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.sensorName} Report'),
            Text(
              selectedDate,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isGraphView ? Icons.table_chart : Icons.show_chart),
            onPressed: () {
              setState(() {
                isGraphView = !isGraphView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : report.isEmpty
              ? const Center(child: Text('No data available'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1000), // Better for Web
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isGraphView) _buildHeaderSummary(),
                          if (!isGraphView) const SizedBox(height: 5),
                          Expanded(
                            child: isGraphView
                                ? _buildGraphView()
                                : _buildDataTable(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeaderSummary() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.sensorName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(selectedDate, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildGraphView() {
    List<SensorHourReportGsm> sortedValidReports = report
        .where((r) => double.tryParse(r.value) != null)
        .toList();

    sortedValidReports.sort(
        (a, b) => _parseHour(a.hour).compareTo(_parseHour(b.hour)));

    if (sortedValidReports.isEmpty) {
      return const Center(child: Text('No sensor data available for this date'));
    }

    double minVal = sortedValidReports
        .map((r) => double.parse(r.value))
        .reduce((a, b) => a < b ? a : b);
    double maxVal = sortedValidReports
        .map((r) => double.parse(r.value))
        .reduce((a, b) => a > b ? a : b);

    var latest = sortedValidReports.last;
    double currentVal = double.parse(latest.value);
    String currentValTime = latest.hour;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.sensorName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(selectedDate,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("24 Hour Trend",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(widget.unit,
                          style: const TextStyle(
                              color: Colors.teal, fontWeight: FontWeight.bold)),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildSummaryCard("Current",
                    "${currentVal.toStringAsFixed(2)} ${widget.unit}",
                    subText: "Last: $currentValTime"),
                _buildSummaryCard(
                    "MIN", "${minVal.toStringAsFixed(2)} ${widget.unit}"),
                _buildSummaryCard(
                    "MAX", "${maxVal.toStringAsFixed(2)} ${widget.unit}"),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildLineChart(minVal, maxVal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, {String? subText}) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (subText != null) ...[
            const SizedBox(height: 4),
            Text(subText,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]
        ],
      ),
    );
  }

  Widget _buildLineChart(double minVal, double maxVal) {
    List<FlSpot> spots = [];
    for (int i = 0; i <= 23; i++) {
      String hourStr = "${i.toString().padLeft(2, '0')}:00";
      var match = report.where((r) => r.hour == hourStr);
      if (match.isNotEmpty) {
        var r = match.first;
        var val = double.tryParse(r.value);
        if (val != null) {
          spots.add(FlSpot(i.toDouble(), val));
        } else {
          spots.add(FlSpot.nullSpot);
        }
      } else {
        spots.add(FlSpot.nullSpot);
      }
    }

    double range = maxVal - minVal;
    if (range == 0) range = 10; // Avoid zero range
    double minYLimit = minVal - (range * 0.2);
    double maxYLimit = maxVal + (range * 0.2);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 23,
        minY: minYLimit,
        maxY: maxYLimit,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval:
              ((maxYLimit - minYLimit) / 5) > 0 ? ((maxYLimit - minYLimit) / 5) : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text('Hour',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            axisNameSize: 24,
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value > 23) return const SizedBox.shrink();
                if (value.toInt() % 3 == 0 || value.toInt() == 23) {
                  if (value == value.toInt()) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "${value.toInt().toString().padLeft(2, '0')}:00",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            left: BorderSide(color: Colors.grey.shade300, width: 1),
            right: BorderSide.none,
            top: BorderSide.none,
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.teal.shade800,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                String hourStr =
                    "${touchedSpot.x.toInt().toString().padLeft(2, '0')}:00";
                return LineTooltipItem(
                  "$hourStr\n${touchedSpot.y} ${widget.unit}",
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.teal,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                String hourStr =
                    "${spot.x.toInt().toString().padLeft(2, '0')}:00";
                var match = report.where((r) => r.hour == hourStr);
                bool isError = false;
                if (match.isNotEmpty) {
                  var code = match.first.errorCode;
                  isError = (code != '255' && code != 'NA');
                }
                return FlDotCirclePainter(
                  radius: 4,
                  color: isError ? Colors.red : Colors.teal,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.teal.withOpacity(0.3),
                  Colors.teal.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        headingRowHeight: 50,
        headingRowColor: MaterialStateProperty.all(Colors.teal),
        border: const TableBorder(
          horizontalInside: BorderSide(color: Colors.teal, width: 1),
        ),
        columns: const [
          DataColumn2(
            label: Text('Hour', style: TextStyle(fontWeight: FontWeight.bold)),
            fixedWidth: 80,
          ),
          DataColumn2(
              label: Text('Value',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn2(
              label: Text('Min',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn2(
              label: Text('Max',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn2(
              label: Text('Avg',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn2(
            label: Text('Status',
                style: TextStyle(fontWeight: FontWeight.bold)),
            fixedWidth: 100,
            numeric: true,
          ),
        ],
        rows: report.map((r) {
          Color rowColor;

          if (r.errorCode == '255') {
            rowColor = Colors.green.shade50;
          } else if (r.errorCode == 'NA') {
            rowColor = Colors.grey.shade300;
          } else {
            rowColor = Colors.red.shade50;
          }
          return DataRow(
              color: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  return rowColor;
                },
              ),
              cells: [
                DataCell(Text(r.hour,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Text(
                    '${r.value} ${r.value != "NA" ? widget.unit : ''}')),
                DataCell(Text(
                    '${r.minValue} ${r.minValue != "NA" ? widget.unit : ''}')),
                DataCell(Text(
                    '${r.maxValue} ${r.maxValue != "NA" ? widget.unit : ''}')),
                DataCell(Text(
                    '${r.averageValue} ${r.averageValue != "NA" ? widget.unit : ''}')),
                DataCell(
                  _buildStatusBadge(r.errorCode),
                ),
              ]);
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: code == '255'
              ? Colors.green.shade50
              : code == 'NA'
                  ? Colors.grey.shade50
                  : Colors.red.shade50,
        ),
      ),
      child: Text(
        code == '255'
            ? 'Normal'
            : code == 'NA'
                ? '$code'
                : 'ERR-$code',
        style: TextStyle(
          color: code == '255'
              ? Colors.green
              : code == 'NA'
                  ? Colors.grey
                  : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}