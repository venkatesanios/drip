import 'dart:io';
import 'package:flutter/material.dart';
 import 'package:path_provider/path_provider.dart';
 import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../services/sftp_service.dart';

class FileTransferPage extends StatefulWidget {
  @override
  _FileTransferPageState createState() => _FileTransferPageState();
}

class _FileTransferPageState extends State<FileTransferPage> {
  double downloadProgress = 0.0;
  double transferProgress = 0.0;
  String status = "Ready";

  bool isDownloading = false;
  bool isDownloaded = false;

  late MqttPayloadProvider mqttPayloadProvider;

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

      String localFileNameForTrace = "gem_log";
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String filePath = '$appDocPath/$localFileNameForTrace.txt';
      final localFile = File(filePath);
      await localFile.writeAsString(traceData.join('\n'));

      int downResponse = await sftpService.downloadFile(
        remoteFilePath: '/home/ubuntu/oro2024/OroGem/OroGemApp_RaspberryPi_64bit/OroGem',
      );

      if (downResponse == 200) {
        print('download success');
        setState(() {
          status = "Download complete";
          isDownloaded = true;
        });
      } else {
        print('downResponse--->$downResponse');
        print('download failed');
        setState(() {
          status = "Download failed";
        });
      }

      sftpService.disconnect();
    } else {
      setState(() {
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

  void _sendViaBle() {
    // Your BLE sending logic here
    _deleteBootFile();
    print("Send via BLE clicked");
    setState(() {
      status = "Sending via BLE...";
    });
  }




  Future<String?> readBootFileString() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/bootFile.txt';
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

            if (isDownloaded)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
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

