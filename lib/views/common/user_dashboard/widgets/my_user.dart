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

class MyUser extends StatelessWidget {
  final UserDashboardViewModel viewModel;
  final int userId;

  const MyUser({
    super.key,
    required this.viewModel,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
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
                color: Theme.of(context).primaryColorDark,
                onPressed: () => userAccountBottomSheet(context, viewModel, userId),
              ),
            ),
          ),
          Expanded(
            child: DataTable2(
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
                DataColumn2(
                  label: Text(''),
                  fixedWidth: 100,
                ),
              ],
              rows: List<DataRow>.generate(
                viewModel.myCustomerList.length,
                    (index) => DataRow(
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
                          onPressed: () => openDealerDeviceListBottomSheet(
                            context,
                            viewModel.myCustomerList[index],
                            viewModel,
                            userId,
                          ),
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
                            userProvider.setViewedCustomer(user);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DealerScreenLayout(),
                              ),
                            );
                          },
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