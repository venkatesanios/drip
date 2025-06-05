import 'package:flutter/cupertino.dart';

import '../utils/routes.dart';
import '../utils/shared_preferences_helper.dart';

class NavRailViewModel extends ChangeNotifier {
  late int selectedIndex;

  TextEditingController txtFldSearch = TextEditingController();

  String searchedChipName = '';
  bool filterActive = false;
  bool searched = false;
  bool showSearchButton = false;

  NavRailViewModel(){
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

  void clearSearch() {
    txtFldSearch.clear();
    searchedChipName = '';
    filterActive = false;
    searched = false;
    //filterProductInventoryList.clear();
    showSearchButton = false;
    notifyListeners();
  }

}