import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Models/customer/site_model.dart';
import '../../../utils/constants.dart';
import '../../../view_models/customer/irrigation_line_view_model.dart';

class IrrigationLine extends StatelessWidget {
  final List<IrrigationLineData>? lineData;
  final double pumpStationWith;

  const IrrigationLine({super.key, required this.lineData, required this.pumpStationWith});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => IrrigationLineViewModel(context, lineData, MediaQuery.of(context).size.width, pumpStationWith),
      child: Consumer<IrrigationLineViewModel>(
        builder: (context, vm, _) {

          return SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: vm.gridHeight,
            child: Padding(
              padding: const EdgeInsets.only(left: 3, right: 3),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: vm.crossAxisCount,
                  childAspectRatio: 1.32,
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                ),
                itemCount: vm.valveWidgets.length,
                itemBuilder: (context, index) {
                  return vm.valveWidgets[index];
                },
              ),
            ),
          );

        },
      ),
    );
  }
}