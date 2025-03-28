import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/Logs/view/hourly_data.dart';
import 'package:oro_drip_irrigation/modules/Logs/view/pump_log.dart';
import 'package:oro_drip_irrigation/modules/Logs/view/voltage_log.dart';

class PumpLogsHome extends StatefulWidget {
  final int userId, controllerId;
  const PumpLogsHome({super.key, required this.userId, required this.controllerId});

  @override
  State<PumpLogsHome> createState() => _PumpLogsHomeState();
}

class _PumpLogsHomeState extends State<PumpLogsHome> with TickerProviderStateMixin{
  late TabController tabController;

  @override
  void initState() {
    // TODO: implement initState
    tabController = TabController(length: 3, vsync: this);
    super.initState();
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
                        Tab(text: "Pump log",),
                        Tab(text: "Power graph",),
                        Tab(text: "Voltage Log",),
                      ]
                  ),
                  // SizedBox(height: 10,),
                  Expanded(
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                          children: [
                            PumpLogScreen(userId: widget.userId, controllerId: widget.controllerId),
                            PumpHourlyLog(userId: widget.userId, controllerId: widget.controllerId),
                            PumpVoltageLogScreen(userId: widget.userId, controllerId: widget.controllerId),
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
