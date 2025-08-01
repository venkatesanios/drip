import 'package:flutter/material.dart';
import 'package:oro_drip_irrigation/layouts/base_layout.dart';
import 'package:oro_drip_irrigation/views/admin/desktop/admin_desktop.dart';
import 'package:oro_drip_irrigation/views/admin/mobile/admin_mobile.dart';
import 'package:oro_drip_irrigation/views/admin/tablet/admin_tablet.dart';
import 'package:provider/provider.dart';

import '../view_models/admin_header_view_model.dart';
import '../views/admin/web/admin_web.dart';

class AdminLayout extends BaseLayout {
  const AdminLayout({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<AdminHeaderViewModel>(
      create: (_) => AdminHeaderViewModel(),
      child: Consumer<AdminHeaderViewModel>(
        builder: (context, viewModel, _) {
          return super.build(context);
        },
      ),
    );
  }

  @override
  Widget buildDesktop(BuildContext context) => const AdminDesktop();
  @override
  Widget buildTablet(BuildContext context) => const AdminTablet();
  @override
  Widget buildMobile(BuildContext context) => const AdminMobileLayout();
  @override
  Widget buildWeb(BuildContext context) => const AdminWeb();

}