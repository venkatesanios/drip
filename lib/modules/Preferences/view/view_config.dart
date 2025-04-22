import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/services/mqtt_service.dart';
import 'package:oro_drip_irrigation/utils/environment.dart';
import 'package:provider/provider.dart';

import '../../../StateManagement/mqtt_payload_provider.dart';
import '../model/preference_data_model.dart';
import '../state_management/preference_provider.dart';

class ViewConfig extends StatefulWidget {
  final int userId;
  final bool isLora;
  const ViewConfig({super.key, required this.userId,required this.isLora});

  @override
  State<ViewConfig> createState() => _ViewConfigState();
}

class _ViewConfigState extends State<ViewConfig> {
  List<String> viewPayloads = [
    "pumpconfig", "tankconfig", "ctconfig", "calibration", "voltageconfig",
  ];
  String selectedPayload = "pumpconfig";
  bool _hasTimedOut = false;
  Timer? _timeoutTimer;
  int _remainingTime = 0;
  final MqttService mqttService = MqttService();

  void requestViewConfig(int index) {
    final mqttProvider = context.read<MqttPayloadProvider>();
    final preferenceProvider = context.read<PreferenceProvider>();

    // mqttProvider.viewSetting.clear();
    mqttProvider.viewSettingsList.clear();
    mqttProvider.cCList.clear();
    int waitingSeconds = 90;
    _remainingTime = waitingSeconds;

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        setState(() {
          _hasTimedOut = true;
        });
      }
    });

    if ([1].contains(preferenceProvider.generalData!.categoryId)) {
      final pump = preferenceProvider.commonPumpSettings![preferenceProvider.selectedTabIndex];
      final payload = jsonEncode({"sentSms": "viewconfig,${index + 1}"});
      final payload2 = jsonEncode({"0": payload});
      final viewConfig = {
        "5900": [
          {"5901": "${pump.serialNumber}+${pump.referenceNumber}+${pump.deviceId}+${pump.interfaceTypeId}+$payload2+${pump.categoryId}"},
          {"5902": "${widget.userId}"}
        ]
      };
      // print("published data ${pump.deviceId}");
      mqttService.topicToPublishAndItsMessage(jsonEncode(viewConfig), "${Environment.mqttPublishTopic}/${preferenceProvider.generalData!.deviceId}");
    } else {
      mqttService.topicToPublishAndItsMessage(jsonEncode({"sentSms": "viewconfig"}), "${Environment.mqttPublishTopic}/${preferenceProvider.generalData!.deviceId}");
    }
  }

  List<String> generateDynamicConfigs(int pumpConfig) {
    List<String> dynamicConfigs = [];

    int numberOfPumps = pumpConfig;

    for (int i = 1; i <= numberOfPumps; i++) {
      dynamicConfigs.add("currentconfig$i");
      dynamicConfigs.add("delayconfig$i");
      dynamicConfigs.add("rtcconfig$i");
      dynamicConfigs.add("scheduleconfig$i");
    }

    return dynamicConfigs;
  }

  void updateViewPayloads(String pumpConfigValue) {
    int numberOfPumps = int.tryParse(pumpConfigValue) ?? 1;
    viewPayloads.addAll(generateDynamicConfigs(numberOfPumps));
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestViewConfig(0);
  }

  @override
  dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferenceProvider = context.read<PreferenceProvider>();
    final mqttProvider = context.watch<MqttPayloadProvider>();
    final deviceId = preferenceProvider.commonPumpSettings![preferenceProvider.selectedTabIndex].deviceId;

    if(widget.isLora) {
      if (mqttProvider.viewSetting.isNotEmpty && mqttProvider.viewSetting['cC'] != null && mqttProvider.viewSetting['cC'].contains(deviceId)) {
        _timeoutTimer?.cancel();
        _hasTimedOut = false;
      }
    } else {
      // print('viewSettingsList :: ${mqttProvider.viewSettingsList}');
      if(mqttProvider.viewSettingsList.isNotEmpty && mqttProvider.cCList.contains(deviceId)) {
        _timeoutTimer?.cancel();
        _hasTimedOut = false;
      }
    }

    if (_hasTimedOut) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildDropdown(),
              const SizedBox(height: 10),
              const Text(
                "Device is not responding. Please try again later.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: () {
                  setState(() {
                    _timeoutTimer?.cancel();
                    _hasTimedOut = false;
                    _remainingTime = 20;
                  });
                  requestViewConfig(viewPayloads.indexOf(selectedPayload));
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            ],
          )
      );
    }

    if (widget.isLora
        ? (mqttProvider.viewSetting.isEmpty || (mqttProvider.viewSetting['cC'] != null && !mqttProvider.viewSetting['cC'].contains(deviceId)) || !_hasPayload(selectedPayload, context.read<MqttPayloadProvider>(), deviceId))
        : (!mqttProvider.cCList.contains(deviceId))
    ) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(margin: const EdgeInsets.symmetric(horizontal: 50), child: const LinearProgressIndicator()),
          const SizedBox(height: 10),
          const Text("Fetching configuration... Please wait", style: TextStyle(fontSize: 16)),
          if (_timeoutTimer != null)
            Text("Time remaining: ${_remainingTime}s", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          _buildDropdown(),
          if (_hasPayload("pumpconfig", mqttProvider, deviceId))
            _buildPumpConfig(widget.isLora ? mqttProvider.viewSetting['cM'][0]["pumpconfig"] : '${jsonDecode(mqttProvider.viewSettingsList[0])[0]['pumpconfig']}', preferenceProvider)
          else if (_hasPayload("tankconfig", mqttProvider, deviceId))
            _buildTankConfig(
                widget.isLora
                    ? mqttProvider.viewSetting['cM'][0]["tankconfig"]
                    : _getNumberOfTankConfig(mqttProvider),
                preferenceProvider)
          else if(_hasPayload("ctconfig", mqttProvider, deviceId) || _hasPayload("voltageconfig", mqttProvider, deviceId) || _hasPayload("calibration", mqttProvider, deviceId))
              Expanded(child: _buildCommonSettingCategory(mqttProvider, deviceId))
            else
              Expanded(child: _buildIndividualSettingCategory(mqttProvider, deviceId))
        ],
      ),
    );
  }

  String _getNumberOfTankConfig(MqttPayloadProvider mqttProvider) {
    final noOfPumps = jsonDecode(mqttProvider.viewSettingsList[0])[0]['pumpconfig'];
    List<String> tankConfig = [];
    for(int i = 0; i < noOfPumps; i++) {
      tankConfig.add('${jsonDecode(mqttProvider.viewSettingsList[i+1])[5]['tankconfig']}');
    }

    return tankConfig.join(',');
  }

  Widget _buildDropdown() {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(25),
          color: const Color(0xffF5F5F5)
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: DropdownButton<String>(
          menuMaxHeight: 300,
          padding: const EdgeInsets.symmetric(vertical: 0),
          value: selectedPayload,
            underline: Container(),
          borderRadius: BorderRadius.circular(5),
          items: viewPayloads.toSet().toList()
              .map((value) => DropdownMenuItem(value: value, child: Text(value)))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedPayload = value!;
              if(widget.isLora) {
                requestViewConfig(viewPayloads.indexOf(value));
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildPumpConfig(String payload, PreferenceProvider prefProvider) {
    final values = payload.split(',');
    updateViewPayloads(values[0]);
    List<String> titles = ['Number of pumps'];
    if (widget.isLora) {
      final pumpNames = prefProvider.individualPumpSetting!
          .where((e) => e.deviceId == prefProvider.commonPumpSettings![prefProvider.selectedTabIndex].deviceId)
          .map((e) => e.name)
          .toList();
      titles.add('Serial id');
      titles.addAll(pumpNames);
    }

    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).primaryColorLight,
          width: 0.5,
        ),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      margin: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
      elevation: 4,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Theme.of(context).primaryColorLight.withAlpha(100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          titles.length,
              (i) => _buildListTile(titles[i].toUpperCase(), values[i]),
        ),
      ),
    );
  }

  bool _hasPayload(String key, MqttPayloadProvider provider, String deviceId) {
    if(widget.isLora) {
      return provider.viewSetting.isNotEmpty && provider.viewSetting['cM'].first.containsKey(key) && provider.viewSetting['cC'].contains(deviceId) && selectedPayload.contains(key);
    } else {
      switch(key) {
        case 'pumpconfig':
          return provider.viewSettingsList.isNotEmpty && jsonDecode(provider.viewSettingsList[0])[0][key] != null && selectedPayload.contains(key) && provider.cCList.contains(deviceId);
        case 'tankconfig':
          return provider.viewSettingsList.isNotEmpty && jsonDecode(provider.viewSettingsList[1])[5][key] != null && selectedPayload.contains(key) && provider.cCList.contains(deviceId);
        case 'ctconfig':
          return provider.viewSettingsList.isNotEmpty && jsonDecode(provider.viewSettingsList[0])[1][key] != null && selectedPayload.contains(key) && provider.cCList.contains(deviceId);
        case 'voltageconfig':
          return provider.viewSettingsList.isNotEmpty && jsonDecode(provider.viewSettingsList[0])[2][key] != null && selectedPayload.contains(key) && provider.cCList.contains(deviceId);
        case 'currentconfig':
          return provider.viewSettingsList.isNotEmpty && jsonDecode(provider.viewSettingsList[1])[3][key] != null && selectedPayload.contains(key) && provider.cCList.contains(deviceId);
        case 'rtcconfig':
          return provider.viewSettingsList.isNotEmpty && jsonDecode(provider.viewSettingsList[1])[2][key] != null && selectedPayload.contains(key) && provider.cCList.contains(deviceId);
        case 'delayconfig':
          return provider.viewSettingsList.isNotEmpty && jsonDecode(provider.viewSettingsList[1])[1][key] != null && selectedPayload.contains(key) && provider.cCList.contains(deviceId);
        case 'scheduleconfig':
          return provider.viewSettingsList.isNotEmpty && jsonDecode(provider.viewSettingsList[1])[4][key] != null && selectedPayload.contains(key) && provider.cCList.contains(deviceId);
        case 'calibration':
          return provider.viewSettingsList.isNotEmpty && jsonDecode(provider.viewSettingsList[0])[3][key] != null && selectedPayload.contains(key) && provider.cCList.contains(deviceId);
      }
      return false;
    }
  }

  Widget _buildTankConfig(String payload, PreferenceProvider prefProvider) {
    final values = payload.split(',');
    final groups = List.generate(
      (values.length / 9).ceil(),
          (i) => values.skip(i * 9).take(9).toList(),
    );
    final titles = [
      "Number of sump pins",
      "Sump low pin",
      "Sump high pin",
      "Number of tank pins",
      "Tank low pin",
      "Tank high pin",
      "Level on off",
      "Flow on off",
      "Pressure on off"
    ];
    final pumpNames = prefProvider.commonPumpSettings!.length > 1 ? prefProvider.individualPumpSetting!.where((e) =>
    e.deviceId == prefProvider.commonPumpSettings![context.read<PreferenceProvider>().selectedTabIndex].deviceId)
        .map((e) => e.name).toList() : prefProvider.individualPumpSetting!.map((e) => e.name).toList();

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 50,
              runAlignment: WrapAlignment.spaceBetween,
              children: [
                for(int i = 0; i < pumpNames.length; i++)
                  SizedBox(
                    width: MediaQuery.of(context).size.width <= 500 ? MediaQuery.of(context).size.width : 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IntrinsicWidth(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            height: 25,
                            decoration: BoxDecoration(
                              // gradient: AppProperties.linearGradientLeading,
                                color: Theme.of(context).primaryColorLight,
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(3))
                            ),
                            child: Center(
                              child: Text(
                                // '${Provider.of<PreferenceProvider>(context).individualPumpSetting![index].name}',
                                pumpNames[i],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                              ),
                            ),
                          ),
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Theme.of(context).primaryColorLight,
                              width: 0.5,
                            ),
                            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
                          ),
                          margin: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
                          elevation: 4,
                          color: Colors.white,
                          surfaceTintColor: Colors.white,
                          shadowColor: Theme.of(context).primaryColorLight.withAlpha(100),
                          child: Column(
                            children: [
                              ...groups[i].asMap().entries.map(
                                    (entry) => _buildListTile(titles[entry.key].toUpperCase(), entry.value,),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String value,) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            // flex: 1,
            child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonSettingCategory(MqttPayloadProvider provider, deviceId) {
    final prefProvider = context.read<PreferenceProvider>();
    final settings = prefProvider.commonPumpSettings![prefProvider.selectedTabIndex].settingList;
    final calibrationSettings = prefProvider.calibrationSetting!.isNotEmpty ? prefProvider.calibrationSetting![prefProvider.selectedTabIndex].settingList : null;

    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 50,
            runAlignment: WrapAlignment.spaceBetween,
            children: !(_hasPayload('calibration', provider, deviceId)) ? settings.map((setting) {
              if ([206].contains(setting.type) && _hasPayload('ctconfig', provider, deviceId)) {
                final values = widget.isLora
                    ? provider.viewSetting['cM'].first['ctconfig'].split(',')
                    : '${jsonDecode(provider.viewSettingsList[0])[1]['ctconfig']}'.split(',');
                return _buildSettingCard(setting, values);
              } else if ([204].contains(setting.type) && _hasPayload('voltageconfig', provider, deviceId)) {
                final values = widget.isLora
                    ? provider.viewSetting['cM'].first['voltageconfig'].split(',')
                    : '${jsonDecode(provider.viewSettingsList[0])[2]['voltageconfig']}'.split(',');
                return _buildSettingCard(setting, values);
              }
              return Container();
            }).toList() : calibrationSettings != null ? calibrationSettings.map((setting) {
              if ([208, 209, 210].contains(setting.type)) {
                final List<String> values = widget.isLora
                    ? provider.viewSetting['cM'].first['calibration'].split(',')
                    : '${jsonDecode(provider.viewSettingsList[0])[3]['calibration']}'.split(',');
                return _buildSettingCard(
                  setting,
                  setting.type == 208
                      ? values
                      : setting.type == 209
                      ? values.skip(3).toList()
                      : values.skip(6).toList(),
                );
              }
              return Container();
            }).toList() : [Container()],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(SettingList setting, List<String> values) {
    return SizedBox(
      width: MediaQuery.of(context).size.width <= 500 ? MediaQuery.of(context).size.width : 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 25,
              decoration: BoxDecoration(
                // gradient: AppProperties.linearGradientLeading,
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(3))
              ),
              child: Center(
                child: Text(
                  // '${Provider.of<PreferenceProvider>(context).individualPumpSetting![index].name}',
                  setting.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                ),
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColorLight,
                width: 0.5,
              ),
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            margin: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
            elevation: 4,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shadowColor: Theme.of(context).primaryColorLight.withAlpha(100),
            child: Column(
              children: List.generate(
                setting.setting.length, (i) => _buildListTile(setting.setting[i].title, values[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualSettingCategory(MqttPayloadProvider provider, deviceId) {
    final prefProvider = context.read<PreferenceProvider>();
    final pumps = prefProvider.commonPumpSettings!.length > 1 ? prefProvider.individualPumpSetting!.where(
          (e) => e.deviceId == prefProvider.commonPumpSettings![prefProvider.selectedTabIndex].deviceId,
    ).toList() : prefProvider.individualPumpSetting!;

    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 50,
            runAlignment: WrapAlignment.spaceBetween,
            children: pumps.isNotEmpty ? pumps[0].settingList.map((setting) {
              if ([23, 203].contains(setting.type) && _hasPayload('currentconfig', provider, deviceId)) {
                return _buildConfigCard(provider, setting, pumps, 'currentconfig');
              }
              if ([22, 202].contains(setting.type) && (_hasPayload('rtcconfig', provider, deviceId) || _hasPayload('delayconfig', provider, deviceId))) {
                return _hasPayload('rtcconfig', provider, deviceId)
                    ? _buildRTCConfigCard(provider, setting, pumps)
                    : _buildDelayConfigCard(provider, setting, pumps);
              }
              if ([25, 205].contains(setting.type) && _hasPayload('scheduleconfig', provider, deviceId)) {
                return _buildConfigCard(provider, setting, pumps, 'scheduleconfig');
              }
              return Container();
            }).toList() : [],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard(MqttPayloadProvider provider, dynamic setting, List pumps, String configType) {
    final values = _getConfigValues(provider, configType);
    final pumpName = _getPumpName(pumps, configType);
    return _buildSettingCardWithTitle(pumpName, setting, values, offset: widget.isLora ? 1 : 0);
  }

  Widget _buildRTCConfigCard(MqttPayloadProvider provider, dynamic setting, List pumps) {
    final rtcValues = _getConfigValues(provider, 'rtcconfig');
    final pumpName = _getPumpName(pumps, 'rtcconfig');

    return SizedBox(
      width: MediaQuery.of(context).size.width <= 500 ? MediaQuery.of(context).size.width : 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 25,
              decoration: BoxDecoration(
                // gradient: AppProperties.linearGradientLeading,
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(3))
              ),
              child: Center(
                child: Text(
                  // '${Provider.of<PreferenceProvider>(context).individualPumpSetting![index].name}',
                  pumpName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                ),
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColorLight,
                width: 0.5,
              ),
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            margin: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
            elevation: 4,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shadowColor: Theme.of(context).primaryColorLight.withAlpha(100),
            child: Column(
              children: [
                _buildListTile(setting.setting[11].title, widget.isLora ? rtcValues[1] : rtcValues[0]),
                _buildRTCTable(setting, rtcValues),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDelayConfigCard(MqttPayloadProvider provider, dynamic setting, List pumps) {
    final delayValues = _getConfigValues(provider, 'delayconfig');
    final pumpName = _getPumpName(pumps, 'delayconfig');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 25,
            decoration: BoxDecoration(
              // gradient: AppProperties.linearGradientLeading,
                color: Theme.of(context).primaryColorLight,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(3))
            ),
            child: Center(
              child: Text(
                // '${Provider.of<PreferenceProvider>(context).individualPumpSetting![index].name}',
                pumpName,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
              ),
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).primaryColorLight,
              width: 0.5,
            ),
            borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          margin: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
          elevation: 4,
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shadowColor: Theme.of(context).primaryColorLight.withAlpha(100),
          child: Column(
            children: [
              ...List.generate(setting.setting.length, (i) {
                return (i == 11 || i == 12) ? Container() : _buildListTile(setting.setting[i].title, widget.isLora ? delayValues[i + 1] : delayValues[i]);
              }),
            ],
          ),
        )
      ],
    );
  }

  List<String> _getConfigValues(MqttPayloadProvider provider, String configType) {
    return widget.isLora
        ? provider.viewSetting['cM'].first[configType].split(',')
        : jsonDecode(provider.viewSettingsList[_getPayloadIndex(configType)])[_getConfigTypeIndex(configType)][configType].split(',');
  }

  int _getConfigTypeIndex(String configType) {
    switch(configType) {
      case 'currentconfig':
        return 3;
      case 'rtcconfig':
        return 2;
      case 'delayconfig':
        return 1;
      case 'scheduleconfig':
        return 4;
      default:
        return 0;
    }
  }

  int _getPayloadIndex(String configType) {
    return selectedPayload.contains('${configType}2') ? 2 :
    selectedPayload.contains('${configType}3') ? 3 : 1;
  }

  String _getPumpName(List pumps, String configType) {
    int index = _getPayloadIndex(configType) - 1;
    return (pumps.length > index) ? pumps[index].name : 'Not Configured';
  }

  Widget _buildRTCTable(dynamic setting, List<String> rtcValues) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      children: [
        TableRow(children: [
          Center(child: Text('RTC', style: Theme.of(context).textTheme.bodyLarge)),
          Center(child: Text('On Time', style: Theme.of(context).textTheme.bodyLarge)),
          Center(child: Text('Off Time', style: Theme.of(context).textTheme.bodyLarge)),
        ]),
        const TableRow(children: [
          SizedBox(height: 20),
          SizedBox(height: 20),
          SizedBox(height: 20),
        ]),
        if (setting.setting[12].rtcSettings != null)
          ...setting.setting[12].rtcSettings!.asMap().entries.map((entry) {
            final idx = entry.key;
            final timeValues = extractValues(idx, rtcValues.skip(widget.isLora ? 2 : 1).toList());
            return TableRow(
              children: [
                Center(child: Text('${idx + 1}', style: Theme.of(context).textTheme.bodyLarge)),
                Center(child: Text(timeValues[0], style: Theme.of(context).textTheme.bodyLarge)),
                Center(child: Text(timeValues[1], style: Theme.of(context).textTheme.bodyLarge)),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildSettingCardWithTitle(String title, setting, List<String> values,
      {int offset = 0}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width <= 500 ? MediaQuery.of(context).size.width : 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 25,
              decoration: BoxDecoration(
                // gradient: AppProperties.linearGradientLeading,
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(3))
              ),
              child: Center(
                child: Text(
                  // '${Provider.of<PreferenceProvider>(context).individualPumpSetting![index].name}',
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                ),
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColorLight,
                width: 0.5,
              ),
              borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            margin: const EdgeInsets.only(left: 0, right: 0, bottom: 15),
            elevation: 4,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shadowColor: Theme.of(context).primaryColorLight.withAlpha(100),
            child: Column(
              children: [
                ...List.generate(
                  setting.setting.length, (i) => _buildListTile(setting.setting[i].title, values[i + offset]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<String> extractValues(int index, List<String> values) {
    final start = index * 2;
    return values.sublist(start, start + 2);
  }

}