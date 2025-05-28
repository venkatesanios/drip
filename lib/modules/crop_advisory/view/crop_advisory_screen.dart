import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import '../model/recommendation_model.dart';
import '../repository/image_processor.dart';
import '../repository/weather_service.dart';

class CropAdvisoryScreen extends StatefulWidget {
  const CropAdvisoryScreen({super.key});

  @override
  State<CropAdvisoryScreen> createState() => _CropAdvisoryScreenState();
}

class _CropAdvisoryScreenState extends State<CropAdvisoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  String _cropType = 'Wheat';
  String _location = '';
  double? _latitude;
  double? _longitude;
  String _soilType = 'Loamy';
  String _growthStage = 'Vegetative';
  double _soilMoisture = 20.0;
  String _recommendation = '';
  bool _isLoading = false;
  File? _rgbImage;
  File? _thermalImage;
  int _currentStep = 0;

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _soilMoistureController = TextEditingController(text: '20.0');
  final ImagePicker _picker = ImagePicker();

  final List<String> _crops = ['Wheat', 'Rice', 'Maize', 'Tomato', 'Cotton', 'Soybean'];
  final List<String> _soilTypes = ['Loamy', 'Clay', 'Sandy', 'Silt'];
  final List<String> _growthStages = ['Vegetative', 'Flowering', 'Fruiting', 'Harvest'];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _soilMoistureController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cropType = prefs.getString('cropType') ?? 'Wheat';
      _location = prefs.getString('location') ?? '';
      _soilType = prefs.getString('soilType') ?? 'Loamy';
      _growthStage = prefs.getString('growthStage') ?? 'Vegetative';
      _soilMoisture = prefs.getDouble('soilMoisture') ?? 20.0;
      _latitude = prefs.getDouble('latitude');
      _longitude = prefs.getDouble('longitude');
      _locationController.text = _location;
      _soilMoistureController.text = _soilMoisture.toString();
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cropType', _cropType);
    await prefs.setString('location', _location);
    await prefs.setString('soilType', _soilType);
    await prefs.setString('growthStage', _growthStage);
    await prefs.setDouble('soilMoisture', _soilMoisture);
    if (_latitude != null) await prefs.setDouble('latitude', _latitude!);
    if (_longitude != null) await prefs.setDouble('longitude', _longitude!);
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable location services.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied. Please grant location access.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions permanently denied. Please enable in settings.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _location = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
        _locationController.text = _location;
        _isLoading = false;
      });

      await _saveData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location detected successfully!'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickImage(String type) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Text('Choose how you want to add the image'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (source == null) return;

    try {
      PermissionStatus permissionStatus;
      if (source == ImageSource.camera) {
        permissionStatus = await Permission.camera.request();
      } else {
        permissionStatus = await Permission.storage.request();
      }

      if (!permissionStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${source == ImageSource.camera ? 'Camera' : 'Gallery'} permission denied'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (type == 'rgb') {
            _rgbImage = File(pickedFile.path);
          } else {
            _thermalImage = File(pickedFile.path);
          }
        });
        await _saveData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${type.toUpperCase()} image uploaded successfully!'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _getRecommendation() async {
    if (!_formKey.currentState!.validate()) {
      // Show validation error with better feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Please fill in all required fields'),
            ],
          ),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _recommendation = ''; // Clear previous recommendation
    });

    try {
      // Show progress feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Analyzing your data...'),
            ],
          ),
          backgroundColor: Colors.blue[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );

      // Fetch weather data
      final weather = await WeatherService().fetchWeather(
        city: _location.isNotEmpty && (_latitude == null || _longitude == null) ? _location : null,
        lat: _latitude,
        lon: _longitude,
      );

      // Analyze images if provided
      Map<String, dynamic> imageAnalysis = {
        'health': 'Unknown',
        'waterStress': 'Unknown',
        'pestRisk': 'Unknown',
        'nutrientStatus': 'Unknown',
      };

      if (_rgbImage != null && _thermalImage != null) {
        imageAnalysis = await ImageProcessor().analyzeImages(_rgbImage!, _thermalImage!);
      }

      // Generate recommendation
      print('weather :: ${weather['humidity']}');
      final recommendation = RecommendationModel.generateRecommendation(
        cropType: _cropType,
        soilType: _soilType,
        temperature: weather['temperature'] ?? 25.0,
        rainfall: weather['rainfall'] ?? 0.0,
        growthStage: _growthStage,
        soilMoisture: double.parse(_soilMoistureController.text),
        imageAnalysis: imageAnalysis,
        humidity: double.parse(weather['humidity'].toString()),
      );

      setState(() {
        _recommendation = recommendation;
        _isLoading = false;
      });

      await _saveData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Recommendation generated successfully!'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _recommendation = 'Error fetching data: $e';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString().length > 50 ? '${e.toString().substring(0, 50)}...' : e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _getRecommendation,
            ),
          ),
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Crop Advisory'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Step ${_currentStep + 1} of 4',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 4,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),

            // Page View Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  _buildBasicInfoStep(),
                  _buildLocationStep(),
                  _buildSoilInfoStep(),
                  _buildImageAnalysisStep(),
                ],
              ),
            ),

            // Bottom Navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Crop Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your crop to get personalized advice',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),

          _buildInfoCard(
            child: Column(
              children: [
                _buildDropdownField(
                  label: 'Crop Type',
                  value: _cropType,
                  items: _crops,
                  icon: Icons.agriculture,
                  onChanged: (value) => setState(() => _cropType = value!),
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Growth Stage',
                  value: _growthStage,
                  items: _growthStages,
                  icon: Icons.timeline,
                  onChanged: (value) => setState(() => _growthStage = value!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We need your location for accurate weather data',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),

          _buildInfoCard(
            child: Column(
              children: [
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter city name or coordinates',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter a location or use current location' : null,
                  onChanged: (value) {
                    setState(() {
                      _location = value;
                      if (!value.startsWith('Lat:')) {
                        _latitude = null;
                        _longitude = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _getCurrentLocation,
                    icon: _isLoading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.my_location),
                    label: Text(_isLoading ? 'Getting Location...' : 'Use Current Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (_latitude != null && _longitude != null)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[600]),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Location detected successfully',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoilInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Soil Information',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Soil conditions are crucial for accurate crop recommendations',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),

          _buildInfoCard(
            child: Column(
              children: [
                _buildDropdownField(
                  label: 'Soil Type',
                  value: _soilType,
                  items: _soilTypes,
                  icon: Icons.layers,
                  onChanged: (value) => setState(() => _soilType = value!),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _soilMoistureController,
                  decoration: InputDecoration(
                    labelText: 'Soil Moisture (%)',
                    hintText: 'Enter percentage (0-100)',
                    prefixIcon: const Icon(Icons.opacity),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter soil moisture percentage';
                    final moisture = double.tryParse(value);
                    if (moisture == null) return 'Please enter a valid number';
                    if (moisture < 0 || moisture > 100) return 'Moisture must be between 0-100%';
                    return null;
                  },
                  onChanged: (value) {
                    final moisture = double.tryParse(value);
                    if (moisture != null && moisture >= 0 && moisture <= 100) {
                      setState(() {
                        _soilMoisture = moisture;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Soil Moisture: ${_soilMoisture.round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Slider(
                  value: _soilMoisture,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: Colors.green[600],
                  onChanged: (value) {
                    setState(() {
                      _soilMoisture = value;
                      _soilMoistureController.text = value.round().toString();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dry (0%)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text('Optimal (50%)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text('Wet (100%)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageAnalysisStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Image Analysis',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload images for detailed crop analysis (optional but recommended)',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 24),

          _buildInfoCard(
            child: Column(
              children: [
                _buildImageUploadSection('RGB Image', _rgbImage, 'rgb'),
                const SizedBox(height: 20),
                _buildImageUploadSection('Thermal Image', _thermalImage, 'thermal'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _getRecommendation,
                    icon: _isLoading
                        ? const SpinKitCircle(color: Colors.white, size: 20)
                        : const Icon(Icons.psychology),
                    label: Text(_isLoading ? 'Analyzing...' : 'Get Recommendation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_recommendation.isNotEmpty) _buildRecommendationCard(),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(String title, File? image, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: image != null
              ? Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  image,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        if (type == 'rgb') {
                          _rgbImage = null;
                        } else {
                          _thermalImage = null;
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          )
              : InkWell(
            onTap: () => _pickImage(type),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload $title',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Camera or Gallery',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard() {
    if (_recommendation.isEmpty && !_isLoading) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: _buildInfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isLoading ? Icons.psychology : Icons.lightbulb,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoading ? 'Generating Recommendation...' : 'AI Crop Recommendation',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _isLoading ? 'Analyzing your crop data' : 'Based on your inputs and analysis',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const SpinKitCircle(
                      color: Colors.white,
                      size: 30,
                    ),
                ],
              ),
            ),

            // Content Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: _isLoading
                  ? Column(
                children: [
                  const SpinKitWave(
                    color: Colors.green,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please wait while we analyze your crop data...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recommendation Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _recommendation.startsWith('Error')
                          ? Colors.red[100]
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _recommendation.startsWith('Error')
                            ? Colors.red[300]!
                            : Colors.green[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _recommendation.startsWith('Error')
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          size: 16,
                          color: _recommendation.startsWith('Error')
                              ? Colors.red[700]
                              : Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _recommendation.startsWith('Error') ? 'Analysis Failed' : 'Analysis Complete',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _recommendation.startsWith('Error')
                                ? Colors.red[700]
                                : Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recommendation Content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _recommendation,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: _recommendation.startsWith('Error')
                            ? Colors.red[700]
                            : Colors.grey[800],
                      ),
                    ),
                  ),

                  if (!_recommendation.startsWith('Error')) ...[
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Copy to clipboard functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Recommendation copied to clipboard'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Copy'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green[700],
                              side: BorderSide(color: Colors.green[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Save recommendation functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Recommendation saved successfully'),
                                  backgroundColor: Colors.green[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bookmark, size: 18),
                            label: const Text('Save'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _currentStep < 3 ? _nextStep : null,
                icon: Icon(_currentStep < 3 ? Icons.arrow_forward : Icons.check),
                label: Text(_currentStep < 3 ? 'Next' : 'Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
