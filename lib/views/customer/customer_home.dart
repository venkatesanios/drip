import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/views/customer/home_sub_classes/current_program.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../Models/customer/sensor_hourly_data_model.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../Widgets/pump_widget.dart';
import '../../repository/repository.dart';
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


    final waterSources = {
      for (var source in linesToDisplay.expand((line) => line.waterSources)) source.sNo: source
    }.values.toList();

    final filterSite = {
      for (var line in linesToDisplay)
        if (line.centralFilterSite != null) line.centralFilterSite!.sNo : line.centralFilterSite!
    }.values.toList();

    final fertilizerSite = {
      for (var line in linesToDisplay)
        if (line.centralFertilizerSite != null) line.centralFertilizerSite!.sNo : line.centralFertilizerSite!
    }.values.toList();


    int totalWaterSources = waterSources.length;
    int totalOutletPumps = waterSources.fold(0, (sum, source) => sum + source.pumpObjects.length);

    int totalFilters = filterSite.fold(0, (sum, site) => sum + (site.filters.length));
    int totalPressureIn = filterSite.fold(0, (sum, site) => sum + (site.pressureIn!=null ? 1 : 0));
    int totalPressureOut = filterSite.fold(0, (sum, site) => sum + (site.pressureOut!=null ? 1 : 0));

    int totalBoosterPump = fertilizerSite.fold(0, (sum, site) => sum + (site.boosterPump.length));
    int totalChannels = fertilizerSite.fold(0, (sum, site) => sum + (site.channel.length));
    int totalAgitators = fertilizerSite.fold(0, (sum, site) => sum + (site.agitator.length));

    final totalValveCount = linesToDisplay.fold<int>(0,
          (previous, line) => previous + line.valveObjects.length,
    );

    int grandTotal = totalWaterSources + totalOutletPumps +
        totalFilters + totalPressureIn + totalPressureOut +
        totalBoosterPump + totalChannels + totalAgitators;

    return kIsWeb
        ? _buildWebLayout(context, grandTotal, waterSources, filterSite, fertilizerSite, linesToDisplay, totalValveCount, scheduledProgram)
        : _buildMobileLayout(context, grandTotal, waterSources, filterSite, fertilizerSite, linesToDisplay, totalValveCount, scheduledProgram);
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

  Widget _buildWebLayout(
      BuildContext context, grandTotal, List<WaterSourceModel> waterSources, filterSite,
      fertilizerSite, linesToDisplay, totalValveCount, scheduledProgram) {

    final viewModel = context.read<CustomerScreenControllerViewModel>();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          context.watch<MqttPayloadProvider>().onRefresh ? displayLinearProgressIndicator() : const SizedBox(),

          (fertilizerSite.isEmpty && (grandTotal < 7 && totalValveCount < 25))
              ? buildWidgetInHorizontal(context, waterSources, filterSite, fertilizerSite, linesToDisplay, grandTotal, false)
              : buildWidgetInVertical(context, waterSources, filterSite, fertilizerSite, linesToDisplay, false),

          CurrentProgram(
            scheduledPrograms: scheduledProgram,
            deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,
            customerId: customerId,
            controllerId: controllerId,
            currentLineSNo: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].irrigationLine[viewModel.lIndex].sNo,
          ),
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
      BuildContext context, grandTotal, waterSources, filterSite,
      fertilizerSite, linesToDisplay, totalValveCount, scheduledProgram) {

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
          buildWidgetInVertical(context, waterSources, filterSite, fertilizerSite, linesToDisplay, true),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget buildWidgetInHorizontal(BuildContext context, waterSources, filterSite, fertilizerSite,
      List<IrrigationLineModel> linesToDisplay, int grandTotal, bool isMobile){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
            width: (grandTotal*70) + 20,
            child: PumpStationWidget(waterSources: waterSources, filterSite: filterSite, fertilizerSite: fertilizerSite, isLineRight: true,
              deviceId: deviceId, customerId: customerId, controllerId: controllerId, isMobile: isMobile,)
        ),
        ...linesToDisplay.map((lineObjects) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
              width: MediaQuery.sizeOf(context).width - ((grandTotal*70) + 168),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 0.5,
                ),
                borderRadius: const BorderRadius.only(
                  topRight:Radius.circular(5),
                  topLeft: Radius.circular(0),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: LineObjects(valves: lineObjects.valveObjects, prsSwitch: lineObjects.prsSwitch,
                  pressureIn: lineObjects.pressureIn, waterMeter: lineObjects.waterMeter,
                  customerId: customerId, controllerId: controllerId,
                  containerWidth: MediaQuery.sizeOf(context).width - ((grandTotal*70) + 168),
                  isMobile: isMobile, pressureOut: lineObjects.pressureOut),
              )
          ),
        )),
      ],
    );
  }

  Widget buildWidgetInVertical(BuildContext context, waterSources, filterSite, fertilizerSite,
      List<IrrigationLineModel> linesToDisplay, bool isMobile)
  {
    return LayoutBuilder(
      builder: (context, constraints) {
        double containerWidth = 0.0;

        if(linesToDisplay.length == 1 || isMobile){
          containerWidth = constraints.maxWidth;
        }else{
          containerWidth = (constraints.maxWidth/linesToDisplay.length);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PumpStationWidget(
              waterSources: waterSources,
              filterSite: filterSite,
              fertilizerSite: fertilizerSite,
              isLineRight: false,
              deviceId: deviceId,
              customerId: customerId,
              controllerId: controllerId,
              isMobile: isMobile,
            ),
            isMobile? Column(
              children: linesToDisplay.map((lineObjects) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
                  child: SizedBox(
                    width: containerWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 2),
                          child: Text(
                            lineObjects.name,
                            textAlign: TextAlign.start,
                            style: const TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        ),
                        LineObjects(
                          valves: lineObjects.valveObjects,
                          prsSwitch: lineObjects.prsSwitch,
                          pressureIn: lineObjects.pressureIn,
                          waterMeter: lineObjects.waterMeter,
                          customerId: customerId,
                          controllerId: controllerId,
                          containerWidth: containerWidth,
                          isMobile: isMobile,
                          pressureOut: lineObjects.pressureOut,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ):
            Wrap(
              children: linesToDisplay.map((lineObjects) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: SizedBox(
                    width: containerWidth-12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 0.5,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5, top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            linesToDisplay.length != 1?SizedBox(
                              width: constraints.maxWidth,
                              child: Text(
                                lineObjects.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ):
                            const SizedBox(),
                            linesToDisplay.length != 1?
                            const Divider(height: 5, color: Colors.black12):
                            const SizedBox(),
                            LineObjects(
                              valves: lineObjects.valveObjects,
                              prsSwitch: lineObjects.prsSwitch,
                              pressureIn: lineObjects.pressureIn,
                              waterMeter: lineObjects.waterMeter,
                              customerId: customerId,
                              controllerId: controllerId,
                              containerWidth: containerWidth,
                              isMobile: isMobile,
                              pressureOut: lineObjects.pressureOut,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class LineObjects extends StatelessWidget {
  final int customerId, controllerId;
  final List<ValveModel> valves;
  final List<SensorModel> prsSwitch;
  final List<SensorModel> pressureIn;
  final List<SensorModel> pressureOut;
  final List<SensorModel> waterMeter;
  final double containerWidth;
  final bool isMobile;

  const LineObjects({
    super.key,
    required this.valves,
    required this.prsSwitch,
    required this.pressureIn,
    required this.pressureOut,
    required this.waterMeter,
    required this.customerId,
    required this.controllerId,
    required this.containerWidth,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final allItems = [
      ..._buildSensorItems(prsSwitch, 'Pressure Switch', 'assets/png/pressure_switch.png'),
      ..._buildSensorItems(pressureIn, 'Pressure Sensor', 'assets/png/pressure_sensor.png'),
      ..._buildSensorItems(waterMeter, 'Water Meter', 'assets/png/water_meter.png'),
      ...valves.map((valve) => ValveWidget(valve: valve,customerId: customerId, controllerId: controllerId)),
      ..._buildSensorItems(pressureOut, 'Pressure Sensor', 'assets/png/pressure_sensor.png'),
    ];

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: isMobile ? 2 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: (containerWidth / 85).round(),
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
          childAspectRatio: isMobile? 1.0 : 1.30,
        ),
        itemCount: allItems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 3, right: 3),
            child: allItems[index],
          );
        },
      ),
    );

  }

  List<Widget> _buildSensorItems(List<SensorModel> sensors, String type, String imagePath) {
    return sensors.map((sensor) {
      return SensorWidget(
        sensor: sensor,
        sensorType: type,
        imagePath: imagePath,
        customerId: customerId,
        controllerId: controllerId,
      );
    }).toList();
  }
}

class PumpStationWidget extends StatelessWidget {
  final List<WaterSourceModel> waterSources;
  final List<FilterSiteModel> filterSite;
  final List<FertilizerSiteModel> fertilizerSite;
  final bool isLineRight;
  final String deviceId;
  final int customerId, controllerId;
  final bool isMobile;

  const PumpStationWidget({
    super.key,
    required this.waterSources,
    required this.filterSite,
    required this.fertilizerSite,
    required this.isLineRight,
    required this.deviceId,
    required this.customerId,
    required this.controllerId,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> gridItems = [];

    final sortedWaterSources = List<WaterSourceModel>.from(waterSources)
      ..sort((a, b) {
        if (a.isWaterInAndOut == b.isWaterInAndOut) return 0;
        return a.isWaterInAndOut ? 1 : -1;
      });

    for (int index = 0; index < sortedWaterSources.length; index++) {
      final source = sortedWaterSources[index];
      gridItems.add(_buildSourceColumn(context, source, index, sortedWaterSources.length));
      for (final pump in source.pumpObjects) {
        gridItems.add(PumpWidget(pump: pump, isSourcePump: !source.isWaterInAndOut, deviceId: deviceId,
          customerId: customerId, controllerId: controllerId, isMobile: isMobile,));
      }
    }

    int totalFilters = filterSite.fold(0, (sum, site) => sum + (site.filters.length));
    int totalPressureIn = filterSite.fold(0, (sum, site) => sum + (site.pressureIn!=null ? 1 : 0));
    int totalPressureOut = filterSite.fold(0, (sum, site) => sum + (site.pressureOut!=null ? 1 : 0));
    int totalBoosterPump = fertilizerSite.fold(0, (sum, site) => sum + (site.boosterPump.length));
    int totalChannels = fertilizerSite.fold(0, (sum, site) => sum + (site.channel.length));
    int totalAgitators = fertilizerSite.fold(0, (sum, site) => sum + (site.agitator.length));

    int ffGrandTotal = totalFilters + totalPressureIn + totalPressureOut +
        totalBoosterPump + totalChannels + totalAgitators;


    return isMobile? Padding(
      padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 2),
            child: Text(
              'PUMP STATION',
              textAlign: TextAlign.start,
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
          Card(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (MediaQuery.sizeOf(context).width / 85).round(),
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: isMobile? 1.0 : 1.30,
              ),
              itemCount: gridItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 3, right: 3),
                  child: gridItems[index],
                );
              },
            ),
          ),
          if(ffGrandTotal < 6 && filterSite.isNotEmpty && fertilizerSite.isNotEmpty)...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    filterSite.isNotEmpty? const Padding(
                      padding: EdgeInsets.only(left: 5, bottom: 2, top: 5),
                      child: Text(
                        'FILTER SITE',
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ):
                    const SizedBox(),
                    filterSite.isNotEmpty? Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 2, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for(int fIndex=0; fIndex<filterSite.length; fIndex++)
                                FilterSiteView(filterSite: filterSite[fIndex]),
                            ],
                          ),
                        ),
                      ),
                    ):
                    const SizedBox(),
                  ],
                ),
                Column(
                  children: [
                    fertilizerSite.isNotEmpty? const Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 2, top: 5),
                      child: Text(
                        'FERTILIZER SITE',
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ):
                    const SizedBox(),
                    fertilizerSite.isNotEmpty? Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 2, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for(int siteIndex=0; siteIndex<fertilizerSite.length; siteIndex++)
                                FertilizerSiteView(fertilizerSite: fertilizerSite[siteIndex], siteIndex: siteIndex),
                            ],
                          ),
                        ),
                      ),
                    ):
                    const SizedBox(),
                  ],
                )
              ],
            )
          ] else...[
            filterSite.isNotEmpty? const Padding(
              padding: EdgeInsets.only(left: 5, bottom: 2, top: 5),
              child: Text(
                'FILTER SITE',
                textAlign: TextAlign.start,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ):
            const SizedBox(),
            filterSite.isNotEmpty? Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 2, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for(int fIndex=0; fIndex<filterSite.length; fIndex++)
                        FilterSiteView(filterSite: filterSite[fIndex]),
                    ],
                  ),
                ),
              ),
            ):
            const SizedBox(),
            fertilizerSite.isNotEmpty? const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 2, top: 5),
              child: Text(
                'FERTILIZER SITE',
                textAlign: TextAlign.start,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ):
            const SizedBox(),
            fertilizerSite.isNotEmpty? Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 2, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for(int siteIndex=0; siteIndex<fertilizerSite.length; siteIndex++)
                        FertilizerSiteView(fertilizerSite: fertilizerSite[siteIndex], siteIndex: siteIndex),
                    ],
                  ),
                ),
              ),
            ):
            const SizedBox(),
          ]
        ],
      ),
    ):
    Padding(
      padding: EdgeInsets.only(left: 8, top: 8, right: isLineRight? 0:8),
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade400,
            width: 0.5,
          ),
          borderRadius: BorderRadius.only(
            topRight: isLineRight? const Radius.circular(0) : const Radius.circular(5),
            topLeft: const Radius.circular(5),
            bottomLeft: const Radius.circular(5),
            bottomRight:  isLineRight? const Radius.circular(0) : const Radius.circular(5),
          ),
        ),
        child: ScrollConfiguration(
          behavior: const ScrollBehavior(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: isLineRight ? 0 : 8),
              child: Row(
                children: [
                  Row(
                    children: gridItems.map<Widget>((item) {
                      return Padding(
                        padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty? 27: 10),
                        child: SizedBox(
                          width: 70,
                          height: 100,
                          child: item,
                        ),
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for(int fIndex=0; fIndex<filterSite.length; fIndex++)
                        Padding(
                          padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty? 35: 10),
                          child: FilterSiteView(filterSite: filterSite[fIndex]),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for(int siteIndex=0; siteIndex<fertilizerSite.length; siteIndex++)
                        FertilizerSiteView(fertilizerSite: fertilizerSite[siteIndex], siteIndex: siteIndex),
                    ],
                  )
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
      height: isMobile? 75 : 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            height: isMobile ? 55:70,
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: isMobile? 8:0),
                  child: AppConstants.getAsset('source', 0, position),
                ),
                if (hasLevel) ...[
                  Positioned(
                    top: isMobile ? 37 : 50,
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
                    top: isMobile ? 5 : 33,
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
          width: 85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (sensorType != 'Pressure Switch') ...[
                Stack(
                  children: [
                    SizedBox(
                      width: 85,
                      height: 40,
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

                              return Row(
                                children: [
                                  SizedBox(
                                    width: 450,
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
                                ],
                              );
                            },
                            direction: PopoverDirection.bottom,
                            width: 550,
                            height: 175,
                            arrowHeight: 15,
                            arrowWidth: 30,
                            barrierColor: Colors.black54,
                            arrowDyOffset: -20,
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
                          width: 35,
                          height: 35,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
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
                SizedBox(
                  width: 85,
                  height: 40,
                  child: Image.asset(
                    imagePath,
                    width: 40,
                    height: 40,
                  ),
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
  const ValveWidget({super.key, required this.valve, required this.customerId, required this.controllerId});

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
          width: 85,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 35,
                    height: 35,
                    child: AppConstants.getAsset('valve', valve.status, ''),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valve.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
              if (hasMoisture)
                Positioned(
                  top: 0,
                  left: 47,
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
                        arrowDxOffset: 23,
                        arrowDyOffset: -25,
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
