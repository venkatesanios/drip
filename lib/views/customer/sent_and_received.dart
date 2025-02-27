import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../view_models/customer/sent_and_received_view_model.dart';

class SentAndReceived extends StatelessWidget {
  const SentAndReceived({super.key, required this.customerId, required this.controllerId});
  final int customerId, controllerId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SentAndReceivedViewModel(Repository(HttpService()))..getSentAndReceivedData(customerId, controllerId, DateFormat('yyyy-MM-dd').format(DateTime.now())),
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
                      onDaySelected: (selectedDay, focusedDay)=>viewModel.onDateChanged(customerId, controllerId, selectedDay, focusedDay),
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
                VerticalDivider(color: Colors.grey.shade300),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width-512,
                  height: MediaQuery.sizeOf(context).height-77,
                  child: viewModel.isLoading? Visibility(
                    visible: true,
                    child: Container(
                      height: double.infinity,
                      color: Colors.transparent,
                      padding: EdgeInsets.fromLTRB(MediaQuery.sizeOf(context).width/2 - 280, 0, MediaQuery.sizeOf(context).width/2 - 280, 0),
                      child: const LoadingIndicator(
                        indicatorType: Indicator.ballPulse,
                      ),
                    ),
                  ):
                  viewModel.sentAndReceivedList.isNotEmpty? ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: viewModel.sentAndReceivedList.length,
                    itemBuilder: (context, index)
                    {
                      if(viewModel.sentAndReceivedList[index].messageType == 'RECEIVED')
                      {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onLongPress: () {
                                  if(!viewModel.hasPayloadViewPermission){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Enter Password'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('This content is protected.\nPlease enter your password to\nview the payload.',
                                                style: TextStyle(fontWeight: FontWeight.normal),),
                                              const SizedBox(height: 8),
                                              TextField(
                                                controller: viewModel.passwordController,
                                                obscureText: false,
                                                decoration: const InputDecoration(
                                                  labelText: 'Password',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                String enteredPassword = viewModel.passwordController.text;
                                                if (enteredPassword == 'Oro@321') {
                                                  viewModel.hasPayloadViewPermission=true;
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Access granted. Showing payload...')),
                                                  );
                                                  viewModel.getUserSoftwareOrHardwarePayload(context,customerId, controllerId,
                                                      viewModel.sentAndReceivedList[index].sentAndReceivedId,'Hardware payload',
                                                      viewModel.sentAndReceivedList[index].message);
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Incorrect password.')),
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
                                onTap: (){
                                  if(viewModel.hasPayloadViewPermission){
                                    viewModel.getUserSoftwareOrHardwarePayload(context,customerId, controllerId,
                                        viewModel.sentAndReceivedList[index].sentAndReceivedId,'Hardware payload',
                                        viewModel.sentAndReceivedList[index].message);
                                  }
                                },
                                child: BubbleSpecialOne(
                                  textStyle: const TextStyle(fontSize: 12),
                                  text: viewModel.sentAndReceivedList[index].message,
                                  color: Colors.green.shade100,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 25),
                                child: Text(viewModel.convertTo12hrs(viewModel.sentAndReceivedList[index].time), style: const TextStyle(fontSize: 11, color: Colors.grey),),
                              ),
                            ],
                          ),
                        );
                      }
                      else
                      {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onLongPress: () {
                                  if(!viewModel.hasPayloadViewPermission){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Enter Password'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('This content is protected.\nPlease enter your password to\nview the payload.',
                                                style: TextStyle(fontWeight: FontWeight.normal),),
                                              const SizedBox(height: 8),
                                              TextField(
                                                controller: viewModel.passwordController,
                                                obscureText: false,
                                                decoration: const InputDecoration(
                                                  labelText: 'Password',
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                String enteredPassword = viewModel.passwordController.text;
                                                if (enteredPassword == 'Oro@321') {
                                                  viewModel.hasPayloadViewPermission=true;
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Access granted. Showing payload...')),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Incorrect password.')),
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
                                onTap: (){
                                  if(viewModel.hasPayloadViewPermission){
                                    viewModel.getUserSoftwareOrHardwarePayload(context,customerId, controllerId,
                                        viewModel.sentAndReceivedList[index].sentAndReceivedId,'Hardware payload',
                                        viewModel.sentAndReceivedList[index].message);
                                  }
                                },
                                child: BubbleSpecialOne(
                                  text: viewModel.sentAndReceivedList[index].message,
                                  isSender: false,
                                  color: Colors.blue.shade100,
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: Text('${viewModel.sentAndReceivedList[index].sentUser}(${viewModel.sentAndReceivedList[index].sentMobileNumber}) - ${viewModel.convertTo12hrs(viewModel.sentAndReceivedList[index].time)}', style: const TextStyle(fontSize: 11, color: Colors.grey),),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ):
                  const Center(child: Text('Message not found',
                    style: TextStyle(fontSize: 17,fontWeight: FontWeight.normal),),),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}