import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../services/bluetooth_sevice.dart';
import '../../services/communication_service.dart';
import '../../services/sftp_service.dart';
import '../../utils/snack_bar.dart';

import 'dart:typed_data' show Uint8List;

class FirmwareBLEPage extends StatefulWidget {
  const FirmwareBLEPage({super.key});

  @override
  _FirmwareBLEPageState createState() => _FirmwareBLEPageState();
}

class _FirmwareBLEPageState extends State<FirmwareBLEPage> {
  double downloadProgress = 0.0;
  double transferProgress = 0.0;
  String status = "Ready";
  String contentString = "";
  int fileSize = 0;
  String fileChecksumSize = '';

  bool isDownloading = false;
  bool isDownloaded = false;

  late MqttPayloadProvider mqttPayloadProvider;

  late final Uint8List firmwareBytes;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _downloadToFile() async {
    setState(() {
      isDownloading = true;
      isDownloaded = false;
      status = "Downloading...";
    });

    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    List<String> traceData = mqttPayloadProvider.traceLog;
    SftpService sftpService = SftpService();
    int connectResponse = await sftpService.connect();

    if (connectResponse == 200) {
      await Future.delayed(const Duration(seconds: 1));

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String filePath = '$appDocPath/bootFile.txt';

      // Save trace log to file (optional)
      final localFile = File(filePath);
      await localFile.writeAsString(traceData.join('\n'));

      // Download file to the same path
      int downResponse = await sftpService.downloadFile(
        remoteFilePath: '/home/ubuntu/oro2024/OroGem/OroGemApp_RaspberryPi_64bit/OroGem',
       );

      if (downResponse == 200) {
        print('Download success');
        setState(() {
          GlobalSnackBar.show(context, "Download complete", 200);
          status = "Download complete";
          isDownloaded = true;
        });
      } else {
        GlobalSnackBar.show(context, "Download failed", 201);
        print('Download failed');
        setState(() {
          status = "Download failed";
        });
      }

      sftpService.disconnect();
    } else {
      setState(() {
        GlobalSnackBar.show(context, "Download failed", 201);
        status = "Connection failed";
      });
    }

    setState(() {
      isDownloading = false;
    });
  }

  Future<void> _deleteBootFile() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/bootFile.txt';
      File file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        print('bootFile.txt deleted successfully.');
      } else {
        print('bootFile.txt does not exist.');
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  Future<String?> calculateSHA256Checksum(String filePath) async {
    try {
       File file = File(filePath);

      if (await file.exists()) {
        List<int> fileBytes = await file.readAsBytes();
       firmwareBytes = Uint8List.fromList(fileBytes);

        Digest sha256Digest = sha256.convert(fileBytes);
        String hex = sha256Digest.toString().toUpperCase();
        print("SHA-256 Checksum: $hex");
        return hex;
      } else {
        print('bootFile.txt not found.');
        return null;
      }
    } catch (e) {
      print('Error calculating checksum: $e');
      return null;
    }
  }
  void _sendViaBle() {
    senddata();
     setState(() {
      status = "Sending via BLE...";
    });
  }

  Future<void> senddata() async {

    await readBootFileStringWithSize();
    await Future.delayed(const Duration(seconds: 1));
    String payLoadFinal = jsonEncode({
      "6900": {"6901": "1,$fileChecksumSize,$fileSize"},
    });
    print('payLoadFinal --> $payLoadFinal');

    final result = await context.read<CommunicationService>().sendCommand(
        payload: payLoadFinal,
        serverMsg: '');

    if (result['bluetooth'] == true) {
      debugPrint("Payload sent via Bluetooth");
      GlobalSnackBar.show(context, "Please wait... controller updating...", 200);
      writeUpdatedCode();
    }else{
      GlobalSnackBar.show(context, "Not Updating controller.. please verify the bluetooth connection and try again", 400);
    }
  }

  Future<void> writeUpdatedCode() async {
    final BluService blueService = BluService();
    const chunkSize = 512;
    for (int offset = 0; offset < firmwareBytes.length; offset += chunkSize) {
      final chunk = firmwareBytes.sublist(
        offset,
        offset + chunkSize > firmwareBytes.length
            ? firmwareBytes.length
            : offset + chunkSize,
      );

      print(chunk.runtimeType);
      print(chunk);

      String base64String = base64Encode(chunk);
      blueService.write(base64String);


     /* final resultcontent = await context.read<CommunicationService>().sendCommand(
          payload: base64String, serverMsg: '');
      if (resultcontent['http'] == true) {
        debugPrint("Payload sent to Server");
      }
      if (resultcontent['mqtt'] == true) {
        debugPrint("Payload sent to MQTT Box");
      }
      if (resultcontent['bluetooth'] == true) {
        debugPrint("Payload sent via Bluetooth");
      }*/
    }
    print('file write completed');

    GlobalSnackBar.show(context, "Payload sent via Bluetooth", 200);
  }


  Future<void> readBootFileStringWithSize() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/bootFile.txt';
      File file = File(filePath);
        if (await file.exists()) {
        List<int> contentsBytes = await file.readAsBytes();
        int sizeInBytes = contentsBytes.length;
        int sizeInKB = (sizeInBytes / 1024).ceil();
        print('contentStringreadBootFileStringWithSize 1---->$contentString sizeInKB:$sizeInKB');
        // String contents = await file.readAsString();
        // contentString = contents.trim();

        String contents = utf8.decode(contentsBytes, allowMalformed: true);
        contentString = contents.trim();

        print('contentStringreadBootFileStringWithSize 2---->$contentString');
        fileSize = sizeInBytes;
         final checksum = await calculateSHA256Checksum(filePath);
        fileChecksumSize = checksum as String;
        } else {
        print('bootFile.txt not found.');
      }
    } catch (e) {
      print('Error reading file: $e');
    }
  }

  Future<String?> readBootFileString(String filePath) async {
    try {
       File file = File(filePath);

      if (await file.exists()) {
        String contents = await file.readAsString();
        print('bootFile.txt contents$contents');
        return contents.trim();
      } else {
        print('bootFile.txt not found.');
        return null;
      }
    } catch (e) {
      print('Error reading file: $e');
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("EXE Transfer via Bluetooth")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Status: $status"),
            SizedBox(height: 20),

            if (isDownloading) ...[
              Center(child: CircularProgressIndicator()),
              SizedBox(height: 20),
            ],

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              onPressed: isDownloading ? null : _downloadToFile,
              child: Text("Download"),
            ),

            SizedBox(height: 20),

            // if (isDownloaded)
              ElevatedButton( style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
                onPressed: _sendViaBle,
                child: Text("Send via BLE"),
              ),
          ],
        ),
      ),
    );
  }
}

