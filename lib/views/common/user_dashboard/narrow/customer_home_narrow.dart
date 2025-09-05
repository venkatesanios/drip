import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/customer/site_model.dart';
import '../../../../StateManagement/mqtt_payload_provider.dart';
import '../../../../Widgets/pump_widget.dart';
import '../../../../providers/user_provider.dart';
import '../../../../services/communication_service.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/my_function.dart';
import '../../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../../customer/customer_home.dart';
import '../../../customer/home_sub_classes/current_program.dart';
import '../../../customer/home_sub_classes/fertilizer_site.dart';
import '../../../customer/home_sub_classes/filter_site.dart';
import '../../../customer/home_sub_classes/next_schedule.dart';

class CustomerDashboardNarrow extends StatelessWidget {
  const CustomerDashboardNarrow({super.key});


  @override
  Widget build(BuildContext context) {

    final viewedCustomer = context.read<UserProvider>().viewedCustomer;

    final viewModel = Provider.of<CustomerScreenControllerViewModel>(context);

    final int controllerId = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].controllerId;
    final int modelId = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].modelId;
    final String deviceId = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId;

    final irrigationLines = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].irrigationLine;
    final scheduledProgram = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].programList;

    final linesToDisplay = (viewModel.myCurrentIrrLine == "All irrigation line" || viewModel.myCurrentIrrLine.isEmpty)
        ? irrigationLines.where((line) => line.name != viewModel.myCurrentIrrLine).toList()
        : irrigationLines.where((line) => line.name == viewModel.myCurrentIrrLine).toList();

    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            context.watch<MqttPayloadProvider>().onRefresh ? displayLinearProgressIndicator() : const SizedBox(),
            CurrentProgram(
              scheduledPrograms: scheduledProgram,
              deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,
              customerId: viewedCustomer!.id,
              controllerId: controllerId,
              currentLineSNo: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].irrigationLine[viewModel.lIndex].sNo,
              modelId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].modelId,
            ),
            NextSchedule(scheduledPrograms: scheduledProgram),

            ...linesToDisplay.map((line) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, right: 8),

              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: 45,
                          color: Colors.white70,
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Text(
                                'Pump Station of ${line.name}',
                                textAlign: TextAlign.left,
                                style: const TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        buildPumpStation(context, line, viewedCustomer.id, controllerId, modelId, deviceId)
                      ],
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    elevation: 1,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: 45,
                          color: Colors.white70,
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Text(
                                line.name,
                                textAlign: TextAlign.left,
                                style: const TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              MaterialButton(
                                color: line.linePauseFlag == 0
                                    ? Theme.of(context).primaryColorLight
                                    : Colors.orange.shade400,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                onPressed: () async {
                                  String payLoadFinal = jsonEncode({
                                    "4900": {
                                      "4901": "${line.sNo}, ${line.linePauseFlag == 0 ? 1 : 0}",
                                    }
                                  });

                                  final result = await context.read<CommunicationService>().sendCommand(
                                    payload: payLoadFinal,
                                    serverMsg: line.linePauseFlag == 0
                                        ? 'Paused the ${line.name}'
                                        : 'Resumed the ${line.name}',
                                  );

                                  if (result['http'] == true) debugPrint("Payload sent to Server");
                                  if (result['mqtt'] == true) debugPrint("Payload sent to MQTT Box");
                                  if (result['bluetooth'] == true) debugPrint("Payload sent via Bluetooth");
                                },
                                child: Text(
                                  line.linePauseFlag == 0 ? 'PAUSE THE LINE' : 'RESUME THE LINE',
                                  style: const TextStyle(
                                    color:Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5)
                            ],
                          ),
                        ),
                        buildIrrigationLineNew(context, line, viewedCustomer.id, controllerId, modelId, deviceId)
                      ],
                    ),
                  ),
                ],
              ),

              /*child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    width: 0.5,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 45,
                      color: Colors.white70,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Text(
                            line.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          MaterialButton(
                            color: line.linePauseFlag == 0
                                ? Theme.of(context).primaryColorLight
                                : Colors.orange.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            onPressed: () async {
                              String payLoadFinal = jsonEncode({
                                "4900": {
                                  "4901": "${line.sNo}, ${line.linePauseFlag == 0 ? 1 : 0}",
                                }
                              });

                              final result = await context.read<CommunicationService>().sendCommand(
                                payload: payLoadFinal,
                                serverMsg: line.linePauseFlag == 0
                                    ? 'Paused the ${line.name}'
                                    : 'Resumed the ${line.name}',
                              );

                              if (result['http'] == true) debugPrint("Payload sent to Server");
                              if (result['mqtt'] == true) debugPrint("Payload sent to MQTT Box");
                              if (result['bluetooth'] == true) debugPrint("Payload sent via Bluetooth");
                            },
                            child: Text(
                              line.linePauseFlag == 0 ? 'PAUSE THE LINE' : 'RESUME THE LINE',
                              style: const TextStyle(
                                color:Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5)
                        ],
                      ),
                    ),
                    buildIrrigationLine(context, line, viewedCustomer.id, controllerId, modelId, deviceId),
                  ],
                ),
              ),*/
            )),

            /*...linesToDisplay.map((line) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    width: 0.5,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 45,
                      color: Colors.white70,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Text(
                            line.name,
                            textAlign: TextAlign.left,
                            style: const TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          MaterialButton(
                            color: line.linePauseFlag == 0
                                ? Theme.of(context).primaryColorLight
                                : Colors.orange.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            onPressed: () async {
                              String payLoadFinal = jsonEncode({
                                "4900": {
                                  "4901": "${line.sNo}, ${line.linePauseFlag == 0 ? 1 : 0}",
                                }
                              });

                              final result = await context.read<CommunicationService>().sendCommand(
                                payload: payLoadFinal,
                                serverMsg: line.linePauseFlag == 0
                                    ? 'Paused the ${line.name}'
                                    : 'Resumed the ${line.name}',
                              );

                              if (result['http'] == true) debugPrint("Payload sent to Server");
                              if (result['mqtt'] == true) debugPrint("Payload sent to MQTT Box");
                              if (result['bluetooth'] == true) debugPrint("Payload sent via Bluetooth");
                            },
                            child: Text(
                              line.linePauseFlag == 0 ? 'PAUSE THE LINE' : 'RESUME THE LINE',
                              style: const TextStyle(
                                color:Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5)
                        ],
                      ),
                    ),
                    buildIrrigationLine(context, line, viewedCustomer.id, controllerId, modelId, deviceId),
                  ],
                ),
              ),
            )),*/

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget displayLinearProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 3, right: 3),
      child: LinearProgressIndicator(
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        backgroundColor: Colors.grey[200],
        minHeight: 4,
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  Widget buildPumpStation(BuildContext context, IrrigationLineModel irrLine, int customerId, int controllerId, int modelId, String deviceId) {

    final inletWaterSources = {
      for (var source in irrLine.inletSources) source.sNo: source
    }.values.toList();

    final outletWaterSources = {
      for (var source in irrLine.outletSources) source.sNo: source
    }.values.toList();

    final filterSite = {
      if (irrLine.centralFilterSite != null) irrLine.centralFilterSite!.sNo : irrLine.centralFilterSite!
    }.values.toList();

    final fertilizerSite = {
      if (irrLine.centralFertilizerSite != null) irrLine.centralFertilizerSite!.sNo : irrLine.centralFertilizerSite!
    }.values.toList();

    return PumpStation(
      inletWaterSources: inletWaterSources,
      outletWaterSources: outletWaterSources,
      filterSite: filterSite,
      fertilizerSite: fertilizerSite,
      prsSwitch: irrLine.prsSwitch,
      customerId: customerId,
      controllerId: controllerId,
      deviceId: deviceId,
      modelId: modelId,
    );

  }

  Widget buildIrrigationLineNew(BuildContext context, IrrigationLineModel irrLine, int customerId, int controllerId, int modelId, String deviceId){

    return IrrigationLine(
      valves: irrLine.valveObjects,
      mainValves: irrLine.mainValveObjects,
      lights:irrLine.lightObjects,
      gates:irrLine.gateObjects,
      pressureIn: irrLine.pressureIn,
      pressureOut: irrLine.pressureOut,
      waterMeter: irrLine.waterMeter,
      customerId: customerId,
      controllerId: controllerId,
      deviceId: deviceId,
      modelId: modelId,
    );

  }

  Widget buildIrrigationLine(BuildContext context, IrrigationLineModel irrLine, int customerId, int controllerId, int modelId, String deviceId){

    final inletWaterSources = {
      for (var source in irrLine.inletSources) source.sNo: source
    }.values.toList();

    final outletWaterSources = {
      for (var source in irrLine.outletSources) source.sNo: source
    }.values.toList();

    final filterSite = {
      if (irrLine.centralFilterSite != null) irrLine.centralFilterSite!.sNo : irrLine.centralFilterSite!
    }.values.toList();

    final fertilizerSite = {
      if (irrLine.centralFertilizerSite != null) irrLine.centralFertilizerSite!.sNo : irrLine.centralFertilizerSite!
    }.values.toList();

    return PumpStationWithLine(
      inletWaterSources: inletWaterSources,
      outletWaterSources: outletWaterSources,
      filterSite: filterSite,
      fertilizerSite: fertilizerSite,
      valves: irrLine.valveObjects,
      mainValves: irrLine.mainValveObjects,
      lights:irrLine.lightObjects,
      gates:irrLine.gateObjects,
      prsSwitch: irrLine.prsSwitch,
      pressureIn: irrLine.pressureIn,
      pressureOut: irrLine.pressureOut,
      waterMeter: irrLine.waterMeter,
      customerId: customerId,
      controllerId: controllerId,
      containerWidth: MediaQuery.sizeOf(context).width,
      deviceId: deviceId,
      modelId: modelId,
    );

  }
}

