import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../../../Widgets/sales_chip.dart';
import '../../../../utils/enums.dart';
import '../../../../view_models/analytics_view_model.dart';
import '../../../admin_dealer/sales_bar_chart.dart';


class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AnalyticsViewModel>();

    return Card(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: [
            buildHeader(context, viewModel),
            Expanded(
              child: viewModel.isLoadingSalesData ?
              const Center(child: SizedBox(width: 40, child: LoadingIndicator(indicatorType: Indicator.ballPulse)))
                  : MySalesBarChart(graph: viewModel.mySalesData.graph),
            ),
            const SizedBox(height: 6),
            if ((viewModel.mySalesData.total ?? []).isNotEmpty)
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: List.generate(
                  viewModel.mySalesData.total!.length, (index) => SalesChip(
                    index: index, item: viewModel.mySalesData.total![index]),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context, AnalyticsViewModel viewModel) {
    return ListTile(
      tileColor: Colors.white,
      leading: Text.rich(
        TextSpan(
          text: 'Total Sales: ',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          children: [
            TextSpan(
              text: viewModel.totalSales.toString().padLeft(2, '0'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      trailing: SegmentedButton<MySegment>(
        segments: const [
          ButtonSegment(value: MySegment.all, label: Text('All'), icon: Icon(Icons.calendar_view_day)),
          ButtonSegment(value: MySegment.year, label: Text('Year'), icon: Icon(Icons.calendar_view_month)),
        ],
        selected: {viewModel.segmentView},
        onSelectionChanged: (Set<MySegment> newSelection) {
          if (newSelection.isNotEmpty) {
            final selectedSegment = newSelection.first;
            viewModel.getMySalesData(selectedSegment);
          }
        },
      ),
    );
  }
}
