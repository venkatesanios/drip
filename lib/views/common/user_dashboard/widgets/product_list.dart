import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../../../../flavors.dart';
import '../../../../view_models/admin_dealer/admin_dealer_dashboard_view_model.dart';

class ProductList extends StatelessWidget {
  final UserDashboardViewModel viewModel;
  final int userId;

  const ProductList({
    super.key,
    required this.viewModel,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: double.infinity,
      child: Card(
        color: Colors.white,
        child: viewModel.isLoadingCustomerData
            ? const Center(
          child: SizedBox(
            width: 40,
            child: LoadingIndicator(indicatorType: Indicator.ballPulse),
          ),
        )
            : Column(
          children: [
            const ListTile(
              title: Text('All My Devices', style: TextStyle(fontSize: 20)),
            ),
            const Divider(height: 0),
            Expanded(
              child: viewModel.categoryList.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: ListView.builder(
                  itemCount: viewModel.categoryList.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.categoryList[index];
                    return ListTile(
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          "assets/images/Png/${F.appFlavor!.name.contains('oro') ? 'Oro' : 'SmartComm'}/category_${index + 1}.png",
                          errorBuilder: (context, error, stackTrace) {
                            print('error: $error');
                            return const Icon(Icons.error);
                          },
                        ),
                      ),
                      title: Text(
                        item.categoryName,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      subtitle: Text('Model : discription'),
                    );
                  },
                ),
              )
                  : const LoadingIndicator(indicatorType: Indicator.ballPulse),
            ),
          ],
        ),
      ),
    );
  }
}

/*
class ProductList extends StatelessWidget {
  final UserDashboardViewModel viewModel;
  final int userId;

  const ProductList({
    super.key,
    required this.viewModel,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: double.infinity,
      child: Card(
        color: Colors.white,
        child: viewModel.isLoadingCustomerData
            ? const Center(
          child: SizedBox(
            width: 40,
            child: LoadingIndicator(indicatorType: Indicator.ballPulse),
          ),
        )
            : Column(
          children: [
            const ListTile(
              title: Text('All My Devices', style: TextStyle(fontSize: 20)),
            ),
            const Divider(height: 0),
            Expanded(
              child: viewModel.categoryList.isNotEmpty ?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: viewModel.categoryList.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.categoryList[index];
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Image.asset(
                                "assets/images/Png/${F.appFlavor!.name.contains('oro') ? 'Oro' : 'SmartComm'}/category_${index + 1}.png",
                                errorBuilder: (context, error, stackTrace) {
                                  print('error: $error');
                                  return const Icon(Icons.error);
                                },
                              ),
                            ),
                          ),
                          Container(
                            height: 25,
                            color: Colors.white,
                            child: Center(
                              child: Text(
                                item.categoryName,
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ) :
              const LoadingIndicator(indicatorType: Indicator.ballPulse),
            ),
          ],
        ),
      ),
    );
  }

}*/