class PumpStation extends StatelessWidget {
  final int customerId, controllerId, modelId;
  final String deviceId;
  final List<WaterSourceModel> inletWaterSources;
  final List<WaterSourceModel> outletWaterSources;
  final List<FilterSiteModel> filterSite;
  final List<FertilizerSiteModel> fertilizerSite;
  final List<SensorModel> prsSwitch;

  const PumpStation({
    super.key,
    required this.inletWaterSources,
    required this.outletWaterSources,
    required this.filterSite,
    required this.fertilizerSite,
    required this.prsSwitch,
    required this.customerId,
    required this.controllerId,
    required this.deviceId,
    required this.modelId,
  });

  @override
  Widget build(BuildContext context) {

    final baseSensors = [
      ..._buildSensorItems(prsSwitch, 'Pressure Switch', 'assets/png/pressure_switch_wj.png', false),
    ];

    final wsAndFilterItems = [
      if (inletWaterSources.isNotEmpty)
        ..._buildWaterSource(context, inletWaterSources, true, true, false),
      if (outletWaterSources.isNotEmpty)
        ..._buildWaterSource(context, outletWaterSources, inletWaterSources.isNotEmpty, false, false),
      if (filterSite.isNotEmpty)
        ..._buildFilter(context, filterSite, false),
    ];

    final fertilizerItems = fertilizerSite.isNotEmpty
        ? _buildFertilizer(context, fertilizerSite).cast<Widget>()
        : <Widget>[];

    final allItemsWithoutValves = [
      ...baseSensors,
    ];

    final allItems = [
      ...allItemsWithoutValves,
    ];

    if (fertilizerSite.isEmpty) {
      return Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 0,
          runSpacing: 0,
          children: [
            ...wsAndFilterItems,
            ...allItems,
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 0,
              runSpacing: 0,
              children: wsAndFilterItems,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 0,
              runSpacing: 0,
              children: fertilizerItems,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 0,
              runSpacing: 0,
              children: allItems,
            ),
          ),
        ],
      );
    }
  }

  List<Widget> _buildWaterSource(BuildContext context, List<WaterSourceModel> waterSources,
      bool isAvailInlet, bool isInlet, bool isAvailFertilizer) {
    final List<Widget> gridItems = [];
    for (int index = 0; index < waterSources.length; index++) {
      final source = waterSources[index];
      gridItems.add(Padding(
        padding: EdgeInsets.only(top: isAvailFertilizer? 38.5:8),
        child: _buildSourceColumn(context, source, index, waterSources.length, isAvailInlet, isInlet),
      ));
      gridItems.addAll(source.outletPump.map((pump) => Padding(
        padding: EdgeInsets.only(top: isAvailFertilizer? 38.5:8),
        child: PumpWidget(
          pump: pump,
          isSourcePump: isInlet,
          deviceId: deviceId,
          customerId: customerId,
          controllerId: controllerId,
          isMobile: false,
          modelId: modelId,
        ),
      )));
    }
    return gridItems;
  }

  Widget _buildSourceColumn(BuildContext context, WaterSourceModel source,
      int index, int total, bool isAvailInlet, bool isInletSource) {

    String position = isInletSource ? (index == 0) ? 'First' : 'Center':
    (index == 0 && isAvailInlet) ? 'Last' : (index == 0 && !isAvailInlet)? 'First':
    (index == total - 1)? 'Last' : 'Center';

    final bool hasLevel = source.level.isNotEmpty;

    return SizedBox(
      width: 70,
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AppConstants.getAsset('source', source.sourceType, position),
                ),
                if (hasLevel) ...[
                  Positioned(
                    top: 50,
                    left: 2,
                    right: 2,
                    child: Consumer<MqttPayloadProvider>(
                      builder: (_, provider, __) {
                        final sensorUpdate = provider.getSensorUpdatedValve(source.level[0].sNo.toString());
                        final statusParts = sensorUpdate?.split(',') ?? [];

                        if (statusParts.length > 1) {
                          source.level.first.value = statusParts[1];
                        }

                        return Container(
                          height: 17,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.grey, width: 0.5),
                          ),
                          child: Center(
                            child: Text(
                              MyFunction().getUnitByParameter(context, 'Level Sensor', source.level.first.value.toString()) ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 33,
                    left: 18,
                    right: 18,
                    child: Consumer<MqttPayloadProvider>(
                      builder: (_, provider, __) {
                        final sensorUpdate = provider.getSensorUpdatedValve(source.level[0].sNo.toString());
                        final statusParts = sensorUpdate?.split(',') ?? [];

                        if (statusParts.length > 2) {
                          source.level.first.value = statusParts[2];
                        }

                        return Container(
                          height: 17,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey, width: 0.5),
                          ),
                          child: Center(
                            child: Text(
                              '${source.level.first.value}%',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );

                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            source.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSensorItems(List<SensorModel> sensors, String type, String imagePath, bool isAvailFertilizer) {
    return sensors.map((sensor) {
      return Padding(
        padding: EdgeInsets.only(top: isAvailFertilizer? 30 : 0),
        child: SensorWidgetMobile(
          sensor: sensor,
          sensorType: type,
          imagePath: imagePath,
          customerId: customerId,
          controllerId: controllerId,
        ),
      );
    }).toList();
  }

  List<Widget> _buildFilter(BuildContext context, List<FilterSiteModel> filterSite, bool isFertAvail) {
    return filterSite.expand((site) => [
      if (site.pressureIn != null)
        Padding(
          padding: EdgeInsets.only(top: isFertAvail? 38.5:8),
          child: PressureSensorWidget(sensor: site.pressureIn!),
        ),
      ...site.filters.map((filter) => Padding(
        padding: EdgeInsets.only(top: isFertAvail? 38.5:8),
        child: FilterWidget(filter: filter, siteSno: filter.sNo.toString()),
      )),
      if (site.pressureOut != null)
        Padding(
          padding: EdgeInsets.only(top: isFertAvail? 38.5:8),
          child: PressureSensorWidget(sensor: site.pressureOut!),
        ),
    ]).toList();
  }

  List<Widget> _buildFertilizer(BuildContext context, List<FertilizerSiteModel> fertilizerSite) {
    return List.generate(fertilizerSite.length, (siteIndex) {
      final site = fertilizerSite[siteIndex];
      final widgets = <Widget>[];

      if (siteIndex != 0) {
        widgets.add(SizedBox(
          width: 4.5,
          height: 120,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 42),
                child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
              ),
              const SizedBox(width: 4.5,),
              Padding(
                padding: const EdgeInsets.only(top: 45),
                child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
              ),
            ],
          ),
        ));
      }
      widgets.add(BoosterWidget(fertilizerSite: site));

      for (int channelIndex = 0; channelIndex < site.channel.length; channelIndex++) {
        final channel = site.channel[channelIndex];
        widgets.add(ChannelWidget(
          channel: channel,
          cIndex: channelIndex,
          channelLength: site.channel.length,
          agitator: site.agitator,
          siteSno: site.sNo.toString(),
        ));

        final isLast = channelIndex == site.channel.length - 1;

        if(isLast && site.agitator.isNotEmpty){
          widgets.add(AgitatorWidget(
            fertilizerSite: site,
          ));
        }
      }
      return widgets;
    }).expand((item) => item).toList().cast<Widget>();
  }

}

class IrrigationLine extends StatelessWidget {
  final int customerId, controllerId, modelId;
  final String deviceId;
  final List<ValveModel> valves;
  final List<ValveModel> mainValves;
  final List<LightModel> lights;
  final List<GateModel> gates;
  final List<SensorModel> pressureIn;
  final List<SensorModel> pressureOut;
  final List<SensorModel> waterMeter;

  const IrrigationLine({
    super.key,
    required this.valves,
    required this.mainValves,
    required this.lights,
    required this.gates,
    required this.pressureIn,
    required this.pressureOut,
    required this.waterMeter,
    required this.customerId,
    required this.controllerId,
    required this.deviceId,
    required this.modelId,
  });

  @override
  Widget build(BuildContext context) {

    double myDouble = MediaQuery.sizeOf(context).width / 75;
    int itemsPerRow = myDouble.toInt();

    final valveWidgetEntries = valves.asMap().entries.toList();
    final mainValveWidgetEntries = mainValves.asMap().entries.toList();

    final baseSensors = [
      ..._buildSensorItems(pressureIn, 'Pressure Sensor', 'assets/png/pressure_sensor.png'),
      ..._buildSensorItems(waterMeter, 'Water Meter', 'assets/png/water_meter_wj.png'),
    ];

    final allItemsWithoutValves = [
      ...baseSensors,
    ];

    final valveWidgets = valveWidgetEntries.map((entry) {
      final index = entry.key;
      final valve = entry.value;
      final totalOffset = allItemsWithoutValves.length;
      final globalIndex = totalOffset + index;

      final isLastValveInRow = (globalIndex + 1) % itemsPerRow == 0;
      final isLastValve = index == valveWidgetEntries.length - 1;

      return ValveWidgetMobile(
        valve: valve,
        customerId: customerId,
        controllerId: controllerId,
        isLastValve: isLastValve? isLastValve && pressureOut.isEmpty:
        isLastValveInRow && pressureOut.isEmpty,
        modelId: modelId,
      );
    }).toList();

    final mainValveWidgets = mainValveWidgetEntries.map((entry) {
      final valve = entry.value;
      return MainValveWidget(
        valve: valve,
        customerId: customerId,
        controllerId: controllerId,
        modelId: modelId,
      );
    }).toList();

    final pressureOutWidgets = _buildSensorItems(
      pressureOut, 'Pressure Sensor', 'assets/png/pressure_sensor.png',
    );

    final allItems = [
      ...allItemsWithoutValves,
      ...mainValveWidgets,
      ...valveWidgets,
      ...pressureOutWidgets,
    ];

    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 0,
            runSpacing: 0,
            children: allItems,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSensorItems(List<SensorModel> sensors, String type, String imagePath) {
    return sensors.map((sensor) {
      return SizedBox(
        width: 70,
        height: 50,
        child: SensorWidgetMobile(
          sensor: sensor,
          sensorType: type,
          imagePath: imagePath,
          customerId: customerId,
          controllerId: controllerId,
        ),
      );
    }).toList();
  }

}
