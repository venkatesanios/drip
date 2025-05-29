import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:oro_drip_irrigation/modules/bluetooth_low_energy/utils/extra.dart';
import 'package:path_provider/path_provider.dart';
import '../../../services/sftp_service.dart';
import '../utils/snackbar.dart';
import '../view/node_connection_page.dart';

enum BleNodeState {
  loading,
  bluetoothOff,
  locationOff,
  scanning,
  deviceFound,
  deviceNotFound,
  connecting,
  connected,
  disConnected,
  dashboard,
}

enum NodeMode{
  applicationMode,
  bootMode
}

enum FileMode{
  connected,
  connecting,
  errorOnConnected,
  disConnected,
  idle,
  fileNameGetSuccess,
  fileNameNotGet,
  errorOnWhileGetFileName,
  tryAgainToGetFileName,
  downloadFileSuccess,
  downloadingFile,
  downloadFileFailed,
  sendingToHardware,
  crcPass,
  crcFail,
  firmwareUpdating,
  bootPass,
  bootFail,
}

class BleProvider extends ChangeNotifier {
  BleNodeState bleNodeState = BleNodeState.bluetoothOff;
  FileMode fileMode = FileMode.idle;

  /*scanning variables*/
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;


  /* connecting variables*/
  BluetoothDevice? device;
  int? _rssi;
  int? _mtuSize;
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  List<BluetoothService> _services = [];
  bool _isDiscoveringServices = false;
  bool _isConnecting = false;
  bool _isDisconnecting = false;
  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;
  late StreamSubscription<bool> _isConnectingSubscription;
  late StreamSubscription<bool> _isDisconnectingSubscription;
  late StreamSubscription<int> _mtuSubscription;

  /* communicating variables*/
  BluetoothService? myService;
  BluetoothCharacteristic? sendToHardware;
  BluetoothCharacteristic? readFromHardware;
  String sentAndReceive = '';
  List<int> sendToHardwareListeningValue = [];
  List<int> readFromHardwareListeningValue = [];
  late StreamSubscription<List<int>> sendToHardwareSubscription;
  late StreamSubscription<List<int>> readFromHardwareSubscription;
  Map<String, dynamic> nodeDataFromHw = {};
  String  readFromHardwareStringValue = '';
  int addingResult = 0;
  String addingStringResult = '';
  int totalNoOfLines = 0;
  int currentLine = 0;



  /* server variable*/
  Map<String, dynamic> nodeDataFromServer = {};
  String nodeFirmwareFileName = '';

  void editNodeDataFromServer(data){
    nodeDataFromServer = data;
    notifyListeners();
  }


  String connectionState(){
    if(_connectionState == BluetoothConnectionState.connected){
      return "Connected";
    }else if(_connectionState == BluetoothConnectionState.disconnected){
      return "DisConnected";
    }else{
      return "Connecting...";
    }
  }


  void autoScanAndFoundDevice({required String macAddressToConnect}) async{
    bleNodeState = BleNodeState.scanning;
    notifyListeners();
    startListeningDevice();
    startScan();
    outerLoop : for(var scanLoop = 0;scanLoop < 15;scanLoop++){
      await Future.delayed(const Duration(seconds: 1));
      print("_isScanning :: $_isScanning");
      for(var result in _scanResults){
        var adv = result.advertisementData;
        print("${adv.advName} ----------------- ${result.device.remoteId}");
        String upComingMacAddress = result.device.remoteId.toString().split(':').join('');
        if(macAddressToConnect == upComingMacAddress){
          device = result.device;
          bleNodeState = BleNodeState.deviceFound;
          notifyListeners();
          print("device is found ...............................................");
          await Future.delayed(const Duration(seconds: 2));
          break outerLoop;
        }
      }
    }
    if(bleNodeState != BleNodeState.deviceFound){
      bleNodeState = BleNodeState.deviceNotFound;
      notifyListeners();
    }
    stopScan();
    clearListOfScanDevice();
    if(bleNodeState == BleNodeState.deviceFound){
      autoConnect();
    }
  }

