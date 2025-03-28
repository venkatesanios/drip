/*
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/modules/Preferences/view/settings_screen.dart';
import 'package:provider/provider.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../StateManagement/overall_use.dart';
import '../state_management/preference_provider.dart';
import '../../IrrigationProgram/widgets/custom_animated_switcher.dart';
import '../widgets/custom_segmented_control.dart';
import '../../IrrigationProgram/view/schedule_screen.dart';

class ViewSettings extends StatefulWidget {
  final int userId, controllerId;
  const ViewSettings({super.key, required this.userId, required this.controllerId});

  @override
  State<ViewSettings> createState() => _ViewSettingsState();
}

class _ViewSettingsState extends State<ViewSettings> with TickerProviderStateMixin{

  late MqttPayloadProvider mqttPayloadProvider;
  late PreferenceProvider preferenceProvider;
  late OverAllUse overAllPvd;
  Timer? timer;
  Timer? dialogTimer;
  bool showCannotCommunicateMessage = false;
  late TabController tabController1;
  late TabController tabController2;
  // int selectedPumpIndex1 = 0;
  // int selectedPumpIndex2 = 0;
  int selectedSetting = 0;
  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    preferenceProvider = Provider.of<PreferenceProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    mqttPayloadProvider.viewSettingsList.clear();
    tabController1 = TabController(
        length: preferenceProvider.commonPumpSettings?.length ?? 0,
        vsync: this
    );
    tabController2 = TabController(
        length: preferenceProvider.individualPumpSetting?.length ?? 0,
        vsync: this
    );
    if(mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if(preferenceProvider.commonPumpSettings?.isEmpty ?? false) {
          setState(() {
            selectedSetting = 1;
          });
        }
      });
    }
    requestViewSettings();
  }

  @override
  void dispose() {
    timer?.cancel();
    dialogTimer?.cancel();
    tabController1.dispose();
    tabController2.dispose();
    super.dispose();
  }

  Future<void> requestViewSettings() async {
    setState(() {
      mqttPayloadProvider.viewSettingsList = [];
      showCannotCommunicateMessage = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      // MQTTManager().publish(jsonEncode({
      //   "sentSms": "viewconfig"
      // }), "AppToFirmware/${overAllPvd.imeiNo}");
    }).then((value) {
      preferenceProvider.getUserPreference(userId: widget.userId, controllerId: widget.controllerId);
    });

    timer = Timer(const Duration(seconds: 20), () {
      if (mqttPayloadProvider.viewSettingsList.isEmpty) {
        retryRequest();
      } else {
        setState(() {
          showCannotCommunicateMessage = false;
        });
      }
    });
  }

  void retryRequest() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          timer?.cancel();
          dialogTimer = Timer(const Duration(seconds: 10), () {
            Navigator.of(context).pop();
            setState(() {
              if(mqttPayloadProvider.viewSettingsList.isEmpty) {
                showCannotCommunicateMessage = true;
              } else {
                showCannotCommunicateMessage = false;
              }
            });
          });
          return AlertDialog(
              title: const Text("Warning!", style: TextStyle(color: Colors.red),),
              content: Text("Controller is not responding")
              // content: Text('${mqttPayloadProvider.getAppConnectionState == MQTTConnectionState.connected ? "Controller is not responding" : mqttPayloadProvider.getAppConnectionState.name.toUpperCase()}. Retrying...')
          );
        }
    );
    requestViewSettings();
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    preferenceProvider = Provider.of<PreferenceProvider>(context, listen: true);
    if (showCannotCommunicateMessage) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Settings view", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Sorry! Cannot communicate", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
              ElevatedButton(
                onPressed: (){
                  retryRequest();
                },
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }
    if(mqttPayloadProvider.viewSettingsList.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Settings view", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
        ),
        // body: buildWidget(),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                children: [
                  const SizedBox(height: 10,),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: CustomSegmentedControl(
                      segmentTitles: const {
                        0: 'Common setting',
                        1: 'Individual setting',
                        2: 'Calibration'
                      },
                      padding: EdgeInsets.symmetric(vertical: 10),
                      groupValue: selectedSetting,
                      onChanged: (value) {
                        setState(() {
                          selectedSetting = value!;
                        });
                      },
                    ),
                  ),
                  DefaultTabController(
                      length: selectedSetting != 1 ? preferenceProvider.commonPumpSettings!.length: preferenceProvider.individualPumpSetting!.length,
                      child: Column(
                        children: [
                          if(preferenceProvider.commonPumpSettings!.isNotEmpty)
                            const SizedBox(height: 10,),
                          Container(
                            width: double.infinity,
                            color: (selectedSetting == 0 || selectedSetting == 2) ? preferenceProvider.commonPumpSettings!.length > 1 ? AppProperties.primaryColorDark : Colors.transparent : AppProperties.primaryColorDark,
                            // color: (preferenceProvider.commonPumpSettings!.length > 1 && selectedSetting != 0) ? primaryColorDark : Colors.transparent,
                            child: TabBar(
                              controller: selectedSetting != 1 ? tabController1 : tabController2,
                              labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                              indicatorColor: Colors.white,
                              tabAlignment: TabAlignment.start,
                              labelStyle: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey.shade400),
                              dividerColor: Colors.transparent,
                              isScrollable: true,
                              tabs: [
                                if(selectedSetting != 1)
                                  ...preferenceProvider.commonPumpSettings!.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final element = entry.value;
                                    return preferenceProvider.commonPumpSettings!.length > 1 ? Tab(
                                      text: "${element.deviceName}\n${element.deviceId}",
                                    ) : Container();
                                    // return buildTabItem(index: index, itemName: "${element.deviceName}\n${element.deviceId}", selectedIndex: selectedPumpIndex1);
                                  })
                                else
                                  ...preferenceProvider.individualPumpSetting!.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final element = entry.value;
                                    return Tab(
                                      text: (preferenceProvider.commonPumpSettings!.length > 1 && element.deviceId != null) ? "${element.name}\n${element.deviceId}" : "${element.name}",
                                    );
                                    // return buildTabItem(index: index, itemName: "${element.name}", selectedIndex: selectedPumpIndex2);
                                  })
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                  if(selectedSetting != 2)
                    Expanded(
                        child: TabBarView(
                          controller: selectedSetting != 1 ? tabController1 : tabController2,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            if(selectedSetting == 0)
                              for(var commonSettingIndex = 0; commonSettingIndex < preferenceProvider.commonPumpSettings!.length; commonSettingIndex++)
                                buildSettingsCategory(
                                    context: context,
                                    settingList: preferenceProvider.commonPumpSettings![commonSettingIndex].settingList,
                                    constraints: constraints,
                                    pumpIndex: commonSettingIndex
                                )
                            else if(selectedSetting == 1)
                              for(var pumpSettingIndex = 0; pumpSettingIndex < preferenceProvider.individualPumpSetting!.length; pumpSettingIndex++)
                                buildSettingsCategory(
                                    context: context,
                                    settingList: preferenceProvider.individualPumpSetting![pumpSettingIndex].settingList,
                                    constraints: constraints,
                                    pumpIndex: pumpSettingIndex
                                )
                          ],
                        )
                    ),
                  if(selectedSetting == 2)
                    Expanded(
                        child: TabBarView(
                          controller: selectedSetting != 1 ? tabController1 : tabController2,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            for(var calibrationSettingIndex = 0; calibrationSettingIndex < preferenceProvider.calibrationSetting!.length; calibrationSettingIndex++)
                              buildSettingsCategory(
                                  context: context,
                                  settingList: preferenceProvider.calibrationSetting![calibrationSettingIndex].settingList,
                                  constraints: constraints,
                                  pumpIndex: calibrationSettingIndex
                              )
                          ],
                        )
                    ),
                ],
              );
            }
        ),
        floatingActionButton: MaterialButton(
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          elevation: 15,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          onPressed: () {
            requestViewSettings();
            print(mqttPayloadProvider.viewSettingsList);
          },
          child: Text("Request again".toUpperCase()),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Settings view", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
  }

  Widget buildSettingsCategory({required BuildContext context, required List settingList, required BoxConstraints constraints, required int pumpIndex}) {
    try {
      return ListView(
        children: [
          for(var categoryIndex = 0; categoryIndex < settingList.length; categoryIndex++)
            if((settingList[categoryIndex].pumpType == 210 && (preferenceProvider.generalData!.categoryId != 3 || preferenceProvider.generalData!.categoryId != 4)) ? preferenceProvider.individualPumpSetting![pumpIndex].controlGem : true)
              Container(
                margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth < 700 ? 10 : 200, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(settingList[categoryIndex].name, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: AppProperties.customBoxShadowLiteTheme
                      ),
                      child: Column(
                          children: [
                            for(var settingIndex = 0; settingIndex < settingList[categoryIndex].setting.length; settingIndex++)
                              if(settingList[categoryIndex].setting[settingIndex].title == "RTC TIMER")
                                CustomAnimatedSwitcher(
                                  condition: true,
                                  child: Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(),
                                      1: FlexColumnWidth(),
                                      2: FlexColumnWidth(),
                                    },
                                    children: [
                                      // Header row
                                      TableRow(
                                        children: [
                                          Center(
                                            child: Text('RTC', style: Theme.of(context).textTheme.bodyLarge),
                                          ),
                                          Center(
                                            child: Text('On Time', style: Theme.of(context).textTheme.bodyLarge),
                                          ),
                                          Center(
                                            child: Text('Off Time', style: Theme.of(context).textTheme.bodyLarge),
                                          ),
                                        ],
                                      ),
                                      // Space between header and content rows
                                      TableRow(
                                        children: [
                                          const SizedBox(height: 20),
                                          const SizedBox(height: 20),
                                          const SizedBox(height: 20),
                                        ],
                                      ),
                                      // Dynamic content rows
                                      if (settingList[categoryIndex].setting[settingIndex].rtcSettings != null)
                                        ...settingList[categoryIndex].setting[settingIndex].rtcSettings!.asMap().entries.map((entry) {
                                          final int rtcIndex = entry.key;

                                          List<String> value = [];
                                          String rtcSettingsValue = getValueForRtc(
                                            type: settingList[categoryIndex].pumpType,
                                            categoryIndex: categoryIndex,
                                            pumpIndex: pumpIndex,
                                            settingIndex: settingIndex,
                                          ).split(',').skip(1).join(',');
                                          List<String> valuesList = rtcSettingsValue.split(',');
                                          value = extractValues(rtcIndex, valuesList); // value[0] = On Time, value[1] = Off Time
                                          // print("value ==> $value");
                                          // print("valuesList ==> $valuesList");

                                          return TableRow(
                                            children: [
                                              Center(
                                                child: Text(
                                                  '${rtcIndex + 1}', // RTC index
                                                  style: Theme.of(context).textTheme.bodyLarge,
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  value[0], // On Time
                                                  style: Theme.of(context).textTheme.bodyLarge,
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  value[1], // Off Time
                                                  style: Theme.of(context).textTheme.bodyLarge,
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                    ],
                                  ),
                                )
                              else if(settingList[categoryIndex].setting[settingIndex].title == "2 PHASE" || settingList[categoryIndex].setting[settingIndex].title == "AUTO RESTART 2 PHASE")
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: Container(
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            gradient: AppProperties.linearGradientLeading,
                                          ),
                                          child: CircleAvatar(
                                              backgroundColor: cardColor,
                                              child: Icon(otherSettingsIcons[settingIndex], color: Theme.of(context).primaryColor)
                                          )
                                      ),
                                      title: Text(settingList[categoryIndex].setting[settingIndex].title),
                                      trailing: Text((getValue(
                                          type: settingList[categoryIndex].pumpType,
                                          categoryIndex: categoryIndex,
                                          pumpIndex: pumpIndex,
                                          settingIndex: settingIndex
                                      ).split(',')[settingIndex]), style: TextStyle(fontSize: 14),),
                                    ),
                                  ],
                                )
                              else
                                buildCustomListTileWidget(
                                  context: context,
                                  title: settingList[categoryIndex].setting[settingIndex].title,
                                  widgetType: 6,
                                  inputFormatters: [],
                                  dataList: settingList[categoryIndex].setting[settingIndex].title == "SENSOR HEIGHT" ? ["20", "35"] : ["10", "12"],
                                  value: (() {
                                    try {
                                      if (settingList[categoryIndex].setting[settingIndex].title == "RTC") {
                                        return getValueForRtc(
                                          type: settingList[categoryIndex].pumpType,
                                          categoryIndex: categoryIndex,
                                          pumpIndex: pumpIndex,
                                          settingIndex: settingIndex,
                                        )[0];
                                      } else {
                                        return getValue(
                                          type: settingList[categoryIndex].pumpType,
                                          categoryIndex: categoryIndex,
                                          pumpIndex: pumpIndex,
                                          settingIndex: settingIndex,
                                        ).split(',')[settingIndex];
                                      }
                                    } catch (e) {
                                      if (e is RangeError) {
                                        return "Not Received";
                                      }
                                      rethrow; // Propagate unexpected errors
                                    }
                                  })(),
                                  leading: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        gradient: AppProperties.linearGradientLeading,
                                      ),
                                      child: CircleAvatar(
                                          backgroundColor: cardColor,
                                          child: Icon(
                                              (settingList[categoryIndex].pumpType == 26 || settingList[categoryIndex].pumpType == 206)
                                                  ? otherSettingsIcons[settingIndex]
                                                  : (settingList[categoryIndex].pumpType == 24 || settingList[categoryIndex].pumpType == 204)
                                                  ? voltageSettingsIcons[settingIndex]
                                                  : (settingList[categoryIndex].pumpType == 22 || settingList[categoryIndex].pumpType == 202)
                                                  ? timerSettingsIcons[settingIndex]
                                                  : (settingList[categoryIndex].pumpType == 23 || settingList[categoryIndex].pumpType == 203)
                                                  ? currentSettingIcons[settingIndex]
                                                  : ((settingList[categoryIndex].pumpType == 27 || settingList[categoryIndex].pumpType == 28) || (settingList[categoryIndex].pumpType == 207 || settingList[categoryIndex].pumpType == 208))
                                                  ? voltageCalibrationIcons[settingIndex]
                                                  : (settingList[categoryIndex].pumpType == 29 || settingList[categoryIndex].pumpType == 209)
                                                  ? otherCalibrationIcons[settingIndex]
                                                  : settingList[categoryIndex].pumpType == 210
                                                  ? levelSettingsIcons[settingIndex]
                                                  : additionalSettingsIcons[settingIndex],
                                              color: Theme.of(context).primaryColor
                                          )
                                      )
                                  ),
                                  onValueChange: (newValue) {},
                                  conditionToShow: true,
                                  subTitle: null,
                                  hidden: settingList[categoryIndex].setting[settingIndex].hidden,
                                  enabled: true,
                                )
                  ],
                ),
              ),
          SizedBox(height: 10,),
          if(categoryIndex == settingList.length -1)
            const SizedBox(height: 50,)
        ],
      )),
    for(var categoryIndex = 0; categoryIndex < settingList.length; categoryIndex++)
    if(!((settingList[categoryIndex].pumpType == 210 && (preferenceProvider.generalData!.categoryId != 3 || preferenceProvider.generalData!.categoryId != 4)) ? preferenceProvider.individualPumpSetting![pumpIndex].controlGem : true))
    SizedBox(height: 50,)],
    );
    } catch(error, stackTrace) {
    // throw Exception('This is a test exception');

    print("error ==> $error");
    print("stackTrace ==> $stackTrace");

    return Center(
    child: Text('Unexpected error'));
    }
  }

  List<String> extractValues(int rtcIndex, List<String> valuesList) {
    int startIndex = rtcIndex * 2;
    return valuesList.sublist(startIndex, startIndex + 2);
  }

  String getValue({required int type, required int categoryIndex, required int pumpIndex, required int settingIndex}) {
    String valueToShow = "";

    for (var i = 0; i < mqttPayloadProvider.viewSettingsList.length; i++) {
      var rtcTimeTemp = "";
      var delayTimeTemp = "";
      if(i != 0) {
        if(i-1 == pumpIndex) {
          var decodedList = jsonDecode(mqttPayloadProvider.viewSettingsList[i]);
          for (var element in decodedList) {
            Map<String, dynamic> decode = element;
            decode.forEach((key, value) {
              switch (type) {
                case 22:case 202:
                if (key.contains("delayconfig")) delayTimeTemp = value;
                if (key.contains("rtcconfig")) rtcTimeTemp = value;
                final list = [...delayTimeTemp.split(','), ...rtcTimeTemp.split(',').sublist(1)];
                valueToShow = list.join(',');
                break;
                case 23:case 203:
                if (key.contains("currentconfig")) valueToShow = value;
                break;
                case 25:case 205:
                if (key.contains("scheduleconfig")) valueToShow = value;
                break;
                case 26:case 206:
                // print("key ==> $key");
                if (key.contains("ctconfig")) valueToShow = value;
                break;
                case 24:case 204:
                if (key.contains("voltageconfig")) valueToShow = value;
                break;
                case 27:case 207:
                if (key.contains("calibration")) valueToShow = value;
                break;
                case 28:case 208:
                if (key.contains("calibration")) valueToShow = value.split(',').skip(3).join(',');
                break;
                case 29:case 209:
                if (key.contains("calibration")) valueToShow = value.split(',').skip(6).join(',');
                break;
              }
            });
          }
        }
      } else {
        var decodedList = jsonDecode(mqttPayloadProvider.viewSettingsList[i]);
        for (var element in decodedList) {
          Map<String, dynamic> decode = element;
          decode.forEach((key, value) {
            switch (type) {
              case 23:case 203:
              if (key.contains("currentconfig")) valueToShow = value;
              break;
              case 26:case 206:
              if (key.contains("ctconfig")) valueToShow = value;
              break;
              case 24:case 204:
              if (key.contains("voltageconfig")) valueToShow = value;
              break;
              case 27:case 207:
              if (key.contains("calibration")) valueToShow = value;
              break;
              case 28:case 208:
              if (key.contains("calibration")) valueToShow = value.split(',').skip(3).join(',');
              break;
              case 29:case 209:
              if (key.contains("calibration")) valueToShow = value.split(',').skip(6).join(',');
              break;
            }
          });
        }
      }
    }

    return valueToShow;
  }

  String getValueForRtc({required int type, required int categoryIndex, required int pumpIndex, required int settingIndex}) {
    String valueToShow = "";

    for (var i = 0; i < mqttPayloadProvider.viewSettingsList.length; i++) {
      if(i-1 == pumpIndex) {
        var rtcTimeTemp = "";
        var delayTimeTemp = "";
        var decodedList = jsonDecode(mqttPayloadProvider.viewSettingsList[i]);
        for (var element in decodedList) {
          Map<String, dynamic> decode = element;
          decode.forEach((key, value) {
            switch (type) {
              case 22:case 202:
              if (key == "rtcconfig") rtcTimeTemp = value;
              valueToShow = delayTimeTemp+rtcTimeTemp;
              break;
            }
          });
        }
      }
    }
    return valueToShow;
  }

  Map<String, bool> conditions = {
    'phaseValue': false,
    'lowVoltage': false,
    'highVoltage': false,
    'startingCapacitor': false,
    'starterFeedback': false,
    'maxTime': false,
    'cyclicTime': false,
    'rtc': false,
    'dryRun': false,
    'dryRunRestart': false,
    'dryRunOcc': false,
    'overLoad': false,
    'schedule': false,
    'light': false,
    'peakHour': false,
  };

  bool getConditionToShow({required int type, required int serialNumber, required value}) {
    bool result = true;
    void setCondition(String key) {
      conditions[key] = value;
    }
    switch (type) {
      case 26:case 206:
      if (serialNumber == 1) setCondition('phaseValue');
      if (serialNumber == 9) setCondition('light');
      if (serialNumber == 12) setCondition('peakHour');
      if ([10,11].contains(serialNumber)) result = conditions['light']!;
      if ([13,14].contains(serialNumber)) result = conditions['peakHour']!;
      break;

      case 24:case 204:
      if (serialNumber == 1) setCondition('lowVoltage');
      if (serialNumber == 6) setCondition('highVoltage');
      if ([2,3].contains(serialNumber)) result = conditions['lowVoltage']!;
      if ([4,5].contains(serialNumber)) result = conditions['phaseValue']! && conditions['lowVoltage']!;
      if ([7,8].contains(serialNumber)) result = conditions['highVoltage']!;
      if ([9,10].contains(serialNumber)) result = conditions['phaseValue']! && conditions['highVoltage']!;
      break;

      case 22:case 202:
      if (serialNumber == 3) setCondition('startingCapacitor');
      if (serialNumber == 4) result = conditions['startingCapacitor']!;
      if (serialNumber == 5) setCondition('starterFeedback');
      if (serialNumber == 6) result = conditions['starterFeedback']!;
      if (serialNumber == 7) setCondition('maxTime');
      if (serialNumber == 8) result = conditions['maxTime']!;
      if (serialNumber == 9) setCondition('cyclicTime');
      if ([10,11].contains(serialNumber)) result = conditions['cyclicTime']!;
      if (serialNumber == 12) setCondition('rtc');
      if (serialNumber == 13) result = conditions['rtc']!;
      break;

      case 23:case 203:
      if (serialNumber == 1) setCondition('dryRun');
      if (serialNumber == 4) result = conditions['phaseValue']! && conditions['dryRun']!;
      if ([2, 3, 5, 6, 7, 8, 9, 10].contains(serialNumber)) result = conditions['dryRun']!;
      if (serialNumber == 5) setCondition('dryRunRestart');
      if (serialNumber == 6) result = conditions['dryRun']! && conditions['dryRunRestart']!;
      if (serialNumber == 7) setCondition('dryRunOcc');
      if ([8,9].contains(serialNumber)) result = conditions['dryRun']! && conditions['dryRunOcc']!;
      if (serialNumber == 11) setCondition('overLoad');
      if (serialNumber == 14) result = conditions['phaseValue']! && conditions['overLoad']!;
      if ([12, 13, 15].contains(serialNumber)) result = conditions['overLoad']!;
      break;

      case 25:case 205:
      if (serialNumber == 3) setCondition('schedule');
      if ([4,5].contains(serialNumber)) result = conditions['schedule']!;

      default:
        break;
    }

    return result;
  }

  Widget buildTabItem({required int index, required String itemName, required int selectedIndex}) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: index == selectedIndex ? Theme.of(context).primaryColor : cardColor
        ),
        child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(itemName, style: TextStyle(color: index == selectedIndex ? Colors.white : Theme.of(context).primaryColor),),
            )
        )
    );
  }
}
*/
