import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../modules/PumpController/view/node_settings.dart';
import '../../../modules/bluetooth_low_energy/view/node_connection_page.dart';
import '../../../modules/open_ai/view/open_ai_screen.dart';
import '../../../utils/constants.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../mobile/mobile_screen_controller.dart';
import '../sent_and_received.dart';

List<Widget> appBarActions(BuildContext context, CustomerScreenControllerViewModel vm,
    dynamic currentMaster, dynamic loggedInUser, dynamic viewedCustomer) {
  final isGem = [
    ...AppConstants.gemModelList,
    ...AppConstants.ecoGemModelList,
  ].contains(currentMaster.modelId);

  if (isGem) {
    return [
      Consumer<CustomerScreenControllerViewModel>(
        builder: (context, vm, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (vm.programRunning)
                CircleAvatar(
                  radius: 15,
                  backgroundImage:
                  const AssetImage('assets/gif/water_drop_ani.gif'),
                  backgroundColor: Colors.blue.shade100,
                ),
            ],
          );
        },
      ),
      const SizedBox(width: 8),
      AlarmButton(
        alarmPayload: vm.alarmDL,
        deviceID: currentMaster.deviceId,
        customerId: viewedCustomer!.id,
        controllerId: currentMaster.controllerId,
      ),
      IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIChatScreen()),
          );
        },
        icon: const Icon(Icons.assistant),
      ),
    ];
  } else {
    return [
      _buildNonGemActions(context, currentMaster, loggedInUser, viewedCustomer),
    ];
  }
}

Widget _buildNonGemActions(BuildContext context, dynamic currentMaster,
    dynamic loggedInUser, dynamic viewedCustomer) {
  return Container(
    height: 35,
    decoration: BoxDecoration(
      color: MediaQuery.of(context).size.width >= 600 ?
      Colors.transparent : Theme.of(context).primaryColorLight,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        bottomLeft: Radius.circular(25),
      ),
    ),
    child: Row(
      children: [
        if (currentMaster.nodeList.isNotEmpty && [48, 49].contains(currentMaster.modelId))...[
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => NodeSettings(
                  userId: viewedCustomer!.id,
                  controllerId: currentMaster.controllerId,
                  customerId: viewedCustomer.id,
                  nodeList: currentMaster.nodeList,
                  deviceId: currentMaster.deviceId,
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.settings_remote),
            ),
          ),
        ],
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SentAndReceived(
                  customerId: loggedInUser.id,
                  controllerId: currentMaster.controllerId,
                ),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.question_answer_outlined),
          ),
        ),
        if (!kIsWeb)...[
          InkWell(
            onTap: () {
              final Map<String, dynamic> data = {
                'controllerId': currentMaster.controllerId,
                'deviceId': currentMaster.deviceId,
                'deviceName': currentMaster.deviceName,
                'categoryId': currentMaster.categoryId,
                'categoryName': currentMaster.categoryName,
                'modelId': currentMaster.modelId,
                'modelName': currentMaster.modelName,
                'InterfaceType': 1,
                'interface': 'GSM',
                'relayOutput': 3,
                'latchOutput': 0,
                'analogInput': 8,
                'digitalInput': 4,
              };
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NodeConnectionPage(
                    nodeData: data,
                    masterData: {
                      "userId": loggedInUser.id,
                      "customerId": viewedCustomer!.id,
                      "controllerId": currentMaster.controllerId,
                    },
                  ),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.bluetooth),
            ),
          ),
        ],
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AIChatScreen()),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.assistant),
          ),
        ),
      ],
    ),
  );
}