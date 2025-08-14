import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../../../flavors.dart';
import '../../../../view_models/product_category_view_model.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductCategoryViewModel>();

    return Card(
      color: Colors.white,
      child: viewModel.isLoadingCategory ? const Center(
        child: SizedBox(
          width: 40,
          child: LoadingIndicator(indicatorType: Indicator.ballPulse),
        ),
      ) : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView.builder(
          itemCount: viewModel.categoryList.length,
          shrinkWrap: true, // important!
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          itemBuilder: (context, index) {
            final item = viewModel.categoryList[index];
            return ListTile(
              tileColor: Colors.white,
              leading: Image.asset(
                "assets/images/Png/${F.appFlavor!.name.contains('oro') ? 'Oro' : 'SmartComm'}/category_${index + 1}.png",
                errorBuilder: (context, error, stackTrace) {
                  print('error: $error');
                  return const Icon(Icons.error);
                },
              ),
              title: Text(
                item.categoryName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Device description',
                style: TextStyle(color: Colors.black54),
              ),
              trailing: const Icon(Icons.arrow_right_outlined),
              onTap: () {
              },
            );
          },
        ),
      ),
    );
  }

}