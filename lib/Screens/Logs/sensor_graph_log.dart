import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorGraphLog extends StatefulWidget {
  const SensorGraphLog({super.key});

  @override
  State<SensorGraphLog> createState() => _SensorGraphLogState();
}

enum GraphType { area, line, bar }

class SensorDataInfo {
  final String name;
  final String category;
  final String unit;
  final IconData icon;
  final List<List<ChartData>> multiData;
  final List<String> phaseNames;
  final List<double> phaseLatestValues;
  final List<double> phaseMaxValues;
  final List<double> phaseMinValues;
  final List<double> phaseLastActiveValues;

  final String overallStatus;
  final Color statusColor;

  SensorDataInfo({
    required this.name,
    required this.category,
    required this.unit,
    required this.icon,
    required this.multiData,
    required this.phaseNames,
    required this.phaseLatestValues,
    required this.phaseMaxValues,
    required this.phaseMinValues,
    required this.phaseLastActiveValues,
    required this.overallStatus,
    required this.statusColor,
  });
}

class ChartData {
  ChartData(this.time, this.value);
  final String time;
  final double value;
}

class _SensorGraphLogState extends State<SensorGraphLog> with SingleTickerProviderStateMixin {
  GraphType _selectedGraphType = GraphType.area;
  List<SensorDataInfo> _sensors = [];
  int _selectedSensorIndex = 0;
  final Set<int> _visiblePhases = {0, 1, 2};

  // Standard R-Y-B Phase Colors universally used in 3-phase electrical systems
  static const List<Color> phaseColors3 = [
    Color(0xFFE53935), // Red Phase (R)
    Color(0xFFFFB300), // Yellow/Amber Phase (Y)
    Color(0xFF1E88E5), // Blue Phase (B)
  ];

  static const List<Color> phaseBgColors3 = [
    Color(0xFFFFEBEE), // Light Red tint
    Color(0xFFFFF8E1), // Light Yellow tint
    Color(0xFFE3F2FD), // Light Blue tint
  ];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // 1. Mock Config Data properly structured based on the real API JSON
    final Map<String, dynamic> configJson = {
      "data": {
        "configObject": [
          { "sNo": 5.002, "name": "Pump 2", "objectName": "Pump" },
          { "sNo": 25.001, "name": "Moisture Sensor 1", "objectName": "Moisture Sensor" },
          { "sNo": 30.001, "name": "Soil Temperature Sensor 1", "objectName": "Soil Temperature Sensor" },
          { "sNo": 26.001, "name": "Level Sensor 1", "objectName": "Level Sensor" },
          { "sNo": 24.001, "name": "Pressure Sensor 1", "objectName": "Pressure Sensor" },
          { "sNo": 27.001, "name": "EC Sensor 1", "objectName": "EC Sensor" },
          { "sNo": 28.001, "name": "PH Sensor 1", "objectName": "PH Sensor" },
        ]
      }
    };

    // 2. Mock Log Data mimicking the exact structure for these sensors
    final Map<String, dynamic> logJson = {
      "data": {
        "log": [
          {
            "irrigation": {
              "396": {
                // Pump Voltage (3-phase)
                "5.002_-1": [
                  "08:15:00,220_218_222", "09:15:00,225_220_223",
                  "10:15:00,230_225_228", "11:15:51,230_228_232"
                ],
                // Pump Current (3-phase)
                "5.002_-2": [
                  "08:15:00,1:12.5_2:12.0_3:12.8", "09:15:00,1:13.0_2:12.5_3:13.2",
                  "10:15:00,1:14.2_2:13.8_3:14.5", "11:15:51,1:14.0_2:13.9_3:14.2"
                ],
                // Moisture Sensor
                "25.001_-1": [
                  "08:15:00,1:45.0", "09:15:00,1:42.0",
                  "10:15:00,1:38.0", "11:15:51,1:35.5"
                ],
                // Soil Temperature
                "30.001_-1": [
                  "08:15:00,1:22.5", "09:15:00,1:24.0",
                  "10:15:00,1:26.5", "11:15:51,1:28.0"
                ],
                // Level Sensor
                "26.001_-1": [
                  "08:15:00,1:80.0", "09:15:00,1:75.0",
                  "10:15:00,1:60.0", "11:15:51,1:55.0"
                ],
                // Pressure Sensor
                "24.001_-1": [
                  "08:15:00,1:2.5", "09:15:00,1:2.6",
                  "10:15:00,1:2.4", "11:15:51,1:2.5"
                ],
                // EC Sensor
                "27.001_-1": [
                  "08:15:00,1:1.2", "09:15:00,1:1.3",
                  "10:15:00,1:1.5", "11:15:51,1:1.4"
                ],
                // PH Sensor
                "28.001_-1": [
                  "08:15:00,1:6.5", "09:15:00,1:6.7",
                  "10:15:00,1:6.6", "11:15:51,1:6.5"
                ]
              }
            }
          }
        ]
      }
    };

