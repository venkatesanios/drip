import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import '../../../Models/customer/site_model.dart';
import '../../../StateManagement/duration_notifier.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../services/mqtt_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/formatters.dart';
import '../../../utils/snack_bar.dart';
import '../../../view_models/customer/pump_station_view_model.dart';
import 'irrigation_line.dart';


class PumpStation extends StatelessWidget {
  const PumpStation({super.key, required this.waterSource, required this.filterSite, required this.fertilizerSite, this.irrLineData, required this.currentLineName, required this.deviceId, required this.customerId, required this.controllerId});

  final List<WaterSource> waterSource;
  final List<FilterSite> filterSite;
  final List<FertilizerSite> fertilizerSite;
  final List<IrrigationLineData>? irrLineData;
  final String currentLineName, deviceId;
  final int customerId, controllerId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PumpStationViewModel(context, waterSource, filterSite, fertilizerSite, irrLineData, currentLineName),
      child: Consumer<PumpStationViewModel>(
        builder: (context, vm, _) {

          var outputStatusPayload = Provider.of<MqttPayloadProvider>(context).outputStatusPayload;
          var pumpPayload = Provider.of<MqttPayloadProvider>(context).pumpPayload;
          var filterPayload = Provider.of<MqttPayloadProvider>(context).filterPayload;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (vm.shouldUpdate(outputStatusPayload, pumpPayload, filterPayload)) {
              vm.updateOutputStatus(outputStatusPayload.toList(), pumpPayload.toList(), filterPayload.toList());
            }
          });

