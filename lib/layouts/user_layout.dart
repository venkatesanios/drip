import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:oro_drip_irrigation/views/customer/desktop/customer_desktop.dart';
import 'package:oro_drip_irrigation/views/customer/mobile/customer_mobile.dart';
import 'package:oro_drip_irrigation/views/customer/tablet/customer_tablet.dart';
import 'package:oro_drip_irrigation/views/customer/web/customer_web.dart';
import '../providers/user_provider.dart';
import '../repository/repository.dart';
import '../services/http_service.dart';
import '../views/common/user_dashboard/dashboard_service_provider.dart';
import '../views/common/user_dashboard/mobile/admin_mobile_dashboard.dart';
import '../views/common/user_dashboard/mobile/customer_mobile_dashboard.dart';
import '../views/common/user_dashboard/mobile/dealer_mobile_dashboard.dart';
import '../view_models/base_header_view_model.dart';
import '../views/admin/desktop/admin_desktop.dart';
import '../views/admin/mobile/admin_mobile.dart';
import '../views/admin/tablet/admin_tablet.dart';
import '../views/admin/web/admin_web.dart';
import '../views/common/login/desktop/login_desktop.dart';
import '../views/common/login/mobile/login_mobile.dart';
import '../views/common/login/tablet/login_tablet.dart';
import '../views/common/login/web/login_web.dart';
import '../views/common/user_dashboard/tablet/admin_tablet_dashboard.dart';
import '../views/common/user_dashboard/tablet/customer_tablet_dashboard.dart';
import '../views/common/user_dashboard/tablet/dealer_tablet_dashboard.dart';
import '../views/common/user_dashboard/web/admin_web_dashboard.dart';
import '../views/common/user_dashboard/web/customer_web_dashboard.dart';
import '../views/common/user_dashboard/web/dealer_web_dashboard.dart';
import '../views/dealer/desktop/dealer_desktop.dart';
import '../views/dealer/mobile/dealer_mobile.dart';
import '../views/dealer/tablet/dealer_tablet.dart';
import '../views/dealer/web/dealer_web.dart';
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
  Widget buildMobile(BuildContext context) => const AdminMobile();
  @override
  Widget buildTablet(BuildContext context) => const AdminTablet();
  @override
  Widget buildDesktop(BuildContext context) => const AdminDesktop();
  @override
  Widget buildWeb(BuildContext context) => const AdminWeb();
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
  Widget buildMobile(BuildContext context) => const DealerMobile();
  @override
  Widget buildTablet(BuildContext context) => const DealerTablet();
  @override
  Widget buildDesktop(BuildContext context) => const DealerDesktop();
  @override
  Widget buildWeb(BuildContext context) => const DealerWeb();
}

class CustomerScreenLayout extends BaseScreenLayout {
  const CustomerScreenLayout({super.key});

  @override
  Widget buildMobile(BuildContext context) => const CustomerMobile();
  @override
  Widget buildTablet(BuildContext context) => const CustomerTablet();
  @override
  Widget buildDesktop(BuildContext context) => const CustomerWeb();
  @override
  Widget buildWeb(BuildContext context) => const CustomerWeb();
}

class LoginScreenLayout extends BaseScreenLayout {
  const LoginScreenLayout({super.key});

  @override
  Widget buildMobile(BuildContext context) => const LoginMobile();
  @override
  Widget buildTablet(BuildContext context) => const LoginTablet();
  @override
  Widget buildDesktop(BuildContext context) => const LoginDesktop();
  @override
  Widget buildWeb(BuildContext context) => const LoginWeb();
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
  Widget buildMobile(BuildContext context) => const AdminMobileDashboard();
  @override
  Widget buildTablet(BuildContext context) => const AdminTabletDashboard();
  @override
  Widget buildDesktop(BuildContext context) => const AdminWebDashboard();
  @override
  Widget buildWeb(BuildContext context) => const AdminWebDashboard();
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
  Widget buildMobile(BuildContext context) => const DealerMobileDashboard();
  @override
  Widget buildTablet(BuildContext context) => const DealerTabletDashboard();
  @override
  Widget buildDesktop(BuildContext context) => const DealerWebDashboard();
  @override
  Widget buildWeb(BuildContext context) => const DealerWebDashboard();
}

class CustomerDashboardLayout extends BaseScreenLayout {
  const CustomerDashboardLayout({super.key});

  @override
  Widget buildMobile(BuildContext context) => const CustomerMobileDashboard();
  @override
  Widget buildTablet(BuildContext context) => const CustomerTabletDashboard();
  @override
  Widget buildDesktop(BuildContext context) => const CustomerWebDashboard();
  @override
  Widget buildWeb(BuildContext context) => const CustomerWebDashboard();
}