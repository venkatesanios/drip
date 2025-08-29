import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../modules/PumpController/view/node_settings.dart';
import '../../../../modules/open_ai/view/open_ai_screen.dart';
import '../../../../utils/constants.dart';
import '../../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../../mobile/mobile_screen_controller.dart';
import '../../sent_and_received.dart';

class CustomerAppBarActions extends StatelessWidget {
  final dynamic vm;
  final dynamic currentMaster;
  final dynamic viewedCustomer;
  final dynamic loggedInUser;

  const CustomerAppBarActions({
    super.key,
    required this.vm,
    required this.currentMaster,
    required this.viewedCustomer,
    required this.loggedInUser,
  });

  bool get isGemModel => [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId);

  @override
  Widget build(BuildContext context) {
    if (isGemModel) {
      return Row(
        children: [
          Consumer<CustomerScreenControllerViewModel>(
            builder: (context, vm, child) {
              return vm.programRunning ? CircleAvatar(
                radius: 15,
                backgroundImage:
                const AssetImage('assets/gif/water_drop_ani.gif'),
                backgroundColor: Colors.blue.shade100,
              ) :
              const SizedBox();
            },
          ),
          const SizedBox(width: 8),
          AlarmButton(
            alarmPayload: vm.alarmDL,
            deviceID: currentMaster.deviceId,
            customerId: viewedCustomer.id,
            controllerId: currentMaster.controllerId,
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AIChatScreen()),
            ),
            icon: const Icon(Icons.assistant),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          if (currentMaster.nodeList.isNotEmpty && [48, 49].contains(currentMaster.modelId))...[
            IconButton(
              icon: const Icon(Icons.settings_remote),
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (_) => NodeSettings(
                  userId: viewedCustomer.id,
                  controllerId: currentMaster.controllerId,
                  customerId: viewedCustomer.id,
                  nodeList: currentMaster.nodeList,
                  deviceId: currentMaster.deviceId,
                ),
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.question_answer_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SentAndReceived(
                  customerId: loggedInUser.id,
                  controllerId: currentMaster.controllerId,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.assistant),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AIChatScreen()),
            ),
          ),
        ],
      );
    }
  }
}