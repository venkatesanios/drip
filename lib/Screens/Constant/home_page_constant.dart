import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  final List<WaterMeters> waterMeter;
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
  String? selectedParameter;
  final ScrollController _scrollController = ScrollController();
  late List<ConstantMenu> filteredMenu;

  @override
  void initState() {
    super.initState();

    // Exclude "Normal Alarm" and filter items with value == '1'
    filteredMenu = widget.constantMenu
        .where((item) => item.parameter != "Normal Alarm" && item.value == '1')
        .toList();

    // Add the "Finish" parameter at the end
    filteredMenu.add(ConstantMenu(parameter: "Finish", dealerDefinitionId: 0, value: '1'));

    // Set initial selected parameter
    selectedParameter = filteredMenu.firstWhere(
          (item) => item.parameter == "General",
      orElse: () => filteredMenu.isNotEmpty
          ? filteredMenu.first
          : ConstantMenu(parameter: "General", dealerDefinitionId: 82, value: '1'),
    ).parameter;

    _tabController = TabController(length: filteredMenu.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(_tabController.index);
    });

    // Listen for tab changes
    _tabController.addListener(() {
      if (_tabController.index < filteredMenu.length) {
        setState(() {
          selectedParameter = filteredMenu[_tabController.index].parameter;
        });
        _scrollToSelected(_tabController.index);
      }
    });
  }

  void _scrollToSelected(int index) {
    if (!_scrollController.hasClients) return;

    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = 190.0;
    double scrollOffset = index * itemWidth - (screenWidth / 2) + (itemWidth / 2);

    _scrollController.animateTo(
      scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: 50,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filteredMenu.asMap().entries.map((entry) {
                int index = entry.key;
                ConstantMenu filteredItem = entry.value;
                bool isSelected = selectedParameter == filteredItem.parameter;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedParameter = filteredItem.parameter;
                    });
                    _tabController.animateTo(index);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          isSelected ? const Color(0xFF005B8D) : const Color(
                              0xFFFFFFFF),
                          BlendMode.srcIn,
                        ),
                        child: SvgPicture.asset(
                          'assets/Images/Svg/white.svg',
                          width: 218,
                          height: 55,
                        ),
                      ),
                      Positioned(
                        child: Text(
                          filteredItem.parameter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // IndexedStack for content
        Expanded(
          child: IndexedStack(
            index: filteredMenu.indexWhere(
                  (item) => item.parameter == selectedParameter,
            ).clamp(0, filteredMenu.length - 1),
            children: [
              ...filteredMenu.map((item) {
                switch (item.parameter) {
                  case "General":
                    return widget.generalUpdated.isNotEmpty
                        ? GeneralPage(generalUpdated: List<Map<String, dynamic>>.from(widget.generalUpdated))
                        : const Center(child: Text("General Data not available"));

                  case "Pump":
                    return widget.pump.isNotEmpty
                        ? PumpPage(pump: widget.pump)
                        : const Center(child: Text("Pump Data not available"));

                  case "Irrigation Line":
                    return widget.irrigationLines.isNotEmpty
                        ? IrrigationLineInConstant(irrigationLines: widget.irrigationLines)
                        : const Center(child: Text("Irrigation Line Data not available"));

                  case "Main Valve":
                    return widget.mainValves.isNotEmpty
                        ? MainValveInConstant(
                      mainValves: widget.mainValves,
                      irrigationLines: widget.irrigationLines,
                    )
                        : const Center(child: Text("Main Valve Data not available"));

                  case "Valve":
                    return widget.valves.isNotEmpty
                        ? ValveInConstant(
                      valves: widget.valves,
                      irrigationLines: widget.irrigationLines,
                    )
                        : const Center(child: Text("Valve Data not available"));

                  case "Water Meter":
                    return widget.waterMeter.isNotEmpty
                        ? WatermeterInConstant(waterMeter: widget.waterMeter)
                        : const Center(child: Text("Water Meter Data not available"));

                  case "Fertilizer":
                    return widget.fertilizerSite.isNotEmpty
                        ? FertilizerInConstant(
                      fertilizerSite: widget.fertilizerSite,
                      channels: widget.channels,
                    )
                        : const Center(child: Text("Fertilizer Data not available"));

                  case "EC/PH":
                    return widget.ec.isNotEmpty && widget.ph.isNotEmpty
                        ? EcPhInConstant(
                      ec: widget.ec,
                      ph: widget.ph,
                      fertilizerSite: widget.fertilizerSite,
                      controlSensors: widget.controlSensors,
                    )
                        : const Center(child: Text("EC/PH Data not available"));

                  case "Critical Alarm":
                    return widget.alarm.isNotEmpty
                        ? CriticalAlarmInConstant(alarm: widget.alarm)
                        : const Center(child: Text("Critical Alarm Data not available"));

                  case "Global Alarm":
                    return widget.alarm.isNotEmpty
                        ? GlobalAlarmInConstant(alarm: widget.alarm)
                        : const Center(child: Text("Global Alarm Data not available"));

                  case "Moisture Sensor":
                    return widget.moistureSensors.isNotEmpty
                        ? MoistureSensorConstant(moistureSensors: widget.moistureSensors)
                        : const Center(child: Text("Moisture Sensor Data not available"));

                  case "Level Sensor":
                    return widget.levelSensor.isNotEmpty
                        ? LevelSensorInConstant(
                      levelSensor: widget.levelSensor,
                      waterSource: widget.waterSource,
                    )
                        : const Center(child: Text("Level Sensor Data not available"));

                  case "Finish":
                    return  FinishInConstant(
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
                      levelSensor: widget.levelSensor,
                      moistureSensors: widget.moistureSensors,
                      waterMeter: widget.waterMeter,
                    );

                  default:
                    return Center(child: Text("${item.parameter} Data not available"));
                }
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}


/*body: Column(
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
                      return constInit?WaterMeterInConstant(
                        waterMeter: widget.waterMeter,
                      ):SizedBox();
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
      ),*/
     /* floatingActionButton: SizedBox(
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
    );*/

