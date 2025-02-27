import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/admin&dealer/stock_model.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../view_models/admin&dealer/dealer_device_list_view_model.dart';

class DealerDeviceList extends StatelessWidget {
  const DealerDeviceList({
    super.key,
    required this.userId,
    required this.customerName,
    required this.customerId,
    required this.userRole,
    required this.productStockList,
    required this.onDeviceListAdded,
  });

  final int userId, customerId;
  final String userRole, customerName;
  final List<StockModel> productStockList;
  final Function(Map<String, dynamic>) onDeviceListAdded;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = DealerDeviceListViewModel(Repository(HttpService()), userId, customerId, productStockList.length);
        viewModel.loadDeviceList(1);
        return viewModel;
      },
      child: Consumer<DealerDeviceListViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                customerName,
                style: const TextStyle(fontSize: 16),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.redAccent),
                tooltip: "Close",
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                PopupMenuButton(
                  tooltip: 'Add new product to $customerName',
                  color: Colors.white,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                      side: const BorderSide(color: Colors.white54, width: 0.5),
                    ),
                    onPressed: null,
                    textColor: Colors.white,
                    child: const Row(
                      children: [
                        Text('Add New Product'),
                        SizedBox(width: 3),
                        Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                  onCanceled: () {
                    viewModel.selectedProducts = List<bool>.filled(productStockList.length, false);
                  },
                  itemBuilder: (context) {
                    return List.generate(productStockList.length + 1, (index) {
                      if (productStockList.isEmpty) {
                        return const PopupMenuItem(
                          child: Text('No stock available to add in the site'),
                        );
                      } else if (productStockList.length == index) {
                        return PopupMenuItem(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MaterialButton(
                                color: Colors.red,
                                textColor: Colors.white,
                                child: const Text('CANCEL'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              const SizedBox(width: 5),
                              MaterialButton(
                                color: Colors.green,
                                textColor: Colors.white,
                                child: const Text('ADD'),
                                onPressed: () => viewModel.addProductToCustomer(context, productStockList, onDeviceListAdded),
                              ),
                            ],
                          ),
                        );
                      }

                      return PopupMenuItem(
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return CheckboxListTile(
                              title: Text(productStockList[index].categoryName),
                              subtitle: Text(productStockList[index].imeiNo),
                              value: viewModel.selectedProducts[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  viewModel.toggleProductSelection(index);
                                });
                              },
                            );
                          },
                        ),
                      );
                    });
                  },
                ),
                const SizedBox(width: 20),
              ],
            ),
            body: viewModel.isLoading ? const Center(
              child: CircularProgressIndicator(),
            ):
            Column(
              children: [
                Expanded(
                  child: viewModel.dealerDeviceList.isNotEmpty? DataTable2(
                    scrollController: viewModel.scrollController,
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    headingRowHeight: 30,
                    headingRowColor: WidgetStateProperty.all<
                        Color>(Theme.of(context).primaryColorDark.withAlpha(1)),
                    dataRowHeight: 35,
                    minWidth: 580,
                    columns: const [
                      DataColumn2(
                        label: Text('S.No',),
                        fixedWidth: 40,
                      ),
                      DataColumn2(
                        label: Text('Category'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Model'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('IMEI'),
                        size: ColumnSize.M,
                      ),
                      DataColumn2(
                        label: Text('Status'),
                        fixedWidth: 90,
                      ),
                      DataColumn2(
                        label: Text('Modify Date'),
                        fixedWidth: 90,
                      ),
                    ],
                    rows: List<DataRow>.generate(
                      viewModel.dealerDeviceList.length,
                          (index) => DataRow(
                        cells: [
                          DataCell(Center(
                            child: Text(
                              '${index + 1}',
                              style: viewModel.commonTextStyle,
                            ),
                          )),
                          DataCell(Text(viewModel.dealerDeviceList[index].categoryName,
                              style: viewModel.commonTextStyle)),
                          DataCell(Text(viewModel.dealerDeviceList[index].model,
                              style: viewModel.commonTextStyle)),
                          DataCell(SelectableText(viewModel.dealerDeviceList[index].deviceId,
                              style: viewModel.commonTextStyle)),
                          DataCell(Center(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor: viewModel.dealerDeviceList[index]
                                      .productStatus ==
                                      1
                                      ? Colors.pink
                                      : viewModel.dealerDeviceList[index].productStatus == 2
                                      ? Colors.blue
                                      : viewModel.dealerDeviceList[index].productStatus == 3
                                      ? Colors.purple
                                      : Colors.green,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  viewModel.dealerDeviceList[index].productStatus == 1
                                      ? 'In-Stock'
                                      : viewModel.dealerDeviceList[index].productStatus == 2
                                      ? 'Stock'
                                      : viewModel.dealerDeviceList[index].productStatus == 3
                                      ? 'Free'
                                      : 'Active',
                                  style: viewModel.commonTextStyle,
                                ),
                              ],
                            ),
                          )),
                          DataCell(Text(
                            DateFormat('dd-MM-yyyy').format(DateTime.parse(
                                viewModel.dealerDeviceList[index].modifyDate)),
                            style: viewModel.commonTextStyle,
                          )),
                        ],
                      ),
                    ),
                  ):
                  const Center(child: Text('No device available'),),
                ),
                viewModel.isLoading? Container(
                  width: double.infinity,
                  height: 30,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(300, 0, 300, 0),
                  child: const CircularProgressIndicator(),
                ):
                Container(),
              ],
            ),
          );
        },
      ),
    );
  }
}