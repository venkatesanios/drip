import 'package:flutter/material.dart';

import '../../../models/admin_dealer/new_stock_model.dart';
import '../../../view_models/admin_dealer/stock_entry_view_model.dart';

class CategoryModelDd extends StatelessWidget {
  final StockEntryViewModel viewModel;
  final double? width;
  const CategoryModelDd({
    super.key,
    required this.viewModel,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<ProductModel>(
      controller: viewModel.modelTextController,
      label: const Text('Model'),
      width: width ?? double.infinity,
      dropdownMenuEntries: viewModel.modelEntries,
      inputDecorationTheme: inputDecorationTheme(),
      onSelected: (mdl) {
        if (mdl != null) {
          viewModel.selectedModelId = mdl.modelId;
          viewModel.modelTextController.text = mdl.modelName;
        }
      },
    );
  }

  InputDecorationTheme inputDecorationTheme() => const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(),
  );
}