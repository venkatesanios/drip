import 'package:flutter/material.dart';
import '../../utils/my_function.dart';

class CropAdvisoryForm extends StatefulWidget {
  const CropAdvisoryForm({super.key});

  @override
  State<CropAdvisoryForm> createState() => _CropAdvisoryFormPageState();
}

class _CropAdvisoryFormPageState extends State<CropAdvisoryForm> {
  final _formKey = GlobalKey<FormState>();

  // Field variables
  String? cropName, variety, stage, soilType, irrigationType, location;
  String? rainfall, waterSource, fertilizerUsed, fertilizerFreq;
  DateTime? sowingDate;
  double? soilPH, fieldArea;


  bool isEnabled = true;

  final Map<String, List<String>> crops = {
    "Crops": ["Cotton", "Sugarcane", "Maize", "Groundnut", "Wheat","Tomato", "Chilli", "Brinjal", "Okra",
      "Cabbage", "Cauliflower", "Cucumber", "Capsicum", "Pumpkin", "Bitter Gourd","Banana", "Pomegranate",
      "Papaya", "Grapes", "Mango", "Guava", "Sweet Lime", "Orange", "Watermelon", "Muskmelon","Turmeric",
      "Ginger", "Aloe Vera", "Ashwagandha", "Tulsi","Coconut", "Arecanut", "Coffee", "Tea", "Rubber"],
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Crop Advisory"),
        actions: [
          Row(
            children: [
              Transform.scale(
                scale: 0.8,
                child: Tooltip(
                  message: isEnabled ? 'deactivate' : 'activate',
                  child: Switch(
                    value: isEnabled,
                    activeColor: Theme.of(context).primaryColorLight,
                    activeTrackColor: Colors.white70,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.black12,
                    onChanged: (value) {
                      setState(() {
                        isEnabled = value;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value ? "Crop Advisory activated" : "Crop Advisory deactivated",
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10)
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              _sectionTitle("🌱 Crop Details"),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _dropdown("Crop Name", crops['Crops']!, (val) => setState(() => cropName = val), selected: cropName),
                      _textField("Crop Variety", (val) => variety = val),
                      _dateField("Sowing Date", (val) => sowingDate = val),
                      _dropdown("Stage of Crop", ["Germination", "Flowering", "Harvest"], (val) => setState(() => stage = val), selected: stage),
                    ],
                  ),
                ),
              ),

              _sectionTitle("🌍 Soil & Land Details"),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _dropdown("Soil Type", ["Loamy", "Clay", "Sandy", "Red"], (val) => setState(() => soilType = val), selected: soilType),
                      _textField("Soil pH (e.g. 6.5)", (val) => soilPH = double.tryParse(val)),
                      _textField("Field Area (acres)", (val) => fieldArea = double.tryParse(val)),
                    ],
                  ),
                ),
              ),

              _sectionTitle("💧 Irrigation & Water Details"),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _dropdown("Irrigation Type", ["Drip", "Sprinkler"], (val) => setState(() => irrigationType = val), selected: irrigationType),
                      _dropdown("Water Source", ["Bore-well", "Tank", "Canal", "River"], (val) => setState(() => waterSource = val), selected: waterSource),
                    ],
                  ),
                ),
              ),

              _sectionTitle("🌿 Fertilizer Info"),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _textField("Last Fertilizer Used", (val) => fertilizerUsed = val),
                      _dropdown("Fertilizer Frequency", ["Daily","Weekly", "Biweekly", "Monthly"], (val) => setState(() => fertilizerFreq = val), selected: fertilizerFreq),
                    ],
                  ),
                ),
              ),

              _sectionTitle("📍 Field Location"),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _textField("Location / District", (val) => location = val),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 18, right: 16),
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColorLight),
                    backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColorLight),
                  ),
                  onPressed: () {
                    // Send to backend or AI model here
                    final params = IrrigationParams(
                      cropType: 'Rice',
                      soilType: 'Clay',
                      moistureLevel: 30,
                      weather: 'Hot',
                      area: 100,
                    );
                    double irrigationTime = MyFunction().calculateIrrigationTime(params);
                    print("Irrigation time needed: ${irrigationTime.toStringAsFixed(2)} minutes");

                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Submitting data...")),
                      );
                    }
                  },
                  child: const Text("Save the Details", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ========== UI Helpers ==========

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(title,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      ),
    );
  }

  Widget _textField(String label, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Theme.of(context).primaryColorLight.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.black12, width: 1.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.black12, width: 1.0),
          ),
        ),
        onSaved: (value) => onSaved(value ?? ''),
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _dropdown(String label, List<String> items, Function(String?) onChanged, {String? selected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selected, // <- this retains the selected value
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Theme.of(context).primaryColorLight.withOpacity(0.1),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.black12, width: 1.0),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.black12, width: 1.0),
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }

  Widget _dateField(String label, Function(DateTime) onDatePicked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() => sowingDate = picked);
            onDatePicked(picked);
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Theme.of(context).primaryColorLight.withOpacity(0.1),
              hintText: sowingDate != null ? "${sowingDate!.toLocal()}".split(' ')[0] : "Select Date",
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: Colors.black12, width: 1.0),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: Colors.black12, width: 1.0),
              ),
            ),
            validator: (_) => sowingDate == null ? 'Select a date' : null,
          ),
        ),
      ),
    );
  }
}