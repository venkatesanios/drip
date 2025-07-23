import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_drip_irrigation/utils/Theme/oro_theme.dart';
import 'package:oro_drip_irrigation/views/admin_dealer/sales_bar_chart.dart';
import 'package:provider/provider.dart';
import '../../flavors.dart';
import '../../models/admin_dealer/customer_list_model.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/constants.dart';
import '../../utils/snack_bar.dart';
import '../../view_models/admin_dealer/admin_dealer_dashboard_view_model.dart';
import '../create_account.dart';
import 'dealer_device_list.dart';
import 'dealer_screen_controller.dart';

enum MySegment {all, year}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key, required this.userId, required this.userName, required this.mobileNo});
  final int userId;
  final String userName, mobileNo;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminAndDealerDashboardViewModel(Repository(HttpService()), userId, 1)
        ..getMySalesData(userId, MySegment.all)
        ..getMyStock()
        ..getMyCustomers()
        ..getCategoryList(),
      child: Consumer<AdminAndDealerDashboardViewModel>(
        builder: (context, viewModel, _) {
          handleAccountCreated(viewModel, context);
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        buildAnalyticsCard(viewModel),
                        Expanded(
                          child: Card(
                            color: Colors.white,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 44,
                                  child: ListTile(
                                    title: const Text('My Dealers', style: TextStyle(fontSize: 17)),
                                    trailing: IconButton(
                                      tooltip: 'Create Dealer account',
                                      icon: const Icon(Icons.person_add_outlined),
                                      color: primaryDark,
                                      onPressed: () => openCreateDealerBottomSheet(context, viewModel, userId),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: buildProductList(context, viewModel),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  buildDealerListCard(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void handleAccountCreated(AdminAndDealerDashboardViewModel viewModel, BuildContext context) {
    if (viewModel.accountCreated) {
      viewModel.accountCreated = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GlobalSnackBar.show(context, viewModel.responseMsg, 200);
        viewModel.responseMsg = '';
      });
    }
  }

  Widget buildAnalyticsCard(AdminAndDealerDashboardViewModel viewModel) {
    return SizedBox(
      height: 360,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            children: [
              ListTile(
                title: AppConstants().anlOvrView,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildSegmentedButton(viewModel, userId),
                    const SizedBox(width: 16),
                    Text.rich(
                      TextSpan(
                        text: 'Total Sales: ',
                        style: const TextStyle(fontSize: 15),
                        children: [
                          TextSpan(
                            text: viewModel.totalSales.toString().padLeft(2, '0'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: viewModel.isLoadingSalesData
                    ? const Center(child: SizedBox(width: 40, child: LoadingIndicator(indicatorType: Indicator.ballPulse)))
                    : MySalesBarChart(graph: viewModel.mySalesData.graph),
              ),
              const SizedBox(height: 6),
              if ((viewModel.mySalesData.total ?? []).isNotEmpty)
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: List.generate(
                    viewModel.mySalesData.total!.length,
                        (index) => buildSalesChip(index, viewModel),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProductList(BuildContext context, AdminAndDealerDashboardViewModel viewModel) {

    /*return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 10,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1.0,
        ),
        itemCount: viewModel.categoryList.length,
        itemBuilder: (context, index) {
          final item = viewModel.categoryList[index];
          return Card(
            color: Colors.white,
            elevation: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: F.appFlavor!.name.contains('oro') ?
                Image.asset("assets/images/Png/Oro/category_${index+1}.png"):
                Image.asset("assets/images/Png/SmartComm/category_${index+1}.png")),
                Container(
                  height: 30,
                  color: Theme.of(context).primaryColorLight.withOpacity(0.2),
                  child: Center(
                    child: Text(item.categoryName, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );*/
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 600,
      headingRowColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColorLight.withOpacity(0.1)),
      headingRowHeight: 35,
      dataRowHeight: 40,
      columns: const [
        DataColumn(
          label: Text('Name',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text('Mobile No',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn2(
          label: Text(
            'E-mail Address',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('Address',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          fixedWidth: 100,
        ),
      ],
      rows: List<DataRow>.generate(
        viewModel.myCustomerList.length, (index) => DataRow(
        cells: [
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage("assets/png/user_thumbnail.png"),
                backgroundColor: Colors.transparent,
                radius: 14,
              ),
              const SizedBox(width: 12),
              Text(viewModel.myCustomerList[index].userName),
            ],
          )),
          DataCell(Text('+ ${viewModel.myCustomerList[index].countryCode} ${viewModel.myCustomerList[index].mobileNumber}')),
          DataCell(Text(viewModel.myCustomerList[index].emailId)),
          const DataCell(Text('--')),
          DataCell(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'View and Add new product',
                icon: const Icon(Icons.playlist_add),
                onPressed: () => openDealerDeviceListBottomSheet(context, viewModel.myCustomerList[index], viewModel, userId),
              ),
              IconButton(
                tooltip: 'View dealer dashboard',
                icon: const Icon(Icons.dashboard_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DealerScreenController(
                      userId: viewModel.myCustomerList[index].userId,
                      userName: viewModel.myCustomerList[index].userName,
                      mobileNo: viewModel.myCustomerList[index].mobileNumber,
                      fromLogin: false,
                      emailId: viewModel.myCustomerList[index].emailId,
                    ),
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
      ),
    );
  }

  Widget buildDealerListCard(BuildContext context, AdminAndDealerDashboardViewModel viewModel) {
    return SizedBox(
      width: 300,
      height: MediaQuery.sizeOf(context).height,
      child: Card(
        child: viewModel.isLoadingCustomerData
            ? const Center(child: SizedBox(width: 40, child: LoadingIndicator(indicatorType: Indicator.ballPulse)))
            : Column(
          children: [
            const ListTile(
              title: Text('All My Devices', style: TextStyle(fontSize: 17)),
            ),
            const Divider(height: 0),
            Expanded(
              child: viewModel.myCustomerList.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: viewModel.categoryList.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.categoryList[index];
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                              child: F.appFlavor!.name.contains('oro')
                                  ? Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Image.asset(
                              "assets/images/Png/Oro/category_${index+1}.png",
                              errorBuilder: (context, error, stackTrace) {
                                print('error:$error');
                                return const Icon(Icons.error);
                              },
                            ),
                          )
                                  : Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Image.asset("assets/images/Png/SmartComm/category_${index+1}.png"),
                          )
                          ),
                          Container(
                            height: 25,
                            color: Theme.of(context).primaryColorLight.withOpacity(0.2),
                            child: Center(
                              child: Text(item.categoryName, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
                  : const _NoCustomersWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSegmentedButton(AdminAndDealerDashboardViewModel viewModel, int userId) {
    return SegmentedButton<MySegment>(
      segments: const <ButtonSegment<MySegment>>[
        ButtonSegment(
          value: MySegment.all,
          label: SizedBox(width: 45, child: Text('All', textAlign: TextAlign.center)),
          icon: Icon(Icons.calendar_view_day),
        ),
        ButtonSegment(
          value: MySegment.year,
          label: SizedBox(width: 45, child: Text('Year', textAlign: TextAlign.center)),
          icon: Icon(Icons.calendar_view_month),
        ),
      ],
      selected: <MySegment>{viewModel.segmentView},
      onSelectionChanged: (Set<MySegment> newSelection) {
        if (newSelection.isNotEmpty) {
          viewModel.updateSegmentView(newSelection.first);
          viewModel.getMySalesData(userId, newSelection.first);
        }
      },
    );
  }

  Widget buildSalesChip(int index, AdminAndDealerDashboardViewModel viewModel) {
    final item = viewModel.mySalesData.total![index];
    return Chip(
      avatar: CircleAvatar(backgroundColor: item.color),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.black12, width: 0.1),
      ),
      color: WidgetStateProperty.resolveWith<Color>((states) => Colors.blueGrey.shade50),
      label: Text('${index + 1} - ${item.categoryName}', style: const TextStyle(fontSize: 11)),
      visualDensity: VisualDensity.compact,
    );
  }

  void openCreateDealerBottomSheet(BuildContext context, AdminAndDealerDashboardViewModel viewModel, int userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.84,
          widthFactor: 0.75,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
            ),
            child: CreateAccount(
              userId: userId,
              role: UserRole.admin,
              customerId: 0,
              onAccountCreated: viewModel.updateCustomerList,
            ),
          ),
        );
      },
    );
  }

  void openDealerDeviceListBottomSheet(BuildContext context, CustomerListModel customer, AdminAndDealerDashboardViewModel viewModel, int userId) {

    showModalBottomSheet(
      context: context,
      elevation: 10,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
      ),
      builder: (context) => DealerDeviceList(
        userId: userId,
        customerName: customer.userName,
        customerId: customer.userId,
        userRole: 'Dealer',
        productStockList: viewModel.productStockList,
        onDeviceListAdded: viewModel.removeStockList,
      ),
    );
  }
}

class _NoCustomersWidget extends StatelessWidget {
  const _NoCustomersWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Customers not found.', style: TextStyle(fontSize: 17)),
            SizedBox(height: 5),
            Text(
              'Add your customer using top of the customer adding button.',
              textAlign: TextAlign.center,
            ),
            Icon(Icons.person_add_outlined),
          ],
        ),
      ),
    );
  }
}