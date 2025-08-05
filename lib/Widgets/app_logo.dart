import 'package:flutter/cupertino.dart';
import '../flavors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final isOro = F.appFlavor!.name.contains('oro');
    return Image.asset(
      isOro ? "assets/png/oro_logo_white.png" : "assets/png/company_logo.png",
      width: isOro ? 75 : 150,
      fit: BoxFit.fitWidth,
    );
  }
}