import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/common/user_dashboard/widgets/sensor_widget.dart';
import 'package:oro_drip_irrigation/views/common/user_dashboard/widgets/valve_widget.dart';

import '../../../../Widgets/pump_widget.dart';
import '../../../../models/customer/site_model.dart';
import '../../../customer/widgets/agitator_widget.dart';
import '../../../customer/widgets/booster_widget.dart';
import '../../../customer/widgets/channel_widget.dart';
import '../../../customer/widgets/filter_builder.dart';
import '../../../customer/widgets/gate_widget.dart';
import '../../../customer/widgets/light_widget.dart';
import '../../../customer/widgets/main_valve_widget.dart';
import '../../../customer/widgets/source_column_widget.dart';
import 'customer_widget_builders.dart';

class IrrigationLineWide extends StatelessWidget {
  final int customerId, controllerId, modelId;
  final String deviceId;
  final List<WaterSourceModel> inletWaterSources;
  final List<WaterSourceModel> outletWaterSources;

  final List<FilterSiteModel> cFilterSite;
  final List<FertilizerSiteModel> cFertilizerSite;

  final List<FilterSiteModel> lFilterSite;
  final List<FertilizerSiteModel> lFertilizerSite;

  final List<ValveModel> valves;
  final List<ValveModel> mainValves;
  final List<LightModel> lights;
  final List<GateModel> gates;
  final List<SensorModel> prsSwitch;
  final List<SensorModel> pressureIn;
  final List<SensorModel> pressureOut;
  final List<SensorModel> waterMeter;
  final double containerWidth;
  final bool isNava;


  IrrigationLineWide({
    super.key,
    required this.inletWaterSources,
    required this.outletWaterSources,
    required this.cFilterSite,
    required this.cFertilizerSite,
    required this.lFilterSite,
    required this.lFertilizerSite,
    required this.valves,
    required this.mainValves,
    required this.lights,
    required this.gates,
    required this.prsSwitch,
    required this.pressureIn,
    required this.pressureOut,
    required this.waterMeter,
    required this.customerId,
    required this.controllerId,
    required this.deviceId,
    required this.containerWidth,
    required this.modelId,
    required this.isNava,
  });

