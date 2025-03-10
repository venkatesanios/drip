import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';

class CurrentProgramViewModel extends ChangeNotifier {
  List<String> currentSchedule = [];

  CurrentProgramViewModel(BuildContext context);


  void updateSchedule(List<String> newSchedule) {
    currentSchedule = List.from(newSchedule);
    notifyListeners();
  }
}