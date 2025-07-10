import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_drip_irrigation/view_models/customer/stand_alone_view_model.dart';
import 'package:provider/provider.dart';
import '../../Models/customer/site_model.dart';
import '../../Models/customer/stand_alone_model.dart';
import '../../repository/repository.dart';
import '../../services/http_service.dart';

class StandAlone extends StatefulWidget {
  const StandAlone({super.key, required this.customerId, required this.siteId, required this.controllerId, required this.userId, required this.deviceId, required this.callbackFunction, required this.masterData});

  final int customerId, siteId, controllerId, userId;
  final String deviceId;
  final void Function(String msg) callbackFunction;
  final MasterControllerModel masterData;

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
        create: (_) => StandAloneViewModel(Repository(HttpService()), widget.masterData, widget.userId, widget.customerId, widget.controllerId, widget.deviceId)
          ..getProgramList(),
        child: Consumer<StandAloneViewModel>(
          builder: (context, viewModel, _) {
            return kIsWeb? Container(
              width: 400,
              height: MediaQuery.sizeOf(context).height,
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    width: 400,
                    height: viewModel.ddCurrentPosition!=0 && viewModel.segmentWithFlow.index!=0 ? 133: viewModel.programList.length > 1? 90:60,
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
                                    viewModel.fetchStandAloneSelection(
                                      value!.serialNumber,
                                      viewModel.programList.indexOf(value),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ) :
                          const SizedBox(height: 8),
                          viewModel.ddCurrentPosition==0 ?Row(
                            children: [
                              SizedBox(
                                width: 275,
                                child: SegmentedButton<SegmentWithFlow>(
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
                          ):
                          Column(
                            children: [
                              SizedBox(
                                width: 350,
                                child: SegmentedButton<SegmentWithFlow>(
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
                                ),
                              ),
                              const SizedBox(height: 5),
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
                      child: displayLineOrSequence(widget.masterData, viewModel, viewModel.ddCurrentPosition),
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
                          onPressed:() => viewModel.stopAllManualOperation(context),
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
            ):
            Scaffold(
              appBar: AppBar(
                title: const Text('Manual'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      children: [
                        const Text('Select by :', style: TextStyle(color: Colors.white),),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 175,
                          child: DropdownButtonFormField(
                            dropdownColor: Theme.of(context).primaryColorLight,
                            value: viewModel.programList.isNotEmpty
                                ? viewModel.programList[viewModel.ddCurrentPosition]
                                : null,
                            items: viewModel.programList.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.programName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              viewModel.fetchStandAloneSelection(
                                value!.serialNumber,
                                viewModel.programList.indexOf(value),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: viewModel.ddCurrentPosition==0 ?
                  Expanded(child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: SegmentedButton<SegmentWithFlow>(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Theme.of(context).primaryColorLight; // Background when selected
                                }
                                return Colors.white; // Default background
                              },
                            ),
                            foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Colors.white; // Text/Icon color when selected
                                }
                                return Colors.black; // Text/Icon color by default
                              },
                            ),
                            overlayColor: WidgetStateProperty.all(Theme.of(context).primaryColorLight.withOpacity(0.1)), // Ripple effect
                            surfaceTintColor: WidgetStateProperty.all(Colors.white), // Background surface tint
                            side: WidgetStateProperty.all(BorderSide(color: Colors.grey.shade300)), // Border
                          ),
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
                      viewModel.segmentWithFlow.index == 1 ?
                      const SizedBox(width: 10):
                      const SizedBox(),
                      viewModel.segmentWithFlow.index == 1 ? SizedBox(
                        width: 100,
                        child: TextButton(
                          onPressed: () => viewModel.showDurationInputDialog(context),
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                            shape: WidgetStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                          child: Text(viewModel.durationValue, style: const TextStyle(color: Colors.black, fontSize: 17)),
                        ),
                      ):
                      const SizedBox(),
                      const SizedBox(width: 16),
                    ],
                  )):
                  Expanded(child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: SegmentedButton<SegmentWithFlow>(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                                  (Set<WidgetState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Theme.of(context).primaryColorLight; // Background when selected
                                }
                                return Colors.white; // Default background
                              },
                            ),
                            foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Colors.white; // Text/Icon color when selected
                                }
                                return Colors.black; // Text/Icon color by default
                              },
                            ),
                            overlayColor: MaterialStateProperty.all(Theme.of(context).primaryColorLight.withOpacity(0.1)), // Ripple effect
                            surfaceTintColor: MaterialStateProperty.all(Colors.white), // Background surface tint
                            side: MaterialStateProperty.all(BorderSide(color: Colors.grey.shade300)), // Border
                          ),
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
                                label: Text('Liters'),
                                icon: Icon(Icons.water_drop_outlined)),
                          ],
                          selected: <SegmentWithFlow>{viewModel.segmentWithFlow},
                          onSelectionChanged: (Set<SegmentWithFlow> newSelection) {
                            viewModel.segmentWithFlow = newSelection.first;
                            viewModel.segmentSelectionCallbackFunction(viewModel.segmentWithFlow.index, viewModel.durationValue, viewModel.selectedIrLine);
                          },
                        ),
                      ),
                      viewModel.segmentWithFlow.index == 1  || viewModel.segmentWithFlow.index == 2?
                      const SizedBox(width: 8):
                      const SizedBox(),
                      viewModel.segmentWithFlow.index == 1 ? SizedBox(
                        width: 85,
                        child: TextButton(
                          onPressed: () => viewModel.showDurationInputDialog(context),
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            ),
                            backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                            shape: WidgetStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                            ),
                          ),
                          child: Text(viewModel.durationValue, style: const TextStyle(color: Colors.black, fontSize: 17)),
                        ),
                      ):
                      const SizedBox(),
                      viewModel.segmentWithFlow.index == 2 ? Container(
                        width: 90,
                        height: 40,
                        color: Colors.white,
                        child: TextField(
                          maxLength: 7,
                          controller: viewModel.flowLiter,
                          onChanged: (value) => viewModel.segmentSelectionCallbackFunction(
                            viewModel.segmentWithFlow.index,
                            value,
                            viewModel.selectedIrLine,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.black), // Input text color
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Liters',
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ):
                      const SizedBox(),
                      const SizedBox(width: 8),
                    ],
                  )),
                ),
              ),
              body: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: displayLineOrSequence(widget.masterData, viewModel, viewModel.ddCurrentPosition),
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
                            onPressed:() => viewModel.stopAllManualOperation(context),
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
              ),
            );
          },
        ),
    );
  }

  Widget displayLineOrSequence(MasterControllerModel masterData, StandAloneViewModel vm, int ddPosition){

    final sourcePumps = masterData.irrigationLine
        .expand((line) => line.inletSources)
        .expand((ws) => ws.outletPump ?? [])
        .toList();

    final allSourcePumps = sourcePumps.fold<Map<double, PumpModel>>({}, (map, pump) {
      map[pump.sNo] = pump;
      return map;
    }).values.toList();

    final irrigationPumps = masterData.irrigationLine
        .expand((line) => line.outletSources)
        .expand((ws) => ws.outletPump ?? [])
        .toList();

    final allIrrigationPumps = irrigationPumps.fold<Map<double, PumpModel>>({}, (map, pump) {
      map[pump.sNo] = pump;
      return map;
    }).values.toList();

    final filterSites = masterData.irrigationLine
        .map((line) => line.centralFilterSite)
        .whereType<FilterSiteModel>()
        .toList();

    final fertilizerSite = masterData.irrigationLine
        .map((line) => line.centralFertilizerSite)
        .whereType<FertilizerSiteModel>()
        .toList();

    return Column(
      children: [
        if(vm.ddCurrentPosition==0)...[
          allSourcePumps.isNotEmpty ? Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
            child: Column(
              children: [
                SizedBox(
                  height: (allSourcePumps.length*40)+51,
                  child: Card(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5.0),
                              topRight: Radius.circular(5.0),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 10.0, top: 7),
                            child: Text(
                              'Source Pump',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: allSourcePumps.length*40,
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 150,
                            dataRowHeight: 40.0,
                            headingRowHeight: 0,
                            dataRowColor: WidgetStateProperty.all(Colors.white),
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
                                fixedWidth: 50,
                              ),
                            ],
                            rows: List<DataRow>.generate(allSourcePumps.length, (index) => DataRow(cells: [
                              DataCell(Center(child: Image.asset('assets/png/dp_pump.png',width: 30, height: 30,))),
                              DataCell(Text(allSourcePumps[index].name, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14))),
                              DataCell(Transform.scale(
                                scale: 0.7,
                                child: Tooltip(
                                  message: allSourcePumps[index].selected? 'Deselect' : 'Select',
                                  child: Switch(
                                    hoverColor: Colors.pink.shade100,
                                    activeColor: Colors.teal,
                                    value: allSourcePumps[index].selected,
                                    onChanged: (value) {
                                      setState(() {
                                        allSourcePumps[index].selected = value;
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
        ],

        allIrrigationPumps.isNotEmpty ? Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
          child: Column(
            children: [
              SizedBox(
                height: (allIrrigationPumps.length*40)+51,
                child: Card(
                  color: Colors.white,
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
                            'Irrigation Pump',
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: (allIrrigationPumps.length*40)+3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 3,bottom: 3, right: 3),
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 150,
                            dataRowHeight: 40.0,
                            headingRowHeight: 0,
                            dataRowColor: WidgetStateProperty.all(Colors.white),
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
                                fixedWidth: 50,
                              ),
                            ],
                            rows: List<DataRow>.generate(allIrrigationPumps.length, (index) => DataRow(cells: [
                              DataCell(Center(child: Image.asset('assets/png/dp_pump.png',width: 30, height: 30,))),
                              DataCell(Text(allIrrigationPumps[index].name, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14))),
                              DataCell(Transform.scale(
                                scale: 0.7,
                                child: Tooltip(
                                  message: allIrrigationPumps[index].selected? 'Deselect' : 'Select',
                                  child: Switch(
                                    hoverColor: Colors.pink.shade100,
                                    activeColor: Colors.teal,
                                    value: allIrrigationPumps[index].selected,
                                    onChanged: (value) {
                                      setState(() {
                                        allIrrigationPumps[index].selected = value;
                                      });
                                    },
                                  ),
                                ),
                              )),
                            ])),
                          ),
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

        filterSites.isNotEmpty? Padding(
          padding: const EdgeInsets.only(left: 8, right: 5, top: 8),
          child: Column(
            children: filterSites.map((site) {
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
                          height: site.filters.length * 40,
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 150,
                            dataRowHeight: 40.0,
                            headingRowHeight: 0,
                            dataRowColor: WidgetStateProperty.all(Colors.white),
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
                                fixedWidth: 50,
                              ),
                            ],
                            rows: site.filters.map((filter) {
                              return DataRow(
                                cells: [
                                  DataCell(Center(
                                    child: Image.asset(
                                      'assets/png/filter.png',
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

        fertilizerSite.isNotEmpty? Padding(
          padding: const EdgeInsets.only(left: 8, right: 5, top: 8),
          child: Column(
            children: fertilizerSite.map((site) {
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
                            dataRowColor: WidgetStateProperty.all(Colors.white),
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
                                fixedWidth: 50,
                              ),
                            ],
                            rows: site.channel.map((channel) {
                              return DataRow(
                                cells: [
                                  DataCell(Center(
                                    child: Image.asset(
                                      'assets/png/fert_chanel.png',
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
                            dataRowColor: WidgetStateProperty.all(Colors.white),
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
                                fixedWidth: 50,
                              ),
                            ],
                            rows: site.boosterPump.map((boosterPump) {
                              return DataRow(
                                cells: [
                                  DataCell(Center(
                                    child: Image.asset(
                                      'assets/png/booster_pump.png',
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
                            dataRowColor: WidgetStateProperty.all(Colors.white),
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
                                fixedWidth: 50,
                              ),
                            ],
                            rows: site.agitator.map((agitator) {
                              return DataRow(
                                cells: [
                                  DataCell(Center(
                                    child: Image.asset(
                                      'assets/png/agitator_gray.png',
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

        ddPosition == 0 ? Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(masterData.irrigationLine.length, (index) {
            IrrigationLineModel line = masterData.irrigationLine[index];
            if (line.name == 'All irrigation line') return const SizedBox();

            return Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 5),
              child: Card(
                color: Colors.white,
                elevation: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(5),
                          topLeft: Radius.circular(5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 5),
                              child: Text(line.name, textAlign: TextAlign.left),
                            ),
                          ),
                          if (vm.ddCurrentPosition != 0) ...[
                            VerticalDivider(color: Theme.of(context).primaryColor.withOpacity(0.1)),
                            Center(
                              child: SizedBox(
                                width: 60,
                                child: Transform.scale(
                                  scale: 0.7,
                                  child: Switch(
                                    value: true,
                                    activeColor: Theme.of(context).primaryColorLight,
                                    onChanged: (value) {},
                                  ),
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ((line.valveObjects.length + line.lightObjects.length + line.gateObjects.length) * 40) + 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 3, right: 3, bottom: 3),
                        child: DataTable2(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          minWidth: 150,
                          dataRowHeight: 40.0,
                          headingRowHeight: 0,
                          dataRowColor: WidgetStateProperty.all(Colors.white),
                          columns: const [
                            DataColumn2(label: Center(child: Text('')), fixedWidth: 30),
                            DataColumn2(label: Text('Name'), size: ColumnSize.M),
                            DataColumn2(
                              label: Center(child: Text('Status')),
                              fixedWidth: 50,
                            ),
                          ],
                          rows: [
                            ...line.valveObjects.map((valve) => DataRow(cells: [
                              DataCell(
                                Center(
                                  child: Image.asset(
                                    'assets/png/valve_gray.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                              ),
                              DataCell(Text(valve.name)),
                              DataCell(
                                Transform.scale(
                                  scale: 0.7,
                                  child: Tooltip(
                                    message: valve.isOn ? 'Close' : 'Open',
                                    child: Switch(
                                      hoverColor: Colors.pink.shade100,
                                      activeColor: Colors.teal,
                                      value: valve.isOn,
                                      onChanged: (value) {
                                        setState(() {
                                          valve.isOn = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ])),
                            ...line.lightObjects.map((light) => DataRow(cells: [
                              DataCell(
                                Center(
                                  child: Image.asset(
                                    'assets/png/light_gray.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                              ),
                              DataCell(Text(light.name)),
                              DataCell(
                                Transform.scale(
                                  scale: 0.7,
                                  child: Tooltip(
                                    message: light.isOn ? 'Turn Off' : 'Turn On',
                                    child: Switch(
                                      hoverColor: Colors.pink.shade100,
                                      activeColor: Colors.teal,
                                      value: light.isOn,
                                      onChanged: (value) {
                                        setState(() {
                                          light.isOn = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ])),
                            ...line.gateObjects.map((gate) => DataRow(cells: [
                              DataCell(
                                Center(
                                  child: Image.asset(
                                    'assets/png/gate_gray.png',
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                              ),
                              DataCell(Text(gate.name)),
                              DataCell(
                                Transform.scale(
                                  scale: 0.7,
                                  child: Tooltip(
                                    message: gate.isOn ? 'Turn Off' : 'Turn On',
                                    child: Switch(
                                      hoverColor: Colors.pink.shade100,
                                      activeColor: Colors.teal,
                                      value: gate.isOn,
                                      onChanged: (value) {
                                        setState(() {
                                          gate.isOn = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ])),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ):
        vm.standAloneData != null ?
        Column(
          children: List.generate(vm.standAloneData!.sequence.length, (index) {
            SequenceModel sequence = vm.standAloneData!.sequence[index];
            return Padding(
              padding: const EdgeInsets.only(left: 8, right: 5, bottom: 5),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(5), topLeft: Radius.circular(5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10, right: 5),
                              child: Text(sequence.name),
                            ),
                          ),
                          if (vm.ddCurrentPosition != 0) ...[
                            VerticalDivider(color: Theme.of(context).primaryColor.withOpacity(0.1)),
                            SizedBox(
                              width: 60,
                              child: Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: sequence.selected,
                                  hoverColor: Colors.pink.shade100,
                                  activeColor: Colors.teal,
                                  onChanged: (value) {
                                    setState(() {
                                      for (var sequence in vm.standAloneData!.sequence) {
                                        sequence.selected = false;
                                      }
                                      sequence.selected = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(
                      height: sequence.valve.length * 40,
                      width: double.infinity,
                      child: DataTable2(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        minWidth: 150,
                        dataRowHeight: 40,
                        headingRowHeight: 0,
                        dataRowColor: WidgetStateProperty.all(Colors.white),
                        columns: const [
                          DataColumn2(label: Center(child: Text('')), fixedWidth: 30),
                          DataColumn2(label: Center(child: Text('Name')), size: ColumnSize.M),
                        ],
                        rows: List<DataRow>.generate(sequence.valve.length, (index) {
                          return DataRow(cells: [
                            DataCell(Center(child: Image.asset('assets/png/valve_gray.png', width: 25, height: 25))),
                            DataCell(Text(sequence.valve[index].name)),
                          ]);
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ) :
        const SizedBox(),
      ],
    );
  }
}
