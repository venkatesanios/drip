import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oro_drip_irrigation/modules/PumpController/state_management/pump_controller_provider.dart';
import 'package:oro_drip_irrigation/services/bluetooth_manager.dart';
import 'package:oro_drip_irrigation/services/communication_service.dart';
import 'package:oro_drip_irrigation/services/mqtt_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/Constant/ConstantPageProvider/changeNotifier_constantProvider.dart';
import 'app/app.dart';
import 'StateManagement/customer_provider.dart';
import 'firebase_options.dart';
import 'modules/IrrigationProgram/state_management/irrigation_program_provider.dart';
import 'modules/Preferences/state_management/preference_provider.dart';
import 'modules/SystemDefinitions/state_management/system_definition_provider.dart';
import 'modules/config_Maker/state_management/config_maker_provider.dart';
import 'StateManagement/mqtt_payload_provider.dart';
import 'StateManagement/overall_use.dart';
import 'modules/constant/state_management/constant_provider.dart';
import 'package:http/http.dart' as http;

// Initialize local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Background message handler for Firebase
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

FutureOr<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(!kIsWeb){
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Request notification permissions
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Set up Firebase background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Start Azure Notification Hub
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }



  final mqttService = MqttService();
  final myMqtt = MqttPayloadProvider();

  runApp(CropAdvisoryApp());

  /*runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ConfigMakerProvider()),
        ChangeNotifierProvider(create: (_) => IrrigationProgramMainProvider()),
        ChangeNotifierProvider(create: (_) => myMqtt),
        ChangeNotifierProvider(create: (_) => OverAllUse()),
        ChangeNotifierProvider(create: (_) => PreferenceProvider()),
        ChangeNotifierProvider(create: (_) => SystemDefinitionProvider()),
        ChangeNotifierProvider(create: (_) => ConstantProviderMani()),
        ChangeNotifierProvider(create: (_) => ConstantProvider()),
        ChangeNotifierProvider(create: (_) => PumpControllerProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothManager()),

        Provider<CommunicationService>(
          create: (context) => CommunicationService(
            mqttService: mqttService,
            bluetoothManager: context.read<BluetoothManager>(),
            customerProvider: context.read<CustomerProvider>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );*/
}

// Main App
/*void main() {
  runApp(CropAdvisoryApp());
}*/

class CropAdvisoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Advisory System',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomeScreen(),
    );
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _cropType = 'Wheat';
  String _location = '';
  double? _latitude;
  double? _longitude;
  String _soilType = 'Loamy';
  String _recommendation = '';
  bool _isLoading = false;
  final TextEditingController _locationController = TextEditingController();

  final List<String> _crops = ['Wheat', 'Rice', 'Maize', 'Tomato'];
  final List<String> _soilTypes = ['Loamy', 'Clay', 'Sandy', 'Silt'];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  // Load saved user inputs
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cropType = prefs.getString('cropType') ?? 'Wheat';
      _location = prefs.getString('location') ?? '';
      _soilType = prefs.getString('soilType') ?? 'Loamy';
      _latitude = prefs.getDouble('latitude');
      _longitude = prefs.getDouble('longitude');
      _locationController.text = _location; // Set initial text
    });
  }

  // Save user inputs
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cropType', _cropType);
    await prefs.setString('location', _location);
    await prefs.setString('soilType', _soilType);
    if (_latitude != null) await prefs.setDouble('latitude', _latitude!);
    if (_longitude != null) await prefs.setDouble('longitude', _longitude!);
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _location = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
        _locationController.text = _location; // Update text field
        _isLoading = false;
      });
      await _saveData();
    } catch (e) {
      setState(() {
        _recommendation = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  // Fetch weather and generate recommendation
  Future<void> _getRecommendation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final weather = await WeatherService().fetchWeather(
        city: _location.isNotEmpty && (_latitude == null || _longitude == null) ? _location : null,
        lat: _latitude,
        lon: _longitude,
      );
      final recommendation = RecommendationEngine.generateRecommendation(
        cropType: _cropType,
        soilType: _soilType,
        temperature: weather['temperature'],
        rainfall: weather['rainfall'],
      );

      setState(() {
        _recommendation = recommendation;
        _isLoading = false;
      });
      await _saveData();
    } catch (e) {
      setState(() {
        _recommendation = 'Error fetching data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crop Advisory System')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _cropType,
                decoration: InputDecoration(labelText: 'Crop Type'),
                items: _crops.map((crop) => DropdownMenuItem(value: crop, child: Text(crop))).toList(),
                onChanged: (value) => setState(() => _cropType = value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location (City or Coordinates)'),
                controller: _locationController, // Use controller instead of initialValue
                onChanged: (value) {
                  setState(() {
                    _location = value;
                    // Clear coordinates if user types a city manually
                    if (!value.startsWith('Lat:')) {
                      _latitude = null;
                      _longitude = null;
                    }
                  });
                },
                validator: (value) => value!.isEmpty ? 'Enter a location or use current location' : null,
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _getCurrentLocation,
                child: Text('Use Current Location'),
              ),
              DropdownButtonFormField<String>(
                value: _soilType,
                decoration: InputDecoration(labelText: 'Soil Type'),
                items: _soilTypes.map((soil) => DropdownMenuItem(value: soil, child: Text(soil))).toList(),
                onChanged: (value) => setState(() => _soilType = value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    _getRecommendation();
                  }
                },
                child: Text('Get Recommendation'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : Text(
                _recommendation.isEmpty ? 'Enter details to get advice' : _recommendation,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Weather Service
class WeatherService {
  final String _apiKey = '440faba4d67293ec99cb1ed8d9951478';
  final String _weatherUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> fetchWeather({String? city, double? lat, double? lon}) async {
    Uri uri;
    if (city != null && city.isNotEmpty) {
      uri = Uri.parse('$_weatherUrl?q=$city&appid=$_apiKey&units=metric');
    } else if (lat != null && lon != null) {
      uri = Uri.parse('$_weatherUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
    } else {
      throw Exception('Provide either a city name or coordinates');
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'temperature': data['main']['temp'],
        'rainfall': data['rain'] != null ? data['rain']['1h'] ?? 0.0 : 0.0,
      };
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }
}

// Recommendation Engine
class RecommendationEngine {
  static String generateRecommendation({
    required String cropType,
    required String soilType,
    required double temperature,
    required double rainfall,
  }) {
    String advice = 'Crop: $cropType\nSoil: $soilType\n';

    if (cropType == 'Wheat') {
      if (temperature < 10 || temperature > 30) {
        advice += 'Warning: Temperature ($temperature°C) is not ideal for wheat. Optimal range is 10-30°C.\n';
      } else {
        advice += 'Temperature ($temperature°C) is suitable for wheat.\n';
      }
      if (rainfall < 5) {
        advice += 'Consider irrigation; rainfall ($rainfall mm) is low for wheat.\n';
      } else {
        advice += 'Rainfall ($rainfall mm) is adequate.\n';
      }
      if (soilType != 'Loamy') {
        advice += 'Wheat prefers loamy soil; $soilType may reduce yield.\n';
      }
    } else if (cropType == 'Rice') {
      if (temperature < 20 || temperature > 35) {
        advice += 'Warning: Temperature ($temperature°C) is not ideal for rice. Optimal range is 20-35°C.\n';
      } else {
        advice += 'Temperature ($temperature°C) is suitable for rice.\n';
      }
      if (rainfall < 20) {
        advice += 'Rice needs more water; rainfall ($rainfall mm) is insufficient.\n';
      } else {
        advice += 'Rainfall ($rainfall mm) is good for rice.\n';
      }
      if (soilType != 'Clay') {
        advice += 'Rice thrives in clay soil; $soilType may affect growth.\n';
      }
    }

    advice += 'General Advice: Monitor soil moisture and consider local pest control measures.';
    return advice;
  }
}