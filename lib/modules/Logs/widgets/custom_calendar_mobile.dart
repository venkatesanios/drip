import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../Constants/properties.dart';

class MobileCustomCalendar extends StatefulWidget {
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final DateTime selectedDate;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;

  const MobileCustomCalendar({
    super.key,
    required this.focusedDay,
    required this.calendarFormat,
    required this.selectedDate,
    required this.onDaySelected,
    required this.onFormatChanged,
  });

  @override
  _MobileCustomCalendarState createState() => _MobileCustomCalendarState();
}

class _MobileCustomCalendarState extends State<MobileCustomCalendar> {
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
    _calendarFormat = widget.calendarFormat;
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // boxShadow: AppProperties.customBoxShadowLiteTheme,
        color: Colors.white,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: TableCalendar(
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.now(),
        calendarFormat: _calendarFormat,
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            gradient: AppProperties.linearGradientLeading,
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        ),
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDay = focusedDay;
          });
          widget.onDaySelected(selectedDay, focusedDay);
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
            widget.onFormatChanged(format);
          }
        },
      ),
    );
  }
}