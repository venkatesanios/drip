import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../layouts/user_layout.dart';
import '../../../../models/admin_dealer/customer_list_model.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/user_provider.dart';
import '../../../../utils/enums.dart';
import '../../../../view_models/customer_list_view_model.dart';
import '../../../create_account.dart';
import '../../../customer/mobile/customer_mobile.dart';

class CustomerView extends StatelessWidget {
  const CustomerView({super.key, required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CustomerListViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: viewModel.myCustomerList.length,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        itemBuilder: (context, index) {
          final customer = viewModel.myCustomerList[index];
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
            /*trailing: IconButton(
                  tooltip: 'View and Add new product',
                  icon: const Icon(Icons.playlist_add),
                  onPressed: () => openDealerDeviceListBottomSheet(context, customer, viewModel, userId),
                ),*/
            onTap: () => openUserDashboard(context, customer),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: role.name=='Admin'? "Add new dealer" : "Add new customer",
        onPressed: () {
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
                    userId: viewModel.userId,
                    role: UserRole.admin,
                    customerId: 0,
                    onAccountCreated: viewModel.updateCustomerList,
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  void openUserDashboard(BuildContext context, CustomerListModel customer) {
    final user = UserModel(
      token: context.read<UserProvider>().loggedInUser.token,
      id: customer.userId ?? 0,
      name: customer.userName ?? '',
      role: role.name == "Admin" ? UserRole.dealer : UserRole.customer,
      countryCode: customer.countryCode ?? '',
      mobileNo: customer.mobileNumber ?? '',
      email: customer.emailId ?? '',
    );
    context.read<UserProvider>().pushViewedCustomer(user);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => role.name == "Dealer" ? const CustomerMobile() :
      const DealerScreenLayout()),
    ).then((_) {
      context.read<UserProvider>().popViewedCustomer();
    });
  }
}