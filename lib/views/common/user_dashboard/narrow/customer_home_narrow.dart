import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/utils/helpers/mc_permission_helper.dart';
import 'package:oro_drip_irrigation/views/customer/widgets/main_valve_widget.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

import '../../../../models/customer/site_model.dart';
import '../../../../StateManagement/mqtt_payload_provider.dart';
import '../../../../Widgets/pump_widget.dart';
import '../../../../services/communication_service.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';
import '../../../../utils/formatters.dart';
import '../../../../utils/my_function.dart';
import '../../../../utils/snack_bar.dart';
import '../../../../view_models/customer/current_program_view_model.dart';
import '../../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../../customer/customer_home.dart';
import '../../../customer/home_sub_classes/fertilizer_site.dart';
import '../../../customer/widgets/filter_builder.dart';
import '../../../customer/widgets/my_material_button.dart';
import '../../../customer/widgets/sensor_widget_mobile.dart';
import '../../../customer/widgets/source_column_widget.dart';

class CustomerHomeNarrow extends StatelessWidget {
  const CustomerHomeNarrow({super.key});

  @override
  Widget build(BuildContext context) {

    final viewModel = Provider.of<CustomerScreenControllerViewModel>(context);
    final cM = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex];
    bool isNova = [...AppConstants.ecoGemModelList].contains(cM.modelId);

    final linesToDisplay = (viewModel.myCurrentIrrLine == "All irrigation line" || viewModel.myCurrentIrrLine.isEmpty)
        ? cM.irrigationLine.where((line) => line.name != viewModel.myCurrentIrrLine).toList()
        : cM.irrigationLine.where((line) => line.name == viewModel.myCurrentIrrLine).toList();

