import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Models/customer/site_model.dart';
import '../../../services/communication_service.dart';
import '../../../view_models/customer/customer_screen_controller_view_model.dart';
import '../customer_home.dart';

class MobileDashboard extends StatelessWidget {
  const MobileDashboard({super.key, required this.customerId, required this.controllerId,
    required this.deviceId, required this.modelId});
  final int customerId, controllerId, modelId;
  final String deviceId;

  Widget build(BuildContext context) {

    final viewModel = context.read<CustomerScreenControllerViewModel>();

    final irrigationLines = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].irrigationLine;
    final scheduledProgram = viewModel.mySiteList.data[viewModel.sIndex].master[viewModel.mIndex].programList;

    final linesToDisplay = (viewModel.myCurrentIrrLine == "All irrigation line" || viewModel.myCurrentIrrLine.isEmpty)
        ? irrigationLines.where((line) => line.name != viewModel.myCurrentIrrLine).toList()
        : irrigationLines.where((line) => line.name == viewModel.myCurrentIrrLine).toList();

    return _buildMobileLayout(context, linesToDisplay, scheduledProgram);
  }


  Widget _buildMobileLayout(
      BuildContext context, List<IrrigationLineModel> irrigationLine, scheduledProgram) {

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ...irrigationLine.map((line) => Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, right: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 0.5,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 45,
                    color: Theme.of(context).primaryColor.withOpacity(0.03),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Text(
                          line.name,
                          textAlign: TextAlign.left,
                          style: const TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        MaterialButton(
                          color: line.linePauseFlag == 0
                              ? Theme.of(context).primaryColorLight
                              : Colors.orange.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          onPressed: () async {
                            String payLoadFinal = jsonEncode({
                              "4900": {
                                "4901": "${line.sNo}, ${line.linePauseFlag == 0 ? 1 : 0}",
                              }
                            });

                            final result = await context.read<CommunicationService>().sendCommand(
                              payload: payLoadFinal,
                              serverMsg: line.linePauseFlag == 0
                                  ? 'Paused the ${line.name}'
                                  : 'Resumed the ${line.name}',
                            );

                            if (result['http'] == true) debugPrint("Payload sent to Server");
                            if (result['mqtt'] == true) debugPrint("Payload sent to MQTT Box");
                            if (result['bluetooth'] == true) debugPrint("Payload sent via Bluetooth");
                          },
                          child: Text(
                            line.linePauseFlag == 0 ? 'PAUSE THE LINE' : 'RESUME THE LINE',
                            style: const TextStyle(
                              color:Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5)
                      ],
                    ),
                  ),
                  buildIrrigationLine(context, line, customerId, controllerId, modelId),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget buildIrrigationLine(BuildContext context, IrrigationLineModel irrLine, int customerId, int controllerId, int modelId){

    final inletWaterSources = {
      for (var source in irrLine.inletSources) source.sNo: source
    }.values.toList();

    final outletWaterSources = {
      for (var source in irrLine.outletSources) source.sNo: source
    }.values.toList();

    final filterSite = {
      if (irrLine.centralFilterSite != null) irrLine.centralFilterSite!.sNo : irrLine.centralFilterSite!
    }.values.toList();

    final fertilizerSite = {
      if (irrLine.centralFertilizerSite != null) irrLine.centralFertilizerSite!.sNo : irrLine.centralFertilizerSite!
    }.values.toList();

    return PumpStationWithLine(
      inletWaterSources: inletWaterSources,
      outletWaterSources: outletWaterSources,
      filterSite: filterSite,
      fertilizerSite: fertilizerSite,
      valves: irrLine.valveObjects,
      mainValves: irrLine.mainValveObjects,
      lights:irrLine.lightObjects,
      gates:irrLine.gateObjects,
      prsSwitch: irrLine.prsSwitch,
      pressureIn: irrLine.pressureIn,
      pressureOut: irrLine.pressureOut,
      waterMeter: irrLine.waterMeter,
      customerId: customerId,
      controllerId: controllerId,
      containerWidth: MediaQuery.sizeOf(context).width,
      deviceId: deviceId,
      modelId: modelId,
    );
  }

}