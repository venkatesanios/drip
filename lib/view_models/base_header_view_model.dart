import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import '../repository/repository.dart';
import '../utils/enums.dart';
import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';

class BaseHeaderViewModel extends ChangeNotifier {
  int selectedIndex = 0;
  int hoveredIndex = -1;
  final List<String> menuTitles;

  MainMenuSegment _segmentView = MainMenuSegment.dashboard;
  MainMenuSegment get mainMenuSegmentView => _segmentView;


  final Repository repository;
  late Map<String, dynamic> jsonDataMap;
  TextEditingController txtFldSearch = TextEditingController();
  Timer? debounce;

  void updateMainMenuSegmentView(MainMenuSegment newView) {
    _segmentView = newView;
    selectedIndex = newView.index;
    notifyListeners();
  }

  BaseHeaderViewModel({required this.repository, required this.menuTitles}) {
    initState();
  }

  Future<void> fetchCategoryModelList(int userId, UserRole userRole) async {
    try {
      Map<String, dynamic> body = {
        "userId": userId,
        "userType": userRole.name == 'admin' ? 1 : 2,
      };

      var response = await repository.fetchAllCategoriesAndModels(body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody["code"] == 200) {
          jsonDataMap = responseBody;
        } else {
          debugPrint("API Error: ${responseBody['message']}");
        }
      }
    } catch (error) {
      debugPrint("Error: $error");
    } finally {
      notifyListeners();
    }
  }

  void initState() {
    selectedIndex = 0;
    notifyListeners();
  }

  void onDestinationSelectingChange(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void onHoverChange(int index) {
    hoveredIndex = index;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await PreferenceHelper.clearAll();
    const route = kIsWeb ? Routes.login : Routes.loginOtp;
    Navigator.pushNamedAndRemoveUntil(context, route, (route) => false,);
    // Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }

  void clearSearch() {
    txtFldSearch.clear();
    notifyListeners();
  }
}