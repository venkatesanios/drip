import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Models/customer/stand_alone_model.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
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

    if(viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData[0].sNo==0 ||
        viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData.length==1)
    {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  DisplayPumpStation(
                    sourceName: waterSources[0].name,
                    level: waterSources[0].level,
                    outletPump:  waterSources[0].outletPump ?? [],
                    irrLineData: lineData,
                    filterSite: filterSite,
                  ),
                  scheduledProgram.isNotEmpty? ScheduledProgram(userId: customerId, scheduledPrograms: scheduledProgram, masterInx: viewModel.mIndex):
                  const SizedBox(),
                  const SizedBox(height: 8,),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (lineData.isNotEmpty)
          DisplayPumpStation(
            sourceName: waterSources[0].name,
            level: waterSources[0].level,
            outletPump:  waterSources[0].outletPump ?? [],
            irrLineData: lineData,
            filterSite: filterSite,
          )
        else
          const Center(child: Text('Site not configure')),

      ],
    );
  }
}

class DisplayPumpStation extends StatelessWidget {

  final String sourceName;
  final Level? level;
  final List<Pump> outletPump;
  final List<FilterSite> filterSite;

  final List<IrrigationLineData>? irrLineData;

  const DisplayPumpStation({super.key, required this.level, required this.outletPump,
    required this.irrLineData, required this.sourceName, required this.filterSite});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                  width: 70,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: Divider(thickness: 2, color: Colors.grey.shade300, height: 10),
                  )
              ),
              SizedBox(
                width: 70,
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 20,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: VerticalDivider(thickness: 1, color: Colors.grey.shade400),
                      ),
                    ),
                    Container(
                      width: 45,
                      height: 50,
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
              if(level!=null)
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
            ],
          ),
          if (outletPump.isNotEmpty)
            ...outletPump.map((pump) => displayPump(pump)),
          if (filterSite.isNotEmpty)
            displayFilterSite(context, filterSite),
          if (irrLineData!.isNotEmpty)
            IrrigationLine(lineData: irrLineData, pumpStationWith: (outletPump.length * 70)+210),
        ],
      ),
    );
  }

  Widget displayPump(Pump pump){
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
                height: 10,
                child: Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: VerticalDivider(thickness: 3, color: Colors.grey.shade400),
                ),
              ),
              SizedBox(
                width: 70,
                height: 60,
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for(int i=0; i<filterSite.length; i++)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      filterSite[i].pressureIn!.isNotEmpty?
                      SizedBox(
                        width: 70,
                        height: 70,
                        child : Stack(
                          children: [
                            Image.asset('assets/images/dp_prs_sensor.png',),
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
                                  child: Text('${filterSite[i].pressureIn?['val'].toStringAsFixed(2)} bar', style: const TextStyle(
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
                                const SizedBox(height: 6),
                                SizedBox(
                                    width: 70,
                                    child: Divider(thickness: 2, color: Colors.grey.shade300, height: 0)
                                ),
                                Stack(
                                  children: [
                                    SizedBox(
                                      width: 70,
                                      height: 65,
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
                      filterSite[i].pressureOut!.isNotEmpty?
                      SizedBox(
                        width: 70,
                        height: 70,
                        child : Stack(
                          children: [
                            Image.asset('assets/images/dp_prs_sensor.png',),
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
                                  child: Text('${filterSite[i].pressureOut?['val'].toStringAsFixed(2)} bar', style: const TextStyle(
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
                    width: filterSite[i].pressureIn!.isNotEmpty? filterSite[i].filters.length * 70+70:
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


}

class SingleSourcePumpStationWithFilterAndFertilizer extends StatelessWidget {

  final String sourceName;
  final Level? level;
  final List<Pump> outletPump;
  final List<IrrigationLineData>? irrLineData;

  const SingleSourcePumpStationWithFilterAndFertilizer({super.key, required this.level, required this.outletPump, required this.irrLineData, required this.sourceName});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                  width: 70,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 35),
                    child: Divider(thickness: 2, color: Colors.grey.shade300, height: 10),
                  )
              ),
              SizedBox(
                width: 70,
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 20,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 3),
                        child: VerticalDivider(thickness: 1, color: Colors.grey.shade400),
                      ),
                    ),
                    Container(
                      width: 45,
                      height: 50,
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
              if(level!=null)
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
            ],
          ),
          if (outletPump.isNotEmpty)
            ...outletPump.map((pump) => displayPump(pump)),
          if (irrLineData!.isNotEmpty)
            IrrigationLine(lineData: irrLineData, pumpStationWith: (outletPump.length * 70)+210),
        ],
      ),
    );
  }

  Widget displayPump(Pump pump){
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
                height: 10,
                child: Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: VerticalDivider(thickness: 3, color: Colors.grey.shade400),
                ),
              ),
              SizedBox(
                width: 70,
                height: 60,
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
    /*return Column(
      children: [
        Stack(
          children: [
            Tooltip(
              message: 'View more details',
              child: TextButton(
                onPressed: () {
                },
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                  minimumSize: WidgetStateProperty.all(Size.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: SizedBox(
                  width: 80,
                  height: 50,
                  child: AppConstants.getAsset('pump', pump.status, ''),
                ),
              ),
            ),
            *//*pump.onDelayLeft != '00:00:00'? Positioned(
              top: 30,
              left: 7.5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  border: Border.all(color: Colors.green, width: .50),
                ),
                width: 55,
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
                      Text(pump.onDelayLeft,
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
            )
                : const SizedBox(),
            int.tryParse(pump.reason) != null && int.parse(pump.reason) > 0
                ? const Positioned(
              top: 10,
              left: 37.5,
              child: CircleAvatar(
                radius: 11,
                backgroundColor: Colors.orange,
                child: Icon(
                  Icons.running_with_errors,
                  size: 17,
                  color: Colors.white,
                ),
              ),
            )
                : const SizedBox(),*//*
          ],
        ),
        SizedBox(
          width: 70,
          height: 30,
          child: Text(
            pump.name!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );*/
  }

}