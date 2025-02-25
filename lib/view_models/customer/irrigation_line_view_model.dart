import 'package:flutter/material.dart';
import '../../Models/customer/site_model.dart';

class IrrigationLineViewModel extends ChangeNotifier {
  final List<IrrigationLineData>? lineData;
  final double screenWidth;

  int crossAxisCount = 1;
  double gridHeight = 0;
  List<Valve> valves = [];

  IrrigationLineViewModel(BuildContext context, this.lineData, this.screenWidth) {
    _initialize(context);
  }

  void _initialize(context) {
    if (lineData == null || lineData!.isEmpty) return;
    updateGridAlign();

  }

  void updateGridAlign(){
    valves = lineData![0].valves ?? [];

    crossAxisCount = (screenWidth / 95).floor().clamp(1, double.infinity).toInt();
    int rowCount = (valves.length / crossAxisCount).ceil();

    double itemHeight = 75;
    gridHeight = rowCount * (itemHeight + 5);

    notifyListeners();
  }


}