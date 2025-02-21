import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';

import '../../StateManagement/irrigation_program_provider.dart';

class NewAlarmScreen2 extends StatefulWidget {
  const NewAlarmScreen2({super.key});

  @override
  State<NewAlarmScreen2> createState() => _NewAlarmScreen2State();
}

class _NewAlarmScreen2State extends State<NewAlarmScreen2> {
  late IrrigationProgramMainProvider irrigationProgramMainProvider;

  @override
  void initState() {
    // TODO: implement initState
    irrigationProgramMainProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    irrigationProgramMainProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: true);

    final iconList = [
      MdiIcons.gaugeLow,
      MdiIcons.gaugeFull,
      MdiIcons.gaugeEmpty,
      'assets/SVGPicture/ec high.svg',
      'assets/SVGPicture/ph low.svg',
      'assets/SVGPicture/ph high.svg',
      MdiIcons.speedometerSlow,
      MdiIcons.speedometer,
      MdiIcons.powerPlugOff,
      'assets/SVGPicture/no communication.svg',
      'assets/SVGPicture/wrong feedback1.svg',
      'assets/SVGPicture/sump empty.svg',
      'assets/SVGPicture/tank full.svg',
      MdiIcons.batteryLow,
      'assets/SVGPicture/ec diff.svg',
      'assets/SVGPicture/ph-differencef.svg',
      'assets/SVGPicture/pumpoff1.svg',
      'assets/SVGPicture/pressure switch.svg',
      'assets/SVGPicture/pressure switch.svg',
    ];

    return Container(
      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MaterialButton(
              // color: Colors.greenAccent.shade100,
              // minWidth: MediaQuery.of(context).size.width - 40,
              textColor: Colors.white,
              elevation: 8,
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
              ),
              onPressed: () {
                setState(() {
                  for(var i = 0; i < irrigationProgramMainProvider.newAlarmList!.alarmList.length; i++) {
                    irrigationProgramMainProvider.newAlarmList!.alarmList[i].value = irrigationProgramMainProvider.newAlarmList!.defaultAlarm[i].value;
                  }
                });
              },
              child: Text("Use global alarm".toUpperCase()),
            ),
          ),
          const SizedBox(height: 5,),
          Expanded(
            child: ListView.builder(
                itemCount: irrigationProgramMainProvider.newAlarmList!.alarmList.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = irrigationProgramMainProvider.newAlarmList!.alarmList[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 5),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: AppProperties.customBoxShadow
                          ),
                          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 1200 ? 8 : 0),
                          child: ListTile(
                            horizontalTitleGap: 30,
                            title: Text(item.name),
                            trailing: IntrinsicWidth(
                              child: Switch(
                                  value: item.value,
                                  onChanged: (newValue) {
                                    setState(() {
                                      item.value = newValue;
                                    });
                                  }
                              ),
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppProperties.linearGradientLeading,
                              ),
                              child: iconList[index] is IconData
                                  ? Icon(
                                iconList[index] as IconData,
                                color: Colors.white,
                                size: 24,
                              )
                                  : SvgPicture.asset(
                                iconList[index] as String,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                       /* buildCustomListTile(
                            context: context,
                            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width > 1200 ? 8 : 0),
                            title: item.name,
                            icon: iconList[index],
                            // icon: Icons.alarm,
                            isSwitch: true,
                            switchValue: item.value,
                            onSwitchChanged: (newValue) {
                              setState(() {
                                item.value = newValue;
                              });
                            }
                        ),*/
                        SizedBox(height: index == irrigationProgramMainProvider.newAlarmList!.alarmList.length - 1 ? 80 : 5,)
                      ],
                    ),
                  );
                }
            ),
          )
        ],
      ),
    );
  }
}
