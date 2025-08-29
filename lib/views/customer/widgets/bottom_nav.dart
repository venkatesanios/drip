import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

class CustomerBottomNav extends StatelessWidget {
  final dynamic vm;
  final dynamic currentMaster;

  const CustomerBottomNav({super.key,
    required this.vm,
    required this.currentMaster,
  });

  @override
  Widget build(BuildContext context) {
    final isGemModel = [
      ...AppConstants.gemModelList,
      ...AppConstants.ecoGemModelList
    ].contains(currentMaster.modelId);
    if (!isGemModel) return const SizedBox.shrink();

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).primaryColor,
      currentIndex: vm.selectedIndex,
      onTap: vm.onItemTapped,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white54,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: "Scheduled Program"),
        BottomNavigationBarItem(icon: Icon(Icons.report_gmailerrorred), label: "Log"),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
      ],
    );
  }
}