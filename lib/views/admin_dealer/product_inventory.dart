import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/constants.dart';
import '../../view_models/admin&dealer/inventory_view_model.dart';

class ProductInventory extends StatelessWidget {
  const ProductInventory({super.key, required this.userId, required this.userName, required this.userRole});
  final int userId;
  final String userName;
  final UserRole userRole;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryViewModel(Repository(HttpService()),userId, userRole)
        ..loadInventoryData(1)
      ..getCategoryModelList(),
      child: Consumer<InventoryViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Theme.of(context).primaryColorDark.withAlpha(1),
            body: viewModel.isLoading? Center(
              child: Visibility(
                visible: true,
                child: Container(
                  height: 50,
                  color: Colors.transparent,
                  padding: EdgeInsets.fromLTRB(MediaQuery.sizeOf(context).width/2 - 100, 0, MediaQuery.sizeOf(context).width/2 - 100, 0),
                  child: const LoadingIndicator(
                    indicatorType: Indicator.ballPulse,
                  ),
                ),
              ),
            ):
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      viewModel.totalProduct > 25 ?Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 300,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 1)],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: viewModel.txtFldSearch,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.search),
                                      suffixIcon: viewModel.txtFldSearch.text.isNotEmpty
                                          ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () => viewModel.clearSearch(),
                                      )
                                          : null,
                                      hintText: 'Search by device id / person',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      viewModel.showSearchButton = value.isNotEmpty;
                                    },
                                    onSubmitted: (value) {
                                      if (value.isNotEmpty) {
                                        viewModel.filterActive = true;
                                        viewModel.searchedChipName = value;
                                        viewModel.fetchFilterData(null, null, value, userRole, userId);
                                      }
                                    },
                                  ),
                                ),
                                if (viewModel.showSearchButton)
                                  IconButton(
                                    icon: const Icon(Icons.search, color: Colors.blue),
                                    onPressed: () {
                                      if (viewModel.txtFldSearch.text.isNotEmpty) {
                                        viewModel.filterActive = true;
                                        viewModel.searchedChipName = viewModel.txtFldSearch.text;
                                        viewModel.fetchFilterData(null, null, viewModel.txtFldSearch.text, userRole, userId);
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<dynamic>(
                            icon: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              height: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.filter_alt_outlined),
                                  SizedBox(width: 3),
                                  Text(
                                    'Filter by category or model',
                                    style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                            tooltip: 'select category or model',
                            itemBuilder: (BuildContext context) {
                              List<PopupMenuEntry<dynamic>> menuItems = [];
                              menuItems.add(
                                const PopupMenuItem<dynamic>(
                                  enabled: false,
                                  child: Text("Category"),
                                ),
                              );

                              List<dynamic> categoryItems = viewModel.jsonDataMap['data']['category'];
                              menuItems.addAll(
                                categoryItems.map((dynamic item) {
                                  return PopupMenuItem<dynamic>(
                                    value: item,
                                    child: Text(item['categoryName']),
                                  );
                                }),
                              );
                              menuItems.add(
                                const PopupMenuItem<dynamic>(
                                  enabled: false,
                                  child: Text("Model"),
                                ),
                              );
                              List<dynamic> modelItems = viewModel.jsonDataMap['data']['model'];
                              menuItems.addAll(
                                modelItems.map((dynamic item) {
                                  return PopupMenuItem<dynamic>(
                                    value: item,
                                    child: Text('${item['categoryName']} - ${item['modelName']}'),
                                  );
                                }),
                              );

                              return menuItems;
                            },
                            onSelected: (dynamic selectedItem) {
                              if (selectedItem is Map<String, dynamic>) {
                                viewModel.filterActive = true;
                                if (selectedItem.containsKey('categoryName') && selectedItem.containsKey('modelName')) {
                                  viewModel.searchedChipName = '${selectedItem['categoryName']} - ${selectedItem['modelName']}';
                                  viewModel.fetchFilterData(null, selectedItem['modelId'], null, userRole, userId);
                                } else {
                                  viewModel.searchedChipName = '${selectedItem['categoryName']}';
                                  viewModel.fetchFilterData(selectedItem['categoryId'], null, null, userRole, userId);
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          viewModel.searchedChipName != ''? Padding(
                            padding: const EdgeInsets.only(top: 5, left: 5),
                            child: Chip(
                              backgroundColor: Colors.yellow,
                              label: Text('filtered By ${viewModel.searchedChipName}'),
                              onDeleted: () => viewModel.clearSearch(),
                            ),
                          ) :
                          const SizedBox(),
                        ],
                      ) :
                      Container(),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(5),topRight: Radius.circular(5)),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: DataTable2(
                              scrollController: viewModel.scrollController,
                              columnSpacing: 12,
                              horizontalMargin: 12,
                              minWidth: 1200,
                              dataRowHeight: 35.0,
                              headingRowHeight: 30,
                              headingRowColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColorDark.withAlpha(1)),
                              border: TableBorder.all(color: Colors.teal.shade100, width: 0.5),
                              columns: const [
                                DataColumn2(
                                    label: Center(child: Text('S.No')),
                                    fixedWidth: 70
                                ),
                                DataColumn2(
                                    label: Center(child: Text('Category')),
                                    size: ColumnSize.S
                                ),
                                DataColumn2(
                                    label: Center(child: Text('Model Name')),
                                    size: ColumnSize.S
                                ),
                                DataColumn2(
                                    label: Center(child: Text('Device Id')),
                                    size: ColumnSize.S
                                ),
                                DataColumn2(
                                  label: Center(child: Text('M.Date')),
                                  fixedWidth: 100,
                                ),
                                DataColumn2(
                                  label: Center(child: Text('Warranty')),
                                  fixedWidth: 90,
                                ),
                                DataColumn2(
                                  label: Center(child: Text('Status')),
                                  fixedWidth: 110,
                                ),
                                DataColumn2(
                                    label: Center(child: Text('Sales Person')),
                                    size: ColumnSize.S
                                ),
                                DataColumn2(
                                  label: Center(child: Text('Modify Date')),
                                  fixedWidth: 100,
                                ),
                                DataColumn2(
                                  label: Center(child: Text('Action')),
                                  fixedWidth: 55,
                                ),
                              ],
                              rows: viewModel.searched ? List<DataRow>.generate(viewModel.filterProductInventoryList.length, (index) => DataRow(cells: [
                                DataCell(Center(child: Text('${index + 1}'))),
                                DataCell(Center(child: Text(viewModel.filterProductInventoryList[index].categoryName))),
                                DataCell(Center(child: Text(viewModel.filterProductInventoryList[index].modelName))),
                                DataCell(
                                  Center(
                                    child: SelectableText(
                                        viewModel.filterProductInventoryList[index].deviceId, style: const TextStyle(fontSize: 12)
                                    ),
                                  ),
                                ),
                                DataCell(Center(child: Text(viewModel.filterProductInventoryList[index].dateOfManufacturing))),
                                DataCell(Center(child: Text('${viewModel.filterProductInventoryList[index].warrantyMonths}'))),
                                DataCell(
                                    userRole.name == 'admin'? Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(radius: 5,
                                          backgroundColor:
                                          viewModel.filterProductInventoryList[index].productStatus==1? Colors.pink:
                                          viewModel.filterProductInventoryList[index].productStatus==2? Colors.blue:
                                          viewModel.filterProductInventoryList[index].productStatus==3? Colors.purple:
                                          viewModel.filterProductInventoryList[index].productStatus==4? Colors.yellow:
                                          viewModel.filterProductInventoryList[index].productStatus==5? Colors.deepOrangeAccent:
                                          Colors.green,
                                        ),
                                        const SizedBox(width: 5,),
                                        viewModel.filterProductInventoryList[index].productStatus==1? const Text('In-Stock'):
                                        viewModel.filterProductInventoryList[index].productStatus==2? const Text('Stock'):
                                        viewModel.filterProductInventoryList[index].productStatus==3? const Text('Sold-Out'):
                                        const Text('Active'),
                                      ],
                                    ):
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(radius: 5,
                                          backgroundColor:
                                          viewModel.filterProductInventoryList[index].productStatus==1? Colors.pink:
                                          viewModel.filterProductInventoryList[index].productStatus==2? Colors.purple:
                                          viewModel.filterProductInventoryList[index].productStatus==3? Colors.yellow:
                                          Colors.green,
                                        ),
                                        const SizedBox(width: 5,),
                                        viewModel.filterProductInventoryList[index].productStatus==2? const Text('In-Stock'):
                                        viewModel.filterProductInventoryList[index].productStatus==3? const Text('Sold-Out'):
                                        const Text('Active'),
                                      ],
                                    )
                                ),
                                DataCell(Center(child: userName==viewModel.filterProductInventoryList[index].latestBuyer? Text('-'):Text(viewModel.filterProductInventoryList[index].latestBuyer))),
                                const DataCell(Center(child: Text('25-09-2023'))),
                                userRole.name == 'admin' ? DataCell(Center(child: IconButton(tooltip:'Edit product', onPressed: () {
                                  viewModel.getModelByActiveList(context, viewModel.filterProductInventoryList[index].categoryId, viewModel.filterProductInventoryList[index].categoryName,
                                      viewModel.filterProductInventoryList[index].modelName, viewModel.filterProductInventoryList[index].modelId, viewModel.filterProductInventoryList[index].deviceId,
                                      viewModel.filterProductInventoryList[index].warrantyMonths, viewModel.filterProductInventoryList[index].productId, userId);
                                }, icon: const Icon(Icons.edit_outlined),))):
                                DataCell(Center(child: IconButton(tooltip:'replace product',onPressed: () {
                                  viewModel.displayReplaceProductDialog(context, viewModel.filterProductInventoryList[index].categoryId, viewModel.filterProductInventoryList[index].categoryName,
                                      viewModel.filterProductInventoryList[index].modelName, viewModel.filterProductInventoryList[index].modelId, viewModel.filterProductInventoryList[index].deviceId,
                                      viewModel.filterProductInventoryList[index].warrantyMonths, viewModel.filterProductInventoryList[index].productId, viewModel.filterProductInventoryList[index].buyerId,viewModel.filterProductInventoryList[index].modelId);
                                }, icon: const Icon(Icons.repeat),)))
                              ])):
                              List<DataRow>.generate(viewModel.productInventoryList.length, (index) => DataRow(cells: [
                                DataCell(Center(child: Text('${index + 1}', style: const TextStyle(fontSize: 12),))),
                                DataCell(Center(child: Text(viewModel.productInventoryList[index].categoryName, style: const TextStyle(fontSize: 12)))),
                                DataCell(Center(child: Text(viewModel.productInventoryList[index].modelName, style: const TextStyle(fontSize: 12)))),
                                DataCell(Center(child: SelectableText(viewModel.productInventoryList[index].deviceId, style: const TextStyle(fontSize: 12),))),
                                DataCell(Center(child: Text(viewModel.productInventoryList[index].dateOfManufacturing, style: const TextStyle(fontSize: 12)))),
                                DataCell(Center(child: Text('${viewModel.productInventoryList[index].warrantyMonths}', style: const TextStyle(fontSize: 12)))),
                                DataCell(
                                  userRole.name == 'admin'? Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(radius: 5,
                                        backgroundColor:
                                        viewModel.productInventoryList[index].productStatus==1? Colors.pink:
                                        viewModel.productInventoryList[index].productStatus==2? Colors.blue:
                                        viewModel.productInventoryList[index].productStatus==3? Colors.purple:
                                        Colors.green,
                                      ),
                                      const SizedBox(width: 5,),
                                      viewModel.productInventoryList[index].productStatus==1? const Text('In-Stock', style: const TextStyle(fontSize: 12)):
                                      viewModel.productInventoryList[index].productStatus==2? const Text('Stock', style: const TextStyle(fontSize: 12)):
                                      viewModel.productInventoryList[index].productStatus==3? const Text('Sold-Out', style: const TextStyle(fontSize: 12)):
                                      const Text('Active', style: TextStyle(fontSize: 12)),
                                    ],
                                  ):
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(radius: 5,
                                        backgroundColor:
                                        viewModel.productInventoryList[index].productStatus==1? Colors.pink:
                                        viewModel.productInventoryList[index].productStatus==2? Colors.purple:
                                        viewModel.productInventoryList[index].productStatus==3? Colors.yellow:
                                        Colors.green,
                                      ),
                                      const SizedBox(width: 5,),
                                      viewModel.productInventoryList[index].productStatus==2? const Text('In-Stock', style: const TextStyle(fontSize: 12)):
                                      viewModel.productInventoryList[index].productStatus==3? const Text('Sold-Out', style: const TextStyle(fontSize: 12)):
                                      const Text('Active', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                DataCell(Center(child: userName==viewModel.productInventoryList[index].latestBuyer? Text('-'):Text(viewModel.productInventoryList[index].latestBuyer, style: const TextStyle(fontSize: 12)))),
                                const DataCell(Center(child: Text('25-09-2023', style: TextStyle(fontSize: 12)))),
                                userRole.name == 'admin' ? DataCell(Center(child: IconButton(tooltip:'Edit product', onPressed: () {
                                  viewModel.getModelByActiveList(context, viewModel.productInventoryList[index].categoryId, viewModel.productInventoryList[index].categoryName,
                                      viewModel.productInventoryList[index].modelName, viewModel.productInventoryList[index].modelId, viewModel.productInventoryList[index].deviceId,
                                      viewModel.productInventoryList[index].warrantyMonths, viewModel.productInventoryList[index].productId, userId);
                                }, icon: const Icon(Icons.edit_outlined),))):
                                DataCell(Center(child: IconButton(tooltip:'replace product',onPressed: () {
                                  viewModel.displayReplaceProductDialog(context, viewModel.productInventoryList[index].categoryId, viewModel.productInventoryList[index].categoryName,
                                      viewModel.productInventoryList[index].modelName, viewModel.productInventoryList[index].modelId, viewModel.productInventoryList[index].deviceId,
                                      viewModel.productInventoryList[index].warrantyMonths, viewModel.productInventoryList[index].productId, viewModel.productInventoryList[index].buyerId,
                                      viewModel.productInventoryList[index].modelId);
                                }, icon: const Icon(Icons.repeat),)))
                              ])),
                            ),
                          ),
                          viewModel.isLoadingMore ? Container(
                            width: double.infinity,
                            height: 30,
                            color: Colors.white,
                            padding: EdgeInsets.fromLTRB(MediaQuery.sizeOf(context).width/2 - 60, 0, MediaQuery.sizeOf(context).width/2 - 60, 0),
                            child: const LoadingIndicator(
                              indicatorType: Indicator.ballPulse,
                            ),
                          ):
                          Container(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
