import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../view_models/admin_dealer/stock_entry_view_model.dart';
import '../../../view_models/product_stock_view_model.dart';
import '../widgets/category_model_dd.dart';
import '../widgets/manufacturing_date_field.dart';
import '../widgets/product_category_dd.dart';
import '../widgets/stock_overview_table.dart';
import '../widgets/stock_table.dart';
import '../widgets/stock_text_field.dart';

class NewStockWide extends StatelessWidget {
  const NewStockWide({super.key});

  Widget _gap() => const SizedBox(width: 8);
  Widget _sized(Widget child, double w) => SizedBox(width: w, height: 50, child: child);

  @override
  Widget build(BuildContext context) {

    final viewedCustomer = context.read<UserProvider>().viewedCustomer!;
    final viewModel = context.watch<StockEntryViewModel>();

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHeaderRow(context, viewModel),
          const Divider(height:0, color: Colors.black12),
          Expanded(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height-150,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(viewModel.addedProductList.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 50, top: 10),
                        child: Row(
                          children: [
                            _overviewHeader("Stock Overview"),
                            const Spacer(),
                            TextButton(
                              onPressed: (){
                                if(viewModel.addedProductList.isNotEmpty)
                                {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirmation'),
                                        content: const Text('Are you sure! You want to save the product to Stock list?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => viewModel.addProductStock(viewedCustomer.id, context),
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }else{
                                  //_showAlertDialog('Alert Message', 'Product Empty!');
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_outlined),
                                  SizedBox(width: 8),
                                  Text('SAVE TO STOCK', style: TextStyle(fontSize: 11)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 50)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50, top: 8, bottom: 8),
                        child: Container(
                          color: Colors.white,
                          height: (viewModel.addedProductList.length * 40.0) + 40,
                          child: StockOverviewTable(
                            addedProductList: viewModel.addedProductList,
                            onRemove: viewModel.removeNewStock,
                          ),
                        ),
                      ),
                    ],

                    const Padding(
                      padding: EdgeInsets.only(left: 50, top: 10),
                      child: Text('ALL MY STOCKS', style: TextStyle(fontSize: 15, color: Colors.black87)),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 50, right: 50, top: 8, bottom: 8),
                      child: Container(
                        color: Colors.white,
                        height: (viewModel.productStockList.length * 40.0) + 40,
                        child: stockTable(viewModel.productStockList),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeaderRow(BuildContext context, StockEntryViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: 80,
      color: Colors.white24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sized(ProductCategoryDd(viewModel: viewModel), 220),
              _gap(),
              _sized(CategoryModelDd(viewModel: viewModel, width: 205), 205),
              _gap(),
              StockTextField(
                controller: viewModel.imeiController,
                label: "Device ID",
                maxLength: 12,
                width: 200,
              ),
              _gap(),
              StockTextField(
                controller: viewModel.warrantyMonthsController,
                label: "Warranty Months",
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                width: 125,
              ),
              _gap(),
              _sized(ManufacturingDateField(controller: viewModel.manufacturingDateController), 120),
              const SizedBox(width: 16),
              _addButton(viewModel),
            ],
          ),
          if (viewModel.errorMsg.isNotEmpty)
            SizedBox(
              width: 500,
              child: Center(
                child: Text(viewModel.errorMsg, style: const TextStyle(color: Colors.red)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _addButton(StockEntryViewModel viewModel) {
    return TextButton.icon(
      onPressed: viewModel.saveStockListToLocal,
      style: TextButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      icon: const Icon(Icons.add, size: 16),
      label: const Text('ADD', style: TextStyle(fontSize: 12)),
    );
  }

  Widget _overviewHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87
        ),
      ),
    );
  }
}
