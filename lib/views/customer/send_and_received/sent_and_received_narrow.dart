import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../repository/repository.dart';
import '../../../services/http_service.dart';
import '../../../view_models/customer/sent_and_received_view_model.dart';

class SentAndReceivedNarrow extends StatelessWidget {
  const SentAndReceivedNarrow({
    super.key,
    required this.customerId,
    required this.controllerId,
  });

  final int customerId, controllerId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SentAndReceivedViewModel(Repository(HttpService()))
        ..getSentAndReceivedData(
          customerId,
          controllerId,
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
        ),
      child: Consumer<SentAndReceivedViewModel>(
        builder: (context, viewModel, _) {
          final calendarWidget = _buildCalendar(context, viewModel);

          return Scaffold(
            appBar: AppBar(title: const Text('Sent & Received')),
            body: Column(
              children: [
                Container(color: Colors.white, child: calendarWidget),
                Expanded(child: _buildBody(context, viewModel)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, SentAndReceivedViewModel viewModel) {
    const CalendarFormat initialFormat = CalendarFormat.week;

    return TableCalendar(
      firstDay: DateTime.utc(2020, 10, 16),
      lastDay: DateTime.utc(2050, 3, 14),
      focusedDay: viewModel.focusedDay,
      selectedDayPredicate: (day) => isSameDay(viewModel.selectedDay, day),
      enabledDayPredicate: (day) =>
      day.isBefore(DateTime.now()) || isSameDay(day, DateTime.now()),
      onDaySelected: (selectedDay, focusedDay) {
        viewModel.onDateChanged(customerId, controllerId, selectedDay, focusedDay);
      },
      calendarFormat: initialFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
        CalendarFormat.week: 'Week',
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          shape: BoxShape.circle,
        ),
        disabledTextStyle: const TextStyle(color: Colors.grey),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildBody(BuildContext context, SentAndReceivedViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: LoadingIndicator(indicatorType: Indicator.ballPulse),
        ),
      );
    }

    if (viewModel.sentAndReceivedList.isEmpty) {
      return const Center(
        child: Text(
          'Message not found',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: viewModel.sentAndReceivedList.length,
      itemBuilder: (context, index) {
        final message = viewModel.sentAndReceivedList[index];
        final isReceived = message.messageType == 'RECEIVED';

        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment:
            isReceived ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: () {
                  if (!viewModel.hasPayloadViewPermission) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Enter Password'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'This content is protected.\nPlease enter your password to\nview the payload.',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: viewModel.passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                final enteredPassword =
                                    viewModel.passwordController.text;
                                if (enteredPassword == 'Oro@321') {
                                  viewModel.hasPayloadViewPermission = true;
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Access granted. Showing payload...')),
                                  );
                                  viewModel.getUserSoftwareOrHardwarePayload(
                                    context,
                                    customerId,
                                    controllerId,
                                    message.sentAndReceivedId,
                                    'Hardware payload',
                                    message.message,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Incorrect password.')),
                                  );
                                }
                              },
                              child: const Text('Submit'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                onTap: () {
                  if (viewModel.hasPayloadViewPermission) {
                    viewModel.getUserSoftwareOrHardwarePayload(
                      context,
                      customerId,
                      controllerId,
                      message.sentAndReceivedId,
                      'Hardware payload',
                      message.message,
                    );
                  }
                },
                child: BubbleSpecialOne(
                  text: message.message,
                  isSender: isReceived,
                  color:
                  isReceived ? Colors.green.shade100 : Colors.blue.shade100,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: isReceived ? 0 : 25,
                  right: isReceived ? 25 : 0,
                  top: 2,
                ),
                child: Text(
                  isReceived
                      ? viewModel.convertTo12hrs(message.time)
                      : '${message.sentUser}(${message.sentMobileNumber}) - ${viewModel.convertTo12hrs(message.time)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}