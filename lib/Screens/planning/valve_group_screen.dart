import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
import '../../Models/valve_group_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../StateManagement/overall_use.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/snack_bar.dart';
import '../../modules/IrrigationProgram/view/preview_screen.dart';
import 'add_edit_group.dart';

class GroupListScreen extends StatefulWidget {
  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  late MqttPayloadProvider mqttPayloadProvider;
  Groupdata _groupdata = Groupdata();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: false);
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchData();
      });
    }
  }

  void deleteValveGroupAtIndex(int index) {
    if (_groupdata.data?.valveGroup != null &&
        index >= 0 &&
        index < _groupdata.data!.valveGroup!.length) {
      _groupdata.data!.valveGroup!.removeAt(index);
    } else {
      print("Invalid index or valveGroup is null.");
    }
  }

  Future<void> fetchData() async {
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);

    Map<String, Object> body = {
      "userId": overAllPvd.takeSharedUserId
          ? overAllPvd.sharedUserId
          : overAllPvd.userId,
      "controllerId": overAllPvd.controllerId
    };
    final Repository repository = Repository(HttpService());
    final response = await repository.getUserPlanningValveGroup(body);
    print("response.body in the valve group ::: ${response.body}");
    if (response.statusCode == 200) {
      setState(() {

        var jsonData = jsonDecode(response.body);
        _groupdata = Groupdata.fromJson(jsonData);
      });
    } else {
      // _showSnackBar(response.body);
    }

  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);
    if (_groupdata.data != null) {
      print('print(_groupdata.data?.valveGroup?.length):${_groupdata.data!.valveGroup!.length}');
      print('print(_groupdata.data?.irrigationLine?.length):${_groupdata.data!.defaultData.irrigationLine.length}');
    }

    return Scaffold(
      backgroundColor: Color(0xffE6EDF5),
      appBar: AppBar(
        title: Text('Groups',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: ListView.builder(
                  itemCount:
                  _groupdata.data?.valveGroup!.length ?? 0, // _groupdata.data?.valveGroup?.length, // Number of items
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: customBoxShadow,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    "${_groupdata.data?.valveGroup?[index].groupName}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${_groupdata.data?.valveGroup?[index].irrigationLineName}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("Valves List:"),
                                  Wrap(
                                    spacing: 5.0,
                                    runSpacing: 10.0,
                                    children: List.generate(
                                        3 /*_groupdata.data?.valveGroup![index].valve.length ?? 0*/,
                                            (vindex) {
                                          return Chip(
                                            label: Text(
                                                '${_groupdata.data?.valveGroup![index].valve[vindex].name}'),
                                            backgroundColor: Colors.blueAccent,
                                          );
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .start, // Centers the children vertically
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                    icon: Icon(Icons
                                        .delete), // The icon you want to display
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Delete Valve Group'),
                                            content: Text(
                                                'Are you sure you want to delete this valve group?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  deleteValveGroupAtIndex(index);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }),
                                SizedBox(
                                  height: 5,
                                ),
                                IconButton(
                                  icon: Icon(Icons
                                      .edit_note_rounded,color: Colors.white,), // The icon you want to display
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditValveGroup(
                                      selectedline: '${_groupdata.data?.valveGroup![index].irrigationLineName}',
                                      valveGroupdata: _groupdata.data?.valveGroup![index],
                                      editcheck: true,
                                      selectedgroupindex: index,
                                      groupdata: _groupdata.data!,
                                    )));
                                    print('Icon Button Pressed');
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )),
            const SizedBox(
              height: 10,
            ),
            //Show Lines and selection valve
          ],
        ),
      ),
      floatingActionButton: Row(
        children: [
          const Spacer(),
          ElevatedButton(
            // backgroundColor: Theme.of(context).primaryColor,
            // foregroundColor: Colors.white,
            child: const Icon(Icons.add,color: Colors.white,),
            onPressed: () {
              if(_groupdata.data!.defaultData.valveGroupLimit < 0 && _groupdata.data!.valveGroup!.length > _groupdata.data!.defaultData.valveGroupLimit) {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    AddEditValveGroup(
                      editcheck: false, groupdata: _groupdata.data!,)));
              }
              else
    {
    GlobalSnackBar.show(
    context, "Valve group limit is reached", 201);
    }
    }

          ),
          const SizedBox(
            width: 10,
          ),
          //ToDo: Delete Button
          const SizedBox(
            width: 10,
          ),
          //ToDo: Send button
          ElevatedButton(
            // backgroundColor: Theme.of(context).primaryColor,
            // foregroundColor: Colors.white,
            onPressed: () {},
            child: const Icon(Icons.send,color: Colors.white,),
          ),
        ],
      ),
      // ),
    );
  }
}


