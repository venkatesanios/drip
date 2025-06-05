import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Constants/dialog_boxes.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';
import 'package:provider/provider.dart';

import '../state_management/ble_service.dart';

class InterfaceSetting extends StatefulWidget {
  const InterfaceSetting({super.key});

  @override
  State<InterfaceSetting> createState() => _InterfaceSettingState();
}

class _InterfaceSettingState extends State<InterfaceSetting> {
  late BleProvider bleService;
  FocusNode frequencyFocus = FocusNode();
  FocusNode spreadingFactorFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  String userName = '';
  String password = '';

  final inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
  );

  @override
  void initState() {
    bleService = Provider.of<BleProvider>(context, listen: false);
    // TODO: implement initState
    super.initState();
    bleService.onRefresh();
    frequencyFocus.addListener(() {
      if(frequencyFocus.hasFocus == false){
        var value = double.parse(bleService.frequency.text == '' ? '0' : bleService.frequency.text);
        if(value > 850.0 && value < 1000.0){

        }else{
          setState(() {
            bleService.frequency.text = '850.0';
          });
          simpleDialogBox(message: 'Frequency should be in the range of 850.0 to 880.0',context: context,title: 'Alert');
        }
      }
    });
    spreadingFactorFocus.addListener(() {
      if(spreadingFactorFocus.hasFocus == false){
        var value = int.parse(bleService.spreadFactor.text == '' ? '0' : bleService.spreadFactor.text);
        if(value >= 7.0 && value <= 12.0){

        }else{
          setState(() {
            bleService.spreadFactor.text = '7';
          });
          simpleDialogBox(message: 'Spreading factor should be in the range of 7 to 12',context: context, title: 'Alert');
        }
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    frequencyFocus.dispose();
    spreadingFactorFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interface Setting'),
      ),
      body: RefreshIndicator(
        onRefresh: bleService.onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 30,
                  children: [
                    const SizedBox(height: 30),
                    SvgPicture.asset(
                      'assets/Images/Svg/SmartComm/interface_setting.svg',
                      height: 150,
                    ),
                    if (bleService.nodeDataFromHw['IFT'] == '1') loraSetting(),
                    if (bleService.nodeDataFromHw['IFT'] == '2') mqttSetting(),
                    if (bleService.nodeDataFromHw['IFT'] == '4') wifiSetting(),
                  ],
                ),
              ),
            );
          },
        ),
      ),

    );
  }

  Widget loraSetting(){
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter Signal Parameters",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextFormField(
                focusNode: frequencyFocus,
                controller: bleService.frequency,
                keyboardType: TextInputType.number,
                decoration: inputDecoration.copyWith(
                  labelText: "Frequency",
                  hintText: "Enter frequency",
                  prefixIcon: const Icon(Icons.waves),
                  suffixText: "Hz",
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                focusNode: spreadingFactorFocus,
                controller: bleService.spreadFactor,
                keyboardType: TextInputType.number,
                decoration: inputDecoration.copyWith(
                  labelText: "Spread Factor",
                  hintText: "Enter spread factor",
                  prefixIcon: const Icon(Icons.scatter_plot),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Enable Repeater",
                    style: TextStyle(fontSize: 16),
                  ),
                  Switch(
                    value: bleService.nodeDataFromHw['REP'] == '0' ? false : true,
                    activeColor: Colors.blueAccent,
                    onChanged: (value) {
                      print('value ==> $value');
                      setState(() {
                        bleService.nodeDataFromHw['REP'] = (value ? '1' : '0');
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (){
                    var payload = '${bleService.nodeDataFromServer['settingCommand']['loraSettingCommand']}${(double.parse(bleService.frequency.text)*10).toInt()}:${bleService.spreadFactor.text}:${bleService.nodeDataFromHw['REP']}:';
                    List<int> listOfBytes = [];
                    var sumOfAscii = 0;
                    for(var i in payload.split('')){
                      var bytes = i.codeUnitAt(0);
                      sumOfAscii += bytes;
                    }
                    for(var i = 0;i < (3 - '${sumOfAscii % 256}'.split('').length);i++){
                      payload += '0';
                    }
                    payload += '${sumOfAscii % 256}:\r';
                    for(var i in payload.split('')){
                      var bytes = i.codeUnitAt(0);
                      listOfBytes.add(bytes);
                    }
                    print('listOfBytes : $listOfBytes');
                    print('sumOfAscii : $sumOfAscii');
                    print('crc : ${sumOfAscii % 256}');
                    print('payload : ${payload}');
                    bleService.sendDataToHw(listOfBytes);
                    loadingDialog();
                  },
                  icon: const Icon(Icons.send, color: Colors.white,),
                  label: const Text("Submit", style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget mqttSetting(){
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Fields are hidden for security purposes.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center,
              ),
              for(var field in ['Mqtt Port', 'Mqtt User Name', 'Mqtt Password'])
                SizedBox(
                  width: double.infinity,
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(field, style: const TextStyle(fontSize: 16),),
                      const Text('******************', style: TextStyle(fontSize: 14, color: Colors.black54))
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (){
                    var payload = '${bleService.nodeDataFromServer['settingCommand']['mqttSettingCommand']}${AppConstants.mqttUrlMobile}:${AppConstants.mqttUserName}:${AppConstants.mqttPassword}:';
                    List<int> listOfBytes = [];
                    var sumOfAscii = 0;
                    for(var i in payload.split('')){
                      var bytes = i.codeUnitAt(0);
                      // listOfBytes.add(bytes);
                      sumOfAscii += bytes;
                    }
                    for(var i = 0;i < (3 - '${sumOfAscii % 256}'.split('').length);i++){
                      payload += '0';
                    }
                    payload += '${sumOfAscii % 256}:\r';
                    for(var i in payload.split('')){
                      var bytes = i.codeUnitAt(0);
                      listOfBytes.add(bytes);
                    }
                    print('listOfBytes : $listOfBytes');
                    print('sumOfAscii : $sumOfAscii');
                    print('crc : ${sumOfAscii % 256}');
                    print('payload : ${payload}');
                    bleService.sendDataToHw(listOfBytes);
                    loadingDialog();
                  },
                  icon: const Icon(Icons.send, color: Colors.white,),
                  label: const Text("Submit", style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget wifiSetting(){
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Enter Signal Parameters",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: bleService.wifiSsid,
                  decoration: inputDecoration.copyWith(
                    labelText: "Wifi SSID",
                    hintText: "Enter SSID",
                    prefixIcon: const Icon(Icons.wifi),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: bleService.wifiPassword,
                  decoration: inputDecoration.copyWith(
                    labelText: "Wifi Password",
                    hintText: "Enter Password",
                    prefixIcon: const Icon(Icons.password),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      String staticIp = '0:0:0:0';
                      String subNetMask = '0:0:0:0';
                      String gateWay = '0:0:0:0';
                      String dnsServer = '0:0:0:0';
                      String serverIp = '0:0:0:0';
                      var payload = '\$:29:210:${bleService.wifiSsid.text}:${bleService.wifiPassword.text}:${AppConstants.mqttUserName}:${AppConstants.mqttPassword}:$staticIp:$subNetMask:$gateWay:$dnsServer:$serverIp:';
                      List<int> listOfBytes = [];
                      var sumOfAscii = 0;
                      for(var i in payload.split('')){
                        var bytes = i.codeUnitAt(0);
                        sumOfAscii += bytes;
                      }
                      payload += '${sumOfAscii % 256}:\r';
                      for(var i in payload.split('')){
                        var bytes = i.codeUnitAt(0);
                        listOfBytes.add(bytes);
                      }
                      print('listOfBytes : $listOfBytes');
                      print('sumOfAscii : $sumOfAscii');
                      print('crc : ${sumOfAscii % 256}');
                      print('payload : ${payload}');
                      bleService.sendDataToHw(listOfBytes);
                      loadingDialog();
                    },
                    icon: const Icon(Icons.send, color: Colors.white,),
                    label: const Text("Submit", style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
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
    await Future.delayed(Duration(seconds: 2), (){
      Navigator.pop(context);
    });
    simpleDialogBox(context: context, title: 'Success', message: 'Interface Setting Sent Successfully...');
  }
}
