import 'package:flutter/cupertino.dart';

import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';

class AdminHeaderViewModel extends ChangeNotifier {

  int selectedIndex = 0;
  int hoveredIndex = -1;

  final List<String> menuTitles = ['Dashboard', 'Products', 'Stock'];
  final List<Widget?> _pages = List.filled(3, null);

  AdminHeaderViewModel(){
    initState();
  }

  void initState() {
    selectedIndex = 0;
    notifyListeners();
  }

  void onDestinationSelectingChange(int index){
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> logout(context) async {
    await PreferenceHelper.clearAll();
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false,);
  }

}