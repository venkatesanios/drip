import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/irrigation_report/view/ec_25_log.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';

import '../../models/customer/site_model.dart';
import '../../modules/Logs/repository/log_repos.dart';
import '../../modules/Logs/view/pump_list.dart';
import '../../modules/irrigation_report/view/list_of_log_config.dart';
import '../../modules/irrigation_report/view/standalone_log.dart';
import '../../services/http_service.dart';

class IrrigationAndPumpLog extends StatefulWidget {
  final Map<String, dynamic> userData;
  final MasterControllerModel masterData;
  const IrrigationAndPumpLog({super.key, required this.userData, required this.masterData});

  @override
  State<IrrigationAndPumpLog> createState() => _IrrigationAndPumpLogState();
}

class _IrrigationAndPumpLogState extends State<IrrigationAndPumpLog> with TickerProviderStateMixin{
  late TabController tabController;
  List pumpList = [];
  String message = '';
  final LogRepository repository = LogRepository(HttpService());

  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 3, vsync: this);
    getUserNodePumpList();
    super.initState();
  }

  Future<void> getUserNodePumpList() async{
    final userData = {'userId' : widget.userData['customerId'], 'controllerId' :  widget.userData['controllerId']};
    print("userData in the getUserNodePumpList :: ${widget.userData}");
    final result = await repository.getUserNodePumpList(userData);
    setState(() {
      if(result.statusCode == 200 && jsonDecode(result.body)['data'] != null) {
        pumpList = jsonDecode(result.body)['data'];
      } else {
        message = jsonDecode(result.body)['message'];
      }
    });
    // print(result.body);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
            length: tabController.length,
            child: Column(
              children: [
                  TabBar(
                    tabs: [
                      if(AppConstants.ecoGemModelList.contains(widget.masterData.modelId))
                        ...[
                          const Tab(text: "Motor Cyclic Log",)
                        ]
                      else
                        ...[
                          const Tab(text: "Irrigation Log",),
                          const Tab(text: "Standalone Log",),
                        ],
                      if(!AppConstants.ecoGemModelList.contains(widget.masterData.modelId) ? pumpList.isNotEmpty : true)
                        const Tab(text: "Pump Log",)
                      else
                        Container()

                    ]
                ),
                // SizedBox(height: 10,),
                Expanded(
                    child: TabBarView(
                        children: [
                          if(AppConstants.ecoGemModelList.contains(widget.masterData.modelId))
                            Ec25Log(userData: widget.userData)
                          else
                            ...[
                              ListOfLogConfig(userData: widget.userData,),
                              StandaloneLog(userData: widget.userData,),
                            ],
                          if(!AppConstants.ecoGemModelList.contains(widget.masterData.modelId) ? pumpList.isNotEmpty : true)
                            PumpList(
                              pumpList: pumpList,
                              userId: widget.userData['customerId'],
                              masterData: widget.masterData,
                            )
                          else
                            Container()

                        ]
                    )
                )
              ],
            )
        )
      ),
    );
  }
}
