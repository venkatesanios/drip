import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../models/customer/site_model.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../view_models/customer/node_hourly_logs_vm.dart';

class NodeHourlyLogs extends StatelessWidget {
  const NodeHourlyLogs( {super.key, required this.userId, required this.controllerId, required this.nodes});
  final int userId, controllerId;
  final List<NodeListModel> nodes;

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    return ChangeNotifierProvider(
      create: (_) => NodeHourlyLogsVm(Repository(HttpService()), userId, controllerId, nodes)..getNodeLogs(selectedDate),
      child: Consumer<NodeHourlyLogsVm>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Hourly power logs'),
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
            body: viewModel.nodeDataMap.isNotEmpty?SingleChildScrollView(
              child: Column(
                children: viewModel.nodeDataMap.entries.map((entry) {
                  String nodeId = entry.key;
                  List<ChartDataLog> chartData = entry.value;
                  return SfCartesianChart(
                    primaryXAxis: const CategoryAxis(),
                    title: ChartTitle(text: 'Device Name: ${chartData.elementAt(0).deviceName}  -  ID: $nodeId'),
                    legend: const Legend(isVisible: true),
                    //tooltipBehavior: TooltipBehavior(enable: true),
                    primaryYAxis: const NumericAxis(
                      title: AxisTitle(text: 'Percentage'),
                    ),
                    series: <LineSeries<ChartDataLog, String>>[
                      LineSeries<ChartDataLog, String>(
                        dataSource: chartData,
                        xValueMapper: (ChartDataLog data, _) => data.hour,
                        yValueMapper: (ChartDataLog data, _) => data.batteryVoltage,
                        name: 'Battery Voltage',
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      ),
                      LineSeries<ChartDataLog, String>(
                        dataSource: chartData,
                        xValueMapper: (ChartDataLog data, _) => data.hour,
                        yValueMapper: (ChartDataLog data, _) => data.solarVoltage,
                        name: 'Solar Voltage',
                        dataLabelSettings: const DataLabelSettings(isVisible: true),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ):
            const Center(child: Text('Node hourly log not found')),
          );
        },
      ),
    );
  }
}

class ChartDataLog {
  final String deviceName;
  final String hour;
  final double batteryVoltage;
  final double solarVoltage;

  ChartDataLog(this.deviceName, this.hour, this.batteryVoltage, this.solarVoltage);
}
