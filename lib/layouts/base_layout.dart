import 'package:flutter/material.dart';
import '../utils/enums.dart';
import '../utils/helpers/screen_helper.dart';

abstract class BaseLayout extends StatelessWidget {
  const BaseLayout({super.key});

  Widget buildMobile(BuildContext context);
  Widget buildTablet(BuildContext context);
  Widget buildDesktop(BuildContext context);
  Widget buildWeb(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final type = ScreenHelper.getDeviceType(width);

    switch (type) {
      case ScreenType.mobile:
        return buildMobile(context);
      case ScreenType.tablet:
        return buildTablet(context);
      case ScreenType.desktop:
        return buildDesktop(context);
      case ScreenType.web:
        return buildWeb(context);
    }
  }
}