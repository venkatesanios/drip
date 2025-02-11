import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../view_models/customer/sent_and_received_view_model.dart';

class SentAndReceived extends StatelessWidget {
  const SentAndReceived({super.key, required this.customerId});
  final int customerId;

  @override
  Widget build(BuildContext context) {
    final cvm = Provider.of<CustomerScreenControllerViewModel>(context);
    return ChangeNotifierProvider(
      create: (_) => SentAndReceivedViewModel(Repository(HttpService()))..getSentAndReceivedData(customerId, cvm.controllerId, DateFormat('yyyy-MM-dd').format(DateTime.now())),
      child: Consumer<SentAndReceivedViewModel>(
        builder: (context, viewModel, _) {
          return SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 350,
                  height: 400,
                  child: TableCalendar(
                      firstDay: DateTime.utc(2020, 10, 16),
                      lastDay: DateTime.utc(2050, 3, 14),
                      focusedDay: viewModel.focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(viewModel.selectedDay, day);
                      },
                      enabledDayPredicate: (day) {
                        return day.isBefore(DateTime.now()) || isSameDay(day, DateTime.now());
                      },
                      onDaySelected: (selectedDay, focusedDay)=>viewModel.onDateChanged(customerId, cvm.controllerId, selectedDay, focusedDay),
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.deepOrange,
                          shape: BoxShape.circle,
                        ),
                        disabledTextStyle: TextStyle(color: Colors.grey),  // To make the disabled dates greyed out
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      )
                  ),
                ),
                const SizedBox(width: 5,),
                /*Container(width: 0.5, height: widget.from=='Gem'? MediaQuery.sizeOf(context).height-77: MediaQuery.sizeOf(context).height-120, color: Colors.teal.shade200,),
                msgListBox(screenWidth),*/
              ],
            ),
          );
        },
      ),
    );
  }
}