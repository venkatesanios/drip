import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../view_models/admin_dealer/stock_entry_view_model.dart';

class StockEntry extends StatefulWidget {
  const StockEntry({super.key, required this.userId});
  final int userId;

  @override
  State<StockEntry> createState() => _StockEntryState();
}

class _StockEntryState extends State<StockEntry> {
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => StockEntryViewModel(Repository(HttpService()))..getMyStock(widget.userId, 1),
      child: Consumer<StockEntryViewModel>(
        builder: (context, viewModel, _) {

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                decoration: const BoxDecoration(
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
                    minWidth: 600,
                    border: TableBorder.all(color: Colors.teal.shade100),
                    headingRowColor: WidgetStateProperty.all<
                        Color>(Theme.of(context).primaryColorDark.withAlpha(1)),
                    headingRowHeight: 40,
                    dataRowHeight: 40,
                    columns: const [
                      DataColumn2(
                        label: Center(
                          child: Text(
                            'S.No',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        fixedWidth: 50,
                      ),
                      DataColumn(
                        label: Text(
                          'Category',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Model',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn2(
                        label: Center(
                          child: Text(
                            'IMEI',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        size: ColumnSize.L,
                      ),
                      DataColumn2(
                        label: Center(
                          child: Text(
                            'M.Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        fixedWidth: 150,
                      ),
                      DataColumn2(
                        label: Center(
                          child: Text(
                            'Warranty',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        fixedWidth: 100,
                      ),
                    ],
                    rows: List<DataRow>.generate(
                      viewModel.productStockList.length,
                          (index) => DataRow(
                        cells: [
                          DataCell(
                            Center(child: Text('${index + 1}')),
                          ),
                          DataCell(Text(viewModel.productStockList[index].categoryName)),
                          DataCell(Text(viewModel.productStockList[index].model)),
                          DataCell(
                            Center(
                              child: Text(viewModel.productStockList[index].imeiNo),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(viewModel.productStockList[index].dtOfMnf),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text('${viewModel.productStockList[index].warranty}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ) :
                const Center(child: Text(
                  'SOLD OUT', style: TextStyle(fontSize: 20),)),
              ),
            ),
          );
        },
      ),
    );

  }
}
