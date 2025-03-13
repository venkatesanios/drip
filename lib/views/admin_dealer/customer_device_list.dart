import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/config_maker/view/config_base_page.dart';
import 'package:provider/provider.dart';
import '../../models/admin&dealer/stock_model.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../view_models/admin&dealer/customer_device_list_view_model.dart';

enum MasterController {gem1, gem2, gem3, gem4, gem5, gem6, gem7, gem8, gem9, gem10,}

class CustomerDeviceList extends StatefulWidget {
  const CustomerDeviceList({
    super.key,
    required this.userId,
    required this.customerName,
    required this.customerId,
    required this.userRole,
    required this.productStockList,
    required this.onDeviceListAdded,
    required this.comingFrom,
  });

  final int userId, customerId;
  final String userRole, customerName, comingFrom;
  final List<StockModel> productStockList;
  final Function(Map<String, dynamic>) onDeviceListAdded;

  @override
  State<CustomerDeviceList> createState() => _CustomerDeviceListState();
}

class _CustomerDeviceListState extends State<CustomerDeviceList> with TickerProviderStateMixin {

  late TabController tabController;
  late CustomerDeviceListViewModel viewModel;
  List<Object> tabList = [];
  int currentSiteInx = 0;

  @override
  void initState() {
    super.initState();
    widget.comingFrom == 'Admin'?tabList = ['Products List', 'Site']:tabList = ['Products List'];
    viewModel = CustomerDeviceListViewModel(Repository(HttpService()), widget.userId, widget.customerId, widget.productStockList.length);
    tabController = TabController(length: tabList.length, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
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
              title: Text(
                widget.customerName,
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
                  color: Colors.white,
                  tooltip: tabController.index==0 ?'Add new product to ${widget.customerName}' : 'Create new site to ${widget.customerName}',
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                      side: const BorderSide(color: Colors.white54, width: 0.5),
                    ),
                    onPressed: null,
                    textColor: Colors.white,
                    child: Row(
                      children: [
                        Text(tabController.index==0 ?'Add New Product':'Create New site'),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                      ],
                    ),
                  ),
                  onCanceled: () {
                    viewModel.selectedProducts = List<bool>.filled(widget.productStockList.length, false);
                  },
                  itemBuilder: (context) {
                    return tabController.index==0 ?
                    List.generate(widget.productStockList.length + 1, (index) {
                      if (widget.productStockList.isEmpty) {
                        return const PopupMenuItem(
                          child: Text('No stock available to add in the site'),
                        );
                      } else if (widget.productStockList.length == index) {
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
                                onPressed: () => viewModel.addProductToCustomer(context, widget.productStockList, widget.onDeviceListAdded),
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
                              onChanged: (bool? value) {
                                setState(() {
                                  viewModel.toggleProductSelection(index);
                                });
                              },
                            );
                          },
                        ),
                      );
                    }):
                    List.generate(viewModel.myMasterControllerList.length+1 ,(index) {
                      if(viewModel.myMasterControllerList.isEmpty){
                        return const PopupMenuItem(
                          child: Text('No master available to create site'),
                        );
                      }
                      else if(viewModel.myMasterControllerList.length == index){
                        return PopupMenuItem(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              MaterialButton(
                                color: Colors.red,
                                textColor: Colors.white,
                                child: const Text('CANCEL'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              MaterialButton(
                                color: Colors.green,
                                textColor: Colors.white,
                                child: const Text('CREATE'),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  viewModel.displayCustomerSiteDialog(context, viewModel.myMasterControllerList[viewModel.selectedRadioTile].categoryName,
                                      viewModel.myMasterControllerList[viewModel.selectedRadioTile].model,
                                      viewModel.myMasterControllerList[viewModel.selectedRadioTile].imeiNo.toString());
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      return PopupMenuItem(
                        value: index,
                        child: AnimatedBuilder(
                            animation: viewModel.selectedItem,
                            builder: (context, child) {
                              return RadioListTile(
                                value: MasterController.values[index],
                                groupValue: viewModel.selectedItem.value,
                                title: child,  onChanged: (value) {
                                viewModel.selectedItem.value = value!;
                                viewModel.selectedRadioTile = value.index;
                              },
                                subtitle: Text(viewModel.myMasterControllerList[index].imeiNo),
                              );
                            },
                            child: Text(viewModel.myMasterControllerList[index].categoryName)

                        ),
                      );
                    },);
                  },
                ),
                const SizedBox(width: 20),
              ],
              bottom: TabBar(
                controller: tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.4),
                tabs: [
                  ...tabList.map((label) => Tab(
                    child: Text(label.toString(),),
                  )),
                ],
              ),
            ),
            body: viewModel.isLoading ? const Center(
              child: CircularProgressIndicator(),
            ):
            TabBarView(
              controller: tabController,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: viewModel.customerDeviceList.isNotEmpty? DataTable2(
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
                          viewModel.customerDeviceList.length,
                              (index) => DataRow(
                            cells: [
                              DataCell(Center(
                                child: Text(
                                  '${index + 1}',
                                  style: viewModel.commonTextStyle,
                                ),
                              )),
                              DataCell(Text(viewModel.customerDeviceList[index].categoryName,
                                  style: viewModel.commonTextStyle)),
                              DataCell(Text(viewModel.customerDeviceList[index].model,
                                  style: viewModel.commonTextStyle)),
                              DataCell(SelectableText(viewModel.customerDeviceList[index].deviceId,
                                  style: viewModel.commonTextStyle)),
                              DataCell(Center(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 5,
                                      backgroundColor: viewModel.customerDeviceList[index]
                                          .productStatus ==
                                          1
                                          ? Colors.pink
                                          : viewModel.customerDeviceList[index].productStatus == 2
                                          ? Colors.blue
                                          : viewModel.customerDeviceList[index].productStatus == 3
                                          ? Colors.purple
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      viewModel.customerDeviceList[index].productStatus == 1
                                          ? 'In-Stock'
                                          : viewModel.customerDeviceList[index].productStatus == 2
                                          ? 'Stock'
                                          : viewModel.customerDeviceList[index].productStatus == 3
                                          ? 'Free'
                                          : 'Active',
                                      style: viewModel.commonTextStyle,
                                    ),
                                  ],
                                ),
                              )),
                              DataCell(Text(
                                DateFormat('dd-MM-yyyy').format(DateTime.parse(
                                    viewModel.customerDeviceList[index].modifyDate)),
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
                DefaultTabController(
                  length: viewModel.customerSiteList.length, // Number of tabs
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
                                for (var i = 0; i < viewModel.customerSiteList.length; i++)
                                  Tab(text: viewModel.customerSiteList[i].groupName,),
                              ],
                              onTap: (index) {
                                currentSiteInx = index;
                                //getNodeStockList(customerSiteList[currentSiteInx].master[0].categoryId);
                              },
                            ),
                          ),
                          PopupMenuButton(
                            elevation: 10,
                            tooltip: 'Add New Master Controller',
                            child: const Center(
                              child: MaterialButton(
                                onPressed: null,
                                child: Row(
                                  children: [
                                    Icon(Icons.add, color: Colors.black),
                                    SizedBox(width: 3),
                                    Text(
                                      'Add New Master',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    SizedBox(width: 3),
                                    Icon(Icons.arrow_drop_down, color: Colors.black),
                                  ],
                                ),
                              ),
                            ),
                            onCanceled: () {
                              viewModel.checkboxValue = false; // Update checkbox state if needed
                            },
                            itemBuilder: (context) {
                              if (viewModel.myMasterControllerList.isEmpty) {
                                return [
                                  const PopupMenuItem(
                                    child: Text('No master controller available'),
                                  ),
                                ];
                              }

                              return List.generate(viewModel.myMasterControllerList.length, (index) {
                                return PopupMenuItem(
                                  value: index,
                                  child: Column(
                                    children: [
                                      RadioListTile<int>(
                                        value: index,
                                        groupValue: viewModel.selectedRadioTile,
                                        title: Text(viewModel.myMasterControllerList[index].categoryName),
                                        subtitle: Text(viewModel.myMasterControllerList[index].imeiNo),
                                        onChanged: (value) {
                                          setState(() {
                                            viewModel.selectedRadioTile = value!;
                                          });
                                        },
                                      ),
                                      // Optionally include a cancel and add button
                                      if (index == viewModel.myMasterControllerList.length - 1) ...[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            MaterialButton(
                                              color: Colors.red,
                                              textColor: Colors.white,
                                              child: const Text('CANCEL'),
                                              onPressed: () {
                                                Navigator.pop(context); // Close the menu
                                              },
                                            ),
                                            MaterialButton(
                                              color: Colors.teal,
                                              textColor: Colors.white,
                                              child: const Text('ADD'),
                                              onPressed: () => viewModel.createNewMaster(context, currentSiteInx),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              });
                            },
                          ),
                          const SizedBox(width: 10,),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height-160,
                        child: TabBarView(
                          children: [
                            for (int siteIndex = 0; siteIndex < viewModel.customerSiteList.length; siteIndex++)
                              SizedBox(
                                height: MediaQuery.sizeOf(context).height-160,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      for (int mstIndex = 0; mstIndex < viewModel.customerSiteList[siteIndex].master.length; mstIndex++)
                                        Column(
                                          children: [
                                            ListTile(
                                              title: Text(viewModel.customerSiteList[siteIndex].master[mstIndex].categoryName, style: const TextStyle(fontSize: 15),),
                                              subtitle: SelectableText(viewModel.customerSiteList[siteIndex].master[mstIndex].deviceId.toString(), style: const TextStyle(fontSize: 12),),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  MaterialButton(
                                                    onPressed:() async {
                                                      /*String payLoadFinal = jsonEncode({
                                                        "2400": [{"2401": "0"},]
                                                      });

                                                      MQTTManager().publish(payLoadFinal, 'AppToFirmware/${customerSiteList[siteIndex].master[mstIndex].deviceId}');

                                                      Map<String, Object> body = {"userId": widget.customerID, "controllerId": customerSiteList[siteIndex].master[mstIndex].deviceId, "messageStatus": 'Cleared node serial from site config', "hardware": jsonDecode(payLoadFinal), "createUser": widget.userID};
                                                      final response = await HttpService().postRequest("createUserSentAndReceivedMessageManually", body);
                                                      if (response.statusCode == 200) {
                                                        print(response.body);
                                                      } else {
                                                        throw Exception('Failed to load data');
                                                      }*/
                                                    },
                                                    textColor: Colors.white,
                                                    color: Colors.redAccent,
                                                    child: const Text('Reset Serial Connection',style: TextStyle(color: Colors.white)),
                                                  ),
                                                  const SizedBox(width: 8,),
                                                  MaterialButton(
                                                    onPressed:() async {
                                                      /*String payLoadFinal = jsonEncode({
                                                        "2400": [{"2401": "0"},]
                                                      });

                                                      Map<String, Object> body = {"userId": widget.customerID, "controllerId": customerSiteList[siteIndex].master[mstIndex].deviceId, "messageStatus": 'Cleared node serial from site config', "hardware": jsonDecode(payLoadFinal), "createUser": widget.userID};
                                                      final response = await HttpService().postRequest("createUserSentAndReceivedMessageManually", body);
                                                      if (response.statusCode == 200) {
                                                        print(response.body);
                                                      } else {
                                                        throw Exception('Failed to load data');
                                                      }*/
                                                    },
                                                    textColor: Colors.white,
                                                    color: Colors.redAccent,
                                                    child: const Text('Delete',style: TextStyle(color: Colors.white)),
                                                  ),
                                                  const SizedBox(width: 8,),
                                                  MaterialButton(
                                                    onPressed:() async {
                                                      Navigator.push(context, MaterialPageRoute(builder: (context){
                                                        var masterData = viewModel.customerSiteList[siteIndex].master[mstIndex];
                                                        return ConfigBasePage(
                                                          masterData: {
                                                            "userId": widget.userId,
                                                            "customerId": widget.customerId,
                                                            "controllerId": masterData.controllerId,
                                                            "deviceId": masterData.deviceId,
                                                            "deviceName": masterData.deviceName,
                                                            "categoryId": masterData.categoryId,
                                                            "categoryName": masterData.categoryName,
                                                            "modelId": masterData.modelId,
                                                            "modelName": masterData.modelName,
                                                            "groupId" : viewModel.customerSiteList[siteIndex].userGroupId,
                                                            "groupName" : viewModel.customerSiteList[siteIndex].groupName,
                                                            "connectingObjectId" : [...masterData.outputObjectId.split(','), ...masterData.inputObjectId.split(',')],
                                                          },
                                                        );
                                                      }));
                                                    },
                                                    textColor: Colors.white,
                                                    color: Colors.teal,
                                                    child: const Row(
                                                      children: [
                                                        Icon(Icons.confirmation_number_outlined, color: Colors.white),
                                                        SizedBox(width: 5,),
                                                        Text('Site Config',style: TextStyle(color: Colors.white)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            viewModel.customerSiteList[siteIndex].master.length>1?
                                            const Divider():const SizedBox(),
                                          ],
                                        ),
                                    ],
                                  ),
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
          );
        },
      ),
    );
  }

}