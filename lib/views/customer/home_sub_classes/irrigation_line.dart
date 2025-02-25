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
    double screenWidth = MediaQuery.sizeOf(context).width - pumpStationWith;
    return ChangeNotifierProvider(
      create: (_) => IrrigationLineViewModel(context, lineData, screenWidth),
      child: Consumer<IrrigationLineViewModel>(
        builder: (context, viewModel, _) {
          int rowCount = (viewModel.valves.length / viewModel.crossAxisCount).ceil();
          print('row count:$rowCount');
          return Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3.3),
                  child: Container(
                    color: Colors.grey.shade300,
                    width: 2,
                    height: rowCount==2?80:rowCount==3?150:rowCount==4?232:0,
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: viewModel.gridHeight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.75),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: viewModel.crossAxisCount,
                          childAspectRatio: 1.32,
                          mainAxisSpacing: 0.0,
                          crossAxisSpacing: 0.0,
                        ),
                        itemCount: viewModel.valves.length,
                        itemBuilder: (context, index) {
                          bool isLastInRow = (index + 1) % viewModel.crossAxisCount == 0;
                          bool isLastItem = index == viewModel.valves.length - 1;

                          return buildValveWidget(
                            viewModel.valves[index].name,
                            viewModel.valves[index].status,
                            isLastInRow,
                            isLastItem,
                          );

                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildValveWidget(String vName, int vStatus, bool isLastInRow, bool isLastItem) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(right: isLastInRow || isLastItem? 49:0),
          child: Divider(thickness: 2, color: Colors.grey.shade300, height: 5),
        ),
        SizedBox(
          width: 100,
          height: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 10,
                child: VerticalDivider(thickness: 1, color: Colors.grey.shade400),
              ),
              SizedBox(
                width: 35,
                height: 35,
                child: AppConstants.getAsset('valve', vStatus, ''),
              ),
              const SizedBox(height: 4),
              Text(
                vName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
