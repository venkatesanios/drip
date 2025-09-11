import 'package:flutter/material.dart';
import '../../../../utils/enums.dart';
import '../widgets/analytics_view.dart';
import '../widgets/customer_view.dart';
import '../widgets/product_view.dart';


class AdminDashboardMiddle extends StatelessWidget {
  const AdminDashboardMiddle({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: 400,
                      child: const AnalyticsView(),
                    ),
                    const ProductView(isWideScreen: true),
                  ],
                ),
              ),
            ),
            SizedBox(
                width: 325,
                height: MediaQuery.sizeOf(context).height,
                child: CustomerView(role: UserRole.admin, isNarrow: false, onCustomerProductChanged: (String action) {})
            ),
          ],
        ),
      ),
    );
  }
}
