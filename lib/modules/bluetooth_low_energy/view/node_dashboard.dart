import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oro_drip_irrigation/Widgets/custom_buttons.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/view/ble_sent_and_receive.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/view/calibration.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/view/control_node.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/view/interface_setting.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/view/node_in_boot_mode.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/view/trace_screen.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '../state_management/ble_service.dart';

class NodeDashboard extends StatefulWidget {
  final Map<String, dynamic> nodeData;
  const NodeDashboard({super.key, required this.nodeData});

  @override
  State<NodeDashboard> createState() => _NodeDashboardState();
}

class _NodeDashboardState extends State<NodeDashboard> {
  late BleProvider bleService;
  late int fileNameResponse;

  @override
  void initState() {
    super.initState();
    bleService = Provider.of<BleProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    bleService = Provider.of<BleProvider>(context, listen: true);
    if(bleService.nodeDataFromHw['BOOT'] == '31'){
      return const NodeInBootMode();
    }
    return RefreshIndicator(
      onRefresh: bleService.onRefresh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ResponsiveGridList(
                  minSpacing: 20,
                  desiredItemWidth: 120,
                  children: [
                    gridItemWidget(
                        imagePath: 'assets/Images/Svg/SmartComm/bootMode.svg',
                        title: 'Update Firmware',
                      onTap: (){
                        userAcknowledgementForUpdatingFirmware();
                      }
                    ),
                    if(!bleService.loraModel.contains(bleService.nodeDataFromHw['MID']) && (!AppConstants.pumpWithValveModelList.contains(bleService.nodeData['modelId']) && !AppConstants.ecoGemModelList.contains(bleService.nodeData['modelId'])))
                    ...[
                      if(bleService.nodeDataFromHw.containsKey('RLY'))
                        gridItemWidget(
                          imagePath: 'assets/Images/Svg/SmartComm/control.svg',
                          title: 'Control',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return const ControlNode();
                            }));
                          },
                        ),
                      gridItemWidget(
                          imagePath: 'assets/Images/Svg/SmartComm/interface_setting.svg',
                          title: 'Interface Setting',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return const InterfaceSetting();
                            }));
                          }
                      ),
                      gridItemWidget(
                        imagePath: 'assets/Images/Svg/SmartComm/trace_file.svg',
                        title: 'Trace',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return TraceScreen(nodeData: widget.nodeData,);
                          }));
                        },
                      ),
                      gridItemWidget(
                        imagePath: 'assets/Images/Svg/SmartComm/calibration.svg',
                        title: 'Calibration',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return Calibration(nodeData: widget.nodeData,);
                          }));
                        },
                      ),
                    ],
                    if(bleService.developerOption >= 10)
                      gridItemWidget(
                        imagePath: 'assets/Images/Svg/SmartComm/sent_and_receive.svg',
                        title: 'Sent And Receive',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return const BleSentAndReceive();
                          }));
                        },
                      ),
                  ]
              ),
            ),
          ),
          // NodeInBootMode()
        ],
      ),
    );
  }

  void userAcknowledgementForUpdatingFirmware(){
    showDialog(
      barrierDismissible: false,
        context: context, builder: (context){
          return AlertDialog(
            title: Text('Do you want to update firmware', style: TextStyle(fontSize: 14),),
            actions: [
              CustomMaterialButton(
                title: 'Yes',
                onPressed: (){
                  bleService.changingNodeToBootMode();
                  Navigator.pop(context);
                  userShouldWaitUntilRestart();
                },
              )
            ],
          );
      }
      );
  }

  void nodeNotInBootMode(){
    showDialog(
        barrierDismissible: false,
        context: context, builder: (context){
      return AlertDialog(
        title: const Text('Device not changed to Boot Mode.', style: TextStyle(fontSize: 14),),
        actions: [
          CustomMaterialButton()
        ],
      );
    }
    );
  }

  void userShouldWaitUntilRestart()async{
    showDialog(
        barrierDismissible: false,
        context: context, builder: (context){
      return const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            spacing: 20,
            children: [
              CircularProgressIndicator(),
              Text('Please wait...')
            ],
          ),
        ),
      );
    }
    );
    bool closeDialog = false;
    for(var waitLoop = 0;waitLoop < 15;waitLoop++){
      if(bleService.nodeDataFromHw['BOOT'] == '31'){
        closeDialog = true;
        break;
      }
      await Future.delayed(const Duration(seconds: 2));
      bleService.requestingMac();
      print("userShouldWaitUntilRestart seconds : ${waitLoop + 1}");
      print("nodeDataFromHw : ${bleService.nodeDataFromHw}");
    }
    if(closeDialog){
      Navigator.pop(context);
    }else{
      Navigator.pop(context);
      nodeNotInBootMode();
    }
  }

  Widget gridItemWidget({
    required String imagePath,
    required String title,
    required void Function() onTap
}){
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 5),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SvgPicture.asset(
              imagePath,
              height: 80,
            ),
            Text(title, style: const TextStyle(fontSize: 14),textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }
}