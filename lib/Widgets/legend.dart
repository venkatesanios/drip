import 'package:flutter/material.dart';

import '../Constants/properties.dart';

class ColorLegend extends StatelessWidget {
  final Color color;
  final String message;
  final double screenWidth;
  const ColorLegend({
    super.key,
    required this.color,
    required this.message,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: color
            ),
          ),
          const SizedBox(width: 10,),
          Text(message,style: screenWidth > 1000 ? AppProperties.normalBlackBoldTextStyle : AppProperties.tableHeaderStyle,)
        ],
      ),
    );
  }
}
