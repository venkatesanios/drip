import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/constants.dart';
import '../../../utils/formatters.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../../mobile/mobile_screen_controller.dart';

Widget appBarBottomBar(BuildContext context,
    CustomerScreenControllerViewModel vm, dynamic currentMaster) {
  return Container(
    color: Theme.of(context).primaryColor,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 15),
            SiteSelectorWidget(vm: vm, context: context),
            const VerticalDividerWhite(),
            MasterSelectorWidget(vm: vm, sIndex: vm.sIndex, mIndex: vm.mIndex),
            if (vm.mySiteList.data[vm.sIndex].master.length > 1)...[
              const VerticalDividerWhite(),
            ],
            IrrigationLineSelectorWidget(vm: vm),
            if ([...AppConstants.gemModelList, ...AppConstants.ecoGemModelList]
                .contains(currentMaster.modelId) &&
                currentMaster.irrigationLine.length > 1)...[
              const VerticalDividerWhite(),
            ],
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.transparent,
              ),
              width: 45,
              height: 45,
              child: IconButton(
                tooltip: 'refresh',
                onPressed: vm.onRefreshClicked,
                icon: const Icon(Icons.refresh),
                color: Colors.white,
                iconSize: 24.0,
                hoverColor: Theme.of(context).primaryColorLight,
              ),
            ),
            Selector<CustomerScreenControllerViewModel, String>(
              selector: (_, vm) => vm.mqttProvider.liveDateAndTime,
              builder: (_, liveDateAndTime, __) => Text(
                'Last sync @ - ${Formatters.formatDateTime(liveDateAndTime)}',
                style: const TextStyle(fontSize: 14, color: Colors.white60),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
    ),
  );
}