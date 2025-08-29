import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../Models/admin_dealer/stock_model.dart';

Widget stockTable(List<StockModel> stocks) {
  if (stocks.isEmpty) {
    return const Center(child: Text('SOLD OUT', style: TextStyle(fontSize: 20)));
  }

  return DataTable2(
    columnSpacing: 12,
    horizontalMargin: 12,
    minWidth: 650,
    border: TableBorder.all(color: Colors.black12),
    headingRowColor: WidgetStateProperty.all(Colors.black12.withOpacity(0.05)),
    headingRowHeight: 40,
    dataRowHeight: 40,
    columns: const [
      DataColumn2(label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold))), fixedWidth: 50),
      DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(label: Text('Model', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn2(label: Center(child: Text('IMEI', style: TextStyle(fontWeight: FontWeight.bold))), size: ColumnSize.L),
      DataColumn2(label: Center(child: Text('M.Date', style: TextStyle(fontWeight: FontWeight.bold))), fixedWidth: 150),
      DataColumn2(label: Center(child: Text('Warranty', style: TextStyle(fontWeight: FontWeight.bold))), fixedWidth: 100),
    ],
    rows: List.generate(stocks.length, (i) {
      final s = stocks[i];
      return DataRow(cells: [
        DataCell(Center(child: Text('${i + 1}'))),
        DataCell(Text(s.categoryName)),
        DataCell(Text(s.model)),
        DataCell(Center(child: Text(s.imeiNo))),
        DataCell(Center(child: Text(s.dtOfMnf))),
        DataCell(Center(child: Text('${s.warranty}'))),
      ]);
    }),
  );
}