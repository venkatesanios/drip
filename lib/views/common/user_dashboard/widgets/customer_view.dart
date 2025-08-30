import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:oro_drip_irrigation/views/common/user_dashboard/widgets/user_device_list.dart';
import 'package:provider/provider.dart';
import '../../../../Screens/Dealer/sevicerequestdealer.dart';
import '../../../../layouts/user_layout.dart';
import '../../../../models/admin_dealer/customer_list_model.dart';
import '../../../../models/user_model.dart';
import '../../../../modules/UserChat/view/user_chat.dart';
import '../../../../providers/user_provider.dart';
import '../../../../utils/enums.dart';
import '../../../../view_models/customer_list_view_model.dart';
import '../../../../view_models/product_stock_view_model.dart';
import '../../../admin_dealer/customer_device_list.dart';
import '../../user_profile/create_account.dart';

class CustomerView extends StatelessWidget {
  const CustomerView({super.key, required this.role, required this.isNarrow, required this.onCustomerProductChanged});
  final UserRole role;
  final bool isNarrow;
  final void Function(String action) onCustomerProductChanged;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CustomerListViewModel>();
    final stockVM = context.watch<ProductStockViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(viewModel),
      body: Column(
        children: [
          ListTile(
            dense: true, // reduces overall height
            visualDensity: const VisualDensity(vertical: -2),
            title: const Text('My Customers',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 15),
            ),
            trailing: Text(
              '${viewModel.myCustomerList.length}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: viewModel.filteredCustomerList.length,
              itemBuilder: (context, index) {
                final customer = viewModel.filteredCustomerList[index];
                return _buildCustomerTile(context, customer, viewModel, stockVM);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: role.name == 'admin' ? "Add new dealer" : "Add new customer",
        onPressed: () => _showCreateAccountSheet(context, viewModel),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  PreferredSizeWidget? _buildAppBar(CustomerListViewModel vm) {
    final showSearch = vm.searching || vm.filteredCustomerList.length > 15;

    if (!showSearch) return null;

    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: !isNarrow ? Colors.white : null,
      title: SizedBox(
        height: 40,
        child: TextField(
          controller: vm.txtFldSearch,
          style: TextStyle(
            color: isNarrow ? Colors.white : Colors.black,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            hintText: 'Search customers...',
            hintStyle: TextStyle(
              color: isNarrow ? Colors.white30 : Colors.black38,
            ),
            prefixIcon: Icon(Icons.search,
                size: 20, // 👈 shrink icon size
                color: isNarrow ? Colors.white60 : Colors.black54),
            suffixIcon: vm.searching
                ? IconButton(
              icon: Icon(Icons.clear,
                  size: 20,
                  color: isNarrow ? Colors.white : Colors.black),
              onPressed: vm.clearSearch,
            )
                : null,
            filled: true,
            fillColor: isNarrow ? Colors.white24 : Colors.black12,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.white30),
            ),
          ),
          onChanged: (value) =>
          value.isEmpty ? vm.clearSearch() : vm.filterCustomer(value),
          onSubmitted: (_) => vm.searchCustomer(),
        ),
      ),
    );
  }

  Widget _buildCustomerTile(BuildContext context, CustomerListModel customer,
      CustomerListViewModel vm, ProductStockViewModel stockVM) {
    final textStyle = isNarrow
        ? const TextStyle(fontWeight: FontWeight.bold)
        : const TextStyle(fontWeight: FontWeight.bold, fontSize: 13);

    final subtitleStyle = isNarrow
        ? const TextStyle(color: Colors.black54)
        : const TextStyle(color: Colors.black54, fontSize: 12);

    return ListTile(
      tileColor: Colors.white,
      leading: const CircleAvatar(
        backgroundImage: AssetImage("assets/png/user_thumbnail.png"),
        backgroundColor: Colors.transparent,
        radius: 20,
      ),
      title: Text(customer.name, style: textStyle),
      subtitle: Text(
        '+ ${customer.countryCode} ${customer.mobileNumber}\n${customer.emailId}',
        style: subtitleStyle,
      ),
      trailing: role.name == 'admin' ? IconButton(
        tooltip: 'View and Add new product',
        icon: const Icon(Icons.playlist_add_circle),
        onPressed: () => _showDeviceList(context, customer, stockVM),
      ) :
      buildCustomerTrailing(context, customer, stockVM),
      contentPadding: const EdgeInsets.only(left: 10, right: 5),
      onTap: () => openUserDashboard(
          context,
          customer,
          context.read<UserProvider>()
      ),
    );
  }

  Widget buildCustomerTrailing(BuildContext context,
      CustomerListModel customer, ProductStockViewModel stockVM) {

    return Row(
      mainAxisSize: MainAxisSize.min, // keep row compact
      children: [
        IconButton(
          tooltip: 'Chat with Customer',
          icon: const Icon(Icons.chat),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserChatScreen(
                  userId: customer.id,
                  userName: customer.name,
                  phoneNumber:
                  '+${customer.countryCode} ${customer.mobileNumber}',
                ),
              ),
            );
          },
        ),
        IconButton(
          tooltip: 'View and Add new product',
          icon: const Icon(Icons.playlist_add_circle),
          onPressed: () => _showDeviceList(context, customer, stockVM),
        ),
        if((customer.criticalAlarmCount + customer.serviceRequestCount) > 0)...[
          Badge(
            showBadge: (customer.criticalAlarmCount + customer.serviceRequestCount) > 0,
            position: BadgePosition.topEnd(top: 0, end: 0),
            badgeStyle: const BadgeStyle(
                badgeColor: Colors.red
            ),
            badgeContent: Text(
              '${customer.criticalAlarmCount + customer.serviceRequestCount}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            child: IconButton(
              tooltip: 'Service Request',
              icon: const Icon(Icons.build_circle),
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceRequestsTable(userId: customer.id),
                  ),
                );

                /*showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  elevation: 10,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                  ),
                  builder: (_) => ServiceRequestsTable(userId: customer.id),
                );*/
              },
            ),
          ),
        ]
      ],
    );
  }

  void _showCreateAccountSheet(
      BuildContext context, CustomerListViewModel vm) {
    final userRole = role.name == 'admin' ? UserRole.admin : UserRole.dealer;

    if (isNarrow) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => SizedBox(
          height: 600,
          child: CreateAccount(
            userId: vm.userId,
            role: userRole,
            customerId: 0,
            onAccountCreated: vm.updateCustomerList,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.84,
          widthFactor: 0.75,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: CreateAccount(
              userId: vm.userId,
              role: userRole,
              customerId: 0,
              onAccountCreated: vm.updateCustomerList,
            ),
          ),
        ),
      );
    }
  }

  void _showDeviceList(BuildContext context, CustomerListModel customer,
      ProductStockViewModel stockVM) {

    print(role.name);

    final loggedInUser = Provider.of<UserProvider>(context, listen: false).loggedInUser;

    if(role.name=='admin'){
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        elevation: 10,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
        ),
        builder: (_) => UserDeviceList(
          userId: loggedInUser.id,
          customerName: customer.name,
          customerId: customer.id,
          userRole: 'Dealer',
          productStockList: stockVM.productStockList,
          onDeviceListAdded: stockVM.removeStockList,
        ),
      );
    }else{

      if(isNarrow){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CustomerDeviceList(
            customerName: customer.name,
            customerId: customer.id,
            onCustomerProductChanged: onCustomerProductChanged,
            productStockList: stockVM.productStockList,
            userId: loggedInUser.id,
            userRole:'Customer',
          )),
        );
      }else{
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          elevation: 10,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
          ),
          builder: (_) => CustomerDeviceList(
            customerName: customer.name,
            customerId: customer.id,
            onCustomerProductChanged: onCustomerProductChanged,
            productStockList: stockVM.productStockList,
            userId: loggedInUser.id,
            userRole:'Customer',
          ),
        );
      }

    }
  }

  void openUserDashboard(
      BuildContext context, CustomerListModel customer, UserProvider userProvider) {
    final user = UserModel(
      token: userProvider.loggedInUser.token,
      id: customer.id,
      name: customer.name,
      role: role.name == "admin" ? UserRole.dealer : UserRole.customer,
      countryCode: customer.countryCode,
      mobileNo: customer.mobileNumber,
      email: customer.emailId,
    );

    userProvider.pushViewedCustomer(user);

    final route = role.name == 'admin'
        ? const DealerScreenLayout()
        : const CustomerScreenLayout();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => route),
    ).then((_) => userProvider.popViewedCustomer());
  }
}