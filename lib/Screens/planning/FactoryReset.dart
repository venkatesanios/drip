import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../Models/reset_AccumalationModel.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../services/mqtt_service.dart';
import '../../utils/environment.dart';

class Reset_Accumalation extends StatefulWidget {
  const Reset_Accumalation(
      {Key? key,
        required this.userId,
        required this.controllerId,
        required this.deviceID});
  final userId, controllerId, deviceID;

  @override
  State<Reset_Accumalation> createState() => _Reset_AccumalationState();
}

class _Reset_AccumalationState extends State<Reset_Accumalation>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  ResetModel _resetModel = ResetModel();
  int tabclickindex = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
      try{
      final Repository repository = Repository(HttpService());
      var getUserDetails = await repository.getresetAccumulation({
        "userId": widget.userId,
        "controllerId": widget.controllerId
      });
       if (getUserDetails.statusCode == 200) {
        setState(() {
          var jsonData = jsonDecode(getUserDetails.body);
          _resetModel = ResetModel.fromJson(jsonData);
        });
      } else {
        //_showSnackBar(response.body);
      }
    }
    catch (e, stackTrace) {
       print(' Error overAll getData => ${e.toString()}');
      print(' trace overAll getData  => ${stackTrace}');
    }


  }
   createUserSentAndReceivedMessageManually(String hw) async {
    try{
      final Repository repository = Repository(HttpService());
      var getUserDetails = await repository.sendManualOperationToServer(
        {"userId": widget.userId, "controllerId": widget.controllerId, "messageStatus": "Factory Reset", "hardware": hw, "createUser": widget.userId}
      );

    }
    catch (e, stackTrace) {
      print(' Error overAll getData => ${e.toString()}');
      print(' trace overAll getData  => ${stackTrace}');
    }


  }




  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Factory Reset'),),
        body: Column(
          children: [
            _resetModel.code == 200 ? _resetModel.data!.accumulation!.isEmpty ? DefaultTabController(
              length: _resetModel.data!.accumulation!.length,
              child: Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 80, right: 8, top: 8),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          child: TabBar(
                            // controller: _tabController,
                            indicatorColor: const Color.fromARGB(255, 175, 73, 73),
                            isScrollable: true,
                            unselectedLabelColor: Colors.grey,
                            labelColor: Theme.of(context).primaryColor,
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                            tabs: [
                              for (var i = 0; i < _resetModel.data!.accumulation!.length; i++)
                                Tab(
                                  text: '${_resetModel.data!.accumulation![i].name}',
                                ),
                            ],
                            onTap: (value) {
                              setState(() {
                                tabclickindex = value;
                                changeval(value);
                              });
                            },
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(
                            //     color: myTheme.primaryColor, // Border color
                            //     // width: 10.0, // Border width
                            //   ),
                            // ),
                            // decoration: BoxDecoration(
                            //   color: Colors.white.withOpacity(0.1),
                            //   borderRadius: BorderRadius.circular(1.0),
                            //   boxShadow: [
                            //     BoxShadow(
                            //       color: Colors.blueGrey.shade100,
                            //       spreadRadius: 5,
                            //       blurRadius: 7,
                            //       offset: Offset(0, 3),
                            //     ),
                            //   ],
                            // ),
                            child: TabBarView(children: [
                              for (var i = 0; i < _resetModel.data!.accumulation!.length; i++)
                                buildTab(_resetModel.data!.accumulation![i].list)
                            ]),
                          ),
                        ),
                        ElevatedButton(
                          child: const Text("RESET ALL"),
                          onPressed: () async {
                            setState(() {
                              ResetAll();
                            });
                          },
                        ),
                        const SizedBox(height: 10,),
        
                      ],
                    ),
                  ),
                ),
              
            ) :   const Center(child: Text('Currently No data Available')): const Center(child: Text('Currently No data Available')),
            ElevatedButton(
              style: ButtonStyle(  backgroundColor: WidgetStateProperty.all(Colors.redAccent),),
              child: const Text("Factory Reset",style: TextStyle(color: Colors.white),),
              onPressed: () async {
                setState(() {
                  _showMyDialog(context);
                });
              },
            ),
          ],
        ),
      );

  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you want to Reset All data?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                FResetAll();
                Navigator.of(context).pop(); // Close the alert dialog
              },
            ),
          ],
        );
      },
    );
  }
  double Changesize(int? count, int val) {
    count ??= 0;
    double size = (count * val).toDouble();
    return size;
  }
  changeval(int Selectindexrow) {}
  Widget buildTab(List<ListElement>? Listofvalue,){
    return Container(
      child: DataTable2(
          headingRowColor: WidgetStateProperty.all<Color>(
              Theme.of(context).primaryColorDark.withOpacity(0.2)),
          // fixedCornerColor: myTheme.primaryColor,
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 600,
          // border: TableBorder.all(width: 0.5),
          // fixedColumnsColor: Colors.amber,
          headingRowHeight: 50,
          columns: const [
            DataColumn2(
              fixedWidth: 70,
              label: Center(
                  child: Text(
                    'Sno',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:  16,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  )),
            ),
            DataColumn2(
              label: Center(
                  child: Text(
                    'Name',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:  16,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  )),
            ),
            DataColumn2(
              fixedWidth: 150,
              label: Center(
                  child: Text(
                    'Daily Accumalation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  )),
            ),
            DataColumn2(
              fixedWidth: 150,
              label: Center(
                  child: Text(
                    'Total Accumalation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  )),
            ),
            DataColumn2(
              fixedWidth: 150,
              label: Center(
                  child: Text(
                    'Reset',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  )),
            ),
          ],
          rows: List<DataRow>.generate(Listofvalue!.length, (index) => DataRow(cells: [
            DataCell(Center(child: Text('${Listofvalue[index].sNo}'))),
            DataCell(Center(
              child: Text(
                '${Listofvalue[index].name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
            DataCell(Center(
              child: Text(
                '${Listofvalue[index].todayCumulativeFlow}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
            DataCell(Center(
              child: Text(
                '${Listofvalue[index].totalCumulativeFlow}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
            DataCell(
              Center(
                child: ElevatedButton(
                  style:  ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 18)),
                  onPressed: () { Reset(Listofvalue[index].sNo!);},
                  child: const Text('Reset'),
                ),
              ),
            ),]),
          )),
    );
    // }
  }

   updateradiationset() async {
    try{
      final Repository repository = Repository(HttpService());
      var getUserDetails = await repository.updateresetAccumulation({
        "userId": widget.userId,
        "controllerId": widget.controllerId,
        "modifyUser": widget.userId
      });
      print("getUserDetails.body ${getUserDetails.body}");

      // String payLoadFinal = jsonEncode({
      //   "2900": [
      //     {"2901": body},
      //   ]
      // });
      // MQTTManager().publish( payLoadFinal, 'AppToFirmware/${widget.deviceID}');
    }
    catch (e, stackTrace) {
      print(' Error overAll getData => ${e.toString()}');
      print(' trace overAll getData  => ${stackTrace}');
    }


  }


  Request(){
    String payLoadFinal = jsonEncode({
      "3000":
        {"3001": "#GETAACCUMALATION"},
    });
    MqttService().topicToPublishAndItsMessage(payLoadFinal, "${Environment.mqttPublishTopic}/${widget.deviceID}");

   }

  Reset(int Srno)   {
    String payLoadFinal = jsonEncode({
      "3100":
        {"3101": Srno},
    });
    MqttService().topicToPublishAndItsMessage(payLoadFinal, "${Environment.mqttPublishTopic}/${widget.deviceID}");
    createUserSentAndReceivedMessageManually(payLoadFinal);
  }
  ResetAll()   {
    String payLoadFinal = jsonEncode({
      "3100":
        {"3101": "RESETALL"},
    });
    MqttService().topicToPublishAndItsMessage(payLoadFinal, "${Environment.mqttPublishTopic}/${widget.deviceID}");
    createUserSentAndReceivedMessageManually(payLoadFinal);
  }
  FResetAll()   {
    String payLoadFinal = jsonEncode({
      "3200":
        {"3201": "FRESET"},
    });
    MqttService().topicToPublishAndItsMessage(payLoadFinal, "${Environment.mqttPublishTopic}/${widget.deviceID}");
    createUserSentAndReceivedMessageManually(payLoadFinal);
  }
}