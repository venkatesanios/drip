import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/common/user_dashboard/widgets/user_device_list.dart';
import 'package:provider/provider.dart';

import '../../../../layouts/user_layout.dart';
import '../../../../models/admin_dealer/customer_list_model.dart';
import '../../../../models/user_model.dart';
import '../../../../modules/UserChat/view/user_chat.dart';
import '../../../../providers/user_provider.dart';
import '../../../../utils/enums.dart';
import '../../../../view_models/customer_list_view_model.dart';
import '../../../../view_models/product_stock_view_model.dart';
import '../../../admin_dealer/customer_device_list.dart';
import '../../../create_account.dart';

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
            title: const Text('My Customers', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            trailing: Text('${viewModel.myCustomerList.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
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
      title: TextField(
        controller: vm.txtFldSearch,
        style: TextStyle(
          color: isNarrow ? Colors.white : Colors.black,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          hintText: 'Search customers...',
          hintStyle: TextStyle(
            color: isNarrow ? Colors.white30 : Colors.black38,
          ),
          prefixIcon: Icon(Icons.search,
              color: isNarrow ? Colors.white60 : Colors.black54),
          suffixIcon: vm.searching
              ? IconButton(
            icon: Icon(Icons.clear,
                color: isNarrow ? Colors.white : Colors.black),
            onPressed: vm.clearSearch,
          )
              : null,
          filled: true,
          fillColor: isNarrow ? Colors.white24 : Colors.black12,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Colors.white30),
          ),
        ),
        onChanged: (value) =>
        value.isEmpty ? vm.clearSearch() : vm.filterCustomer(value),
        onSubmitted: (_) => vm.searchCustomer(),
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
        IconButton(
          tooltip: 'Service Request',
          icon: const Icon(Icons.build_circle),
          onPressed: () {
            // TODO: implement service request
          },
        ),
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


/*
Widget buildCustomerListCard(BuildContext context,
    UserDashboardViewModel viewModel,
    double sWidth, int userId) {
  return SizedBox(
    width: sWidth == 300 ? 300: MediaQuery.sizeOf(context).width,
    height: MediaQuery.sizeOf(context).height,
    child: Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: viewModel.isLoadingCustomerData ?
      const Center(child: SizedBox(width: 40,
          child: LoadingIndicator(
              indicatorType: Indicator.ballPulse))) :
      Column(
        children: [
          viewModel.searched? ListTile(
            title: TextField(
              controller: viewModel.txtFldSearch,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.red,),
                    onPressed: () => viewModel.clearSearch(),
                  ),
                  hintText: 'Search',
                  border: InputBorder.none),
              onChanged: (value) => viewModel.filterCustomer(value),
            ),
          ) : ListTile(
            title: Text('My Customers(${viewModel.myCustomerList.length})',
                style: const TextStyle(fontSize: 17)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                viewModel.myCustomerList.length>15?IconButton(
                    tooltip: 'Search Customer by Name or Mobile number',
                    icon: const Icon(Icons.search),
                    color: Theme.of(context).primaryColor, onPressed:()=> viewModel.searchCustomer()):
                const SizedBox(),
                IconButton(
                    tooltip: 'Create Customer account',
                    icon: const Icon(Icons.person_add_outlined),
                    color: Theme.of(context).primaryColor,
                    onPressed: () async
                    {
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
                              child: CreateAccount(userId: userId, role: UserRole.dealer, customerId: 0, onAccountCreated: viewModel.updateCustomerList),
                            ),
                          );
                        },
                      );
                    })
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: viewModel.filteredCustomerList.isNotEmpty? ListView.separated(
              itemCount: viewModel.filteredCustomerList.length,
              itemBuilder: (context, index) {
                final customer = viewModel.filteredCustomerList[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage("assets/png/user_thumbnail.png"),
                    backgroundColor: Colors.transparent,
                  ),
                  contentPadding: const EdgeInsets.only(left: 10),
                  trailing: IntrinsicWidth(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (BuildContext context) => UserChatScreen(
                                      userId: viewModel.filteredCustomerList[index].userId,
                                      userName: viewModel.filteredCustomerList[index].userName,
                                      phoneNumber: '+${customer.countryCode} ${customer.mobileNumber}')
                                  )
                              );
                            },
                            icon: const Icon(Icons.chat)
                        ),
                        */
/* IconButton(
                                        tooltip: 'chart',
                                        onPressed: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UserChatScreen(userId: customer.userId, dealerId: customer.userId, userName: customer.userName,),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.question_answer_rounded),
                                      ),
                                      (customer.criticalAlarmCount + customer.serviceRequestCount)>0? BadgeButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return  Column(
                                                children: [
                                                  Container(
                                                    width: MediaQuery.sizeOf(context).width,
                                                    color: Colors.teal.shade100,
                                                    height: 30,
                                                    child: Center(child: Text(customer.userName)),
                                                  ),
                                                  customer.serviceRequestCount>0?SizedBox(
                                                    width: MediaQuery.sizeOf(context).width,
                                                    height: (customer.serviceRequestCount*45)+45,
                                                    child: ServiceRequestsTable(userId: customer.userId),
                                                  ):
                                                  const SizedBox(),
                                                  customer.criticalAlarmCount>0?SizedBox(
                                                    width: MediaQuery.sizeOf(context).width,
                                                    height: customer.criticalAlarmCount*45+40,
                                                    child: DisplayCriticalAlarm(userId: customer.userId,),
                                                  ):
                                                  const SizedBox(),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        icon: Icons.hail,
                                        badgeNumber: customer.criticalAlarmCount + customer.serviceRequestCount,
                                      ):
                                      const SizedBox(),*//*

                        IconButton(
                          tooltip: 'View and Add new product',
                          onPressed: (){
                            showModalBottomSheet(
                              context: context,
                              elevation: 10,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
                              builder: (BuildContext context) {
                                return CustomerDeviceList(userId: userId, customerName: viewModel.filteredCustomerList[index]
                                    .userName, customerId: viewModel.filteredCustomerList[index]
                                    .userId, userRole: 'Customer', productStockList: viewModel.productStockList,
                                    onCustomerProductChanged: viewModel.onCustomerProductChanged);
                              },
                            );
                          },
                          icon: const Icon(Icons.playlist_add),
                        ),
                      ],
                    ),
                  ),
                  title: Text(customer.userName, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                  subtitle: Text('+${customer.countryCode} ${customer.mobileNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
                  onTap:() {
                    Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) => CustomerScreenController(userId: viewModel.filteredCustomerList[index].userId,
                            customerName: viewModel.filteredCustomerList[index].userName,
                            mobileNo: viewModel.filteredCustomerList[index].mobileNumber, fromLogin: false,
                            emailId: viewModel.filteredCustomerList[index].emailId,
                            customerId: viewModel.filteredCustomerList[index].userId,)),
                    );
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Colors.black26,
                  thickness: 0.3,
                  indent: 16,
                  endIndent: 0,
                  height: 0,
                );
              },
            ):
            Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Customers not found.', style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal)),
                    const SizedBox(height: 5),
                    !viewModel.searched? const Text('Add your customer using top of the customer adding button.', style: TextStyle(fontWeight: FontWeight.normal)):
                    const SizedBox(),
                    !viewModel.searched?const Icon(Icons.person_add_outlined):const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}*/
