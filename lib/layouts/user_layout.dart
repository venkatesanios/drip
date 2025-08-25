import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:oro_drip_irrigation/views/customer/mobile/customer_mobile.dart';
import 'package:oro_drip_irrigation/views/customer/tablet/customer_tablet.dart';
import 'package:oro_drip_irrigation/views/customer/web/customer_web.dart';
import '../providers/user_provider.dart';
import '../repository/repository.dart';
import '../services/http_service.dart';
import '../views/admin/middle/admin_middle.dart';
import '../views/admin/narrow/admin_narrow.dart';
import '../views/admin/wide/admin_wide.dart';
import '../views/common/login/middle/login_tablet.dart';
import '../views/common/login/narrow/login_mobile.dart';
import '../views/common/login/wide/login_web.dart';
import '../views/common/user_dashboard/dashboard_service_provider.dart';
import '../views/common/user_dashboard/mobile/admin_mobile_dashboard.dart';
import '../views/common/user_dashboard/mobile/customer_mobile_dashboard.dart';
import '../views/common/user_dashboard/mobile/dealer_mobile_dashboard.dart';
import '../view_models/base_header_view_model.dart';
import '../views/common/user_dashboard/tablet/admin_tablet_dashboard.dart';
import '../views/common/user_dashboard/tablet/customer_tablet_dashboard.dart';
import '../views/common/user_dashboard/tablet/dealer_tablet_dashboard.dart';
import '../views/common/user_dashboard/web/admin_web_dashboard.dart';
import '../views/common/user_dashboard/web/customer_web_dashboard.dart';
import '../views/common/user_dashboard/web/dealer_web_dashboard.dart';
import '../views/dealer/middle/dealer_tablet.dart';
import '../views/dealer/narrow/dealer_mobile.dart';
import '../views/dealer/wide/dealer_web.dart';
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
  Widget buildNarrow(BuildContext context) => const DealerMobile();
  @override
  Widget buildMiddle(BuildContext context) => const DealerTablet();
  @override
  Widget buildWide(BuildContext context) => const DealerWeb();
}

class CustomerScreenLayout extends BaseScreenLayout {
  const CustomerScreenLayout({super.key});

  @override
  Widget buildNarrow(BuildContext context) => const CustomerMobile();
  @override
  Widget buildMiddle(BuildContext context) => const CustomerTablet();
  @override
  Widget buildWide(BuildContext context) => const CustomerWeb();
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
    return DashboardServiceProvider(
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
    return DashboardServiceProvider(
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
  Widget buildNarrow(BuildContext context) => const CustomerMobileDashboard();
  @override
  Widget buildMiddle(BuildContext context) => const CustomerTabletDashboard();
  @override
  Widget buildWide(BuildContext context) => const CustomerWebDashboard();
}