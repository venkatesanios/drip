
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Models/customer/site_model.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';

class CurrentProgram extends StatelessWidget {
  const CurrentProgram({super.key, required this.scheduledPrograms});
  final List<ProgramList> scheduledPrograms;

  @override
  Widget build(BuildContext context) {

    var currentSchedule = Provider.of<MqttPayloadProvider>(context).currentSchedule;
    print('currentProgram:$currentSchedule');

    return currentSchedule.isNotEmpty && currentSchedule[0].isNotEmpty?
    Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey,
                  width: 0.5,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              height: (currentSchedule.length * 45) + 45,
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 1100,
                dataRowHeight: 45.0,
                headingRowHeight: 40.0,
                headingRowColor: WidgetStateProperty.all<Color>(Colors.green.shade50),
                columns: const [
                  DataColumn2(
                      label: Text('Name', style: TextStyle(fontSize: 13),),
                      size: ColumnSize.M
                  ),
                  DataColumn2(
                    label: Text('Location', style: TextStyle(fontSize: 13)),
                    fixedWidth: 75,
                  ),
                  DataColumn2(
                    label: Text('Zone', style: TextStyle(fontSize: 13),),
                    fixedWidth: 75,
                  ),
                  DataColumn2(
                      label: Text('Zone Name', style: TextStyle(fontSize: 13)),
                      size: ColumnSize.S
                  ),
                  DataColumn2(
                    label: Center(child: Text('RTC', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 75,
                  ),
                  DataColumn2(
                    label: Center(child: Text('Cyclic', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 75,
                  ),
                  DataColumn2(
                    label: Center(child: Text('Start Time', style: TextStyle(fontSize: 13),)),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Center(child: Text('Set (Dur/Flw)', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 100,
                  ),
                  DataColumn2(
                    label: Center(child: Text('Avg/Flw Rate', style: TextStyle(fontSize: 13),)),
                    fixedWidth: 100,
                  ),
                  DataColumn2(
                    label: Center(child: Text('Remaining', style: TextStyle(fontSize: 13),)),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Center(child: Text('')),
                    fixedWidth: 90,
                  ),
                ],

                rows: List<DataRow>.generate(currentSchedule.length, (index) => DataRow(cells: [
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(getProgramNameById(int.parse(currentSchedule[index][0]))),
                        //Text(getContentByCode(widget.currentSchedule[index].reasonCode), style: const TextStyle(fontSize: 10, color: Colors.black),),
                      ],
                    ),
                  ),
                  //DataCell(Text(widget.currentSchedule[index].programCategory)),
                  DataCell(Text('dfdfdf')),
                  DataCell(Text('dfdfdf')),
                  DataCell(Text('dfdfdf')),
                  DataCell(Text('dfdfdf')),
                  DataCell(Text('dfdfdf')),
                  DataCell(Text('dfdfdf')),
                  DataCell(Text('dfdfdf')),
                  DataCell(Text('dfdfdf')),
                  DataCell(Text('dfdfdf')),
                  DataCell(Text('dfdfdf')),
                  /*DataCell(Text('${widget.currentSchedule[index].currentZone}/${widget.currentSchedule[index].totalZone}')),
            DataCell(Text(widget.currentSchedule[index].programName=='StandAlone - Manual'? '--':widget.currentSchedule[index].zoneName)),
            DataCell(Center(child: Text(formatRtcValues(widget.currentSchedule[index].currentRtc, widget.currentSchedule[index].totalRtc)))),
            DataCell(Center(child: Text(formatRtcValues(widget.currentSchedule[index].currentCycle,widget.currentSchedule[index].totalCycle)))),
            DataCell(Center(child: Text(convert24HourTo12Hour(widget.currentSchedule[index].startTime)))),
            DataCell(Center(child: Text(widget.currentSchedule[index].programName=='StandAlone - Manual' &&
                (widget.currentSchedule[index].duration_Qty=='00:00:00'||widget.currentSchedule[index].duration_Qty=='0')?
            'Timeless': widget.currentSchedule[index].duration_Qty))),
            DataCell(Center(child: Text('${widget.currentSchedule[index].actualFlowRate}/hr'))),
            DataCell(Center(child: Text(widget.currentSchedule[index].programName=='StandAlone - Manual' &&
                (widget.currentSchedule[index].duration_Qty=='00:00:00'||widget.currentSchedule[index].duration_Qty=='0')? '----': widget.currentSchedule[index].duration_QtyLeft,
                style:  const TextStyle(fontSize: 20)))),
            DataCell(Center(
              child: widget.currentSchedule[index].programName=='StandAlone - Manual'?
              MaterialButton(
                color: Colors.redAccent,
                textColor: Colors.white,
                onPressed: widget.currentSchedule[index].message=='Running.'? (){
                  String payload = '0,0,0,0';
                  String payLoadFinal = jsonEncode({
                    "800": [{"801": payload}]
                  });
                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                  sendToServer(0,widget.currentSchedule[index].programName, widget.currentSchedule[index].zoneName,
                      widget.currentSchedule[index].duration_Qty=='00:00:00'? 3:
                      widget.currentSchedule[index].duration_Qty.contains(':')? 1: 2, payLoadFinal);
                }: null,
                child: const Text('Stop'),
              ):
              widget.currentSchedule[index].programName.contains('StandAlone')?
              MaterialButton(
                color: Colors.redAccent,
                textColor: Colors.white,
                onPressed: () async {

                  String payLoadFinal = jsonEncode({
                    "3900": [{"3901": '0,${widget.currentSchedule[index].programCategory},${widget.currentSchedule[index].programSno},'
                        '${widget.currentSchedule[index].zoneSNo},,,,,,,,,0,'}]
                  });

                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                  sendToServer(widget.currentSchedule[index].programSno,widget.currentSchedule[index].programName,
                      widget.currentSchedule[index].zoneName,
                      widget.currentSchedule[index].duration_Qty=='00:00:00'? 3:
                      widget.currentSchedule[index].duration_Qty.contains(':')?1: 2, payLoadFinal);
                },
                child: const Text('Stop'),
              ):
              MaterialButton(
                color: Colors.orange,
                textColor: Colors.white,
                onPressed: widget.currentSchedule[index].message=='Running.'? (){
                  String payload = '${widget.currentSchedule[index].srlNo},0';
                  String payLoadFinal = jsonEncode({
                    "3700": [{"3701": payload}]
                  });
                  MQTTManager().publish(payLoadFinal, 'AppToFirmware/${widget.siteData.master[0].deviceId}');
                  sendSkipOperationToServer('${widget.currentSchedule[index].programName} - ${widget.currentSchedule[index].zoneName} skipped manually', payLoadFinal);
                } : null,
                child: const Text('Skip'),
              ),
            )),*/
                ])),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 0,
            child: Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                  border: Border.all(width: 0.5, color: Colors.grey)
              ),
              child: const Text('CURRENT SCHEDULE',  style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    ):
    const SizedBox();
  }

  String getProgramNameById(int id) {
    print('Program id:$id');
    try {
      return scheduledPrograms.firstWhere((program) => program.serialNumber == id).programName;
    } catch (e) {
      return "Program not found";
    }
  }

}
