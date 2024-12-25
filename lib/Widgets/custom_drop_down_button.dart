import 'package:flutter/material.dart';

import '../Constants/properties.dart';


class CustomDropDownButton extends StatelessWidget {
  final String value;
  final List<String> list;
  final void Function(String?)? onChanged;
  const CustomDropDownButton({
    super.key,
    required this.value,
    required this.list,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      underline: Container(),
      value: value,
      style: AppProperties.tableHeaderStyle,
      items: list.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
