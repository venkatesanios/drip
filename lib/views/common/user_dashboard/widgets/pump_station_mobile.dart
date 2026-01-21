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
        ...buildFilter(context, cFilterSite, (cFertilizerSite.isNotEmpty || lFertilizerSite.isNotEmpty), true, isNova),

      if (lFilterSite.isNotEmpty)
        ...buildFilter(context, lFilterSite, (cFertilizerSite.isNotEmpty || lFertilizerSite.isNotEmpty), true, isNova),

    ];

    final fertilizerItemsCentral = cFertilizerSite.isNotEmpty
        ? _buildFertilizer(context, cFertilizerSite, isNova).cast<Widget>()
        : <Widget>[];

    final fertilizerItemsLocal = lFertilizerSite.isNotEmpty
        ? _buildFertilizer(context, lFertilizerSite, isNova).cast<Widget>()
        : <Widget>[];

    const double itemWidth = 70;
    const double itemHeight = 90;

    return LayoutBuilder(
      builder: (context, constraints) {
        final int itemsPerRow = (constraints.maxWidth / itemWidth)
            .floor().clamp(1, wsAndFilterItems.length);
        final int rowCount = (wsAndFilterItems.length / itemsPerRow).ceil();

        return Column(
          children: [
            for (int row = 0; row < rowCount; row++)
              SizedBox(
                height: itemHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int i = 0; i < itemsPerRow; i++)
                      if (row * itemsPerRow + i < wsAndFilterItems.length)
                        wsAndFilterItems[
                        row == 0
                            ? row * itemsPerRow + (itemsPerRow - 1 - i).
                        clamp(0, wsAndFilterItems.length - 1)
                            : row * itemsPerRow + i
                        ],
                  ],
                ),
              ),

            if (cFertilizerSite.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 125,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
          ],
        );
      },
    );


    final screenWidth = MediaQuery.of(context).size.width;
    //const double itemWidth = 70;
    //const double itemHeight = 100; // height of each item
    final int totalItems = wsAndFilterItems.length;

// How many items can fit in one row horizontally
    final int itemsPerRow = screenWidth ~/ itemWidth;

// Number of rows needed to display all items
    final int rowCount = (totalItems / itemsPerRow).ceil();

    return SizedBox(
      width: double.infinity,
      height: rowCount * itemHeight, // grid height grows based on rows
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: rowCount,   // number of rows (vertical)
          mainAxisExtent: itemWidth,   // width of each item
          mainAxisSpacing: 0,
          crossAxisSpacing: 0,
        ),
        itemCount: wsAndFilterItems.length,
        itemBuilder: (context, index) {
          return wsAndFilterItems[index]; // just use the list order
        },
      ),
    );


    return SizedBox(
      width: double.infinity,
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: false,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 0,
            runSpacing: 0,
            children: wsAndFilterItems.reversed.toList(),
          ),
        ),
      ),
    );

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

          IntrinsicWidth(
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

          /*SizedBox(
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
          ),*/


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
        isAvailFrtSite: (cFertilizerSite.isNotEmpty || lFertilizerSite.isNotEmpty),
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
        isAvailFrtSite: (cFertilizerSite.isNotEmpty || lFertilizerSite.isNotEmpty),
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
        ));

        final isLast = channelIndex == site.channel.length - 1;
        if (isLast && site.agitator.isNotEmpty) {
          channelWidgets.add(AgitatorWidget(
            fertilizerSite: site,
            isMobile: true,
          ));
        }
      }

      widgets.add(BoosterWidget(
        fertilizerSite: site,
        isMobile: true,
      ));
      widgets.addAll(channelWidgets);


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