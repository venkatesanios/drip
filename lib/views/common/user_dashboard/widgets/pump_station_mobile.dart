import 'package:flutter/cupertino.dart';

import '../../../../Widgets/pump_widget.dart';
import '../../../../models/customer/site_model.dart';
import '../../../customer/widgets/agitator_widget.dart';
import '../../../customer/widgets/booster_widget.dart';
import '../../../customer/widgets/channel_widget.dart';
import '../../../customer/widgets/filter_builder.dart';
import '../../../customer/widgets/source_column_widget.dart';

class PumpStationMobile extends StatelessWidget {
  final int customerId, controllerId, modelId;
  final String deviceId;
  final List<WaterSourceModel> inletWaterSources;
  final List<WaterSourceModel> outletWaterSources;
  final List<FilterSiteModel> cFilterSite;
  final List<FertilizerSiteModel> cFertilizerSite;
  final List<FilterSiteModel> lFilterSite;
  final List<FertilizerSiteModel> lFertilizerSite;
  final bool isNova;

  PumpStationMobile({
    super.key,
    required this.inletWaterSources,
    required this.outletWaterSources,
    required this.cFilterSite,
    required this.cFertilizerSite,
    required this.lFilterSite,
    required this.lFertilizerSite,
    required this.customerId,
    required this.controllerId,
    required this.deviceId,
    required this.modelId,
    required this.isNova,
  });

  final ValueNotifier<int> popoverUpdateNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {

    final wsAndFilterItems = [
      if (inletWaterSources.isNotEmpty)
        ..._buildWaterSource(context, inletWaterSources, true, true),

      if (outletWaterSources.isNotEmpty)
        ..._buildWaterSource(context, outletWaterSources, inletWaterSources.isNotEmpty, false),

      if (cFilterSite.isNotEmpty)
        ...buildFilter(context, cFilterSite, isNova? true:false, true, isNova),

      if (lFilterSite.isNotEmpty)
        ...buildFilter(context, lFilterSite, isNova? true:false, true, isNova),

      if (isNova && cFertilizerSite.isNotEmpty)
        ..._buildFertilizer(context, cFertilizerSite, isNova),

      if (isNova && lFertilizerSite.isNotEmpty)
        ..._buildFertilizer(context, lFertilizerSite, isNova),
    ];

    final fertilizerItemsCentral = cFertilizerSite.isNotEmpty
        ? _buildFertilizer(context, cFertilizerSite, isNova).cast<Widget>()
        : <Widget>[];

    final fertilizerItemsLocal = lFertilizerSite.isNotEmpty
        ? _buildFertilizer(context, lFertilizerSite, isNova).cast<Widget>()
        : <Widget>[];

    if(isNova) {
      return SizedBox(
        width: double.infinity,
        height: 100,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          physics: const AlwaysScrollableScrollPhysics(),
          child: IntrinsicWidth(
            child: Align(
              alignment: Alignment.topRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 0,
                runSpacing: 0,
                children: [
                  ...wsAndFilterItems,
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      if (cFertilizerSite.isEmpty && lFertilizerSite.isNotEmpty) {
        return SizedBox(
          width: double.infinity,
          height: 100,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            physics: const AlwaysScrollableScrollPhysics(),
            child: IntrinsicWidth(
              child: Align(
                alignment: Alignment.topRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 0,
                  runSpacing: 0,
                  children: [
                    ...wsAndFilterItems,
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                physics: const AlwaysScrollableScrollPhysics(),
                child: IntrinsicWidth(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 0,
                      runSpacing: 0,
                      children: wsAndFilterItems,
                    ),
                  ),
                ),
              ),
            ),

            if (cFertilizerSite.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 125,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: IntrinsicWidth(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 0,
                        runSpacing: 0,
                        children: fertilizerItemsCentral,
                      ),
                    ),
                  ),
                ),
              ),


            if (lFertilizerSite.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 125,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: IntrinsicWidth(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 0,
                        runSpacing: 0,
                        children: fertilizerItemsLocal,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }
    }
  }

  List<Widget> _buildWaterSource(BuildContext context, List<WaterSourceModel> waterSources,
      bool isAvailInlet, bool isInlet) {

    final List<Widget> gridItems = [];
    for (int index = 0; index < waterSources.length; index++) {
      final source = waterSources[index];
      gridItems.add(SourceColumnWidget(
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
        isMobile: true,
        isNova: isNova,
      ));
      gridItems.addAll(source.outletPump.map((pump) => PumpWidget(
        pump: pump,
        isSourcePump: isInlet,
        deviceId: deviceId,
        customerId: customerId,
        controllerId: controllerId,
        isMobile: true,
        modelId: modelId,
        pumpPosition: 'First',
        isNova: isNova,
      )));
    }
    return gridItems;
  }

  List<Widget> _buildFertilizer(BuildContext context,
      List<FertilizerSiteModel> fertilizerSite, bool isNova) {

    return fertilizerSite.map((site) {
      final widgets = <Widget>[];

      final List<Widget> channelWidgets = [];

      for (int channelIndex = 0; channelIndex < site.channel.length; channelIndex++) {
        final channel = site.channel[channelIndex];

        channelWidgets.add(ChannelWidget(
          channel: channel,
          cIndex: channelIndex,
          channelLength: site.channel.length,
          agitator: site.agitator,
          siteSno: site.sNo.toString(),
          isMobile: true,
          isNova: isNova,
        ));

        final isLast = channelIndex == site.channel.length - 1;
        if (isLast && site.agitator.isNotEmpty) {
          channelWidgets.add(AgitatorWidget(
            fertilizerSite: site,
            isMobile: true,
          ));
        }
      }

      if (isNova) {
        widgets.add(BoosterWidget(
          fertilizerSite: site,
          isMobile: true,
          isNava: isNova,
        ));
        widgets.addAll(channelWidgets);
      } else {
        widgets.addAll(channelWidgets.reversed);
        widgets.add(BoosterWidget(
          fertilizerSite: site,
          isMobile: true,
          isNava: isNova,
        ));
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          ),
        ),
      );
    }).toList();
  }

}