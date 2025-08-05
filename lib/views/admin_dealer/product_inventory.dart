import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/search_provider.dart';
import '../../providers/user_provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';
import '../../view_models/admin_dealer/inventory_view_model.dart';

class ProductInventory extends StatefulWidget {
  const ProductInventory({super.key});

  @override
  State<ProductInventory> createState() => _ProductInventoryState();
}

class _ProductInventoryState extends State<ProductInventory> {
  late InventoryViewModel viewModel;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final viewedCustomer = Provider.of<UserProvider>(context, listen: false).viewedCustomer!;
      viewModel = InventoryViewModel(Repository(HttpService()), viewedCustomer.id, viewedCustomer.role);
      viewModel.loadInventoryData(1);
      _isInitialized = true;
    }

    final searchProvider = context.watch<SearchProvider>();

    if (searchProvider.isSearchProduct &&
        !searchProvider.hasHandledSearch &&
        (searchProvider.searchValue.isNotEmpty ||
            searchProvider.filteredCategoryId != 0 ||
            searchProvider.filteredModelId != 0)) {

      if (searchProvider.searchValue.isNotEmpty) {
        viewModel.fetchFilterData(null, null, searchProvider.searchValue);
      } else if (searchProvider.filteredCategoryId != 0) {
        viewModel.fetchFilterData(searchProvider.filteredCategoryId, null, null);
      } else if (searchProvider.filteredModelId != 0) {
        viewModel.fetchFilterData(null, searchProvider.filteredModelId, null);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        searchProvider.markSearchHandled();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewedCustomer = Provider.of<UserProvider>(context).viewedCustomer;
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<InventoryViewModel>(
        builder: (context, vm, _) {

          print("viewModel.userRole:${vm.userRole}");
          return Scaffold(
              backgroundColor: Theme.of(context).primaryColorDark.withAlpha(1),
              body: vm.isLoading? Center(
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
                          scrollController: vm.scrollController,
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 1200,
                          dataRowHeight: 35.0,
                          headingRowHeight: 30,
                          headingRowColor: WidgetStateProperty.all<Color>(Colors.cyan.shade50),
                          columns: const [
                            DataColumn2(
                                label: Center(child: Text('S.No', style: TextStyle(fontWeight: FontWeight.bold))),
                                fixedWidth: 70
                            ),
                            DataColumn2(
                                label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                                size: ColumnSize.S
                            ),
                            DataColumn2(
                                label: Text('Model', style: TextStyle(fontWeight: FontWeight.bold)),
                                size: ColumnSize.M
                            ),
                            DataColumn2(
                              label: Text('Device Id', style: TextStyle(fontWeight: FontWeight.bold)),
                                size: ColumnSize.S
                            ),
                            DataColumn2(
                              label: Center(child: Text('M.Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              fixedWidth: 100,
                            ),
                            DataColumn2(
                              label: Center(child: Text('Warranty', style: TextStyle(fontWeight: FontWeight.bold))),
                              fixedWidth: 90,
                            ),
                            DataColumn2(
                              label: Center(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              fixedWidth: 110,
                            ),
                            DataColumn2(
                                label: Text('Sales Person', style: TextStyle(fontWeight: FontWeight.bold)),
                                size: ColumnSize.S
                            ),
                            DataColumn2(
                              label: Center(child: Text('Modify Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              fixedWidth: 100,
                            ),
                            DataColumn2(
                              label: Center(child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                              fixedWidth: 55,
                            ),
                          ],
                          rows: vm.searched ? List<DataRow>.generate(vm.filterProductInventoryList.length, (index) => DataRow(cells: [
                            DataCell(Center(child: Text('${index + 1}'))),
                            DataCell(Center(child: Text(vm.filterProductInventoryList[index].categoryName))),
                            DataCell(Center(child: Text(vm.filterProductInventoryList[index].modelName))),
                            DataCell(Center(
                                child: SelectableText(
                                    vm.filterProductInventoryList[index].deviceId, style: const TextStyle(fontSize: 12)
                                ),
                              ),
                            ),
                            DataCell(Center(child: Text(vm.filterProductInventoryList[index].dateOfManufacturing))),
                            DataCell(Center(child: Text('${vm.filterProductInventoryList[index].warrantyMonths}'))),
                            DataCell(
                                vm.userRole == UserRole.admin ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(radius: 5,
                                      backgroundColor:
                                      vm.filterProductInventoryList[index].productStatus==1? Colors.pink:
                                      vm.filterProductInventoryList[index].productStatus==2? Colors.blue:
                                      vm.filterProductInventoryList[index].productStatus==3? Colors.purple:
                                      vm.filterProductInventoryList[index].productStatus==4? Colors.yellow:
                                      vm.filterProductInventoryList[index].productStatus==5? Colors.deepOrangeAccent:
                                      Colors.green,
                                    ),
                                    const SizedBox(width: 5),
                                    vm.filterProductInventoryList[index].productStatus==1? const Text('In-Stock'):
                                    vm.filterProductInventoryList[index].productStatus==2? const Text('Stock'):
                                    vm.filterProductInventoryList[index].productStatus==3? const Text('Sold-Out'):
                                    const Text('Active'),
                                  ],
                                ):
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(radius: 5,
                                      backgroundColor:
                                      vm.filterProductInventoryList[index].productStatus==1? Colors.pink:
                                      vm.filterProductInventoryList[index].productStatus==2? Colors.purple:
                                      vm.filterProductInventoryList[index].productStatus==3? Colors.yellow:
                                      Colors.green,
                                    ),
                                    const SizedBox(width: 5,),
                                    vm.filterProductInventoryList[index].productStatus==2? const Text('In-Stock'):
                                    vm.filterProductInventoryList[index].productStatus==3? const Text('Sold-Out'):
                                    const Text('Active'),
                                  ],
                                )
                            ),
                            DataCell(Center(child: viewedCustomer!.name == vm.filterProductInventoryList[index].latestBuyer? Text('-'):Text(viewModel.filterProductInventoryList[index].latestBuyer))),
                            const DataCell(Center(child: Text('25-09-2023'))),
                            vm.userRole == UserRole.admin ? DataCell(Center(child:
                            IconButton(tooltip:'Edit product', onPressed: () {
                              vm.getModelByActiveList(context, vm.filterProductInventoryList[index].categoryId, vm.filterProductInventoryList[index].categoryName,
                                  vm.filterProductInventoryList[index].modelName, vm.filterProductInventoryList[index].modelId, viewModel.filterProductInventoryList[index].deviceId,
                                  vm.filterProductInventoryList[index].warrantyMonths, vm.filterProductInventoryList[index].productId, viewedCustomer.id);
                            },
                              icon: const Icon(Icons.edit_outlined),))):
                            DataCell(Center(child: IconButton(tooltip:'replace product',onPressed: () {
                              vm.displayReplaceProductDialog(context, vm.filterProductInventoryList[index].categoryId, vm.filterProductInventoryList[index].categoryName,
                                  vm.filterProductInventoryList[index].modelName, vm.filterProductInventoryList[index].modelId, viewModel.filterProductInventoryList[index].deviceId,
                                  vm.filterProductInventoryList[index].warrantyMonths, vm.filterProductInventoryList[index].productId, viewModel.filterProductInventoryList[index].buyerId,viewModel.filterProductInventoryList[index].modelId);
                            }, icon: const Icon(Icons.repeat),)))
                          ])):
                          List<DataRow>.generate(
                              vm.productInventoryList.length, (index) => DataRow(
                              color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                  return index % 2 == 0 ? Colors.white : Colors.grey.shade100;
                                },
                              ),
                              cells: [
                                DataCell(Center(child: Text('${index + 1}', style: const TextStyle(fontSize: 12),))),
                                DataCell(Text(vm.productInventoryList[index].categoryName, style: const TextStyle(fontSize: 12))),
                                DataCell(Text(vm.productInventoryList[index].modelName, style: const TextStyle(fontSize: 12))),
                                DataCell(SelectableText(vm.productInventoryList[index].deviceId, style: const TextStyle(fontSize: 12),)),
                                DataCell(Center(child: Text(vm.productInventoryList[index].dateOfManufacturing, style: const TextStyle(fontSize: 12)))),
                                DataCell(Center(child: Text('${vm.productInventoryList[index].warrantyMonths}', style: const TextStyle(fontSize: 12)))),
                                DataCell(
                                  vm.userRole == UserRole.admin? Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(radius: 5,
                                        backgroundColor:
                                        vm.productInventoryList[index].productStatus==1? Colors.pink:
                                        vm.productInventoryList[index].productStatus==2? Colors.blue:
                                        vm.productInventoryList[index].productStatus==3? Colors.purple:
                                        Colors.green,
                                      ),
                                      const SizedBox(width: 5,),
                                      vm.productInventoryList[index].productStatus==1? const Text('In-Stock', style: const TextStyle(fontSize: 12)):
                                      vm.productInventoryList[index].productStatus==2? const Text('Stock', style: const TextStyle(fontSize: 12)):
                                      vm.productInventoryList[index].productStatus==3? const Text('Sold-Out', style: const TextStyle(fontSize: 12)):
                                      const Text('Active', style: TextStyle(fontSize: 12)),
                                    ],
                                  ):
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(radius: 5,
                                        backgroundColor:
                                        vm.productInventoryList[index].productStatus==1? Colors.pink:
                                        vm.productInventoryList[index].productStatus==2? Colors.purple:
                                        vm.productInventoryList[index].productStatus==3? Colors.yellow:
                                        Colors.green,
                                      ),
                                      const SizedBox(width: 5,),
                                      vm.productInventoryList[index].productStatus==2? const Text('In-Stock', style: const TextStyle(fontSize: 12)):
                                      vm.productInventoryList[index].productStatus==3? const Text('Sold-Out', style: const TextStyle(fontSize: 12)):
                                      const Text('Active', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                DataCell(viewedCustomer!.name == vm.productInventoryList[index].latestBuyer? const Text('-'):Text(viewModel.productInventoryList[index].latestBuyer, style: const TextStyle(fontSize: 12))),
                                const DataCell(Center(child: Text('25-09-2023', style: TextStyle(fontSize: 12)))),
                                vm.userRole == UserRole.admin ? DataCell(Center(child: IconButton(tooltip:'Edit product', onPressed: () {
                                  print('kamaraj');
                                  vm.getModelByActiveList(context, vm.productInventoryList[index].categoryId, vm.productInventoryList[index].categoryName,
                                      vm.productInventoryList[index].modelName, vm.productInventoryList[index].modelId, vm.productInventoryList[index].deviceId,
                                      vm.productInventoryList[index].warrantyMonths, vm.productInventoryList[index].productId, viewedCustomer.id
                                  );
                                }, icon: const Icon(Icons.edit_outlined),))):
                                DataCell(Center(child: IconButton(tooltip:'replace product',onPressed: () {
                                  vm.displayReplaceProductDialog(context, vm.productInventoryList[index].categoryId, vm.productInventoryList[index].categoryName,
                                      vm.productInventoryList[index].modelName, vm.productInventoryList[index].modelId, vm.productInventoryList[index].deviceId,
                                      vm.productInventoryList[index].warrantyMonths, vm.productInventoryList[index].productId, vm.productInventoryList[index].buyerId,
                                      vm.productInventoryList[index].modelId);
                                }, icon: const Icon(Icons.repeat),)))
                              ])
                          ),
                        ),
                      ),
                      vm.isLoadingMore ? Container(
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