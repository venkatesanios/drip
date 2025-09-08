import 'package:flutter/cupertino.dart';
import '../../../flavors.dart';

Widget appBarLogo() {
  return F.appFlavor!.name.contains('oro') ?
  Image.asset(
    "assets/png/oro_logo_white.png",
    width: 70,
    fit: BoxFit.fitWidth,
  ) : Image.asset(
    "assets/png/lk_logo_white.png",
    width: 160,
    fit: BoxFit.fitWidth,
  );
}