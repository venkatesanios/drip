import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';

class CurrentProgramViewModel extends ChangeNotifier {
  late MqttPayloadProvider payloadProvider;
  List<String> currentSchedule = [];
  Timer? _timer;

  CurrentProgramViewModel(BuildContext context){
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
  }

  void updateSchedule(List<String> newSchedule) {
    currentSchedule = List.from(newSchedule);
    payloadProvider.currentSchedule.clear();
    notifyListeners();
    startTimer();
  }

  void startTimer(){
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      updateDurationQtyLeft();
    });
  }

  void updateDurationQtyLeft() {
    bool allOnDelayLeftZero = true;
    try {
      if(currentSchedule.isNotEmpty){
        for (int i = 0; i < currentSchedule.length; i++) {
          List<String> values = currentSchedule[i].split(",");
          if(values.length>1){
            if(values[17]=='1'){
              if (values[4].contains(':')){
                List<String> parts = values[4].split(':');
                int hours = int.parse(parts[0]);
                int minutes = int.parse(parts[1]);
                int seconds = int.parse(parts[2]);

                if (seconds > 0) {
                  seconds--;
                } else {
                  if (minutes > 0) {
                    minutes--;
                    seconds = 59;
                  } else {
                    if (hours > 0) {
                      hours--;
                      minutes = 59;
                      seconds = 59;
                    }
                  }
                }

                if (values[4] != '00:00:00') {
                  values[4] = '${hours.toString().padLeft(2, '0')}:'
                      '${minutes.toString().padLeft(2, '0')}:'
                      '${seconds.toString().padLeft(2, '0')}';
                  currentSchedule[i] = values.join(",");
                  notifyListeners();
                }
              }
              else {
                double remainFlow = double.parse(values[4]);
                if (remainFlow > 0) {
                  double flowRate = double.parse(values[16]);
                  remainFlow -= flowRate;

                  if (remainFlow < 0) {
                    remainFlow = 0;
                  }

                  String formattedFlow = remainFlow.toStringAsFixed(2);

                  values[4] = formattedFlow;
                  currentSchedule[i] = values.join(",");
                  notifyListeners();
                } else {
                  values[4] = '0.00';
                  currentSchedule[i] = values.join(",");
                  notifyListeners();
                }
              }
              allOnDelayLeftZero = false;
            }
            else{
              //pump on delay or filter running
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }

    if (allOnDelayLeftZero) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}