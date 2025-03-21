import 'package:flutter/material.dart';

import '../../modules/irrigation_report/view/list_of_log_config.dart';
import '../../modules/irrigation_report/view/standalone_log.dart';

class IrrigationAndPumpLog extends StatefulWidget {
  final Map<String, dynamic> userData;
  const IrrigationAndPumpLog({super.key, required this.userData});

  @override
  State<IrrigationAndPumpLog> createState() => _IrrigationAndPumpLogState();
}

class _IrrigationAndPumpLogState extends State<IrrigationAndPumpLog> with TickerProviderStateMixin{
  late TabController tabController;
  List pumpList = [];
  String message = '';

  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 3, vsync: this);
    // getUserNodePumpList();
    super.initState();
  }

  // Future<void> getUserNodePumpList() async{
  //   Map<String, dynamic> userData = {
  //     "userId": widget.userId,
  //     "controllerId": widget.controllerId
  //   };
  //
  //   final result = await HttpService().postRequest('getUserNodePumpList', userData);
  //   setState(() {
  //     if(result.statusCode == 200 && jsonDecode(result.body)['data'] != null) {
  //       pumpList = jsonDecode(result.body)['data'];
  //     } else {
  //       message = jsonDecode(result.body)['message'];
  //     }
  //   });
  //   // print(result.body);
  // }

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
                      const Tab(text: "Irrigation Log",),
                      const Tab(text: "Standalone Log",),
                      if(pumpList.isNotEmpty)
                        const Tab(text: "Pump Log",)
                      else
                        Container()
                    ]
                ),
                // SizedBox(height: 10,),
                Expanded(
                    child: TabBarView(
                        children: [
                          ListOfLogConfig(userData: widget.userData,),
                          StandaloneLog(userData: widget.userData,),
                          Container(),
                          // if(pumpList.isNotEmpty)
                          //   PumpList(pumpList: pumpList, userId: widget.userId, controllerId: widget.controllerId,)
                          // else
                          //   Container()
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
