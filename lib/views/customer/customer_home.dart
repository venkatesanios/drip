import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/views/customer/home_sub_classes/current_program.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../Models/customer/sensor_hourly_data_model.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../Widgets/pump_widget.dart';
import '../../repository/repository.dart';
import '../../services/communication_service.dart';
import '../../services/http_service.dart';
import '../../utils/constants.dart';
import '../../utils/my_function.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import 'home_sub_classes/fertilizer_site.dart';
import 'home_sub_classes/filter_site.dart';
import 'home_sub_classes/next_schedule.dart';
import 'home_sub_classes/scheduled_program.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key, required this.customerId, required this.controllerId,
    required this.deviceId});
  final int customerId, controllerId;
  final String deviceId;

  @override
  Widget build(BuildContext context) {

    final viewModel = context.read<CustomerScreenControllerViewModel>();

    final irrigationLines = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].irrigationLine;
    final scheduledProgram = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].programList;

    final linesToDisplay = (viewModel.myCurrentIrrLine == "All irrigation line" || viewModel.myCurrentIrrLine.isEmpty)
        ? irrigationLines.where((line) => line.name != viewModel.myCurrentIrrLine).toList()
        : irrigationLines.where((line) => line.name == viewModel.myCurrentIrrLine).toList();

    return kIsWeb ? _buildWebLayout(context, linesToDisplay, scheduledProgram, viewModel):
    _buildMobileLayout(context, linesToDisplay, scheduledProgram);
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

  Widget _buildWebLayout(BuildContext context, List<IrrigationLineModel> irrigationLine,
      scheduledProgram, CustomerScreenControllerViewModel viewModel) {

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          context.watch<MqttPayloadProvider>().onRefresh ? displayLinearProgressIndicator() : const SizedBox(),

          ...irrigationLine.map((line) => Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top:8, bottom: 5),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 0.5,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width,
                    height: 40,
                    child: Card(
                      color: Colors.white,
                      elevation: 1.2,
                      surfaceTintColor: Colors.white,
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
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
                            color: line.linePauseFlag==0? Colors.amber : Colors.green,
                            textColor: Colors.black87,
                            onPressed: () async {
                              String payLoadFinal = jsonEncode({
                                "4900": {
                                  "4901": "${line.sNo}, ${line.linePauseFlag==0?1:0}",
                                }
                              });
                              final result = await context.read<CommunicationService>().sendCommand(payload: payLoadFinal,
                                  serverMsg: line.linePauseFlag==0 ? 'Paused the ${line.name}' : 'Resumed the ${line.name}');
                              if (result['http'] == true) {
                                debugPrint("Payload sent to Server");
                              }
                              if (result['mqtt'] == true) {
                                debugPrint("Payload sent to MQTT Box");
                              }
                              if (result['bluetooth'] == true) {
                                debugPrint("Payload sent via Bluetooth");
                              }
                            },
                            child: Text(
                              line.linePauseFlag==0?'PAUSE THE LINE':
                              'RESUME THE LINE',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                          const SizedBox(width: 10)
                        ],
                      ),
                    ),
                  ),
                  buildIrrigationLine(context, line, customerId, controllerId),
                ],
              ),
            ),
          )),

          CurrentProgram(
            scheduledPrograms: scheduledProgram,
            deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,
            customerId: customerId,
            controllerId: controllerId,
            currentLineSNo: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].irrigationLine[viewModel.lIndex].sNo,
          ),
          if (scheduledProgram.isNotEmpty)
            NextSchedule(scheduledPrograms: scheduledProgram),

          if (scheduledProgram.isNotEmpty)
            ScheduledProgram(
              userId: customerId,
              scheduledPrograms: scheduledProgram,
              controllerId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].controllerId,
              deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,
              customerId: customerId,
              currentLineSNo: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].irrigationLine[viewModel.lIndex].sNo,
              groupId: viewModel.mySiteList.data[viewModel.sIndex].groupId,
              categoryId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].categoryId,
              modelId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].modelId,
              deviceName: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceName,
              categoryName: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].categoryName,
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, List<IrrigationLineModel> irrigationLine, scheduledProgram) {

    final viewModel = context.read<CustomerScreenControllerViewModel>();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          context.watch<MqttPayloadProvider>().onRefresh ? displayLinearProgressIndicator() : const SizedBox(),
          CurrentProgram(
            scheduledPrograms: scheduledProgram,
            deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,
            customerId: customerId,
            controllerId: controllerId,
            currentLineSNo: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].irrigationLine[viewModel.lIndex].sNo,
          ),
          NextSchedule(scheduledPrograms: scheduledProgram),
          ...irrigationLine.map((line) => Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 0.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 47,
                        child: Card(
                          color: Colors.white,
                          elevation: 1.2,
                          surfaceTintColor: Colors.white,
                          margin: EdgeInsets.zero,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                          ),
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
                                color: line.linePauseFlag==0? Colors.amber : Colors.green,
                                textColor: Colors.black54,
                                onPressed: () async {
                                  String payLoadFinal = jsonEncode({
                                    "4900": {
                                      "4901": "${line.sNo}, ${line.linePauseFlag==0?1:0}",
                                    }
                                  });
                                  final result = await context.read<CommunicationService>().sendCommand(payload: payLoadFinal,
                                      serverMsg: line.linePauseFlag==0 ? 'Paused the ${line.name}' : 'Resumed the ${line.name}');
                                  if (result['http'] == true) {
                                    debugPrint("Payload sent to Server");
                                  }
                                  if (result['mqtt'] == true) {
                                    debugPrint("Payload sent to MQTT Box");
                                  }
                                  if (result['bluetooth'] == true) {
                                    debugPrint("Payload sent via Bluetooth");
                                  }
                                },
                                child: Text(
                                  line.linePauseFlag==0?'PAUSE THE LINE':
                                  'RESUME THE LINE',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ),
                              const SizedBox(width: 5)
                            ],
                          ),
                        ),
                      ),
                      buildIrrigationLine(context, line, customerId, controllerId),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget buildIrrigationLine(BuildContext context, IrrigationLineModel irrLine, int customerId, int controllerId){

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
      prsSwitch: irrLine.prsSwitch,
      pressureIn: irrLine.pressureIn,
      pressureOut: irrLine.pressureOut,
      waterMeter: irrLine.waterMeter,
      customerId: customerId,
      controllerId: controllerId,
      containerWidth: MediaQuery.sizeOf(context).width,
      isMobile: false,
      deviceId: deviceId,
    );

    int totalInletPumps = inletWaterSources.fold(0, (sum, source) => sum + source.outletPump.length);
    int totalOutletPumps = outletWaterSources.fold(0, (sum, source) => sum + source.outletPump.length);

    int totalFilters = filterSite.fold(0, (sum, site) => sum + (site.filters.length));
    int totalPressureIn = filterSite.fold(0, (sum, site) => sum + (site.pressureIn!=null ? 1 : 0));
    int totalPressureOut = filterSite.fold(0, (sum, site) => sum + (site.pressureOut!=null ? 1 : 0));

    int totalBoosterPump = fertilizerSite.fold(0, (sum, site) => sum + (site.boosterPump.length));
    int totalChannels = fertilizerSite.fold(0, (sum, site) => sum + (site.channel.length));
    int totalAgitators = fertilizerSite.fold(0, (sum, site) => sum + (site.agitator.length));

    int grandTotal = inletWaterSources.length + outletWaterSources.length +
        totalInletPumps + totalOutletPumps + totalFilters + totalPressureIn +
        totalPressureOut + totalBoosterPump + totalChannels + totalAgitators;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        /*SizedBox(
            width: (grandTotal*70) + 20,
            child: PumpStationWidget(waterSources: waterSources, filterSite: filterSite, fertilizerSite: fertilizerSite, isLineRight: true,
              deviceId: deviceId, customerId: customerId, controllerId: controllerId, isMobile: false,)
        ),*/
        /*LineObjects(
          valves: irrLine.valveObjects,
          prsSwitch: irrLine.prsSwitch,
          pressureIn: irrLine.pressureIn,
          waterMeter: irrLine.waterMeter,
          customerId: customerId,
          controllerId: controllerId,
          containerWidth: 1000,
          isMobile: false,
          pressureOut: irrLine.pressureOut,
        ),*/
      ],
    );
  }

}

