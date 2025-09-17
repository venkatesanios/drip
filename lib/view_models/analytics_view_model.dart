import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../models/sales_data_model.dart';
import '../repository/repository.dart';
import '../utils/enums.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final Repository repository;
  SalesDataModel mySalesData = SalesDataModel(graph: {}, total: []);
  int totalSales = 0, userId;
  bool isLoadingSalesData = false;
  MySegment segmentView = MySegment.all;

  AnalyticsViewModel(this.repository, this.userId);

  Future<void> getMySalesData(MySegment segment, int userType) async {
    segmentView = segment;
    setLoadingSales(true);

    final body = {"userId": userId, "userType": userType,
      "type": segment == MySegment.all ? 'All' : 'Year', "year": 2025};

    try {
      final response = await repository.fetchAllMySalesReports(body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["code"] == 200 && data.containsKey("data")) {
          mySalesData = SalesDataModel.fromJson(data);
          totalSales = mySalesData.total?.fold(0, (sum, e) => sum! + e.totalProduct) ?? 0;
        } else {
          debugPrint("API Error: ${data['message'] ?? 'Unknown error'}");
        }
      } else {
        debugPrint("HTTP Error: ${response.statusCode}");
      }
    } catch (e, st) {
      debugPrint('Error: $e\n$st');
    } finally {
      setLoadingSales(false);
    }
  }

  void updateSegmentView(MySegment newSegment) {
    segmentView = newSegment;
    notifyListeners();
  }

  void setLoadingSales(bool loadingState) {
    isLoadingSalesData = loadingState;
    notifyListeners();
  }
}