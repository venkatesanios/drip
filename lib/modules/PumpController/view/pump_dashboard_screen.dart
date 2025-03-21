import 'dart:math';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/services/mqtt_service.dart';

class PumpDashboardScreen extends StatefulWidget {
  const PumpDashboardScreen({super.key});

  @override
  State<PumpDashboardScreen> createState() => _PumpDashboardScreenState();
}

class _PumpDashboardScreenState extends State<PumpDashboardScreen> with TickerProviderStateMixin{
  late AnimationController _controller;
  late AnimationController _controller2;
  late Animation<double> _animation;
  late Animation<double> _animation2;
  String _formattedTime = "00:00:00";
  int requestedLive = 0;
  bool hasRequestedLive = false;

  @override
  void initState() {
    // TODO: implement initState
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);
    _animation2 = Tween<double>(begin: 1.0, end: 0.0).animate(_controller2);
    _controller.addListener(() {setState(() {});});
    _controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    _controller2.dispose();
    // _timer.cancel();
    // _formattedTime = "00:00:00";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: MqttService().pumpDashboardPayloadController,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }
          if(!snapshot.hasData) {
            return const Center(child: Text('Data not available'),);
          }
          return Center(child: Text('${MqttService().pumpDashboardPayload!.batteryStrength}'),);
        }
    );
  }

  Widget _buildColumn({
    required String title,
    required String value,
    BoxConstraints? constraints,
  }) {
    return Container(
      width:  constraints != null ? constraints.maxWidth * 0.25 : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300), textAlign: TextAlign.center),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget buildButton({required String label, required Color color, required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: color,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              shadows: [Shadow(offset: const Offset(2, 2), blurRadius: 6, color: Colors.black.withOpacity(0.3))],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContainer({
    required String title,
    required String value,
    String? value2,
    required Color color1,
    required Color color2,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: _boxDecoration(color1, color2),
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            if (value2 != null) Text(value2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget buildCurrentContainer({
    required String title,
    required String value,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width: 100,
      decoration: _boxDecoration(color1, color2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration(Color color1, Color color2) {
    return BoxDecoration(
      gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color2, width: 0.3),
      boxShadow: [BoxShadow(color: color2.withOpacity(0.5), offset: const Offset(0, 0))],
    );
  }

  Widget _buildPumpDetailColumn({
    required String title,
    required Widget content,
    required String footer1,
    required String footer2,
    required IconData icon,
    bool condition = true,
  }) {
    return condition
        ? Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildIcon(icon),
            const SizedBox(width: 10),
            _buildPumpDetails(title, footer1, footer2),
          ],
        ),
        content,
      ],
    )
        : _buildFallbackLayout(title, content, footer1, footer2);
  }

  Widget _buildIcon(IconData icon) {
    return Container(
      height: 35,
      width: 35,
      decoration: BoxDecoration(gradient: AppProperties.linearGradientLeading, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildPumpDetails(String title, String footer1, String footer2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Row(
          children: [
            _buildDetailColumn("Actual value"),
            const SizedBox(width: 5),
            _buildDetailColumn(footer2.isNotEmpty ? "Total flow" : ""),
            const SizedBox(width: 5),
            _buildDetailColumn(footer1, isBold: true),
            const SizedBox(width: 5),
            if (footer2.isNotEmpty) _buildDetailColumn(footer2.split(':')[1], isBold: true),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailColumn(String text, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text.toUpperCase(), style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w400)),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildFallbackLayout(String title, Widget content, String footer1, String footer2) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title.toUpperCase()),
        content,
        Text(footer1, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (footer2.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: Column(
              children: [
                Text(footer2.split(':')[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(footer2.split(':')[1]),
              ],
            ),
          ),
      ],
    );
  }
}
