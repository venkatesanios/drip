import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/views/admin/widgets/stock_text_field.dart';

class ManufacturingDateField extends StatelessWidget {
  final TextEditingController controller;
  const ManufacturingDateField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return StockTextField(
      controller: controller,
      label: "Manufacturing Date",
      readOnly: true,
      onTap: () async {
        DateTime? date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          controller.text = DateFormat('dd-MM-yyyy').format(date);
        }
      },
    );
  }
}