          return Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                color: kIsWeb? Colors.white : Colors.white54,
                border: kIsWeb? Border.all(
                  color: Colors.grey.shade400,
                  width: 0.5,
                ) : null,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: kIsWeb? Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Column(
                  children: [
                    ((vm.mvFertilizerSite.isEmpty && vm.grandTotal < 7) ||
                        (vm.mvFertilizerSite.isEmpty && vm.mvIrrLineData![0].valves.length < 25)) ?
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildRow(context, vm.sortedWaterSources, vm),
                        Padding(
                          padding: const EdgeInsets.only(top: 3.1),
                          child: DisplayIrrigationLine(lineData:vm.mvIrrLineData, pumpStationWith:(vm.grandTotal*70)+157, currentLineName:currentLineName),
                        ),
                      ],
                    ):
                    Column(
                      children: [
                        vm.grandTotal > 17 ?
                        ScrollConfiguration(
                          behavior: const ScrollBehavior(),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: buildRow(context, vm.sortedWaterSources, vm),
                          ),
                        ):
                        buildRow(context, vm.sortedWaterSources, vm),
                        DisplayIrrigationLine(lineData: vm.mvIrrLineData, pumpStationWith: 0, currentLineName: currentLineName,),
                      ],
                    ),

                  ],
                ),
              ):
              buildMobile(context, vm.sortedWaterSources, vm),
            ),
          );

        },
      ),
    );
  }

  Widget buildRow(BuildContext context, List<WaterSource> sortedWaterSources, PumpStationViewModel vm) {

    final List<Widget> gridItems = [];

    gridItems.addAll(
      sortedWaterSources.asMap().entries.expand((entry) {
        int i = entry.key;
        var source = entry.value;
        return [
          SourceWidget(source: source, index: i),
          ...source.outletPump.map((pump) => PumpWidget(pump: pump, vm: vm, customerId: customerId, controllerId: controllerId))
        ];
      }),
    );

    gridItems.addAll(
      vm.mvFilterSite.expand((filterSite) => [
        if (filterSite.pressureIn != null)
          PressureSensorWidget(pressureSensor: filterSite.pressureIn!),

        ...filterSite.filters.map((filter) => FilterWidget(filter: filter)),

        if (filterSite.pressureOut != null)
          PressureSensorWidget(pressureSensor: filterSite.pressureOut!),
      ]),
    );

    gridItems.addAll(
      vm.mvFertilizerSite.expand((fertilizerSite) => [
        /*if (fertilizerSite.boosterPump.isNotEmpty)
          PressureSensorWidget(pressureSensor: filterSite.pressureIn!),*/

        ...fertilizerSite.channel.map((channel) => FertilizerWidget(channel: channel)),

      ]),
    );

    /*return Row(
      children: gridItems.asMap().entries.map((entry) {
        int index = entry.key;
        return Padding(
          padding: EdgeInsets.only(top: vm.mvFertilizerSite.isNotEmpty ? 38.4 : 0),
          child: SizedBox(
            width: 70,
            height: 100,
            child: GridTile(
              child: gridItems[index],
            ),
          ),
        );
      }).toList(),
    );*/

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: sortedWaterSources.asMap().entries.map((entry) {
        int index = entry.key;
        var source = entry.value;
        bool isLastIndex = index == sortedWaterSources.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: vm.mvFertilizerSite.isNotEmpty ? 38.4 : 0),
              child: Stack(
                children: [
                  SizedBox(
                    width: 70,
                    child: isLastIndex? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              Container(width: 32, height: 2, color: Colors.grey.shade300),
                              const SizedBox(width: 7,),
                              Container(width: 31, height: 2, color: Colors.grey.shade300),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.9),
                          child: Row(
                            children: [
                              Container(width: 27, height: 2, color: Colors.grey.shade300),
                              const SizedBox(width: 10,),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Container(width: 28, height: 2, color: Colors.grey.shade300),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ):
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: index == 0 ? 33 : 0),
                          child: Divider(thickness: 2, color: Colors.grey.shade300, height: 5.5),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: index == 0 ? 37 : 0),
                          child: Divider(thickness: 2, color: Colors.grey.shade300, height: 4.5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 95,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 15,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                VerticalDivider(thickness: 1, color: Colors.grey.shade400, width: 3),
                                VerticalDivider(thickness: 1, color: Colors.grey.shade400, width: 5),
                                isLastIndex? const SizedBox(width: 3,):const SizedBox(),
                                isLastIndex? VerticalDivider(thickness: 1, color: Colors.grey.shade400, width: 3):const SizedBox(),
                                isLastIndex? VerticalDivider(thickness: 1, color: Colors.grey.shade400, width: 5):const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade300,
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          source.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  if (source.level != null) ...[
                    Positioned(
                      top: 25,
                      left: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          border: Border.all(color: Colors.grey, width: .50),
                        ),
                        width: 60,
                        height: 18,
                        child: Center(
                          child: Text(
                            '${source.level!.percentage!} feet',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 5,
                      child: SizedBox(
                        width: 60,
                        child: Center(
                          child: Text(
                            '${source.valves} %',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Wrap(
              spacing: 0.0,
              children: source.outletPump.map((pump) {
                return Padding(
                  padding: EdgeInsets.only(top: vm.mvFertilizerSite.isNotEmpty ? 38.4 : 0),
                  child: displayPump(context, pump, vm, source.inletPump.isEmpty? true : false),
                );
              }).toList(),
            ),
            if (isLastIndex && vm.mvFilterSite.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: vm.mvFertilizerSite.isNotEmpty ? 38.4 : 0),
                child: displayFilterSite(context, vm.mvFilterSite),
              ),
            if (isLastIndex && vm.mvFertilizerSite.isNotEmpty)
              displayFertilizerSite(context, vm.mvFertilizerSite),
          ],
        );
      }).toList(),
    );
  }

  Widget buildMobile(BuildContext context, List<WaterSource> sortedWaterSources, PumpStationViewModel vm) {

    final List<Widget> gridItems = [];

    gridItems.addAll(
      sortedWaterSources.asMap().entries.expand((entry) {
        int i = entry.key;
        var source = entry.value;
        return [
          SourceWidget(source: source, index: i),
          ...source.outletPump.map((pump) => PumpWidget(pump: pump, vm: vm, customerId: customerId, controllerId: controllerId))
        ];
      }),
    );

    gridItems.addAll(
      vm.mvFilterSite.expand((filterSite) => [
        if (filterSite.pressureIn != null)
          PressureSensorWidget(pressureSensor: filterSite.pressureIn!),
        ...filterSite.filters.map((filter) => FilterWidget(filter: filter)),

        if (filterSite.pressureOut != null)
          PressureSensorWidget(pressureSensor: filterSite.pressureOut!),
      ]),
    );

    gridItems.addAll(
      vm.mvIrrLineData!.expand((line) => line.valves.map((valve) => ValveWidget(valve: valve))),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: (gridItems.length/5)*100,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 0.82,
          ),
          itemCount: gridItems.length,
          itemBuilder: (context, index) {
            return GridTile(
              child: gridItems[index],
            );
          },
        ),
      ),
    );
  }


  Widget displayPump(BuildContext context, Pump pump, PumpStationViewModel vm, bool isSourcePump){
    return Stack(
      children: [
        SizedBox(
          width: 70,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Tooltip(
                message: 'View more details',
                child: TextButton(
                  onPressed: () {
                    final RenderBox button = context.findRenderObject() as RenderBox;
                    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                    final position = button.localToGlobal(Offset.zero, ancestor: overlay);

                    bool voltKeyExists = pump.voltage.isNotEmpty;
                    //int signalStrength = voltKeyExists? int.parse(filteredPumps[index].signalStrength):0;
                    //int batteryVolt = voltKeyExists? int.parse(filteredPumps[index].battery):0;
                    List<String> voltages = voltKeyExists? pump.voltage.split('_'):[];
                    List<String> currents = voltKeyExists? pump.current.split('_'):[];

                    //List<String> icEnergy = voltKeyExists? filteredPumps[index].icEnergy.split(','):[];
                    //List<String> icPwrFactor = voltKeyExists? filteredPumps[index].pwrFactor.split(','):[];
                    //List<String> icPwr = voltKeyExists? filteredPumps[index].pwr.split(','):[];

                    //List<dynamic> pumpLevel = voltKeyExists? filteredPumps[index].level:[];

                    List<String> columns = ['-', '-', '-'];

                    if (voltKeyExists) {
                      for (var pair in currents) {
                        String sanitizedPair = pair.trim().replaceAll(RegExp(r'^"|"$'), '');
                        List<String> parts = sanitizedPair.split(':');
                        if (parts.length != 2) {
                          print('Error: Pair "$sanitizedPair" does not have the expected format');
                          continue;
                        }

                        try {
                          int columnIndex = int.parse(parts[0].trim()) - 1;
                          if (columnIndex >= 0 && columnIndex < columns.length) {
                            columns[columnIndex] = parts[1].trim();
                          } else {
                            print('Error: Column index $columnIndex is out of bounds');
                          }
                        } catch (e) {
                          print('Error parsing column index from "$sanitizedPair": $e');
                        }
                      }
                    }

                    showPopover(
                      context: context,
                      bodyBuilder: (context) {
                        //MqttPayloadProvider provider = Provider.of<MqttPayloadProvider>(context, listen: true);
                        Future.delayed(const Duration(seconds: 2));
                        vm.popoverUpdateNotifier.value++;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ValueListenableBuilder<int>(
                              valueListenable: vm.popoverUpdateNotifier,
                              builder: (BuildContext context, int value, Widget? child) {

                                return Material(
                                  child: voltKeyExists?Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 315,
                                        height: 35,
                                        color: Colors.teal,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(width: 8,),
                                            Text.rich(
                                              TextSpan(
                                                text: 'Version : ',
                                                style: const TextStyle(color: Colors.white54),
                                                children: [
                                                  /*TextSpan(
                                                    text: filteredPumps[index].version,
                                                    style: const TextStyle(
                                                        fontWeight: FontWeight.bold, color: Colors.white),
                                                  ),*/
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            /*Icon(signalStrength == 0 ? Icons.wifi_off :
                                            signalStrength >= 1 && signalStrength <= 20 ?
                                            Icons.network_wifi_1_bar_outlined :
                                            signalStrength >= 21 && signalStrength <= 40 ?
                                            Icons.network_wifi_2_bar_outlined :
                                            signalStrength >= 41 && signalStrength <= 60 ?
                                            Icons.network_wifi_3_bar_outlined :
                                            signalStrength >= 61 && signalStrength <= 80 ?
                                            Icons.network_wifi_3_bar_outlined :
                                            Icons.wifi, color: signalStrength == 0?Colors.white54:Colors.white,),
                                            const SizedBox(width: 5,),
                                            Text('$signalStrength%', style: const TextStyle(color: Colors.white),),*/

                                           /* const SizedBox(width: 5,),
                                            batteryVolt==0?const Icon(Icons.battery_0_bar, color: Colors.white54,):
                                            batteryVolt>0&&batteryVolt<=10?const Icon(Icons.battery_1_bar_rounded, color: Colors.white,):
                                            batteryVolt>10&&batteryVolt<=30?const Icon(Icons.battery_2_bar_rounded, color: Colors.white,):
                                            batteryVolt>30&&batteryVolt<=50?const Icon(Icons.battery_3_bar_rounded, color: Colors.white,):
                                            batteryVolt>50&&batteryVolt<=70?const Icon(Icons.battery_4_bar_rounded, color: Colors.white,):
                                            batteryVolt>70&&batteryVolt<=90?const Icon(Icons.battery_5_bar_rounded, color: Colors.white,):
                                            const Icon(Icons.battery_full, color: Colors.white,),
                                            Text('$batteryVolt%', style: const TextStyle(color: Colors.white),),*/

                                            const SizedBox(width: 8,),
                                          ],
                                        ),
                                      ),
                                      int.parse(pump.reason)>0 && int.parse(pump.reason)!=31 ? Container(
                                        width: 315,
                                        height: 33,
                                        color: Colors.orange.shade100,
                                        child: Row(
                                          children: [
                                            Expanded(child: Padding(
                                              padding: const EdgeInsets.only(left: 5),
                                              child: Text(
                                                pump.reason == '8' && vm.isTimeFormat(pump.actualValue.split('_').last)
                                                    ? '${vm.getContentByCode(int.parse(pump.reason))}, It will be restart automatically within ${pump.actualValue.split('_').last} (hh:mm:ss)'
                                                    :vm.getContentByCode(int.parse(pump.reason)),
                                                style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.normal),
                                              ),
                                            )),
                                            (!PumpStationViewModel.excludedReasons.contains(pump.reason)) ? SizedBox(
                                              height:23,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  backgroundColor: Colors.redAccent.shade200,
                                                  textStyle: const TextStyle(color: Colors.white),
                                                ),
                                                onPressed: () => vm.resetPump(context, deviceId, pump.sNo, pump.name, customerId, controllerId, customerId),
                                                child: const Text('Reset', style: TextStyle(fontSize: 12, color: Colors.white),),
                                              ),
                                            ):const SizedBox(),
                                            const SizedBox(width: 5,),
                                          ],
                                        ),
                                      ):
                                      const SizedBox(),
                                      Container(
                                        width: 300,
                                        height: 25,
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            const SizedBox(width:100, child: Text('Phase', style: TextStyle(color: Colors.black54),),),
                                            const Spacer(),
                                            CircleAvatar(radius: 7, backgroundColor: int.parse(pump.phase)>0? Colors.green: Colors.red.shade100,),
                                            const VerticalDivider(color: Colors.transparent,),
                                            CircleAvatar(radius: 7, backgroundColor: int.parse(pump.phase)>1? Colors.green: Colors.red.shade100,),
                                            const VerticalDivider(color: Colors.transparent,),
                                            CircleAvatar(radius: 7, backgroundColor: int.parse(pump.phase)>2? Colors.green: Colors.red.shade100,),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5,),
                                      Container(
                                        width: 300,
                                        height: 25,
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            const SizedBox(width:85, child: Text('Voltage', style: TextStyle(color: Colors.black54),),),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                border: Border.all(
                                                  color: Colors.red.shade200,
                                                  width: 0.7,
                                                ),
                                                borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                              ),
                                              width: 65,
                                              height: 40,
                                              child: Center( // Center widget aligns the child in the center
                                                child: Text(
                                                  'RY : ${voltages[0]}',
                                                  style: const TextStyle(fontSize: 11),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 7,),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.yellow.shade50,
                                                border: Border.all(
                                                  color: Colors.yellow.shade500,
                                                  width: 0.7,
                                                ),
                                                borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                              ),
                                              width: 65,
                                              height: 40,
                                              child: Center(
                                                child: Text(
                                                  'YB : ${voltages[1]}',
                                                  style: const TextStyle(fontSize: 11),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 7,),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                border: Border.all(
                                                  color: Colors.blue.shade300,
                                                  width: 0.7,
                                                ),
                                                borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                              ),
                                              width: 65,
                                              height: 40,
                                              child: Center(
                                                child: Text(
                                                  'BR : ${voltages[2]}',
                                                  style: const TextStyle(fontSize: 11),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 7,),
                                      Container(
                                        width: 300,
                                        height: 25,
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            const SizedBox(width:85, child: Text('Current', style: TextStyle(color: Colors.black54),),),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                border: Border.all(
                                                  color: Colors.red.shade200,
                                                  width: 0.7,
                                                ),
                                                borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                              ),
                                              width: 65,
                                              height: 40,
                                              child: Center( // Center widget aligns the child in the center
                                                child: Text(
                                                  'RC : ${columns[0]}',
                                                  style: const TextStyle(fontSize: 11),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 7,),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.yellow.shade50,
                                                border: Border.all(
                                                  color: Colors.yellow.shade500,
                                                  width: 0.7,
                                                ),
                                                borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                              ),
                                              width: 65,
                                              height: 40,
                                              child: Center(
                                                child: Text(
                                                  'YC : ${columns[1]}',
                                                  style: const TextStyle(fontSize: 11),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 7,),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                border: Border.all(
                                                  color: Colors.blue.shade300,
                                                  width: 0.7,
                                                ),
                                                borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                              ),
                                              width: 65,
                                              height: 40,
                                              child: Center(
                                                child: Text(
                                                  'BC : ${columns[2]}',
                                                  style: const TextStyle(fontSize: 11),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 7,),
                                     /* icEnergy.length>1?Padding(
                                        padding: const EdgeInsets.only(bottom: 7),
                                        child: Container(
                                          width: 300,
                                          height: 25,
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              const SizedBox(width:229, child: Text('Instant Energy ', style: TextStyle(color: Colors.black54),),),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    icEnergy[0],
                                                    style: const TextStyle(fontSize: 12),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ):
                                      const SizedBox(),
                                      icEnergy.length>1?Padding(
                                        padding: const EdgeInsets.only(bottom: 7),
                                        child: Container(
                                          width: 300,
                                          height: 25,
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              const SizedBox(width:229, child: Text('Cumulative Energy ', style: TextStyle(color: Colors.black54),),),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade200,
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    icEnergy[1],
                                                    style: const TextStyle(fontSize: 12),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ):
                                      const SizedBox(),
                                      icPwrFactor.length>1?Padding(
                                        padding: const EdgeInsets.only(bottom: 7),
                                        child: Container(
                                          width: 300,
                                          height: 25,
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              const SizedBox(width:90, child: Text('Power Factor', style: TextStyle(color: Colors.black54),),),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  border: Border.all(
                                                    color: Colors.red.shade200,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center( // Center widget aligns the child in the center
                                                  child: Text(
                                                    'RPF : ${icPwrFactor[0]}',
                                                    style: const TextStyle(fontSize: 11),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 7,),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.yellow.shade50,
                                                  border: Border.all(
                                                    color: Colors.yellow.shade200,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    'YPF : ${icPwrFactor[1]}',
                                                    style: const TextStyle(fontSize: 11),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 7,),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  border: Border.all(
                                                    color: Colors.blue.shade200,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    'BPF : ${icPwrFactor[2]}',
                                                    style: const TextStyle(fontSize: 11),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ):
                                      const SizedBox(),
                                      icPwr.length>1?Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: Container(
                                          width: 300,
                                          height: 25,
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              const SizedBox(width:90, child: Text('Power', style: TextStyle(color: Colors.black54),),),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  border: Border.all(
                                                    color: Colors.red.shade200,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center( // Center widget aligns the child in the center
                                                  child: Text(
                                                    'RP : ${icPwr[0]}',
                                                    style: const TextStyle(fontSize: 11),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 7,),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.yellow.shade50,
                                                  border: Border.all(
                                                    color: Colors.yellow.shade200,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    'YP : ${icPwr[1]}',
                                                    style: const TextStyle(fontSize: 11),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 7,),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  border: Border.all(
                                                    color: Colors.blue.shade200,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    'BP : ${icPwr[2]}',
                                                    style: const TextStyle(fontSize: 11),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      ):
                                      const SizedBox(),
                                      int.parse(filteredPumps[index].reason)>0 && isTimeFormat(filteredPumps[index].setValue) ?
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 5),
                                        child: SizedBox(
                                          width: 300,
                                          height: 45,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  text: (filteredPumps[index].reason == '11'||filteredPumps[index].reason == '22') ? 'Cyc-Remain(hh:mm:ss)':'Set Amps : ',
                                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                  children: [
                                                    TextSpan(
                                                      text: '\n${filteredPumps[index].setValue}',
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight.bold, color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text.rich(
                                                TextSpan(
                                                  text: (filteredPumps[index].reason == '11'||filteredPumps[index].reason == '22') ? 'Max Time(hh:mm:ss)': 'Actual Amps : ' ,
                                                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                  children: [
                                                    TextSpan(
                                                      text: '\n${filteredPumps[index].actualValue}',
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight.bold, color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ):
                                      const SizedBox(),

                                      filteredPumps[index].topTankHigh.isNotEmpty?
                                      Padding(
                                        padding: const EdgeInsets.only(left:5, bottom: 5, top: 5),
                                        child: Column(
                                          children: filteredPumps[index].topTankHigh.map((item) {
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: 300,
                                                  height: 25,
                                                  color: Colors.transparent,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width:230, child: Text(item['SW_Name']!=null?' ${item['SW_Name']} ':
                                                      '${item['Name']} ', style: const TextStyle(color: Colors.black54),),),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade200,
                                                          border: Border.all(
                                                            color: Colors.grey.shade300,
                                                            width: 0.7,
                                                          ),
                                                          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                        ),
                                                        width: 65,
                                                        height: 40,
                                                        child: Center(
                                                          child: Text(
                                                            item['Value'],
                                                            style: const TextStyle(fontSize: 12),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ):
                                      const SizedBox(),

                                      filteredPumps[index].topTankLow.isNotEmpty?
                                      Padding(
                                        padding: const EdgeInsets.only(left:5, bottom: 5, top: 5),
                                        child: Column(
                                          children: filteredPumps[index].topTankLow.map((item) {
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: 300,
                                                  height: 25,
                                                  color: Colors.transparent,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width:235, child: Text(item['SW_Name']!=null?' ${item['SW_Name']} : ':
                                                      '${item['Name']} : ', style: const TextStyle(color: Colors.black54),),),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade200,
                                                          border: Border.all(
                                                            color: Colors.grey.shade300,
                                                            width: 0.7,
                                                          ),
                                                          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                        ),
                                                        width: 65,
                                                        height: 40,
                                                        child: Center(
                                                          child: Text(
                                                            item['Value'],
                                                            style: const TextStyle(fontSize: 12),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ):
                                      const SizedBox(),

                                      filteredPumps[index].sumpTankHigh.isNotEmpty?
                                      Padding(
                                        padding: const EdgeInsets.only(left:5, bottom: 5, top: 5),
                                        child: Column(
                                          children: filteredPumps[index].sumpTankHigh.map((item) {
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: 300,
                                                  height: 25,
                                                  color: Colors.transparent,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width:235, child: Text(item['SW_Name']!=null?' ${item['SW_Name']} : ':
                                                      '${item['Name']} : ', style: const TextStyle(color: Colors.black54),),),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade200,
                                                          border: Border.all(
                                                            color: Colors.grey.shade300,
                                                            width: 0.7,
                                                          ),
                                                          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                        ),
                                                        width: 65,
                                                        height: 40,
                                                        child: Center(
                                                          child: Text(
                                                            item['Value'],
                                                            style: const TextStyle(fontSize: 12),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ):
                                      const SizedBox(),

                                      filteredPumps[index].sumpTankLow.isNotEmpty?
                                      Padding(
                                        padding: const EdgeInsets.only(left:5, bottom: 5, top: 5),
                                        child: Column(
                                          children: filteredPumps[index].sumpTankLow.map((item) {
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  width: 300,
                                                  height: 25,
                                                  color: Colors.transparent,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width:235, child: Text(item['SW_Name']!=null?' ${item['SW_Name']} : ':
                                                      '${item['Name']} : ', style: const TextStyle(color: Colors.black54),),),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey.shade200,
                                                          border: Border.all(
                                                            color: Colors.grey.shade300,
                                                            width: 0.7,
                                                          ),
                                                          borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                        ),
                                                        width: 65,
                                                        height: 40,
                                                        child: Center(
                                                          child: Text(
                                                            item['Value'],
                                                            style: const TextStyle(fontSize: 12),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                      ):
                                      const SizedBox(),

                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          MaterialButton(
                                            color: Colors.green,
                                            textColor: Colors.white,
                                            onPressed: () {
                                              if(getPermissionStatusBySNo(context, 4)){
                                                String payload = '${filteredPumps[index].sNo},1,1';
                                                String payLoadFinal = jsonEncode({
                                                  "6200": [{"6201": payload}]
                                                });
                                                MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                                sentUserOperationToServer('${pump.swName?? pump.name} Start Manually', payLoadFinal);
                                                showSnakeBar('Pump of comment sent successfully');
                                                Navigator.pop(context);
                                              }else{
                                                Navigator.pop(context);
                                                GlobalSnackBar.show(context, 'Permission denied', 400);
                                              }
                                            },
                                            child: const Text('Start Manually',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 16,),
                                          MaterialButton(
                                            color: Colors.redAccent,
                                            textColor: Colors.white,
                                            onPressed: () {
                                              if(getPermissionStatusBySNo(context, 4)){
                                                String payload = '${filteredPumps[index].sNo},0,1';
                                                String payLoadFinal = jsonEncode({
                                                  "6200": [{"6201": payload}]
                                                });
                                                MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                                sentUserOperationToServer('${pump.swName ?? pump.name} Stop Manually', payLoadFinal);
                                                showSnakeBar('Pump of comment sent successfully');
                                                Navigator.pop(context);
                                              }else{
                                                Navigator.pop(context);
                                                GlobalSnackBar.show(context, 'Permission denied', 400);
                                              }
                                            },
                                            child: const Text('Stop Manually',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 16,),
                                        ],
                                      ),
                                      const SizedBox(height: 7,),*/
                                    ],
                                  ):
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 8,),
                                          MaterialButton(
                                            color: Colors.green,
                                            textColor: Colors.white,
                                            onPressed: () {
                                              /*if(getPermissionStatusBySNo(context, 4)){
                                                String payload = '${filteredPumps[index].sNo},1,1';
                                                String payLoadFinal = jsonEncode({
                                                  "6200": [{"6201": payload}]
                                                });
                                                MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                                sentUserOperationToServer('${pump.swName ?? pump.name} Start Manually', payLoadFinal);
                                                showSnakeBar('Pump of comment sent successfully');
                                                Navigator.pop(context);
                                              }else{
                                                Navigator.pop(context);
                                                GlobalSnackBar.show(context, 'Permission denied', 400);
                                              }*/
                                            },
                                            child: const Text('Start Manually',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(height: 8,),
                                          MaterialButton(
                                            color: Colors.redAccent,
                                            textColor: Colors.white,
                                            onPressed: () {
                                              /*if(getPermissionStatusBySNo(context, 4)){
                                                String payload = '${filteredPumps[index].sNo},0,1';
                                                String payLoadFinal = jsonEncode({
                                                  "6200": [{"6201": payload}]
                                                });
                                                MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                                sentUserOperationToServer('${pump.swName ?? pump.name} Stop Manually', payLoadFinal);
                                                showSnakeBar('Pump of comment sent successfully');
                                                Navigator.pop(context);
                                              }else{
                                                Navigator.pop(context);
                                                GlobalSnackBar.show(context, 'Permission denied', 400);
                                              }*/

                                            },
                                            child: const Text('Stop Manually',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(height: 8,),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            isSourcePump? Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Spacer(),
                                  MaterialButton(
                                    color: Colors.green,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      String payload = '${pump.sNo},1,1';
                                      String payLoadFinal = jsonEncode({
                                        "6200": {"6201": payload}
                                      });
                                      MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                                      sentUserOperationToServer('${pump.name} Start Manually', payLoadFinal);
                                      GlobalSnackBar.show(context, 'Pump start comment sent successfully', 200);
                                      Navigator.pop(context);

                                      /*if(getPermissionStatusBySNo(context, 4)){
                                        String payload = '${filteredPumps[index].sNo},1,1';
                                        String payLoadFinal = jsonEncode({
                                          "6200": [{"6201": payload}]
                                        });
                                        MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                        sentUserOperationToServer('${pump.swName ?? pump.name} Start Manually', payLoadFinal);
                                        showSnakeBar('Pump of comment sent successfully');
                                        Navigator.pop(context);
                                      }else{
                                        Navigator.pop(context);
                                        GlobalSnackBar.show(context, 'Permission denied', 400);
                                      }*/
                                    },
                                    child: const Text('Start Manually',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8,),
                                  MaterialButton(
                                    color: Colors.redAccent,
                                    textColor: Colors.white,
                                    onPressed: () {

                                      String payload = '${pump.sNo},0,1';
                                      String payLoadFinal = jsonEncode({
                                        "6200": {"6201": payload}
                                      });
                                      MqttService().topicToPublishAndItsMessage(payLoadFinal, '${AppConstants.publishTopic}/$deviceId');
                                      sentUserOperationToServer('${pump.name} Stop Manually', payLoadFinal);
                                      GlobalSnackBar.show(context, 'Pump stop comment sent successfully', 200);
                                      Navigator.pop(context);

                                      /*if(getPermissionStatusBySNo(context, 4)){
                                            String payload = '${filteredPumps[index].sNo},0,1';
                                            String payLoadFinal = jsonEncode({
                                              "6200": [{"6201": payload}]
                                            });
                                            MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                            sentUserOperationToServer('${pump.swName ?? pump.name} Stop Manually', payLoadFinal);
                                            showSnakeBar('Pump of comment sent successfully');
                                            Navigator.pop(context);
                                          }else{
                                            Navigator.pop(context);
                                            GlobalSnackBar.show(context, 'Permission denied', 400);
                                          }*/

                                    },
                                    child: const Text('Stop Manually',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8,),
                                ],
                              ),
                            ):
                            const SizedBox(),
                          ],
                        );
                      },
                      onPop: () => print('Popover was popped!'),
                      direction: PopoverDirection.right,
                      width: voltKeyExists? 300:140,
                      arrowHeight: 15,
                      arrowWidth: 30,
                      barrierColor: Colors.black54,
                      arrowDxOffset: (position.dx + 210)-25,


                      /*arrowDxOffset: pump.length==1?(position.dx+25)+(index*70)-140:
                      filteredPumps.length==2?(position.dx+25)+(index*70)-210:
                      filteredPumps.length==3?(position.dx+25)+(index*70)-280:
                      filteredPumps.length==4?(position.dx+25)+(index*70)-350:
                      filteredPumps.length==5?(position.dx+25)+(index*70)-420:
                      filteredPumps.length==6?(position.dx+25)+(index*70)-490:
                      filteredPumps.length==7?(position.dx+25)+(index*70)-560:
                      filteredPumps.length==8?(position.dx+25)+(index*70)-630:
                      filteredPumps.length==9?(position.dx+25)+(index*70)-700:
                      filteredPumps.length==10?(position.dx+25)+(index*70)-770:
                      filteredPumps.length==11?(position.dx+25)+(index*70)-840:
                      filteredPumps.length==12?(position.dx+25)+(index*70)-910:
                      (position.dx+25)+(index*70)-280,*/
                    );
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                    minimumSize: WidgetStateProperty.all(Size.zero),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: AppConstants.getAsset('pump', pump.status, ''),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pump.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),

        pump.onDelayLeft != '00:00:00' && Formatters().isValidTimeFormat(pump.onDelayLeft)?
        Positioned(
          top: 40,
          left: 7.5,
          child: Container(
            width: 55,
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
              border: Border.all(color: Colors.green, width: .50),
            ),
            child: ChangeNotifierProvider(
              create: (_) => DurationNotifierPump(pump.onDelayLeft),
              child: Stack(
                children: [
                  Consumer<DurationNotifierPump>(
                    builder: (context, durationNotifier, _) {
                      return Center(
                        child: Column(
                          children: [
                            const Text(
                              "On delay",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 3, right: 3),
                              child: Divider(
                                height: 0,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              durationNotifier.onDelayLeft, // Updates every second
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ):
        const SizedBox(),

        int.tryParse(pump.reason) != null && int.parse(pump.reason) > 0 && int.parse(pump.reason)!=31
            ? Positioned(
          top: 1,
          left: 37.5,
          child: Tooltip(
            message: vm.getContentByCode(int.parse(pump.reason)),
            textStyle: const TextStyle(color: Colors.black54),
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const CircleAvatar(
              radius: 11,
              backgroundColor: Colors.deepOrangeAccent,
              child: Icon(
                Icons.info_outline,
                size: 17,
                color: Colors.white,
              ),
            ),
          ),
        ):
        const SizedBox(),

        (pump.reason == '11'||pump.reason == '22')?
        Positioned(
          top: 40,
          left: 0,
          child: Container(
            decoration: BoxDecoration(
              color: pump.status==1?Colors.greenAccent:Colors.yellowAccent,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
              border: Border.all(color: Colors.grey, width: .50),
            ),
            width: 67,
            child: Center(
              child: ValueListenableBuilder<String>(
                valueListenable: Provider.of<DurationNotifier>(context).onDelayLeft,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      Text(
                        'Max: ${pump.actualValue}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 3, right: 3),
                        child: Divider(
                          height: 0,
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                      ),
                      Text(
                        pump.status==1?'cRm: ${pump.setValue}':'Brk: ${pump.setValue}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ):
        pump.reason == '8' && vm.isTimeFormat(pump.actualValue.split('_').last)?
        Positioned(
          top: 40,
          left: 0,
          child: Container(
            decoration: BoxDecoration(
              color: pump.status==1?Colors.greenAccent:Colors.yellowAccent,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
              border: Border.all(color: Colors.grey, width: .50),
            ),
            width: 67,
            child: Center(
              child: ValueListenableBuilder<String>(
                valueListenable: Provider.of<DurationNotifier>(context).onDelayLeft,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      const Text(
                        'Restart within',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 3, right: 3),
                        child: Divider(
                          height: 0,
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                      ),
                      Text(pump.actualValue.split('_').last,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ):
        const SizedBox(),
      ],
    );
  }

  Widget displayFilter(Filters filter){
    return Stack(
      children: [
        SizedBox(
            width: 70,
            child: Divider(thickness: 2, color: Colors.grey.shade300, height: 10)
        ),
        SizedBox(
          width: 70,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: AppConstants.getAsset('filter', filter.status, ''),
              ),
              const SizedBox(height: 4),
              Text(
                filter.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget displayFilterSite(context, List<FilterSite> filterSite){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for(int i=0; i<filterSite.length; i++)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      filterSite[i].pressureIn != null?
                      SizedBox(
                        width: 70,
                        height: 70,
                        child : Stack(
                          children: [
                            Image.asset('assets/png/dp_prs_sensor.png',),
                            Positioned(
                              top: 42,
                              left: 5,
                              child: Container(
                                width: 60,
                                height: 17,
                                decoration: BoxDecoration(
                                  color:Colors.yellow,
                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.grey, width: .50,),
                                ),
                                child: Center(
                                  child: Text('${filterSite[i].pressureIn?.value} bar', style: const TextStyle(
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
                      ):
                      const SizedBox(),
                      SizedBox(
                        height: 91,
                        width: filterSite[i].filters.length * 70,
                        child: ListView.builder(
                          itemCount: filterSite[i].filters.length,
                          scrollDirection: Axis.horizontal,
                          //reverse: true,
                          itemBuilder: (BuildContext context, int flIndex) {
                            return Column(
                              children: [
                                Stack(
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      height: 70,
                                      child: AppConstants.getAsset('filter', filterSite[i].filters[flIndex].status,''),
                                    ),
                                    filterSite[i].filters[flIndex].onDelayLeft != '00:00:00' &&
                                        Formatters().isValidTimeFormat(filterSite[i].filters[flIndex].onDelayLeft)?
                                    Positioned(
                                      top: 55,
                                      left: 7.5,
                                      child: Container(
                                        width: 55,
                                        decoration: BoxDecoration(
                                          color:Colors.greenAccent,
                                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                                          border: Border.all(color: Colors.grey, width: .50,),
                                        ),
                                        child: ChangeNotifierProvider(
                                          create: (_) => DurationNotifierPump(filterSite[i].filters[flIndex].onDelayLeft),
                                          child: Stack(
                                            children: [
                                              Consumer<DurationNotifierPump>(
                                                builder: (context, durationNotifier, _) {
                                                  return Center(
                                                    child: Text(filterSite[i].filters[flIndex].onDelayLeft,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ):
                                    const SizedBox(),

                                    /*Positioned(
                                      top: 55,
                                      left: 7.5,
                                      child: filterSite[i].filters[flIndex].onDelayLeft!='00:00:00'? filterSite[i].filters[flIndex].status == (flIndex+1) ?
                                      Container(
                                        decoration: BoxDecoration(
                                          color:Colors.greenAccent,
                                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                                          border: Border.all(color: Colors.grey, width: .50,),
                                        ),
                                        width: 55,
                                        child: Center(
                                          child: Text(filterSite[i].filters[flIndex].onDelayLeft,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ) :
                                      const SizedBox(): const SizedBox(),
                                    ),*/
                                    /*Positioned(
                                      top: 0,
                                      left: 45,
                                      child: filterSite[i].pressureIn!=0 && filterSite[i].filters.length-1==flIndex? Container(
                                        width:25,
                                        decoration: BoxDecoration(
                                          color:Colors.yellow,
                                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                                          border: Border.all(color: Colors.grey, width: .50,),
                                        ),
                                        child: Center(
                                          child: Text('${filterSite[i]['DpValue']}', style: const TextStyle(fontSize: 10),),
                                        ),

                                      ) :
                                      const SizedBox(),
                                    ),*/
                                  ],
                                ),
                                SizedBox(
                                  width: 70,
                                  height: 20,
                                  child: Center(
                                    child: Text(filterSite[i].filters[flIndex].name, style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      filterSite[i].pressureOut != null?
                      SizedBox(
                        width: 70,
                        height: 70,
                        child : Stack(
                          children: [
                            Image.asset('assets/png/dp_prs_sensor.png',),
                            Positioned(
                              top: 42,
                              left: 5,
                              child: Container(
                                width: 60,
                                height: 17,
                                decoration: BoxDecoration(
                                  color:Colors.yellow,
                                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                                  border: Border.all(color: Colors.grey, width: .50,),
                                ),
                                child: Center(
                                  child: Text('${filterSite[i].pressureOut?.value} bar', style: const TextStyle(
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
                      ):
                      const SizedBox(),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(3),
                    ),

                    width: filterSite[i].pressureIn != null? filterSite[i].filters.length * 70+70:
                    filterSite[i].filters.length * 70,
                    height: 20,
                    child: Center(
                      child: Text(filterSite[i].name, style: TextStyle(color: Theme.of(context).primaryColorDark, fontSize: 11),),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget displayFertilizerSite(context, List<FertilizerSite> fertilizerSite){
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for(int fIndex=0; fIndex<fertilizerSite.length; fIndex++)
          SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if(fIndex!=0)
                        SizedBox(
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
                        ),
                      SizedBox(
                          width: 70,
                          height: 120,
                          child : Stack(
                            children: [
                              AppConstants.getAsset('booster', fertilizerSite[fIndex].boosterPump[0].status,''),
                              Positioned(
                                top: 70,
                                left: 15,
                                child: fertilizerSite[fIndex].selector.isNotEmpty ? const SizedBox(
                                  width: 50,
                                  child: Center(
                                    child: Text('Selector' , style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    ),
                                  ),
                                ) :
                                const SizedBox(),
                              ),
                              Positioned(
                                top: 85,
                                left: 18,
                                child: fertilizerSite[fIndex].selector.isNotEmpty ? Container(
                                  decoration: BoxDecoration(
                                    color: fertilizerSite[fIndex].selector[0]['Status']==0? Colors.grey.shade300:
                                    fertilizerSite[fIndex].selector[0]['Status']==1? Colors.greenAccent:
                                    fertilizerSite[fIndex].selector[0]['Status']==2? Colors.orangeAccent:Colors.redAccent,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  width: 45,
                                  height: 22,
                                  /*child: Center(
                                    child: Text(fertilizerSite[fIndex].selector[0]['Status']!=0?
                                    fertilizerSite[fIndex].selector[0]['Name'] : '--' , style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    ),
                                  ),*/
                                ) :
                                const SizedBox(),
                              ),
                              Positioned(
                                top: 115,
                                left: 8.3,
                                child: Image.asset('assets/png/dp_frt_vertical_pipe.png', width: 9.5, height: 37,),
                              ),
                            ],
                          )
                      ),
                      SizedBox(
                        width: fertilizerSite[fIndex].channel.length * 70,
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: fertilizerSite[fIndex].channel.length,
                          itemBuilder: (BuildContext context, int index) {
                            var channel = fertilizerSite[fIndex].channel[index];
                            double fertilizerQty = 0.0;
                            var qtyValue = channel.qty;
                            fertilizerQty = double.parse(qtyValue);

                            var fertilizerLeftVal = channel.qtyLeft;
                            channel.qtyLeft = fertilizerLeftVal;

                            return SizedBox(
                              width: 70,
                              height: 120,
                              child: Stack(
                                children: [
                                  buildFertilizerImage(index, channel.status, fertilizerSite[fIndex].channel.length, fertilizerSite[fIndex].agitator),
                                  Positioned(
                                    top: 52,
                                    left: 6,
                                    child: CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Colors.teal.shade100,
                                      child: Text('${index+1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),),
                                    ),
                                  ),
                                  Positioned(
                                    top: 50,
                                    left: 18,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      width: 60,
                                      child: Center(
                                        child: Text(channel.fertMethod=='1' || channel.fertMethod=='3'? channel.duration :
                                        '${fertilizerQty.toStringAsFixed(2)} L', style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 65,
                                    left: 18,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      width: 60,
                                      child: Center(
                                        child: Text('${channel.flowRate_LpH}-lph', style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 103,
                                    left: 0,
                                    child: channel.status !=0
                                        &&
                                        channel.selected!='_'
                                        &&
                                        channel.durationLeft !='00:00:00'
                                        ?
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      width: 50,
                                      child: Center(
                                        child: Text(channel.fertMethod=='1' || channel.fertMethod=='3'
                                            ? channel.durationLeft
                                            : '${channel.qtyLeft} L' , style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        ),
                                      ),
                                    ) :
                                    const SizedBox(),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      fertilizerSite[fIndex].agitator.isNotEmpty ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: fertilizerSite[fIndex].agitator.map<Widget>((agitator) {
                          return Column(
                            children: [
                              SizedBox(
                                width: 59,
                                height: 34,
                                child: AppConstants.getAsset('agitator', agitator.status, '',),
                              ),
                              Center(child: Text(agitator.name, style: const TextStyle(fontSize: 10, color: Colors.black54),)),
                            ],
                          );
                        }).toList(), // Convert the map result to a list of widgets
                      ):
                      const SizedBox(),

                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: (fertilizerSite[fIndex].channel.length * 79 + fertilizerSite[fIndex].agitator.length*59)+50,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                        child: Row(
                          children: [
                            if(fIndex!=0)
                              const Row(
                                children: [
                                  VerticalDivider(width: 0,color: Colors.black12),
                                  SizedBox(width: 4.0,),
                                  VerticalDivider(width: 0,color: Colors.black12),
                                ],
                              ),
                            Row(
                              children: [
                                const SizedBox(width: 10.5,),
                                const VerticalDivider(width: 0,color: Colors.black12),
                                const SizedBox(width: 4.0,),
                                const VerticalDivider(width: 0,color: Colors.black12),
                                const SizedBox(width: 5.0,),

                                fertilizerSite[fIndex].ec!.isNotEmpty || fertilizerSite[fIndex].ph!.isNotEmpty?
                                SizedBox(
                                  width: fertilizerSite[fIndex].ec!.length > 1 ? 110 : 60,
                                  height: 24,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      fertilizerSite[fIndex].ec!.isNotEmpty?
                                      SizedBox(
                                        height: 12,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: fertilizerSite[fIndex].ec!.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Center(
                                                    child: Text(
                                                      'Ec : ',
                                                      style: TextStyle(
                                                          fontSize: 10, fontWeight: FontWeight.normal),
                                                    )),
                                                Center(
                                                  child: Text(
                                                    double.parse(
                                                        fertilizerSite[fIndex].ec![index].value)
                                                        .toStringAsFixed(2),
                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ):
                                      const SizedBox(),

                                      fertilizerSite[fIndex].ph!.isNotEmpty?
                                      SizedBox(
                                        height: 12,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: fertilizerSite[fIndex].ph!.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Row(
                                              children: [
                                                const Center(
                                                    child: Text(
                                                      'pH : ',
                                                      style: TextStyle(
                                                          fontSize: 10, fontWeight: FontWeight.normal),
                                                    )),
                                                Center(
                                                  child: Text(
                                                    double.parse(
                                                        fertilizerSite[fIndex].ph![index].value)
                                                        .toStringAsFixed(2),
                                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ):
                                      const SizedBox(),
                                    ],
                                  ),
                                ):
                                const SizedBox(),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  width: (fertilizerSite[fIndex].channel.length * 67) - (fertilizerSite[fIndex].ec!.isNotEmpty ?
                                  fertilizerSite[fIndex].ec!.length * 70 : fertilizerSite[fIndex].ph!.length * 70),
                                  child: Center(
                                    child: Text(fertilizerSite[fIndex].name, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 11),),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      /*const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 14),
                            child: Divider(height: 0, color: Colors.black12),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10.5),
                            child: Divider(height: 6, color: Colors.black12),
                          ),
                        ],
                      )*/
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget buildFertilizerImage(int cIndex, int status, int cheLength, List agitatorList) {
    String imageName;
    if(cIndex == cheLength - 1){
      if(agitatorList.isNotEmpty){
        imageName='dp_frt_channel_last_aj';
      }else{
        imageName='dp_frt_channel_last';
      }
    }else{
      if(agitatorList.isNotEmpty){
        if(cIndex==0){
          imageName='dp_frt_channel_first_aj';
        }else{
          imageName='dp_frt_channel_center_aj';
        }
      }else{
        imageName='dp_frt_channel_center';
      }
    }

    switch (status) {
      case 0:
        imageName += '.png';
        break;
      case 1:
        imageName += '_g.png';
        break;
      case 2:
        imageName += '_y.png';
        break;
      case 3:
        imageName += '_r.png';
        break;
      case 4:
        imageName += '.png';
        break;
      default:
        imageName += '.png';
    }

    return Image.asset('assets/png/$imageName');

  }

  void updatePumpStatus(List<WaterSource> waterSource, List<dynamic> filteredPumpStatus) {
    for (var source in waterSource) {
      for (var pump in source.outletPump) {
        int? status = getStatus(filteredPumpStatus, pump.sNo);
        if (status != null) {
          pump.status = status;
        } else {
          print("Serial Number ${pump.sNo} not found");
        }
      }
    }
  }

  void updateValveStatus(List<IrrigationLineData> lineData, List<dynamic> filteredValveStatus) {

    for (var line in lineData) {
      for (var vl in line.valves) {
        int? status = getStatus(filteredValveStatus, vl.sNo);
        if (status != null) {
          vl.status = status;
        } else {
          print("Serial Number ${vl.sNo} not found");
        }
      }
    }
  }

  int? getStatus(List<dynamic> outputOnOffLiveMessage, double serialNumber) {
    for (int i = 0; i < outputOnOffLiveMessage.length; i++) {
      List<String> parts = outputOnOffLiveMessage[i].split(',');
      double? serial = double.tryParse(parts[0]);

      if (serial != null && serial == serialNumber) {
        return int.parse(parts[1]);
      }
    }
    return null;
  }

  void sentUserOperationToServer(String msg, String data) async
  {
    Map<String, Object> body = {"userId": customerId, "controllerId": controllerId, "messageStatus": msg, "hardware": jsonDecode(data), "createUser": customerId};
    final response = await Repository(HttpService()).createUserSentAndReceivedMessageManually(body);
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

}

class SourceWidget extends StatelessWidget {
  final WaterSource source;
  final int index;
  const SourceWidget({super.key, required this.source, required this.index});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double gridWidth = constraints.maxWidth;
        return Stack(
          children: [
            SizedBox(
              width: gridWidth,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 33 : 0),
                    child: Divider(thickness: 2, color: Colors.grey.shade300, height: 5.5),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 37 : 0),
                    child: Divider(thickness: 2, color: Colors.grey.shade300, height: 4.5),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 70,
              height: 95,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 15,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          VerticalDivider(thickness: 1, color: Colors.grey.shade400, width: 3),
                          VerticalDivider(thickness: 1, color: Colors.grey.shade400, width: 5),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade300,
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    source.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (source.level != null) ...[
              Positioned(
                top: 25,
                left: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: const BorderRadius.all(Radius.circular(2)),
                    border: Border.all(color: Colors.grey, width: .50),
                  ),
                  width: 60,
                  height: 18,
                  child: Center(
                    child: Text(
                      '${source.level!.percentage!} feet',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 5,
                child: SizedBox(
                  width: 60,
                  child: Center(
                    child: Text(
                      '${source.valves} %',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );

  }
}

class PumpWidget extends StatelessWidget {
  final Pump pump;
  final PumpStationViewModel vm;
  final int customerId, controllerId;
  const PumpWidget({super.key, required this.pump, required this.vm, required this.customerId, required this.controllerId});

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        double gridWidth = constraints.maxWidth;
        return Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Tooltip(
                  message: 'View more details',
                  child: TextButton(
                    onPressed: () {
                      final RenderBox button = context.findRenderObject() as RenderBox;
                      final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                      final position = button.localToGlobal(Offset.zero, ancestor: overlay);

                      bool voltKeyExists = pump.voltage.isNotEmpty;
                      //int signalStrength = voltKeyExists? int.parse(filteredPumps[index].signalStrength):0;
                      //int batteryVolt = voltKeyExists? int.parse(filteredPumps[index].battery):0;
                      List<String> voltages = voltKeyExists? pump.voltage.split('_'):[];
                      List<String> currents = voltKeyExists? pump.current.split('_'):[];

                      //List<String> icEnergy = voltKeyExists? filteredPumps[index].icEnergy.split(','):[];
                      //List<String> icPwrFactor = voltKeyExists? filteredPumps[index].pwrFactor.split(','):[];
                      //List<String> icPwr = voltKeyExists? filteredPumps[index].pwr.split(','):[];

                      //List<dynamic> pumpLevel = voltKeyExists? filteredPumps[index].level:[];

                      List<String> columns = ['-', '-', '-'];

                      if (voltKeyExists) {
                        for (var pair in currents) {
                          String sanitizedPair = pair.trim().replaceAll(RegExp(r'^"|"$'), '');
                          List<String> parts = sanitizedPair.split(':');
                          if (parts.length != 2) {
                            print('Error: Pair "$sanitizedPair" does not have the expected format');
                            continue;
                          }

                          try {
                            int columnIndex = int.parse(parts[0].trim()) - 1;
                            if (columnIndex >= 0 && columnIndex < columns.length) {
                              columns[columnIndex] = parts[1].trim();
                            } else {
                              print('Error: Column index $columnIndex is out of bounds');
                            }
                          } catch (e) {
                            print('Error parsing column index from "$sanitizedPair": $e');
                          }
                        }
                      }

                      showPopover(
                        context: context,
                        bodyBuilder: (context) {
                          //MqttPayloadProvider provider = Provider.of<MqttPayloadProvider>(context, listen: true);
                          Future.delayed(const Duration(seconds: 2));
                          vm.popoverUpdateNotifier.value++;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ValueListenableBuilder<int>(
                                valueListenable: vm.popoverUpdateNotifier,
                                builder: (BuildContext context, int value, Widget? child) {

                                  return Material(
                                    child: voltKeyExists?Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 315,
                                          height: 35,
                                          color: Colors.teal,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const SizedBox(width: 8,),
                                              Text.rich(
                                                TextSpan(
                                                  text: 'Version : ',
                                                  style: const TextStyle(color: Colors.white54),
                                                  children: [
                                                    /*TextSpan(
                                                      text: filteredPumps[index].version,
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight.bold, color: Colors.white),
                                                    ),*/
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              /*Icon(signalStrength == 0 ? Icons.wifi_off :
                                              signalStrength >= 1 && signalStrength <= 20 ?
                                              Icons.network_wifi_1_bar_outlined :
                                              signalStrength >= 21 && signalStrength <= 40 ?
                                              Icons.network_wifi_2_bar_outlined :
                                              signalStrength >= 41 && signalStrength <= 60 ?
                                              Icons.network_wifi_3_bar_outlined :
                                              signalStrength >= 61 && signalStrength <= 80 ?
                                              Icons.network_wifi_3_bar_outlined :
                                              Icons.wifi, color: signalStrength == 0?Colors.white54:Colors.white,),
                                              const SizedBox(width: 5,),
                                              Text('$signalStrength%', style: const TextStyle(color: Colors.white),),*/

                                              /* const SizedBox(width: 5,),
                                              batteryVolt==0?const Icon(Icons.battery_0_bar, color: Colors.white54,):
                                              batteryVolt>0&&batteryVolt<=10?const Icon(Icons.battery_1_bar_rounded, color: Colors.white,):
                                              batteryVolt>10&&batteryVolt<=30?const Icon(Icons.battery_2_bar_rounded, color: Colors.white,):
                                              batteryVolt>30&&batteryVolt<=50?const Icon(Icons.battery_3_bar_rounded, color: Colors.white,):
                                              batteryVolt>50&&batteryVolt<=70?const Icon(Icons.battery_4_bar_rounded, color: Colors.white,):
                                              batteryVolt>70&&batteryVolt<=90?const Icon(Icons.battery_5_bar_rounded, color: Colors.white,):
                                              const Icon(Icons.battery_full, color: Colors.white,),
                                              Text('$batteryVolt%', style: const TextStyle(color: Colors.white),),*/

                                              const SizedBox(width: 8,),
                                            ],
                                          ),
                                        ),
                                        int.parse(pump.reason)>0 && int.parse(pump.reason)!=31 ? Container(
                                          width: 315,
                                          height: 33,
                                          color: Colors.orange.shade100,
                                          child: Row(
                                            children: [
                                              Expanded(child: Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: Text(
                                                  pump.reason == '8' && vm.isTimeFormat(pump.actualValue.split('_').last)
                                                      ? '${vm.getContentByCode(int.parse(pump.reason))}, It will be restart automatically within ${pump.actualValue.split('_').last} (hh:mm:ss)'
                                                      :vm.getContentByCode(int.parse(pump.reason)),
                                                  style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.normal),
                                                ),
                                              )),
                                              (!PumpStationViewModel.excludedReasons.contains(pump.reason)) ? SizedBox(
                                                height:23,
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: Colors.redAccent.shade200,
                                                    textStyle: const TextStyle(color: Colors.white),
                                                  ),
                                                  onPressed: () => vm.resetPump(context, 'deviceId', pump.sNo, pump.name, customerId, controllerId, customerId),
                                                  child: const Text('Reset', style: TextStyle(fontSize: 12, color: Colors.white),),
                                                ),
                                              ):const SizedBox(),
                                              const SizedBox(width: 5,),
                                            ],
                                          ),
                                        ):
                                        const SizedBox(),
                                        Container(
                                          width: 300,
                                          height: 25,
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              const SizedBox(width:100, child: Text('Phase', style: TextStyle(color: Colors.black54),),),
                                              const Spacer(),
                                              CircleAvatar(radius: 7, backgroundColor: int.parse(pump.phase)>0? Colors.green: Colors.red.shade100,),
                                              const VerticalDivider(color: Colors.transparent,),
                                              CircleAvatar(radius: 7, backgroundColor: int.parse(pump.phase)>1? Colors.green: Colors.red.shade100,),
                                              const VerticalDivider(color: Colors.transparent,),
                                              CircleAvatar(radius: 7, backgroundColor: int.parse(pump.phase)>2? Colors.green: Colors.red.shade100,),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5,),
                                        Container(
                                          width: 300,
                                          height: 25,
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              const SizedBox(width:85, child: Text('Voltage', style: TextStyle(color: Colors.black54),),),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  border: Border.all(
                                                    color: Colors.red.shade200,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center( // Center widget aligns the child in the center
                                                  child: Text(
                                                    'RY : ${voltages[0]}',
                                                    style: const TextStyle(fontSize: 11),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 7,),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.yellow.shade50,
                                                  border: Border.all(
                                                    color: Colors.yellow.shade500,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    'YB : ${voltages[1]}',
                                                    style: const TextStyle(fontSize: 11),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 7,),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  border: Border.all(
                                                    color: Colors.blue.shade300,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    'BR : ${voltages[2]}',
                                                    style: const TextStyle(fontSize: 11),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 7,),
                                        Container(
                                          width: 300,
                                          height: 25,
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              const SizedBox(width:85, child: Text('Current', style: TextStyle(color: Colors.black54),),),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  border: Border.all(
                                                    color: Colors.red.shade200,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center( // Center widget aligns the child in the center
                                                  child: Text(
                                                    'RC : ${columns[0]}',
                                                    style: const TextStyle(fontSize: 11),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 7,),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.yellow.shade50,
                                                  border: Border.all(
                                                    color: Colors.yellow.shade500,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    'YC : ${columns[1]}',
                                                    style: const TextStyle(fontSize: 11),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 7,),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  border: Border.all(
                                                    color: Colors.blue.shade300,
                                                    width: 0.7,
                                                  ),
                                                  borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                ),
                                                width: 65,
                                                height: 40,
                                                child: Center(
                                                  child: Text(
                                                    'BC : ${columns[2]}',
                                                    style: const TextStyle(fontSize: 11),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 7,),
                                        /* icEnergy.length>1?Padding(
                                          padding: const EdgeInsets.only(bottom: 7),
                                          child: Container(
                                            width: 300,
                                            height: 25,
                                            color: Colors.transparent,
                                            child: Row(
                                              children: [
                                                const SizedBox(width:229, child: Text('Instant Energy ', style: TextStyle(color: Colors.black54),),),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    border: Border.all(
                                                      color: Colors.grey.shade300,
                                                      width: 0.7,
                                                    ),
                                                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                  ),
                                                  width: 65,
                                                  height: 40,
                                                  child: Center(
                                                    child: Text(
                                                      icEnergy[0],
                                                      style: const TextStyle(fontSize: 12),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ):
                                        const SizedBox(),
                                        icEnergy.length>1?Padding(
                                          padding: const EdgeInsets.only(bottom: 7),
                                          child: Container(
                                            width: 300,
                                            height: 25,
                                            color: Colors.transparent,
                                            child: Row(
                                              children: [
                                                const SizedBox(width:229, child: Text('Cumulative Energy ', style: TextStyle(color: Colors.black54),),),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    border: Border.all(
                                                      color: Colors.grey.shade300,
                                                      width: 0.7,
                                                    ),
                                                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                  ),
                                                  width: 65,
                                                  height: 40,
                                                  child: Center(
                                                    child: Text(
                                                      icEnergy[1],
                                                      style: const TextStyle(fontSize: 12),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ):
                                        const SizedBox(),
                                        icPwrFactor.length>1?Padding(
                                          padding: const EdgeInsets.only(bottom: 7),
                                          child: Container(
                                            width: 300,
                                            height: 25,
                                            color: Colors.transparent,
                                            child: Row(
                                              children: [
                                                const SizedBox(width:90, child: Text('Power Factor', style: TextStyle(color: Colors.black54),),),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade50,
                                                    border: Border.all(
                                                      color: Colors.red.shade200,
                                                      width: 0.7,
                                                    ),
                                                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                  ),
                                                  width: 65,
                                                  height: 40,
                                                  child: Center( // Center widget aligns the child in the center
                                                    child: Text(
                                                      'RPF : ${icPwrFactor[0]}',
                                                      style: const TextStyle(fontSize: 11),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 7,),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.yellow.shade50,
                                                    border: Border.all(
                                                      color: Colors.yellow.shade200,
                                                      width: 0.7,
                                                    ),
                                                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                  ),
                                                  width: 65,
                                                  height: 40,
                                                  child: Center(
                                                    child: Text(
                                                      'YPF : ${icPwrFactor[1]}',
                                                      style: const TextStyle(fontSize: 11),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 7,),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade50,
                                                    border: Border.all(
                                                      color: Colors.blue.shade200,
                                                      width: 0.7,
                                                    ),
                                                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                  ),
                                                  width: 65,
                                                  height: 40,
                                                  child: Center(
                                                    child: Text(
                                                      'BPF : ${icPwrFactor[2]}',
                                                      style: const TextStyle(fontSize: 11),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ):
                                        const SizedBox(),
                                        icPwr.length>1?Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child: Container(
                                            width: 300,
                                            height: 25,
                                            color: Colors.transparent,
                                            child: Row(
                                              children: [
                                                const SizedBox(width:90, child: Text('Power', style: TextStyle(color: Colors.black54),),),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade50,
                                                    border: Border.all(
                                                      color: Colors.red.shade200,
                                                      width: 0.7,
                                                    ),
                                                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                  ),
                                                  width: 65,
                                                  height: 40,
                                                  child: Center( // Center widget aligns the child in the center
                                                    child: Text(
                                                      'RP : ${icPwr[0]}',
                                                      style: const TextStyle(fontSize: 11),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 7,),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.yellow.shade50,
                                                    border: Border.all(
                                                      color: Colors.yellow.shade200,
                                                      width: 0.7,
                                                    ),
                                                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                  ),
                                                  width: 65,
                                                  height: 40,
                                                  child: Center(
                                                    child: Text(
                                                      'YP : ${icPwr[1]}',
                                                      style: const TextStyle(fontSize: 11),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 7,),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade50,
                                                    border: Border.all(
                                                      color: Colors.blue.shade200,
                                                      width: 0.7,
                                                    ),
                                                    borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                  ),
                                                  width: 65,
                                                  height: 40,
                                                  child: Center(
                                                    child: Text(
                                                      'BP : ${icPwr[2]}',
                                                      style: const TextStyle(fontSize: 11),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ):
                                        const SizedBox(),
                                        int.parse(filteredPumps[index].reason)>0 && isTimeFormat(filteredPumps[index].setValue) ?
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 5),
                                          child: SizedBox(
                                            width: 300,
                                            height: 45,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text.rich(
                                                  TextSpan(
                                                    text: (filteredPumps[index].reason == '11'||filteredPumps[index].reason == '22') ? 'Cyc-Remain(hh:mm:ss)':'Set Amps : ',
                                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                    children: [
                                                      TextSpan(
                                                        text: '\n${filteredPumps[index].setValue}',
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.bold, color: Colors.black),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text.rich(
                                                  TextSpan(
                                                    text: (filteredPumps[index].reason == '11'||filteredPumps[index].reason == '22') ? 'Max Time(hh:mm:ss)': 'Actual Amps : ' ,
                                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                                    children: [
                                                      TextSpan(
                                                        text: '\n${filteredPumps[index].actualValue}',
                                                        style: const TextStyle(
                                                            fontWeight: FontWeight.bold, color: Colors.black),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ):
                                        const SizedBox(),

                                        filteredPumps[index].topTankHigh.isNotEmpty?
                                        Padding(
                                          padding: const EdgeInsets.only(left:5, bottom: 5, top: 5),
                                          child: Column(
                                            children: filteredPumps[index].topTankHigh.map((item) {
                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    width: 300,
                                                    height: 25,
                                                    color: Colors.transparent,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width:230, child: Text(item['SW_Name']!=null?' ${item['SW_Name']} ':
                                                        '${item['Name']} ', style: const TextStyle(color: Colors.black54),),),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey.shade200,
                                                            border: Border.all(
                                                              color: Colors.grey.shade300,
                                                              width: 0.7,
                                                            ),
                                                            borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                          ),
                                                          width: 65,
                                                          height: 40,
                                                          child: Center(
                                                            child: Text(
                                                              item['Value'],
                                                              style: const TextStyle(fontSize: 12),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ):
                                        const SizedBox(),

                                        filteredPumps[index].topTankLow.isNotEmpty?
                                        Padding(
                                          padding: const EdgeInsets.only(left:5, bottom: 5, top: 5),
                                          child: Column(
                                            children: filteredPumps[index].topTankLow.map((item) {
                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    width: 300,
                                                    height: 25,
                                                    color: Colors.transparent,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width:235, child: Text(item['SW_Name']!=null?' ${item['SW_Name']} : ':
                                                        '${item['Name']} : ', style: const TextStyle(color: Colors.black54),),),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey.shade200,
                                                            border: Border.all(
                                                              color: Colors.grey.shade300,
                                                              width: 0.7,
                                                            ),
                                                            borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                          ),
                                                          width: 65,
                                                          height: 40,
                                                          child: Center(
                                                            child: Text(
                                                              item['Value'],
                                                              style: const TextStyle(fontSize: 12),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ):
                                        const SizedBox(),

                                        filteredPumps[index].sumpTankHigh.isNotEmpty?
                                        Padding(
                                          padding: const EdgeInsets.only(left:5, bottom: 5, top: 5),
                                          child: Column(
                                            children: filteredPumps[index].sumpTankHigh.map((item) {
                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    width: 300,
                                                    height: 25,
                                                    color: Colors.transparent,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width:235, child: Text(item['SW_Name']!=null?' ${item['SW_Name']} : ':
                                                        '${item['Name']} : ', style: const TextStyle(color: Colors.black54),),),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey.shade200,
                                                            border: Border.all(
                                                              color: Colors.grey.shade300,
                                                              width: 0.7,
                                                            ),
                                                            borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                          ),
                                                          width: 65,
                                                          height: 40,
                                                          child: Center(
                                                            child: Text(
                                                              item['Value'],
                                                              style: const TextStyle(fontSize: 12),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ):
                                        const SizedBox(),

                                        filteredPumps[index].sumpTankLow.isNotEmpty?
                                        Padding(
                                          padding: const EdgeInsets.only(left:5, bottom: 5, top: 5),
                                          child: Column(
                                            children: filteredPumps[index].sumpTankLow.map((item) {
                                              return Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    width: 300,
                                                    height: 25,
                                                    color: Colors.transparent,
                                                    child: Row(
                                                      children: [
                                                        SizedBox(width:235, child: Text(item['SW_Name']!=null?' ${item['SW_Name']} : ':
                                                        '${item['Name']} : ', style: const TextStyle(color: Colors.black54),),),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey.shade200,
                                                            border: Border.all(
                                                              color: Colors.grey.shade300,
                                                              width: 0.7,
                                                            ),
                                                            borderRadius: const BorderRadius.all(Radius.circular(3.0)),
                                                          ),
                                                          width: 65,
                                                          height: 40,
                                                          child: Center(
                                                            child: Text(
                                                              item['Value'],
                                                              style: const TextStyle(fontSize: 12),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ),
                                        ):
                                        const SizedBox(),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            MaterialButton(
                                              color: Colors.green,
                                              textColor: Colors.white,
                                              onPressed: () {
                                                if(getPermissionStatusBySNo(context, 4)){
                                                  String payload = '${filteredPumps[index].sNo},1,1';
                                                  String payLoadFinal = jsonEncode({
                                                    "6200": [{"6201": payload}]
                                                  });
                                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                                  sentUserOperationToServer('${pump.swName?? pump.name} Start Manually', payLoadFinal);
                                                  showSnakeBar('Pump of comment sent successfully');
                                                  Navigator.pop(context);
                                                }else{
                                                  Navigator.pop(context);
                                                  GlobalSnackBar.show(context, 'Permission denied', 400);
                                                }
                                              },
                                              child: const Text('Start Manually',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 16,),
                                            MaterialButton(
                                              color: Colors.redAccent,
                                              textColor: Colors.white,
                                              onPressed: () {
                                                if(getPermissionStatusBySNo(context, 4)){
                                                  String payload = '${filteredPumps[index].sNo},0,1';
                                                  String payLoadFinal = jsonEncode({
                                                    "6200": [{"6201": payload}]
                                                  });
                                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                                  sentUserOperationToServer('${pump.swName ?? pump.name} Stop Manually', payLoadFinal);
                                                  showSnakeBar('Pump of comment sent successfully');
                                                  Navigator.pop(context);
                                                }else{
                                                  Navigator.pop(context);
                                                  GlobalSnackBar.show(context, 'Permission denied', 400);
                                                }
                                              },
                                              child: const Text('Stop Manually',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 16,),
                                          ],
                                        ),
                                        const SizedBox(height: 7,),*/
                                      ],
                                    ):
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(height: 8,),
                                            MaterialButton(
                                              color: Colors.green,
                                              textColor: Colors.white,
                                              onPressed: () {
                                                /*if(getPermissionStatusBySNo(context, 4)){
                                                  String payload = '${filteredPumps[index].sNo},1,1';
                                                  String payLoadFinal = jsonEncode({
                                                    "6200": [{"6201": payload}]
                                                  });
                                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                                  sentUserOperationToServer('${pump.swName ?? pump.name} Start Manually', payLoadFinal);
                                                  showSnakeBar('Pump of comment sent successfully');
                                                  Navigator.pop(context);
                                                }else{
                                                  Navigator.pop(context);
                                                  GlobalSnackBar.show(context, 'Permission denied', 400);
                                                }*/
                                              },
                                              child: const Text('Start Manually',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(height: 8,),
                                            MaterialButton(
                                              color: Colors.redAccent,
                                              textColor: Colors.white,
                                              onPressed: () {
                                                /*if(getPermissionStatusBySNo(context, 4)){
                                                  String payload = '${filteredPumps[index].sNo},0,1';
                                                  String payLoadFinal = jsonEncode({
                                                    "6200": [{"6201": payload}]
                                                  });
                                                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.deviceId}');
                                                  sentUserOperationToServer('${pump.swName ?? pump.name} Stop Manually', payLoadFinal);
                                                  showSnakeBar('Pump of comment sent successfully');
                                                  Navigator.pop(context);
                                                }else{
                                                  Navigator.pop(context);
                                                  GlobalSnackBar.show(context, 'Permission denied', 400);
                                                }*/

                                              },
                                              child: const Text('Stop Manually',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(height: 8,),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                        onPop: () => print('Popover was popped!'),
                        direction: PopoverDirection.right,
                        width: voltKeyExists? 300:140,
                        arrowHeight: 15,
                        arrowWidth: 30,
                        barrierColor: Colors.black54,
                        arrowDxOffset: (position.dx + 210)-25,


                        /*arrowDxOffset: pump.length==1?(position.dx+25)+(index*70)-140:
                        filteredPumps.length==2?(position.dx+25)+(index*70)-210:
                        filteredPumps.length==3?(position.dx+25)+(index*70)-280:
                        filteredPumps.length==4?(position.dx+25)+(index*70)-350:
                        filteredPumps.length==5?(position.dx+25)+(index*70)-420:
                        filteredPumps.length==6?(position.dx+25)+(index*70)-490:
                        filteredPumps.length==7?(position.dx+25)+(index*70)-560:
                        filteredPumps.length==8?(position.dx+25)+(index*70)-630:
                        filteredPumps.length==9?(position.dx+25)+(index*70)-700:
                        filteredPumps.length==10?(position.dx+25)+(index*70)-770:
                        filteredPumps.length==11?(position.dx+25)+(index*70)-840:
                        filteredPumps.length==12?(position.dx+25)+(index*70)-910:
                        (position.dx+25)+(index*70)-280,*/
                      );
                    },
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                      minimumSize: WidgetStateProperty.all(Size.zero),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    child: SizedBox(
                      width: gridWidth * 1.0,
                      height: gridWidth * 0.99,
                      child: AppConstants.getAsset('pump', pump.status, ''),
                    ),
                  ),
                ),
                Text(
                  pump.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ],
            ),
            pump.onDelayLeft != '00:00:00'? Positioned(
              top: 47.5,
              left: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  border: Border.all(color: Colors.green, width: .50),
                ),
                width: gridWidth-8,
                child: Center(
                  child: Column(
                    children: [
                      const Text(
                        "On delay",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 3, right: 3),
                        child: Divider(
                          height: 0,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        pump.onDelayLeft,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ):
            const SizedBox(),

            int.tryParse(pump.reason) != null && int.parse(pump.reason) > 0 && int.parse(pump.reason)!=31
                ? Positioned(
              top: 1,
              left: 37.5,
              child: Tooltip(
                message: vm.getContentByCode(int.parse(pump.reason)),
                textStyle: const TextStyle(color: Colors.black54),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const CircleAvatar(
                  radius: 11,
                  backgroundColor: Colors.deepOrangeAccent,
                  child: Icon(
                    Icons.info_outline,
                    size: 17,
                    color: Colors.white,
                  ),
                ),
              ),
            ):
            const SizedBox(),

            (pump.reason == '11'||pump.reason == '22')?
            Positioned(
              top: 40,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: pump.status==1?Colors.greenAccent:Colors.yellowAccent,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  border: Border.all(color: Colors.grey, width: .50),
                ),
                width: 67,
                child: Center(
                  child: ValueListenableBuilder<String>(
                    valueListenable: Provider.of<DurationNotifier>(context).onDelayLeft,
                    builder: (context, value, child) {
                      return Column(
                        children: [
                          Text(
                            'Max: ${pump.actualValue}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 3, right: 3),
                            child: Divider(
                              height: 0,
                              color: Colors.grey,
                              thickness: 0.5,
                            ),
                          ),
                          Text(
                            pump.status==1?'cRm: ${pump.setValue}':'Brk: ${pump.setValue}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ):
            pump.reason == '8' && vm.isTimeFormat(pump.actualValue.split('_').last)?
            Positioned(
              top: 40,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: pump.status==1?Colors.greenAccent:Colors.yellowAccent,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  border: Border.all(color: Colors.grey, width: .50),
                ),
                width: 67,
                child: Center(
                  child: ValueListenableBuilder<String>(
                    valueListenable: Provider.of<DurationNotifier>(context).onDelayLeft,
                    builder: (context, value, child) {
                      return Column(
                        children: [
                          const Text(
                            'Restart within',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 3, right: 3),
                            child: Divider(
                              height: 0,
                              color: Colors.grey,
                              thickness: 0.5,
                            ),
                          ),
                          Text(pump.actualValue.split('_').last,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ):
            const SizedBox(),

          ],
        );
      },
    );

  }
}

class FilterWidget extends StatelessWidget {
  final Filters filter;
  const FilterWidget({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double gridWidth = constraints.maxWidth;

        return Stack(
          children: [
            AppConstants.getAsset('filter', filter.status, ''),
            Positioned(
              top: 85,
              left: 0,
              child: SizedBox(
                width: gridWidth,
                child: Text(
                  filter.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ),
            ),
          ],
        );

      },
    );
  }
}

class PressureSensorWidget extends StatelessWidget {
  final PressureSensor pressureSensor;
  const PressureSensorWidget({super.key, required this.pressureSensor});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double gridWidth = constraints.maxWidth;

        return Stack(
          children: [
            Image.asset('assets/png/dp_prs_sensor.png',),
            Positioned(
              top: 47.5,
              left: 4,
              child: Container(
                width: gridWidth-8,
                height: 17,
                decoration: BoxDecoration(
                  color:Colors.yellow,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  border: Border.all(color: Colors.grey, width: .50,),
                ),
                child: Center(
                  child: Text('${pressureSensor?.value} bar', style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
              ),
            ),
          ],
        );

      },
    );
  }
}

class FertilizerWidget extends StatelessWidget {
  final Channel channel;
  const FertilizerWidget({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double gridWidth = constraints.maxWidth;

        return Stack(
          children: [
            AppConstants.getAsset('channel', channel.status, ''),
            Positioned(
              top: 85,
              left: 0,
              child: SizedBox(
                width: gridWidth,
                child: Text(
                  channel.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ),
            ),
          ],
        );

      },
    );
  }
}

class ValveWidget extends StatelessWidget {
  final Valve valve;
  const ValveWidget({super.key, required this.valve});

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        double gridWidth = constraints.maxWidth;
        return Stack(
          children: [
            SizedBox(
              width: gridWidth,
              child: Column(
                children: [
                  Divider(thickness: 2, color: Colors.grey.shade200, height: 5.5),
                  Divider(thickness: 2, color: Colors.grey.shade200, height: 4.5),
                ],
              ),
            ),
            SizedBox(
              width: 70,
              height: 95,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 15,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          VerticalDivider(thickness: 1, color: Colors.grey.shade400, width: 3),
                          VerticalDivider(thickness: 1, color: Colors.grey.shade400, width: 5),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 45,
                    height: 45,
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
          ],
        );
      },
    );
  }
}

class PipelineBendPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    Path path1 = Path();
    path1.moveTo(20, 30);
    path1.lineTo(size.width - 20, 30);
    path1.relativeLineTo(0, 5);

    canvas.drawPath(path1, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
