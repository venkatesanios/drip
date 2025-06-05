import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/admin_dealer/product_entry.dart';
import 'package:oro_drip_irrigation/views/admin_dealer/product_inventory.dart';
import 'package:oro_drip_irrigation/views/admin_dealer/stock_entry.dart';
import 'package:provider/provider.dart';
import '../../Screens/Dealer/ServicerequestAdmin.dart';
import '../../flavors.dart';
import '../../utils/constants.dart';
import '../../view_models/nav_rail_view_model.dart';
import '../account_settings.dart';
import 'admin_dashboard.dart';

class AdminScreenController extends StatefulWidget {
  const AdminScreenController({super.key, required this.userId, required this.userName, required this.mobileNo, required this.emailId});
  final int userId;
  final String userName, mobileNo, emailId;

  @override
  State<AdminScreenController> createState() => _AdminScreenControllerState();
}

class _AdminScreenControllerState extends State<AdminScreenController> {

  int selectedIndex = 0;
  int hoveredIndex = -1;
  final List<String> menuTitles = ['Dashboard', 'Products', 'Stock'];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavRailViewModel(),
      child: Consumer<NavRailViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Image.asset(
                  width: F.appFlavor!.name.contains('oro') ? 75:150,
                  F.appFlavor!.name.contains('oro')
                      ? "assets/png/oro_logo_white.png"
                      : "assets/png/company_logo.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(menuTitles.length, (index) {
                    final isSelected = selectedIndex == index;
                    final isHovered = hoveredIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? F.appFlavor!.name.contains('oro') ? Colors.teal:
                                    Theme.of(context).primaryColorLight
                                  : isHovered
                                  ? Colors.white24
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  index==0?Icons.dashboard_outlined:index==1? Icons.format_list_numbered:Icons.playlist_add_circle_outlined,
                                  size: 18,
                                  color: isSelected?Colors.white:Colors.white54,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  menuTitles[index],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
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
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          onTapDown: (TapDownDetails details) {
                            final offset = details.globalPosition;
                            showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, 0),
                              items: [
                                const PopupMenuItem(
                                  value: 'profile',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_outline),
                                      SizedBox(width: 8),
                                      Text('Profile Settings'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'logout',
                                  child: Row(
                                    children: [
                                      Icon(Icons.logout, color: Colors.redAccent),
                                      SizedBox(width: 5),
                                      Text('Logout'),
                                    ],
                                  ),
                                ),
                              ],
                            ).then((value) async {
                              if (value == 'profile') {
                                showModalBottomSheet(
                                  context: context,
                                  elevation: 10,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5))),
                                  builder: (BuildContext context) {
                                    return AccountSettings(userId: widget.userId, userName: widget.userName,
                                        mobileNo: widget.mobileNo, emailId: widget.emailId, customerId: widget.userId);
                                  },
                                );
                              } else if (value == 'logout') {
                                await viewModel.logout(context);
                              }
                              //AccountSettings(userId: userId, userName: userName, mobileNo: widget.mobileNo, emailId: widget.emailId, customerId: userId)
                            });
                          },
                          child: Container(
                            width: 230,
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
                                Text(
                                  widget.userName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_drop_down_sharp, color: Colors.black54),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],),
              ],
              centerTitle: false,
              elevation: 10,
              leadingWidth: F.appFlavor!.name.contains('oro') ? 75:110,
            ),
            /*body: IndexedStack(
              index: selectedIndex,
              children: const [
                Center(child: Text('Home Page')),
                Center(child: Text('Product List')),
                Center(child: Text('Stock Page')),
              ],
            ),*/
            /*appBar: AppBar(
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
                    *//*Text(viewModel.userName!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(width: 08),
                    const CircleAvatar(
                      radius: 23,
                      backgroundImage: AssetImage("assets/png/user_thumbnail.png"),
                    ),*//*
                  ],),
              ],
            ),*/

            body: Row(
              children: [
                Card(),
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children:  [
                      AdminDashboard(
                        userId: widget.userId,
                        userName: widget.userName, mobileNo: widget.mobileNo,
                      ),
                      ProductInventory(
                        userId: widget.userId,
                        userName: widget.userName,
                        userRole: UserRole.admin,
                      ),
                      StockEntry(userId: widget.userId),
                    ],
                  ),
                ),
                Card(),
              ],
            ),
           /* body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Card(elevation: 10),
                *//*NavigationRail(
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
                ),*//*
                Expanded(
                  child: mainMenu(viewModel.selectedIndex, widget.userId, widget.userName),
                ),
              ],
            ),*/
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
          userName: userName, mobileNo: widget.mobileNo,
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
        return AccountSettings(userId: userId, userName: userName, mobileNo: widget.mobileNo, emailId: widget.emailId, customerId: userId);
      case 4:
        return ServiceRequestAdmin(userId: userId,);
       default:
        return const SizedBox();
    }
  }
}