    // 3. Mapping sNo to Sensor Metadata from Config
    Map<String, Map<String, String>> sNoMetadata = {};
    if (configJson['data'] != null && configJson['data']['configObject'] != null) {
      for (var obj in configJson['data']['configObject']) {
        String sNo = obj['sNo'].toString();
        sNoMetadata[sNo] = {
          'name': obj['name']?.toString() ?? 'Unknown Sensor',
          'objectName': obj['objectName']?.toString() ?? 'Unknown',
        };
      }
    }

    // 4. Parsing the Logs and populating _sensors
    List<SensorDataInfo> parsedSensors = [];
    if (logJson['data'] != null && logJson['data']['log'] != null) {
      for (var logEntry in logJson['data']['log']) {
        if (logEntry['irrigation'] != null) {
          Map<String, dynamic> irrigation = logEntry['irrigation'];
          if (irrigation.isNotEmpty) {
            String firstProgram = irrigation.keys.first;
            Map<String, dynamic> sensorsLog = irrigation[firstProgram];

            sensorsLog.forEach((sensorKey, valuesList) {
              List<String> keyParts = sensorKey.split('_');
              String sNo = keyParts[0];
              String subParam = keyParts.length > 1 ? keyParts[1] : '';
              
              var meta = sNoMetadata[sNo] ?? {'name': 'Sensor $sNo', 'objectName': ''};
              String sensorName = meta['name']!;
              String objectType = meta['objectName']!;
              
              String unit = '';
              IconData icon = Icons.sensors_rounded;
              String category = '';
              String farmerTip = '';
              String insightOptimal = 'Dynamically parsed from the backend API sample JSON.';
              String overallStatus = 'Normal';
              Color statusColor = const Color(0xFF2E7D32);

              // Assign properties based on the STRICT objectName from the backend
              switch (objectType) {
                case 'Moisture Sensor':
                  unit = '%';
                  icon = Icons.water_drop_rounded;
                  category = 'Field Moisture Level';
                  farmerTip = '🌱 Farmer Guide: Soil moisture is actively tracked. Keep between 30% and 50% for optimal root health.';
                  overallStatus = 'Optimal Moisture';
                  statusColor = const Color(0xFF00897B);
                  break;
                case 'Soil Temperature Sensor':
                case 'Temperature Sensor':
                  unit = '°C';
                  icon = Icons.thermostat_rounded;
                  category = 'Soil Temperature';
                  farmerTip = '🌡️ Farmer Guide: Monitors ground temperature. Protect crops if it drops below 10°C.';
                  overallStatus = 'Temp Normal';
                  statusColor = Colors.orange.shade600;
                  break;
                case 'Level Sensor':
                  unit = '%';
                  icon = Icons.waves_rounded;
                  category = 'Tank Level';
                  farmerTip = '💧 Farmer Guide: Tank water level reserve. Refill if below 20%.';
                  overallStatus = 'Level Good';
                  statusColor = Colors.blue.shade600;
                  break;
                case 'Pressure Sensor':
                  unit = 'bar';
                  icon = Icons.speed_rounded;
                  category = 'Pipe Pressure';
                  farmerTip = '⏱️ Farmer Guide: System pressure monitoring. High pressure indicates a blockage.';
                  overallStatus = 'Pressure Safe';
                  statusColor = Colors.indigo.shade500;
                  break;
                case 'EC Sensor':
                  unit = 'dS/m';
                  icon = Icons.science_rounded;
                  category = 'Electrical Conductivity';
                  farmerTip = '🧪 Farmer Guide: Fertilizer salt concentration in soil. 1.0 - 2.0 is ideal for most crops.';
                  overallStatus = 'EC Balanced';
                  statusColor = Colors.teal.shade600;
                  break;
                case 'PH Sensor':
                  unit = 'pH';
                  icon = Icons.opacity_rounded;
                  category = 'Soil/Water Acidity';
                  farmerTip = '🧪 Farmer Guide: Monitor pH to ensure plants absorb nutrients. 6.0 to 7.0 is best.';
                  overallStatus = 'pH Balanced';
                  statusColor = Colors.purple.shade500;
                  break;
                case 'Pump':
                  if (subParam == '-1') {
                    sensorName += ' (Voltage)';
                    unit = 'V';
                    icon = Icons.bolt_rounded;
                    category = '3-Phase Power Supply (Voltage)';
                    farmerTip = '💡 Farmer Guide: All 3 wires (Red, Yellow, Blue) have stable voltage (~220V - 240V). Safe to run.';
                    overallStatus = '3-Phase Healthy';
                    statusColor = const Color(0xFF2E7D32);
                  } else if (subParam == '-2') {
                    sensorName += ' (Current)';
                    unit = 'A';
                    icon = Icons.electric_meter_rounded;
                    category = '3-Phase Motor Load (Current)';
                    farmerTip = '💡 Farmer Guide: Motor current draw shows the pump is actively pushing water steadily.';
                    overallStatus = 'Motor Load Normal';
                    statusColor = const Color(0xFF1976D2);
                  } else {
                    icon = Icons.water_damage_rounded;
                  }
                  break;
                default:
                  unit = '';
                  icon = Icons.analytics_rounded;
                  category = 'General Sensor Data';
                  farmerTip = '📊 Farmer Guide: Raw telemetry from the device.';
                  overallStatus = 'Online';
              }

              List<List<ChartData>> multiData = [[], [], []];
              int phaseCount = 1;

              for (String valStr in valuesList) {
                List<String> parts = valStr.split(',');
                if (parts.length >= 2) {
                  String time = parts[0].substring(0, 5); // Extract "08:15"
                  String dataPart = parts[1];
                  
                  List<String> phaseStrings = dataPart.split('_');
                  phaseCount = phaseStrings.length;
                  
                  for (int i = 0; i < phaseStrings.length; i++) {
                     double parsedValue = 0.0;
                     if (phaseStrings[i].contains(':')) {
                       parsedValue = double.tryParse(phaseStrings[i].split(':').last) ?? 0.0;
                     } else {
                       parsedValue = double.tryParse(phaseStrings[i]) ?? 0.0;
                     }
                     if (i < 3) {
                       multiData[i].add(ChartData(time, parsedValue));
                     }
                  }
                }
              }

              multiData = multiData.take(phaseCount).toList();

              // Compute phase statistics
              List<double> latestValues = [];
              List<double> maxValues = [];
              List<double> minValues = [];
              List<double> lastActiveValues = [];

              for (int i = 0; i < phaseCount; i++) {
                var series = multiData[i];
                if (series.isNotEmpty) {
                  latestValues.add(series.last.value);
                  
                  double mx = series.map((e) => e.value).reduce((a, b) => a > b ? a : b);
                  maxValues.add(mx);
                  
                  double mn = series.map((e) => e.value).reduce((a, b) => a < b ? a : b);
                  minValues.add(mn);

                  var nonZeroSeries = series.where((e) => e.value > 0).toList();
                  if (nonZeroSeries.isNotEmpty) {
                    lastActiveValues.add(nonZeroSeries.last.value);
                  } else {
                    lastActiveValues.add(0.0);
                  }
                } else {
                  latestValues.add(0.0);
                  maxValues.add(0.0);
                  minValues.add(0.0);
                  lastActiveValues.add(0.0);
                }
              }

              List<String> phaseNames = [];
              if (phaseCount == 3) {
                phaseNames = ['R Phase (Red)', 'Y Phase (Yellow)', 'B Phase (Blue)'];
                
                // Override status if voltages/currents are 0
                if (latestValues.every((v) => v == 0)) {
                  if (subParam == '-1') {
                    overallStatus = 'Motor Off (0 V)';
                    statusColor = Colors.orange.shade800;
                  } else if (subParam == '-2') {
                    overallStatus = 'Motor Stopped (0 A)';
                    statusColor = Colors.orange.shade800;
                  }
                }
              } else {
                phaseNames = List.generate(phaseCount, (i) => 'Phase ${i + 1}');
              }

              parsedSensors.add(
                SensorDataInfo(
                  name: sensorName,
                  category: category,
                  unit: unit,
                  icon: icon,
                  multiData: multiData,
                  phaseNames: phaseNames,
                  phaseLatestValues: latestValues,
                  phaseMaxValues: maxValues,
                  phaseMinValues: minValues,
                  phaseLastActiveValues: lastActiveValues,
                  overallStatus: overallStatus,
                  statusColor: statusColor,
                )
              );
            });
          }
        }
      }
    }

