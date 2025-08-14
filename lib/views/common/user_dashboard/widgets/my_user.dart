import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../../layouts/user_layout.dart';
import '../../../../models/admin_dealer/customer_list_model.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/user_provider.dart';
import '../../../../utils/enums.dart';
import '../../../../view_models/admin_dealer/admin_dealer_dashboard_view_model.dart';
import '../../../admin_dealer/dealer_device_list.dart';
import '../../../create_account.dart';
import '../../../customer/mobile/customer_mobile.dart';
import '../../../mobile/mobile_screen_controller.dart';

class MyUser extends StatelessWidget {
  const MyUser({super.key,
    required this.viewModel,
    required this.userId,
    required this.isWideScreen,
    required this.title,
  });

  final UserDashboardViewModel viewModel;
  final int userId;
  final bool isWideScreen;
  final String title;

  @override
  Widget build(BuildContext context) {
    final customerList = viewModel.myCustomerList;

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: isWideScreen? 5:0,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          children: [
            ListTile(
              tileColor: Colors.white,
              title: Text(title, style: const TextStyle(fontSize: 20)),
              trailing: IconButton(
                tooltip: 'Create Dealer account',
                icon: const Icon(Icons.person_add_outlined),
                color: Theme.of(context).primaryColorDark,
                onPressed: () => userAccountBottomSheet(context, viewModel, userId),
              ),
            ),
            SizedBox(
              height: isWideScreen ? (customerList.length * 40)+35 :
              title.contains('Customer') ? MediaQuery.sizeOf(context).height - 231 :
              customerList.length * 78,
              child: isWideScreen ? DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 850,
                headingRowColor: WidgetStateProperty.all<Color>(
                  Theme.of(context).primaryColorLight.withOpacity(0.1),
                ),
                headingRowHeight: 35,
                dataRowHeight: 40,
                columns: const [
                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Mobile No', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn2(
                    label: Text('E-mail Address', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(label: Text(''), fixedWidth: 100),
                ],
                rows: List<DataRow>.generate(
                  customerList.length,
                      (index) {
                    final customer = customerList[index];
                    return DataRow(
                      cells: [
                        DataCell(Row(
                          children: [
                            const CircleAvatar(
                              backgroundImage: AssetImage("assets/png/user_thumbnail.png"),
                              backgroundColor: Colors.transparent,
                              radius: 14,
                            ),
                            const SizedBox(width: 12),
                            Text(customer.userName),
                          ],
                        )),
                        DataCell(Text('+ ${customer.countryCode} ${customer.mobileNumber}')),
                        DataCell(Text(customer.emailId)),
                        const DataCell(Text('--')),
                        DataCell(Row(
                          children: [
                            IconButton(
                              tooltip: 'View and Add new product',
                              icon: const Icon(Icons.playlist_add),
                              onPressed: () => openDealerDeviceListBottomSheet(
                                context, customer, viewModel, userId,
                              ),
                            ),
                            IconButton(
                              tooltip: title.contains('Dealer') ? 'View dealer dashboard'
                                  : 'View customer dashboard',
                              icon: const Icon(Icons.dashboard_outlined),
                              onPressed: () => _openUserDashboard(context, customer),
                            ),
                          ],
                        )),
                      ],
                    );
                  },
                ),
              ) :
              ListView.builder(
                itemCount: customerList.length,
                physics: title.contains('Customer') ? null :
                const NeverScrollableScrollPhysics(),
                shrinkWrap: true, // important!
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                itemBuilder: (context, index) {
                  final customer = customerList[index];
                  return ListTile(
                    tileColor: Colors.white,
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage("assets/png/user_thumbnail.png"),
                      backgroundColor: Colors.transparent,
                      radius: 20,
                    ),
                    title: Text(
                      customer.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '+ ${customer.countryCode} ${customer.mobileNumber}\n${customer.emailId}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    trailing: IconButton(
                      tooltip: 'View and Add new product',
                      icon: const Icon(Icons.playlist_add),
                      onPressed: () => openDealerDeviceListBottomSheet(context, customer, viewModel, userId),
                    ),
                    onTap: () => _openUserDashboard(context, customer),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void userAccountBottomSheet(BuildContext context, UserDashboardViewModel viewModel, int userId) {
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

  void openDealerDeviceListBottomSheet(
      BuildContext context,
      CustomerListModel customer,
      UserDashboardViewModel viewModel,
      int userId,
      ) {
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
        userRole: title.contains('Dealer') ? 'Dealer': 'Customer',
        productStockList: viewModel.productStockList,
        onDeviceListAdded: viewModel.removeStockList,
      ),
    );
  }

  void _openUserDashboard(BuildContext context, CustomerListModel customer) {
    final user = UserModel(
      token: context.read<UserProvider>().loggedInUser.token,
      id: customer.userId ?? 0,
      name: customer.userName ?? '',
      role: title.contains('Dealer') ? UserRole.dealer : UserRole.customer,
      countryCode: customer.countryCode ?? '',
      mobileNo: customer.mobileNumber ?? '',
      email: customer.emailId ?? '',
    );
    context.read<UserProvider>().pushViewedCustomer(user);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => title.contains('Customer') ? const CustomerMobile() :
      const DealerScreenLayout()),
    ).then((_) {
      context.read<UserProvider>().popViewedCustomer();
    });
  }

}