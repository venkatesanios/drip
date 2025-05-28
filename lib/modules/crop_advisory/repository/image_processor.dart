import 'package:image/image.dart' as img;
import 'dart:io';

class ImageProcessor {
  Future<Map<String, dynamic>> analyzeImages(File rgbImage, File thermalImage) async {
    final rgb = img.decodeImage(await rgbImage.readAsBytes());
    final thermal = img.decodeImage(await thermalImage.readAsBytes());

    print("rgb :: $rgb");
    print("thermal :: $thermal");
    if (rgb == null || thermal == null) {
      throw Exception('Failed to decode images');
    }

    // RGB analysis: Average green intensity for health and nutrient status
    double avgGreen = 0;
    int pixelCount = 0;
    for (var pixel in rgb) {
      avgGreen += pixel.g;
      pixelCount++;
    }
    avgGreen /= pixelCount;

    // RGB analysis: Color variance for pest detection
    double colorVariance = 0;
    List<int> greenValues = [];
    for (var pixel in rgb) {
      greenValues.add(pixel.g.toInt());
    }
    double meanGreen = greenValues.reduce((a, b) => a + b) / greenValues.length;
    colorVariance = greenValues.map((g) => (g - meanGreen) * (g - meanGreen)).reduce((a, b) => a + b) / greenValues.length;

    // Thermal analysis: Average intensity for water stress
    double avgThermal = 0;
    pixelCount = 0;
    for (var pixel in thermal) {
      avgThermal += pixel.r; // Grayscale thermal image
      pixelCount++;
    }
    avgThermal /= pixelCount;

    print("avgGreen :: $avgGreen");
    print("avgThermal :: $avgThermal");
    print("colorVariance :: $colorVariance");
    return {
      'health': avgGreen > 120 ? 'Good' : 'Poor',
      'waterStress': avgThermal < 100 ? 'Low' : 'High',
      'pestRisk': colorVariance > 500 ? 'High' : 'Low',
      'nutrientStatus': avgGreen < 100 ? 'Deficient' : 'Adequate',
    };
  }
}