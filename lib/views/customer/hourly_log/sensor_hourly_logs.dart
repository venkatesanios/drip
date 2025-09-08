import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../models/customer/site_model.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../utils/my_function.dart';
import '../../../view_models/customer/sensor_hourly_logs_vm.dart';

class SensorHourlyLogs extends StatelessWidget {
  const SensorHourlyLogs({super.key, required this.userId, required this.controllerId, required this.configObjects});
  final int userId, controllerId;
  final List<ConfigObject> configObjects;

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    return ChangeNotifierProvider(
      create: (_) => SensorHourlyLogsVm(Repository(HttpService()), userId, controllerId, configObjects)
        ..getSensorHourlyLogs(selectedDate),
      child: Consumer<SensorHourlyLogsVm>(
        builder: (context, viewModel, _) {

          return Scaffold(
            appBar: AppBar(
              title: const Text('Hourly Sensor logs'),
              actions: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => viewModel.selectDate(context),
                  ),
                ),
              ],
            ),
            body: viewModel.sensorsBySNo.isNotEmpty?
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: viewModel.sensorsBySNo.entries.map((entry) {
                  String nodeId = entry.key;
                  List<SensorHourlyData> chartData = entry.value;
                  return SfCartesianChart(
                    primaryXAxis: const CategoryAxis(),
                    title: ChartTitle(text: 'Sensor Name: ${chartData.elementAt(0).name}'),
                    legend: const Legend(isVisible: true),
                    //tooltipBehavior: TooltipBehavior(enable: true),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(text: MyFunction().getSensorUnit(chartData.elementAt(0).objectName, context)),
                    ),
                    series: <LineSeries<SensorHourlyData, String>>[
                      LineSeries<SensorHourlyData, String>(
                        dataSource: chartData,
                        xValueMapper: (SensorHourlyData data, _) => data.hour,
                        yValueMapper: (SensorHourlyData data, _) => data.value,
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                        name: chartData.elementAt(0).objectName,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ):
            Container(),
          );
        },
      ),
    );
  }
}

