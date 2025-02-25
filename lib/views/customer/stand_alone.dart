import 'package:flutter/material.dart';

class StandAlone extends StatefulWidget {
  const StandAlone({super.key, required this.customerID, required this.siteID, required this.controllerID, required this.userId, required this.siteName, required this.imeiNo, required this.callbackFunction});

  final int customerID, siteID, controllerID, userId;
  final String siteName, imeiNo;
  final void Function(String msg) callbackFunction;

  @override
  State<StandAlone> createState() => _StandAloneState();
}

class _StandAloneState extends State<StandAlone> with SingleTickerProviderStateMixin {

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('data'));
  }
}
