import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/admin_dealer/product_inventory.dart';
import 'package:oro_drip_irrigation/views/admin_dealer/stock_entry.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/search_provider.dart';
import '../../flavors.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';
import '../../utils/enums.dart';
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

  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (_) => NavRailViewModel(Repository(HttpService()))..getCategoryModelList(widget.userId, UserRole.admin),
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
              title: screenWidth > 695? buildMainMenu(context, viewModel):
              const SizedBox(),
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
                                    return const AccountSettings(hideAppbar: false);
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
            body: Column(
              children: [
                if(screenWidth<=695)...[
                  Container(
                    width: screenWidth,
                    color: Theme.of(context).primaryColor,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            children: [
                              buildMainMenu(context, viewModel),
                              if(selectedIndex==1)...[
                                const SizedBox(height: 8),
                                buildSearchBar(viewModel),
                              ]
                            ],
                          ),
                        ),
                      )
                  ),
                ],
                Expanded(
                  child: IndexedStack(
                    index: selectedIndex,
                    children: List.generate(menuTitles.length, (index) {
                      return selectedIndex == index ? getPage(index) :
                      const SizedBox();
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildMainMenu(BuildContext context, NavRailViewModel viewModel)
  {
    final sWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(menuTitles.length, (index) {
              final isSelected = selectedIndex == index;
              final isHovered = hoveredIndex == index;

              return Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => hoveredIndex = index),
                  onExit: (_) => setState(() => hoveredIndex = -1),
                  child: InkWell(
                    onTap: () => setState(() => selectedIndex = index),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColorLight
                            : isHovered
                            ? Colors.white24
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            index == 0
                                ? Icons.dashboard_outlined
                                : index == 1
                                ? Icons.format_list_numbered
                                : Icons.playlist_add_circle_outlined,
                            size: 18,
                            color: isSelected ? Colors.white : Colors.white54,
                          ),
                          const SizedBox(width: 8),
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
          if(selectedIndex==1 && sWidth > 695)...[
            buildSearchBar(viewModel),
          ]
        ],
      ),
    );
  }

  Widget buildSearchBar(NavRailViewModel viewModel)
  {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Spacer(),
        Container(
          width: 400,
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12, width: 0.7),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 350,
                child: TextField(
                  controller: viewModel.txtFldSearch,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    suffixIcon: viewModel.txtFldSearch.text.isNotEmpty ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.redAccent),
                      onPressed: () {
                        viewModel.clearSearch();
                        context.read<SearchProvider>().isSearchingProduct(false);
                        context.read<SearchProvider>().clearSearchFilters();
                      },
                    ) : null,
                    hintText: 'Search by device id / sales person',
                    hintStyle: const TextStyle(color: Colors.white24),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 100), () {
                      if (value.isEmpty) {
                        context.read<SearchProvider>().clearSearchFilters();
                      } else {
                        context.read<SearchProvider>().isSearchingProduct(true);
                        context.read<SearchProvider>().updateSearch(value);
                        context.read<SearchProvider>().updateCategoryId(0);
                        context.read<SearchProvider>().updateModelId(0);
                      }
                    });
                  },
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      context.read<SearchProvider>().isSearchingProduct(true);
                      context.read<SearchProvider>().updateSearch(value);
                    }
                  },
                ),
              ),
              PopupMenuButton<dynamic>(
                icon: const Icon(Icons.filter_alt_outlined),
                tooltip: 'Filter by category or model',
                itemBuilder: (BuildContext context) {
                  final categoryItems = viewModel.jsonDataMap['data']?['category'] ?? [];
                  final modelItems = viewModel.jsonDataMap['data']?['model'] ?? [];

                  return [
                    const PopupMenuItem<dynamic>(
                      enabled: false,
                      child: Text("Category"),
                    ),
                    ...categoryItems.map<PopupMenuItem>((item) => PopupMenuItem(
                      value: item,
                      child: Text(item['categoryName']),
                    )),
                    const PopupMenuItem<dynamic>(
                      enabled: false,
                      child: Text("Model"),
                    ),
                    ...modelItems.map<PopupMenuItem>((item) => PopupMenuItem(
                      value: item,
                      child: Text('${item['categoryName']} - ${item['modelName']}'),
                    )),
                  ];
                },
                onSelected: (selectedItem) {
                  if (selectedItem is Map<String, dynamic>) {
                    viewModel.txtFldSearch.text = selectedItem.containsKey('modelName')
                        ? '${selectedItem['categoryName']} - ${selectedItem['modelName']}'
                        : '${selectedItem['categoryName']}';

                    context.read<SearchProvider>().isSearchingProduct(true);
                    context.read<SearchProvider>().updateSearch('');
                    context.read<SearchProvider>().updateCategoryId(
                      selectedItem['categoryId'] ?? 0,
                    );
                    context.read<SearchProvider>().updateModelId(
                      selectedItem['modelId'] ?? 0,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget getPage(int index) {
    switch (index) {
      case 0:
        return const AdminDashboard(isWideLayout: true);
      case 1:
        return const ProductInventory();
      case 2:
        return const StockEntry();
      default:
        return const SizedBox();
    }
  }

}