import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Models/customer/stand_alone_model.dart';
import 'package:oro_drip_irrigation/utils/Theme/oro_theme.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../utils/constants.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import 'home_sub_classes/irrigation_line.dart';
import 'home_sub_classes/scheduled_program.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key, required this.customerId});
  final int customerId;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CustomerScreenControllerViewModel>(context);

    final waterSources = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.waterSource;
    final filterSite = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.filterSite;
    final fertilizerSite = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.fertilizerSite;
    final lineData = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData;
    final scheduledProgram = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].programList;

    return Column(
      children: [
        DisplayPumpStation(
          waterSource: waterSources,
          irrLineData: lineData,
          filterSite: filterSite,
          fertilizerSite: fertilizerSite,
        ),
        scheduledProgram.isNotEmpty? ScheduledProgram(userId: customerId, scheduledPrograms: scheduledProgram, masterInx: viewModel.mIndex):
        const SizedBox(),
        const SizedBox(height: 8,),
      ],
    );
  }
}

class DisplayPumpStation extends StatelessWidget {

  final List<WaterSource> waterSource;
  final List<FilterSite> filterSite;
  final List<FertilizerSite> fertilizerSite;

  final List<IrrigationLineData>? irrLineData;

  const DisplayPumpStation({super.key, required this.waterSource,
    required this.irrLineData, required this.filterSite,
    required this.fertilizerSite});

