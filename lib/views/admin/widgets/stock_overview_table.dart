import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class StockOverviewTable extends StatelessWidget {
  final List<Map<String, dynamic>> addedProductList;
  final Function(int) onRemove;

  const StockOverviewTable({
    super.key,
    required this.addedProductList,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 650,
      dataRowHeight: 40.0,
      headingRowHeight: 40.0,
      headingRowColor: WidgetStateProperty.all<Color>(
        Theme.of(context).primaryColorLight.withOpacity(0.1),
      ),
      columns: const [
        DataColumn2(label: Center(child: Text('S.No')), fixedWidth: 32),
        DataColumn2(label: Text('Category'), size: ColumnSize.M),
        DataColumn2(label: Text('Model Name'), size: ColumnSize.M),
        DataColumn2(label: Text('Device Id'), size: ColumnSize.M),
        DataColumn2(label: Center(child: Text('M.Date')), fixedWidth: 95),
        DataColumn2(label: Center(child: Text('Warranty')), fixedWidth: 80),
        DataColumn2(label: Center(child: Text('Action')), fixedWidth: 45),
      ],
      rows: List<DataRow>.generate(
        addedProductList.length, (index) => DataRow(cells: [
          DataCell(Center(child: Text('${index + 1}'))),
          DataCell(Text(addedProductList[index]['categoryName'])),
          DataCell(Text(addedProductList[index]['modelName'])),
          DataCell(Text('${addedProductList[index]['deviceId']}')),
          DataCell(Center(child: Text(addedProductList[index]['dateOfManufacturing']))),
          DataCell(Center(child: Text('${addedProductList[index]['warrantyMonths']}'))),
          DataCell(Center(
            child: IconButton(
              tooltip: 'Remove',
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => onRemove(index),
            ),
          )),
        ]),
      ),
    );
  }
}