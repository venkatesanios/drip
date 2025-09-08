import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';

class PumpTopicChangePage extends StatefulWidget {
  final   deviceID;
  final   userId;
  final   communicationType;
  final   controllerId,modelId;

  const PumpTopicChangePage({
    super.key,
    required this.deviceID,
    required this.userId,
    required this.communicationType,
    required this.controllerId,
    required this.modelId,
  });

  @override
  State<PumpTopicChangePage> createState() => _PumpTopicChangePageState();
}


class _PumpTopicChangePageState extends State<PumpTopicChangePage> {
  bool isLoading = true;
  String errorMessage = '';
  late MqttPayloadProvider mqttPayloadProvider;

  String selectedTopicType = 'Old';
  Map<String, dynamic>? selectedOldTopic;
  Map<String, dynamic>? selectedNewTopic;

  List<Map<String, dynamic>> oldTopicConfigs = [];
  List<Map<String, dynamic>> newTopicConfigs = [];

  // Controllers
  final TextEditingController topicController = TextEditingController();
  final TextEditingController mqttIpController = TextEditingController();
  final TextEditingController mqttUserController = TextEditingController();
  final TextEditingController mqttPassController = TextEditingController();
  final TextEditingController ftpIpController = TextEditingController();
  final TextEditingController ftpUserController = TextEditingController();
  final TextEditingController ftpPassController = TextEditingController();
  final TextEditingController pathController = TextEditingController();