  Future startScan() async {
    try {
      // `withServices` is required on iOS for privacy purposes, ignored on android.
      var withServices = [Guid("180f")]; // Battery Level Service
      _systemDevices = await FlutterBluePlus.systemDevices(withServices);
    } catch (e, backtrace) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e), success: false);
      print(e);
      print("backtrace: $backtrace");
    }
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        withServices: [
          // Guid("180f"), // battery
          // Guid("180a"), // device info
          // Guid("1800"), // generic access
          // Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e"), // Nordic UART
        ],
        webOptionalServices: [
          Guid("180f"), // battery
          Guid("180a"), // device info
          Guid("1800"), // generic access
          Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e"), // Nordic UART
        ],
      );
    } catch (e, backtrace) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e), success: false);
      print(e);
      print("backtrace: $backtrace");
    }
  }

  Future stopScan() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e, backtrace) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e), success: false);
      print(e);
      print("backtrace: $backtrace");
    }
  }

  void startListeningDevice(){
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
    });
  }

  void clearListOfScanDevice(){
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    _scanResults.clear();
    _systemDevices.clear();
  }

  void autoConnect()async{
    bleNodeState = BleNodeState.connecting;
    notifyListeners();
    listeningConnectionState();
    for(var connectLoop = 0;connectLoop < 30;connectLoop++){
      await Future.delayed(const Duration(seconds: 1));
      print("connecting seconds :: ${connectLoop+1}");
      if(_connectionState == BluetoothConnectionState.connected){
        bleNodeState = BleNodeState.connected;
        notifyListeners();
        await Future.delayed(const Duration(seconds: 2));
        bleNodeState = BleNodeState.dashboard;
        notifyListeners();
        break;
      }
    }
    if(bleNodeState != BleNodeState.connected && bleNodeState != BleNodeState.dashboard){
      bleNodeState = BleNodeState.disConnected;
      notifyListeners();
    }
  }

  void listeningConnectionState(){
    onConnect();
    _connectionStateSubscription = device!.connectionState.listen((state) async {
      print("connection state :: $state");
      _connectionState = state;
      notifyListeners();
      if (state == BluetoothConnectionState.connected) {
        gettingStatusAfterConnect();
        _services = []; // must rediscover services
        _isDiscoveringServices = true;
        try {
          _services = await device!.discoverServices();
          onRequestMtuPressed();
          updateCharacteristic();
          if (kDebugMode) {
            print('_services === $_services');
            print(
                '----------------------------------------MTU SIZE REQUEST TO MAXIMUM------------------');
          }
          // Snackbar.show(ABC.c, "Discover Services: Success", success: true);
        } catch (e) {
          print('Error on discover service: $e');
          // Snackbar.show(ABC.c, prettyException("Discover Services Error:", e),
          //     success: false);
        }
        _isDiscoveringServices = false;
      }else if(state == BluetoothConnectionState.disconnected && bleNodeState != BleNodeState.connecting){
        print("state ::: $state");
        print("bleNodeState.name ::: ${bleNodeState.name}");
        clearBluetoothDeviceState();
        bleNodeState = BleNodeState.disConnected;
        notifyListeners();
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await device!.readRssi();
      }
    });

    _mtuSubscription = device!.mtu.listen((value) {
      _mtuSize = value;
    });

    _isConnectingSubscription = device!.isConnecting.listen((value) {
      _isConnecting = value;
    });

    _isDisconnectingSubscription = device!.isDisconnecting.listen((value) {
      _isDisconnecting = value;
    });
  }

  void gettingStatusAfterConnect() async {
    nodeDataFromHw = {};
    for (var i = 0; i < 200; i++) {
      try {
        if(nodeDataFromHw.isNotEmpty){
          break;
        }
        await Future.delayed(const Duration(seconds: 2));
        print('after connect ${i + 1}');
        print('Requesting mac address.....');
        requestingMac();
      } catch (e) {
        print('requesting mac is stopped due to : ${e.toString()}');
        break;
      }
    }
    notifyListeners();
  }

  void requestingMac()async{
    List<int> sendMac = [];
    for (var i in 'MAC\n'.split('')) {
      sendMac.add(i.codeUnitAt(0));
    }
    await sendToHardware!.write(sendMac,
    withoutResponse:
    sendToHardware!.properties.writeWithoutResponse);
  }

  void changingNodeToBootMode()async{
    List<int> checkBootFile = [];
    for (var bootCode
    in 'NIA_BLE_BOOT_SAMD21'.split('')) {
      checkBootFile.add(bootCode.codeUnitAt(0));
    }
    await sendToHardware!.write(
        checkBootFile,
        withoutResponse: sendToHardware!
            .properties.writeWithoutResponse);
  }

  void updateCharacteristic(){
    // for(BluetoothService service in _services){
    //   print("service : ${service.uuid}");
    //   for (var c = 0; c <  service.characteristics.length;c++){
    //     print('characteristic ${c+1} => (${service.characteristics[c].uuid})\n ${service.characteristics[c].properties}\n\n');
    //   }
    // }
    myService = _services[1];
    for (BluetoothCharacteristic c in myService!.characteristics) {
      // if(c.uuid.str.toUpperCase() == swWritingId){
      //   swWritingCharacteristic = c;
      //   notifyListeners();
      // }
      // print('uuid in ble : ${c.uuid.str}');
      print('uuid in pro : ${c.properties}');
      if (c.properties.writeWithoutResponse == false &&
          c.properties.write == true &&
          c.properties.notify == true) {
        print('find out => ${c.uuid.str}');
        if (readFromHardware == null) {
          listeningReadFromHardwareSubscription(c);
        }
        readFromHardware = c;
      }
      if (c.properties.writeWithoutResponse && !c.properties.notify) {
        if (sendToHardware == null) {
          listeningSendToHardwareSubscription(c);
        }
        sendToHardware = c;
      }
    }
  }

  void listeningSendToHardwareSubscription(BluetoothCharacteristic? characteristic) {
    print('listeningSendingData called............................................................');
    if (characteristic != null) {
      sendToHardwareSubscription =
          characteristic.lastValueStream.listen((value) {
            print('AppToHardware =>  ${String.fromCharCodes(value)}');
            // if (fileTraceControl != 'File') {
            sentAndReceive +=
            'AppToHardware ==> \n ${String.fromCharCodes(value)}\n len ${String.fromCharCodes(value).length}\n';
            // }
            if (value.isNotEmpty) {
              sentAndReceive += '${value.toString()} \n len ${value.length} \n';
              // await Future.delayed(Duration(seconds: 1));
              print('swListeningValue == > $value');
              // notifyListeners();
            }
          });
    } else {
      print('sending characteristic is null');
    }
  }

  void listeningReadFromHardwareSubscription(BluetoothCharacteristic? characteristic) {
    print(
        'listeningReceivingData called............................................................');
    if (characteristic != null) {
      characteristic.setNotifyValue(true);
      readFromHardwareSubscription =
          characteristic.lastValueStream.listen((value) async {
            print(value);
            String convertToString = String.fromCharCodes(value);
            print("read :: $convertToString");
            if(convertToString == "PASS"){
              fileMode = FileMode.crcPass;
              notifyListeners();
            }else if(convertToString == "FAIL"){
              fileMode = FileMode.crcFail;
              notifyListeners();
            }else if(convertToString == "START"){
              timeOutForBootMessage();
              fileMode = FileMode.firmwareUpdating;
              notifyListeners();
            }else if(convertToString == "BOOTPASS"){
              fileMode = FileMode.bootPass;
              notifyListeners();
            }
            sentAndReceive +=
            'HardwareToApp ==> \n ${String.fromCharCodes(value)}\n\n';
            if (value.isNotEmpty) {
              readFromHardwareStringValue += String.fromCharCodes(value);
            }
            if(value[value.length - 1] == 125){
              if(readFromHardwareStringValue[0] == '{'){
                nodeDataFromHw = jsonDecode(readFromHardwareStringValue);
                readFromHardwareStringValue = '';
              }else{
                readFromHardwareStringValue = '';
              }
            }
            print("nodeDataFromHw : $nodeDataFromHw");
            notifyListeners();
            // if (fileTraceControl == 'Trace') {
            //   print("fileTraceControl => $fileTraceControl");
            //   try {
            //     var day = DateTime.now().day;
            //     var month = DateTime.now().month;
            //     var year = DateTime.now().year;
            //     var hour = DateTime.now().hour;
            //     var minute = DateTime.now().minute;
            //     var second = DateTime.now().second;
            //     dynamic dataFromHw = String.fromCharCodes(value);
            //     dataFromHw = dataFromHw.split('|');
            //     dataFromHw = dataFromHw.join('\n');
            //     String traceData =
            //         '$day/$month/$year - $hour:$minute:$second :: $dataFromHw';
            //     traceResult += traceData;
            //     MQTTManager().publish(traceData.toString(),
            //         'getTraceFromBle/${nodeDataFromHw['MAC']}');
            //     notifyListeners();
            //   } catch (e) {
            //     print('mqtt error => ${e.toString()}');
            //   }
            // }
            // else {
            //   if (value.isNotEmpty) {
            //     hwListeningValue = value;
            //     if (addingStringTrace.isEmpty ||
            //         addingStringTrace.split('')[0] == '{') {
            //       addingStringTrace += String.fromCharCodes(value);
            //     }
            //     if (String.fromCharCodes(value).contains('_200')) {
            //       Future.delayed(const Duration(seconds: 2), () {
            //         Snackbar.show(
            //             ABC.c,
            //             prettyException("Message from hardware => ",
            //                 String.fromCharCodes(value)),
            //             success: true,
            //             hwMessageMode: true);
            //       });
            //     }
            //     print('String.fromCharCodes : ${String.fromCharCodes(value)}');
            //     if (String.fromCharCodes(value) == 'FAIL') {
            //       messageFromHw = 'failed';
            //       notifyListeners();
            //       for (var i = 0; i < 20; i++) {
            //         await Future.delayed(const Duration(seconds: 1));
            //       }
            //       messageFromHw = '';
            //     }
            //     if (String.fromCharCodes(value) == 'PASS') {
            //       messageFromHw = 'matched';
            //       notifyListeners();
            //       matchLoop:
            //       for (var i = 0; i < 20; i++) {
            //         print('seconds : ${i + 1}');
            //         await Future.delayed(const Duration(seconds: 1));
            //         if (i == 19 && messageFromHw == 'matched') {
            //           messageFromHw = 'incomplete';
            //           notifyListeners();
            //           break matchLoop;
            //         }
            //       }
            //       if (messageFromHw == 'incomplete') {
            //         for (var i = 0; i < 10; i++) {
            //           print('seconds : ${i + 1}');
            //           await Future.delayed(const Duration(seconds: 1));
            //           if (i == 9) {
            //             messageFromHw = '';
            //             notifyListeners();
            //           }
            //         }
            //       }
            //     }
            //     if (String.fromCharCodes(value) == 'START') {
            //       messageFromHw = 'start';
            //     }
            //     if (String.fromCharCodes(value) == 'BOOTPASS') {
            //       messageFromHw = 'updated';
            //       notifyListeners();
            //       for (var i = 0; i < 5; i++) {
            //         await Future.delayed(Duration(seconds: 1));
            //       }
            //       // messageFromHw = '';
            //       nodeDataFromHw = {};
            //     }
            //     if (String.fromCharCodes(value) == 'BOOTFAIL') {
            //       messageFromHw = 'boot failed';
            //       notifyListeners();
            //       for (var i = 0; i < 5; i++) {
            //         await Future.delayed(Duration(seconds: 1));
            //       }
            //       // messageFromHw = '';
            //       nodeDataFromHw = {};
            //     }
            //     if (value[value.length - 1] == 125) {
            //       print('addingStringTrace : $addingStringTrace');
            //       if (addingStringTrace.split('')[0] == '{') {
            //         nodeDataFromHw = jsonDecode(addingStringTrace);
            //         if (nodeDataFromHw['MAC'] != null) {
            //           nodeDataFromHw['MAC'] =
            //               '${nodeDataFromHw['MAC']}'.toUpperCase();
            //         }
            //         if (nodeDataFromHw.containsKey('WIFISSID')) {
            //           wifiSsid_controller.text = nodeDataFromHw['WIFISSID'];
            //         }
            //         if (nodeDataFromHw.containsKey('WIFISSID')) {
            //           wifiPassword_controller.text = nodeDataFromHw['WIFIPASS'];
            //         }
            //         if (nodeDataFromHw.containsKey('IFT')) {
            //           interfaceType = nodeDataFromHw['IFT'];
            //         }
            //         if (nodeDataFromHw.containsKey('FRQ')) {
            //           frequency.text = '${int.parse(nodeDataFromHw['FRQ']) / 10}';
            //         }
            //         if (nodeDataFromHw.containsKey('SF')) {
            //           spreadFactor.text = nodeDataFromHw['SF'];
            //         }
            //         if (nodeDataFromHw['PIN'] != null) {
            //           cumulative_Controller.text = nodeDataFromHw['PIN'];
            //         }
            //         if (nodeDataFromHw['BC'] != null) {
            //           battery_Controller.text = nodeDataFromHw['BC'];
            //         }
            //         if (nodeDataFromHw['AD7'] != null) {
            //           if (calibrationEc1 == 'ec1') {
            //             ec1Controller.text = nodeDataFromHw['AD7'];
            //           }
            //           if (calibrationEc1 == 'ec_1') {
            //             ec1_Controller.text = nodeDataFromHw['AD7'];
            //           }
            //         }
            //         if (nodeDataFromHw['AD8'] != null) {
            //           if (calibrationEc2 == 'ec2') {
            //             ec2Controller.text = nodeDataFromHw['AD8'];
            //           }
            //           if (calibrationEc2 == 'ec_2') {
            //             ec2_Controller.text = nodeDataFromHw['AD8'];
            //           }
            //         }
            //         if (nodeDataFromHw[
            //         'AD${nodeDataFromHw['MID'] == '35' ? '1' : '5'}'] !=
            //             null) {
            //           if (calibrationPh1 == 'ph1') {
            //             ph1Controller.text = nodeDataFromHw[
            //             'AD${nodeDataFromHw['MID'] == '35' ? '1' : '5'}'];
            //           }
            //           if (calibrationPh1 == 'ph_1') {
            //             ph1_Controller.text = nodeDataFromHw[
            //             'AD${nodeDataFromHw['MID'] == '35' ? '1' : '5'}'];
            //           }
            //         }
            //         if (nodeDataFromHw[
            //         'AD${nodeDataFromHw['MID'] == '35' ? '2' : '5'}'] !=
            //             null) {
            //           if (calibrationPh2 == 'ph2') {
            //             ph2Controller.text = nodeDataFromHw[
            //             'AD${nodeDataFromHw['MID'] == '35' ? '2' : '5'}'];
            //           }
            //           if (calibrationPh2 == 'ph_2') {
            //             ph2_Controller.text = nodeDataFromHw[
            //             'AD${nodeDataFromHw['MID'] == '35' ? '2' : '5'}'];
            //           }
            //         }
            //         addingStringTrace = '';
            //         print('nodeDataFromHw => $nodeDataFromHw');
            //       }
            //     }
            //     notifyListeners();
            //   }
            // }
          });
    } else {
      print('receiving characteristic is null');
    }
  }

  void timeOutForBootMessage()async{
    int totalTimeOut = 60;
    for(var second = 0;second < totalTimeOut;second++){
      if(fileMode == FileMode.bootPass){
        requestingMacUntilBootModeToApp();
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
      print("waiting for boot pass ${second+1}");
      if(second == 59){
        fileMode = FileMode.bootFail;
        notifyListeners();
        break;
      }
    }
  }

  void requestingMacUntilBootModeToApp()async{
    onDisconnect();
    // for(var waitLoop = 0;waitLoop < 15;waitLoop++){
    //   if(nodeDataFromHw['BOOT'] == '30'){
    //     break;
    //   }
    //   await Future.delayed(const Duration(seconds: 2));
    //   requestingMac();
    //   print("userShouldWaitForBootModeToApp seconds : ${waitLoop + 1}");
    //   print("nodeDataFromHw : ${nodeDataFromHw}");
    // }
  }

  Future onConnect() async {
    try {
      await device!.connectAndUpdateStream();
      // Snackbar.show(ABC.c, "Connect: Success", success: true);
    } catch (e, backtrace) {
      if (e is FlutterBluePlusException && e.code == FbpErrorCode.connectionCanceled.index) {
        // ignore connections canceled by the user
      } else {
        // Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
        print(e);
        print("backtrace: $backtrace");
      }
    }
  }

  Future onCancel() async {
    try {
      await device!.disconnectAndUpdateStream(queue: false);
      // Snackbar.show(ABC.c, "Cancel: Success", success: true);
    } catch (e, backtrace) {
      // Snackbar.show(ABC.c, prettyException("Cancel Error:", e), success: false);
      print("$e");
      print("backtrace: $backtrace");
    }
  }

  Future onDisconnect() async {
    try {
      await device!.disconnectAndUpdateStream();
      clearBluetoothDeviceState();
      bleNodeState = BleNodeState.disConnected;
      notifyListeners();
      // Snackbar.show(ABC.c, "Disconne
      // ct: Success", success: true);
    } catch (e, backtrace) {
      // Snackbar.show(ABC.c, prettyException("Disconnect Error:", e), success: false);
      print("$e backtrace: $backtrace");
    }
  }

  Future onRequestMtuPressed() async {
    try {
      await device!.requestMtu(330, predelay: 0);
      // Snackbar.show(ABC.c, "Request Mtu: Success", success: true);
    } catch (e, backtrace) {
      // Snackbar.show(ABC.c, prettyException("Change Mtu Error:", e), success: false);
      print(e);
      print("backtrace: $backtrace");
    }
  }

  void clearBluetoothDeviceState(){
    _connectionStateSubscription.cancel();
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    _rssi;
    _mtuSize;
  }

  Future<void> getFileName()async{
    try{
      SftpService sftpService = SftpService();
      fileMode = FileMode.connecting;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
      int connectResponse =  await sftpService.connect();
      if(connectResponse == 200){
        fileMode = FileMode.connected;
        notifyListeners();
        List<SftpName> listOfFile = await sftpService.listFilesInPath("/home/ubuntu/FTP/RTU");
        for(var file in listOfFile){
          print(file);
          if(file.filename.contains('version')){
            nodeFirmwareFileName = file.filename;
          }
        }
        if(nodeFirmwareFileName.isNotEmpty){
          fileMode = FileMode.fileNameGetSuccess;
          notifyListeners();
        }else{
          fileMode = FileMode.fileNameNotGet;
          notifyListeners();
        }
        fileMode = FileMode.downloadingFile;
        notifyListeners();
        await Future.delayed(const Duration(seconds: 2));
        int downloadResponse = await sftpService.downloadFile(remoteFilePath: '/home/ubuntu/FTP/RTU/$nodeFirmwareFileName');
        if(downloadResponse == 200){
          fileMode = FileMode.downloadFileSuccess;
        }else{
          fileMode = FileMode.downloadFileFailed;
        }
        sftpService.disconnect();
        notifyListeners();
      }else{
        fileMode = FileMode.errorOnConnected;
      }
      notifyListeners();
      
    }catch(e, backTrace){
      fileMode = FileMode.errorOnWhileGetFileName;
      print('Error on getting File Name :: ${e}');
      rethrow;
    }
  }

  void sendBootFile()async{
    try {
      List<String> listOfLine = await fetchBootFileInLocal();
      int noOfLinesToSend = 8;
      for (var line = 0; line < listOfLine.length; line += noOfLinesToSend) {
        List<int> dataList = [];
        var increasingLineCount = line + noOfLinesToSend;
        var slicingLoopFor8Line = increasingLineCount < listOfLine.length
            ? increasingLineCount
            : (increasingLineCount -
            (increasingLineCount - listOfLine.length));
        for (var count = line; count < slicingLoopFor8Line; count++) {
          var listOfSingleChar = listOfLine[count].split('');
          for (var takeTwo = 0;
          takeTwo < listOfSingleChar.length - 1;
          takeTwo += 2) {
            var doubleCharValue = int.parse(
                '${listOfSingleChar[takeTwo]}${listOfSingleChar[takeTwo + 1]}',
                radix: 16);
            dataList.add(doubleCharValue);
          }
        }

        List<int> writeData = [];
        for (var bytes = 0; bytes < dataList.length; bytes++) {
          addingResult += dataList[bytes];
          writeData.add(dataList[bytes]);
        }

        if (sendToHardware != null) {
          await sendToHardware!.write(writeData,
              withoutResponse:
              sendToHardware!.properties.writeWithoutResponse);
          await Future.delayed(const Duration(milliseconds: 10));
        }
        currentLine += 8;
        print("line ==================== $line");
        print("currentLine ==================== $currentLine");
        notifyListeners();
      }
      sendCalculatedCrc(lengthOfFile: listOfLine.length);
    } catch (e) {
      print('overAll Error => ${e.toString()}');
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
    notifyListeners();
  }

  Future<List<String>> fetchBootFileInLocal()async{
    fileMode = FileMode.sendingToHardware;
    notifyListeners();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    String localFileName = 'bootFile.txt';
    String filePath = '$appDocPath/$localFileName';
    File file = File(filePath);
    String fileContent = await file.readAsString();
    print('noOfLine   => ${fileContent.split('\n').length}');
    totalNoOfLines = 0;
    currentLine = 0;
    addingResult = 0;
    addingStringResult = '';
    List<String> listOfLine = fileContent.split('\n');
    totalNoOfLines = listOfLine.length;
    notifyListeners();
    return listOfLine;
  }

  void sendCalculatedCrc({required int lengthOfFile})async{
    try {
      await Future.delayed(Duration(seconds: 1));
      print('addingResult === > ${addingResult}');
      print('result is : ${addingResult.toRadixString(16).toUpperCase()}');

      String result = addingResult.toRadixString(16).toUpperCase();
      var resultList = result.split('');
      if (resultList.length > 8) {
        // Dont delete..............................................
        // Example list
        // List<dynamic> resultList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        // Using sublist to get the last 8 elements
        // resultList = resultList.sublist(resultList.length - 8);
        // Now `resultList` contains only the last 8 elements
        // print(resultList); // Output: [3, 4, 5, 6, 7, 8, 9, 10]
        // .................................................................
        resultList = resultList.sublist(resultList.length - 8);
      } else {
        int loop = 8 - resultList.length;
        for (var len = 0; len < loop; len++) {
          resultList.insert(0, '0');
        }
      }
      List<int> crcList = [];
      for (var crc = 0; crc < resultList.length; crc += 2) {
        crcList.add(
            int.parse('${resultList[crc]}${resultList[crc + 1]}', radix: 16));
      }
      List<int> crcName = [];
      String crcNameStr = 'CRC:';
      for (var cName in 'CRC:'.split('')) {
        crcName.add(cName.codeUnitAt(0));
      }
      List<int> fileLengthName = [];
      String fileLengthStr = ',L:';
      for (var fName in ',L:'.split('')) {
        fileLengthName.add(fName.codeUnitAt(0));
      }
      int fileSize = ((lengthOfFile) * 16).toInt();
      print('fileSize => ${fileSize}');
      String fileSizeString = fileSize.toRadixString(16).toUpperCase();
      var fileSizeStringList = fileSizeString.split('');
      if (fileSizeStringList.length > 8) {
        // Dont delete..............................................
        // Example list
        // List<dynamic> fileSizeStringList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        // Using sublist to get the last 8 elements
        // fileSizeStringList = fileSizeStringList.sublist(fileSizeStringList.length - 8);
        // Now `fileSizeStringList` contains only the last 8 elements
        // print(fileSizeStringList); // Output: [3, 4, 5, 6, 7, 8, 9, 10]
        // .................................................................
        fileSizeStringList =
            fileSizeStringList.sublist(fileSizeStringList.length - 8);
      } else {
        int loop = 8 - fileSizeStringList.length;
        for (var len = 0; len < loop; len++) {
          fileSizeStringList.insert(0, '0');
        }
      }
      print('fileSizeStringList => ${fileSizeStringList}');
      List<int> crcFormatFileSizeStringList = [];
      for (var cfsf = 0; cfsf < fileSizeStringList.length; cfsf += 2) {
        crcFormatFileSizeStringList.add(int.parse(
            '${fileSizeStringList[cfsf]}${fileSizeStringList[cfsf + 1]}',
            radix: 16));
      }
      List<int> finalOutPutOfCrcAndFileSize = [
        ...crcName,
        ...crcList,
        ...fileLengthName,
        ...crcFormatFileSizeStringList
      ];
      await Future.delayed(Duration(milliseconds: 100));
      await sendToHardware?.write(finalOutPutOfCrcAndFileSize,
          withoutResponse:
          sendToHardware!.properties.writeWithoutResponse);
      sentAndReceive +=
      'before conversion :: $crcNameStr$addingResult$fileLengthStr$fileSize';
      for (var crc in finalOutPutOfCrcAndFileSize) {
        sentAndReceive += '${crc.toRadixString(16).padLeft(2, '0')}';
      }

      sentAndReceive += 'file size ==> ${fileSize}';

    } catch (e) {
      print('Error on crc & others => ${e.toString()}');
    }

    Snackbar.show(ABC.c, "Write: Success", success: true);
    if (sendToHardware!.properties.read) {
      await sendToHardware!.read();
    }
  }
  
}