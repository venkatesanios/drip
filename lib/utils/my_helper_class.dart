
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../repository/repository.dart';
import '../services/http_service.dart';
import '../view_models/base_header_view_model.dart';
import '../view_models/customer/customer_screen_controller_view_model.dart';
import '../views/common/user_dashboard/management_dashboard_service.dart';
import 'constants.dart';


mixin LayoutHelpers {
  UserProvider getUserProvider(BuildContext context) => context.read<UserProvider>();

  ChangeNotifierProvider<BaseHeaderViewModel> wrapWithBaseHeader(
      BuildContext context, {
        required List<String> menuTitles,
        required Widget child,
      }) {
    final viewedCustomer = getUserProvider(context).viewedCustomer!;
    return ChangeNotifierProvider<BaseHeaderViewModel>(
      create: (_) => BaseHeaderViewModel(
        menuTitles: menuTitles,
        repository: Repository(HttpService()),
      )..fetchCategoryModelList(viewedCustomer.id, viewedCustomer.role),
      child: child,
    );
  }

  Widget wrapWithDashboardService({
    required int userType,
    required BuildContext context,
    required Widget child,
  }) {
    final viewedCustomer = getUserProvider(context).viewedCustomer!;
    return ManagementDashboardService(
      userId: viewedCustomer.id,
      userType: userType,
      child: child,
    );
  }
}

abstract class BaseCustomerScreenState<T extends StatefulWidget> extends State<T> with ProgramRefreshMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void callbackFunction(String status) {
    if (status == 'Program created' && mounted) {
      onProgramCreated(context);
    }
  }

  bool isGemModel(int modelId) => [...AppConstants.gemModelList, ...AppConstants.ecoGemModelList].contains(modelId);
}

mixin ProgramRefreshMixin<T extends StatefulWidget> on State<T> {
  void onProgramCreated(BuildContext context) {
    final viewModel = Provider.of<CustomerScreenControllerViewModel>(context, listen: false);
    final viewedCustomer = Provider.of<UserProvider>(context, listen: false).viewedCustomer;
    if (viewedCustomer != null) {
      viewModel.getAllMySites(context, viewedCustomer.id, preserveSelection: true);
    }
  }
}