import 'package:flutter/material.dart';

import '../../../../modules/IrrigationProgram/view/program_library.dart';
import '../../../../modules/ScheduleView/view/schedule_view_screen.dart';
import '../../input_output_connection_details.dart';
import '../../node_list.dart';
import '../../sent_and_received.dart';
import '../../stand_alone.dart';

class ActionsPopupMenu extends StatelessWidget {
  final dynamic vm;
  final dynamic currentMaster;
  final dynamic viewedCustomer;
  final dynamic loggedInUser;

  const ActionsPopupMenu({
    super.key,
    required this.vm,
    required this.currentMaster,
    required this.viewedCustomer,
    required this.loggedInUser,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, -180),
      color: Colors.white,
      onSelected: (String value) => _handleSelection(context, value),
      icon: const Icon(Icons.menu, color: Colors.white),
      itemBuilder: (BuildContext context) => [
        _popupItem(context, 'Node Status', Icons.format_list_numbered, 'Node Status'),
        _popupItem(context, 'I/O Connection', Icons.settings_input_component_outlined, 'I/O\nConnection\ndetails'),
        _popupItem(context, 'Program', Icons.list_alt, 'Program'),
        _popupItem(context, 'ScheduleView', Icons.view_list_outlined, 'Scheduled\nprogram\ndetails'),
        _popupItem(context, 'Manual', Icons.touch_app_outlined, 'Manual'),
        _popupItem(context, 'Sent & Received', Icons.question_answer_outlined, 'Sent &\nReceived'),
      ],
    );
  }

  PopupMenuItem<String> _popupItem(BuildContext context, String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).primaryColorLight,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _handleSelection(BuildContext context, String value) {
    switch (value) {
      case 'Node Status':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => NodeList(
            customerId: viewedCustomer.id,
            nodes: currentMaster.nodeList,
            userId: loggedInUser.id,
            configObjects: currentMaster.configObjects,
            masterData: currentMaster,
          ),
        ));
        break;

      case 'I/O Connection':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => InputOutputConnectionDetails(
            masterInx: vm.mIndex,
            nodes: currentMaster.nodeList,
          ),
        ));
        break;

      case 'Sent & Received':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => SentAndReceived(
            customerId: viewedCustomer.id,
            controllerId: currentMaster.controllerId,
          ),
        ));
        break;

      case 'Program':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ProgramLibraryScreenNew(
            customerId: viewedCustomer.id,
            controllerId: currentMaster.controllerId,
            deviceId: currentMaster.deviceId,
            userId: loggedInUser.id,
            groupId: vm.mySiteList.data[vm.sIndex].groupId,
            categoryId: currentMaster.categoryId,
            modelId: currentMaster.modelId,
            deviceName: currentMaster.deviceName,
            categoryName: currentMaster.categoryName,
          ),
        ));
        break;

      case 'ScheduleView':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ScheduleViewScreen(
            deviceId: currentMaster.deviceId,
            userId: loggedInUser.id,
            controllerId: currentMaster.controllerId,
            customerId: viewedCustomer.id,
            groupId: vm.mySiteList.data[vm.sIndex].groupId,
          ),
        ));
        break;

      case 'Manual':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => StandAlone(
            siteId: vm.mySiteList.data[vm.sIndex].groupId,
            controllerId: currentMaster.controllerId,
            customerId: viewedCustomer.id,
            deviceId: currentMaster.deviceId,
            callbackFunction: (_) {},
            userId: loggedInUser.id,
            masterData: currentMaster,
          ),
        ));
        break;
    }
  }
}