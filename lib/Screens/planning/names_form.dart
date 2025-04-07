import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import '../../StateManagement/overall_use.dart';
import '../../modules/IrrigationProgram/view/program_library.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';

class Names extends StatefulWidget {
  final int userID, customerID, controllerId, menuId;
  final String imeiNo;

  const Names({
    required this.userID,
    required this.customerID,
    required this.controllerId,
    required this.menuId,
    required this.imeiNo,
    super.key,
  });

  @override
  _NamesState createState() => _NamesState();
}

class _NamesState extends State<Names> {
  late List<Map<String, dynamic>> configObjects;
  List<String> uniqueObjectNames = [];
  Map<String, dynamic> configData = {};
  late MqttPayloadProvider payloadProvider;
  late OverAllUse overAllPvd;
  var liveData;
  int selectedCategory = 0;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    configObjects = [];
    _controllers = [];
    getData();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> getData() async {
    print("getData");
    try {
      final Repository repository = Repository(HttpService());
      var getUserDetails = await repository.fetchAllMySite({
        "userId": widget.userID,
      });
      final jsonData = jsonDecode(getUserDetails.body);
      print("jsonData$jsonData");

      if (jsonData['code'] == 200) {
        await payloadProvider.updateDashboardPayload(jsonData);
        setState(() {
          liveData = payloadProvider.dashboardLiveInstance!.data;
          configObjects = List<Map<String, dynamic>>.from(
              jsonData['data'][0]['master'][0]["config"]["configObject"]);
          uniqueObjectNames = configObjects
              .map((obj) => obj["objectName"] as String)
              .toSet()
              .toList();
          _controllers = configObjects
              .map((obj) => TextEditingController(text: obj["name"]?.toString() ?? ""))
              .toList();
        });
      }
      payloadProvider.httpError = false;
    } catch (e, stackTrace) {
      payloadProvider.httpError = true;
      print('Error overAll getData => ${e.toString()}');
      print('trace overAll getData  => $stackTrace');
    }
  }

  String getNameBySNo(double sNo) {
    for (var obj in configObjects) {
      if (obj['sNo'] == sNo) {
        return obj['name'] ?? "Not found";
      }
    }
    return "Not found";
  }

  void _updateName(int index, String newName) {
    setState(() {
      configObjects[index]["name"] = newName;
      _controllers[index].text = newName;
    });
  }

  Widget getTabBarViewWidget() {
    List<String> listOfCategory = uniqueObjectNames;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < listOfCategory.length; i++)
              InkWell(
                onTap: () {
                  setState(() {
                    selectedCategory = i;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: selectedCategory == i ? 12 : 10,
                  ),
                  decoration: BoxDecoration(
                    border: const Border(
                      top: BorderSide(width: 0.5),
                      left: BorderSide(width: 0.5),
                      right: BorderSide(width: 0.5),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                    color: selectedCategory == i
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                  ),
                  child: Text(
                    listOfCategory[i],
                    style: TextStyle(
                      color: selectedCategory == i ? Colors.white : Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
        Container(
          width: double.infinity,
          height: 3,
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget buildTab(int selectedTabIndex) {
    if (selectedTabIndex < 0 || selectedTabIndex >= uniqueObjectNames.length) {
      return const Center(child: Text('No category selected'));
    }

    final filteredData = configObjects
        .where((obj) => obj["objectName"] == uniqueObjectNames[selectedTabIndex])
        .toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(80),
            1: FixedColumnWidth(120),
            2: FlexColumnWidth(),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Colors.white),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'S.No',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Location',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            if (filteredData.isNotEmpty)
              ...filteredData.asMap().entries.map((entry) {
                int index = entry.key;
                var data = entry.value;
                Color rowColor = (index % 2 == 0) ? Colors.grey[100]! : Colors.white;
                int originalIndex = configObjects.indexOf(data);

                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children: [
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        data["sNo"].toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        getNameBySNo(data["location"]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: TextFormField(
                        controller: _controllers[originalIndex],
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s.]')),
                        ],
                        onChanged: (val) {
                          setState(() {
                            bool nameExists = configObjects.any((element) =>
                            element["name"] == val && element != data);
                            if (nameExists) {
                              showSnackBar(
                                  message: 'Name Already Exists', context: context);
                              _controllers[originalIndex].text = data["name"] ?? "";
                            } else if (val.length > 15) {
                              showSnackBar(
                                  message: 'Name length Maximum reached',
                                  context: context);
                            } else if (val.isNotEmpty) {
                              data["name"] = val;
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          getTabBarViewWidget(),
          Expanded(
            child: buildTab(selectedCategory),
          ),
        ],
      ),

    );
  }
}

// Utility function for showing snackbar (implement as needed)
void showSnackBar({required String message, required BuildContext context}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}
