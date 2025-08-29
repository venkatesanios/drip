import 'package:flutter/material.dart';

import '../../../models/admin_dealer/simple_category.dart';
import '../../../view_models/admin_dealer/stock_entry_view_model.dart';

class ProductCategoryDd extends StatelessWidget {
  final StockEntryViewModel viewModel;
  const ProductCategoryDd({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<SimpleCategory>(
      value: viewModel.selectedCategory,
      hint: const Text("Select a category"),
      decoration: inputDecoration(),
      items: viewModel.categoryList.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          viewModel.selectedCategoryId = newValue.id;
          viewModel.modelTextController.clear();
          viewModel.selectedModelId = 0;
          viewModel.getModelsByCategoryId();
          viewModel.selectedCategory = newValue;
        }
      },
    );
  }

  InputDecoration inputDecoration() => const InputDecoration(
    border: OutlineInputBorder(),
    filled: true,
    fillColor: Colors.white,
  );
}