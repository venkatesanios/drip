import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/utils/enums.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/bottom_nav_view_model.dart';
import '../widgets/analytics_view.dart';
import '../widgets/customer_view.dart';
import '../widgets/product_view.dart';

class AdminMobileDashboard extends StatelessWidget {
  const AdminMobileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final navModel = context.watch<BottomNavViewModel>();

    const pages = [AnalyticsView(), CustomerView(role: UserRole.admin), ProductView()];

    return Scaffold(
      body: IndexedStack(
        index: navModel.index,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navModel.index,
        onTap: navModel.setIndex,
        backgroundColor: Theme.of(context).primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Product',
          ),
        ],
      ),
    );
  }
}