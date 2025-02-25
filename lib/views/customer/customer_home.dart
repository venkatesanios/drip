import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../utils/constants.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import 'home_sub_classes/irrigation_line.dart';

class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CustomerScreenControllerViewModel>(context);

    final waterSources = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.waterSource;
    final fertilizerSite = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.fertilizerSite;
    final lineData = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].config.lineData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (lineData.length == 1 && fertilizerSite.isEmpty)
          SingleSourcePumpStation(
            sourceName: waterSources[0].name,
            level: waterSources[0].level,
            outletPump:  waterSources[0].outletPump ?? [],
            irrLineData: lineData,
          )
        else
          const Text('No Single Water Source site'),
      ],
    );
  }
}

class SingleSourcePumpStation extends StatelessWidget {

  final String sourceName;
  final Level? level;
  final List<Pump> outletPump;
  final List<IrrigationLineData>? irrLineData;

  const SingleSourcePumpStation({super.key, required this.level, required this.outletPump, required this.irrLineData, required this.sourceName});

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