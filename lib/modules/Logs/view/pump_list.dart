
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/modules/Logs/view/pump_log.dart';
import 'package:oro_drip_irrigation/modules/Logs/view/voltage_log.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '../../../Models/customer/site_model.dart';
import 'power_graph_screen.dart';

class PumpList extends StatefulWidget {
  final List pumpList;
  final int userId;
  final MasterControllerModel masterData;
  const PumpList({super.key, required this.pumpList, required this.userId, required this.masterData});

  @override
  State<PumpList> createState() => _PumpListState();
}

class _PumpListState extends State<PumpList> {

  @override
  Widget build(BuildContext context) {
    return ResponsiveGridList(
      desiredItemWidth: MediaQuery.of(context).size.width >= 600
          ? MediaQuery.of(context).size.width / 3
          : MediaQuery.of(context).size.width,
      minSpacing: 10,
      children: List.generate(widget.pumpList.length, (index) {
        final pumpItem = widget.pumpList[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: AppProperties.customBoxShadowLiteTheme,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppProperties.linearGradientLeading,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text('${pumpItem['deviceName']}'),
              subtitle: Text('${pumpItem['deviceId']}'),
            ),
            subtitle: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 3; i++)
                    actionChip(
                      title: ['Pump Log', 'Power', 'Voltage'][i],
                      iconColor: [Colors.orange, Colors.red, Colors.green][i],
                      backgroundColor: [
                        const Color(0xffFFF0E5),
                        const Color(0xffFFDEDC),
                        const Color(0xffEFFFFB)
                      ][i],
                      icon: [
                        Icons.schedule,
                        Icons.auto_graph,
                        Icons.electric_bolt
                      ][i],
                      onPressed: [
                            () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => PumpLogScreen(
                            userId: widget.userId,
                            controllerId: widget.masterData.controllerId,
                            nodeControllerId: pumpItem['controllerId'],
                            masterData: widget.masterData,
                          ),
                        ),
                            () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => PowerGraphScreen(
                            userId: widget.userId,
                            controllerId: widget.masterData.controllerId,
                            nodeControllerId: pumpItem['controllerId'],
                            masterData: widget.masterData,
                          ),
                        ),
                            () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => PumpVoltageLogScreen(
                            userId: widget.userId,
                            controllerId: widget.masterData.controllerId,
                            nodeControllerId: pumpItem['controllerId'],
                            masterData: widget.masterData,
                          ),
                        ),
                      ][i],
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget actionChip({required String title, required IconData icon,
    required void Function()? onPressed, required Color backgroundColor,
    required Color iconColor
  }) {
    return ActionChip.elevated(
      label: Text(title),
      backgroundColor: backgroundColor,
      avatar: Icon(icon, color: iconColor,),
      // avatar: Container(
      //   height: 35,
      //   width: 35,
      //   decoration: BoxDecoration(
      //     shape: BoxShape.circle,
      //     gradient: linearGradientLeading,
      //   ),
      //   child: Center(child: Icon(icon, color: Colors.white,),),
      // ),
      onPressed: onPressed,
      pressElevation: 20,
      elevation: 8,
    );
  }
}
