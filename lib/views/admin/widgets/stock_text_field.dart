import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final double? width;

  const StockTextField({
    super.key,
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.maxLength,
    this.inputFormatters,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      validator: _requiredValidator,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );

    return width != null ? SizedBox(width: width, child: field) : field;
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please fill out this field';
    }
    return null;
  }
}