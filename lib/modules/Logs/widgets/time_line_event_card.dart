import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../../Constants/constants.dart';
import '../../../Constants/properties.dart';
import '../../ScheduleView/widgets/custom_timeline_widget.dart';
import '../view/event_log_model.dart';

class TimelineEventCard extends StatelessWidget {
  final EventLog event;

  const TimelineEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    /*return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppProperties.customBoxShadowLiteTheme,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${event.onTime}",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.event_note, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                event.onReason,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.event_busy, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                event.offReason,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                "Duration: ${event.duration}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ],
      ),
    );*/
    return TimeLine(
      itemGap: 0,
      padding: const EdgeInsets.symmetric(vertical: 0),
      indicatorSize: 80,
      gutterSpacing: 0,
      indicators: [
        buildTimeLineIndicators(context: context, event: event)
      ],
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
            border: Border(top: BorderSide(color: Theme.of(context).primaryColor, width: 0.5), bottom: BorderSide(color: Theme.of(context).primaryColor, width: 0.5), right: BorderSide(color: Theme.of(context).primaryColor, width: 0.5)),
            boxShadow: AppProperties.customBoxShadowLiteTheme,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(MdiIcons.powerOff, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        Constants.capitalizeFirstLetter(event.onReason),
                        style: TextStyle(
                          // fontSize: 16,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Row(
                  children: [
                    Icon(MdiIcons.powerOff, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        Constants.capitalizeFirstLetter(event.offReason),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(text: "Duration: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 14)),
                        TextSpan(text: '${event.duration}', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildTimeLineIndicators({context, required EventLog event}) {
    // DateTime onTime = DateFormat('HH:mm:ss').parse(event.onTime);
    // DateTime offTime = DateFormat('HH:mm:ss').parse(event.offTime);
    // String formattedOnTime = DateFormat('hh:mm a').format(onTime);
    // String formattedOffTime = DateFormat('hh:mm a').format(offTime);
    return Container(
        margin: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppProperties.linearGradientLeading,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
          border: Border(top: BorderSide(color: Theme.of(context).primaryColor, width: 0.5), bottom: BorderSide(color: Theme.of(context).primaryColor, width: 0.5), left: BorderSide(color: Theme.of(context).primaryColor, width: 0.5)),
          boxShadow: AppProperties.customBoxShadowLiteTheme,
        ),
        // width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${event.onTime}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.white),),
            const Text("to", style: TextStyle(fontSize: 12,  color: Colors.white),),
            Text("${event.offTime}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic,  color: Colors.white),),
            // Expanded(
            //   child: Container(
            //     margin: const EdgeInsets.symmetric(vertical: 5),
            //     width: 5,
            //     decoration: BoxDecoration(
            //         // gradient: linearGradientLeading,
            //         color: Colors.white,
            //         borderRadius: BorderRadius.circular(5)
            //     ),
            //     // color: status.color,
            //   ),
            // )
            // Text("${event.duration}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
          ],
        )
    );
  }
}