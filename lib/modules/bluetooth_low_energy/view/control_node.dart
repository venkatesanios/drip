import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/view/node_not_get_live.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../../../Constants/dialog_boxes.dart';
import '../state_management/ble_service.dart';

class ControlNode extends StatefulWidget {
  const ControlNode({super.key});

  @override
  State<ControlNode> createState() => _ControlNodeState();
}

class _ControlNodeState extends State<ControlNode> {
  late BleProvider bleService;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    bleService = Provider.of<BleProvider>(context, listen: false);
    bleService.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    bleService = Provider.of<BleProvider>(context, listen: true);
    int keyCount = bleService.nodeDataFromHw.keys.length;

    return Scaffold(
      backgroundColor: const Color(0xffF7FFFD),
      appBar: AppBar(
        title: const Text('Control'),
      ),
      body: keyCount > 4
          ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              if(bleService.nodeDataFromHw.containsKey('VER'))
                versionRow(),
              if(bleService.nodeDataFromHw.containsKey('R-VOLT'))
                voltageWidget(),
              relayWidget(),
              viewDetailsWidget(),
              if(bleService.nodeDataFromServer['analogInput'] != '-')
                analogDetailsWidget()

            ],
          ),
        ),
      )
          : NodeNotGetLive(
              loading: loading,
              onPressed: ()async{
                setState(() {
                  loading = true;
                });
                bleService.onRefresh();
                int delaySeconds = 5;
                for(var second = 0;second < delaySeconds;second++){
                  if(bleService.nodeDataFromHw.containsKey('BAT')){
                    break;
                  }
                  await Future.delayed(const Duration(seconds: 1));
                  if(second == (delaySeconds - 1)){
                    setState(() {
                      loading = false;
                    });
                  }
                }
              }
          ),
    );
  }

  Widget versionRow(){
    var versionList = bleService.nodeDataFromHw['VER'].split(',');
    var controller = versionList[0];
    var boot = versionList[1];
    var interFaceVersion = versionList.length > 2 ? versionList[2] : "0.0.0";
    return Row(
      spacing: 20,
      children: [
        Expanded(child: versionWidget(color: const Color(0xffEB7C17), title: 'Controller Version $controller')),
        Expanded(child: versionWidget(color: const Color(0xff005C8E), title: 'Boot Version $boot')),
        Expanded(child: versionWidget(color: const Color(0xffE0070A), title: '${bleService.nodeDataFromServer['interface']} Version $interFaceVersion')),
      ],
    );
  }

  Widget versionWidget({required Color color, required String title}){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 1, color: color),
        color: color.withValues(alpha: 0.1)
      ),
      child: Center(
        child: Text(title, style: TextStyle(color: color), textAlign: TextAlign.center,),
      ),
    );
  }

  Widget currentBox({required Color color, required String title}){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.5)
      ),
      child: Center(
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
      ),
    );
  }

  Widget voltageWidget(){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 0.5, color: const Color(0xff008CD7)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 4,
                spreadRadius: 0,
                color: const Color(0xff8B8282).withValues(alpha: 0.2)
            )
          ]
      ),
      child: Row(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text('Voltage', style: TextStyle(fontWeight: FontWeight.bold),),
            currentBox(color: const Color(0xffFF8688), title: 'RY : ${bleService.nodeDataFromHw['R-VOLT']}V'),
            currentBox(color: const Color(0xffFFED68), title: 'YB : ${bleService.nodeDataFromHw['Y-VOLT']}V'),
            currentBox(color: const Color(0xff6FAEFF), title: 'BR : ${bleService.nodeDataFromHw['B-VOLT']}V'),
          ]
      ),
    );
  }

  bool getRelayStatus(int relayNo){
    print("bleService.nodeDataFromHw['RLY'] : ${bleService.nodeDataFromHw['RLY']}");
    var relayStatusList = bleService.nodeDataFromHw['RLY'].split(',');
    return relayStatusList[relayNo] == '1' ? true : false;
  }

  Widget relayWidget(){
    int relayOrLatch = 0;
    if(bleService.nodeDataFromServer['latchOutput'] != '-'){
      relayOrLatch = int.parse(bleService.nodeDataFromServer['latchOutput']);
    }else if(bleService.nodeDataFromServer['relayOutput'] != '-'){
      relayOrLatch = int.parse(bleService.nodeDataFromServer['relayOutput']);
    }
    return Column(
      children: [
        Row(
          spacing: 20,
          children: [
            Container(
              width: 150,
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 8),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5) ,topRight: Radius.circular(27.5), ),
                  color: Color(0xff008CD7)
              ),
              child: const Center(
                child: Text('Relay Details',style: TextStyle(color: Colors.white, fontSize: 14),),
              ),
            ),
            Text('MAC Address : ${bleService.nodeDataFromHw['MAC']}', style: TextStyle(fontSize: 14),)
          ],
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topRight: Radius.circular(5), bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
              border: Border.all(width: 0.5, color: const Color(0xff008CD7)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                    spreadRadius: 0,
                    color: const Color(0xff8B8282).withValues(alpha: 0.2)
                )
              ]
          ),
          width: double.infinity,
          child: ResponsiveGridList(
            horizontalGridMargin: 0,
            verticalGridMargin: 10,
            minItemWidth: MediaQuery.of(context).size.width/2.5,
            shrinkWrap: true,
            listViewBuilderOptions: ListViewBuilderOptions(
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: [
              for(var relay = 0;relay < relayOrLatch;relay++)
                ListTile(
                  title: Text('Relay ${relay+1}', style: TextStyle(fontWeight: FontWeight.bold),),
                  trailing: Switch(
                      activeTrackColor: Theme.of(context).primaryColorLight,
                      value: getRelayStatus(relay),
                      onChanged: (value)async{
                        // $:13:148:0:0:0:0:0:0:0:0:277:<CR>
                        // var payload = '\$:13:147:';
                        var payload = bleService.nodeDataFromServer['settingCommand']['relaySettingCommand'].toString();
                        for (var r = 0;r < bleService.nodeDataFromHw['RLY'].split(',').length; r++) {
                          if (relay == r) {
                            payload += '${bleService.nodeDataFromHw['RLY'].split(',')[relay] == '0' ? '1' : '0'}:';
                          } else {
                            payload += '${bleService.nodeDataFromHw['RLY'].split(',')[r]}:';
                          }
                          // payload += '${smart['RLY'].split(',')[relay]}:';
                        }
                        List<int> listOfBytes = [];
                        var sumOfAscii = 0;
                        for (var i in payload.split('')) {
                          var bytes = i.codeUnitAt(0);
                          // listOfBytes.add(bytes);
                          sumOfAscii += bytes;
                        }
                        for (var i = 0; i < (3 - '${sumOfAscii % 256}'.split('').length); i++) {
                          payload += '0';
                        }
                        payload += '${sumOfAscii % 256}:\r';
                        for (var i in payload.split('')) {
                          var bytes = i.codeUnitAt(0);
                          listOfBytes.add(bytes);
                        }
                        if (kDebugMode) {
                          print(
                              'listOfBytes : $listOfBytes');
                          print('sumOfAscii : $sumOfAscii');
                          print(
                              'crc : ${sumOfAscii % 256}');
                          print('payload : $payload');
                        }
                        bleService.sendDataToHw(listOfBytes);
                        loadingDialog();
                      }
                  ),
                )
            ],
          ),
        )
      ],
    );
  }

  void loadingDialog()async{
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
    await Future.delayed(const Duration(seconds: 3), (){
      Navigator.pop(context);
    });
    simpleDialogBox(context: context, title: 'Success', message: 'Relay Setting Sent Successfully...');
  }

  Widget commonParameterWidget({required String title,required String? value,}){
    if(value == null){
      return Container();
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 8),
      width: 150,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Theme.of(context).primaryColor.withValues(alpha: 0.07)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(title.split('')[0].toUpperCase(),style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),),
          ),
          Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),textAlign: TextAlign.center,),
              Text(value, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),)
            ],
          ),
        ],
      ),
    );
  }

  Widget viewDetailsWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
        ResponsiveGridList(
          horizontalGridMargin: 0,
          verticalGridMargin: 10,
          minItemWidth: MediaQuery.of(context).size.width/2.5,
          shrinkWrap: true,
          listViewBuilderOptions: ListViewBuilderOptions(
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: [
            commonParameterWidget(title: 'Frequency', value: bleService.nodeDataFromHw['FRQ']),
            commonParameterWidget(title: 'Spread Factor', value: bleService.nodeDataFromHw['SF']),
            commonParameterWidget(title: 'Battery', value: bleService.nodeDataFromHw['BAT']),
            commonParameterWidget(title: 'Solar', value: bleService.nodeDataFromHw['SOL']),
            commonParameterWidget(title: 'Mfr Date', value: bleService.nodeDataFromHw['MFD']),
            commonParameterWidget(title: 'Repeater', value: bleService.nodeDataFromHw['REP'] == '1' ? 'ON' : 'OFF'),
            commonParameterWidget(title: 'Interface', value: bleService.nodeDataFromServer['interface']),
          ],
        )
      ],
    );
  }

  Widget analogDetailsWidget(){
    print("bleService.nodeDataFromServer : ${bleService.nodeDataFromServer}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Analog Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
        ResponsiveGridList(
          horizontalGridMargin: 0,
          verticalGridMargin: 10,
          minItemWidth: MediaQuery.of(context).size.width/2.5,
          shrinkWrap: true,
          listViewBuilderOptions: ListViewBuilderOptions(
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: [
              for(var analog = 0;analog < int.parse(bleService.nodeDataFromServer['analogInput']);analog++)
                if(bleService.nodeDataFromHw.containsKey('AD${analog+1}'))
                  commonParameterWidget(title: 'Analog ${analog + 1}', value: bleService.nodeDataFromHw['AD${analog+1}']),
          ],
        )
      ],
    );
  }

}
