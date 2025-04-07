import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Models/admin&dealer/language_list.dart';
import '../../Models/customer/notification_list_model.dart';
import '../../repository/repository.dart';
import '../../utils/snack_bar.dart';
import 'package:timezone/standalone.dart' as tz;

class ControllerSettingsViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";

  List<Map<String, dynamic>> filteredSettingList = [];

  final List<Map<String, dynamic>> allSettings = [
    {'title': 'General', 'icon': Icons.settings_outlined},
    {'title': 'Name', 'icon': Icons.text_fields},
    {'title': 'Preference', 'icon': Icons.settings_applications_outlined},
    {'title': 'Constant', 'icon': Icons.private_connectivity_sharp},
    {'title': 'Condition Library', 'icon': Icons.library_books_outlined},
    {'title': 'Notification', 'icon': Icons.notifications_none},
    {'title': 'Fertilizer Set', 'icon': Icons.format_textdirection_r_to_l},
    {'title': 'Valve Group', 'icon': Icons.group_work_outlined},
    {'title': 'System Definitions', 'icon': Icons.settings_system_daydream_outlined},
    {'title': 'Global Limit', 'icon': Icons.production_quantity_limits},
    {'title': 'Virtual Water Meter', 'icon': Icons.gas_meter_outlined},
    {'title': 'Program Queue', 'icon': Icons.query_stats},
    {'title': 'Frost Protection', 'icon': Icons.fort_outlined},
    {'title': 'Calibration', 'icon': Icons.compass_calibration_outlined},
    {'title': 'Dealer Definition', 'icon': Icons.person_outline},
    {'title': 'View Settings', 'icon': Icons.remove_red_eye_outlined},
  ];

  ControllerSettingsViewModel(this.repository);

  Future<void> getSettingsMenu(int customerId, int controllerId) async {
    try {
      Map<String, Object> body = {
        "userId": customerId,
        "controllerId": controllerId
      };
      var response = await repository.getPlanningHiddenMenu(body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData["code"] == 200 && jsonData["data"] is List) {
          final List<dynamic> dataList = jsonData["data"];

          final Set<String> availableTitles = dataList
              .map((e) => e["parameter"]?.toString() ?? '')
              .toSet();

          filteredSettingList = allSettings.where((setting) {
            if (setting['title'] == 'General') return true;
            return availableTitles.contains(setting['title']);
          }).toList();
        }
      }
    } catch (error) {
      debugPrint('Error fetching settings menu: $error');
    } finally {
      setLoading(false);
    }
  }


  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

}