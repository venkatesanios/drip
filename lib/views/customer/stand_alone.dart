import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_drip_irrigation/view_models/customer/stand_alone_view_model.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';

class StandAlone extends StatefulWidget {
  const StandAlone({super.key, required this.customerId, required this.siteId, required this.controllerId, required this.userId, required this.deviceId, required this.callbackFunction, required this.config});

  final int customerId, siteId, controllerId, userId;
  final String deviceId;
  final void Function(String msg) callbackFunction;
  final Config config;

  @override
  State<StandAlone> createState() => _StandAloneState();
}

class _StandAloneState extends State<StandAlone> with SingleTickerProviderStateMixin {

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StandAloneViewModel(Repository(HttpService()), widget.config, widget.userId, widget.customerId, widget.controllerId, widget.deviceId)
        ..getProgramList(),
      child: Consumer<StandAloneViewModel>(
        builder: (context, viewModel, _) {

          return Container(
            width: 400,
            height: MediaQuery.sizeOf(context).height,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  width: 400,
                  height: 90,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        viewModel.programList.length > 1? Row(
                          children: [
                            const Text(
                              'Select by:',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 200,
                              child: DropdownButtonFormField(
                                value: viewModel.programList.isNotEmpty
                                    ? viewModel.programList[viewModel.ddCurrentPosition]
                                    : null,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                ),
                                items: viewModel.programList.map((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(item.programName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  // Your callback method here
                                },
                              ),
                            ),
                          ],
                        ) :
                        Container(),
                        Row(
                          children: [
                            SizedBox(
                              width: 250,
                              child: viewModel.ddCurrentPosition!=0? SegmentedButton<SegmentWithFlow>(
                                segments: const <ButtonSegment<SegmentWithFlow>>[
                                  ButtonSegment<SegmentWithFlow>(
                                      value: SegmentWithFlow.manual,
                                      label: Text('Timeless'),
                                      icon: Icon(Icons.pan_tool_alt_outlined)),
                                  ButtonSegment<SegmentWithFlow>(
                                      value: SegmentWithFlow.duration,
                                      label: Text('Duration'),
                                      icon: Icon(Icons.timer_outlined)),
                                  ButtonSegment<SegmentWithFlow>(
                                      value: SegmentWithFlow.flow,
                                      label: Text('Flow-Liters'),
                                      icon: Icon(Icons.water_drop_outlined)),
                                ],
                                selected: <SegmentWithFlow>{viewModel.segmentWithFlow},
                                onSelectionChanged: (Set<SegmentWithFlow> newSelection) {
                                  viewModel.segmentWithFlow = newSelection.first;
                                  viewModel.segmentSelectionCallbackFunction(viewModel.segmentWithFlow.index, viewModel.durationValue, viewModel.selectedIrLine);
                                },
                              ) :
                              SegmentedButton<SegmentWithFlow>(
                                segments: const <ButtonSegment<SegmentWithFlow>>[
                                  ButtonSegment<SegmentWithFlow>(
                                      value: SegmentWithFlow.manual,
                                      label: Text('Timeless'),
                                      icon: Icon(Icons.pan_tool_alt_outlined)),
                                  ButtonSegment<SegmentWithFlow>(
                                      value: SegmentWithFlow.duration,
                                      label: Text('Duration'),
                                      icon: Icon(Icons.timer_outlined)),
                                ],
                                selected: <SegmentWithFlow>{viewModel.segmentWithFlow},
                                onSelectionChanged: (Set<SegmentWithFlow> newSelection) {
                                  viewModel.segmentWithFlow = newSelection.first;
                                  viewModel.segmentSelectionCallbackFunction(viewModel.segmentWithFlow.index, viewModel.durationValue, viewModel.selectedIrLine);
                                },
                              ),
                            ),
                            const SizedBox(width: 5,),
                            viewModel.segmentWithFlow.index == 1 ? SizedBox(
                              width: 85,
                              child: TextButton(
                                onPressed: () => viewModel.showDurationInputDialog(context),
                                style: ButtonStyle(
                                  padding: WidgetStateProperty.all(
                                    const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                  ),
                                  backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor.withOpacity(0.3)),
                                  shape: WidgetStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                                  ),
                                ),
                                child: Text(viewModel.durationValue, style: const TextStyle(color: Colors.black, fontSize: 17)),
                              ),
                            ) :
                            Container(),
                            viewModel.segmentWithFlow.index == 2 ? SizedBox(
                              width: 85,
                              child: TextField(
                                maxLength: 7,
                                controller: viewModel.flowLiter,
                                onChanged: (value) => viewModel.segmentSelectionCallbackFunction(viewModel.segmentWithFlow.index, value, viewModel.selectedIrLine),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Liters',
                                  counterText: '',
                                ),
                              ),
                            ):
                            Container(),
                          ],
                        )

                      ],
                    ),
                  ),
                ),
                const Divider(height: 0),
                Expanded(
                  child: SingleChildScrollView(
                    child: displayStandAloneDefault(widget.config, viewModel),
                  ),
                ),
                ListTile(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 10),
                      MaterialButton(
                        color: Colors.redAccent,
                        textColor: Colors.white,
                        onPressed:() => viewModel.stopAllManualOperation(),
                        child: const Text('Stop Manually'),
                      ),
                      const SizedBox(width: 16),
                      MaterialButton(
                        color: Colors.green,
                        textColor: Colors.white,
                        onPressed:() => viewModel.startManualOperation(context),
                        child: const Text('Start Manually'),
                      ),
                      const SizedBox(width: 15),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget displayStandAloneDefault(Config config, StandAloneViewModel vm){
    return Column(
      children: [
        config.pump.isNotEmpty ? Padding(
          padding: const EdgeInsets.only(left: 8, right: 5, top: 8),
          child: Column(
            children: [
              SizedBox(
                height: config.pump.length*40+48,
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0), // Adjust the value as needed
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50, // Background color (optional)
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            topRight: Radius.circular(5.0),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 10.0, top: 8.0, bottom: 8.0), // Adjust values as needed
                          child: Text(
                            'Source & Irrigation Pump',
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: config.pump.length*40,
                        child: DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 150,
                          dataRowHeight: 40.0,
                          headingRowHeight: 0,
                          headingRowColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor.withOpacity(0.05)),
                          columns: const [
                            DataColumn2(
                              label: Center(child: Text('', style: TextStyle(fontSize: 14),)),
                              fixedWidth: 35,
                            ),
                            DataColumn2(
                                label: Text('',  style: TextStyle(fontSize: 14),),
                                size: ColumnSize.M
                            ),
                            DataColumn2(
                              label: Center(
                                child: Text('', textAlign: TextAlign.right,),
                              ),
                              fixedWidth: 70,
                            ),
                          ],
                          rows: List<DataRow>.generate(config.pump.length, (index) => DataRow(cells: [
                            DataCell(Center(child: Image.asset('assets/png_images/dp_pump.png',width: 30, height: 30,))),
                            DataCell(Text(config.pump[index].name, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14))),
                            DataCell(Transform.scale(
                              scale: 0.7,
                              child: Tooltip(
                                message: config.pump[index].selected? 'Close' : 'Open',
                                child: Switch(
                                  hoverColor: Colors.pink.shade100,
                                  activeColor: Colors.teal,
                                  value: config.pump[index].selected,
                                  onChanged: (value) {
                                    setState(() {
                                      config.pump[index].selected = value;
                                    });
                                  },
                                ),
                              ),
                            )),
                          ])),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ):
        Container(),
        config.filterSite.isNotEmpty? Padding(
          padding: const EdgeInsets.only(left: 8, right: 5, top: 8),
          child: Column(
            children: config.filterSite.map((site) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  height: site.filters.length * 40 + 48,
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5.0),
                              topRight: Radius.circular(5.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 8.0, bottom: 8.0),
                            child: Text(
                              site.name,
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: site.filters.length * 40, // Adjust height based on number of filters
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 150,
                            dataRowHeight: 40.0,
                            headingRowHeight: 0,
                            headingRowColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).primaryColor.withOpacity(0.05),
                            ),
                            columns: const [
                              DataColumn2(
                                label: Center(child: Text('', style: TextStyle(fontSize: 14))),
                                fixedWidth: 35,
                              ),
                              DataColumn2(
                                label: Text('', style: TextStyle(fontSize: 14)),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: Center(child: Text('', textAlign: TextAlign.right)),
                                fixedWidth: 70,
                              ),
                            ],
                            rows: site.filters.map((filter) {
                              return DataRow(
                                cells: [
                                  DataCell(Center(
                                    child: Image.asset(
                                      'assets/png_images/filter.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  )),
                                  DataCell(Text(
                                    filter.name,
                                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                                  )),
                                  DataCell(Transform.scale(
                                    scale: 0.7,
                                    child: Tooltip(
                                      message: filter.selected ? 'Close' : 'Open',
                                      child: Switch(
                                        hoverColor: Colors.pink.shade100,
                                        activeColor: Colors.teal,
                                        value: filter.selected,
                                        onChanged: (value) {
                                          setState(() {
                                            filter.selected = value;
                                          });
                                        },
                                      ),
                                    ),
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ):
        Container(),
        config.fertilizerSite.isNotEmpty? Padding(
          padding: const EdgeInsets.only(left: 8, right: 5, top: 8),
          child: Column(
            children: config.fertilizerSite.map((site) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  height: (site.channel.length + site.agitator.length + site.boosterPump.length) * 40 + 48,
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5.0),
                              topRight: Radius.circular(5.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, top: 8.0, bottom: 8.0),
                            child: Text(
                              site.name,
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: site.channel.length * 40, // Adjust height based on number of filters
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 150,
                            dataRowHeight: 40.0,
                            headingRowHeight: 0,
                            headingRowColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).primaryColor.withOpacity(0.05),
                            ),
                            columns: const [
                              DataColumn2(
                                label: Center(child: Text('', style: TextStyle(fontSize: 14))),
                                fixedWidth: 35,
                              ),
                              DataColumn2(
                                label: Text('', style: TextStyle(fontSize: 14)),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: Center(child: Text('', textAlign: TextAlign.right)),
                                fixedWidth: 70,
                              ),
                            ],
                            rows: site.channel.map((channel) {
                              return DataRow(
                                cells: [
                                  DataCell(Center(
                                    child: Image.asset(
                                      'assets/png_images/fert_chanel.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  )),
                                  DataCell(Text(
                                    channel.name,
                                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                                  )),
                                  DataCell(Transform.scale(
                                    scale: 0.7,
                                    child: Tooltip(
                                      message: channel.selected ? 'Close' : 'Open',
                                      child: Switch(
                                        hoverColor: Colors.pink.shade100,
                                        activeColor: Colors.teal,
                                        value: channel.selected,
                                        onChanged: (value) {
                                          setState(() {
                                            channel.selected = value;
                                          });
                                        },
                                      ),
                                    ),
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          height: site.boosterPump.length * 40, // Adjust height based on number of filters
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 150,
                            dataRowHeight: 40.0,
                            headingRowHeight: 0,
                            headingRowColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).primaryColor.withOpacity(0.05),
                            ),
                            columns: const [
                              DataColumn2(
                                label: Center(child: Text('', style: TextStyle(fontSize: 14))),
                                fixedWidth: 35,
                              ),
                              DataColumn2(
                                label: Text('', style: TextStyle(fontSize: 14)),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: Center(child: Text('', textAlign: TextAlign.right)),
                                fixedWidth: 70,
                              ),
                            ],
                            rows: site.boosterPump.map((boosterPump) {
                              return DataRow(
                                cells: [
                                  DataCell(Center(
                                    child: Image.asset(
                                      'assets/png_images/booster_pump.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  )),
                                  DataCell(Text(
                                    boosterPump.name,
                                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                                  )),
                                  DataCell(Transform.scale(
                                    scale: 0.7,
                                    child: Tooltip(
                                      message: boosterPump.selected ? 'Close' : 'Open',
                                      child: Switch(
                                        hoverColor: Colors.pink.shade100,
                                        activeColor: Colors.teal,
                                        value: boosterPump.selected,
                                        onChanged: (value) {
                                          setState(() {
                                            boosterPump.selected = value;
                                          });
                                        },
                                      ),
                                    ),
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          height: site.agitator.length * 40, // Adjust height based on number of filters
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 150,
                            dataRowHeight: 40.0,
                            headingRowHeight: 0,
                            headingRowColor: WidgetStateProperty.all<Color>(
                              Theme.of(context).primaryColor.withOpacity(0.05),
                            ),
                            columns: const [
                              DataColumn2(
                                label: Center(child: Text('', style: TextStyle(fontSize: 14))),
                                fixedWidth: 35,
                              ),
                              DataColumn2(
                                label: Text('', style: TextStyle(fontSize: 14)),
                                size: ColumnSize.M,
                              ),
                              DataColumn2(
                                label: Center(child: Text('', textAlign: TextAlign.right)),
                                fixedWidth: 70,
                              ),
                            ],
                            rows: site.agitator.map((agitator) {
                              return DataRow(
                                cells: [
                                  DataCell(Center(
                                    child: Image.asset(
                                      'assets/png_images/agitator_gray.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  )),
                                  DataCell(Text(
                                    agitator.name,
                                    style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                                  )),
                                  DataCell(Transform.scale(
                                    scale: 0.7,
                                    child: Tooltip(
                                      message: agitator.selected ? 'Close' : 'Open',
                                      child: Switch(
                                        hoverColor: Colors.pink.shade100,
                                        activeColor: Colors.teal,
                                        value: agitator.selected,
                                        onChanged: (value) {
                                          setState(() {
                                            agitator.selected = value;
                                          });
                                        },
                                      ),
                                    ),
                                  )),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ):
        Container(),
        SizedBox(
          height: getTotalHeight(),
          child: ListView.builder(
            itemCount: widget.config.lineData.length,
            itemBuilder: (context, index) {
              IrrigationLineData line = widget.config.lineData[index];
              return Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5,),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, top: 10, right: 5),
                                child: Text(line.name, textAlign: TextAlign.left),
                              ),
                            ),

                            if (vm.ddCurrentPosition!=0)
                              VerticalDivider(color: Theme.of(context).primaryColor.withOpacity(0.1)),

                            if(vm.ddCurrentPosition!=0)
                              Center(
                                child: SizedBox(
                                  width: 60,
                                  child: Transform.scale(
                                    scale: 0.7,
                                    child: Switch(
                                      value: true,
                                      hoverColor: Colors.pink.shade100,
                                      activeColor: Colors.teal,
                                      onChanged: (value) {
                                        /* setState(() {
                                                      for (var line in widget.lineOrSequence) {
                                                        line.selected = false;
                                                      }
                                                      line.selected = value;
                                                    });*/
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: (line.valves.length * 40),
                        width: MediaQuery.sizeOf(context).width,
                        child:  DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 150,
                          dataRowHeight: 40.0,
                          headingRowHeight: 0,
                          headingRowColor: WidgetStateProperty.all<Color>(Theme.of(context).primaryColor.withOpacity(0.05)),
                          columns: const [
                            DataColumn2(
                                label: Center(child: Text('', style: TextStyle(fontSize: 14),)),
                                fixedWidth: 30
                            ),
                            DataColumn2(
                                label: Text('Name',  style: TextStyle(fontSize: 14),),
                                size: ColumnSize.M
                            ),
                            DataColumn2(
                              label: Center(
                                child: Text('Valve Status', textAlign: TextAlign.right,),
                              ),
                              fixedWidth: 70,
                            ),
                          ],
                          rows: List<DataRow>.generate(line.valves.length, (index) => DataRow(cells: [
                            DataCell(Center(child: Image.asset('assets/png_images/valve_gray.png',width: 25, height: 25,))),
                            DataCell(Text(line.valves[index].name, style: const TextStyle(fontWeight: FontWeight.normal))),
                            DataCell(Transform.scale(
                              scale: 0.7,
                              child: Tooltip(
                                message: line.valves[index].isOn? 'Close' : 'Open',
                                child: Switch(
                                  hoverColor: Colors.pink.shade100,
                                  activeColor: Colors.teal,
                                  value: line.valves[index].isOn,
                                  onChanged: (value) {
                                    setState(() {
                                      line.valves[index].isOn = value;
                                    });
                                  },
                                ),
                              ),
                            )),
                          ])),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  double getTotalHeight() {
    int totalValves = widget.config.lineData.fold(0, (sum, line) => sum + line.valves.length);
    return (totalValves * 40).toDouble()+60;
  }

}
