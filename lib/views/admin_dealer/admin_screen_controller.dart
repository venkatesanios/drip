import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/admin_dealer/product_entry.dart';
import 'package:oro_drip_irrigation/views/admin_dealer/product_inventory.dart';
import 'package:provider/provider.dart';
import '../../Screens/Dealer/ServicerequestAdmin.dart';
import '../../flavors.dart';
import '../../utils/constants.dart';
import '../../view_models/nav_rail_view_model.dart';
import '../account_settings.dart';
import 'admin_dashboard.dart';

class AdminScreenController extends StatelessWidget {
  const AdminScreenController({super.key, required this.userId, required this.userName, required this.mobileNo, required this.emailId});
  final int userId;
  final String userName, mobileNo, emailId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavRailViewModel(),
      child: Consumer<NavRailViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Image.asset(
                width: F.appFlavor!.name.contains('oro')?70:110,
                F.appFlavor!.name.contains('oro')
                    ? "assets/png/oro_logo_white.png"
                    : "assets/png/company_logo.png",
                fit: BoxFit.fitWidth,
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    F.appFlavor!.name.contains('oro') ?
                    const SizedBox():
                    Image.asset(
                      width: 140,
                      "assets/png/lk_logo_white.png",
                      fit: BoxFit.fitWidth,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 200,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 2),
                          const CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage("assets/png/user_thumbnail.png"),
                          ),
                          const SizedBox(width: 5),
                          Text(userName, style: const TextStyle(fontWeight: FontWeight.bold))
                        ],
                      ),
                    )
                    /*Text(viewModel.userName!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 08),
                    const CircleAvatar(
                      radius: 23,
                      backgroundImage: AssetImage("assets/png/user_thumbnail.png"),
                    ),*/
                  ],),
              ],
            ),
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NavigationRail(
                  selectedIndex: viewModel.selectedIndex,
                  labelType: NavigationRailLabelType.all,
                  elevation: 5,
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: IconButton(
                          tooltip: 'Logout',
                          icon: const Icon(Icons.logout, color: Colors.redAccent),
                          autofocus: true,
                          focusColor: Colors.white,
                          onPressed: () async {
                            await viewModel.logout(context);
                          },
                        ),
                      ),
                    ),
                  ),
                  onDestinationSelected: (int index) {
                    viewModel.onDestinationSelectingChange(index);
                  },
                  destinations: getNavigationDestinations(),
                ),
                Expanded(
                  child: mainMenu(viewModel.selectedIndex, userId, userName),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<NavigationRailDestination> getNavigationDestinations() {
    final destinations = [
      const NavigationRailDestination(
        padding: EdgeInsets.only(top: 5),
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard_outlined, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2_outlined, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.topic_outlined),
        selectedIcon: Icon(Icons.topic_outlined, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.manage_accounts_outlined),
        selectedIcon: Icon(Icons.manage_accounts_outlined, color: Colors.white),
        label: Text(''),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.support_agent_sharp),
        selectedIcon: Icon(Icons.support_agent_sharp, color: Colors.white),
        label: Text(''),
      ),
    ];

    return destinations;
  }

  Widget mainMenu(int index, int userId, String userName) {
    switch (index) {
      case 0:
        return AdminDashboard(
          userId: userId,
          userName: userName, mobileNo: mobileNo,
        );
      case 1:
        return ProductInventory(
          userId: userId,
          userName: userName,
          userRole: UserRole.admin,
        );
      case 2:
        return ProductEntry(userId: userId);
      case 3:
        return AccountSettings(userId: userId, userName: userName, mobileNo: mobileNo, emailId: emailId, customerId: userId);
      case 4:
        return ServiceRequestAdmin(userId: userId,);
       default:
        return const SizedBox();
    }
  }
}
