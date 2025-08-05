import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/views/customer/mobile/customer_mobile.dart';
import 'package:provider/provider.dart';
import '../view_models/base_header_view_model.dart';
import '../views/admin/desktop/admin_desktop.dart';
import '../views/admin/mobile/admin_mobile.dart';
import '../views/admin/tablet/admin_tablet.dart';
import '../views/admin/web/admin_web.dart';
import '../views/customer/mobile/customer_mobile.dart';
import '../views/dealer/desktop/dealer_desktop.dart';
import '../views/dealer/mobile/dealer_mobile.dart';
import '../views/dealer/tablet/dealer_tablet.dart';
import '../views/dealer/web/dealer_web.dart';
import 'base_layout.dart';

class AdminLayout extends BaseLayout {
  const AdminLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BaseHeaderViewModel>(
      create: (_) => BaseHeaderViewModel(menuTitles: ['Dashboard', 'Products', 'Stock']),
      child: super.build(context),
    );
  }

  @override
  Widget buildDesktop(BuildContext context) => const AdminDesktop();
  @override
  Widget buildTablet(BuildContext context) => const AdminTablet();
  @override
  Widget buildMobile(BuildContext context) => const AdminMobile();
  @override
  Widget buildWeb(BuildContext context) => const AdminWeb();

}

class DealerLayout extends BaseLayout {
  const DealerLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BaseHeaderViewModel>(
      create: (_) => BaseHeaderViewModel(menuTitles: ['Dashboard', 'Products']),
      child: super.build(context),
    );
  }

  @override
  Widget buildDesktop(BuildContext context) => const DealerDesktop();
  @override
  Widget buildMobile(BuildContext context) => const DealerMobile();
  @override
  Widget buildTablet(BuildContext context) => const DealerTablet();
  @override
  Widget buildWeb(BuildContext context) => const DealerWeb();

}

class CustomerLayout extends BaseLayout {
  const CustomerLayout({super.key});

  @override
  Widget buildMobile(BuildContext context) => const CustomerMobile();

  @override
  Widget buildDesktop(BuildContext context) {
    // TODO: implement buildDesktop
    throw UnimplementedError();
  }


  @override
  Widget buildTablet(BuildContext context) {
    // TODO: implement buildTablet
    throw UnimplementedError();
  }

  @override
  Widget buildWeb(BuildContext context) {
    // TODO: implement buildWeb
    throw UnimplementedError();
  }

}