  final ValueNotifier<int> popoverUpdateNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {

    final allValveWidgets = [

      ...mainValveList(
        list: mainValves,
        customerId: customerId,
        controllerId: controllerId,
        modelId: modelId,
        isNarrow: false,
      ),

      ...valveList(
        valves: valves,
        customerId: customerId,
        controllerId: controllerId,
        modelId: modelId,
        isMobile: false,
      ),

    ];

    final gateWidgets = gates.asMap().entries.map((entry) {
      return GateWidget(objGate: entry.value);
    }).toList();

    final lightWidgets = lights.asMap().entries.map((entry) {
      return LightWidget(objLight: entry.value, isWide: true);
    }).toList();

    final allItems = [
      if (inletWaterSources.isNotEmpty)
        ..._buildWaterSource(context, inletWaterSources, true, true, cFertilizerSite.isNotEmpty? true : false),

      if (outletWaterSources.isNotEmpty)
        ..._buildWaterSource(context, outletWaterSources, inletWaterSources.isNotEmpty, false, cFertilizerSite.isNotEmpty),

      if (cFilterSite.isNotEmpty)
        ...buildFilter(context, cFilterSite, cFertilizerSite.isNotEmpty, false, false),

      if (lFilterSite.isNotEmpty)
        ...buildFilter(context, lFilterSite, (cFertilizerSite.isNotEmpty || lFertilizerSite.isNotEmpty), false, false),

      if (cFertilizerSite.isNotEmpty)
        ..._buildFertilizer(context, cFertilizerSite, isNava),

      if (lFertilizerSite.isNotEmpty)
        ..._buildFertilizer(context, lFertilizerSite, isNava),

      ...lightWidgets,
      ..._buildSensorItems(prsSwitch, 'Pressure Switch', 'assets/png/pressure_switch_wj.png', cFertilizerSite.isNotEmpty),
      ..._buildSensorItems(pressureIn, 'Pressure Sensor', 'assets/png/pressure_sensor_wj.png', cFertilizerSite.isNotEmpty),
      ..._buildSensorItems(waterMeter, 'Water Meter', 'assets/png/water_meter_wj.png', cFertilizerSite.isNotEmpty),
      ...allValveWidgets,
      ..._buildSensorItems(pressureOut, 'Pressure Sensor', 'assets/png/pressure_sensor_wjl.png', cFertilizerSite.isNotEmpty),
      ...gateWidgets,
    ];

    int cFrtChannelCount = 0;
    int lFrtChannelCount = 0;

    if(cFertilizerSite.isNotEmpty) {
      cFrtChannelCount = (cFertilizerSite[0].channel.length + cFertilizerSite[0].agitator.length + 1);
    }
    if(lFertilizerSite.isNotEmpty){
      lFrtChannelCount = (lFertilizerSite[0].channel.length + lFertilizerSite[0].agitator.length + 1);
    }

    int itemsPerRow = ((MediaQuery.sizeOf(context).width - 140) / 67).floor() -
        (cFrtChannelCount + lFrtChannelCount);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 0,
          runSpacing: 0,
          children: allItems.asMap().entries.map<Widget>((entry) {

            final index = entry.key;
            final item = entry.value;
            if(cFertilizerSite.isNotEmpty) {
              if (((item is ValveWidget) || (item is BuildMainValve)
                  ||(item is LightWidget)||(item is SensorWidget))
                  && index < itemsPerRow) {
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
      ),
    );
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
          isMobile: false,
          isAvailFrtSite: (cFertilizerSite.isNotEmpty || lFertilizerSite.isNotEmpty),
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
          isMobile: false,
          modelId: modelId,
          pumpPosition: 'First',
          isNova: false,
          isAvailFrtSite: (cFertilizerSite.isNotEmpty || lFertilizerSite.isNotEmpty),
        ),
      )));
    }
    return gridItems;
  }

  List<Widget> _buildSensorItems(List<SensorModel> sensors, String type, String imagePath, bool isAvailFertilizer) {
    return sensors.map((sensor) {
      return Padding(
        padding: EdgeInsets.only(top: isAvailFertilizer? 30 : 0),
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

  List<Widget> _buildFertilizer(BuildContext context,
      List<FertilizerSiteModel> fertilizerSite, bool isNova) {
    return List.generate(fertilizerSite.length, (siteIndex) {
      final site = fertilizerSite[siteIndex];
      final widgets = <Widget>[];

      if (siteIndex != 0) {
        widgets.add(_buildVerticalLine(height: 120));
      }

      widgets.add(BoosterWidget(fertilizerSite: site, isMobile: false));

      for (int channelIndex = 0; channelIndex < site.channel.length; channelIndex++) {
        final channel = site.channel[channelIndex];

        widgets.add(ChannelWidget(
          channel: channel,
          cIndex: channelIndex,
          channelLength: site.channel.length,
          agitator: site.agitator,
          siteSno: site.sNo.toString(),
          isMobile: false,
        ));

        if (channelIndex == site.channel.length - 1 && site.agitator.isNotEmpty) {
          widgets.add(AgitatorWidget(
            fertilizerSite: site,
            isMobile: false,
          ));
        }
      }

      if (kIsWeb) {
        widgets.add(_buildVerticalLine(height: 130));
      }

      return SizedBox(
        width: ((site.boosterPump.length + site.channel.length + site.agitator.length ) * 70) + 5,
        child: Stack(
          children: [
            Row(children: widgets),
            Positioned(
              left: 3,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey, width: 0.5),
                ),
                child: Text(
                  site.name,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

    }).toList();
  }

  Widget _buildVerticalLine({required double height}) {
    return SizedBox(
      width: 4.5,
      height: height,
      child: const Row(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 42),
            child: VerticalDivider(width: 0, color: Colors.black12),
          ),
          SizedBox(width: 4.5),
          Padding(
            padding: EdgeInsets.only(top: 45),
            child: VerticalDivider(width: 0, color: Colors.black12),
          ),
        ],
      ),
    );
  }
}