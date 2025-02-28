import 'package:flutter/material.dart';
import '../../Models/customer/site_model.dart';

class IrrigationLineViewModel extends ChangeNotifier {
  final List<IrrigationLineData>? lineData;
  final double screenWidth;
  final double pumpStationWith;

  int crossAxisCount = 1;
  double gridHeight = 0;
  List<Widget> valveWidgets = [];

  IrrigationLineViewModel(BuildContext context, this.lineData, this.screenWidth, this.pumpStationWith) {
    _initialize(context);
  }

  void _initialize(context) {
    if (lineData == null || lineData!.isEmpty) return;
    updateGridAlign();

  }

  void updateGridAlign(){

    valveWidgets = [
      for (var line in lineData!) ...[
        ...line.valves.map((vl) => ValveWidget(vl: vl, status: vl.status,
          userId: 0,
          controllerId: 0,
        )),
      ]
    ];

    crossAxisCount = (screenWidth - pumpStationWith / 105).floor().clamp(1, double.infinity).toInt();
    int rowCount = (valveWidgets.length / crossAxisCount).ceil();
    double itemHeight = 72;
    gridHeight = rowCount * (itemHeight + 5);

    notifyListeners();
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
          width: 150,
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
                    SizedBox(width: 4),
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