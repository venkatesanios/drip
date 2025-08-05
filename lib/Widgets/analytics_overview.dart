import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_drip_irrigation/Widgets/sales_chip.dart';

import '../utils/constants.dart';
import '../view_models/admin_dealer/admin_dealer_dashboard_view_model.dart';
import '../views/admin_dealer/admin_dashboard.dart';
import '../views/admin_dealer/sales_bar_chart.dart';

class AnalyticsOverview extends StatelessWidget {
  final UserDashboardViewModel viewModel;
  final int userId;

  const AnalyticsOverview({super.key, required this.viewModel, required this.userId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenWidth > 800 ? 360 : 410,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            children: [
              buildHeader(context, screenWidth),
              Expanded(
                child: viewModel.isLoadingSalesData
                    ? const Center(child: SizedBox(width: 40, child: LoadingIndicator(indicatorType: Indicator.ballPulse)))
                    : MySalesBarChart(graph: viewModel.mySalesData.graph),
              ),
              const SizedBox(height: 6),
              if ((viewModel.mySalesData.total ?? []).isNotEmpty)
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: List.generate(
                    viewModel.mySalesData.total!.length,
                        (index) => SalesChip(index: index, item: viewModel.mySalesData.total![index]),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context, double screenWidth) {
    return ListTile(
      tileColor: Colors.white,
      title: AppConstants().anlOvrView,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<MySegment>(
            segments: const [
              ButtonSegment(value: MySegment.all, label: Text('All'), icon: Icon(Icons.calendar_view_day)),
              ButtonSegment(value: MySegment.year, label: Text('Year'), icon: Icon(Icons.calendar_view_month)),
            ],
            selected: {viewModel.segmentView},
            onSelectionChanged: (Set<MySegment> newSelection) {
              if (newSelection.isNotEmpty) {
                viewModel.updateSegmentView(newSelection.first);
                viewModel.getMySalesData(userId, newSelection.first);
              }
            },
          ),
          const SizedBox(width: 16),
          Text.rich(
            TextSpan(
              text: 'Total Sales: ',
              style: const TextStyle(fontSize: 15),
              children: [
                TextSpan(
                  text: viewModel.totalSales.toString().padLeft(2, '0'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}