import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Models/customer/sent_and_received_model.dart';
import '../../repository/repository.dart';
import '../../utils/shared_preferences_helper.dart';

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
    String? userRole = await PreferenceHelper.getUserRole();
    if(userRole != 'customer'){
      hasPayloadViewPermission = true;
    }
    try {
      Map<String, Object> body = {"userId": customerId, "controllerId": controllerId, "fromDate":date, "toDate":date};
      final response = await repository.fetchSentAndReceivedData(body);
      if (response.statusCode == 200) {
        sentAndReceivedList.clear();
        final jsonData = jsonDecode(response.body);
        print(response.body);
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

  Future<void> getUserSoftwareOrHardwarePayload(
      BuildContext context,
      int customerId,
      int controllerId,
      int sentAndReceivedId,
      String aTitle,
      String pyTitle) async {

    var body = {
      "userId": customerId,
      "controllerId": controllerId,
      "sentAndReceivedId": sentAndReceivedId,
    };

    try {
      final response = await repository.fetchSentAndReceivedHardwarePayload(body);
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print(response.body);

        if (jsonData["code"] == 200) {

          final Map<String, dynamic> dataMap = Map<String, dynamic>.from(jsonData['data'] ?? {});

          if (dataMap.isNotEmpty) {
            final message = dataMap['message'] ?? "Empty message";
            final changedPayload = (dataMap['changedPayload'] != null)
                ? Map<String, dynamic>.from(dataMap['changedPayload'])
                : <String, dynamic>{};

            displayJsonData(context, message, aTitle, pyTitle, changedPayload);
          } else {
            _showNoDataDialog(context, aTitle);
          }

         /* final List<dynamic> dataList = jsonData['data'] ?? [];

          if (dataList.isNotEmpty) {
            final Map<String, dynamic> item = Map<String, dynamic>.from(dataList.first);

            final message = item['message'] ?? "Empty message";
            final changedPayload = (item['changedPayload'] != null)
                ? Map<String, dynamic>.from(item['changedPayload'])
                : <String, dynamic>{};

            displayJsonData(context, message, aTitle, pyTitle, changedPayload);
          } else {
            _showNoDataDialog(context, aTitle);
          }*/
        }
      }
    } catch (error) {
      debugPrint('Error fetching payload: $error');
    } finally {
      setLoading(false);
    }
  }

  void displayJsonData(
      BuildContext context,
      Map<String, dynamic> jsonData,
      String aTitle,
      String pyTitle,
      Map<String, dynamic> changedPayload) {
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
                  Text(pyTitle, style: const TextStyle(color: Colors.teal)),
                  const Divider(),
                  SelectableText(
                    const JsonEncoder.withIndent('  ').convert(jsonData.toString()),
                    style: const TextStyle(color: Colors.black54),
                  ),
                  if (changedPayload.isNotEmpty) ...[
                    const Divider(),
                    const Text("Changed in", style: TextStyle(color: Colors.teal)),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        const JsonEncoder.withIndent('  ').convert(changedPayload),
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ]
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

  void _showNoDataDialog(BuildContext context, String aTitle) {
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