import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/constants.dart';
import '../../../../utils/formatters.dart';
import '../../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../../mobile/mobile_screen_controller.dart';

class CustomerAppBarBottom extends StatelessWidget
    implements PreferredSizeWidget {
  final dynamic vm;
  final dynamic currentMaster;

  const CustomerAppBarBottom({
    super.key,
    required this.vm,
    required this.currentMaster,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SiteSelectorWidget(vm: vm, context: context),
                const VerticalDividerWhite(),
                MasterSelectorWidget(vm: vm, sIndex: vm.sIndex, mIndex: vm.mIndex),
                if (vm.mySiteList.data[vm.sIndex].master.length > 1)
                  const VerticalDividerWhite(),
                IrrigationLineSelectorWidget(vm: vm),
                if ([...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(currentMaster.modelId)
                    && currentMaster.irrigationLine.length > 1)...[
                  const VerticalDividerWhite(),
                ],
                IconButton(
                  tooltip: 'refresh',
                  onPressed: vm.onRefreshClicked,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
                Selector<CustomerScreenControllerViewModel, String>(
                  selector: (_, vm) => vm.mqttProvider.liveDateAndTime,
                  builder: (_, liveDateAndTime, __) => Text(
                    'Last sync @ - ${Formatters.formatDateTime(liveDateAndTime)}',
                    style: const TextStyle(fontSize: 14, color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}