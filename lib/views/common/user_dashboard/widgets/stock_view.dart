import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';
import '../../../../view_models/product_stock_view_model.dart';

class StockView extends StatelessWidget {
  const StockView({super.key, required this.role, required this.isWide});
  final UserRole role;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductStockViewModel>();

    if(viewModel.isLoadingStock){

      return const Center(
        child: SizedBox(
          width: 45,
          height: 45,
          child: LoadingIndicator(indicatorType: Indicator.ballPulse),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: isWide? buildProductStock(context, viewModel) :
      buildForNarrow(viewModel),
    );
  }

  Widget buildForNarrow(ProductStockViewModel viewModel){
    return GridView.builder(
      itemCount: viewModel.productStockList.length,
      padding: const EdgeInsets.all(5),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (context, index) {
        final stock = viewModel.productStockList[index];

        return Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    color: Colors.black12,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      Text(
                        stock.categoryName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            const TextSpan(text: "Model : ", style: TextStyle(color: Colors.black45)),
                            TextSpan(
                              text: stock.model,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 3),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            const TextSpan(text: "imeiNo : ", style: TextStyle(color: Colors.black45)),
                            TextSpan(
                              text: stock.imeiNo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildProductStock(BuildContext context, ProductStockViewModel viewModel) {
    return Card(
      elevation: 1,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        children: [
          Container(
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
            ),
            child: ListTile(
              title: RichText(
                text: TextSpan(
                  text: 'Product Stock : ',
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                  children: [
                    TextSpan(
                      text: viewModel.productStockList.length.toString().padLeft(2, '0'),
                      style: const TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: viewModel.productStockList.isNotEmpty ? Padding(
                padding: const EdgeInsets.all(5.0),
                child: DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 700,
                  border: TableBorder.all(color: Theme.of(context).primaryColorLight.withOpacity(0.1)),
                  headingRowColor: WidgetStateProperty.all<
                      Color>(Theme.of(context).primaryColorLight.withOpacity(0.1)),
                  headingRowHeight: 30,
                  dataRowHeight: 35,
                  columns: [
                    DataColumn2(label: Center(child: AppConstants().txtSNo), fixedWidth: 50),
                    DataColumn(label: AppConstants().txtCategory),
                    DataColumn2(label: AppConstants().txtModel, size: ColumnSize.L),
                    DataColumn2(label: Center(child: AppConstants().txtIMEI), size: ColumnSize.S),
                    DataColumn2(label: Center(child: AppConstants().txtMDate), fixedWidth: 150),
                    DataColumn2(label: Center(child: AppConstants().txtWarranty), fixedWidth: 100),
                  ],
                  rows: List<DataRow>.generate(
                    viewModel.productStockList.length, (index) => DataRow(
                    cells: [
                      DataCell(Center(child: Text('${index + 1}'))),
                      DataCell(Text(viewModel.productStockList[index].categoryName)),
                      DataCell(Text(viewModel.productStockList[index].model)),
                      DataCell(Center(child: Text(viewModel.productStockList[index].imeiNo))),
                      DataCell(Center(child: Text(viewModel.productStockList[index].dtOfMnf))),
                      DataCell(Center(child: Text('${viewModel.productStockList[index].warranty}'))),
                    ],
                  ),
                  ),
                ),
              ) :
              Center(child: AppConstants().txtSoldOut),
            ),
          ),
        ],
      ),
    );
  }

}