import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/admin_dealer/product_inventory.dart';
import 'package:provider/provider.dart';
import '../../flavors.dart';
import '../../utils/constants.dart';
import '../../view_models/nav_rail_view_model.dart';
import '../account_settings.dart';
import 'dealer_dashboard.dart';

class DealerScreenController extends StatelessWidget {
  const DealerScreenController({super.key, required this.userId, required this.userName, required this.mobileNo, required this.fromLogin, required this.emailId});
  final int userId;
  final String userName, mobileNo, emailId;
  final bool fromLogin;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavRailViewModel(),
      child: Consumer<NavRailViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NavigationRail(
                  selectedIndex: viewModel.selectedIndex,
                  labelType: NavigationRailLabelType.all,
                  elevation: 5,
                  leading: Column(
                    children: [

                      fromLogin ? Image(
                        image: F.appFlavor!.name.contains('oro')
                            ? const AssetImage("assets/png_images/oro_logo_white.png")
                            : const AssetImage("assets/png_images/company_logo.png"),
                        height: 40,
                        width: 65,
                        fit: BoxFit.fitWidth,
                      ):
                      IconButton(onPressed: (){
                        Navigator.pop(context);
                      }, icon: const Icon(Icons.arrow_back_outlined, color: Colors.white,)),
                      const SizedBox(height: 20),
                    ],
                  ),
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
                  child: mainMenu(viewModel.selectedIndex, userId, userName, mobileNo, emailId, fromLogin),
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
        icon: Icon(Icons.manage_accounts_outlined),
        selectedIcon: Icon(Icons.manage_accounts_outlined, color: Colors.white),
        label: Text(''),
      ),
    ];

    return destinations;
  }

  Widget mainMenu(int index, int userId, String userName, String mobileNo, String emailId, bool fromLogin) {
    switch (index) {
      case 0:
        return DealerDashboard(
          userId: userId,
          userName: userName,
          mobileNo: mobileNo,
          fromLogin: fromLogin,
        );
      case 1:
        return ProductInventory(
          userId: userId,
          userName: userName,
          userRole: UserRole.dealer,
        );
      case 2:
        return AccountSettings(userId: userId, userName: userName, mobileNo: mobileNo, emailId: emailId, customerId: userId);
      default:
        return const SizedBox();
    }
  }
}