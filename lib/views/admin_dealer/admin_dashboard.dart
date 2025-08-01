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
import '../../utils/enums.dart';
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
    final isLargeScreen = MediaQuery.of(context).size.width > 1130;

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
              child: isLargeScreen ? Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        buildAnalyticsCard(context, viewModel),
                        Expanded(
                          child: buildDealerDataTable(context, viewModel),
                        ),
                      ],
                    ),
                  ),
                  buildProductListCard(context, viewModel, 300),
                ],
              ): SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    buildAnalyticsCard(context, viewModel),
                    SizedBox(
                      height: (viewModel.myCustomerList.length*45)+95,
                      child: buildDealerDataTable(context, viewModel),
                    ),
                    buildProductListCard(context, viewModel, MediaQuery.of(context).size.width),
                  ],
                ),
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

  Widget buildAnalyticsCard(BuildContext context,
      AdminAndDealerDashboardViewModel viewModel) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: screenWidth>800?360:410,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            children: [
              if(screenWidth<600)...[
                ListTile(
                  tileColor: Colors.white,
                  title: AppConstants().anlOvrView,
                ),
                ListTile(
                  tileColor: Colors.white,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SegmentedButton<MySegment>(
                        segments: const <ButtonSegment<MySegment>>[
                          ButtonSegment<MySegment>(
                            value: MySegment.all,
                            label: SizedBox(
                              width: 45,
                              child: Text('All', textAlign: TextAlign.center),
                            ),
                            icon: Icon(Icons.calendar_view_day),
                          ),
                          ButtonSegment<MySegment>(
                            value: MySegment.year,
                            label: SizedBox(
                              width: 45,
                              child: Text('Year', textAlign: TextAlign.center),
                            ),
                            icon: Icon(Icons.calendar_view_month),
                          ),
                        ],
                        selected: <MySegment>{viewModel.segmentView},
                        onSelectionChanged: (Set<MySegment> newSelection) {
                          if (newSelection.isNotEmpty) {
                            viewModel.updateSegmentView(newSelection.first);
                            viewModel.getMySalesData(userId, newSelection.first); // Refresh data based on the new selection
                          }
                        },
                      ),
                      const SizedBox(width: 16,),
                      Text.rich(
                        TextSpan(
                          text: 'Total Sales: ', // Regular text
                          style: const TextStyle(fontSize: 15),
                          children: <TextSpan>[
                            TextSpan(
                              text: viewModel.totalSales.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]
              else...[
                ListTile(
                  tileColor: Colors.white,
                  title: AppConstants().anlOvrView,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SegmentedButton<MySegment>(
                        segments: const <ButtonSegment<MySegment>>[
                          ButtonSegment<MySegment>(
                            value: MySegment.all,
                            label: SizedBox(
                              width: 45,
                              child: Text('All', textAlign: TextAlign.center),
                            ),
                            icon: Icon(Icons.calendar_view_day),
                          ),
                          ButtonSegment<MySegment>(
                            value: MySegment.year,
                            label: SizedBox(
                              width: 45,
                              child: Text('Year', textAlign: TextAlign.center),
                            ),
                            icon: Icon(Icons.calendar_view_month),
                          ),
                        ],
                        selected: <MySegment>{viewModel.segmentView},
                        onSelectionChanged: (Set<MySegment> newSelection) {
                          if (newSelection.isNotEmpty) {
                            viewModel.updateSegmentView(newSelection.first);
                            viewModel.getMySalesData(userId, newSelection.first); // Refresh data based on the new selection
                          }
                        },
                      ),
                      const SizedBox(width: 16,),
                      Text.rich(
                        TextSpan(
                          text: 'Total Sales: ', // Regular text
                          style: const TextStyle(fontSize: 15),
                          children: <TextSpan>[
                            TextSpan(
                              text: viewModel.totalSales.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  Widget buildDealerDataTable(BuildContext context,
      AdminAndDealerDashboardViewModel viewModel) {
    final screenHeight = MediaQuery.of(context).size.width;
    return Card(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListTile(
              title: const Text('My Dealers', style: TextStyle(fontSize: 20)),
              trailing: IconButton(
                tooltip: 'Create Dealer account',
                icon: const Icon(Icons.person_add_outlined),
                color: primaryDark,
                onPressed: () => openCreateDealerBottomSheet(context, viewModel, userId),
              ),
            ),
          ),
          Expanded(
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 850,
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
            ),
          ),
        ],
      ),
    );

  }

  Widget buildProductListCard(BuildContext context,
      AdminAndDealerDashboardViewModel viewModel,
      double sWidth)
  {
    print(MediaQuery.of(context).size.width);
    final screenHeight = MediaQuery.of(context).size.height;

    int crossAxisCount;
    if (sWidth >= 1000) {
      crossAxisCount = 8;
    }else if (sWidth >= 850) {
      crossAxisCount = 7;
    }else if (sWidth >= 800) {
      crossAxisCount = 7;
    }else if (sWidth >= 650) {
      crossAxisCount = 6;
    }else if (sWidth >= 570) {
      crossAxisCount = 5;
    } else if (sWidth >= 500) {
      crossAxisCount = 4;
    }else {
      crossAxisCount = 2;
    }

    final int itemRows = (viewModel.categoryList.length / crossAxisCount).ceil();
    final double dynamicHeight = itemRows * 120.0 + 80.0;

    return SizedBox(
      width: sWidth,
      height: viewModel.categoryList.isEmpty ? 200 :
      dynamicHeight,
      child: Card(
        color: Colors.white,
        child: viewModel.isLoadingCustomerData
            ? const Center(
          child: SizedBox(
            width: 40,
            child: LoadingIndicator(indicatorType: Indicator.ballPulse),
          ),
        )
            : Column(
          children: [
            const ListTile(
              title: Text('All My Devices', style: TextStyle(fontSize: 20)),
            ),
            const Divider(height: 0),
            Expanded(
              child: viewModel.categoryList.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: viewModel.categoryList.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.categoryList[index];
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Image.asset(
                                "assets/images/Png/${F.appFlavor!.name.contains('oro') ? 'Oro' : 'SmartComm'}/category_${index + 1}.png",
                                errorBuilder: (context, error, stackTrace) {
                                  print('error: $error');
                                  return const Icon(Icons.error);
                                },
                              ),
                            ),
                          ),
                          Container(
                            height: 25,
                            color: Colors.white,
                            child: Center(
                              child: Text(
                                item.categoryName,
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                              ),
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