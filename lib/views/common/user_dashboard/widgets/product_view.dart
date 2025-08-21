import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../../../flavors.dart';
import '../../../../view_models/product_category_view_model.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key, required this.isWideScreen});
  final bool isWideScreen;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductCategoryViewModel>();

    if (viewModel.isLoadingCategory) {
      return const Center(
        child: SizedBox(
          width: 40,
          child: LoadingIndicator(indicatorType: Indicator.ballPulse),
        ),
      );
    }

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: isWideScreen ? GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 4 / 2.7,
          ),
          itemCount: viewModel.categoryList.length,
          itemBuilder: (context, index) {
            final item = viewModel.categoryList[index];
            return InkWell(
              onTap: () {},
              child: Card(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/Png/${F.appFlavor!.name.contains('oro') ? 'Oro' : 'SmartComm'}/category_${index + 1}.png",
                      height: 60,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.categoryName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Device description',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        )
            : ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          itemCount: viewModel.categoryList.length,
          itemBuilder: (context, index) {
            final item = viewModel.categoryList[index];
            return ListTile(
              tileColor: Colors.white,
              leading: Image.asset(
                "assets/images/Png/${F.appFlavor!.name.contains('oro') ? 'Oro' : 'SmartComm'}/category_${index + 1}.png",
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
              title: Text(
                item.categoryName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Device description',
                style: TextStyle(color: Colors.black54),
              ),
              trailing: const Icon(Icons.arrow_right_outlined),
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}