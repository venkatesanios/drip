import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../flavors.dart';
import '../../repository/repository.dart';
import '../../services/communication_service.dart';
import '../../services/http_service.dart';
import '../../services/mqtt_service.dart';
import '../../utils/constants.dart';

class ConfigureMqtt extends StatefulWidget {
  final deviceID, userId, controllerId,communicationType;

  const ConfigureMqtt(
      {Key? key,
        required this.deviceID,
        required this.userId,
        required this.communicationType,
        required this.controllerId})
      : super(key: key);

  @override
  _ConfigureMqttState createState() => _ConfigureMqttState();
}

class _ConfigureMqttState extends State<ConfigureMqtt> {
  late MqttPayloadProvider mqttPayloadProvider;
  List<Map<String, dynamic>> configs = [];
  int? selectedIndex;
  bool isLoading = true;
  String errorMessage = '';
  String? formattedConfig;

  // New fields
  String macAddress = '';
  String? selectedPlatform;
  String? selectedVersion;
  String? selectedDealer;

  final List<String> platforms = ['AWS', 'Azure'];
  final List<String> dealers = ['ORO', 'LK'];
  final List<String> versions = ['Version 1.0', 'Version 1.1'];
  TextEditingController _macController = TextEditingController();
  final Repository repository = Repository(HttpService());
  @override
  void initState() {
    super.initState();
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: false);
    fetchData();
    _macController.text = widget.deviceID;
    macAddress = widget.deviceID;
  }

  Future<void> fetchData() async {
    print('fetchData ');
    final url = Uri.parse('http://13.235.254.21:9000/getConfigs');

    try {
      final response =
      await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rawConfigs = data['data'];
        configs = rawConfigs.cast<Map<String, dynamic>>();

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load configs: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e, stacktrace) {
      setState(() {
        print(e);
        print(stacktrace);
        errorMessage = 'Error fetching data: $e,';
        isLoading = false;
      });
    }
  }

  String formatConfig(Map<String, dynamic> config) {
    if (selectedVersion == 'Version 1.0') {
      return '${config['MQTT_IP'] ?? '-'},'
          '${config['MQTT_USER_NAME'] ?? '-'},'
          '${config['MQTT_PASSWORD'] ?? '-'},'
          '${config['MQTT_PORT'] ?? '-'},'
          '${config['HTTP_URL'] ?? '-'},'
          '${config['STATIC_IP'] ?? '-'},'
          '${config['SUBNET_MASK'] ?? '-'},'
          '${config['DEFAULT_GATEWAY'] ?? '-'},'
          '${config['DNS_SERVER'] ?? '-'},'
          '${config['FTP_IP'] ?? '-'},'
          '${config['FTP_USER_NAME'] ?? '-'},'
          '${config['FTP_PASSWORD'] ?? '-'},'
          '${config['FTP_PORT'] ?? '-'},'
          '${config['MQTT_FRONTEND_TOPIC'] ?? '-'},'
          '${config['MQTT_HARDWARE_TOPIC'] ?? '-'},'
          '${config['MQTT_SERVER_TOPIC'] ?? '-'}';
    } else {
      return '${config['MQTT_IP'] ?? '-'},'
          '${config['MQTT_USER_NAME'] ?? '-'},'
          '${config['MQTT_PASSWORD'] ?? '-'},'
          '${config['MQTT_PORT'] ?? '-'},'
          '${config['HTTP_URL'] ?? '-'},'
          '${config['STATIC_IP'] ?? '-'},'
          '${config['SUBNET_MASK'] ?? '-'},'
          '${config['DEFAULT_GATEWAY'] ?? '-'},'
          '${config['DNS_SERVER'] ?? '-'},'
          '${config['FTP_IP'] ?? '-'},'
          '${config['FTP_USER_NAME'] ?? '-'},'
          '${config['FTP_PASSWORD'] ?? '-'},'
          '${config['FTP_PORT'] ?? '-'},'
          '${config['MQTT_FRONTEND_TOPIC'] ?? '-'},'
          '${config['MQTT_HARDWARE_TOPIC'] ?? '-'},'
          '${config['MQTT_SERVER_TOPIC'] ?? '-'},'
          '${config['SFTP_IP'] ?? '-'},'
          '${config['SFTP_USER_NAME'] ?? '-'},'
          '${config['SFTP_PASSWORD'] ?? '-'},'
          '${config['SFTP_PORT'] ?? '-'},'
          '${config['MQTTS_PORT'] ?? '-'},'
          '${config['MQTTS_STATUS'] ?? '-'},'
          '${config['REVERSE_SSH_BROKER_NAME'] ?? '-'},'
          '${config['REVERSE_SSH_PORT'] ?? '-'}';
    }
  }

  Future<void> sendSelectedProject() async {
    if (selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a project")),
      );
      return;
    }
    final selectedConfig = configs[selectedIndex!];
    final formatted = formatConfig(selectedConfig);
    if(widget.communicationType == "MQTT") {
      List checkTopic =
      getMqttTopic(selectedPlatform!, selectedVersion!, selectedDealer!);
      print('checkTopic---->$checkTopic,$macAddress');
      String topic = checkTopic[0];
      String oldnewcheck = checkTopic[1];
      if (oldnewcheck == '1') {
        final payload = {
          "6100": [
            {"6101": formatted},
          ]
        };
        MqttService().topicToPublishAndItsMessage(
          jsonEncode(payload),
          "$topic${_macController.text}",
        );
        print('payload $payload  \n $topic${_macController.text}');
      } else {
        final payload = {
          "6100": {"6101": formatted}
        };
        MqttService().topicToPublishAndItsMessage(
          jsonEncode(payload),
          "$topic${_macController.text}",
        );
        print('payload $payload  \n $topic${_macController.text}');
      }
    }
    else
    {
      //bluetooth
      try {
        String payLoadFinal = jsonEncode({
          "6100": {"6101": formatted}
        });
        final result = await context.read<CommunicationService>().sendCommand(payload: payLoadFinal,
            serverMsg: '');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Settings sent Ble")),
        );
        if (result['http'] == true) {
          debugPrint("Payload sent to Server");
        }
        if (result['mqtt'] == true) {
          debugPrint("Payload sent to MQTT Box");
        }
        if (result['bluetooth'] == true) {
          debugPrint("Payload sent via Bluetooth");
        }

      } finally {
        setState(() => isLoading = false);
      }
    }
    var data = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "data": {
        "6100": [
          {"6101": formatted},
        ]
      },
      "messageStatus": "View Settings",
      "createUser": widget.userId,
      "hardware": {
        "6100": [
          {"6101": formatted},
        ]
      },
    };
    await repository.sendManualOperationToServer(data);
  }

  List<String> getMqttTopic(
      String selectedPlatform, String selectedVersion, String selecteddealer) {
    if (selecteddealer == 'ORO') {
      if (selectedPlatform == 'AWS') {
        print('return ORO AWS');
        if (selectedVersion == 'Version 1.0')
          return ['AppToFirmware/', '1'];
        else
          return ['OroAppToFirmware/', '0'];
      }
    } else {
      if (selectedPlatform == 'AWS') {
        print('return LK AWS');
        if (selectedVersion == 'Version 1.0') return ['AppsToFirmware/', '1'];
      } else {
        print('return LK azure');
        if (selectedVersion == 'Version 1.0')
          return ['AppsToFirmware/', '1'];
        else
          return ['AppToFirmware/', '0'];
      }
    }
    print('return else');
    return ['AppToFirmware/', '0'];
  }

  Future<void> viewsettings() async {
    if(widget.communicationType == "MQTT")
      {
    List checkTopic =
    getMqttTopic(selectedPlatform!, selectedVersion!, selectedDealer!);
    String topic = checkTopic[0];
    String oldnewcheck = checkTopic[1];
    if (oldnewcheck == '1') {
      final payload = {
        "5700": [
          {"5701": "22"},
        ]
      };
      MqttService().topicToPublishAndItsMessage(
        jsonEncode(payload),
        "$topic${_macController.text}",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("view settings sent")),
      );
    } else {
      final payload = {
        "5700": {"5701": "22"}
      };
      MqttService().topicToPublishAndItsMessage(
        jsonEncode(payload),
        "$topic${_macController.text}",
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("view settings sent")),
      );
    }
    }
    else   {
      //bluetooth
      try {
        String payLoadFinal = jsonEncode({
          "5700": {"5701": "22"}
        });
        final result = await context.read<CommunicationService>().sendCommand(payload: payLoadFinal,
            serverMsg: '');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("view settings sent Ble")),
        );
        if (result['http'] == true) {
          debugPrint("Payload sent to Server");
        }
        if (result['mqtt'] == true) {
          debugPrint("Payload sent to MQTT Box");
        }
        if (result['bluetooth'] == true) {
          debugPrint("Payload sent via Bluetooth");
        }

      } finally {
        setState(() => isLoading = false);
      }
    }
    var data = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "data": {
        "5700": [
          {"5701": "22"},
        ]
      },
      "messageStatus": "View Settings",
      "createUser": widget.userId,
      "hardware": {
        "5700": [
          {"5701": "22"},
        ]
      },
    };
    await repository.sendManualOperationToServer(data);
  }

  Future<void> updateCode() async {
    if(widget.communicationType == "MQTT") {
      List checkTopic =
      getMqttTopic(selectedPlatform!, selectedVersion!, selectedDealer!);
      String topic = checkTopic[0];
      String oldnewcheck = checkTopic[1];
      if (oldnewcheck == '1') {
        final payload = {
          "5700": [
            {"5701": "27"},
          ]
        };
        MqttService().topicToPublishAndItsMessage(
          jsonEncode(payload),
          "$topic${_macController.text}",
        );
        var data = {
          "userId": widget.userId,
          "controllerId": widget.controllerId,
          "data": {
            "5700": [
              {"5701": "27"},
            ]
          },
          "messageStatus": "updateCode",
          "createUser": widget.userId,
          "hardware": {
            "5700": [
              {"5701": "27"},
            ]
          },
        };
        await repository.sendManualOperationToServer(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("update settings sent")),
        );
        print('payload $payload  \n $topic${_macController.text}');
      } else {
        final payload = {
          "5700": {"5701": "28"}
        };
        MqttService().topicToPublishAndItsMessage(
          jsonEncode(payload),
          "$topic${_macController.text}",
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("update settings sent")),
        );
        print('payload $payload  \n $topic${_macController.text}');
      }
    } else   {
      //bluetooth
      try {
        String payLoadFinal = jsonEncode({
          "5700": {"5701": "28"}
        });
        final result = await context.read<CommunicationService>().sendCommand(payload: payLoadFinal,
            serverMsg: '');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("update settings sent Ble")),
        );
        if (result['http'] == true) {
          debugPrint("Payload sent to Server");
        }
        if (result['mqtt'] == true) {
          debugPrint("Payload sent to MQTT Box");
        }
        if (result['bluetooth'] == true) {
          debugPrint("Payload sent via Bluetooth");
        }

      } finally {
        setState(() => isLoading = false);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text('Configure Hardware'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MAC Address
              TextField(
                decoration: const InputDecoration(
                  labelText: 'MAC Address',
                  border: OutlineInputBorder(),
                ),
                controller: _macController,
                onChanged: (value) {
                  macAddress = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDealer,
                decoration: const InputDecoration(
                  labelText: 'Select Current Dealer',
                  border: OutlineInputBorder(),
                ),
                items: dealers.map((dealers) {
                  return DropdownMenuItem<String>(
                    value: dealers,
                    child: Text(dealers),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    // value == 'ORO' ? F.appFlavor = Flavor.oroProduction : F.appFlavor = Flavor.smartComm;
                    selectedDealer = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Platform Dropdown
              DropdownButtonFormField<String>(
                value: selectedPlatform,
                decoration: const InputDecoration(
                  labelText: 'Select Current Platform',
                  border: OutlineInputBorder(),
                ),
                items: platforms.map((platform) {
                  return DropdownMenuItem<String>(
                    value: platform,
                    child: Text(platform),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    value == 'AWS'
                        ? F.appFlavor = Flavor.oroProduction
                        : F.appFlavor = Flavor.smartComm;
                    print('flaVOR ${F.appFlavor}');
                    print('flaVOR ${F.appFlavor}');
                    print('${AppConstants.mqttUrl}');
                    selectedPlatform = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Version Dropdown
              DropdownButtonFormField<String>(
                value: selectedVersion,
                decoration: const InputDecoration(
                  labelText: 'Select Current Version',
                  border: OutlineInputBorder(),
                ),
                items: versions.map((version) {
                  return DropdownMenuItem<String>(
                    value: version,
                    child: Text(version),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVersion = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Project Config Selection
              DropdownButton<int>(
                value: selectedIndex,
                isExpanded: true,
                hint: const Text('Select Update Project'),
                items: List.generate(configs.length, (index) {
                  final config = configs[index];
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(
                        '${config['PROJECT_NAME']} - ${config['SERVER_NAME']}'),
                  );
                }),
                onChanged: (index) {
                  setState(() {
                    selectedIndex = index;
                    formattedConfig = index != null
                        ? formatConfig(configs[index])
                        : null;
                  });
                },
              ),
              const SizedBox(height: 20),

              if (formattedConfig != null)
                widget.communicationType == "MQTT" ? Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      formattedConfig!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ):Container(),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: sendSelectedProject,
                    child: const Text('Settings Update'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: updateCode,
                    child: const Text('Update HW Code'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: viewsettings,
                    child: const Text('View Settings'),
                  ),
                ],
              ),
             widget.communicationType == "MQTT" ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(mqttPayloadProvider.receivedPayload),
              ) : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
