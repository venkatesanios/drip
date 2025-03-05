import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Models/customer/site_model.dart';
import '../../../utils/constants.dart';
import '../../../view_models/customer/irrigation_line_view_model.dart';

class IrrigationLine extends StatelessWidget {
  final List<IrrigationLineData>? lineData;
  final double pumpStationWith;

  const IrrigationLine({super.key, required this.lineData, required this.pumpStationWith});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - pumpStationWith;

    return ChangeNotifierProvider(
      create: (_) => IrrigationLineViewModel(context, lineData, screenWidth),
      child: Consumer<IrrigationLineViewModel>(
        builder: (context, viewModel, _) {

          final List<Widget> valveWidgets;

          valveWidgets = [
            for (var line in lineData!) ...[
              ...line.valves.map((vl) => ValveWidget(vl: vl, status: vl.status,
                userId: 0,
                controllerId: 0,
              )),
            ]
          ];

          int crossAxisCount = (screenWidth / 90).floor().clamp(1, double.infinity).toInt();
          int rowCount = (valveWidgets.length / crossAxisCount).ceil();
          double itemHeight = 80;
          double gridHeight = rowCount * (itemHeight + 5);

          return SizedBox(
            width: screenWidth,
            height: gridHeight+10,
            child: Column(
              children: [
                const Divider(height: 0, color: Colors.black12,),
                const Divider(height: 5, color: Colors.black12,),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.20,
                      mainAxisSpacing: 0.0,
                      crossAxisSpacing: 0.0,
                    ),
                    itemCount: valveWidgets.length,
                    itemBuilder: (context, index) {
                      return valveWidgets[index];
                    },
                  ),
                ),
              ],
            ),
          );

        },
      ),
    );
  }

  Widget buildValveWidget(String vName, int vStatus, bool isLastInRow, bool isLastItem) {
    return Stack(
      children: [
        SizedBox(
          width: 100,
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 10,
                child: VerticalDivider(thickness: 1, color: Colors.grey.shade400),
              ),
              SizedBox(
                width: 35,
                height: 35,
                child: AppConstants.getAsset('valve', vStatus, ''),
              ),
              const SizedBox(height: 4),
              Text(
                vName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ValveWidget extends StatelessWidget {
  final Valve vl;
  final int status, userId, controllerId;
  //final List<SensorModel> moistureSensor;
  //final Map<String, List<SensorHourlyData>> sensorData;
  const ValveWidget({super.key, required this.vl, required this.status, required this.userId, required this.controllerId});

  @override
  Widget build(BuildContext context) {
    bool hasMoisture = false;
    return Stack(
      children: [
        Container(
          width: 100,
          //color: Colors.grey,
          margin: const EdgeInsets.only(left: 2, right: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: 150,
                height: 15,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VerticalDivider(width: 0),
                    SizedBox(width: 3),
                    VerticalDivider(width: 0),
                  ],
                ),
              ),
              Image.asset(
                width: 35,
                height: 35,
                status == 0
                    ? 'assets/png_images/valve_gray.png'
                    : status == 1
                    ? 'assets/png_images/valve_green.png'
                    : status == 2
                    ? 'assets/png_images/valve_orange.png'
                    : 'assets/png_images/valve_red.png',
              ),
              const SizedBox(height: 4),
              Text(
                vl.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getMoistureColor(List<Map<String, dynamic>> sensors) {
    if (sensors.isEmpty) return Colors.grey;

    final values = sensors
        .map((ms) => double.tryParse(ms['value'] ?? '0') ?? 0.0)
        .toList();

    final averageValue = values.reduce((a, b) => a + b) / values.length;

    if (averageValue < 20) {
      return Colors.green.shade200;
    } else if (averageValue <= 60) {
      return Colors.orange.shade200;
    } else {
      return Colors.red.shade200;
    }
  }
}
