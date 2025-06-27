import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int fileSize = 0;
  String fileChecksumSize = '';
  bool isDownloading = false;
  bool isDownloaded = false;
  bool isLoading = false;
  late MqttPayloadProvider mqttPayloadProvider;
  late final Uint8List firmwareBytes;
  String? selectedFile;
  final List<String> files = [
    'OrogemCode',
    'AutoStartFile',
    'MqttsCaFile',
    'MqttsClientCrtFile',
    'MqttsClientKeyFile',
    'ReverseSshpemfile',
    'SftpPemFile',
  ];

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);
  }

  Map<String, dynamic>? getFileInfo(String fileName) {
    final Map<String, Map<String, dynamic>> fileData = {
      'OrogemCode': {
        'code': 1,
        'path':
            '/home/ubuntu/oro2024/OroGem/OroGemApp_RaspberryPi_64bit/OroGem',
      },
      'AutoStartFile': {
        'code': 2,
        'path':
            '/home/ubuntu/oro2024/OroGem/OroGemApp_AutoStart_RaspberryPi_64bit/AutoStartF',
      },
      'MqttsCaFile': {
        'code': 3,
        'path':
            '/home/ubuntu/oro2024/OroGem/OroGemApp_AutoStart_RaspberryPi_64bit', // replace with actual path
      },
      'MqttsClientCrtFile': {
        'code': 4,
        'path': '/home/ubuntu/oro2024/OroGem/OroGemApp_AutoStart_Tinker_64bit',
      },
      'MqttsClientKeyFile': {
        'code': 5,
        'path': '/home/ubuntu/oro2024/OroGem/OroGemApp_RaspberryPi_32bit',
      },
      'ReverseSshpemfile': {
        'code': 6,
        'path': '/home/ubuntu/oro2024/OroGem/OroGemApp_RaspberryPi_64bit',
      },
      'SftpPemFile': {
        'code': 7,
        'path': '/home/ubuntu/oro2024/OroGem/OroGemLogs',
      },
    };

    return fileData[fileName]; // returns null if not found
  }

  Future<void> _downloadToFile() async {
    setState(() {
      isDownloading = true;
      isDownloaded = false;
      status = "Downloading...";
    });

    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: false);
    List<String> traceData = mqttPayloadProvider.traceLog;
    SftpService sftpService = SftpService();
    int connectResponse = await sftpService.connect();

    if (connectResponse == 200) {
      await Future.delayed(const Duration(seconds: 1));

      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String filePath = '$appDocPath/$selectedFile.txt';

      // Save trace log to file (optional)
      final localFile = File(filePath);
      await localFile.writeAsString(traceData.join('\n'));
      final info = getFileInfo(selectedFile!);
      // Download file to the same path
      print('info![path]:-${info!['path']}\n,selectedFile:$selectedFile');
      int downResponse = await sftpService.downloadFile(
          remoteFilePath: info!['path'], localFileName: '$selectedFile.txt');

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
      String filePath = '${appDocDir.path}/$selectedFile.txt';
      File file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        print('$selectedFile.txt deleted successfully.');
      } else {
        print('$selectedFile.txt does not exist.');
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
        String hex = sha256Digest.toString();
        print("SHA-256 Checksum: $hex");
        return hex;
      } else {
        print('$selectedFile.txt not found.');
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
      isLoading = true;
      status = "Sending via BLE...";
    });
  }

  Future<void> senddata() async {
    await readBootFileStringWithSize();
    await Future.delayed(const Duration(seconds: 1));

    final BluService blueService = BluService();
    final info = getFileInfo(selectedFile!);
    String payLoadFinal = jsonEncode({
      "6900": {"6901": "${info?['code']},$fileChecksumSize,$fileSize"},
    });
    print('payLoadFinal --> $payLoadFinal');
    await blueService.write(payLoadFinal);

    sendFirmwareFromFile();
  }

  Future<void> sendFirmwareFromFile() async {
    final BluService blueService = BluService();
    const chunkSize = 1024;

    try {
      // Get file path
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/$selectedFile.txt';

      // Read file bytes
      final Uint8List firmwareBytes = await File(filePath).readAsBytes();
      print('📦 Loaded ${firmwareBytes.length} bytes from file');

      // Send in chunks
      for (int offset = 0; offset < firmwareBytes.length; offset += chunkSize) {
        final chunk = firmwareBytes.sublist(
          offset,
          (offset + chunkSize > firmwareBytes.length)
              ? firmwareBytes.length
              : offset + chunkSize,
        );
        print('🔹 Sending chunk of size ${chunk.length}');
        await blueService.writeFW(chunk);
      }
      setState(() => isLoading = false);
      print('✅ Firmware sent over Bluetooth');
    } catch (e) {
      setState(() => isLoading = false);
      print('❌ Error loading or sending firmware: $e');
    }
  }

  Future<void> readBootFileStringWithSize() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDocDir.path}/$selectedFile.txt';
      File file = File(filePath);
      if (await file.exists()) {
        List<int> contentsBytes = await file.readAsBytes();
        int sizeInBytes = contentsBytes.length;
        int sizeInKB = (sizeInBytes / 1024).ceil();
        print(
            'contentStringreadBootFileStringWithSize 1---sizeInBytes->$sizeInBytes sizeInKB:$sizeInKB');

        fileSize = sizeInBytes;
        final checksum = await calculateSHA256Checksum(filePath);
        fileChecksumSize = checksum as String;
      } else {
        print('$selectedFile.txt not found.');
      }
    } catch (e) {
      print('Error reading file: $e');
    }
  }

  void statushw() {
    Map<String, dynamic>? ctrlData = mqttPayloadProvider.messageFromHw;
    if (ctrlData != null && ctrlData.isNotEmpty) {
      status = ctrlData['Name'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    statushw();
    return Scaffold(
      appBar: AppBar(title: Text("EXE Transfer via Bluetooth")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text("Status: $status"),
          SizedBox(height: 20),
          if (isDownloading) ...[
            Center(child: CircularProgressIndicator()),
            SizedBox(height: 20),
          ] else if (isLoading) ...[
            Center(child: CircularProgressIndicator()),
            SizedBox(height: 20),
            Text('Sending firmware over Bluetooth...'),
          ],
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: selectedFile,
            decoration: InputDecoration(
              labelText: 'Select File',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            icon: Icon(Icons.arrow_drop_down),
            items: files.map((file) {
              return DropdownMenuItem<String>(
                value: file,
                child: Text(file),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedFile = value;
              });
            },
            validator: (value) => value == null ? 'Please select a file' : null,
          ),
          const SizedBox(height: 20),
          if (selectedFile != null &&
              selectedFile!.isNotEmpty &&
              selectedFile != 'Select File') ...[
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              onPressed: isDownloading ? null : _downloadToFile,
              child: const Text("Download"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              onPressed: isLoading ? null : _sendViaBle,
              child: const Text("Send via Bluetooth"),
            ),
          ],
        ]),
      ),
    );
  }
}
