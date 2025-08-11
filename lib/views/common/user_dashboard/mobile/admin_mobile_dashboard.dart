import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Widgets/analytics_overview.dart';
import '../../../../providers/user_provider.dart';
import '../../../../repository/repository.dart';
import '../../../../services/http_service.dart';
import '../../../../utils/enums.dart';
import '../../../../view_models/admin_dealer/admin_dealer_dashboard_view_model.dart';
import '../widgets/my_user.dart';
import '../widgets/product_list.dart';

class AdminMobileDashboard extends StatelessWidget {
  const AdminMobileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final viewedCustomer = Provider.of<UserProvider>(context).viewedCustomer;

    return ChangeNotifierProvider(
      create: (_) => UserDashboardViewModel(Repository(HttpService()), viewedCustomer!.id, 1)
        ..getMySalesData(viewedCustomer.id, MySegment.all)
        ..getMyStock()
        ..getMyCustomers()
        ..getCategoryList(),
      child: Consumer<UserDashboardViewModel>(
        builder: (context, viewModel, _) {
          //handleAccountCreated(viewModel, context);

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(3.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    AnalyticsOverview(viewModel: viewModel, userId: viewedCustomer!.id, isWideScreen: false),
                    MyUser(viewModel:viewModel, userId: viewedCustomer.id, isWideScreen: false),
                    ProductList(viewModel: viewModel, userId: viewedCustomer.id, isWide: false),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}