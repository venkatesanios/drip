import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Widgets/analytics_overview.dart';
import '../../../../providers/user_provider.dart';
import '../../../../repository/repository.dart';
import '../../../../services/http_service.dart';
import '../../../../utils/enums.dart';
import '../../../../view_models/admin_dealer/admin_dealer_dashboard_view_model.dart';
import '../widgets/my_user.dart';

class DealerMobileDashboard extends StatefulWidget {
  const DealerMobileDashboard({super.key});

  @override
  State<DealerMobileDashboard> createState() => _DealerMobileDashboardState();
}

class _DealerMobileDashboardState extends State<DealerMobileDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final viewedCustomer = Provider.of<UserProvider>(context).viewedCustomer;

    return ChangeNotifierProvider(
      create: (_) => UserDashboardViewModel(Repository(HttpService()), viewedCustomer!.id, 2)
        ..getMySalesData(viewedCustomer.id, MySegment.all)
        ..getMyStock()
        ..getMyCustomers()
        ..getCategoryList(),
      child: Consumer<UserDashboardViewModel>(
        builder: (context, viewModel, _) {
          final pages = [
            AnalyticsOverview(viewModel: viewModel, userId: viewedCustomer!.id, isWideScreen: false),
            MyUser(viewModel: viewModel, userId: viewedCustomer.id, isWideScreen: false, title: 'My Customer'),
          ];

          return Scaffold(
            body: pages[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Theme.of(context).primaryColor,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
                BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
              ],
            ),
          );
        },
      ),
    );
  }
}

