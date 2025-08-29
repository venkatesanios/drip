import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../view_models/admin_dealer/stock_entry_view_model.dart';
import '../widgets/category_model_dd.dart';
import '../widgets/manufacturing_date_field.dart';
import '../widgets/product_category_dd.dart';
import '../widgets/stock_overview_table.dart';
import '../widgets/stock_table.dart';
import '../widgets/stock_text_field.dart';

class NewStockNarrow extends StatelessWidget {
  const NewStockNarrow({super.key});

  Widget _gap() => const SizedBox(height: 8);

  @override
  Widget build(BuildContext context) {

    final viewedCustomer = context.read<UserProvider>().viewedCustomer!;
    final viewModel = context.watch<StockEntryViewModel>();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
                      child: Card(
                        color: Colors.white,
                        elevation: 0,
                        surfaceTintColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: buildHeaderRow(context, viewModel),
                        ),
                      ),
                    ),
                  ),

                  if(viewModel.addedProductList.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        child: Column(
                          children: [

                            ListTile(
                              contentPadding: const EdgeInsets.only(left: 16, right: 5),
                              title: const Text('STOCK OVERVIEW', style: TextStyle(fontSize: 17, color: Colors.black87)),
                              trailing: TextButton(
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
                                              onPressed: () => viewModel.addProductStock(viewedCustomer!.id, context),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                ),
                                child: const SizedBox(
                                  width: 120,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save_outlined),
                                      SizedBox(width: 8),
                                      Text('SAVE TO STOCK', style: TextStyle(fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              height: (viewModel.addedProductList.length * 45.0) + 40,
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: StockOverviewTable(
                                  addedProductList: viewModel.addedProductList,
                                  onRemove: viewModel.removeNewStock,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      child: Column(
                        children: [
                          const ListTile(
                              title: Text('ALL MY STOCKS', style: TextStyle(fontSize: 17, color: Colors.black87))),
                          Container(
                            color: Colors.white,
                            height: (viewModel.productStockList.length * 45.0) + 40,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: stockTable(viewModel.productStockList),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildHeaderRow(BuildContext context, StockEntryViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: 290,
      color: Colors.white24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProductCategoryDd(viewModel: viewModel),
              _gap(),
              CategoryModelDd(viewModel: viewModel),
              _gap(),
              StockTextField(
                controller: viewModel.imeiController,
                label: "Device ID",
                maxLength: 12,
              ),
              _gap(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(flex:1,child: StockTextField(
                    controller: viewModel.warrantyMonthsController,
                    label: "Warranty Months",
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  )),
                  const SizedBox(width: 16),
                  Flexible(flex:1, child: ManufacturingDateField(controller: viewModel.manufacturingDateController)),
                ],
              ),

              const SizedBox(height: 16),
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

}