    final hasProgramOnOff = cM.getPermissionStatus("Program On/Off Manually");
    final hasLinePP = cM.getPermissionStatus("Irrigation Line Pause/Resume Manually");


    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await viewModel.onRefreshClicked();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 130),
          child: Column(
            children: [
              ...linesToDisplay.map((line) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
                child: Column(
                  children: [
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      child: Column(
                        children: [
                          const ListTile(
                            visualDensity: VisualDensity(vertical: -4),
                            title: Text('Pump Station',
                                style: TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.bold)),
                            tileColor: Colors.white,
                          ),
                          Container(
                              color: Colors.white,
                              child: buildPumpStation(context, line, viewModel.mySiteList.data[viewModel.sIndex].customerId,
                                  cM.controllerId, cM.modelId, cM.deviceId)
                          )
                        ],
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      elevation: 1,
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 45,
                            color: Colors.white,
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Text(
                                  line.name,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.bold),
                                ),

                                if(!isNova)...[
                                  if(hasLinePP)...[
                                    const Spacer(),
                                    SizedBox(
                                      height: 35,
                                      child: MyMaterialButton(
                                        buttonId: 'line_${line.sNo}_4900',
                                        label: line.linePauseFlag == 0 ? 'Pause the line' : 'Resume the line',
                                        payloadKey: "4900",
                                        payloadValue: "${line.sNo},${line.linePauseFlag == 0 ? 1 : 0}",
                                        color: line.linePauseFlag == 0 ? Colors.orangeAccent : Colors.green,
                                        textColor: Colors.white,
                                        serverMsg: line.linePauseFlag == 0
                                            ? 'Paused the ${line.name}'
                                            : 'Resumed the ${line.name}',
                                      ),
                                    ),
                                    const SizedBox(width: 5)
                                  ]
                                ]
                              ],
                            ),
                          ),
                          buildIrrigationLine(context, line, viewModel.mySiteList.data[viewModel.sIndex].customerId,
                              cM.controllerId, cM.modelId, cM.deviceId)
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),

      floatingActionButton: SizedBox(
        height: 65,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,          // important: don't expand to full width
            children: [
              ChangeNotifierProvider(
                create: (context) => CurrentProgramViewModel(
                  context,
                  viewModel.mySiteList.data[viewModel.sIndex]
                      .master[viewModel.mIndex]
                      .irrigationLine[viewModel.lIndex]
                      .sNo,
                ),
                child: Consumer<CurrentProgramViewModel>(
                  builder: (context, vm, _) {
                    final currentSchedule = context.watch<MqttPayloadProvider>().currentSchedule;

                    if (currentSchedule.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        vm.updateSchedule(currentSchedule);
                      });
                    }

                    if (vm.currentSchedule.isNotEmpty &&
                        vm.currentSchedule[0].isNotEmpty) {
                      return buildCurrentSchedule(context, vm.currentSchedule,
                          cM.programList, cM.modelId, hasProgramOnOff);
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
              buildNextScheduleCard(context, cM.programList),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartDocked,

    );

  }

  Widget buildCurrentSchedule(BuildContext context,
      List<String> currentSchedule, List<ProgramList> scheduledPrograms, int modelId, bool hasSkip) {
    return Row(
      children: List.generate(currentSchedule.length, (index) {
        List<String> values = currentSchedule[index].split(',');

        final programName = getProgramNameById(int.parse(values[0]), scheduledPrograms);
        final isManual = programName == 'StandAlone - Manual';
        final timeless = (values[3] == '00:00:00' || values[3] == '0');

        return Builder(
          builder: (rowContext) {
            return GestureDetector(
              onTap: () {
                showPopover(
                  context: rowContext,
                  bodyBuilder: (context) =>  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buildScheduleRow(context, values, programName, scheduledPrograms, modelId, hasSkip),
                  ),
                  onPop: () => print('Popover was popped!'),
                  direction: PopoverDirection.top,
                  width: 350,
                  height: 150,
                  arrowHeight: 15,
                  arrowWidth: 30,
                );
              },
              child: Card(
                color: Colors.white,
                elevation: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                  ),
                  child: SizedBox(
                    height: 45,
                    child: Column(
                      children: [
                        Text(programName,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        Text(
                          isManual && timeless ? 'Timeless' : values[4],
                          style:
                          const TextStyle(fontSize: 17, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget buildScheduleRow(BuildContext context, List<String> values, String programName,
      List<ProgramList> scheduledPrograms, int modelId, bool hasSkip) {

    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: 143,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: 20,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 3),
                    child: SizedBox(
                      width: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Method',
                            style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(':'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(getContentByCode(int.parse(values[17])), style: const TextStyle(fontSize: 11, color: Colors.black54),),
                  )
                ],
              ),
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: SizedBox(
                    width: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Zone', style: TextStyle(color: Colors.black45)),
                        SizedBox(height: 2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(':'),
                      SizedBox(height: 2),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(programName == 'StandAlone - Manual' ? '--' :
                      getSequenceName(int.parse(values[0]), values[1], scheduledPrograms) ?? '--',),
                      const SizedBox(height: 3),
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 3),
                  child: SizedBox(
                    width: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Started at', style: TextStyle(color: Colors.black45)),
                        SizedBox(height: 2),
                        Text('Current Zone', style: TextStyle(color: Colors.black45)),
                        SizedBox(height: 2),
                        Text('Rtc & Cyclic', style: TextStyle(color: Colors.black45)),
                        SizedBox(height: 2),
                        Text('Set (Dur/Flw)', style: TextStyle(color: Colors.black45)),
                        SizedBox(height: 2),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(':'),
                      SizedBox(height: 2),
                      Text(':'),
                      SizedBox(height: 2),
                      Text(':'),
                      SizedBox(height: 2),
                      Text(':'),
                      SizedBox(height: 2),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(MyFunction().convert24HourTo12Hour(values[11])),
                          const SizedBox(height: 2),
                          Text('${values[10]} of ${values[9]}'),
                          const SizedBox(height: 1),
                          Text('${Formatters().formatRtcValues(values[6], values[5])} - ${Formatters().formatRtcValues(values[8], values[7])}'),
                          const SizedBox(height: 3),
                          Text(programName == 'StandAlone - Manual' && (values[3] == '00:00:00' || values[3] == '0')
                              ? 'Timeless'
                              : values[3]),
                          const SizedBox(height: 2),
                        ],
                      ),
                      if(hasSkip)...[
                        SizedBox(
                          width: 130,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Spacer(),
                              if(![...AppConstants.ecoGemModelList].contains(modelId))...[
                                buildActionButton(context, values, programName, programName == 'StandAlone - Manual' ? '--' :
                                getSequenceName(int.parse(values[0]), values[1], scheduledPrograms) ?? '--',),
                              ],
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getProgramNameById(int id, List<ProgramList> scheduledPrograms) {
    try {
      return scheduledPrograms.firstWhere((program) => program.serialNumber == id).programName;
    } catch (e) {
      return "StandAlone - Manual";
    }
  }

  ProgramList? getProgramById(int id, List<ProgramList> scheduledPrograms) {
    try {
      return scheduledPrograms.firstWhere((program) => program.serialNumber == id);
    } catch (e) {
      return null;
    }
  }

  String? getSequenceName(int programId, String sequenceId, List<ProgramList> scheduledPrograms) {
    ProgramList? program = getProgramById(programId, scheduledPrograms);
    if (program != null) {
      return getSequenceNameById(program, sequenceId);
    }
    return null;
  }

  String? getSequenceNameById(ProgramList program, String sequenceId) {
    try {
      return program.sequence.firstWhere((seq) => seq.sNo == sequenceId).name;
    } catch (e) {
      return null;
    }
  }


  String getContentByCode(int code) {
    return GemProgramStartStopReasonCode.fromCode(code).content;
  }

  Widget buildActionButton(BuildContext context,
      List<String> values, String  programName, String  sequenceName) {

    if (programName == 'StandAlone - Manual') {
      return MaterialButton(
        color: Colors.redAccent,
        textColor: Colors.white,
        onPressed: values[17]=='1'? () async {
          String payLoadFinal = jsonEncode({
            "800": {"801": '0,0,0,0,0'}
          });

          final result = await context.read<CommunicationService>().sendCommand(
              serverMsg: '$programName Stopped manually',
              payload: payLoadFinal);

          if (result['http'] == true) debugPrint("Payload sent to Server");
          if (result['mqtt'] == true) debugPrint("Payload sent to MQTT Box");
          if (result['bluetooth'] == true) debugPrint("Payload sent via Bluetooth");

          GlobalSnackBar.show(context, 'Comment sent successfully', 200);
        }: null,
        child: const Text('Stop'),
      );
    } else if (programName.contains('StandAlone'))  {
      return MaterialButton(
        color: Colors.redAccent,
        textColor: Colors.white,
        onPressed: () async {

          String payLoadFinal = jsonEncode({
            "3900": {"3901": '0,${values[3]},${values[0]},'
                '${values[1]},,,,,,,0'}
          });

          final result = await context.read<CommunicationService>().sendCommand(
              serverMsg: '$programName Stopped manually',
              payload: payLoadFinal);

          if (result['http'] == true) debugPrint("Payload sent to Server");
          if (result['mqtt'] == true) debugPrint("Payload sent to MQTT Box");
          if (result['bluetooth'] == true) debugPrint("Payload sent via Bluetooth");

          GlobalSnackBar.show(context, 'Comment sent successfully', 200);

        },
        child: const Text('Stop'),
      );
    }else{
      return MaterialButton(
        color: Colors.orangeAccent,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        onPressed: values[17]=='1' ? () async {
          String payload = '${values[18]},0';
          String payLoadFinal = jsonEncode({
            "3700": {"3701": payload}
          });

          final result = await context.read<CommunicationService>().sendCommand(
              serverMsg: '$programName - $sequenceName skipped manually',
              payload: payLoadFinal);

          if (result['http'] == true) debugPrint("Payload sent to Server");
          if (result['mqtt'] == true) debugPrint("Payload sent to MQTT Box");
          if (result['bluetooth'] == true) debugPrint("Payload sent via Bluetooth");

          Navigator.pop(context);
          GlobalSnackBar.show(context, 'Comment sent successfully', 200);

        } : null,
        child: const Text('Skip', style: TextStyle(color: Colors.white, fontSize: 13)),
      );
    }
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

  Widget buildPumpStation(BuildContext context, IrrigationLineModel irrLine,
      int customerId, int controllerId, int modelId, String deviceId) {

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

  Widget buildIrrigationLine(BuildContext context, IrrigationLineModel irrLine,
      int customerId, int controllerId, int modelId, String deviceId){
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

  Widget buildNextScheduleCard(BuildContext context, List<ProgramList> scheduledPrograms) {

    var nextSchedule =  context.watch<MqttPayloadProvider>().nextSchedule;

    if(nextSchedule.isNotEmpty && nextSchedule[0].isNotEmpty){
      return Row(
        children: List.generate(nextSchedule.length, (index) {

          List<String> values = nextSchedule[index ~/ 2].split(',');
          final programName = getProgramNameById(int.parse(values[0]), scheduledPrograms);
          final sqName = getSequenceName(int.parse(values[0]), values[1], scheduledPrograms) ?? '--';

          return Builder(
            builder: (rowContext) {
              return GestureDetector(
                onTap: () {
                  showPopover(
                    context: rowContext,
                    bodyBuilder: (context) =>  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildNextScheduleRow(context, values, programName, sqName),
                    ),
                    onPop: () => print('Popover was popped!'),
                    direction: PopoverDirection.top,
                    width: 300,
                    height: 90,
                    arrowHeight: 15,
                    arrowWidth: 30,
                  );
                },
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade300,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                      ),
                    ),
                    child: SizedBox(
                      height: 45,
                      child: Column(
                        children: [
                          const Text('Next Shift',
                              style: TextStyle(color: Colors.black45, fontSize: 13)),
                          const SizedBox(height: 3),
                          Text(sqName, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );

        }),
      );
    }else{
      return const SizedBox();
    }

  }

  Widget buildNextScheduleRow(BuildContext context, List<String> values,
      String programName, String sequenceName) {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Program Name', style: TextStyle(color: Colors.black45)),
                SizedBox(height: 2),
                Text('Start at', style: TextStyle(color: Colors.black45)),
                SizedBox(height: 2),
                Text('Set (Dur/Flw)', style: TextStyle(color: Colors.black45)),
                SizedBox(height: 2),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(programName),
                const SizedBox(height: 1),
                Text(MyFunction().convert24HourTo12Hour(values[6])),
                const SizedBox(height: 3),
                Text(values[3]),
                const SizedBox(height: 2),
              ],
            ),
          ),
        )
      ],
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

  PumpStation({
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

  final ValueNotifier<int> popoverUpdateNotifier = ValueNotifier<int>(0);

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
        ...buildFilter(context, filterSite, false),
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
        child: SourceColumnWidget(
          source: source,
          isInletSource: isInlet,
          isAvailInlet: isAvailInlet,
          index: index,
          total: waterSources.length,
          popoverUpdateNotifier: popoverUpdateNotifier,
          deviceId: deviceId,
          customerId: customerId,
          controllerId: controllerId,
          modelId: modelId,
        ),
      ));
      gridItems.addAll(source.outletPump.map((pump) => Padding(
        padding: EdgeInsets.only(top: isAvailFertilizer? 38.5:8),
        child: PumpWidget(
          pump: pump,
          isSourcePump: isInlet,
          deviceId: deviceId,
          customerId: customerId,
          controllerId: controllerId,
          isMobile: true,
          modelId: modelId,
        ),
      )));
    }
    return gridItems;
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


  List<Widget> _buildFertilizer(BuildContext context, List<FertilizerSiteModel> fertilizerSite) {
    return fertilizerSite.map((site) {
      final widgets = <Widget>[];

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
        if (isLast && site.agitator.isNotEmpty) {
          widgets.add(AgitatorWidget(fertilizerSite: site));
        }
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets
          ),
        ),
      );
    }).toList();
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
      final valve = entry.value;
      return ValveWidgetMobile(
        valve: valve,
        customerId: customerId,
        controllerId: controllerId,
        modelId: modelId,
      );
    }).toList();

    final mainValveWidgets = mainValveWidgetEntries.map((entry) {
      final valve = entry.value;
      return BuildMainValve(
        valve: valve,
        customerId: customerId,
        controllerId: controllerId,
        modelId: modelId,
        isNarrow: true,
      );
    }).toList();

    final pressureOutWidgets = _buildSensorItems(
      pressureOut, 'Pressure Sensor', 'assets/png/pressure_sensor.png',
    );

    final lightWidgets = lights.asMap().entries.map((entry) {
      return LightWidget(objLight: entry.value, isWide: false);
    }).toList();

    final allItems = [
      ...lightWidgets,
      ...mainValveWidgets,
      ...valveWidgets,
      ...pressureOutWidgets,
    ];

    return Column(
      children: [
        if(baseSensors.isNotEmpty)...[
          ...allItemsWithoutValves,
        ],
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
      return SensorWidgetMobile(
        sensor: sensor,
        sensorType: type,
        imagePath: imagePath,
        customerId: customerId,
        controllerId: controllerId,
      );
    }).toList();
  }
}
