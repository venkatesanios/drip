import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/modules/config_Maker/view/config_base_page.dart';
import 'package:provider/provider.dart';
import '../../models/admin_dealer/stock_model.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/formatters.dart';
import '../../view_models/admin_dealer/customer_device_list_view_model.dart';

enum MasterController {gem1, gem2, gem3, gem4, gem5, gem6, gem7, gem8, gem9, gem10,}

class CustomerDeviceList extends StatefulWidget {
  const CustomerDeviceList({
    super.key,
    required this.userId,
    required this.customerName,
    required this.customerId,
    required this.userRole,
    required this.productStockList,
    required this.onCustomerProductChanged,
  });

  final int userId, customerId;
  final String userRole, customerName;
  final List<StockModel> productStockList;

  final void Function(String action) onCustomerProductChanged;

  @override
  State<CustomerDeviceList> createState() => _CustomerDeviceListState();
}

class _CustomerDeviceListState extends State<CustomerDeviceList> with TickerProviderStateMixin {
  late TabController tabController;
  late CustomerDeviceListViewModel viewModel;
  final List<String> tabList = ['Product List', 'Site'];
  int currentSiteInx = 0;

  @override
  void initState() {
    super.initState();
    viewModel = CustomerDeviceListViewModel(
      Repository(HttpService()),
      widget.userId,
      widget.customerId,
      widget.productStockList.length,
      onProductUpdatedCallback: (result) {
        widget.onCustomerProductChanged(result);
      },
    );
    tabController = TabController(length: tabList.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => viewModel..loadDeviceList(1)..getCustomerSite()..getMasterProduct(),
      child: Consumer<CustomerDeviceListViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.customerName, style: const TextStyle(fontSize: 16)),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.redAccent),
                tooltip: "Close",
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                _buildActionPopup(context),
                const SizedBox(width: 20),
              ],
              bottom: TabBar(
                controller: tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.4),
                tabs: tabList.map((label) => Tab(child: Text(label))).toList(),
              ),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: tabController,
              children: [
                const CustomerDeviceTable(),
                CustomerSiteTabView(
                  viewModel: viewModel,
                  currentSiteInx: currentSiteInx,
                  onSiteChange: (index) => setState(() => currentSiteInx = index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionPopup(BuildContext context) {
    return PopupMenuButton(
      tooltip: tabController.index == 0
          ? 'Add new product to ${widget.customerName}'
          : 'Create new site for ${widget.customerName}',
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
          side: const BorderSide(color: Colors.white54, width: 0.5),
        ),
        onPressed: null,
        textColor: Colors.white,
        child: Row(
          children: [
            Text(tabController.index == 0 ? 'Add New Product' : 'Create New Site'),
            const SizedBox(width: 3),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
      onCanceled: () {
        viewModel.selectedProducts = List<bool>.filled(widget.productStockList.length, false);
      },
      itemBuilder: (context) {
        return tabController.index == 0
            ? _buildProductListPopup(context)
            : _buildMasterSitePopup(context);
      },
    );
  }

  List<PopupMenuEntry> _buildProductListPopup(BuildContext context) {
    if (widget.productStockList.isEmpty) {
      return [const PopupMenuItem(child: Text('No stock available'))];
    }

    return List.generate(widget.productStockList.length + 1, (index) {
      if (index == widget.productStockList.length) {
        return PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('ADD'),
                onPressed: () => viewModel.addProductToCustomer(context, widget.productStockList),
              ),
            ],
          ),
        );
      }

      return PopupMenuItem(
        child: StatefulBuilder(
          builder: (context, setState) {
            return CheckboxListTile(
              title: Text(widget.productStockList[index].categoryName),
              subtitle: Text(widget.productStockList[index].imeiNo),
              value: viewModel.selectedProducts[index],
              onChanged: (value) {
                setState(() {
                  viewModel.toggleProductSelection(index);
                });
              },
            );
          },
        ),
      );
    });
  }

  List<PopupMenuEntry> _buildMasterSitePopup(BuildContext context) {
    if (viewModel.myMasterControllerList.isEmpty) {
      return [const PopupMenuItem(child: Text('No master available to create site'))];
    }

    return List.generate(viewModel.myMasterControllerList.length + 1, (index) {
      if (index == viewModel.myMasterControllerList.length) {
        return PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('CANCEL'),
                onPressed: () => Navigator.pop(context),
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('CREATE'),
                onPressed: () {
                  Navigator.pop(context);
                  final selected = viewModel.myMasterControllerList[viewModel.selectedRadioTile];
                  viewModel.displayCustomerSiteDialog(
                    context,
                    selected.categoryName,
                    selected.model,
                    selected.imeiNo.toString(),
                  );
                },
              ),
            ],
          ),
        );
      }

      final master = viewModel.myMasterControllerList[index];

      return PopupMenuItem(
        value: index,
        child: AnimatedBuilder(
          animation: viewModel.selectedItem,
          builder: (context, child) {
            return RadioListTile(
              value: MasterController.values[index],
              groupValue: viewModel.selectedItem.value,
              title: Text(master.categoryName),
              subtitle: Text(master.imeiNo),
              onChanged: (value) {
                viewModel.selectedItem.value = value!;
                viewModel.selectedRadioTile = value.index;
              },
            );
          },
        ),
      );
    });
  }
}

