import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import 'package:flutter/material.dart';

class CurrentProgramViewModel extends ChangeNotifier {
  late MqttPayloadProvider payloadProvider;
  List<String> currentSchedule = [];
  Timer? _timer;
  double currentLineSno;

  CurrentProgramViewModel(BuildContext context, this.currentLineSno) {
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
  }

  void updateSchedule(List<String> newSchedule) {
    currentSchedule = List.from(newSchedule);
    payloadProvider.currentSchedule.clear();
    notifyListeners();
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      updateDurationQtyLeft();
    });
  }

  void updateDurationQtyLeft() {
    bool allOnDelayLeftZero = true;
    bool didUpdate = false;

    try {
      for (int i = 0; i < currentSchedule.length; i++) {
        List<String> values = currentSchedule[i].split(',');

        if (values.length <= 17 || values[17] != '1') continue;

        if (values[4].contains(':')) {
          values[4] = _updateTime(values[4]);
        } else {
          values[4] = _updateFlow(values[4], values[16]);
        }

        currentSchedule[i] = values.join(',');
        allOnDelayLeftZero = false;
        didUpdate = true;
      }
    } catch (e) {
      print("Error in updateDurationQtyLeft: $e");
    }

    if (didUpdate) notifyListeners();
    if (allOnDelayLeftZero) _timer?.cancel();
  }

  String _updateTime(String timeStr) {
    try {
      List<String> parts = timeStr.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      int seconds = int.parse(parts[2]);

      if (seconds > 0) {
        seconds--;
      } else if (minutes > 0) {
        minutes--;
        seconds = 59;
      } else if (hours > 0) {
        hours--;
        minutes = 59;
        seconds = 59;
      }

      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00:00';
    }
  }

  String _updateFlow(String flowStr, String rateStr) {
    try {
      double remainFlow = double.tryParse(flowStr) ?? 0.0;
      double flowRate = double.tryParse(rateStr) ?? 0.0;

      remainFlow -= flowRate;
      if (remainFlow < 0) remainFlow = 0;

      return remainFlow.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}