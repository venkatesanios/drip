import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

import '../widget/custom_countdown_timer.dart';

class PumpWithValves extends StatelessWidget {
  const PumpWithValves({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          shape: const RoundedRectangleBorder(
            side: BorderSide(
              color: Color(0xffFFA300),
              width: 0.5,
            ),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10), topRight: Radius.circular(10)),
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
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 20,
              runSpacing: 20,
              children: [
                for(int i = 0; i < 10; i++)
                  Column(
                    children: [
                      Builder(
                        builder: (valveContext) => InkWell(
                          onTap: () => _showDetails(i, valveContext),
                          child: Image.asset(
                            'assets/png/valve_gray.png',
                            height: 40,
                            color: i < 2 ? Colors.grey.shade100 : i > 5 ? Colors.greenAccent : Colors.deepOrange,
                            colorBlendMode: BlendMode.modulate,
                          ),
                        ),
                      ),
                      Text('Valve ${i+1}', style: Theme.of(context).textTheme.titleSmall,),
                      IntrinsicWidth(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4)
                            ),
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: const CountdownTimerWidget(initialSeconds: 30,)
                          )
                      )
                    ],
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDetails(int i, BuildContext context){
    final RenderBox button = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = button.localToGlobal(Offset.zero, ancestor: overlay);

    showPopover(
      context: context,
      bodyBuilder: (context) => _buildValveContent(i, context),
      onPop: () => print('Popover was popped!'),
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
        Text('Valve ${i+1}'),
        Text('Set : 00:00:30'),
        Text('Actual : 00:00:10')
      ],
    );
  }
}
