import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Models/customer/sent_and_received_model.dart';
import '../../repository/repository.dart';

class SentAndReceivedViewModel extends ChangeNotifier {

  final Repository repository;
  bool isLoading = false;
  String errorMessage = "";
  List<SentAndReceivedModel> sentAndReceivedList = [];

  bool hasPayloadViewPermission = false;
  TextEditingController passwordController = TextEditingController();

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  SentAndReceivedViewModel(this.repository);

  Future<void> getSentAndReceivedData(customerId, controllerId, date) async {
    setLoading(true);
    try {
      Map<String, Object> body = {"userId": customerId, "controllerId": controllerId, "fromDate":date, "toDate":date};
      final response = await repository.fetchSentAndReceivedData(body);
      if (response.statusCode == 200) {
        sentAndReceivedList.clear();
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          sentAndReceivedList = [
            ...jsonData['data'].map((programJson) => SentAndReceivedModel.fromJson(programJson)).toList(),
          ];
        }
      }
    } catch (error) {
      debugPrint('Error fetching country list: $error');
    } finally {
      setLoading(false);
    }
  }

  Future<void> getUserSoftwareOrHardwarePayload(context,customerId, controllerId,
      int sentAndReceivedId, String aTitle, String pyTitle) async
  {
    var body = {
      "userId": customerId,
      "controllerId": controllerId,
      "sentAndReceivedId": sentAndReceivedId,
    };

    try {
      final response = await repository.fetchSentAndReceivedHardwarePayload(body);
      if (response.statusCode == 200) {
        print(response.body);
        final jsonData = jsonDecode(response.body);
        if (jsonData["code"] == 200) {
          final message = jsonData?['data']?['message'];
          if (message != null) {
            print(jsonData['data']['message']);
            displayJsonData(context, jsonData['data']['message'] ?? 'Empty message', aTitle, pyTitle);
          }else{
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(aTitle),
                  content: const Text("No data available."),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } catch (error) {
      debugPrint('Error fetching country list: $error');
    } finally {
      setLoading(false);
    }
  }

  void displayJsonData(BuildContext context, Map<String, dynamic> jsonData, String aTitle, String pyTitle,) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(aTitle),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pyTitle, style: const TextStyle(color: Colors.teal),),
                  const Divider(),
                  Text(jsonEncode(jsonData), style: const TextStyle(color: Colors.black54),),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String convertTo12hrs(String timeString) {
    DateTime dateTime = DateFormat("HH:mm:ss").parse(timeString);
    String formattedTime = DateFormat("h:mm a").format(dateTime);
    return formattedTime;
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void onDateChanged(customerId, controllerId, DateTime sDate, DateTime fDate) {
    selectedDay = sDate;
    focusedDay = fDate;
    String formattedDate = DateFormat('yyyy-MM-dd').format(sDate);
    getSentAndReceivedData(customerId, controllerId, formattedDate);
  }

}