import 'package:flutter/material.dart';

class ConditionLabelsColumn extends StatelessWidget {
  const ConditionLabelsColumn({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Component', style: TextStyle(color: Colors.black54)),
          SizedBox(height: 8),
          Text('Parameter', style: TextStyle(color: Colors.black54)),
          SizedBox(height: 10),
          Text('Value/Threshold', style: TextStyle(color: Colors.black54)),
          SizedBox(height: 12),
          Text('Reason', style: TextStyle(color: Colors.black54)),
          SizedBox(height: 15),
          Text('Delay Time', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}