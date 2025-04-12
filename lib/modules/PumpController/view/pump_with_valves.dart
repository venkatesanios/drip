import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';

import '../../../Constants/constants.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../model/pump_controller_data_model.dart';
import '../widget/custom_countdown_timer.dart';

class PumpWithValves extends StatelessWidget {
  final PumpValveModel valveData;
  final int siteIndex, masterIndex;
  const PumpWithValves({super.key, required this.valveData, required this.siteIndex, required this.masterIndex});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CustomerScreenControllerViewModel>();
    final valves = provider.mySiteList.data[siteIndex].master[masterIndex].configObjects.where((e) => e.objectId == 13).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IntrinsicWidth(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: 25,
                decoration: const BoxDecoration(
                  // gradient: AppProperties.linearGradientLeading,
                    color: Color(0xffFFA300),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(3))
                ),
                child: const Center(
                  child: Text(
                    // '${Provider.of<PreferenceProvider>(context).individualPumpSetting![index].name}',
                    "Valves",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,),
                  ),
                ),
              ),
            ),
            // const Spacer(),
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey, size: 15,),
                const SizedBox(width: 5,),
                Text(
                  'Valve On Mode : ${valveData.valveOnMode == '1' ? "RTC ON" : "STANDALONE"}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const Spacer(),
            InkWell(
              onTap: (){},
              child: Icon(Icons.change_circle, color: Theme.of(context).primaryColorDark, size: 25,),
            ),
            const SizedBox(width: 10)
          ],
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Color(0xffFFA300),
              width: 0.5,
            ),
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                topRight: Radius.circular(10)
            ),
          ),
          elevation: 4,
          color: Colors.white,
          surfaceTintColor: Colors.white,
        /*  color: const Color(0xffFFF3D7),
          surfaceTintColor: const Color(0xffFFF3D7),*/
          shadowColor: const Color(0xffFFF3D7),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: MediaQuery.of(context).size.width <= 500 ? MediaQuery.of(context).size.width : 400,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: valves.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                // crossAxisSpacing: 20,
                // mainAxisSpacing: 20,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, i) {
                final valveItem = valveData.valves['V${i+1}']!;
                return Column(
                  children: [
                    Builder(
                        builder: (valveContext) {
                          return InkWell(
                            onTap: () => _showDetails(i, valveContext),
                            child: Image.asset(
                              'assets/png/valve_gray.png',
                              height: 40,
                              color: valveItem.status == '1'
                                  ? Colors.greenAccent
                                  : valveItem.status == '0'
                                  ? Colors.grey.shade100
                                  : valveItem.status == '2'
                                  ? Colors.redAccent
                                  : Colors.deepOrange,
                              colorBlendMode: BlendMode.modulate,
                            ),
                          );
                        }
                    ),
                    Text(valves[i].name, style: Theme.of(context).textTheme.titleSmall),
                    if (valveItem.status == '1' && valveData.remainingTime != '00:00:00')
                      IntrinsicWidth(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4)),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: CountdownTimerWidget(
                            key: Key(valveData.remainingTime),
                            initialSeconds: Constants.parseTime(valveData.remainingTime).inSeconds,
                          ),
                        ),
                      )
                  ],
                );
              },
            )
          ),
        ),
      ],
    );
  }

  void _showDetails(int i, BuildContext context) {
    showPopover(
      context: context,
      bodyBuilder: (context) => _buildValveContent(i, context),
      onPop: () {},
      direction: PopoverDirection.bottom,
      arrowHeight: 15,
      arrowWidth: 30,
      barrierColor: Colors.black54,
      width: 150,
      arrowDxOffset: 0,
      transitionDuration: const Duration(milliseconds: 150),
    );
  }

  Widget _buildValveContent(int i, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 5,),
        Text('Valve ${i+1}'),
        Text('Set : ${valveData.valves['V${i+1}']!.duration}'),
        const SizedBox(height: 5,)
        // Text('Actual : 00:00:10')
      ],
    );
  }
}
