import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String errstatus;
  final IconData icon;
  final String minval;
  final String maxval;
  final String otherval;

  const WeatherCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.errstatus,
    required this.icon,
    required this.minval,
    required this.maxval,
    required this.otherval,
  });


  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case '1':
        return Colors.red;
      case '2':
        return Colors.yellow;
      case '3':
        return Colors.orange;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // TITLE
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            // ICON
            Icon(icon, size: 32, color: Colors.blueAccent),
            const SizedBox(height: 8),

            // VALUE + UNIT
            Text(
              "$value $unit",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // ERROR STATUS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor(errstatus).withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "ErrCode:$errstatus",
                style: TextStyle(
                   fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ADDITIONAL DETAILS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailColumn('Min', minval, unit),
                _buildDetailColumn('Max', maxval, unit),
                _buildDetailColumn('Other', otherval, unit),
              ],
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "$value $unit",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
