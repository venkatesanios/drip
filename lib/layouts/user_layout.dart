import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:oro_drip_irrigation/views/customer/customer_narrow_layout.dart';
import 'package:oro_drip_irrigation/views/customer/customer_middle_layout.dart';
import 'package:oro_drip_irrigation/views/customer/customer_wide_layout.dart';
import '../providers/user_provider.dart';
import '../repository/repository.dart';
import '../services/http_service.dart';
import '../views/admin/admin_middle_layout.dart';
import '../views/admin/admin_narrow_layout.dart';
import '../views/admin/admin_wide_layout.dart';
import '../views/common/login/middle/login_tablet.dart';
import '../views/common/login/narrow/login_mobile.dart';
import '../views/common/login/wide/login_web.dart';
import '../views/common/user_dashboard/customer_dashboard_service.dart';
import '../views/common/user_dashboard/management_dashboard_service.dart';
import '../view_models/base_header_view_model.dart';
import '../views/common/user_dashboard/middle/admin_tablet_dashboard.dart';
import '../views/common/user_dashboard/middle/customer_tablet_dashboard.dart';
import '../views/common/user_dashboard/middle/dealer_tablet_dashboard.dart';
import '../views/common/user_dashboard/narrow/admin_mobile_dashboard.dart';
import '../views/common/user_dashboard/narrow/customer_home_narrow.dart';
import '../views/common/user_dashboard/narrow/dealer_mobile_dashboard.dart';
import '../views/common/user_dashboard/web/admin_web_dashboard.dart';
import '../views/common/user_dashboard/web/customer_web_dashboard.dart';
import '../views/common/user_dashboard/web/dealer_web_dashboard.dart';
import '../views/dealer/dealer_middle_layout.dart';
import '../views/dealer/dealer_narrow_layout.dart';
import '../views/dealer/dealer_wide_layout.dart';
import 'base_layout.dart';

class AdminScreenLayout extends BaseScreenLayout {
  const AdminScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final viewedCustomer = context.read<UserProvider>().viewedCustomer!;
    return ChangeNotifierProvider<BaseHeaderViewModel>(
      create: (_) => BaseHeaderViewModel(menuTitles: ['Dashboard', 'Inventory', 'Stock'],
          repository: Repository(HttpService()))..fetchCategoryModelList(
          viewedCustomer.id, viewedCustomer.role),
      child: super.build(context),
    );
  }

  @override
  Widget buildNarrow(BuildContext context) => const AdminNarrowLayout();
  @override
  Widget buildMiddle(BuildContext context) => const AdminMiddleLayout();
  @override
  Widget buildWide(BuildContext context) => const AdminWideLayout();
}

class DealerScreenLayout extends BaseScreenLayout {
  const DealerScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final viewedCustomer = context.read<UserProvider>().viewedCustomer!;
    return ChangeNotifierProvider<BaseHeaderViewModel>(
      create: (_) => BaseHeaderViewModel(menuTitles: ['Dashboard', 'Inventory'],
          repository: Repository(HttpService()))..fetchCategoryModelList(
          viewedCustomer.id, viewedCustomer.role),
      child: super.build(context),
    );
  }

  @override
  Widget buildNarrow(BuildContext context) => const DealerNarrowLayout();
  @override
  Widget buildMiddle(BuildContext context) => const DealerMiddleLayout();
  @override
  Widget buildWide(BuildContext context) => const DealerWideLayout();
}

class CustomerScreenLayout extends BaseScreenLayout {
  const CustomerScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final viewedCustomer = context.read<UserProvider>().viewedCustomer!;
    return CustomerDashboardService(
      customerId: viewedCustomer.id,
      child: super.build(context),
    );
  }

  @override
  Widget buildNarrow(BuildContext context) => const CustomerNarrowLayout();
  @override
  Widget buildMiddle(BuildContext context) => const CustomerMiddleLayout();
  @override
  Widget buildWide(BuildContext context) => const CustomerWideLayout();
}

class LoginScreenLayout extends BaseScreenLayout {
  const LoginScreenLayout({super.key});

  @override
  Widget buildNarrow(BuildContext context) => const LoginMobile();
  @override
  Widget buildMiddle(BuildContext context) => const LoginTablet();
  @override
  Widget buildWide(BuildContext context) => const LoginWeb();
}

class AdminDashboardLayout extends BaseScreenLayout {
  const AdminDashboardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final viewedCustomer = context.read<UserProvider>().viewedCustomer!;
    return ManagementDashboardService(
      userId: viewedCustomer.id,
      userType: 1,
      child: super.build(context),
    );
  }

  @override
  Widget buildNarrow(BuildContext context) => const AdminMobileDashboard();
  @override
  Widget buildMiddle(BuildContext context) => const AdminTabletDashboard();
  @override
  Widget buildWide(BuildContext context) => const AdminWebDashboard();
}

class DealerDashboardLayout extends BaseScreenLayout {
  const DealerDashboardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final viewedCustomer = context.read<UserProvider>().viewedCustomer!;
    return ManagementDashboardService(
      userId: viewedCustomer.id,
      userType: 2,
      child: super.build(context),
    );
  }

  @override
  Widget buildNarrow(BuildContext context) => const DealerMobileDashboard();
  @override
  Widget buildMiddle(BuildContext context) => const DealerTabletDashboard();
  @override
  Widget buildWide(BuildContext context) => const DealerWebDashboard();
}


class CustomerDashboardLayout extends BaseScreenLayout {
  const CustomerDashboardLayout({super.key});

  @override
  Widget buildNarrow(BuildContext context) => const CustomerDashboardNarrow();
  @override
  Widget buildMiddle(BuildContext context) => const CustomerTabletDashboard();
  @override
  Widget buildWide(BuildContext context) => const CustomerWebDashboard();
}
