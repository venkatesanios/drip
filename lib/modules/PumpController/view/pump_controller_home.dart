import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/Preferences/view/preference_main_screen.dart';
import 'package:oro_drip_irrigation/modules/PumpController/view/pump_dashboard_screen.dart';
import 'package:oro_drip_irrigation/modules/PumpController/widget/custom_outline_button.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../Logs/view/power_graph_screen.dart';
import '../../Logs/view/pump_log.dart';
import '../../Logs/view/pump_logs_home.dart';
import '../../Logs/view/voltage_log.dart';
import '../state_management/pump_controller_provider.dart';

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
  DateTime _focusedDay = DateTime.now();
  DateTime today = DateTime.now();

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
    final isSmallScreen = MediaQuery.of(context).size.width <= 600;
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
        body: isSmallScreen ? _buildSmallScreen(): _buildLargeScreen(),
        bottomNavigationBar: !kIsWeb ? BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Preference'),
            BottomNavigationBarItem(icon: Icon(Icons.assessment_outlined), activeIcon: Icon(Icons.assessment), label: 'Logs'),
          ],
          currentIndex: _selectedIndex,
          backgroundColor: Colors.white,
          unselectedItemColor: Colors.grey,
          selectedItemColor: Theme.of(context).primaryColorLight,
          type: BottomNavigationBarType.fixed,
          elevation: 8.0,
          onTap: _onItemTapped,
        ) : null,
      ),
    );
  }

  Widget _buildLargeScreen() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10,),
                Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: Row(
                      spacing: 15,
                      children: [
                        for(int index = 0; index < 4; index++)
                          CustomOutlineButton(
                              onPressed: () async{
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              isSelected: _selectedIndex == index,
                              label: ["Pump log", "Power graph", "Voltage log", "Settings"][index]
                          )
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 10,),
                Row(
                  spacing: 10,
                  children: [
                    SizedBox(
                      height: constraints.maxHeight - (constraints.maxHeight * 0.1),
                      width: 400,
                      child: PumpDashboardScreen(
                        deviceId: widget.deviceId,
                        liveData: widget.liveData,
                        masterName: widget.masterName,
                        userId: widget.userId,
                        customerId: widget.customerId,
                        controllerId: widget.controllerId,
                      ),
                    ),
                    if(_selectedIndex != 3)
                      Expanded(
                          child: Container(
                            height: constraints.maxHeight - (constraints.maxHeight * 0.1),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              color: Colors.white,
                              surfaceTintColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: _buildCalendar(constraints),
                              ),
                            ),
                          )
                      ),
                    Expanded(
                      flex: 2,
                        child: SizedBox(
                          height: constraints.maxHeight - (constraints.maxHeight * 0.1),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            color: Colors.white,
                            surfaceTintColor: Colors.white,
                            child: _getSelectedScreen(),
                          )
                        )
                    ),
                  ],
                )
              ],
            ),
          );
        }
    );
  }

  Widget _buildSmallScreen() {
    return PageView(
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
    );
  }

  Widget _buildCalendar(BoxConstraints constraints) {
    final theme = Theme.of(context);
    final provider = context.read<PumpControllerProvider>();
    return TableCalendar(
      rowHeight: 40,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      focusedDay: _focusedDay,
      firstDay: DateTime.utc(2020, 10, 16),
      lastDay: DateTime.utc(2100, 12, 31),
      calendarFormat: CalendarFormat.month,
      calendarStyle: CalendarStyle(
        cellMargin: const EdgeInsets.all(4),
        markerSize: 10,
        markerMargin: const EdgeInsets.all(2),
        markerDecoration: boxDecoration,
        outsideDecoration: boxDecoration,
        holidayDecoration: boxDecoration.copyWith(color: Colors.grey.withOpacity(0.1),),
        weekendDecoration: boxDecoration.copyWith(color: Colors.grey.withOpacity(0.1),),
        defaultDecoration: boxDecoration.copyWith(color: Colors.grey.withOpacity(0.1),),
        selectedDecoration: boxDecoration.copyWith(color: theme.primaryColor),
        todayTextStyle: const TextStyle(color: Colors.black),
        todayDecoration: boxDecoration.copyWith(color: theme.primaryColor.withOpacity(0.2), border: Border.all(color: theme.primaryColor)),
      ),
      selectedDayPredicate: (day) {
        return isSameDay(provider.selectedDate, day);
      },
      onDaySelected: (selectedDay, focusedDay) async{
        setState(() {
          provider.selectedDate = selectedDay;
          _focusedDay = focusedDay;
        });
        await _getDataFunction();
      },
    );
  }

  Future<void> _getDataFunction() async{
    final provider = context.read<PumpControllerProvider>();
    switch(_selectedIndex) {
      case 0:
        await provider.getUserPumpLog(widget.userId, widget.controllerId, 0);
      case 1:
        await provider.getPumpControllerData(userId: widget.userId, controllerId: widget.controllerId, nodeControllerId: 0);
      case 2:
        await provider.getUserVoltageLog(userId: widget.userId, controllerId: widget.controllerId, nodeControllerId: 0);
      default:
        (){};
    }
  }

  final BoxDecoration boxDecoration = BoxDecoration(
    shape: BoxShape.rectangle,
    borderRadius: BorderRadius.circular(4),
  );

  Widget _getSelectedScreen() {
    Widget selectedWidget = const Center(child: Text('Coming soon'),);
    switch(_selectedIndex) {
      case 0:
        selectedWidget =  PumpLogScreen(userId: widget.userId, controllerId: widget.controllerId);
      case 1:
        selectedWidget =  PowerGraphScreen(userId: widget.userId, controllerId: widget.controllerId);
      case 2:
        selectedWidget = PumpVoltageLogScreen(userId: widget.userId, controllerId: widget.controllerId);
      case 3:
        selectedWidget =  PreferenceMainScreen(
            userId: widget.userId,
            controllerId: widget.controllerId,
            deviceId: widget.deviceId,
            customerId: widget.customerId,
            menuId: 0
        );
      default:
        selectedWidget;
    }
    return selectedWidget;
  }
}
