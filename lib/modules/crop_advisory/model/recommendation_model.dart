class RecommendationModel {
  // Crop-specific requirements (expandable)
  static const Map<String, Map<String, dynamic>> _cropData = {
    'Wheat': {
      'optimalTemp': {'min': 10, 'max': 30},
      'optimalMoisture': {'min': 20, 'max': 40},
      'optimalSoil': ['Loamy'],
      'rainfallNeeds': {'min': 5, 'max': 20},
      'growthStages': {
        'Vegetative': 'Focus on nitrogen fertilization and weed control.',
        'Flowering': 'Ensure adequate water and monitor for pests.',
        'Fruiting': 'Optimize irrigation and check for nutrient balance.'
      }
    },
    'Rice': {
      'optimalTemp': {'min': 20, 'max': 35},
      'optimalMoisture': {'min': 30, 'max': 60},
      'optimalSoil': ['Clay'],
      'rainfallNeeds': {'min': 20, 'max': 50},
      'growthStages': {
        'Vegetative': 'Ensure high water levels and weed control.',
        'Flowering': 'Maintain water levels and check for pests.',
        'Fruiting': 'Reduce water gradually and monitor nutrient levels.'
      }
    },
    // Add more crops here (e.g., Maize, Soybean)
  };

  static String generateRecommendation({
    required String cropType,
    required String soilType,
    required double temperature,
    required double rainfall,
    required double humidity,
    required String growthStage,
    required double soilMoisture,
    required Map<String, dynamic> imageAnalysis,
    double? soilNitrogen,
    double? soilPH,
  }) {

    print("humidity :: $humidity");
    // Input validation
    if (!_cropData.containsKey(cropType)) {
      return 'Error: Unsupported crop type: $cropType';
    }
    if (temperature < -50 || temperature > 50) {
      return 'Error: Invalid temperature value: $temperature°C';
    }
    if (soilMoisture < 0 || soilMoisture > 100) {
      return 'Error: Invalid soil moisture value: $soilMoisture%';
    }
    if (humidity < 0 || humidity > 100) {
      return 'Error: Invalid humidity value: $humidity%';
    }

    String advice = 'Crop: $cropType\nSoil: $soilType\nGrowth Stage: $growthStage\n';

    // Weather-based recommendations
    advice += _generateWeatherAdvice(cropType, temperature, rainfall, humidity, soilMoisture);

    // Soil-based recommendations
    advice += _generateSoilAdvice(cropType, soilType, soilNitrogen, soilPH);

    // Image-based recommendations
    advice += _generateImageAdvice(imageAnalysis);

    // Growth stage-based recommendations
    advice += _generateGrowthStageAdvice(cropType, growthStage);

    advice += 'General Advice: Consult local agricultural experts for tailored recommendations.\n';
    return advice;
  }

  static String _generateWeatherAdvice(
      String cropType, double temperature, double rainfall, double humidity, double soilMoisture) {
    String advice = '\nWeather Analysis:\n';
    final crop = _cropData[cropType]!;

    // Temperature
    if (temperature < crop['optimalTemp']['min'] || temperature > crop['optimalTemp']['max']) {
      advice +=
      'Warning: Temperature ($temperature°C) is outside optimal range (${crop['optimalTemp']['min']}-${crop['optimalTemp']['max']}°C) for $cropType.\n';
    } else {
      advice += 'Temperature ($temperature°C) is suitable for $cropType.\n';
    }

    // Rainfall and soil moisture
    if (rainfall < crop['rainfallNeeds']['min'] || soilMoisture < crop['optimalMoisture']['min']) {
      advice +=
      'Consider irrigation; rainfall ($rainfall mm) or soil moisture ($soilMoisture%) is low for $cropType.\n';
    } else if (soilMoisture > crop['optimalMoisture']['max']) {
      advice += 'Warning: Soil moisture ($soilMoisture%) is too high; risk of waterlogging.\n';
    } else {
      advice += 'Rainfall ($rainfall mm) and soil moisture ($soilMoisture%) are adequate.\n';
    }

    // Humidity
    if (humidity > 80) {
      advice += 'Warning: High humidity ($humidity%) may increase fungal disease risk.\n';
    } else if (humidity < 30) {
      advice += 'Low humidity ($humidity%) may stress plants; monitor irrigation.\n';
    } else {
      advice += 'Humidity ($humidity%) is suitable.\n';
    }

    return advice;
  }

  static String _generateSoilAdvice(String cropType, String soilType, double? soilNitrogen, double? soilPH) {
    String advice = '\nSoil Analysis:\n';
    final crop = _cropData[cropType]!;

    if (!crop['optimalSoil'].contains(soilType)) {
      advice += '$cropType prefers ${crop['optimalSoil'].join(", ")} soil; $soilType may reduce yield.\n';
    } else {
      advice += 'Soil type ($soilType) is optimal for $cropType.\n';
    }

    if (soilNitrogen != null && soilNitrogen < 20) {
      advice += 'Low soil nitrogen ($soilNitrogen mg/kg); consider nitrogen fertilizer.\n';
    }

    if (soilPH != null) {
      if (soilPH < 6.0 || soilPH > 7.5) {
        advice += 'Soil pH ($soilPH) is outside optimal range (6.0-7.5); consider soil amendments.\n';
      } else {
        advice += 'Soil pH ($soilPH) is suitable.\n';
      }
    }

    return advice;
  }

  static String _generateImageAdvice(Map<String, dynamic> imageAnalysis) {
    String advice = '\nImage Analysis:\n';
    const requiredKeys = ['health', 'waterStress', 'pestRisk', 'nutrientStatus'];

    // Validate imageAnalysis map
    for (var key in requiredKeys) {
      if (!imageAnalysis.containsKey(key)) {
        return advice + 'Error: Missing image analysis data for $key.\n';
      }
    }

    advice += '  Crop Health: ${imageAnalysis['health']}\n';
    advice += '  Water Stress: ${imageAnalysis['waterStress']}\n';
    advice += '  Pest Risk: ${imageAnalysis['pestRisk']}\n';
    advice += '  Nutrient Status: ${imageAnalysis['nutrientStatus']}\n';

    if (imageAnalysis['health'] == 'Poor' || imageAnalysis['nutrientStatus'] == 'Deficient') {
      advice += 'Recommendation: Apply nitrogen or potassium fertilizers based on soil test.\n';
    }
    if (imageAnalysis['waterStress'] == 'High') {
      advice += 'Recommendation: Irrigate immediately to reduce water stress.\n';
    }
    if (imageAnalysis['pestRisk'] == 'High') {
      advice += 'Recommendation: Inspect for pests and apply targeted pesticides.\n';
    }

    return advice;
  }

  static String _generateGrowthStageAdvice(String cropType, String growthStage) {
    String advice = '\nGrowth Stage Recommendations:\n';
    final crop = _cropData[cropType]!;
    if (crop['growthStages'].containsKey(growthStage)) {
      advice += crop['growthStages'][growthStage] + '\n';
    } else {
      advice += 'Warning: Unknown growth growthStage ($growthStage) for $cropType.\n';
    }
    return advice;
  }
}