class PumpStationWithLine extends StatelessWidget {
  final int customerId, controllerId;
  final String deviceId;
  final List<WaterSourceModel> inletWaterSources;
  final List<WaterSourceModel> outletWaterSources;
  final List<FilterSiteModel> filterSite;
  final List<FertilizerSiteModel> fertilizerSite;
  final List<ValveModel> valves;
  final List<SensorModel> prsSwitch;
  final List<SensorModel> pressureIn;
  final List<SensorModel> pressureOut;
  final List<SensorModel> waterMeter;
  final double containerWidth;
  final bool isMobile;

  const PumpStationWithLine({
    super.key,
    required this.inletWaterSources,
    required this.outletWaterSources,
    required this.filterSite,
    required this.fertilizerSite,
    required this.valves,
    required this.prsSwitch,
    required this.pressureIn,
    required this.pressureOut,
    required this.waterMeter,
    required this.customerId,
    required this.controllerId,
    required this.deviceId,
    required this.containerWidth,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {

    if(kIsWeb)
    {
      final valveWidgets = valves.asMap().entries.map((entry) {
        final index = entry.key;
        final valve = entry.value;
        final isLastValve = index == valves.length - 1;
        return ValveWidget(
          valve: valve,
          customerId: customerId,
          controllerId: controllerId,
          isLastValve: isLastValve && pressureOut.isEmpty,
        );
      }).toList();

      final allItems = [
        if (inletWaterSources.isNotEmpty)
          ..._buildWaterSource(context, inletWaterSources, true, true,fertilizerSite.isNotEmpty? true:false),

        if (outletWaterSources.isNotEmpty)
          ..._buildWaterSource(context, outletWaterSources, inletWaterSources.isNotEmpty? true : false, false,fertilizerSite.isNotEmpty?true:false),

        if (filterSite.isNotEmpty)
          ..._buildFilter(context, filterSite, fertilizerSite.isNotEmpty),

        if (fertilizerSite.isNotEmpty)
          ..._buildFertilizer(context, fertilizerSite),
          ..._buildSensorItems(prsSwitch, 'Pressure Switch', 'assets/png/pressure_switch_wj.png', fertilizerSite.isNotEmpty),
          ..._buildSensorItems(pressureIn, 'Pressure Sensor', 'assets/png/pressure_sensor_wj.png', fertilizerSite.isNotEmpty),
          ..._buildSensorItems(waterMeter, 'Water Meter', 'assets/png/water_meter_wj.png', fertilizerSite.isNotEmpty),
          ...valveWidgets,
          ..._buildSensorItems(pressureOut, 'Pressure Sensor', 'assets/png/pressure_sensor_wjl.png', fertilizerSite.isNotEmpty),
      ];

      return Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 0,
          runSpacing: 0,
          children: allItems.asMap().entries.map<Widget>((entry) {
            final index = entry.key;
            final item = entry.value;
            if(fertilizerSite.isNotEmpty){
              int itemsPerRow = ((MediaQuery.sizeOf(context).width - 140) / 67).floor();

              if (item is ValveWidget && index < itemsPerRow) {
                return Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: item,
                );
              }
              else{
                return item;
              }
            }
            else{
              return item;
            }

          }).toList(),
        ),
      );
    }
    else{

      if(fertilizerSite.isEmpty){

        double myDouble = MediaQuery.sizeOf(context).width / 75;
        int itemsPerRow = myDouble.toInt();

        final valveWidgetEntries = valves.asMap().entries.toList();

        final allItemsWithoutValves = [
          if (inletWaterSources.isNotEmpty)
            ..._buildWaterSource(context, inletWaterSources, true, true, false),
          if (outletWaterSources.isNotEmpty)
            ..._buildWaterSource(context, outletWaterSources, inletWaterSources.isNotEmpty, false, false),
          if (filterSite.isNotEmpty)
            ..._buildFilter(context, filterSite, false),
          ..._buildSensorItems(prsSwitch, 'Pressure Switch', 'assets/png/pressure_switch_wj.png', false),
          ..._buildSensorItems(pressureIn, 'Pressure Sensor', 'assets/png/pressure_sensor_wj.png', false),
          ..._buildSensorItems(waterMeter, 'Water Meter', 'assets/png/water_meter_wj.png', false),
        ];

        final valveWidgets = valveWidgetEntries.map((entry) {
          final index = entry.key;
          final valve = entry.value;
          final totalOffset = allItemsWithoutValves.length;
          final globalIndex = totalOffset + index;
          final isLastValveInRow = (globalIndex + 1) % itemsPerRow == 0;

          return ValveWidget(
            valve: valve,
            customerId: customerId,
            controllerId: controllerId,
            isLastValve: isLastValveInRow && pressureOut.isEmpty,
          );
        }).toList();

        final allItems = [
          ...allItemsWithoutValves,
          ...valveWidgets,
          ..._buildSensorItems(pressureOut, 'Pressure Sensor', 'assets/png/pressure_sensor_wj.png', false),
        ];

        return Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 0,
            runSpacing: 0,
            children: allItems,
          ),
        );
      }else{
        final wsAndFilterItems = [
          if (inletWaterSources.isNotEmpty)
            ..._buildWaterSource(context, inletWaterSources, true, true, false),

          if (outletWaterSources.isNotEmpty)
            ..._buildWaterSource(context, outletWaterSources, inletWaterSources.isNotEmpty? true : false, false, false),

          if (filterSite.isNotEmpty)
            ..._buildFilter(context, filterSite, false),
        ];

        final fertilizerItems = [
          ..._buildFertilizer(context, fertilizerSite),
        ];

        final valveWidgets = valves.asMap().entries.map((entry) {
          final index = entry.key;
          final valve = entry.value;
          final isLastValve = index == valves.length - 1;
          return ValveWidget(
            valve: valve,
            customerId: customerId,
            controllerId: controllerId,
            isLastValve : isLastValve && pressureOut.isEmpty,
          );
        }).toList();

        final lineItems = [
          ..._buildSensorItems(prsSwitch, 'Pressure Switch', 'assets/png/pressure_switch_wj.png', false),
          ..._buildSensorItems(pressureIn, 'Pressure Sensor', 'assets/png/pressure_sensor_wj.png', false),
          ..._buildSensorItems(waterMeter, 'Water Meter', 'assets/png/water_meter_wj.png', false),
          ...valveWidgets,
          ..._buildSensorItems(pressureOut, 'Pressure Sensor', 'assets/png/pressure_sensor_wj.png', false),
        ];

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
                children: lineItems,
              ),
            ),
          ],
        );
      }
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
        padding: EdgeInsets.only(top: isAvailFertilizer?30:0),
        child: SensorWidget(
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
      }

      widgets.add(SizedBox(
        width: 4.5,
        height: 130,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 42, bottom: 4.5),
              child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
            ),
            const SizedBox(width: 4.5,),
            Padding(
              padding: const EdgeInsets.only(top: 45, bottom: 1),
              child: VerticalDivider(width: 0, color: Colors.grey.shade300,),
            ),
          ],
        ),
      ));

      return widgets;
    }).expand((item) => item).toList().cast<Widget>(); // 👈 Cast the final list
  }
}

