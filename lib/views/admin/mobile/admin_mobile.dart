import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Widgets/app_logo.dart';
import '../../../Widgets/user_account_menu.dart';
import '../../../flavors.dart';
import '../../../layouts/layout_selector.dart';
import '../../../utils/enums.dart';
import '../../../view_models/base_header_view_model.dart';
import '../../admin_dealer/product_inventory.dart';
import '../../admin_dealer/stock_entry.dart';
import '../../common/product_search_bar.dart';

class AdminMobile extends StatelessWidget {
  const AdminMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BaseHeaderViewModel>();
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.only(left: 15),
          child: AppLogo(),
        ),
        actions: const <Widget>[
          UserAccountMenu(screenType: 'Mobile'),
        ],
        centerTitle: false,
        elevation: 10,
        leadingWidth: F.appFlavor!.name.contains('oro') ? 75:110,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(viewModel.selectedIndex==1 ? 100 : 50),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width-35,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500), // Limit max size
                    child: SegmentedButton<MainMenuSegment>(
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white;
                          } else {
                            return Colors.white60;
                          }
                        }),
                        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Theme.of(context).primaryColorLight;
                          } else {
                            return Colors.white10;
                          }
                        }),
                        iconColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white;
                          } else {
                            return Colors.white70;
                          }
                        }),
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        visualDensity: VisualDensity.standard,
                        minimumSize: WidgetStateProperty.all(const Size(0, 45)),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      segments: const [
                        ButtonSegment(
                          value: MainMenuSegment.dashboard,
                          label: Text('Dashboard'),
                          icon: Icon(Icons.dashboard_outlined),
                        ),
                        ButtonSegment(
                          value: MainMenuSegment.product,
                          label: Text('Product'),
                          icon: Icon(Icons.inventory_2_outlined),
                        ),
                        ButtonSegment(
                          value: MainMenuSegment.stock,
                          label: Text('Stock'),
                          icon: Icon(Icons.warehouse_outlined),
                        ),
                      ],
                      selected: {context.watch<BaseHeaderViewModel>().mainMenuSegmentView},
                      onSelectionChanged: (Set<MainMenuSegment> newSelection) {
                        if (newSelection.isNotEmpty) {
                          context.read<BaseHeaderViewModel>().updateMainMenuSegmentView(newSelection.first);
                        }
                      },
                    ),
                  ),
                ),
              ),
              if(viewModel.selectedIndex==1)...[
                ProductSearchBar(viewModel: viewModel, barHeight: 45, barRadius: 10),
              ],
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: viewModel.selectedIndex,
        children: const [
          DashboardLayoutSelector(userRole: UserRole.admin),
          ProductInventory(),
          StockEntry(screenType: 'Mobile'),
        ],
      ),
    );
  }
}
