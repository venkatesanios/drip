import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../Models/names_model.dart';
import '../../StateManagement/overall_use.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/snack_bar.dart';
import '../NewIrrigationProgram/program_library.dart';


class Names extends StatefulWidget {
  final int userID, customerID, controllerId;

  Names({
    required this.userID,
    required this.customerID,
    required this.controllerId,
  });

  @override
  _NamesState createState() => _NamesState();
}

class _NamesState extends State<Names> {
    NamesConfigModel configModel = NamesConfigModel();
  List<String> uniqueObjectNames = [];
    var liveData;

  void getData() async {
     try {
      final Repository repository = Repository(HttpService());
      var getUserDetails = await repository.getUserConfigMaker({
        "userId": widget.userID ?? 4,
        "controllerId" : widget.controllerId ??1
      });
      {

  }

      final jsonData = jsonDecode(getUserDetails.body);
      if (jsonData['code'] == 200) {
         setState(() {
          configModel = NamesConfigModel.fromJson(
            jsonData['data'],
          );
          uniqueObjectNames = (configModel.configObject ?? [])
              .map((obj) => obj.objectName ?? '')
              .toSet()
              .toList();

        });
      }
     } catch (e, stackTrace) {
       print('Error overAll getData => ${e.toString()}');
      print('trace overAll getData  => ${stackTrace}');
    }
  }
  @override
  void initState() {
    super.initState();
     getData();
  }


  Widget buildTab(String objectName) {
    final filteredData = (configModel.configObject ?? [])
        .where((obj) => obj.objectName == objectName)
        .toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FixedColumnWidth(80),
            1: FixedColumnWidth(120),
            2: FlexColumnWidth(),
          },
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Colors.blueGrey),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'S.No',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Location',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            ...List<TableRow>.generate(
              filteredData.length,
                  (index) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        filteredData[index].sNo.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        configModel.getNameBySNo(filteredData[index].location ?? 0.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: TextFormField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s.]')),
                        ],
                        initialValue: filteredData[index].name,
                        onChanged: (val) {
                          setState(() {
                            bool nameExists = false;
                            for (var element in configModel.configObject ?? []) {
                              if (element.name == val && element != filteredData[index]) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Name Already Exists')),
                                );
                                nameExists = true;
                                break;
                              }
                            }
                            if (val.length > 15) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Name length Maximum reached')),
                              );
                            }
                            if (!nameExists && val.isNotEmpty) {
                              filteredData[index].name = val;
                             }
                          });
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void updateAllNames() {
    print("configNames");
    Map<double, String> configNames = {};
    for (var obj in configModel.configObject ?? []) {
      if (obj.sNo != null && obj.name != null) {
        configNames[obj.sNo!] = obj.name!;
      }
    }
    print("waterSource");
    for (var src in configModel.waterSource ?? []) {
      if (configNames.containsKey(src.commonDetails.sNo)) {
        src.commonDetails.name = configNames[src.commonDetails.sNo];
      }
    }
    print("pump");
    for (var pump in configModel.pump ?? []) {
      if (configNames.containsKey(pump.commonDetails.sNo)) {
        pump.commonDetails.name = configNames[pump.commonDetails.sNo];
      }
    }
    print("filterSite");
    for (var filterSite in configModel.filterSite ?? []) {
      if (configNames.containsKey(filterSite.commonDetails.sNo)) {
        filterSite.commonDetails.name = configNames[filterSite.commonDetails.sNo];
      }
    }
    print("fertilizerSite");

    for (var fertSite in configModel.fertilizerSite ?? []) {
      if (configNames.containsKey(fertSite.commonDetails.sNo)) {
        fertSite.commonDetails.name = configNames[fertSite.commonDetails.sNo];
      }
    }
    print("moistureSensor");
    for (var moisture in configModel.moistureSensor ?? []) {
      if (configNames.containsKey(moisture.commonDetails.sNo)) {
        moisture.commonDetails.name = configNames[moisture.commonDetails.sNo];
      }
    }
    print("irrigationLine");
    for (var line in configModel.irrigationLine ?? []) {
      if (configNames.containsKey(line.commonDetails.sNo)) {
        line.commonDetails.name = configNames[line.commonDetails.sNo];
      }
    }

    setState(() {}); // Trigger UI update
  }

  @override
  Widget build(BuildContext context) {
    if (configModel == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: uniqueObjectNames.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Names'),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Theme.of(context).primaryColorDark,
            isScrollable: true,
            tabs: uniqueObjectNames.map((name) => Tab(text: name)).toList(),
          ),
        ),
        body: TabBarView(
          children: uniqueObjectNames.map((name) {
            return (configModel.configObject ?? []).any((obj) => obj.objectName == name)
                ? buildTab(name)
                : const Center(child: Text('No Record found'));
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColorDark,
          foregroundColor: Colors.white,
          onPressed: ()  {
            setState(()  {
               updateAllNames();
                updateUserNames();

            });
          },
          tooltip: 'Send',
          child: const Icon(Icons.send),
        ),
      ),
    );
  }
    updateUserNames() async {
      var overAllPvd = Provider.of<OverAllUse>(context,listen: false);
       Map<String, dynamic> namesmodeldata =
      configModel.toJson();


      final Repository repository = Repository(HttpService());

      Map<String, dynamic> body = {
        "userId": overAllPvd.takeSharedUserId ? overAllPvd.sharedUserId : widget.userID,
        "controllerId": widget.controllerId,
        "configObject": namesmodeldata['configObject'],
        "waterSource":namesmodeldata['waterSource'],
        "pump": namesmodeldata['pump'],
        "filterSite": namesmodeldata['filterSite'],
        "fertilizerSite": namesmodeldata['fertilizerSite'],
        "irrigationLine": namesmodeldata['irrigationLine'],
        "moistureSensor": namesmodeldata['moistureSensor'],
        "createUser": widget.userID
      };
      var getUserDetails = await repository.updateUserNames(body);
      final jsonDataResponseput = json.decode(getUserDetails.body);
       GlobalSnackBar.show(
          context, jsonDataResponseput['message'], jsonDataResponseput['code']);


    }

}