import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import '../../services/mqtt_service.dart';
import '../../utils/environment.dart';

class ConfigureMqtt extends StatefulWidget {
  final String deviceID;

  const ConfigureMqtt({Key? key, required this.deviceID}) : super(key: key);

  @override
  _ConfigureMqttState createState() => _ConfigureMqttState();
}

class _ConfigureMqttState extends State<ConfigureMqtt> {
  final Map<String, TextEditingController> _controllers = {};
  Map<String, dynamic> dynamicData = {};
  late MqttPayloadProvider mqttPayloadProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _publishInitialUpdate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);

      if (mqttPayloadProvider.mqttUpdateSettings.isNotEmpty) {
        _initializeControllers(mqttPayloadProvider.mqttUpdateSettings);
      }

      _isInitialized = true;
    }
  }

  void _initializeControllers(Map<String, dynamic> settings) {
    dynamicData = Map<String, dynamic>.from(settings);
    dynamicData.forEach((key, value) {
      _controllers[key] = TextEditingController(text: value?.toString() ?? '-');
    });
  }
  void Updatecode() {
    final payload = {
      "5700": {"5701": "28"},
    };

    MqttService().topicToPublishAndItsMessage(
      jsonEncode(payload),
      "${Environment.mqttPublishTopic}/${widget.deviceID}",
    );
  }

  void _publishInitialUpdate() {
    final payload = {
      "5700": {"5701": "22"},
    };

    MqttService().topicToPublishAndItsMessage(
      jsonEncode(payload),
      "${Environment.mqttPublishTopic}/${widget.deviceID}",
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      final settings = mqttPayloadProvider.mqttUpdateSettings;
      if (settings.isNotEmpty) {
        _initializeControllers(settings);

        setState(() {
          // Update the UI after new data is loaded
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _printValues() {
    _controllers.forEach((key, controller) {
      print('$key: ${controller.text}');
    });

    final mqttData = _controllers.values.map((c) => c.text).join(',') + ';';
print('mqttData----->$mqttData');
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Configure MQTT')),
      body: _controllers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(width: 500,
            child: ListView(
              children: [
                ..._controllers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: entry.key,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                      onPressed: _printValues,
                      child: const Text('Settings Send'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.lightBlue,
                      ),
                      onPressed: Updatecode,
                      child: const Text('Update Code '),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}