class BuildInletSource extends StatelessWidget {
  final List<WaterSourceModel> waterSources;
  final String deviceId;
  final int customerId, controllerId;

  const BuildInletSource({
    super.key,
    required this.waterSources,
    required this.deviceId,
    required this.customerId,
    required this.controllerId,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> gridItems = [];

    for (int index = 0; index < waterSources.length; index++) {
      final source = waterSources[index];
      gridItems.add(_buildSourceColumn(context, source, index, waterSources.length));
      for (final pump in source.outletPump) {
        gridItems.add(PumpWidget(pump: pump, isSourcePump: !source.isWaterInAndOut, deviceId: deviceId,
          customerId: customerId, controllerId: controllerId, isMobile: false));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, right: 0),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade400,
            width: 0.5,
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(0),
            topLeft: Radius.circular(5),
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: ScrollConfiguration(
          behavior: const ScrollBehavior(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Row(
                    children: gridItems.map<Widget>((item) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: 70,
                          height: 100,
                          child: item,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isTimeFormat(String value) {
    final timeRegExp = RegExp(r'^([0-1]?\d|2[0-3]):[0-5]\d:[0-5]\d$');
    return timeRegExp.hasMatch(value);
  }

  Widget _buildSourceColumn(BuildContext context, WaterSourceModel source, int index, int total) {
    final String position = (index == 0)
        ? 'First'
        : (index == total - 1)
        ? 'Last'
        : 'Center';

    final bool hasLevel = source.level.isNotEmpty;

    return SizedBox(
      width: 70,
      height: 70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            height: 55,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: AppConstants.getAsset('source', 0, position),
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
}

class SensorWidget extends StatelessWidget {
  final SensorModel sensor;
  final String sensorType;
  final String imagePath;
  final int customerId, controllerId;

  const SensorWidget({
    super.key,
    required this.sensor,
    required this.sensorType,
    required this.imagePath,
    required this.customerId,
    required this.controllerId,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getSensorUpdatedValve(sensor.sNo.toString()),
      builder: (_, status, __) {

        final statusParts = status?.split(',') ?? [];
        if(statusParts.isNotEmpty){
          sensor.value = statusParts[1];
        }

        return SizedBox(
          width: 70,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (sensorType != 'Pressure Switch') ...[
                Stack(
                  children: [
                    SizedBox(
                      width: 70,
                      height: 65,
                      child: TextButton(
                        onPressed: () async {

                          final sensors = await fetchSensorData();
                          final sensorDataList = getSensorDataById(sensor.sNo.toString(), sensors);

                          showPopover(
                            context: context,
                            bodyBuilder: (context) {

                              List<CartesianSeries<dynamic, String>> series = [
                                LineSeries<SensorHourlyData, String>(
                                  dataSource: sensorDataList,
                                  xValueMapper: (SensorHourlyData data, _) => data.hour,
                                  yValueMapper: (SensorHourlyData data, _) {
                                    try {
                                      return double.parse(data.value);
                                    } catch (_) {
                                      return 0.0;
                                    }
                                  },
                                  markerSettings: const MarkerSettings(isVisible: true),
                                  dataLabelSettings: const DataLabelSettings(isVisible: false),
                                  color: Colors.blueAccent,
                                  name: sensor.name ?? 'Sensor',
                                ),
                              ];

                              return kIsWeb? Column(
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: SfRadialGauge(
                                          axes: <RadialAxis>[
                                            RadialAxis(
                                              minimum: 0,
                                              maximum: sensorType=='Moisture Sensor'?200:sensorType=='Pressure Sensor'?12:100,
                                              pointers: <GaugePointer>[
                                                NeedlePointer(
                                                    value: double.parse(sensor.value),
                                                    needleEndWidth: 3, needleColor: Colors.black54),
                                                RangePointer(
                                                  value: sensorType=='Moisture Sensor'?200.0:100.0,
                                                  width: 0.30,
                                                  sizeUnit: GaugeSizeUnit.factor,
                                                  color: const Color(0xFF494CA2),
                                                  animationDuration: 1000,
                                                  gradient: SweepGradient(
                                                    colors: sensorType == "Water Meter" ? <Color>[
                                                      Colors.teal.shade300,
                                                      Colors.teal.shade400,
                                                      Colors.teal.shade500,
                                                      Colors.teal.shade600
                                                    ]:
                                                    <Color>[
                                                      Colors.tealAccent,
                                                      Colors.orangeAccent,
                                                      Colors.redAccent,
                                                      Colors.redAccent
                                                    ],
                                                    stops: const <double>[0.15, 0.50, 0.70, 1.00],
                                                  ),
                                                  enableAnimation: true,
                                                ),
                                              ],
                                              showFirstLabel: false,
                                              annotations: <GaugeAnnotation>[
                                                GaugeAnnotation(
                                                  widget: Text(
                                                    sensor.value,
                                                    style: const TextStyle(
                                                        fontSize: 10, fontWeight: FontWeight.bold),
                                                  ),
                                                  angle: 90,
                                                  positionFactor: 0.8,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8, right: 8),
                                        child: Container(width: 1, height: 110, color: Colors.black12),
                                      ),
                                      SizedBox(
                                        width : 415,
                                        height : 132,
                                        child: TableCalendar(
                                          focusedDay: DateTime.now(),
                                          firstDay: DateTime.utc(2020, 1, 1),
                                          lastDay: DateTime.utc(2030, 12, 31),
                                          calendarFormat: CalendarFormat.week,
                                          availableCalendarFormats: const {
                                            CalendarFormat.week: 'Week',
                                          },
                                          onDaySelected: (selectedDay, focusedDay) {
                                            print("Selected: $selectedDay");
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    width: 550,
                                    height: 175,
                                    child: SfCartesianChart(
                                      primaryXAxis: CategoryAxis(
                                        title: AxisTitle(
                                          text: sensorType == 'Moisture Sensor'
                                              ? '${sensor.name}($sensorType) - Hours'
                                              : '${sensor.name} - Hours',
                                          textStyle: const TextStyle(fontSize: 12),
                                        ),
                                        majorGridLines: const MajorGridLines(width: 0),
                                        axisLine: const AxisLine(width: 0),
                                        labelStyle: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      primaryYAxis: const NumericAxis(
                                        labelStyle: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      tooltipBehavior: TooltipBehavior(enable: true),
                                      series: series,
                                    ),
                                  ),
                                ],
                              ):
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: SfRadialGauge(
                                            axes: <RadialAxis>[
                                              RadialAxis(
                                                minimum: 0,
                                                maximum: sensorType=='Moisture Sensor'?200:sensorType=='Pressure Sensor'?12:100,
                                                pointers: <GaugePointer>[
                                                  NeedlePointer(
                                                      value: double.parse(sensor.value),
                                                      needleEndWidth: 3, needleColor: Colors.black54),
                                                  RangePointer(
                                                    value: sensorType=='Moisture Sensor'?200.0:100.0,
                                                    width: 0.30,
                                                    sizeUnit: GaugeSizeUnit.factor,
                                                    color: const Color(0xFF494CA2),
                                                    animationDuration: 1000,
                                                    gradient: SweepGradient(
                                                      colors: sensorType == "Water Meter" ? <Color>[
                                                        Colors.teal.shade300,
                                                        Colors.teal.shade400,
                                                        Colors.teal.shade500,
                                                        Colors.teal.shade600
                                                      ]:
                                                      <Color>[
                                                        Colors.tealAccent,
                                                        Colors.orangeAccent,
                                                        Colors.redAccent,
                                                        Colors.redAccent
                                                      ],
                                                      stops: const <double>[0.15, 0.50, 0.70, 1.00],
                                                    ),
                                                    enableAnimation: true,
                                                  ),
                                                ],
                                                showFirstLabel: false,
                                                annotations: <GaugeAnnotation>[
                                                  GaugeAnnotation(
                                                    widget: Text(
                                                      sensor.value,
                                                      style: const TextStyle(
                                                          fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                    angle: 90,
                                                    positionFactor: 0.8,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width : MediaQuery.sizeOf(context).width-128,
                                          height : 132,
                                          child: TableCalendar(
                                            focusedDay: DateTime.now(),
                                            firstDay: DateTime.utc(2020, 1, 1),
                                            lastDay: DateTime.utc(2030, 12, 31),
                                            calendarFormat: CalendarFormat.week,
                                            availableCalendarFormats: const {
                                              CalendarFormat.week: 'Week',
                                            },
                                            onDaySelected: (selectedDay, focusedDay) {
                                              print("Selected: $selectedDay");
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.sizeOf(context).width,
                                    height: 175,
                                    child: SfCartesianChart(
                                      primaryXAxis: CategoryAxis(
                                        title: AxisTitle(
                                          text: sensorType == 'Moisture Sensor'
                                              ? '${sensor.name}($sensorType) - Hours'
                                              : '${sensor.name} - Hours',
                                          textStyle: const TextStyle(fontSize: 12),
                                        ),
                                        majorGridLines: const MajorGridLines(width: 0),
                                        axisLine: const AxisLine(width: 0),
                                        labelStyle: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      primaryYAxis: const NumericAxis(
                                        labelStyle: TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      tooltipBehavior: TooltipBehavior(enable: true),
                                      series: series,
                                    ),
                                  ),

                                ],
                              );
                            },
                            direction: PopoverDirection.bottom,
                            width: kIsWeb ? 550: MediaQuery.sizeOf(context).width-20,
                            height: 310,
                            arrowHeight: 15,
                            arrowWidth: 30,
                            barrierColor: Colors.black54,
                            arrowDyOffset: -40,
                          );
                        },
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                          minimumSize: WidgetStateProperty.all(Size.zero),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: WidgetStateProperty.all(Colors.transparent),
                        ),
                        child: Image.asset(
                          imagePath,
                          width: 70,
                          height: 70,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 17,
                      left: sensorType == 'Pressure Sensor'? 10:1,
                      right: sensorType == 'Pressure Sensor'? 10:1,
                      child: Container(
                        width: 70,
                        height: 17,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey, width: 0.5),
                        ),
                        child: Center(
                          child: Text(
                            MyFunction().getUnitByParameter(context, sensorType, sensor.value.toString()) ?? '',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 8),
                Image.asset(
                  imagePath,
                  width: 70,
                  height: 56,
                ),
              ],
              Text(
                sensor.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<SensorHourlyDataModel>> fetchSensorData() async {
    List<SensorHourlyDataModel> sensors = [];

    try {
      DateTime selectedDate = DateTime.now();
      String date = DateFormat('yyyy-MM-dd').format(selectedDate);

      Map<String, Object> body = {
        "userId": customerId,
        "controllerId": controllerId,
        "fromDate": date,
        "toDate": date,
      };

      final response = await Repository(HttpService()).fetchSensorHourlyData(body);
      if (response.statusCode == 200) {
        print(response.body);
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          sensors = (jsonData['data'] as List).map((item) {
            final Map<String, List<SensorHourlyData>> hourlyDataMap = {};

            item.forEach((key, value) {
              if (key == 'date') return;
              if (value is String && value.isNotEmpty) {
                final entries = value.split(';');
                hourlyDataMap[key] = entries.map((entry) {
                  return SensorHourlyData.fromCsv(entry, key);
                }).toList();
              } else {
                hourlyDataMap[key] = [];
              }
            });

            return SensorHourlyDataModel(
              date: item['date'],
              data: hourlyDataMap,
            );
          }).toList();
        }
      }
    } catch (error) {
      debugPrint('Error fetching sensor hourly data: $error');
    }

    return sensors;
  }

  List<SensorHourlyData> getSensorDataById(String sensorId, List<SensorHourlyDataModel> sensorData) {
    final result = <SensorHourlyData>[];
    for (final model in sensorData) {
      model.data.forEach((hour, sensorList) {
        result.addAll(sensorList.where((sensor) => sensor.sensorId == sensorId));
      });
    }
    return result;
  }
}


class ValveWidget extends StatelessWidget {
  final ValveModel valve;
  final int customerId, controllerId;
  final bool isLastValve;
  const ValveWidget({super.key, required this.valve, required this.customerId,
    required this.controllerId, required this.isLastValve});

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getValveOnOffStatus(valve.sNo.toString()),
      builder: (_, status, __) {

        final statusParts = status?.split(',') ?? [];
        if(statusParts.isNotEmpty){
          valve.status = int.parse(statusParts[1]);
        }

        bool hasMoisture = valve.moistureSensors.isNotEmpty;

        return SizedBox(
          width: 70,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: AppConstants.getAsset(isLastValve? 'valve_lj' : 'valve', valve.status, ''),
                  ),
                  Text(
                    valve.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
              if (hasMoisture)
                Positioned(
                  top: 20,
                  left: 33,
                  child: TextButton(
                    onPressed: () async {

                      final sensors = await fetchSensorData();
                      final sensorDataList = getSensorDataById(valve.moistureSensors[0].sNo.toString(), sensors);

                      showPopover(
                        context: context,
                        bodyBuilder: (context) {
                          List<CartesianSeries<dynamic, String>> series = [
                            LineSeries<SensorHourlyData, String>(
                              dataSource: sensorDataList,
                              xValueMapper: (SensorHourlyData data, _) => data.hour,
                              yValueMapper: (SensorHourlyData data, _) {
                                try {
                                  return double.parse(data.value);
                                } catch (_) {
                                  return 0.0;
                                }
                              },
                              markerSettings: const MarkerSettings(isVisible: true),
                              dataLabelSettings: const DataLabelSettings(isVisible: false),
                              color: Colors.blueAccent,
                              name: valve.moistureSensors[0].name ?? 'Sensor',
                            ),
                          ];

                          return Row(
                            children: [
                              SizedBox(
                                width: 450,
                                height: 175,
                                child: SfCartesianChart(
                                  primaryXAxis: CategoryAxis(
                                    title: AxisTitle(
                                      text: valve.moistureSensors[0].name,
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                    majorGridLines: const MajorGridLines(width: 0),
                                    axisLine: const AxisLine(width: 0),
                                    labelStyle: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  primaryYAxis: const NumericAxis(
                                    labelStyle: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  tooltipBehavior: TooltipBehavior(enable: true),
                                  series: series,
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: SfRadialGauge(
                                  axes: <RadialAxis>[
                                    RadialAxis(
                                      minimum: 0,
                                      maximum: 200,
                                      pointers: <GaugePointer>[
                                        NeedlePointer(
                                            value: double.parse(valve.moistureSensors[0].value),
                                            needleEndWidth: 3, needleColor: Colors.black54),
                                        const RangePointer(
                                          value: 200.0,
                                          width: 0.30,
                                          sizeUnit: GaugeSizeUnit.factor,
                                          color: Color(0xFF494CA2),
                                          animationDuration: 1000,
                                          gradient: SweepGradient(
                                            colors:
                                            <Color>[
                                              Colors.tealAccent,
                                              Colors.orangeAccent,
                                              Colors.redAccent,
                                              Colors.redAccent
                                            ],
                                            stops: <double>[0.15, 0.50, 0.70, 1.00],
                                          ),
                                          enableAnimation: true,
                                        ),
                                      ],
                                      showFirstLabel: false,
                                      annotations: <GaugeAnnotation>[
                                        GaugeAnnotation(
                                          widget: Text(
                                            valve.moistureSensors[0].value,
                                            style: const TextStyle(
                                                fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                          angle: 90,
                                          positionFactor: 0.8,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        onPop: () => print('Popover was popped!'),
                        direction: PopoverDirection.bottom,
                        width: 550,
                        height: valve.moistureSensors.length * 175,
                        arrowHeight: 15,
                        arrowWidth: 30,
                        barrierColor: Colors.black54,
                        arrowDxOffset: 15,
                        arrowDyOffset: -55,
                      );
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                      minimumSize: WidgetStateProperty.all(Size.zero),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: _getMoistureColor(valve.moistureSensors
                          .map((sensor) => {'name': sensor.name, 'value': sensor.value})
                          .toList()),
                      child: Image.asset(
                        'assets/png/moisture_sensor.png',
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getMoistureColor(List<Map<String, dynamic>> sensors) {
    if (sensors.isEmpty) return Colors.grey;

    final values = sensors
        .map((ms) => double.tryParse(ms['value'] ?? '0') ?? 0.0)
        .toList();

    final averageValue = values.reduce((a, b) => a + b) / values.length;

    if (averageValue < 20) {
      return Colors.green.shade200;
    } else if (averageValue <= 60) {
      return Colors.orange.shade200;
    } else {
      return Colors.red.shade200;
    }
  }

  Future<List<SensorHourlyDataModel>> fetchSensorData() async {
    List<SensorHourlyDataModel> sensors = [];

    try {
      DateTime selectedDate = DateTime.now();
      String date = DateFormat('yyyy-MM-dd').format(selectedDate);

      Map<String, Object> body = {
        "userId": customerId,
        "controllerId": controllerId,
        "fromDate": date,
        "toDate": date,
      };
      print(body);

      final response = await Repository(HttpService()).fetchSensorHourlyData(body);
      if (response.statusCode == 200) {
        print(response.body);
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          sensors = (jsonData['data'] as List).map((item) {
            final Map<String, List<SensorHourlyData>> hourlyDataMap = {};

            item.forEach((key, value) {
              if (key == 'date') return;
              if (value is String && value.isNotEmpty) {
                final entries = value.split(';');
                hourlyDataMap[key] = entries.map((entry) {
                  return SensorHourlyData.fromCsv(entry, key);
                }).toList();
              } else {
                hourlyDataMap[key] = [];
              }
            });

            return SensorHourlyDataModel(
              date: item['date'],
              data: hourlyDataMap,
            );
          }).toList();
        }
      }
    } catch (error) {
      debugPrint('Error fetching sensor hourly data: $error');
    }

    return sensors;
  }

  List<SensorHourlyData> getSensorDataById(String sensorId, List<SensorHourlyDataModel> sensorData) {
    final result = <SensorHourlyData>[];
    for (final model in sensorData) {
      model.data.forEach((hour, sensorList) {
        result.addAll(sensorList.where((sensor) => sensor.sensorId == sensorId));
      });
    }
    return result;
  }
}
