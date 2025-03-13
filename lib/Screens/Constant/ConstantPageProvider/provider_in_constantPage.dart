import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../general_in_constant.dart';
import 'changeNotifier_constantProvider.dart';

class ProviderInConstantPage extends StatelessWidget {
  const ProviderInConstantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ConstantProvider(),
      child: Scaffold(
        body: Consumer<ConstantProvider>(
          builder: (context, provider, child) {
             return GeneralPage(generalUpdated: provider.generalUpdated);

          },
        ),
      ),
    );
  }
}


