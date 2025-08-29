import 'package:flutter/material.dart';

import '../../../Screens/Dealer/sevicecustomer.dart';
import '../../../flavors.dart';
import '../../../modules/UserChat/view/user_chat.dart';
import '../../../utils/routes.dart';
import '../../../utils/shared_preferences_helper.dart';
import '../../common/user_profile/user_profile.dart';
import '../app_info.dart';
import '../customer_product.dart';

class CustomerDrawer extends StatelessWidget {
  final dynamic vm;
  final dynamic viewedCustomer;
  final dynamic loggedInUser;

  const CustomerDrawer({
    super.key,
    required this.vm,
    required this.viewedCustomer,
    required this.loggedInUser,
  });

  Widget drawerTile({required BuildContext context, required IconData icon,
    required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Theme.of(context).primaryColor),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: onTap,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 25),
          child: Divider(height: 0, color: Colors.grey.shade300),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(),
      surfaceTintColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(viewedCustomer!.name,
                          style: const TextStyle(color: Colors.white)),
                      Text(viewedCustomer.mobileNo,
                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                      Text(viewedCustomer.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(width: 75, height: 75, child: CircleAvatar()),
              ],
            ),
          ),
          drawerTile(
            context: context,
            icon: Icons.account_circle_outlined,
            title: "Profile",
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const UserProfile()),
            ),
          ),
          drawerTile(
            context: context,
            icon: Icons.info_outline,
            title: "App Info",
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AppInfo()),
            ),
          ),
          drawerTile(
            context: context,
            icon: Icons.help_outline,
            title: "Help",
            onTap: () => Navigator.push(context,
              MaterialPageRoute(
                builder: (_) => UserChatScreen(
                  userId: viewedCustomer.id,
                  userName: viewedCustomer.name,
                  phoneNumber: viewedCustomer.mobileNo,
                ),
              ),
            ),
          ),
          drawerTile(
            context: context,
            icon: Icons.feedback_outlined,
            title: "Send Feedback",
            onTap: () {}, // TODO: implement feedback
          ),
          drawerTile(
            context: context,
            icon: Icons.support_agent_sharp,
            title: "Service Request",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TicketHomePage(
                  userId: loggedInUser.id,
                  controllerId: vm.mySiteList.data[vm.sIndex].master[vm.mIndex].controllerId,
                ),
              ),
            ),
          ),
          drawerTile(
            context: context,
            icon: Icons.devices,
            title: "All my devices",
            onTap: () => Navigator.push(context,
              MaterialPageRoute(
                builder: (_) => CustomerProduct(customerId: loggedInUser.id),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: TextButton.icon(
              onPressed: () async {
                await PreferenceHelper.clearAll();
                Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Logout",
                  style: TextStyle(color: Colors.red, fontSize: 17)),
              style: TextButton.styleFrom(alignment: Alignment.centerLeft),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                F.appFlavor!.name.contains('oro')
                    ? Image.asset('assets/png/company_logo_nia.png', width: 60)
                    : SizedBox(
                  height: 60,
                  child: Image.asset('assets/png/company_logo.png'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}