import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import '../../modules/IrrigationProgram/view/program_library.dart';
import '../../services/mqtt_service.dart';
import '../../utils/environment.dart';
import '../../utils/snack_bar.dart';

class ConfigureMqtt extends StatefulWidget {
  final String deviceID;

  const ConfigureMqtt({Key? key, required this.deviceID}) : super(key: key);

  @override
  _ConfigureMqttState createState() => _ConfigureMqttState();
}

class _ConfigureMqttState extends State<ConfigureMqtt> {
  final _formKey = GlobalKey<FormState>();
  late MqttPayloadProvider mqttPayloadProvider;
  final MqttService manager = MqttService();

  final Map<String, String> formData = {};
  final Map<String, TextEditingController> _controllers = {};

  final List<Map<String, String>> mqttConfigOptions = [
    {
      'name': 'oro old',
      'MqttBroker': '13.235.254.21',
      'MqttUserName': '-',
      'MqttPasword': '-',
      'HttpUrl_Hardware': 'http://13.235.254.21:3000',
      'FtpBroker': '54.179.114.89',
      'FtpUserName': 'niagara',
      'FtpPasword': 'niagara@123',
      'FirmwareToAppTopic': 'FirmwareToApp/',
      'AppToFirmwareTopic': 'AppToFirmware/',
      'ServerTopic': 'FirmwareToApp',
    },
    {
      'name': 'oro AWS',
      'MqttBroker': '13.235.254.21',
      'MqttUserName': '-',
      'MqttPasword': '-',
      'HttpUrl_Hardware': 'http://13.235.254.21:3000',
      'FtpBroker': '54.179.114.89',
      'FtpUserName': 'niagara',
      'FtpPasword': 'niagara@123',
      'FirmwareToAppTopic': 'FirmwareToApps/',
      'AppToFirmwareTopic': 'AppsToFirmware/',
      'ServerTopic': 'FirmwareToApps',
    },
    {
      'name': 'new oro aws',
      'MqttBroker': '13.235.254.21',
      'MqttUserName': '-',
      'MqttPasword': '-',
      'HttpUrl_Hardware': 'http://13.235.254.21:5000',
      'FtpBroker': '54.179.114.89',
      'FtpUserName': 'niagara',
      'FtpPasword': 'niagara@123',
      'SFtpBroker': '54.179.114.89',
      'SFtpUserName': 'ubuntu',
      'SFtpPasword': 'niagara@123',
      'SFtpPort': '22',
      'MqttsOnOff': '1',
      'ReverseSshNameBroker': 'ec2-user@13.235.254.21',
      'ReverseSshPort': '2222:localhost:22',
      'FirmwareToAppTopic': 'FirmwareToOroApp/',
      'AppToFirmwareTopic': 'OroAppToFirmware/',
      'ServerTopic': 'FirmwareToOroApp',
      'SFtpBroker':'54.179.114.89',
      'SFtpUserName':'ubuntu',
      'SFtpPasword':'niagara@123',
      'SFtpPort':'22',
      'MqttsPort':'8883',
      'MqttsOnOff':'1',
      'ReverseSshNameBroker':'ec2-user@13.235.254.21',
      'ReverseSshPort':'2222:localhost:22',
    },
    {
      'name': 'new oro azure',
      'MqttBroker': '52.172.214.208',
      'MqttUserName': 'imsmqtt',
      'MqttPasword': '2L9((WonMr',
      'HttpUrl_Hardware': 'http://52.172.214.208:8000',
      'FtpBroker': '54.179.114.89',
      'FtpUserName': 'niagara',
      'FtpPasword': 'niagara@123',
      'SFtpBroker': '54.179.114.89',
      'SFtpUserName': 'ubuntu',
      'SFtpPasword': 'niagara@123',
      'SFtpPort': '22',
      'MqttsOnOff': '1',
      'ReverseSshNameBroker': 'ec2-user@13.235.254.21',
      'ReverseSshPort': '2222:localhost:22',
      'FirmwareToAppTopic': 'FirmwareToApp/',
      'AppToFirmwareTopic': 'AppToFirmware/',
      'ServerTopic': 'FirmwareToApp',
      'SFtpBroker':'54.179.114.89',
      'SFtpUserName':'ubuntu',
      'SFtpPasword':'niagara@123',
      'SFtpPort':'22',
      'MqttsPort':'8883',
      'MqttsOnOff':'1',
      'ReverseSshNameBroker':'ec2-user@13.235.254.21',
      'ReverseSshPort':'2222:localhost:22',
    },
    {
      'name': 'new LK azure',
      'MqttBroker': '52.172.214.208',
      'MqttUserName': 'imsmqtt',
      'MqttPasword': '2L9((WonMr',
      'HttpUrl_Hardware': 'http://52.172.214.208:5000',
      'FtpBroker': '54.179.114.89',
      'FtpUserName': 'niagara',
      'FtpPasword': 'niagara@123',
      'SFtpBroker': '54.179.114.89',
      'SFtpUserName': 'ubuntu',
      'SFtpPasword': 'niagara@123',
      'SFtpPort': '22',
      'MqttsOnOff': '1',
      'ReverseSshNameBroker': 'ec2-user@13.235.254.21',
      'ReverseSshPort': '2222:localhost:22',
      'FirmwareToAppTopic': 'FirmwareToApp/',
      'AppToFirmwareTopic': 'AppToFirmware/',
      'ServerTopic': 'FirmwareToApp',
      'SFtpBroker':'54.179.114.89',
      'SFtpUserName':'ubuntu',
      'SFtpPasword':'niagara@123',
      'SFtpPort':'22',
      'MqttsPort':'8883',
      'MqttsOnOff':'1',
      'ReverseSshNameBroker':'ec2-user@13.235.254.21',
      'ReverseSshPort':'2222:localhost:22',
    },
  ];

