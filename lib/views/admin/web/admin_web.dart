import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../flavors.dart';
import '../../../view_models/admin_header_view_model.dart';

class AdminWeb extends StatelessWidget {
  const AdminWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminHeaderViewModel>();

    return Scaffold(
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
        title: buildMainMenu(context, viewModel),
        actions: <Widget>[
        ],
        centerTitle: false,
        elevation: 10,
        leadingWidth: F.appFlavor!.name.contains('oro') ? 75:110,
      ),
      body: Center(child: Text("Admin Web Dashboard")),
    );
  }

  Widget buildMainMenu(BuildContext context, AdminHeaderViewModel viewModel)
  {
    final sWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(viewModel.menuTitles.length, (index) {
              final isSelected = viewModel.selectedIndex == index;
              final isHovered = viewModel.hoveredIndex == index;

              return Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  //onEnter: (_) => setState(() => viewModel.hoveredIndex = index),
                  //onExit: (_) => setState(() => viewModel.hoveredIndex = -1),
                  child: InkWell(
                    onTap: () {
                      viewModel.selectedIndex = index;
                    },
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
                            viewModel.menuTitles[index],
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
        ],
      ),
    );
  }
}