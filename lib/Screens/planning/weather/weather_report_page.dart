
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:oro_drip_irrigation/Screens/planning/weather/weather_report_model.dart';
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

  String selectedDate =
  DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    fetchHourlyData();
  }


  Future<void> fetchHourlyData() async {
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
        setState(() => isLoading = false);
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

      setState(() {
        report = temp;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
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
                _buildHeaderSummary(),
                const SizedBox(height: 5),
                Expanded(
                  child: _buildDataTable(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSummary() {
    return  Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.sensorName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(selectedDate,
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDataTable() {

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Ensures table header matches card corners
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        headingRowHeight: 50,
        headingRowColor: WidgetStateProperty.all(Colors.teal),
        border: const TableBorder(
          horizontalInside: BorderSide(color: Colors.teal, width: 1),
        ),
        columns: const [
          DataColumn2(
            label: Text('Hour', style: TextStyle(fontWeight: FontWeight.bold)),
            fixedWidth: 80,
          ),
          DataColumn2(label: Text(
              'Value', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn2(label: Text(
              'Min', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn2(label: Text(
              'Max', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn2(label: Text(
              'Avg', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn2(
            label: Text(
                'Status', style: TextStyle(fontWeight: FontWeight.bold)),
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
          return DataRow( color: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              return rowColor;
            },
          ), cells: [
            DataCell(Text(
                r.hour, style: const TextStyle(fontWeight: FontWeight.w500))),
            DataCell(Text('${r.value} ${r.value != "NA" ? widget.unit : ''}')),
            DataCell(Text('${r.minValue} ${r.minValue != "NA" ? widget.unit : ''}')),
            DataCell(Text('${r.maxValue} ${r.maxValue != "NA" ? widget.unit : ''}')),
            DataCell(Text('${r.averageValue} ${r.averageValue != "NA" ? widget.unit : ''}')),
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
        color:  Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: code == '255' ? Colors.green.shade50 : code == 'NA' ?  Colors.grey.shade50 : Colors.red.shade50,),
      ),
      child: Text(
        code == '255' ? 'Normal' : code == 'NA' ?  code : 'ERR-$code',
        style:  TextStyle(
          color: code == '255' ? Colors.green : code == 'NA' ?  Colors.grey : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}