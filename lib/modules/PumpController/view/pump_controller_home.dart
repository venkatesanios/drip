import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/Preferences/view/preference_main_screen.dart';
import 'package:oro_drip_irrigation/modules/PumpController/view/pump_dashboard_screen.dart';

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
  late final List<GlobalKey<NavigatorState>> _navigatorKeys;

  @override
  void initState() {
    super.initState();
    _navigatorKeys = List.generate(4, (_) => GlobalKey<NavigatorState>());
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  bool get _isIOS => Platform.isIOS;

  Route _generateRoute(int index) {
    final pages = [
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
          menuId: 0
      ),
      const Center(child: Text('View')),
      const Center(child: Text('Logs')),
    ];
    return _isIOS
        ? CupertinoPageRoute(builder: (_) => pages[index])
        : MaterialPageRoute(builder: (_) => pages[index]);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: List.generate(
            4,
                (i) => Navigator(
              key: _navigatorKeys[i],
              onGenerateRoute: (_) => _generateRoute(i),
            ),
          ),
        ),
        bottomNavigationBar: _isIOS
            ? CupertinoTabBar(
          height: 80,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Preference'),
            BottomNavigationBarItem(icon: Icon(Icons.schedule_outlined), activeIcon: Icon(Icons.schedule), label: 'View'),
            BottomNavigationBarItem(icon: Icon(Icons.assessment_outlined), activeIcon: Icon(Icons.assessment), label: 'Logs'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        )
            : BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Preference'),
            BottomNavigationBarItem(icon: Icon(Icons.schedule_outlined), activeIcon: Icon(Icons.schedule), label: 'View'),
            BottomNavigationBarItem(icon: Icon(Icons.assessment_outlined), activeIcon: Icon(Icons.assessment), label: 'Logs'),
          ],
          currentIndex: _selectedIndex,
          backgroundColor: Theme.of(context).primaryColorDark,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 8.0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}