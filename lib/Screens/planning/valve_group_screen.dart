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
  final int userId;
  final int controllerId;
   final String deviceId;

  const GroupListScreen({super.key, required this.userId, required this.controllerId, required this.deviceId});
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

   deleteValveGroupAtIndex(int index) {
    if (_groupdata.data?.valveGroup != null &&
        index >= 0 &&
        index < _groupdata.data!.valveGroup!.length) {
      _groupdata.data!.valveGroup!.removeAt(index);
    } else {
      print("Invalid index or valveGroup is null.");
    }
  }

  Future<void> fetchData() async {
    print("fetch data Call");
    var overAllPvd = Provider.of<OverAllUse>(context, listen: false);

    Map<String, Object> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId
    };
    final Repository repository = Repository(HttpService());
    final response = await repository.getUserPlanningValveGroup(body);
    // print("response.body in the valve group ::: ${response.body}");
    if (response.statusCode == 200) {
      setState(() {
        var jsonData = jsonDecode(response.body);
        _groupdata = Groupdata.fromJson(jsonData);
      });
    } else {
      // _showSnackBar(response.body);
    }

  }
  createvalvegroup() async {
    print("createvalvegroup call");

    final Repository repository = Repository(HttpService());
    Map<String, dynamic> body = {
      "userId": widget.userId,
      "controllerId": widget.controllerId,
      "valveGroup":  _groupdata.data?.valveGroup!.map((x) => x.toJson()).toList() ?? [],
      "createUser": widget.userId
    };

    var getUserDetails = await repository.createUserValveGroup(body);
    var jsonDataResponse = jsonDecode(getUserDetails.body);
    print("jsonDataResponse$jsonDataResponse");
    GlobalSnackBar.show(context, jsonDataResponse['message'], jsonDataResponse['code']);
   if(jsonDataResponse['code'] == 200)
    {
       setState(() {
        fetchData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider =
        Provider.of<MqttPayloadProvider>(context, listen: true);
    if (_groupdata.data != null) {
      // print('print(_groupdata.data?.valveGroup?.length):${_groupdata.data!.valveGroup!.length}');
      // print('print(_groupdata.data?.irrigationLine?.length):${_groupdata.data!.defaultData.irrigationLine.length}');
    }

    return Scaffold(
      backgroundColor: const Color(0xffE6EDF5),
      appBar: AppBar(
        title: const Text('Groups',
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
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${_groupdata.data?.valveGroup?[index].irrigationLineName}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text("Valves List:"),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      spacing: 5.0,
                                      runSpacing: 10.0,
                                      children: List.generate(
                                          _groupdata.data?.valveGroup![index].valve.length ?? 0,
                                              (vindex) {
                                            return Chip(
                                              label: Text(
                                                  '${_groupdata.data?.valveGroup![index].valve[vindex].name}'),
                                              backgroundColor: Colors.blueAccent,
                                            );
                                          }),
                                    ),
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
                                    icon: const Icon(Icons
                                        .delete), // The icon you want to display
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Delete Valve Group'),
                                            content: const Text(
                                                'Are you sure you want to delete this valve group?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  await deleteValveGroupAtIndex(index);
                                                   createvalvegroup();
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }),
                                const SizedBox(
                                  height: 5,
                                ),
                                IconButton(
                                  icon: const Icon(Icons
                                      .edit_note_rounded,), // The icon you want to display
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditValveGroup(
                                      selectedline: '${_groupdata.data?.valveGroup![index].irrigationLineName}',
                                      valveGroupdata: _groupdata.data?.valveGroup!,
                                      editcheck: true,
                                      selectedgroupindex: index,
                                      groupdata: _groupdata.data!,
                                      userId: widget.userId,
                                      controllerId: widget.controllerId,
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

               if(_groupdata.data!.defaultData.valveGroupLimit > 0 && _groupdata.data!.valveGroup!.length < _groupdata.data!.defaultData.valveGroupLimit) {
                 Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    AddEditValveGroup(
                      editcheck: false, groupdata: _groupdata.data!,userId: widget.userId,controllerId: widget.controllerId,valveGroupdata: _groupdata.data?.valveGroup,)));
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
            onPressed: () {
              createvalvegroup();
            },
            child: const Icon(Icons.send,color: Colors.white,),
          ),
        ],
      ),
      // ),
    );
  }
}


