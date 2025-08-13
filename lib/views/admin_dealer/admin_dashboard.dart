import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_drip_irrigation/utils/Theme/oro_theme.dart';
import 'package:provider/provider.dart';
import '../../Widgets/analytics_overview.dart';
import '../../Widgets/empty_customer.dart';
import '../../flavors.dart';
import '../../layouts/user_layout.dart';
import '../../models/admin_dealer/customer_list_model.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/enums.dart';
import '../../utils/snack_bar.dart';
import '../../view_models/admin_dealer/admin_dealer_dashboard_view_model.dart';
import '../create_account.dart';
import 'dealer_device_list.dart';


class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key, required this.isWideLayout});
  final bool isWideLayout;

  @override
  Widget build(BuildContext context) {
    final viewedCustomer = Provider.of<UserProvider>(context).viewedCustomer;

    return ChangeNotifierProvider(
      create: (_) => UserDashboardViewModel(Repository(HttpService()), viewedCustomer!.id, 1)
        ..getMySalesData(viewedCustomer.id, MySegment.all)
        ..getMyStock()
        ..getMyCustomers()
        ..getCategoryList(),
      child: Consumer<UserDashboardViewModel>(
        builder: (context, viewModel, _) {
          handleAccountCreated(viewModel, context);

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(3.0),
              child: isWideLayout ? Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        AnalyticsOverview(viewModel: viewModel, userId: viewedCustomer!.id, isWideScreen: true),
                        Expanded(child: buildDealerDataTable(context, viewModel, viewedCustomer.id)),
                      ],
                    ),
                  ),
                  buildProductListCard(context, viewModel, 300),
                ],
              ): SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    AnalyticsOverview(viewModel: viewModel, userId: viewedCustomer!.id, isWideScreen: false),
                    SizedBox(
                      height: (viewModel.myCustomerList.length*45)+95,
                      child: buildDealerDataTable(context, viewModel, viewedCustomer.id),
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

  void handleAccountCreated(UserDashboardViewModel viewModel, BuildContext context) {
    if (viewModel.accountCreated) {
      viewModel.accountCreated = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GlobalSnackBar.show(context, viewModel.responseMsg, 200);
        viewModel.responseMsg = '';
      });
    }
  }


  Widget buildDealerDataTable(BuildContext context, UserDashboardViewModel viewModel, int userId) {
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
                        onPressed: () {
                          final user = UserModel(
                            token: 'token',
                            id: viewModel.myCustomerList[index].userId ?? 0,
                            name: viewModel.myCustomerList[index].userName ?? '',
                            role: UserRole.dealer,
                            countryCode: viewModel.myCustomerList[index].countryCode ?? '',
                            mobileNo: viewModel.myCustomerList[index].mobileNumber ?? '',
                            email: viewModel.myCustomerList[index].emailId ?? '',
                          );
                          final userProvider = context.read<UserProvider>();
                          //userProvider.setViewedCustomer(user);
                          context.read<UserProvider>().pushViewedCustomer(user);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const DealerScreenLayout()));
                        },
                        /*onPressed: () => Navigator.push(
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
                        ),*/
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
      UserDashboardViewModel viewModel, double sWidth)
  {
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
              ) : const NoCustomers(),
            ),
          ],
        ),
      ),
    );
  }

  void openCreateDealerBottomSheet(BuildContext context, UserDashboardViewModel viewModel, int userId) {
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

  void openDealerDeviceListBottomSheet(BuildContext context, CustomerListModel customer, UserDashboardViewModel viewModel, int userId) {

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
