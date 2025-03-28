/*
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:oro_drip_irrigation/modules/Preferences/view/preference_main_screen.dart';
import 'package:oro_drip_irrigation/modules/PumpController/view/pump_dashboard_screen.dart';
import '../../Logs/view/pump_logs_home.dart';

class PumpControllerHome extends StatefulWidget {
  final String deviceId;
  final dynamic liveData;
  final String masterName;
  final int userId;
  final int customerId;
  final int controllerId;

  const PumpControllerHome({
    super.key,
    required this.deviceId,
    this.liveData,
    required this.masterName,
    required this.userId,
    required this.customerId,
    required this.controllerId,
  });

  @override
  State<PumpControllerHome> createState() => _PumpControllerHomeState();
}

class _PumpControllerHomeState extends State<PumpControllerHome> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      PumpDashboardScreen(
        key: ValueKey(_controller.index == 0 ? UniqueKey() : null), // Forces rebuild
        deviceId: widget.deviceId,
        liveData: widget.liveData,
        masterName: widget.masterName,
        userId: widget.userId,
        customerId: widget.customerId,
        controllerId: widget.controllerId,
      ),
      PreferenceMainScreen(
        key: ValueKey(_controller.index == 1 ? UniqueKey() : null), // Forces rebuild
        userId: widget.userId,
        controllerId: widget.controllerId,
        deviceId: widget.deviceId,
        customerId: widget.customerId,
        menuId: 0,
      ),
      PumpLogsHome(
        key: ValueKey(_controller.index == 2 ? UniqueKey() : null), // Forces rebuild
        userId: widget.userId,
        controllerId: widget.controllerId,
      ),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.dashboard),
        title: "Dashboard",
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings),
        title: "Preference",
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.assessment),
        title: "Logs",
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  Future<bool> _onWillPop() async {
    if (_controller.index > 0) {
      setState(() {
        _controller.index -= 1;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: PersistentTabView(
        context,
        controller: _controller,
        padding: const EdgeInsets.symmetric(vertical: 5),
        margin: const EdgeInsets.symmetric(vertical: 0),
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineToSafeArea: true,
        backgroundColor: Theme.of(context).primaryColorDark,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: false,
        hideNavigationBarWhenKeyboardAppears: true,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.white,
        ),
        popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
        navBarStyle: NavBarStyle.style1,
      ),
    );
  }
}*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/Preferences/view/preference_main_screen.dart';
import 'package:oro_drip_irrigation/modules/PumpController/view/pump_dashboard_screen.dart';

import '../../Logs/view/pump_logs_home.dart';

class PumpControllerHome extends StatefulWidget {
  final String deviceId;
  final dynamic liveData;
  final String masterName;
  final int userId;
  final int customerId;
  final int controllerId;

  const PumpControllerHome({
    super.key,
    required this.deviceId,
    this.liveData,
    required this.masterName,
    required this.userId,
    required this.customerId,
    required this.controllerId,
  });

  @override
  State<PumpControllerHome> createState() => _PumpControllerHomeState();
}

class _PumpControllerHomeState extends State<PumpControllerHome> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          _pageController.jumpToPage(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            PumpDashboardScreen(
              deviceId: widget.deviceId,
              liveData: widget.liveData,
              masterName: widget.masterName,
              userId: widget.userId,
              customerId: widget.customerId,
              controllerId: widget.controllerId,
            ),
            PreferenceMainScreen(
              userId: widget.userId,
              controllerId: widget.controllerId,
              deviceId: widget.deviceId,
              customerId: widget.customerId,
              menuId: 0,
            ),
            PumpLogsHome(userId: widget.userId, controllerId: widget.controllerId),
          ],
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        bottomNavigationBar: !kIsWeb ? BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Preference'),
            BottomNavigationBarItem(icon: Icon(Icons.assessment_outlined), activeIcon: Icon(Icons.assessment), label: 'Logs'),
          ],
          currentIndex: _selectedIndex,
          backgroundColor: Theme.of(context).primaryColorDark,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 8.0,
          onTap: _onItemTapped,
        ) : null,
      ),
    );
  }
}
