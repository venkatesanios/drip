import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Screens/Constant/pump_in_constant.dart';
import 'package:oro_drip_irrigation/Screens/Constant/valve_in_constant.dart';
import 'package:oro_drip_irrigation/Screens/Constant/watermeter_in_constant.dart';
import 'package:provider/provider.dart';
import 'criticalAlarm_in_constant.dart';
import 'ec_ph_in_constant.dart';
import 'fertilizer_in_constant.dart';
import 'finish_in_constant.dart';
import 'general_in_constant.dart';
import 'globalAlarm_in_constant.dart';
import 'irrigationLine_in_constant.dart';
import 'levelSensor_in_constant.dart';
import 'main_valve_in_constant.dart';
import 'modal_in_constant.dart';
import 'moistureSensor_constant.dart';

class ConstantHomePage extends StatefulWidget {
  final List<ConstantMenu> constantMenu;
  final List<Pump> pump;
  final List<IrrigationLine> irrigationLines;
  final List<MainValve> mainValves;
  final List<Valve> valves;
  final List<Channel> channels;
  final List<FertilizerSite> fertilizerSite;
  final List<EC> ec;
  final List<PH> ph;
  final List<WaterMeter> waterMeter;
  final List<String> controlSensors;
  final List<dynamic> generalUpdated;
  final VoidCallback? onUpdateSuccess;
  final List<Alarm> alarm;
  final List<Alarm> normalAlarm;
  final List<Alarm> criticalAlarm;
  List<dynamic> alarmData;
  final int controllerId;
   int userId;
  List<MoistureSensor> moistureSensors;
  List<LevelSensor>levelSensor;
   List<WaterSource> waterSource;
  ConstantHomePage({
    super.key,
    required this.constantMenu,
    required this.pump,
    required this.irrigationLines,
    required this.mainValves,
    required this.valves,
    required this.fertilizerSite,
    required this.channels,
    required this.ec,
    required this.ph,
    required this.waterMeter,
    required this.controlSensors,
    required this.generalUpdated,
    this.onUpdateSuccess,
    required this.alarm,
    required this.normalAlarm,
    required this.criticalAlarm,
    required this.alarmData,
     required this.controllerId,
     required this.userId,
     required this.moistureSensors,
     required this.levelSensor,
     required this.waterSource,

  });

  @override
  _ConstantHomePageState createState() => _ConstantHomePageState();
}

class _ConstantHomePageState extends State<ConstantHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final filteredMenuLength = widget.constantMenu
        .where((item) => item.parameter != "Normal Alarm")
        .length;

    _tabController = TabController(length: filteredMenuLength + 1, vsync: this);

    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
   // var constantPvd = Provider.of<ConstantProvider>(context, listen: false);
    //constantPvd.updateAlarm(widget.alarmData);
  }


  @override
  Widget build(BuildContext context) {
   // var constantPvd = Provider.of<ConstantProvider>(context, listen: true);
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: const Color(0xff003f62), // Tab bar background color
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              indicatorColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                ...widget.constantMenu
                    .where((item) => item.parameter != "Normal Alarm")
                    .map((item) => Tab(text: item.parameter)),
                const Tab(text: 'Finish'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...widget.constantMenu
                    .where((item) => item.parameter != "Normal Alarm")
                    .map((item) {
                  switch (item.parameter) {
                    case "General":
                      return GeneralPage(generalUpdated: List<Map<String, dynamic>>.from(widget.generalUpdated));
                    case "Pump":
                      return PumpPage(pump: widget.pump);
                    case "Irrigation Line":
                      return IrrigationLineInConstant(irrigationLines: widget.irrigationLines);
                    case "Main Valve":
                      return MainValveInConstant(
                        mainValves: widget.mainValves,
                        irrigationLines: widget.irrigationLines,
                      );
                    case "Valve":
                      return ValveInConstant(
                          valves: widget.valves,
                          irrigationLines: widget.irrigationLines);
                    case "Water Meter":
                      return WatermeterInConstant(
                        waterMeter: widget.waterMeter,
                        irrigationLines: widget.irrigationLines,
                        pump: widget.pump,
                      );
                    case "Fertilizer":
                      return FertilizerInConstant(
                        fertilizerSite: widget.fertilizerSite,
                        channels: widget.channels,
                      );
                    case "EC/PH":
                      return EcPhInConstant(
                        ec: widget.ec,
                        ph: widget.ph,
                        fertilizerSite: widget.fertilizerSite,
                        controlSensors: widget.controlSensors,
                      );
                    case "Critical Alarm":
                      return CriticalAlarmInConstant(
                        alarm: widget.alarm,
                      );
                    case "Global Alarm":
                      return GlobalAlarmInConstant(
                        alarm: widget.alarm,
                      );
                    case "Moisture Sensor":
                      return MoistureSensorConstant(
                        moistureSensors: widget.moistureSensors,
                      );
                    case "Level Sensor":
                      return LevelSensorInConstant(
                        levelSensor: widget.levelSensor,
                        waterSource: widget.waterSource,

                      );
                    default:
                      return Center(child: Text(item.parameter));
                  }
                }),
                FinishInConstant(
                  pumps: widget.pump,
                  valves: widget.valves,
                  ec: widget.ec,
                  ph: widget.ph,
                  fertilizerSite: widget.fertilizerSite,
                  controlSensors: widget.controlSensors,
                  irrigationLines: widget.irrigationLines,
                  mainValves: widget.mainValves,
                  generalUpdated: widget.generalUpdated,
                  alarm: widget.alarm,
                  controllerId: widget.controllerId,
                  userId: widget.userId,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton.small(
              heroTag: 'btn_prev',
              tooltip: 'Previous',
              backgroundColor: _currentIndex == 0 ? Colors.white54 : Colors.white,
              onPressed: _currentIndex == 0
                  ? null
                  : () {
                _tabController.animateTo(_currentIndex - 1);
              },
              child: const Icon(Icons.arrow_back_outlined),
            ),
            FloatingActionButton.small(
              heroTag: 'btn_next',
              tooltip: 'Next',
              backgroundColor: _currentIndex == _tabController.length - 1
                  ? Colors.white54
                  : Colors.white,
              onPressed: _currentIndex == _tabController.length - 1
                  ? null
                  : () {
                _tabController.animateTo(_currentIndex + 1);
              },
              child: const Icon(Icons.arrow_forward_outlined),
            ),
          ],
        ),
      ),
    );

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}