    if (parsedSensors.isNotEmpty) {
      _sensors = parsedSensors;
      _visiblePhases.clear();
      _visiblePhases.addAll(List.generate(_sensors[0].multiData.length, (i) => i));
    }
  }

  void _onSensorSelected(int index) {
    setState(() {
      _selectedSensorIndex = index;
      _visiblePhases.clear();
      _visiblePhases.addAll(List.generate(_sensors[index].multiData.length, (i) => i));
    });
  }

  void _togglePhase(int phaseIndex) {
    setState(() {
      if (_visiblePhases.contains(phaseIndex)) {
        if (_visiblePhases.length > 1) {
          _visiblePhases.remove(phaseIndex);
        }
      } else {
        _visiblePhases.add(phaseIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black87;

    if (_sensors.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final selectedSensor = _sensors[_selectedSensorIndex];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar & Screen Title
            // _buildTopAppBar(primaryColor, textColor, selectedSensor),

            // Horizontal Sensor Selector Pills
            _buildSensorSelector(primaryColor, textColor),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prominent R Phase, Y Phase, B Phase Interactive Cards
                    _buildPhaseCardsSection(primaryColor, textColor, selectedSensor),
                    const SizedBox(height: 20),

                    // Graph Header & Graph Controls (Area / Line / Bar)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's Trend Graph",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Tap Phase Cards above to show/hide lines",
                              style: TextStyle(
                                fontSize: 11,
                                color: textColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        _buildGraphTypeToggle(primaryColor, textColor),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Interactive Syncfusion Chart
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Container(
                        key: ValueKey('$_selectedSensorIndex-$_selectedGraphType-${_visiblePhases.join(",")}'),
                        height: 310,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildSyncfusionChart(primaryColor, textColor, selectedSensor),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // // Dual Insights: Farmer Friendly + Technical Breakdown
                    // _buildDualInsights(primaryColor, textColor, selectedSensor),
                    // const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildTopAppBar(Color primaryColor, Color textColor, SensorDataInfo selectedSensor) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).scaffoldBackgroundColor,
  //       border: Border(
  //         bottom: BorderSide(color: textColor.withValues(alpha: 0.06), width: 1),
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Row(
  //           children: [
  //             // IconButton(
  //             //   icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
  //             //   onPressed: () {
  //             //     if (Navigator.canPop(context)) Navigator.pop(context);
  //             //   },
  //             // ),
  //             const SizedBox(width: 4),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'Sensor & Phase Logs',
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: textColor,
  //                   ),
  //                 ),
  //                 Text(
  //                   selectedSensor.category,
  //                   style: TextStyle(
  //                     fontSize: 12,
  //                     color: textColor.withValues(alpha: 0.55),
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //           decoration: BoxDecoration(
  //             color: selectedSensor.statusColor.withValues(alpha: 0.12),
  //             borderRadius: BorderRadius.circular(20),
  //             border: Border.all(color: selectedSensor.statusColor.withValues(alpha: 0.4), width: 1),
  //           ),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Container(
  //                 width: 8,
  //                 height: 8,
  //                 decoration: BoxDecoration(
  //                   color: selectedSensor.statusColor,
  //                   shape: BoxShape.circle,
  //                 ),
  //               ),
  //               const SizedBox(width: 6),
  //               Text(
  //                 selectedSensor.overallStatus,
  //                 style: TextStyle(
  //                   fontSize: 11,
  //                   fontWeight: FontWeight.bold,
  //                   color: selectedSensor.statusColor,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSensorSelector(Color primaryColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(_sensors.length, (index) {
            final isSelected = _selectedSensorIndex == index;
            final sensor = _sensors[index];
            return GestureDetector(
              onTap: () => _onSensorSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : textColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? primaryColor : textColor.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Icon(
                      sensor.icon,
                      color: isSelected ? Colors.white : primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      sensor.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (sensor.multiData.length == 3) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withValues(alpha: 0.2) : primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '3 Phase',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : primaryColor,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPhaseCardsSection(Color primaryColor, Color textColor, SensorDataInfo sensor) {
    if (sensor.multiData.length == 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '3-Phase Live Values',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor.withValues(alpha: 0.85),
                ),
              ),
              Text(
                'Tap card to filter graph',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(3, (i) {
              final isVisible = _visiblePhases.contains(i);
              final phaseColor = phaseColors3[i];
              final phaseBg = phaseBgColors3[i];
              final phaseName = sensor.phaseNames[i];
              final latestVal = sensor.phaseLatestValues[i];
              final lastActiveVal = sensor.phaseLastActiveValues[i];
              final maxVal = sensor.phaseMaxValues[i];

              // Display value: if latest is 0, show peak active value with clear indicator
              final displayVal = latestVal > 0 ? latestVal : lastActiveVal;
              final isOff = latestVal == 0;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _togglePhase(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      color: isVisible ? phaseBg : textColor.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isVisible ? phaseColor : textColor.withValues(alpha: 0.15),
                        width: isVisible ? 2.5 : 1,
                      ),
                      boxShadow: isVisible
                          ? [
                              BoxShadow(
                                color: phaseColor.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phase Tag (R / Y / B)
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: isVisible ? phaseColor : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                phaseName.split(' ').first, // 'R', 'Y', 'B'
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isVisible ? phaseColor : textColor.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                            Icon(
                              isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                              size: 14,
                              color: isVisible ? phaseColor : textColor.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Phase Value
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                displayVal.toStringAsFixed(displayVal.truncateToDouble() == displayVal ? 0 : 1),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: isVisible ? textColor : textColor.withValues(alpha: 0.4),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                sensor.unit,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isVisible ? phaseColor : textColor.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Peak / Status subtext
                        Text(
                          isOff ? 'Peak: ${maxVal.toStringAsFixed(0)} ${sensor.unit}' : 'Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isOff
                                ? textColor.withValues(alpha: 0.5)
                                : (isVisible ? phaseColor : textColor.withValues(alpha: 0.4)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      );
    } else {
      // 1-Phase Card
      final val = sensor.phaseLatestValues.isNotEmpty ? sensor.phaseLatestValues[0] : 0.0;
      final maxV = sensor.phaseMaxValues.isNotEmpty ? sensor.phaseMaxValues[0] : 0.0;
      final minV = sensor.phaseMinValues.isNotEmpty ? sensor.phaseMinValues[0] : 0.0;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(sensor.icon, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      sensor.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sensor.unit,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sensor.overallStatus,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Max: $maxV ${sensor.unit}',
                  style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                ),
                Text(
                  'Min: $minV ${sensor.unit}',
                  style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.6), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildGraphTypeToggle(Color primaryColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(Icons.stacked_line_chart_rounded, 'Area', GraphType.area, primaryColor, textColor),
          _buildToggleOption(Icons.show_chart_rounded, 'Line', GraphType.line, primaryColor, textColor),
          _buildToggleOption(Icons.bar_chart_rounded, 'Bar', GraphType.bar, primaryColor, textColor),
        ],
      ),
    );
  }

  Widget _buildToggleOption(IconData icon, String label, GraphType type, Color primaryColor, Color textColor) {
    final isSelected = _selectedGraphType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGraphType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? primaryColor : textColor.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryColor : textColor.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncfusionChart(Color primaryColor, Color textColor, SensorDataInfo sensor) {
    double maxVal = -double.infinity;
    double minVal = double.infinity;
    
    for (int i = 0; i < sensor.multiData.length; i++) {
      if (!_visiblePhases.contains(i)) continue;
      for (var point in sensor.multiData[i]) {
        if (point.value > maxVal) maxVal = point.value;
        if (point.value < minVal) minVal = point.value;
      }
    }
    
    if (maxVal == -double.infinity) maxVal = 10;
    if (minVal == double.infinity) minVal = 0;

    double rangePadding = (maxVal - minVal) == 0 ? (maxVal == 0 ? 10 : maxVal * 0.2) : (maxVal - minVal) * 0.25;
    double yMax = maxVal + rangePadding;
    double yMin = (minVal - rangePadding) < 0 ? 0 : (minVal - rangePadding);
    if (yMax == 0) yMax = 10;

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,
      legend: Legend(
        isVisible: sensor.multiData.length > 1,
        position: LegendPosition.top,
        alignment: ChartAlignment.center,
        textStyle: TextStyle(
          color: textColor.withValues(alpha: 0.8),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        iconHeight: 12,
        iconWidth: 12,
        padding: 8,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        canShowMarker: true,
        shared: true,
        format: 'series.name: point.y ${sensor.unit}',
        color: textColor.withValues(alpha: 0.95),
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).scaffoldBackgroundColor,
          fontSize: 12,
        ),
        elevation: 8,
      ),
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: AxisLine(width: 1, color: textColor.withValues(alpha: 0.1)),
        labelStyle: TextStyle(
          color: textColor.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        majorTickLines: const MajorTickLines(size: 4),
      ),
      primaryYAxis: NumericAxis(
        minimum: yMin,
        maximum: yMax,
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: MajorGridLines(
          width: 1,
          color: textColor.withValues(alpha: 0.06),
          dashArray: const <double>[4, 4],
        ),
        labelStyle: TextStyle(
          color: textColor.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        labelFormat: '{value} ${sensor.unit}',
      ),
      series: _getChartSeries(primaryColor, sensor),
    );
  }

  List<CartesianSeries<ChartData, String>> _getChartSeries(Color primaryColor, SensorDataInfo sensor) {
    List<CartesianSeries<ChartData, String>> seriesList = [];
    
    List<Color> phaseColors = sensor.multiData.length == 3 
        ? phaseColors3 
        : [primaryColor, Colors.orange, Colors.green];

    for (int i = 0; i < sensor.multiData.length; i++) {
       if (!_visiblePhases.contains(i)) continue;

       Color seriesColor = sensor.multiData.length == 1 ? primaryColor : phaseColors[i];
       String seriesName = sensor.phaseNames.length > i ? sensor.phaseNames[i] : 'Phase ${i + 1}';

       if (_selectedGraphType == GraphType.area) {
          seriesList.add(SplineAreaSeries<ChartData, String>(
            name: seriesName,
            dataSource: sensor.multiData[i],
            xValueMapper: (ChartData data, _) => data.time,
            yValueMapper: (ChartData data, _) => data.value,
            gradient: LinearGradient(
              colors: [
                seriesColor.withValues(alpha: 0.3),
                seriesColor.withValues(alpha: 0.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderColor: seriesColor,
            borderWidth: 3.5,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 6,
              width: 6,
              shape: DataMarkerType.circle,
            ),
            animationDuration: 800,
          ));
       } else if (_selectedGraphType == GraphType.line) {
          seriesList.add(SplineSeries<ChartData, String>(
            name: seriesName,
            dataSource: sensor.multiData[i],
            xValueMapper: (ChartData data, _) => data.time,
            yValueMapper: (ChartData data, _) => data.value,
            color: seriesColor,
            width: 3.5,
            markerSettings: const MarkerSettings(
              isVisible: true,
              height: 6,
              width: 6,
              shape: DataMarkerType.circle,
            ),
            animationDuration: 800,
          ));
       } else {
          seriesList.add(ColumnSeries<ChartData, String>(
            name: seriesName,
            dataSource: sensor.multiData[i],
            xValueMapper: (ChartData data, _) => data.time,
            yValueMapper: (ChartData data, _) => data.value,
            color: seriesColor.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            width: sensor.multiData.length == 1 ? 0.4 : 0.6,
            animationDuration: 800,
          ));
       }
    }
    return seriesList;
  }

  // Widget _buildDualInsights(Color primaryColor, Color textColor, SensorDataInfo sensor) {
  //   return Column(
  //     children: [
  //       // 1. Simple Farmer Friendly Card (Easy for uneducated users)
  //       Container(
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: const Color(0xFFE8F5E9), // Light green farmer theme
  //           borderRadius: BorderRadius.circular(16),
  //           border: Border.all(color: const Color(0xFFA5D6A7), width: 1.5),
  //         ),
  //         child: Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: const BoxDecoration(
  //                 color: Color(0xFF2E7D32),
  //                 shape: BoxShape.circle,
  //               ),
  //               child: const Icon(
  //                 Icons.eco_rounded,
  //                 color: Colors.white,
  //                 size: 20,
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const Text(
  //                     'Farmer Simple Summary',
  //                     style: TextStyle(
  //                       fontSize: 14,
  //                       fontWeight: FontWeight.bold,
  //                       color: Color(0xFF1B5E20),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     sensor.farmerTip,
  //                     style: const TextStyle(
  //                       fontSize: 13,
  //                       color: Color(0xFF2E7D32),
  //                       height: 1.4,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //
  //       // 2. Technical Diagnostics Card (For educated users / engineers)
  //       Container(
  //         padding: const EdgeInsets.all(16),
  //         decoration: BoxDecoration(
  //           color: Theme.of(context).cardColor,
  //           borderRadius: BorderRadius.circular(16),
  //           border: Border.all(color: textColor.withValues(alpha: 0.08), width: 1),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withValues(alpha: 0.03),
  //               blurRadius: 8,
  //               offset: const Offset(0, 3),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Icon(
  //                   Icons.analytics_rounded,
  //                   color: primaryColor,
  //                   size: 20,
  //                 ),
  //                 const SizedBox(width: 8),
  //                 Text(
  //                   'Technical Diagnostics & Metrics',
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.bold,
  //                     color: textColor,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 10),
  //             Text(
  //               sensor.insightOptimal,
  //               style: TextStyle(
  //                 fontSize: 13,
  //                 color: textColor.withValues(alpha: 0.75),
  //                 height: 1.4,
  //                 fontWeight: FontWeight.w400,
  //               ),
  //             ),
  //             if (sensor.multiData.length == 3) ...[
  //               const Divider(height: 20),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                 children: [
  //                   _buildTechStat('R Peak', '${sensor.phaseMaxValues[0].toStringAsFixed(0)} ${sensor.unit}', phaseColors3[0]),
  //                   _buildTechStat('Y Peak', '${sensor.phaseMaxValues[1].toStringAsFixed(0)} ${sensor.unit}', phaseColors3[1]),
  //                   _buildTechStat('B Peak', '${sensor.phaseMaxValues[2].toStringAsFixed(0)} ${sensor.unit}', phaseColors3[2]),
  //                   _buildTechStat('Variance', '< 2%', primaryColor),
  //                 ],
  //               ),
  //             ],
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTechStat(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
