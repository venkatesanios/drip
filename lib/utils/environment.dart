import '../flavors.dart';

class Environment {
  static const String currentEnvironment = String.fromEnvironment('ENV', defaultValue: 'oroDevelopment');
  static const String appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');
  static Map<String, Map<String, dynamic>> config = {
    'oroDevelopment' : {
      'apiUrl': 'http://192.168.68.141:5000/api/v1',
      'apiKey': 'dev-api-key',
      'mqttWebUrl': 'ws://192.168.68.141',
      'mqttMobileUrl': '192.168.68.141',
      'publishTopic': 'AppToFirmware',
      'subscribeTopic': 'FirmwareToApp',
      'mqttWebPort': 9001,
      'mqttMobilePort': 1883,
      "mqttUserName" : '',
      "mqttPassword" : '',
    },
    'smartComm' : {
      'apiUrl': 'http://52.172.214.208:5000/api/v1',
      'apiKey': 'prod-api-key',
      'mqttWebUrl': 'ws://52.172.214.208:9001/mqtt',
      'mqttMobileUrl': '52.172.214.208',
      'publishTopic': 'AppToFirmware',
      'subscribeTopic': 'FirmwareToApp',
      'mqttWebPort': 9001,
      'mqttMobilePort': 1883,
      'sftpIpAddress': '54.179.114.89',
      'sftpPort': 22,
      'privateKeyPath': 'assets/ssh/smartComm/id_rsa',
      "mqttUserName" : 'imsmqtt',
      "mqttPassword" : '2L9((WonMr',
    },
    'oroProduction': {
      'apiUrl': 'http://13.235.254.21:5000/api/v1',
      'apiKey': 'dev-api-key',
      'mqttWebUrl': 'ws://13.235.254.21/mqtt',
      'mqttMobileUrl': '13.235.254.21',
      'publishTopic': 'OroAppToFirmware',
      'subscribeTopic': 'FirmwareToOroApp',
      'mqttWebPort': 8083,
      'mqttMobilePort': 1883,
      "mqttUserName" : 'niagara',
      "mqttPassword" : 'niagara123',
      'sftpIpAddress': '54.179.114.89',
      'sftpPort': 22,
      'privateKeyPath': 'assets/ssh/smartComm/id_rsa',
    },
  };

  static String get apiUrl => config[F.name]?['apiUrl'] ?? '';
  static String get apiKey => config[currentEnvironment]?['apiKey'] ?? '';

  static String get mqttWebUrl => config[F.name]?['mqttWebUrl'] ?? '';
  static String get mqttMobileUrl => config[F.name]?['mqttMobileUrl'] ?? '';

  static int get mqttWebPort => config[F.name]?['mqttWebPort'] ?? 0;
  static int get mqttMobilePort => config[F.name]?['mqttMobilePort'] ?? 0;
  static String get mqttUserName => config[F.name]?['mqttUserName'] ?? '';
  static String get mqttPassword => config[F.name]?['mqttPassword'] ?? '';
  static String get mqttSubscribeTopic => config[F.name]?['subscribeTopic'] ?? '';
  static String get mqttPublishTopic => config[F.name]?['publishTopic'] ?? '';

  static String get mqttLogTopic => 'OroGemLog';

  static String get sftpIpAddress => config[F.name]?['sftpIpAddress'] ?? '';
  static int get sftpPort => config[F.name]?['sftpPort'] ?? 0;
  static String get privateKeyPath => config[F.name]?['privateKeyPath'] ?? '';
}

var command = "#live";