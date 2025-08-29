import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../view_models/admin_dealer/stock_entry_view_model.dart';

class NewStockMiddle extends StatelessWidget {
  const NewStockMiddle({super.key});

  @override
  Widget build(BuildContext context) {

    final viewModel = context.watch<StockEntryViewModel>();

    return Scaffold(
      body: Column(
        children: [
          Text("Middle Layout for"),
        ],
      ),
    );
  }
}