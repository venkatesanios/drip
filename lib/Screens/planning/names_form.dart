import 'dart:convert';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../../Models/customer/site_model.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../StateManagement/overall_use.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';


class Names extends StatefulWidget {
  const Names({
    Key? key,
    required this.userID,
    required this.customerID,
    required this.controllerId,
    required this.imeiNo,
    required this.menuId,

  });
  final int userID, customerID, controllerId, menuId;
  final String imeiNo;


  @override
  State<Names> createState() => _NamesState();
}

class _NamesState extends State<Names> with TickerProviderStateMixin {
   late OverAllUse overAllPvd;
  late MqttPayloadProvider payloadProvider;
  late Map<int, List<ConfigObjectnames>> groupedByObjectId;


  @override
  void initState() {
    super.initState();
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    getData();
  }

  @override
  Widget build(BuildContext context) {
    payloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);

    // print('User ID:${widget.userID}');
    // print('controllerId ID:${widget.controllerId}');
    // print('customerID ID:${widget.customerID}');
    // //print(_namesList);

    return MyContainerWithTabs(
      names: _namesList,
      userID: widget.userID,
      controllerId: widget.controllerId,
      customerID: widget.customerID,
      imeiNo: widget.imeiNo,
      menuId: widget.menuId,
    );
  }

   void getData() async {
     print("getData");

    try
    {
      final Repository repository = Repository(HttpService());
      var getUserDetails = await repository.fetchAllMySite({
        "userId": 4,
      });

      final jsonData = jsonDecode(getUserDetails.body);
      print("jason data---: $jsonData");
      if (jsonData['code'] == 200) {
        await ConfigObjectnames(jsonData);

        groupedByObjectId = {};
        // List<dynamic> configList =  payloadProvider.dashboardLiveInstance!.data  payloadProvider.lineData

        jsonData['configObject'];

        List<ConfigObject> configObjects =
        configList.map((json) => ConfigObject.fromJson(json)).toList();
        for (var obj in configObjects) {
          groupedByObjectId.putIfAbsent(obj.objectId, () => []).add(obj);
        }
      }

     } catch (e, stackTrace) {
      
    }
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class MyContainerWithTabs extends StatefulWidget {
  const MyContainerWithTabs(
      {super.key,
        required this.names,
        required this.userID,
        required this.customerID,
        required this.controllerId,
        required this.imeiNo,
        required this.menuId,
      });
  final List<NamesModel> names;
  final int userID, customerID, controllerId, menuId;
  final String imeiNo;

  @override
  State<MyContainerWithTabs> createState() => _MyContainerWithTabsState();
}

class _MyContainerWithTabsState extends State<MyContainerWithTabs> {
  final TextEditingController _textController = TextEditingController();
  late MqttPayloadProvider mqttPayloadProvider;

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Names", style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.bold)),automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: DefaultTabController(
                length: widget.names.length, // Number of tabs
                child: Column(
                  children: [
                    Container(
                      color:  Theme.of(context).primaryColorDark,
                      // padding: const EdgeInsets.only(right: 10, left: 10),
                      child: TabBar(
                        indicatorColor: Colors.white,
                        tabAlignment: TabAlignment.start,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal,color: Colors.grey.shade400),
                        isScrollable: true,
                        tabs: [
                          for (var i = 0; i < widget.names.length; i++)
                            Tab(
                              text: widget.names[i].nameDescription ?? '',
                            ),
                        ],
                        onTap: (value) {},
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Expanded(
                      flex: 1,
                      child: TabBarView(
                        // physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          for (int i = 0; i < widget.names.length; i++)
                            widget.names[i].userName != null &&
                                widget.names.isNotEmpty
                                ? buildTab(widget.names[i].userName!)
                                : const Center(child: Text('No Record found')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                      onPressed: () async {
                        String Mqttsenddata = toMqttformat(widget.names);
                        List<Map<String, dynamic>> nameListJson = widget.names.map((name) => name.toJson()).toList();
                        Map<String, dynamic> body = {
                          "userId": widget.customerID,
                          "controllerId": widget.controllerId,
                          "userNameList": nameListJson,
                          "hardware": jsonDecode(Mqttsenddata),
                          "createUser": widget.customerID,
                          "controllerReadStatus": "0"
                        };
                        await validatePayloadSent(
                            dialogContext: context,
                            context: context,
                            mqttPayloadProvider: mqttPayloadProvider,
                            acknowledgedFunction: (){
                              setState(() {
                                body["controllerReadStatus"] = "1";
                              });
                            },
                            payload: jsonDecode(Mqttsenddata),
                            payloadCode: '3100',
                            deviceId: widget.imeiNo
                        );
                        final response = await HttpService().postRequest("createUserName", body);
                        if (response.statusCode == 200) {
                          var data = jsonDecode(response.body);
                          if (data["code"] == 200) {
                            _showSnackBar(data["message"]);
                          } else {
                            _showSnackBar(data["message"]);
                          }
                        }
                        showNavigationDialog(context: context, menuId: widget.menuId, ack: body["controllerReadStatus"] == "1");
                        // MQTTManager().publish(Mqttsenddata, 'AppToFirmware/${widget.imeiNo}');
                      },
                      label: Text('Save'),
                      icon: const Icon(
                        Icons.save_as_outlined,
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                             Theme.of(context).primaryColorDark,
                          ),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white))),
                  const SizedBox(
                    width: 20,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildTab(List<UserName> nameList) {
    // print('buildTab');

    // List<UserName> dropirrigationline = widget._names[2].userName!;
    List<UserName> dropirrigationline = widget.names.isNotEmpty
        ? widget.names.length > 2
        ? widget.names[2].userName!
        : []
        : [];

    // print("UserName    --->  ${dropirrigationline.toString()}");
    if (nameList.isNotEmpty) {
      String? selectedUserName = nameList[0].location != ''
          ? nameList[0].location
          : dropirrigationline.isNotEmpty
          ? dropirrigationline[0].name
          : '';
      // if (nameList[0].location == '' || nameList[0].location != '') {
      return Padding(
        padding: const EdgeInsets.only(right: 10, left: 10),
        child: DataTable2(
            dataRowColor: MaterialStateProperty.all<Color>(Colors.white),
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 620,
            headingRowHeight: 40,
            dataRowHeight: 40,
            fixedLeftColumns: 1,
            headingRowColor: MaterialStateProperty.all<Color>( Theme.of(context).primaryColorDark),
            border: TableBorder.all(width: 1),
            columns: const [
              DataColumn2(
                  label: Text(
                    'S.No',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  size: ColumnSize.S),
              DataColumn2(
                  label: Text(
                    'Id',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  size: ColumnSize.M),
              DataColumn2(
                  label: Text(
                    'Location',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  size: ColumnSize.L),
              DataColumn2(
                  label: Text(
                    'Name',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  size: ColumnSize.L),
            ],
            rows: List<DataRow>.generate(
                nameList.length,
                    (index) => DataRow(cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(nameList[index].id!)),
                  (nameList[index].id!.contains('IL') == true ||
                      nameList[index].id!.contains('VLG') == true ||
                      nameList[index].id!.contains('MB.') == true ||
                      nameList[index].id!.contains('COND') == true ||
                      nameList[index].location != '' ||
                      dropirrigationline.isEmpty)
                      ? DataCell(Text(nameList[index].location!))
                      : DataCell(
                    DropdownButton<String>(
                      value: nameList[index].location != ''
                          ? nameList[index].location
                          : dropirrigationline[0].name,
                      hint: Text('Select User Name'),
                      items: dropirrigationline.map((UserName user) {
                        return DropdownMenuItem<String>(
                          value: user.name ?? '',
                          child: Text(user.name ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUserName = newValue;
                          nameList[index].location =
                              findhid(newValue!, dropirrigationline);
                        });
                      },
                    ),
                  ),
                  DataCell(
                    TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(15),
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s.]'))
                      ],
                      initialValue: nameList[index].name,
                      onChanged: (val) {
                        setState(() {
                          for (var element in nameList) {
                            if (element.name == val) {
                              _showSnackBar("Name Already Exists");
                              break;
                            } else {
                              nameList[index].name = val;
                              break;
                            }
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ]))),
      );
    } else {
      return const Center(child: Text('No Record found'));
    }
  }



  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  String findhid(String searchString, List<UserName> irrigationLines) {
    for (var irrigationLine in irrigationLines) {
      if (irrigationLine.name == searchString) {
        return irrigationLine.hid!;
      }
    }
    return '0';
  }

  String toMqttformat(
      List<NamesModel> data,
      ) {
    int srnorunning = 0;
    String Pump = '';
    String IrrigationLine = '';
    String Object = '';
    String GroupLibrary = '';
    String FertilizationSet = '';
    String Program = '';
    String SatelliteOperation = '';
    String VirtualWaterMeter = '';
    String ProgramCondition = '';
    String WaterSources = '';
    String Alarm = '';
    String Filter = '';
    String Fertilizer = '';
    List<UserName> cfsite = [];
    List<UserName> cfinjector = [];
    List<UserName> lfsite = [];
    List<UserName> lfinjector = [];
    for (var i = 0; i < data!.length; i++) {
      int nameTypeId = data[i].nameTypeId!;
      List userName = data[i].userName!;
      if (nameTypeId == 7) {
        cfsite = data[i].userName!;
      } else if (nameTypeId == 8) {
        cfinjector = data[i].userName!;
      } else if (nameTypeId == 13) {
        lfinjector = data[i].userName!;
      } else if (nameTypeId == 3) {
        lfsite = data[i].userName!;
      }
    }

    for (var i = 0; i < data!.length; i++) {
      int nameTypeId = data[i].nameTypeId!;
      List<UserName> userName = data[i].userName!;

      if (nameTypeId == 1 || nameTypeId == 2) {
        //Pump
        for (var j = 0; j < userName.length; j++) {
          srnorunning += 1;
          dynamic Usno = userName[j].sNo;
          String Uname = userName[j].name!;
          String location = userName[j].location!;
          Pump += '${Usno},${Uname};';
        }
      } else if (nameTypeId == 3) {
//IrrigationLine
        for (var j = 0; j < userName.length; j++) {
          srnorunning += 1;
          dynamic Usno = userName[j].sNo;
          String Uname = userName[j].name!;
          IrrigationLine += '${Usno},${Uname};';
        }
      } else if (nameTypeId == 4 ||
          nameTypeId == 5 ||
          nameTypeId == 9 ||
          nameTypeId == 12 ||
          nameTypeId == 14 ||
          nameTypeId == 16 ||
          nameTypeId == 18 ||
          nameTypeId == 19 ||
          nameTypeId == 20 ||
          nameTypeId == 21 ||
          nameTypeId == 22 ||
          nameTypeId == 23 ||
          nameTypeId == 25 ||
          nameTypeId == 28 ||
          nameTypeId == 30 ||
          nameTypeId == 31 ||
          nameTypeId == 32 ||
          nameTypeId == 33 ||
          nameTypeId == 35 ||
          nameTypeId == 36 ||
          nameTypeId == 39 ||
          nameTypeId == 52 ||
          nameTypeId == 53) {
        for (var j = 0; j < userName.length; j++) {
          srnorunning += 1;
          dynamic Usno = userName[j].sNo;
          String Uname = userName[j].name!;
          String location = userName[j].location!;
          Object += '${Usno},${Uname},$location;';
        }
//Object
      } else if (nameTypeId == 6) {
        for (var j = 0; j < userName.length; j++) {
          srnorunning += 1;
          dynamic Usno = userName[j].sNo;
          String Uname = userName[j].name!;
          String location = userName[j].location!;
          GroupLibrary += '${Usno}.${srnorunning},${Uname};';
        }
//GroupLibrary
      } else if (nameTypeId == 10 || nameTypeId == 15) {
//FertilizationSet
        for (var j = 0; j < userName.length; j++) {
          srnorunning += 1;
          dynamic Usno = userName[j].sNo;
          String Uname = userName[j].name!;
          String location = userName[j].location!;
          FertilizationSet += '${Usno},${Uname};';
        }
      } else if (nameTypeId == 17) {
//Program
        for (var j = 0; j < userName.length; j++) {
          srnorunning += 1;
          dynamic Usno = userName[j].sNo;
          String Uname = userName[j].name!;
          Program += '${Usno},${Uname};';
        }
      } else if (nameTypeId == 24) {
//SatelliteOperation
        for (var j = 0; j < userName.length; j++) {
          srnorunning += 1;
          dynamic Usno = userName[j].sNo;
          String Uname = userName[j].name!;
          SatelliteOperation += '${Usno},${Uname};';
        }
      } else if (nameTypeId == 26) {
//VirtualWaterMeter
        for (var j = 0; j < userName.length; j++) {
          srnorunning += 1;
          dynamic Usno = userName[j].sNo;
          String Uname = userName[j].name!;
          VirtualWaterMeter += '${Usno}.${srnorunning},${Uname};';
        }
      } else if (nameTypeId == 29 || nameTypeId == 37 || nameTypeId == 38) {
//ProgramCondition
        for (var j = 0; j < userName.length; j++) {
          srnorunning += 1;
          dynamic Usno = userName[j].sNo;
          String Uname = userName[j].name!;
          ProgramCondition += '${Usno},${Uname};';
        }
      } else if (nameTypeId == 34) {
//WaterSources
        for (var j = 0; j < userName.length; j++) {
          srnorunning += 1;
          dynamic Usno = userName[j].sNo;
          String Uname = userName[j].name!;
          WaterSources += '${Usno},${Uname};';
        }
      } else if (nameTypeId == 27) {
//Alarm
        for (var j = 0; j < userName.length; j++) {
          srnorunning += 1;
          dynamic Usno = userName[j].sNo;
          String Uname = userName[j].name!;
          Alarm += '${Usno},${Uname};';
        }
      } else if (nameTypeId == 11) {
//Filter
        for (var j = 0; j < userName.length; j++) {
          srnorunning += 1;
          dynamic Usno = userName[j].sNo;
          String Uname = userName[j].name!;
          String location = userName[j].location!;
          Filter += '${Usno},${Uname};';
        }
      } else if (nameTypeId == 7 || nameTypeId == 8 || nameTypeId == 13)
      {
        if (nameTypeId == 8) {
          for (var cf = 0; cf < cfinjector.length; cf++) {
            String cfname = '';
            String locationid = '';
            int sitesno = cfinjector[cf].sNo;
            String sitename = cfinjector[cf].name!;
            String location = cfinjector[cf].location!;
            for (var j = 0; j < cfsite.length; j++) {
              cfname = cfsite[j].name!;
              locationid = cfsite[j].id!;
              if (locationid == location) {
                //sitename
                Fertilizer += '${sitesno},${cfname},${sitename};';
              }
            }
          }
        }
        if (nameTypeId == 13) {
          for (var cf = 0; cf < lfinjector.length; cf++) {
            int cfsno = lfinjector[cf].sNo;
            String cfname = lfinjector[cf].name!;
            String sitename = '';
            Fertilizer += '${cfsno},${sitename},${cfname};';
          }
        }
      } else {
        // print('$nameTypeId');
      }
    }
    String payLoadFinal = jsonEncode({
      "3100": [
        {"3101": Pump},
        {"3102": IrrigationLine},
        {"3103": Object},
        {"3104": ''},
        {"3105": FertilizationSet},
        {"3106": Program},
        {"3107": SatelliteOperation},
        {"3108": VirtualWaterMeter},
        {"3109": ProgramCondition},
        {"3110": WaterSources},
        {"3111": Alarm},
        {"3112": Filter},
        {"3113": Fertilizer},
      ]
    });
    // // print('payLoadFinal:$payLoadFinal');
    return payLoadFinal;
  }
}

class ConfigObjectnames {
  final int objectId;
  final double sNo;
  final String name;
  final int? connectionNo;
  final String objectName;
  final String type;
  final int? controllerId;
  final int? count;
  final String? connectedObject;
  final String? siteMode;

  ConfigObjectnames({
    required this.objectId,
    required this.sNo,
    required this.name,
    this.connectionNo,
    required this.objectName,
    required this.type,
    this.controllerId,
    this.count,
    this.connectedObject,
    this.siteMode,
  });

  factory ConfigObjectnames.fromJson(Map<String, dynamic> json) {
    return ConfigObjectnames(
      objectId: json['objectId'],
      sNo: json['sNo'],
      name: json['name'],
      connectionNo: json['connectionNo'],
      objectName: json['objectName'],
      type: json['type'],
      controllerId: json['controllerId'],
      count: json['count'],
      connectedObject: json['connectedObject'],
      siteMode: json['siteMode'],
    );
  }
}