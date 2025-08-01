import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/search_provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';
import '../../view_models/admin_dealer/inventory_view_model.dart';

class ProductInventory extends StatefulWidget {
  const ProductInventory({super.key, required this.userId, required this.userName, required this.userRole});
  final int userId;
  final String userName;
  final UserRole userRole;

  @override
  State<ProductInventory> createState() => _ProductInventoryState();
}

class _ProductInventoryState extends State<ProductInventory> {
  late InventoryViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = InventoryViewModel(Repository(HttpService()), widget.userId, widget.userRole);
    viewModel.loadInventoryData(1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final searchProvider = context.watch<SearchProvider>();

    if (searchProvider.isSearchProduct &&
        !searchProvider.hasHandledSearch &&
        (searchProvider.searchValue.isNotEmpty ||
            searchProvider.filteredCategoryId != 0 ||
            searchProvider.filteredModelId != 0)) {

      if (searchProvider.searchValue.isNotEmpty) {
        viewModel.fetchFilterData(null, null, searchProvider.searchValue, widget.userRole, widget.userId);
      } else if (searchProvider.filteredCategoryId != 0) {
        viewModel.fetchFilterData(searchProvider.filteredCategoryId, null, null, widget.userRole, widget.userId);
      } else if (searchProvider.filteredModelId != 0) {
        viewModel.fetchFilterData(null, searchProvider.filteredModelId, null, widget.userRole, widget.userId);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchProvider.markSearchHandled();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<InventoryViewModel>(
        builder: (context, viewModel, _) {
          // The rest of your UI stays the same
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
              )
                  : Column(
                    children: [
                      Expanded(
                        child: DataTable2(
                          scrollController: viewModel.scrollController,
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 1200,
                          dataRowHeight: 35.0,
                          headingRowHeight: 30,
                          headingRowColor: WidgetStateProperty.all<Color>(Colors.cyan.shade50),
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
                                widget.userRole.name == 'admin'? Row(
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
                            DataCell(Center(child: widget.userName==viewModel.filterProductInventoryList[index].latestBuyer? Text('-'):Text(viewModel.filterProductInventoryList[index].latestBuyer))),
                            const DataCell(Center(child: Text('25-09-2023'))),
                            widget.userRole.name == 'admin' ? DataCell(Center(child:
                            IconButton(tooltip:'Edit product', onPressed: () {
                              viewModel.getModelByActiveList(context, viewModel.filterProductInventoryList[index].categoryId, viewModel.filterProductInventoryList[index].categoryName,
                                  viewModel.filterProductInventoryList[index].modelName, viewModel.filterProductInventoryList[index].modelId, viewModel.filterProductInventoryList[index].deviceId,
                                  viewModel.filterProductInventoryList[index].warrantyMonths, viewModel.filterProductInventoryList[index].productId, widget.userId);
                            },
                              icon: const Icon(Icons.edit_outlined),))):
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
                              widget.userRole.name == 'admin'? Row(
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
                            DataCell(Center(child: widget.userName==viewModel.productInventoryList[index].latestBuyer? const Text('-'):Text(viewModel.productInventoryList[index].latestBuyer, style: const TextStyle(fontSize: 12)))),
                            const DataCell(Center(child: Text('25-09-2023', style: TextStyle(fontSize: 12)))),
                            widget.userRole.name == 'admin' ? DataCell(Center(child: IconButton(tooltip:'Edit product', onPressed: () {
                              viewModel.getModelByActiveList(context, viewModel.productInventoryList[index].categoryId, viewModel.productInventoryList[index].categoryName,
                                  viewModel.productInventoryList[index].modelName, viewModel.productInventoryList[index].modelId, viewModel.productInventoryList[index].deviceId,
                                  viewModel.productInventoryList[index].warrantyMonths, viewModel.productInventoryList[index].productId, widget.userId);
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
                        height: 20,
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(MediaQuery.sizeOf(context).width/2 - 30, 0, MediaQuery.sizeOf(context).width/2 - 60, 0),
                        child: const LoadingIndicator(
                          indicatorType: Indicator.ballPulse,
                        ),
                      ):
                      Container(),
                    ],
                  ) // rest of your DataTable2 UI
          );
        },
      ),
    );
  }
}


/*class ProductInventory extends StatelessWidget {
  const ProductInventory({super.key, required this.userId, required this.userName, required this.userRole});
  final int userId;
  final String userName;
  final UserRole userRole;

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => InventoryViewModel(Repository(HttpService()),userId, userRole)..loadInventoryData(1),
      child: Consumer<InventoryViewModel>(
        builder: (context, viewModel, _) {

          final searchValue = context.watch<SearchProvider>().searchValue;
          final searchCatID = context.watch<SearchProvider>().filteredCategoryId;
          final searchModID = context.watch<SearchProvider>().filteredModelId;

          final isSearchProduct = context.watch<SearchProvider>().isSearchProduct;

          if(isSearchProduct){
            if(searchValue.isNotEmpty || searchCatID!=0 || searchModID!=0){
              if(searchValue.isNotEmpty){
                viewModel.fetchFilterData(null, null, searchValue, userRole, userId);
              }else if(searchCatID!=0){
                viewModel.fetchFilterData(searchCatID, null, null, userRole, userId);
              }else if(searchModID!=0){
                viewModel.fetchFilterData(null, searchModID, null, userRole, userId);
              }

              Future.delayed(const Duration(milliseconds: 500), () {
                context.read<SearchProvider>().updateSearch('');
                context.read<SearchProvider>().updateCategoryId(0);
                context.read<SearchProvider>().updateModelId(0);
              });
            }
          }else{
            viewModel.clearSearch();
          }

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
                        headingRowColor: WidgetStateProperty.all<Color>(Colors.cyan.shade50),
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
                          userRole.name == 'admin' ? DataCell(Center(child:
                          IconButton(tooltip:'Edit product', onPressed: () {
                            viewModel.getModelByActiveList(context, viewModel.filterProductInventoryList[index].categoryId, viewModel.filterProductInventoryList[index].categoryName,
                                viewModel.filterProductInventoryList[index].modelName, viewModel.filterProductInventoryList[index].modelId, viewModel.filterProductInventoryList[index].deviceId,
                                viewModel.filterProductInventoryList[index].warrantyMonths, viewModel.filterProductInventoryList[index].productId, userId);
                          },
                            icon: const Icon(Icons.edit_outlined),))):
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
                      height: 20,
                      color: Colors.white,
                      padding: EdgeInsets.fromLTRB(MediaQuery.sizeOf(context).width/2 - 30, 0, MediaQuery.sizeOf(context).width/2 - 60, 0),
                      child: const LoadingIndicator(
                        indicatorType: Indicator.ballPulse,
                      ),
                    ):
                    Container(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}*/
