class Environment {
  static const String currentEnvironment = String.fromEnvironment('ENV', defaultValue: 'oroDevelopment');
  static const String appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

  static Map<String, Map<String, dynamic>> config = {
    'oroDevelopment' : {
      'apiUrl': 'http://192.168.68.141:5000/api/v1',
      'apiKey': 'dev-api-key',
      'mqttWebUrl': 'ws://192.168.68.141',
      'publishTopic': 'AppToFirmware',
      'subscribeTopic': 'FirmwareToApp',
      'mqttMobileUrl': '192.168.68.141',
      'mqttPort': 9001,
    },
    'lkDevelopment' : {
      'apiUrl': 'http://192.168.68.141:5000/api/v1',
      'apiKey': 'dev-api-key',
      'mqttWebUrl': 'ws://192.168.68.141',
      'publishTopic': 'AppToFirmware',
      'subscribeTopic': 'FirmwareToApp',
      'mqttMobileUrl': '192.168.68.141',
      'mqttPort': 9001,
    },
    'production': {
      'apiUrl': 'http://13.235.254.21:3000/api/v1',
      'apiKey': 'prod-api-key',
      'mqttUrl': 'ws://13.235.254.21:8083/mqtt',
      'mqttPort': 8083,
    },
  };

  static String get apiUrl => config[currentEnvironment]?['apiUrl'] ?? '';
  static String get apiKey => config[currentEnvironment]?['apiKey'] ?? '';

  static String get mqttWebUrl => config[currentEnvironment]?['mqttWebUrl'] ?? '';
  static String get mqttWebPublishTopic => config[currentEnvironment]?['publishTopic'] ?? '';
  static String get mqttMobileUrl => config[currentEnvironment]?['mqttMobileUrl'] ?? '';
  static int get mqttPort => config[currentEnvironment]?['mqttPort'] ?? 0;
}