  @override
  Widget build(BuildContext context) {

    var outputOnOffLiveMessage = Provider.of<MqttPayloadProvider>(context).outputOnOffLiveMessage;
    print('outputOnOffLiveMessage:$outputOnOffLiveMessage');

    List<String> filteredPumpStatus = outputOnOffLiveMessage
        .where((item) => item.startsWith('5.')).toList();
    updatePumpStatus(waterSource, filteredPumpStatus);

    List<String> filteredValveStatus = outputOnOffLiveMessage
        .where((item) => item.startsWith('13.')).toList();
    updateValveStatus(irrLineData!, filteredValveStatus);


    double screenWith = MediaQuery.sizeOf(context).width;

    int totalWaterSources = waterSource.length;
    int totalOutletPumps = waterSource.fold(0, (sum, source) => sum + source.outletPump.length);

    int totalFilters = filterSite.fold(0, (sum, site) => sum + (site.filters.length ?? 0));
    int totalPressureIn = filterSite.fold(0, (sum, site) => sum + (site.pressureIn!=null ? 1 : 0));
    int totalPressureOut = filterSite.fold(0, (sum, site) => sum + (site.pressureOut!=null ? 1 : 0));

    int totalBoosterPump = fertilizerSite.fold(0, (sum, site) => sum + (site.boosterPump.length ?? 0));
    int totalChannels = fertilizerSite.fold(0, (sum, site) => sum + (site.channel.length ?? 0));
    int totalAgitators = fertilizerSite.fold(0, (sum, site) => sum + (site.agitator.length ?? 0));

    /*print("Total Water Sources: $totalWaterSources");
    print("Total Outlet Pumps: $totalOutletPumps");
    print("Total Filters: $totalFilters");
    print("Total Pressure In: $totalPressureIn");
    print("Total Pressure Out: $totalPressureOut");
    print("Total Booster Pumps: $totalBoosterPump");
    print("Total Channels: $totalChannels");
    print("Total Agitators: $totalAgitators");*/

    int grandTotal = totalWaterSources + totalOutletPumps +
        totalFilters + totalPressureIn + totalPressureOut +
        totalBoosterPump + totalChannels + totalAgitators;

    print("Grand Total: $grandTotal");
    print(screenWith);

    List<WaterSource> sortedWaterSources = [...waterSource]
      ..sort((a, b) {
        bool aHasOutlet = a.outletPump.isNotEmpty;
        bool bHasOutlet = b.outletPump.isNotEmpty;

        bool aHasInlet = a.inletPump.isNotEmpty;
        bool bHasInlet = b.inletPump.isNotEmpty;

        if (aHasOutlet && !aHasInlet && (!bHasOutlet || bHasInlet)) return -1;
        if (bHasOutlet && !bHasInlet && (!aHasOutlet || aHasInlet)) return 1;

        return 0;
      });

    return Padding(
      padding: const EdgeInsets.all(8.0),
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
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: Column(
            children: [
              Row(
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
                        padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty?38.4:0),
                        child: Stack(
                          children: [
                            SizedBox(
                                width: 70,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left:index==0?33:0),
                                      child: Divider(thickness: 2, color: Colors.grey.shade300, height: 5.5),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left:index==0?37:0),
                                      child: Divider(thickness: 2, color: Colors.grey.shade300, height: 4.5),
                                    ),
                                  ],
                                )
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
                                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5))
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
                            padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty?38.4:0),
                            child: displayPump(pump),
                          );
                        }).toList(),
                      ),
                      if (isLastIndex && filterSite.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty?38.4:0),
                          child: displayFilterSite(context, filterSite),
                        ),
                      if (isLastIndex && fertilizerSite.isNotEmpty)
                        displayFertilizerSite(context, fertilizerSite),
                    ],
                  );
                  
                }).toList(),
              ),
              IrrigationLine(lineData: irrLineData, pumpStationWith: 0,),
            ],
          ),
        ),
      ),
    );


    /*return Padding(
      padding: const EdgeInsets.all(8.0),
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
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: ((fertilizerSite.isEmpty && (outletPump.length + filterSite.length) < 7) ||
              (fertilizerSite.isEmpty && irrLineData![0].valves.length < 25)) ?
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty?38.4:0),
                child: Stack(
                  children: [
                    SizedBox(
                        width: 70,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 33),
                              child: Divider(thickness: 2, color: Colors.grey.shade300, height: 5.5),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 37),
                              child: Divider(thickness: 2, color: Colors.grey.shade300, height: 4.5),
                            ),
                          ],
                        )
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
                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5))
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sourceName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    if (level != null) ...[
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
                              '${level!.percentage!} feet',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 50,
                        left: 5,
                        child: SizedBox(
                          width: 60,
                          child: Center(
                            child: Text(
                              '70%',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              if (outletPump.isNotEmpty)
                ...outletPump.map((pump) => Padding(
                  padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty?38.4:0),
                  child: displayPump(pump),
                )),
              if (filterSite.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty?38.4:0),
                  child: displayFilterSite(context, filterSite),
                ),

              if (irrLineData!.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14,),
                      Divider(height: 0, color: Colors.grey.shade300),
                      Container(height: 5, color: Colors.white24),
                      Divider(height: 0, color: Colors.grey.shade300),
                      IrrigationLine(lineData: irrLineData, pumpStationWith: (outletPump.length * 70)+210),
                    ],
                  ),
                ),
            ],
          ):
          ((fertilizerSite.isNotEmpty && (outletPump.length + filterSite.length) < 7) ||
              (fertilizerSite.isEmpty && irrLineData![0].valves.length < 15)) ?
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty?38.4:0),
                child: Stack(
                  children: [
                    SizedBox(
                        width: 70,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 33),
                              child: Divider(thickness: 2, color: Colors.grey.shade300, height: 5.5),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 37),
                              child: Divider(thickness: 2, color: Colors.grey.shade300, height: 4.5),
                            ),
                          ],
                        )
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
                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5))
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sourceName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    if (level != null) ...[
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
                              '${level!.percentage!} feet',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 50,
                        left: 5,
                        child: SizedBox(
                          width: 60,
                          child: Center(
                            child: Text(
                              '70%',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),

              if (outletPump.isNotEmpty)
                ...outletPump.map((pump) => Padding(
                  padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty?38.4:0),
                  child: displayPump(pump),
                )),

              if (filterSite.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty?38.4:0),
                  child: displayFilterSite(context, filterSite),
                ),

              if (fertilizerSite.isNotEmpty)
                displayFertilizerSite(context, fertilizerSite),

              Container(height: 142, width: 1, color: Colors.black12),
              const SizedBox(width: 2.0),
              Container(height: 147, width: 1, color: Colors.black12),

              IrrigationLine(lineData: irrLineData, pumpStationWith: 870,),

            ],
          ):
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 9, left: 5, right: 5),
                    child: outletPump.isNotEmpty? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty?38.4:0),
                          child: Stack(
                            children: [
                              SizedBox(
                                  width: 70,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 33),
                                        child: Divider(thickness: 2, color: Colors.grey.shade300, height: 5.5),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 37),
                                        child: Divider(thickness: 2, color: Colors.grey.shade300, height: 4.5),
                                      ),
                                    ],
                                  )
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
                                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5))
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sourceName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 10, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              if (level != null) ...[
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
                                        '${level!.percentage!} feet',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  top: 50,
                                  left: 5,
                                  child: SizedBox(
                                    width: 60,
                                    child: Center(
                                      child: Text(
                                        '70%',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),

                        if (outletPump.isNotEmpty)
                          ...outletPump.map((pump) => Padding(
                            padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty?38.4:0),
                            child: displayPump(pump),
                          )),

                        if (filterSite.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: fertilizerSite.isNotEmpty?38.4:0),
                            child: displayFilterSite(context, filterSite),
                          ),

                        if (fertilizerSite.isNotEmpty)
                          displayFertilizerSite(context, fertilizerSite),
                      ],
                    ):
                    const SizedBox(height: 20),
                  ),
                ),
              ),
              IrrigationLine(lineData: irrLineData, pumpStationWith: 0,)
              Divider(height: 0, color: Colors.grey.shade300),
              Container(height: 4, color: Colors.white24),
              Divider(height: 0, color: Colors.grey.shade300),
              IrrigationLine(lineData: irrLineData, pumpStationWith: 0,),
            ],
          ),
        ),
      ),
    );*/
  }

  Widget displayPump(Pump pump){
    return Stack(
      children: [
        SizedBox(
          width: 70,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: AppConstants.getAsset('pump', pump.status, ''),
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
                            Image.asset('assets/png_images/dp_prs_sensor.png',),
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
                                    /*Positioned(
                                      top: 55,
                                      left: 7.5,
                                      child: filterSite[i]['DurationLeft']!='00:00:00'? filterSite[i]['Status'] == (flIndex+1) ?
                                      Container(
                                        decoration: BoxDecoration(
                                          color:Colors.greenAccent,
                                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                                          border: Border.all(color: Colors.grey, width: .50,),
                                        ),
                                        width: 55,
                                        child: Center(
                                          child: Text(filterSite[i]['DurationLeft'],
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ) :
                                      const SizedBox(): const SizedBox(),
                                    ),
                                    Positioned(
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
                            Image.asset('assets/png_images/dp_prs_sensor.png',),
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
                                  child: Center(
                                    child: Text(fertilizerSite[fIndex].selector[0]['Status']!=0?
                                    fertilizerSite[fIndex].selector[0]['Name'] : '--' , style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    ),
                                  ),
                                ) :
                                const SizedBox(),
                              ),
                              Positioned(
                                top: 115,
                                left: 8.3,
                                child: Image.asset('assets/png_images/dp_frt_vertical_pipe.png', width: 9.5, height: 37,),
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
                            var fertilizer = fertilizerSite[fIndex].channel[index];
                            double fertilizerQty = 0.0;
                            var qtyValue = fertilizer.qty;
                            fertilizerQty = double.parse(qtyValue);

                            var fertilizerLeftVal = fertilizer.qtyLeft;
                            fertilizer.qtyLeft = fertilizerLeftVal;

                            return SizedBox(
                              width: 70,
                              height: 120,
                              child: Stack(
                                children: [
                                  buildFertilizerImage(index, fertilizer.status, fertilizerSite[fIndex].channel.length, fertilizerSite[fIndex].agitator),
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
                                        child: Text(fertilizer.fertMethod=='1' || fertilizer.fertMethod=='3'? fertilizer.duration :
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
                                        child: Text('${fertilizer.flowRate_LpH}-lph', style: const TextStyle(
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
                                    child: fertilizer.status !=0
                                        &&
                                        fertilizer.selected!='_'
                                        &&
                                        fertilizer.durationLeft !='00:00:00'
                                        ?
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      width: 50,
                                      child: Center(
                                        child: Text(fertilizer.fertMethod=='1' || fertilizer.fertMethod=='3'
                                            ? fertilizer.durationLeft
                                            : '${fertilizer.qtyLeft} L' , style: const TextStyle(
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
                                    child: Text(fertilizerSite[fIndex].name, style: TextStyle(color: primaryDark, fontSize: 11),),
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

    return Image.asset('assets/png_images/$imageName');

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

}
