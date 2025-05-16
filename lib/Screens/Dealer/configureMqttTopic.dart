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

  final Map<String, String> formData = {
    'MqttBroker': '13.235.254.21',
    'MqttUserName': '-',
    'MqttPasword': '-',
    'MqttPort': '1883',
    'HttpUrl_Hardware': 'http://13.235.254.21:3000/api/v1/hardware',
    'StaticIp': '-',
    'SubnetMask': '0',
    'DefaultGateway': '0',
    'DNSServer': '0',
    'FtpBroker': '54.179.114.89',
    'FtpUserName': 'niagara',
    'FtpPasword': 'niagara@123',
    'FtpPort': '1883',
    'FirmwareToAppTopic': 'FirmwareToApp/',
    'AppToFirmwareTopic': 'AppToFirmware/',
    'ServerTopic': 'FirmwareToApp',
  };

  final Map<String, TextEditingController> _controllers = {
    'MqttBroker': TextEditingController(),
    'MqttUserName': TextEditingController(),
    'MqttPasword': TextEditingController(),
    'MqttPort': TextEditingController(),
    'HttpUrl_Hardware': TextEditingController(),
    'StaticIp': TextEditingController(),
    'SubnetMask': TextEditingController(),
    'DefaultGateway': TextEditingController(),
    'DNSServer': TextEditingController(),
    'FtpBroker': TextEditingController(),
    'FtpUserName': TextEditingController(),
    'FtpPasword': TextEditingController(),
    'FtpPort': TextEditingController(),
    'FirmwareToAppTopic': TextEditingController(),
    'AppToFirmwareTopic': TextEditingController(),
    'ServerTopic': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    // Initialize controllers with form data
    _controllers.forEach((key, controller) {
      controller.text = formData[key] ?? '';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('mqttPayloadProvider state: ${mqttPayloadProvider.toString()}');
    });
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _sendMqttData(String data) async {
    print('Sending data to MQTT: $data');
    print('MQTT connection status: ${manager.isConnected}');
    Map<String, dynamic> payLoadFinal = {
      '6100': {'6101': data},
    };

    if (manager.isConnected) {
      await validatePayloadSent(
        dialogContext: context,
        context: context,
        mqttPayloadProvider: mqttPayloadProvider,
        acknowledgedFunction: () {},
        payload: payLoadFinal,
        payloadCode: '5700',
        deviceId: widget.deviceID,
      );
    } else {
      GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
    }
  }

  Future<void> _submitForm() async {
    _controllers.forEach((key, controller) {
      formData[key] = controller.text.trim();
      print('Captured $key: ${formData[key]}');
    });

    if (_controllers['MqttBroker']!.text.trim().isEmpty ||
        _controllers['MqttUserName']!.text.trim().isEmpty ||
        _controllers['MqttPasword']!.text.trim().isEmpty ||
        _controllers['MqttPort']!.text.trim().isEmpty) {
      print('MQTT settings validation failed');
      GlobalSnackBar.show(context, 'MQTT settings are required', 201);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      GlobalSnackBar.show(context, 'Please fill all required fields', 201);
      return;
    }

    if (formData.values.any((value) => value.isEmpty)) {
      print('Form has empty fields: $formData');
      GlobalSnackBar.show(context, 'All fields must be filled', 201);
      return;
    }

    String mqttData = formData.values.join(',') + ';';
    print('Built mqttData: $mqttData');
    await _sendMqttData(mqttData);
  }

  Widget _buildTextField(String label, String key,
      {bool isNumber = false, bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: _controllers[key], // ✅ only controller used
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        obscureText: obscure,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            print('Validation failed for $key: Empty');
            return 'Please enter $label';
          }
          return null;
        },
        onChanged: (value) {
          print('TextField $key input: $value');
        },
        onTap: () {
          print('TextField $key focused');
        },
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 5,
        shadowColor: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
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
                  _buildCard('MQTT Settings', [
                    _buildTextField('Broker', 'MqttBroker'),
                    _buildTextField('Username', 'MqttUserName'),
                    _buildTextField('Password', 'MqttPasword', obscure: true),
                    _buildTextField('Port', 'MqttPort', isNumber: true),
                  ]),
                  _buildCard('Network Settings', [
                    _buildTextField('HTTP URL Hardware', 'HttpUrl_Hardware'),
                    _buildTextField('Static IP', 'StaticIp'),
                    _buildTextField('Subnet Mask', 'SubnetMask'),
                    _buildTextField('Default Gateway', 'DefaultGateway'),
                    _buildTextField('DNS Server', 'DNSServer'),
                  ]),
                  _buildCard('FTP Settings', [
                    _buildTextField('Broker', 'FtpBroker'),
                    _buildTextField('Username', 'FtpUserName'),
                    _buildTextField('Password', 'FtpPasword', obscure: true),
                    _buildTextField('Port', 'FtpPort', isNumber: true),
                  ]),
                  _buildCard('MQTT Topics', [
                    _buildTextField('Firmware to App Topic', 'FirmwareToAppTopic'),
                    _buildTextField('App to Firmware Topic', 'AppToFirmwareTopic'),
                    _buildTextField('Server Topic', 'ServerTopic'),
                  ]),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Send Data'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
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