  String? selectedConfig = 'oro old';

  final List<String> formKeys = [
    'MqttBroker',
    'MqttUserName',
    'MqttPasword',
    'MqttPort',
    'MqttsPort',
    'HttpUrl_Hardware',
    'StaticIp',
    'SubnetMask',
    'DefaultGateway',
    'DNSServer',
    'FtpBroker',
    'FtpUserName',
    'FtpPasword',
    'FtpPort',
    'FirmwareToAppTopic',
    'AppToFirmwareTopic',
    'ServerTopic',
    'SFtpBroker',
    'SFtpUserName',
    'SFtpPasword',
    'SFtpPort',
    'MqttsOnOff',
    'ReverseSshNameBroker',
    'ReverseSshPort',
  ];

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    // Initialize formData and controllers
    for (var key in formKeys) {
      _controllers[key] = TextEditingController();
      formData[key] = '';
    }
    _updateMqttFields(selectedConfig);
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _updateMqttFields(String? configName) {
    if (configName == null) return;
    final config = mqttConfigOptions.firstWhere((c) => c['name'] == configName);

    setState(() {
      for (var key in config.keys) {
        if (_controllers.containsKey(key)) {
          _controllers[key]!.text = config[key] ?? '';
          formData[key] = config[key] ?? '';
        }
      }
      selectedConfig = configName;
    });
  }

  Future<void> _sendMqttData(String data) async {
    Map<String, dynamic> payLoadFinal = {
      '6100': {'6101': data},
    };

    if (manager.isConnected) {
      await validatePayloadSent(
        dialogContext: context,
        context: context,
        mqttPayloadProvider: mqttPayloadProvider,
        acknowledgedFunction: () {
          manager.topicToSubscribe('${Environment.mqttLogTopic}/${widget.deviceID}');
        },
        payload: payLoadFinal,
        payloadCode: '6100',
        deviceId: widget.deviceID,
      );
    } else {
      GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
    }
  }

  Future<void> _submitForm() async {
    for (var key in _controllers.keys) {
      formData[key] = _controllers[key]!.text.trim();
    }

    if (!_formKey.currentState!.validate()) {
      GlobalSnackBar.show(context, 'Please fill all required fields', 201);
      return;
    }

    if (formData.values.any((v) => v.isEmpty)) {
      GlobalSnackBar.show(context, 'All fields must be filled', 201);
      return;
    }

    for (String portKey in ['MqttPort', 'MqttsPort', 'FtpPort', 'SFtpPort']) {
      try {
        final port = int.parse(formData[portKey]!);
        if (port < 1 || port > 65535) {
          GlobalSnackBar.show(context, '$portKey must be 1–65535', 201);
          return;
        }
      } catch (e) {
        GlobalSnackBar.show(context, 'Invalid $portKey format', 201);
        return;
      }
    }

    final mqttData = formData.values.join(',') + ';';
    await _sendMqttData(mqttData);
  }

  Widget _buildTextField(String label, String key, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) =>
        value == null || value.trim().isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        shadowColor: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(title: const Text('MQTT Configuration Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: SizedBox(
              width: kIsWeb ? 600 : null,
              child: ListView(
                children: [
                  _buildCard('MQTT Configuration Selection', [
                    DropdownButtonFormField<String>(
                      value: selectedConfig,
                      decoration: const InputDecoration(
                        labelText: 'Select MQTT Configuration',
                        border: OutlineInputBorder(),
                      ),
                      items: mqttConfigOptions.map((config) {
                        return DropdownMenuItem<String>(
                          value: config['name'],
                          child: Text(config['name']!),
                        );
                      }).toList(),
                      onChanged: (value) => _updateMqttFields(value),
                    ),
                  ]),
                  _buildCard('MQTT Settings', [
                    _buildTextField('Broker', 'MqttBroker'),
                    _buildTextField('Username', 'MqttUserName'),
                    _buildTextField('Password', 'MqttPasword'),
                    _buildTextField('Port', 'MqttPort', isNumber: true),
                    _buildTextField('TLS Port', 'MqttsPort', isNumber: true),
                  ]),
                  _buildCard('Network Settings', [
                    _buildTextField('HTTP URL Hardware', 'HttpUrl_Hardware'),
                  ]),
                  _buildCard('FTP Settings', [
                    _buildTextField('Broker', 'FtpBroker'),
                    _buildTextField('Username', 'FtpUserName'),
                    _buildTextField('Password', 'FtpPasword'),
                    _buildTextField('Port', 'FtpPort', isNumber: true),
                  ]),

                  _buildCard('MQTT Topics', [
                    _buildTextField('Firmware to App Topic', 'FirmwareToAppTopic'),
                    _buildTextField('App to Firmware Topic', 'AppToFirmwareTopic'),
                    _buildTextField('Server Topic', 'ServerTopic'),
                  ]),
                  _buildCard('SFTP Settings', [
                    _buildTextField('Broker', 'SFtpBroker'),
                    _buildTextField('Username', 'SFtpUserName'),
                    _buildTextField('Password', 'SFtpPasword'),
                    _buildTextField('Port', 'SFtpPort', isNumber: true),
                  ]),
                  _buildCard('MQTT Advanced Settings', [
                    _buildTextField('MqttsOnOff', 'MqttsOnOff'),
                    _buildTextField('ReverseSshNameBroker', 'ReverseSshNameBroker'),
                    _buildTextField('ReverseSshPort', 'ReverseSshPort'),
                    _buildTextField('MqttsPort', 'MqttsPort', isNumber: true),
                  ]),




                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text('Send Data'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