class CustomerDeviceTable extends StatelessWidget {
  const CustomerDeviceTable({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CustomerDeviceListViewModel>(context);

    return Column(
      children: [
        Expanded(
          child: viewModel.customerDeviceList.isNotEmpty
              ? DataTable2(
            scrollController: viewModel.scrollController,
            columnSpacing: 12,
            horizontalMargin: 12,
            headingRowHeight: 30,
            headingRowColor: WidgetStateProperty.all<Color>(
              Theme.of(context).primaryColorDark.withAlpha(1),
            ),
            dataRowHeight: 35,
            minWidth: 580,
            columns: const [
              DataColumn2(label: Text('S.No'), fixedWidth: 40),
              DataColumn2(label: Text('Category'), size: ColumnSize.M),
              DataColumn2(label: Text('Model'), size: ColumnSize.M),
              DataColumn2(label: Text('IMEI'), size: ColumnSize.M),
              DataColumn2(label: Text('Status'), fixedWidth: 80),
              DataColumn2(label: Text('Modify Date'), fixedWidth: 110),
            ],
            rows: List.generate(viewModel.customerDeviceList.length, (index) {
              final device = viewModel.customerDeviceList[index];
              return DataRow(cells: [
                DataCell(Center(child: Text('${index + 1}', style: viewModel.commonTextStyle))),
                DataCell(Text(device.categoryName, style: viewModel.commonTextStyle)),
                DataCell(Text(device.model, style: viewModel.commonTextStyle)),
                DataCell(SelectableText(device.deviceId, style: viewModel.commonTextStyle)),
                DataCell(Center(
                  child: Row(
                    children: [
                      CircleAvatar(radius: 5, backgroundColor: _getStatusColor(device.productStatus)),
                      const SizedBox(width: 5),
                      Text(_getStatusText(device.productStatus), style: viewModel.commonTextStyle),
                    ],
                  ),
                )),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Formatters().formatDate(device.modifyDate),
                        style: viewModel.commonTextStyle,
                      ),
                      if (device.productStatus == 3) ...[
                        Tooltip(
                          message: 'Remove this product',
                          child: IconButton(
                            onPressed: () => viewModel.removeProductFromCustomer(device.productId),
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ]);
            }),
          )
              : const Center(child: Text('No device available')),
        ),
        if (viewModel.isLoading)
          Container(
            width: double.infinity,
            height: 30,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 300),
            child: const CircularProgressIndicator(),
          ),
      ],
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.pink;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.purple;
      default:
        return Colors.green;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'In-Stock';
      case 2:
        return 'Stock';
      case 3:
        return 'Free';
      default:
        return 'Active';
    }
  }
}

class CustomerSiteTabView extends StatelessWidget {
  final dynamic viewModel;
  final int currentSiteInx;
  final ValueChanged<int> onSiteChange;

  const CustomerSiteTabView({
    super.key,
    required this.viewModel,
    required this.currentSiteInx,
    required this.onSiteChange,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: viewModel.customerSiteList.length,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColor,
                  isScrollable: true,
                  tabs: [
                    for (var site in viewModel.customerSiteList)
                      Tab(text: site.groupName),
                  ],
                  onTap: onSiteChange,
                ),
              ),
              const AddMasterPopup(), // Widget 3
              const SizedBox(width: 10),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 160,
            child: TabBarView(
              children: [
                for (var site in viewModel.customerSiteList)
                  MasterListForSite(site: site, viewModel: viewModel)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddMasterPopup extends StatelessWidget {
  const AddMasterPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CustomerDeviceListViewModel>(context);
    return PopupMenuButton(
      elevation: 10,
      tooltip: 'Add New Master Controller',
      child: const Center(
        child: MaterialButton(
          onPressed: null,
          child: Row(
            children: [
              Icon(Icons.add, color: Colors.black),
              SizedBox(width: 3),
              Text('Add New Master', style: TextStyle(color: Colors.black)),
              SizedBox(width: 3),
              Icon(Icons.arrow_drop_down, color: Colors.black),
            ],
          ),
        ),
      ),
      onCanceled: () => viewModel.checkboxValue = false,
      itemBuilder: (context) {
        if (viewModel.myMasterControllerList.isEmpty) {
          return [const PopupMenuItem(child: Text('No master controller available'))];
        }

        return List.generate(viewModel.myMasterControllerList.length, (index) {
          final controller = viewModel.myMasterControllerList[index];
          return PopupMenuItem(
            value: index,
            child: Column(
              children: [
                RadioListTile<int>(
                  value: index,
                  groupValue: viewModel.selectedRadioTile,
                  title: Text(controller.categoryName),
                  subtitle: Text(controller.imeiNo),
                  onChanged: (value) {
                    viewModel.selectedRadioTile = value!;
                  },
                ),
                if (index == viewModel.myMasterControllerList.length - 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MaterialButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        child: const Text('CANCEL'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      MaterialButton(
                        color: Colors.teal,
                        textColor: Colors.white,
                        child: const Text('ADD'),
                        onPressed: () => viewModel.createNewMaster(context, viewModel.selectedRadioTile),
                      ),
                    ],
                  ),
              ],
            ),
          );
        });
      },
    );
  }
}

class MasterListForSite extends StatelessWidget {
  final dynamic site;
  final dynamic viewModel;

  const MasterListForSite({
    super.key,
    required this.site,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 160,
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (int mstIndex = 0; mstIndex < site.master.length; mstIndex++)
              Column(
                children: [
                  ListTile(
                    title: Text(site.master[mstIndex].categoryName,
                        style: const TextStyle(fontSize: 15)),
                    subtitle: SelectableText(
                        site.master[mstIndex].deviceId.toString(),
                        style: const TextStyle(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            // TODO: Reset Serial Connection
                          },
                          color: Colors.redAccent,
                          child: const Text('Reset Serial Connection',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        MaterialButton(
                          onPressed: () {
                            // TODO: Delete
                          },
                          color: Colors.redAccent,
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        MaterialButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                var masterData = site.master[mstIndex];
                                return ConfigBasePage(
                                  masterData: {
                                    "userId": viewModel.userId,
                                    "customerId": viewModel.customerId,
                                    "controllerId": masterData.controllerId,
                                    "productId": masterData.productId,
                                    "deviceId": masterData.deviceId,
                                    "deviceName": masterData.deviceName,
                                    "categoryId": masterData.categoryId,
                                    "categoryName": masterData.categoryName,
                                    "modelId": masterData.modelId,
                                    "modelName": masterData.modelName,
                                    "groupId": site.userGroupId,
                                    "groupName": site.groupName,
                                    "connectingObjectId": [
                                      ...masterData.outputObjectId.split(','),
                                      ...masterData.inputObjectId.split(','),
                                    ],
                                  },
                                );
                              }),
                            );
                          },
                          color: Colors.teal,
                          child: const Row(
                            children: [
                              Icon(Icons.confirmation_number_outlined,
                                  color: Colors.white),
                              SizedBox(width: 5),
                              Text('Site Config',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (site.master.length > 1) const Divider(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}