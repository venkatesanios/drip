import 'package:flutter/material.dart';

import '../../../utils/my_helper_class.dart';
import 'customer_screen_layout_builder.dart';

class CustomerScreenMiddle extends StatefulWidget {
  const CustomerScreenMiddle({super.key});

  @override
  State<CustomerScreenMiddle> createState() =>
      _CustomerScreenMiddleState();
}

class _CustomerScreenMiddleState
    extends State<CustomerScreenMiddle> with ProgramRefreshMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void callbackFunction(String status) {
    if (status == 'Program created' && mounted) onProgramCreated(context);
  }

  @override
  Widget build(BuildContext context) {
    return CustomerScreenLayoutBuilder(
      isMiddle: true,
      scaffoldKey: _scaffoldKey,
      callbackFunction: callbackFunction,
    );
  }
}