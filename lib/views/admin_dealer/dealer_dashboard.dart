import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:oro_drip_irrigation/views/admin_dealer/sales_bar_chart.dart';
import 'package:provider/provider.dart';

import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/constants.dart';
import '../../utils/snack_bar.dart';
import '../../view_models/admin&dealer/admin&dealer_dashboard_view_model.dart';
import '../create_account.dart';
import '../customer/customer_screen_controller.dart';
import 'admin_dashboard.dart';
import 'customer_device_list.dart';

class DealerDashboard extends StatelessWidget {
  const DealerDashboard({super.key, required this.userId, required this.userName, required this.mobileNo});
  final int userId;
  final String userName, mobileNo;


  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => AdminAndDealerDashboardViewModel(Repository(HttpService()))..getMySalesData(userId, MySegment.all)
        ..getMyStock(userId, 2)..getMyCustomers(userId, 2),
      child: Consumer<AdminAndDealerDashboardViewModel>(
        builder: (context, viewModel, _) {
          if(viewModel.accountCreated){
            viewModel.accountCreated = false;
            Future.delayed(const Duration(milliseconds: 500), () {
              GlobalSnackBar.show(context, viewModel.responseMsg, 200);
              viewModel.responseMsg = '';
            });
          }
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Dashboard'),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(mobileNo, style: const TextStyle(
                            fontWeight: FontWeight.normal, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(width: 08),
                    const CircleAvatar(
                      radius: 23,
                      backgroundImage: AssetImage("assets/png_images/user_thumbnail.png"),
                    ),
                  ],),
                const SizedBox(width: 10),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 350,
                          child: Card(
                            elevation: 1,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Column(
                                children: [
                                  ListTile(
                                    tileColor: Colors.white,
                                    title: const Text(
                                      "Analytics Overview",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
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
                                  Expanded(
                                    child: viewModel.isLoadingSalesData? const Center(child: SizedBox(
                                        width: 40,
                                        child: LoadingIndicator(indicatorType: Indicator.ballPulse))) :
                                    MySalesBarChart(graph: viewModel.mySalesData.graph),
                                  ),
                                  Wrap(
                                    spacing: 5,
                                    runSpacing: 5,
                                    alignment: WrapAlignment.start,
                                    runAlignment: WrapAlignment.spaceBetween,
                                    children: List.generate(
                                      viewModel.mySalesData.total!.length, (index) =>
                                        Chip(
                                          avatar: CircleAvatar(
                                              backgroundColor: viewModel.mySalesData
                                                  .total![index].color),
                                          elevation: 3,
                                          shape: const LinearBorder(),
                                          label: Text(
                                            '${index + 1} - ${viewModel.mySalesData
                                                .total![index].categoryName}',
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            elevation: 1,
                            surfaceTintColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(10),
                                      topLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: RichText(
                                      text: TextSpan(
                                        text: 'Product Stock : ',
                                        style: const TextStyle(fontSize: 20, color: Colors.black),
                                        children: [
                                          TextSpan(
                                            text: viewModel.productStockList.length.toString().padLeft(2, '0'),
                                            style: const TextStyle(fontSize: 20, color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: viewModel.productStockList.isNotEmpty ? Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: DataTable2(
                                        columnSpacing: 12,
                                        horizontalMargin: 12,
                                        minWidth: 600,
                                        border: TableBorder.all(color: Colors.teal.shade50),
                                        headingRowColor: WidgetStateProperty.all<
                                            Color>(Theme.of(context).primaryColorDark.withValues(alpha: 0.1)),
                                        headingRowHeight: 40,
                                        dataRowHeight: 40,
                                        columns: const [
                                          DataColumn2(
                                            label: Center(
                                              child: Text(
                                                'S.No',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            fixedWidth: 50,
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Category',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Model',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          DataColumn2(
                                            label: Center(
                                              child: Text(
                                                'IMEI',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            size: ColumnSize.L,
                                          ),
                                          DataColumn2(
                                            label: Center(
                                              child: Text(
                                                'M.Date',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            fixedWidth: 150,
                                          ),
                                          DataColumn2(
                                            label: Center(
                                              child: Text(
                                                'Warranty',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            fixedWidth: 100,
                                          ),
                                        ],
                                        rows: List<DataRow>.generate(
                                          viewModel.productStockList.length,
                                              (index) => DataRow(
                                            cells: [
                                              DataCell(
                                                Center(child: Text('${index + 1}')),
                                              ),
                                              DataCell(Text(viewModel.productStockList[index].categoryName)),
                                              DataCell(Text(viewModel.productStockList[index].model)),
                                              DataCell(
                                                Center(
                                                  child: Text(viewModel.productStockList[index].imeiNo),
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: Text(viewModel.productStockList[index].dtOfMnf),
                                                ),
                                              ),
                                              DataCell(
                                                Center(
                                                  child: Text('${viewModel.productStockList[index].warranty}'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ) :
                                    const Center(child: Text(
                                      'SOLD OUT', style: TextStyle(fontSize: 20),)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 300,
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
                          ): ListTile(
                            title: const Text('My Customers',
                                style: TextStyle(fontSize: 17)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                viewModel.myCustomerList.length>15?IconButton(
                                    tooltip: 'Search Customer by Name or Mobile number',
                                    icon: const Icon(Icons.search),
                                    color: Theme.of(context).primaryColor, onPressed:()=>viewModel.searchCustomer()):
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
                                    backgroundImage: AssetImage("assets/png_images/user_thumbnail.png"),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
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
                                      const SizedBox(),*/
                                      IconButton(
                                        tooltip: 'View and Add new product',
                                        onPressed: (){
                                          showModalBottomSheet(
                                            context: context,
                                            elevation: 10,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
                                            builder: (BuildContext context) {
                                              return CustomerDeviceList(userId: userId, customerName: viewModel.myCustomerList[index]
                                                  .userName, customerId: viewModel.myCustomerList[index]
                                                  .userId, userRole: 'Customer', productStockList: viewModel.productStockList, onDeviceListAdded: viewModel.removeStockList);
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.playlist_add),
                                      ),
                                    ],
                                  ),
                                  title: Text(customer.userName, style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                                  subtitle: Text('+${customer.countryCode} ${customer.mobileNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
                                  onTap:() {
                                    Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (context) => CustomerScreenController(userId: viewModel.myCustomerList[index].userId,
                                            userName: viewModel.myCustomerList[index].userName,
                                            mobileNo: viewModel.myCustomerList[index].mobileNumber, fromLogin: false, emailId: viewModel.myCustomerList[index].emailId,
                                            customerId: viewModel.myCustomerList[index].userId,)),
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
                            /*child: viewModel.myCustomerList.isNotEmpty ? ListView.separated(
                              itemCount: viewModel.myCustomerList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const CircleAvatar(
                                    backgroundImage: AssetImage(
                                        "assets/png_images/user_thumbnail.png"),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  title: Text(
                                      viewModel.myCustomerList[index].userName,
                                      style: const TextStyle(fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text('+${viewModel.myCustomerList[index]
                                      .countryCode} ${viewModel.myCustomerList[index]
                                      .mobileNumber}',
                                      style: const TextStyle(fontSize: 12,
                                          fontWeight: FontWeight.normal)),
                                  onTap: () {
                                    *//*Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (context) => DealerScreenController(userId: viewModel.myCustomerList[index].userId,
                                              userName: viewModel.myCustomerList[index].userName,
                                              userEmailId: viewModel.myCustomerList[index].emailId, fromLogin: false)),
                                    );*//*
                                  },
                                  trailing: IconButton(
                                    tooltip: 'View and Add new product',
                                    onPressed: () {
                                      *//*showModalBottomSheet(
                                        context: context,
                                        elevation: 10,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
                                        builder: (BuildContext context) {
                                          return DealerDeviceList(userId: userId, customerName: viewModel.myCustomerList[index]
                                              .userName, customerId: viewModel.myCustomerList[index]
                                              .userId, userRole: 'Dealer', productStockList: viewModel.productStockList,);
                                        },
                                      );*//*
                                    },
                                    icon: const Icon(Icons.playlist_add),),
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
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(25.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center,
                                  children: [
                                    Text('Customers not found.',
                                        style: TextStyle(fontSize: 17,
                                            fontWeight: FontWeight.normal)),
                                    SizedBox(height: 5),
                                    Text(
                                        'Add your customer using top of the customer adding button.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal)),
                                    Icon(Icons.person_add_outlined),
                                  ],
                                ),
                              ),
                            ),*/
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}