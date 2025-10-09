import 'package:flutter/material.dart';

import '../../../view_models/customer/customer_screen_controller_view_model.dart';

class SiteSelectorWidget extends StatelessWidget {
  final CustomerScreenControllerViewModel vm;
  final BuildContext context;

  const SiteSelectorWidget({
    super.key,
    required this.vm,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    if ((vm.mySiteList.data.length) > 1) {
      return DropdownButton(
        isExpanded: false,
        underline: Container(),
        items: (vm.mySiteList.data).map((site) {
          return DropdownMenuItem(
            value: site.groupName,
            child: Text(
              site.groupName,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
        onChanged: (siteName) => vm.siteOnChanged(siteName!),
        value: vm.myCurrentSite,
        dropdownColor: Theme.of(context).primaryColorLight,
        iconEnabledColor: Colors.white,
        iconDisabledColor: Colors.white,
        focusColor: Colors.transparent,
      );
    } else {
      return Text(
        vm.mySiteList.data[vm.sIndex].groupName,
        style: const TextStyle(fontSize: 15, color: Colors.white54, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}