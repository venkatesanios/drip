import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/Logs/widgets/time_line_event_card.dart';

import '../view/event_log_model.dart';
class Timeline2 extends StatelessWidget {
  final List<EventLog> events;

  const Timeline2({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...events.map((event) => TimelineEventCard(event: event)).toList()
      ],
    );
  }
}