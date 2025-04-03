import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../StateManagement/mqtt_payload_provider.dart';
import '../../StateManagement/overall_use.dart';
import '../../modules/IrrigationProgram/view/program_library.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';

// Model class (as defined above)
 class Names extends StatefulWidget {
  final int userID, customerID, controllerId, menuId;
  final String imeiNo;
  Names({required this.userID, required this.customerID, required this.controllerId, required this.menuId, required this.imeiNo});

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

  void getData() async {
     print("getData");
    try
    {
      final Repository repository = Repository(HttpService());
      var getUserDetails = await repository.fetchAllMySite({
        "userId": widget.userID ?? 4,
      });
      final jsonData = jsonDecode(getUserDetails.body);
      print("jsonData$jsonData");

      if (jsonData['code'] == 200) {

        await payloadProvider.updateDashboardPayload(jsonData);
        setState(() {
          liveData = payloadProvider.dashboardLiveInstance!.data;
          configObjects = List<Map<String, dynamic>>.from(jsonData['data'][0]['master'][0]["config"]["configObject"]);
          uniqueObjectNames = configObjects.map((obj) => obj["objectName"] as String).toSet().toList();
          });
       }
      payloadProvider.httpError = false;
    } catch (e, stackTrace) {
      payloadProvider.httpError = true;
      print(' Error overAll getData => ${e.toString()}');
      print(' trace overAll getData  => ${stackTrace}');
    }
  }


  @override
  void initState() {
    super.initState();
    // Parse JSON into ConfigObject list
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);

    getData();

  }
  String getNameBySNo(double sNo) {
    for (var obj in configObjects) {
      if (obj['sNo'] == sNo) {
        return obj['name'];
      }
    }
    return "Not found";
  }

  void _updateName(int index, String newName) {
    setState(() {
      configObjects[index]["name"] = newName;
    });
  }

  Widget buildTab(String objectName) {
    final filteredData = configObjects.where((obj) => obj["objectName"] == objectName).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          // border: TableBorder.all(color: Colors.grey),
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
            ...List<TableRow>.generate(
              filteredData.length,
                  (index) {
                // Determine the row background color
                Color rowColor = (index % 2 == 0) ? Colors.grey[100]! : Colors.white;

                return TableRow(
                  decoration: BoxDecoration(
                    color: rowColor, // Set background color for the row
                  ),
                  children: [
                    // Adjust row height by using Container with fixed height
                    Container(
                      height: 50, // Set the height of the row
                      alignment: Alignment.center,
                      child: Text(
                        // "${index+1}",
                       filteredData[index]["sNo"].toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: 50, // Set the height of the row
                      alignment: Alignment.center,
                      child: Text(
                        getNameBySNo(filteredData[index]["location"]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      height: 50, // Set the height of the row
                      alignment: Alignment.center,
                      child: TextFormField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s.]')),
                        ],
                        initialValue: filteredData[index]["name"],
                        onChanged: (val) {
                          setState(() {
                            bool nameExists = false;
                            for (var element in configObjects) {
                              if (element["name"] == val && element != filteredData[index]) {
                                showSnackBar(message: 'Name Already Exists', context: context);
                                nameExists = true;
                                break;
                              }
                            }
                            if (val.length > 15) {
                              showSnackBar(message: 'Name length Maximum reached', context: context);
                            }

                            if (!nameExists && val.isNotEmpty) {
                              filteredData[index]["name"] = val;
                            }

                            _updateName(index, val);
                          });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: uniqueObjectNames.length,
      child: Scaffold(
         body: Column(
          children: [
            Container(
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Theme.of(context).primaryColor,
                indicatorColor: Colors.white,
                isScrollable: true,
                // indicatorPadding: const EdgeInsets.only(left: -10, top: 0, right: -10, bottom: 0),
                indicator: BoxDecoration(color: Theme.of(context).primaryColor ,border: Border.all(),
                  borderRadius: BorderRadius.circular(5),) ,
                // dividerColor: Colors.grey,
                 tabs: uniqueObjectNames.map((name) => Container(height: 40,
                     padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                     decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(5),
                   border: Border.all()
                  ),child: Tab(text: name))).toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: uniqueObjectNames.map((name) {
                  return configObjects.any((obj) => obj["objectName"] == name)
                      ? buildTab(name)
                      : const Center(child: Text('No Record found'));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
