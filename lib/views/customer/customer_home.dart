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
    final viewModel = Provider.of<CustomerScreenControllerViewModel>(context);
    var onRefresh = Provider.of<MqttPayloadProvider>(context).onRefresh;
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

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          onRefresh ? displayLinearProgressIndicator() : const SizedBox(),

          (fertilizerSite.isEmpty && (grandTotal < 7 || totalValveCount < 25))
              ? buildWidgetInHorizontal(context, waterSources, filterSite, fertilizerSite, linesToDisplay, grandTotal)
              : buildWidgetInVertical(context, waterSources, filterSite, fertilizerSite, linesToDisplay, grandTotal,
              deviceId, customerId, controllerId),

          CurrentProgram(
            scheduledPrograms: scheduledProgram,
            deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,
            customerId: customerId,
            controllerId: controllerId,
            currentLineSNo: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].irrigationLine[viewModel.lIndex].sNo,
          ),

          NextSchedule(scheduledPrograms: scheduledProgram),

          if (kIsWeb && scheduledProgram.isNotEmpty)
            ScheduledProgram(
              userId: customerId,
              scheduledPrograms: scheduledProgram,
              controllerId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].controllerId,
              deviceId: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].deviceId,
              customerId: customerId,
              currentLineSNo: viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].irrigationLine[viewModel.lIndex].sNo,
            ),

          const SizedBox(height: 8),
        ],
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

  Widget buildWidgetInHorizontal(BuildContext context, waterSources, filterSite, fertilizerSite,
      List<IrrigationLineModel> linesToDisplay, int grandTotal){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
            width: (grandTotal*70) + 20,
            child: PumpStationWidget(waterSources: waterSources, filterSite: filterSite, fertilizerSite: fertilizerSite, isLineRight: true,
              deviceId: '', customerId: customerId, controllerId: controllerId,)
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
                  customerId: customerId, controllerId: controllerId,),
              )
          ),
        )),
      ],
    );
  }

  Widget buildWidgetInVertical(BuildContext context, waterSources, filterSite, fertilizerSite,
      List<IrrigationLineModel> linesToDisplay,  int grandTotal, deviceId, customerId, controllerId)
  {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final cardWidth = isWide ? (constraints.maxWidth / 2) - 16 : constraints.maxWidth;

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
            ),
            linesToDisplay.length == 1? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 0.5,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: LineObjects(
                    valves: linesToDisplay[0].valveObjects,
                    prsSwitch: linesToDisplay[0].prsSwitch,
                    pressureIn: linesToDisplay[0].pressureIn,
                    waterMeter: linesToDisplay[0].waterMeter,
                    customerId: customerId,
                    controllerId: controllerId,
                  ),
                ),
              ),
            ): Wrap(
              children: linesToDisplay.map((lineObjects) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8, right: 0),
                  child: SizedBox(
                    width: cardWidth+4,
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
                            SizedBox(
                              width: constraints.maxWidth,
                              child: Text(
                                lineObjects.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                            const Divider(height: 5, color: Colors.black12),
                            LineObjects(
                              valves: lineObjects.valveObjects,
                              prsSwitch: lineObjects.prsSwitch,
                              pressureIn: lineObjects.pressureIn,
                              waterMeter: lineObjects.waterMeter,
                              customerId: customerId,
                              controllerId: controllerId,
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
  final List<SensorModel> waterMeter;

  const LineObjects({
    super.key,
    required this.valves,
    required this.prsSwitch,
    required this.pressureIn,
    required this.waterMeter,
    required this.customerId,
    required this.controllerId,
  });

  @override
  Widget build(BuildContext context) {

    /*final List<Widget> valveWidgets = [
      for (var line in lineData!)
        if (currentLineName == 'All irrigation line' || line.name == currentLineName) ...[
          ...line.prsSwitch.map((psw) => SensorWidget(
            sensor: psw,
            sensorType: 'Pressure Switch',
            imagePath: 'assets/png/pressure_switch.png',
            sensorData: sensorsHourlyLog,
          )),
          ...line.pressureIn.map((psw) => SensorWidget(
            sensor: psw,
            sensorType: 'Pressure Sensor',
            imagePath: 'assets/png/pressure_sensor.png',
            sensorData: sensorsHourlyLog,
          )),
          ...line.waterMeter.map((wm) => SensorWidget(
            sensor: wm,
            sensorType: 'Water Meter',
            imagePath: 'assets/png/water_meter.png',
            sensorData: sensorsHourlyLog,
          )),
          ...line.valves.map((vl) => ValveWidget(
            vl: vl,
            status: vl.status,
            userId: 0,
            controllerId: 0,
            moistureSensor: vl.moistureSensor!,
          )),
        ],
    ];*/

    return Container(
      color: Colors.white,
      child: Wrap(
        children: [
          ..._buildSensorItems(prsSwitch, 'Pressure Switch', 'assets/png/pressure_switch.png'),
          ..._buildSensorItems(pressureIn, 'Pressure Sensor', 'assets/png/pressure_sensor.png'),
          ..._buildSensorItems(waterMeter, 'Water Meter', 'assets/png/water_meter.png'),
          ...valves.map((valve) => ValveWidget(valve: valve)),
        ],
      ),
    );
  }

  List<Widget> _buildSensorItems(List<SensorModel> sensors, String type, String imagePath) {
    return sensors.map((sensor) {
      return SizedBox(
        width: 70,
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

}

class PumpStationWidget extends StatelessWidget {
  final List<WaterSourceModel> waterSources;
  final List<FilterSiteModel> filterSite;
  final List<FertilizerSiteModel> fertilizerSite;
  final bool isLineRight;
  final String deviceId;
  final int customerId, controllerId;

  const PumpStationWidget({
    super.key,
    required this.waterSources,
    required this.filterSite,
    required this.fertilizerSite,
    required this.isLineRight,
    required this.deviceId, required this.customerId, required this.controllerId,
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
      gridItems.add(_buildSourceColumn(source, index, sortedWaterSources.length));
      for (final pump in source.pumpObjects) {
        gridItems.add(PumpWidget(pump: pump, isSourcePump: !source.isWaterInAndOut, deviceId: deviceId, customerId: customerId, controllerId: controllerId,));
      }
    }

    return Padding(
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

  Widget _buildSourceColumn(WaterSourceModel source, int index, int total) {
    String position;
    if (index == 0) {
      position = 'First';
    } else if (index == total - 1) {
      position = 'Last';
    } else {
      position = 'Center';
    }

    return SizedBox(
      width: 70,
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AppConstants.getAsset('source', 0, position),
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
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (sensorType != 'Pressure Switch') ...[
              SizedBox(
                width: 85,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 70,
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
                      left: 0,
                      right: 1,
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
              ),
            ] else ...[
              SizedBox(
                width: 85,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 70,
                      height: 35,
                      child: Image.asset(
                        imagePath,
                        width: 35,
                        height: 35,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 24,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.black45,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: sensor.value == '1' ? Colors.redAccent : Colors.lightGreenAccent,
                        ),
                      ),
                    ),
                  ],
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
      ),
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
        "fromDate": '2025:04:17',
        "toDate": '2025:04:17',
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
  const ValveWidget({super.key, required this.valve});

  @override
  Widget build(BuildContext context) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getValveOnOffStatus(valve.sNo.toString()),
      builder: (_, status, __) {

        final statusParts = status?.split(',') ?? [];
        valve.status = int.parse(statusParts[1]);

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            width: 85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
          ),
        );
      },
    );
  }
}
