import 'package:flutter/material.dart';

import '../../../utils/my_helper_class.dart';
import 'customer_screen_layout_builder.dart';

class CustomerScreenWide extends StatefulWidget {
  const CustomerScreenWide({super.key});

  @override
  State<CustomerScreenWide> createState() =>
      _CustomerScreenWideState();
}

class _CustomerScreenWideState
    extends State<CustomerScreenWide> with ProgramRefreshMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void callbackFunction(String status) {
    if (status == 'Program created' && mounted) onProgramCreated(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScreenLayoutBuilder(
      isWide: true,
      scaffoldKey: _scaffoldKey,
      callbackFunction: callbackFunction,
    );
  }
}