  // Field validation states
  Map<String, bool> fieldValid = {
    "Topic": true,
    "MQTT IP": true,
    "MQTT Username": true,
    "MQTT Password": true,
    "FTP IP": true,
    "FTP Username": true,
    "FTP Password": true,
    "Path": true,
  };

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: false);
    fetchData();
  }

  @override
  void dispose() {
    topicController.dispose();
    mqttIpController.dispose();
    mqttUserController.dispose();
    mqttPassController.dispose();
    ftpIpController.dispose();
    ftpUserController.dispose();
    ftpPassController.dispose();
    pathController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    final url = Uri.parse('http://13.235.254.21:9000/getConfigs');

    try {
      final response =
      await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> rawConfigs = data['data'];

        oldTopicConfigs = rawConfigs
            .where((e) => e['TOPIC_TYPE'] == 'Old')
            .cast<Map<String, dynamic>>()
            .toList();

        newTopicConfigs = rawConfigs
            .where((e) => e['TOPIC_TYPE'] == 'New')
            .cast<Map<String, dynamic>>()
            .toList();

        if (!mounted) return;
        setState(() => isLoading = false);
      } else {
        setState(() {
          errorMessage = 'Failed to load configs: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e, stacktrace) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
      print(e);
      print(stacktrace);
    }
  }

  void populateFields(Map<String, dynamic>? config) {
    if (config == null) return;

    topicController.text = config['TOPIC'] ?? '';
    mqttIpController.text = config['MQTT_IP'] ?? '';
    mqttUserController.text = config['MQTT_USER_NAME'] ?? '';
    mqttPassController.text = config['MQTT_PASSWORD'] ?? '';
    ftpIpController.text = config['FTP_IP'] ?? '';
    ftpUserController.text = config['FTP_USER_NAME'] ?? '';
    ftpPassController.text = config['FTP_PASSWORD'] ?? '';
    pathController.text = config['PATH'] ?? '';

    // Reset button colors
    fieldValid.updateAll((key, value) => true);
  }

  void sendField(String fieldName, TextEditingController controller) {
    setState(() {
      fieldValid[fieldName] = controller.text.isNotEmpty;
    });

    if (!fieldValid[fieldName]!) return;

    // Replace below print with actual MQTT/BLE/HTTP send
    print("Send $fieldName: ${controller.text}");
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("$fieldName Sent")));
  }

  Widget buildTextFieldWithButton(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                  fieldValid[label]! ? Colors.blue : Colors.red,
                  foregroundColor: Colors.white),
              onPressed: () => sendField(label, controller),
              child: const Text("Send"),
            ),
          ),
        ],
      ),
    );
  }

  void sendAllFields() {
    final fields = {
      "Topic": topicController.text,
      "MQTT IP": mqttIpController.text,
      "MQTT Username": mqttUserController.text,
      "MQTT Password": mqttPassController.text,
      "FTP IP": ftpIpController.text,
      "FTP Username": ftpUserController.text,
      "FTP Password": ftpPassController.text,
      "Path": pathController.text,
    };

    bool allValid = true;
    fields.forEach((key, value) {
      if (value.isEmpty) allValid = false;
    });

    if (!allValid) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Some fields are empty")));
      return;
    }

    // Replace with actual send logic
    print("Send All Fields: $fields");
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("All Fields Sent")));
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);

    final topicConfigs =
    selectedTopicType == 'Old' ? oldTopicConfigs : newTopicConfigs;
    final selectedTopic =
    selectedTopicType == 'Old' ? selectedOldTopic : selectedNewTopic;

    int? modelId = selectedTopic?['modelId'];

    return Scaffold(
      appBar: AppBar(title: const Text("Pump Topic Change")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: selectedTopicType,
                  decoration: const InputDecoration(
                    labelText: "Select Topic Type",
                    border: OutlineInputBorder(),
                  ),
                  items: ['Old', 'New']
                      .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTopicType = value!;
                      populateFields(selectedTopicType == 'Old'
                          ? selectedOldTopic
                          : selectedNewTopic);
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Dropdown for selecting topic config
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: selectedTopic,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Select Topic Config",
                    border: OutlineInputBorder(),
                  ),
                  items: topicConfigs.map((config) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: config,
                      child: Text(
                          "${config['PROJECT_NAME']} - ${config['SERVER_NAME']}"),
                    );
                  }).toList(),
                  onChanged: (config) {
                    setState(() {
                      if (selectedTopicType == 'Old') {
                        selectedOldTopic = config;
                      } else {
                        selectedNewTopic = config;
                      }
                      populateFields(config);
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Fields + Buttons logic
                if (modelId == 7 || modelId == 10) ...[
                  TextField(
                    controller: topicController,
                    decoration: const InputDecoration(
                        labelText: "Topic",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: mqttIpController,
                    decoration: const InputDecoration(
                        labelText: "MQTT IP",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: mqttUserController,
                    decoration: const InputDecoration(
                        labelText: "MQTT Username",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: mqttPassController,
                    decoration: const InputDecoration(
                        labelText: "MQTT Password",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ftpIpController,
                    decoration: const InputDecoration(
                        labelText: "FTP IP",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ftpUserController,
                    decoration: const InputDecoration(
                        labelText: "FTP Username",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ftpPassController,
                    decoration: const InputDecoration(
                        labelText: "FTP Password",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pathController,
                    decoration: const InputDecoration(
                        labelText: "Path",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: sendAllFields,
                    child: const Text("Send All"),
                  ),
                ] else ...[
                  buildTextFieldWithButton("Topic", topicController),
                  buildTextFieldWithButton(
                      "MQTT IP", mqttIpController),
                  buildTextFieldWithButton(
                      "MQTT Username", mqttUserController),
                  buildTextFieldWithButton(
                      "MQTT Password", mqttPassController),
                  buildTextFieldWithButton("FTP IP", ftpIpController),
                  buildTextFieldWithButton(
                      "FTP Username", ftpUserController),
                  buildTextFieldWithButton(
                      "FTP Password", ftpPassController),
                  buildTextFieldWithButton("Path", pathController),
                ],

                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white),
                  onPressed: () {
                    print("View Settings for $selectedTopicType");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("View Request Sent")),
                    );
                  },
                  child: const Text("View Settings"),
                ),
                const SizedBox(height: 10),
                Text(mqttPayloadProvider.receivedPayload),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

