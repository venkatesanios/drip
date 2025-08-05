import 'package:flutter/cupertino.dart';
import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';

class BaseHeaderViewModel extends ChangeNotifier {
  int selectedIndex = 0;
  int hoveredIndex = -1;
  final List<String> menuTitles;

  BaseHeaderViewModel({required this.menuTitles}) {
    initState();
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
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }
}