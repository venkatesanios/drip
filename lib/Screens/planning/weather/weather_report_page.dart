import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:oro_drip_irrigation/Screens/planning/weather/weather_report_model.dart';
import 'package:oro_drip_irrigation/Screens/planning/weather/weather_report_sensor_model.dart';

import '../../../repository/repository.dart';
import '../../../services/http_service.dart';

class SensorHourlyReportPage extends StatefulWidget {
  final String deviceSrNo;
  final String sensorSrNo;
  final String sensorName;
  final String userId;
  final String controllerId;

  const SensorHourlyReportPage({
    super.key,
    required this.deviceSrNo,
    required this.sensorSrNo,
    required this.sensorName,
    required this.userId,
    required this.controllerId,
  });

  @override
  State<SensorHourlyReportPage> createState() => _SensorHourlyReportPageState();
}

class _SensorHourlyReportPageState extends State<SensorHourlyReportPage> {
  List<SensorHourReport> report = [];
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
      print(response.body);
      final model = weatherReportModelFromJson(response.body);
      print(model);

      if (model.data.isEmpty) {
        print("isEmpty");

        setState(() => isLoading = false);
        return;
      }

      final datum = model.data.first;
      print("datum:$datum");
      print("datum-11 :${model.data[0].the1100}");
      print("datum:${datum.the0000.toString()}");
      print("datum:${datum.the1000.toString()}");


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
      print("hours:$hours");
      final List<SensorHourReport> temp = [];

      hours.forEach((hour, raw) {
        final data = parseSensorRecord(
          hour: hour,
          raw: raw,
          targetDevice: widget.deviceSrNo,
          targetSensor: widget.sensorSrNo,
        );
        print("data:$data");
        if (data != null) temp.add(data);
      });

      setState(() {
        print("temp:$temp");
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

  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.sensorName} Hourly Report'),
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
          : SingleChildScrollView(
         child: DataTable(
          headingRowColor: MaterialStateProperty.all(
              Colors.green.shade50),
          columns: const [
            DataColumn(label: Text('Hour')),
            DataColumn(label: Text('Value')),
            DataColumn(label: Text('Min')),
            DataColumn(label: Text('Max')),
            DataColumn(label: Text('Avg')),
            DataColumn(label: Text('Error')),
          ],
          rows: report.map((r) {
            return DataRow(cells: [
              DataCell(Text(r.hour)),
              DataCell(Text(r.value)),
              DataCell(Text(r.minValue)),
              DataCell(Text(r.maxValue)),
              DataCell(Text(r.averageValue)),
              DataCell(
                Text(
                  r.errorCode,
                  style: TextStyle(
                    color: r.errorCode == '255'
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
