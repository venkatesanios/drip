import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/preview_screen.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/schedule_screen.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/selection_screen.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/sequence_screen.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/water_and_fertilizer_screen.dart';
import 'package:provider/provider.dart';
import '../state_management/irrigation_program_provider.dart';
import '../../../StateManagement/mqtt_payload_provider.dart';
import '../../../StateManagement/overall_use.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/custom_tab.dart';
import 'alarm_screen.dart';
import 'conditions_screen.dart';
import 'done_screen.dart';

class IrrigationProgram extends StatefulWidget {
  final int userId;
  final int customerId;
  final int groupId;
  final int categoryId;

  final int controllerId;
  final String deviceId;
  final int serialNumber;
  final String? programType;
  final bool? conditionsLibraryIsNotEmpty;
  final bool fromDealer;
  final bool toDashboard;
  final int modelId;
  final String deviceName;
  final String categoryName;
  const IrrigationProgram({Key? irrigationProgramKey,
    required this.userId,
    required this.controllerId,
    required this.serialNumber,
    this.programType,
    this.conditionsLibraryIsNotEmpty,
    required this.deviceId,
    required this.fromDealer, required this.groupId,
    required this.categoryId,
    this.toDashboard = false, required this.customerId,
    required this.modelId,
    required this.deviceName,
    required this.categoryName,
  }) :super(key: irrigationProgramKey);

  @override
  State<IrrigationProgram> createState() => _IrrigationProgramState();
}

class _IrrigationProgramState extends State<IrrigationProgram> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final IrrigationProgramMainProvider irrigationProvider = IrrigationProgramMainProvider();
  late MqttPayloadProvider mqttPayloadProvider;
  late OverAllUse overAllPvd;
  dynamic waterAndFertData = [];
  late List<String> labels;
  late List<IconData> icons;

  @override
  void initState() {
    super.initState();
    final irrigationProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context,listen: false);

    Tuple<List<String>, List<IconData>> result = irrigationProvider.getLabelAndIcon(sno: widget.serialNumber, programType: widget.programType, conditionLibrary: widget.conditionsLibraryIsNotEmpty);
    labels = result.labels;
    icons = result.icons;
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        irrigationProvider.updateTabIndex(0);
        irrigationProvider.getUserProgramSequence(userId: widget.customerId, controllerId: widget.controllerId, serialNumber: widget.serialNumber, groupId: widget.groupId, categoryId: widget.categoryId);
        irrigationProvider.scheduleData(widget.customerId, widget.controllerId, widget.serialNumber);
        irrigationProvider.getUserProgramCondition(widget.customerId, widget.controllerId, widget.serialNumber);
        irrigationProvider.getWaterAndFertData(userId: widget.customerId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
        irrigationProvider.getUserProgramSelection(widget.customerId, widget.controllerId, widget.serialNumber);
        irrigationProvider.doneData(widget.customerId, widget.controllerId, widget.serialNumber);
        irrigationProvider.getUserProgramAlarm(widget.customerId, widget.controllerId, widget.serialNumber);
      });
      _tabController = TabController(
        length: labels.length,
        vsync: this,
      );
      _tabController.addListener(() {
        irrigationProvider.updateTabIndex(_tabController.index);
      });
    }
  }

  Future<void> getProgramData() async{
    irrigationProvider.getUserProgramSequence(userId: widget.customerId, controllerId: widget.controllerId, serialNumber: widget.serialNumber, groupId: widget.groupId, categoryId: widget.categoryId);
    irrigationProvider.scheduleData(widget.customerId, widget.controllerId, widget.serialNumber);
    irrigationProvider.getUserProgramCondition(widget.customerId, widget.controllerId, widget.serialNumber);
    irrigationProvider.getWaterAndFertData(userId: widget.customerId, controllerId: widget.controllerId, serialNumber: widget.serialNumber);
    irrigationProvider.getUserProgramSelection(widget.customerId, widget.controllerId, widget.serialNumber);
    irrigationProvider.doneData(widget.customerId, widget.controllerId, widget.serialNumber);
    irrigationProvider.getUserProgramAlarm(widget.customerId, widget.controllerId, widget.serialNumber);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // irrigationProvider.clearDispose();
    super.dispose();
  }

  void _navigateToTab(int tabIndex) {
    if (_tabController.index != tabIndex) {
      _tabController.animateTo(tabIndex);
    }
  }

  void _navigateToNextTab() {
    _tabController.animateTo((_tabController.index + 1) % _tabController.length);
  }

  void _navigateToPreviousTab() {
    _tabController.animateTo((_tabController.index - 1 + _tabController.length) % _tabController.length);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context);
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    final irrigationProgram = ((mainProvider.programDetails?.programType == "Irrigation Program")
        || (mainProvider.selectedProgramType == "Irrigation Program"));
    int selectedIndex = mainProvider.selectedTabIndex;
    // print("irrigation program class");

    if(mainProvider.irrigationLine != null && mainProvider.programDetails != null) {
      final program = mainProvider.programDetails!.programName.isNotEmpty
          ? mainProvider.programName == ''? "Program ${mainProvider.programCount+1}" : mainProvider.programName
          : mainProvider.programDetails!.defaultProgramName;
      return LayoutBuilder(
        builder: (context, constraints
            ) {
          return DefaultTabController(
            length: labels.length,
            child: Scaffold(
              appBar: MediaQuery.of(context).size.width < 600
                  ? AppBar(
                // title: Text(mainProvider.programName != '' ? mainProvider.programName : 'New Program'),
                title: Text(widget.serialNumber == 0 ? "New Program" : program,),
                centerTitle: true,
                leading: IconButton(
                  onPressed: () {
                    mainProvider.programLibraryData(widget.customerId, widget.controllerId);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white,),
                ),
                bottom: constraints.maxWidth < 600
                    ?
                PreferredSize(
                  preferredSize: const Size.fromHeight(80.0),
                  child: TabBar(
                    controller: _tabController,
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    tabs: [
                      for (int i = 0; i <  labels.length; i++)
                        InkWell(
                          onTap: () {
                            if(_tabController.index == 0 && mainProvider.irrigationLine!.sequence.every((element) => element['valve'].isEmpty)) {
                              validatorFunction(context, mainProvider);
                            } else {
                              validateSelection(index: i, mainProvider: mainProvider);
                            }
                          },
                          child: CustomTab(
                            height: 80,
                            label: labels[i],
                            content: icons[i],
                            tabIndex: i,
                            selectedTabIndex: mainProvider.selectedTabIndex,
                          ),
                        ),
                    ],
                  ),
                ) : null,
              ) : PreferredSize(
                  preferredSize: const Size(0, 0),
                  child: Container()
              ),
              // backgroundColor: const Color(0xffF9FEFF),
              body: Row(
                children: <Widget>[
                  if (constraints.maxWidth > 500)
                    Container(
                      width: constraints.maxWidth * 0.15,
                     color: Theme.of(context).primaryColorDark,
                     /* decoration: BoxDecoration(
                          gradient: AppProperties.linearGradientLeading2
                      ),*/
                      child: ListView(
                        padding: const EdgeInsets.all(10),
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const BackButton(color: Colors.white,),
                                  const SizedBox(width: 10,),
                                  Expanded(
                                    child: Text(
                                      widget.serialNumber == 0 ? "New Program" : program,
                                      style: TextStyle(
                                          fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          for (int i = 0; i <  labels.length; i++)
                            Material(
                              type: MaterialType.transparency,
                              child: ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                  title: !(constraints
                                      .maxWidth > 500 && constraints
                                      .maxWidth <= 600)
                                      ? Text(labels[i], style: const TextStyle(color: Colors.white),) : null,
                                  leading: Icon(icons[i], color: Colors.white,),
                                  selected: _tabController.index == i,
                                  onTap: () {
                                    if(_tabController.index == 0 && mainProvider.irrigationLine!.sequence.every((element) => element['valve'].isEmpty)) {
                                      validatorFunction(context, mainProvider);
                                    } else {
                                      validateSelection(index: i, mainProvider: mainProvider);
                                    }
                                  },
                                /*  selectedTileColor: _tabController.index == i ? const Color(0xff2999A9) : null,
                                  hoverColor: _tabController.index == i ? const Color(0xff2999A9) : null*/
                                selectedTileColor: _tabController.index == i ? Theme.of(context).primaryColorLight : null,
                                hoverColor: _tabController.index == i ? Theme.of(context).primaryColorLight : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children:  [
                        for (int i = 0; i < labels.length; i++)
                          _buildTabContent(
                              index: i,
                              isIrrigationProgram: irrigationProgram,
                              conditionsLibraryIsNotEmpty: (widget.conditionsLibraryIsNotEmpty ?? false)
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(selectedIndex != 0)
                    buildActionButtonColored(
                        key: "prevPage",
                        icon: Icons.navigate_before,
                        label: "Back",
                        onPressed: () {
                          _navigateToPreviousTab();
                        },
                      context: context
                    ),
                  const SizedBox(width: 10,),
                  CircleAvatar(
                    // backgroundColor: Theme.of(context).primaryColor,
                    child: Text("${selectedIndex + 1}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          // color: Colors.white
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  if(selectedIndex != labels.length-1)
                    buildActionButtonColored(
                        key: "nextPage",
                        icon: Icons.navigate_next,
                        label: "Next",
                        context: context,
                        onPressed: () {
                          if(_tabController.index == 0 && mainProvider.irrigationLine!.sequence.every((element) => element['valve'].isEmpty)) {
                            validatorFunction(context, mainProvider);
                          } else {
                            validateSelection2();
                          }
                        }
                    ),
                ],
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            ),
          );
        },
      );
    } else {
      return const Scaffold(body: Center(child: CircularProgressIndicator(),),);
    }
  }

  void validateSelection({required int index, required IrrigationProgramMainProvider mainProvider}) {
    if(widget.programType == "Irrigation Program") {
      if(labels.length == 7 ? index > 2 : index > 3){
        if(!mainProvider.selectedObjects!.any((element) => element.objectId == 2)) {
          showValidationAlert(content: "Please select at least one head unit!");
        } else if(!(mainProvider.isPumpStationMode) && mainProvider.pump!.isNotEmpty && !mainProvider.selectedObjects!.any((element) => element.objectId == 5)){

          if(!mainProvider.ignoreValidation) {
            showValidationAlert(
                content: "Are you sure to proceed without pump selection?",
                ignoreValidation: mainProvider.pump!.length > 1,
              index: index
            );
          } else {
            _navigateToTab(index);
          }

        } else if(mainProvider.isPumpStationMode) {
          mainProvider.calculateTotalFlowRate();
          if(mainProvider.pumpStationValveFlowRate < mainProvider.totalValveFlowRate) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red,),
                        Text("Warning!", style: TextStyle(color: Colors.red),)
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Pump station range is not sufficient for total zone's valve flow rate!", style: TextStyle(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Pump station range', style: TextStyle(color: Colors.black)),
                            const SizedBox(width: 20,),
                            Text('${mainProvider.pumpStationValveFlowRate} L/hr', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total zone valve flow rate', style: TextStyle(color: Colors.black)),
                            const SizedBox(width: 20,),
                            Text('${mainProvider.totalValveFlowRate} L/hr', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("OK")
                      )
                    ],
                  );
                }
            );
          } else {
            _navigateToTab(index);
          }
        } else {
          _navigateToTab(index);
        }
      } else{
        _navigateToTab(index);
      }
    } else {
      _navigateToTab(index);
    }
  }

  void validateSelection2() {
    final mainProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    if(widget.programType == "Irrigation Program") {
      if(labels.length == 7 ? _tabController.index == 2 : _tabController.index == 3){
        if(!mainProvider.selectedObjects!.any((element) => element.objectId == 2)) {
          showValidationAlert(content: "Please select at least one head unit!");
        } else if(!(mainProvider.isPumpStationMode) && mainProvider.pump!.isNotEmpty && !mainProvider.selectedObjects!.any((element) => element.objectId == 5)){
          if(!mainProvider.ignoreValidation) {
            showValidationAlert(
                content: "Are you sure to proceed without pump selection?",
                ignoreValidation: mainProvider.pump!.length > 1,
                index: _tabController.index + 1
            );
          } else {
            _navigateToNextTab();
          }
        } else if(mainProvider.isPumpStationMode) {
          mainProvider.calculateTotalFlowRate();
          if(mainProvider.pumpStationValveFlowRate <= mainProvider.totalValveFlowRate) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red,),
                        Text("Warning!", style: TextStyle(color: Colors.red),)
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Pump station range is not sufficient for total zone's valve flow rate!", style: TextStyle(fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Pump station range', style: TextStyle(color: Colors.black)),
                            const SizedBox(width: 20,),
                            Text('${mainProvider.pumpStationValveFlowRate} L/hr', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total zone valve flow rate', style: TextStyle(color: Colors.black)),
                            const SizedBox(width: 20,),
                            Text('${mainProvider.totalValveFlowRate} L/hr', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("OK")
                      )
                    ],
                  );
                }
            );
          } else {
            _navigateToNextTab();
          }
        }
        else {
          _navigateToNextTab();
        }
      } else{
        _navigateToNextTab();
      }
    } else {
      _navigateToNextTab();
    }
  }

  void showValidationAlert({required String content, bool ignoreValidation = false, int? index}) {
    showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
              title: "Warning",
              content: content,
              actions: [
                TextButton(
                    onPressed: () {
                      if(!ignoreValidation) {
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          context.read<IrrigationProgramMainProvider>().ignoreValidation = true;
                        });
                        print("index : ${index}");
                        _navigateToTab(index!);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(ignoreValidation ? "Yes" : "OK")
                ),
                if(ignoreValidation)
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("No", style: TextStyle(color: Colors.red),)
                  )
              ]
          );
        }
    );
  }

  void validatorFunction(BuildContext context, IrrigationProgramMainProvider mainProvider) {
    if(mainProvider.irrigationLine!.sequence.every((element) => element['valve'].isEmpty)) {
      final indexWhereEmpty = mainProvider.irrigationLine!.sequence.indexWhere((element) => element['valve'].isEmpty);
      showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // title: Text('Verify to delete'),
            content: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(text: 'The sequence is empty at ', style: TextStyle(color: Colors.black)),
                  TextSpan(text: '${mainProvider.irrigationLine!.sequence[indexWhereEmpty]['name']}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    // if(mainProvider.irrigationLine!.sequence.every((element) => element['valve'].isNotEmpty)) {
    //   _showAdaptiveDialog(context, mainProvider);
    // } else {
    //   final indexWhereEmpty = mainProvider.irrigationLine!.sequence.indexWhere((element) => element['valve'].isEmpty);
    //   showAdaptiveDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         // title: Text('Verify to delete'),
    //         content: RichText(
    //           text: TextSpan(
    //             children: [
    //               const TextSpan(text: 'The sequence is empty at ',),
    //               TextSpan(text: '${mainProvider.irrigationLine!.sequence[indexWhereEmpty]['name']}',
    //                 style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
    //             ],
    //           ),
    //         ),
    //         actions: [
    //           TextButton(
    //             child: const Text("OK"),
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
    // }
  }

  Widget _buildTabContent({required int index, required bool isIrrigationProgram, required bool conditionsLibraryIsNotEmpty}) {
    switch (index) {
      case 0:
        return SequenceScreen(userId: widget.customerId, controllerId: widget.controllerId, serialNumber: widget.serialNumber, deviceId: widget.deviceId,);
      case 1:
        return ScheduleScreen(serialNumber: widget.serialNumber, modelId: widget.modelId,);
      case 2:
        return isIrrigationProgram
            ? conditionsLibraryIsNotEmpty
            ? ConditionsScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber, deviceId: widget.deviceId, customerId: widget.customerId,)
            : SelectionScreen(modelId: widget.modelId,)
            : WaterAndFertilizerScreen(userId: widget.userId, controllerId: widget.controllerId, serialNumber: widget.serialNumber, isIrrigationProgram: isIrrigationProgram, modelId: widget.modelId,);
      case 3:
        return isIrrigationProgram
            ? conditionsLibraryIsNotEmpty
            ? SelectionScreen(modelId: widget.modelId,)
            : WaterAndFertilizerScreen(userId: widget.customerId, controllerId: widget.controllerId, serialNumber: widget.serialNumber, isIrrigationProgram: isIrrigationProgram, modelId: widget.modelId,)
            : AlarmScreen(modelId: widget.modelId,);
      case 4:
        return isIrrigationProgram
            ? conditionsLibraryIsNotEmpty
            ? WaterAndFertilizerScreen(userId: widget.customerId, controllerId: widget.controllerId, serialNumber: widget.serialNumber, isIrrigationProgram: isIrrigationProgram, modelId: widget.modelId,)
            : AlarmScreen(modelId: widget.modelId,)
            : AdditionalDataScreen(
            userId: widget.userId, controllerId: widget.controllerId, deviceId: widget.deviceId,
            serialNumber: widget.serialNumber, toDashboard: widget.toDashboard, fromDealer: widget.fromDealer,
            programType: widget.programType, conditionsLibraryIsNotEmpty: widget.conditionsLibraryIsNotEmpty,
            isIrrigationProgram: isIrrigationProgram, customerId: widget.customerId, groupId: widget.groupId, categoryId: widget.categoryId, modelId: widget.modelId, deviceName: widget.deviceName, categoryName: widget.categoryName,);
      case 5:
        return isIrrigationProgram
            ? conditionsLibraryIsNotEmpty
            ? AlarmScreen(modelId: widget.modelId,)
            : AdditionalDataScreen(
          userId: widget.userId, controllerId: widget.controllerId, deviceId: widget.deviceId,
          serialNumber: widget.serialNumber, toDashboard: widget.toDashboard, fromDealer: widget.fromDealer,
          programType: widget.programType, conditionsLibraryIsNotEmpty: widget.conditionsLibraryIsNotEmpty,
          isIrrigationProgram: isIrrigationProgram, customerId: widget.customerId, groupId: widget.groupId, categoryId: widget.categoryId,modelId: widget.modelId, deviceName: widget.deviceName, categoryName: widget.categoryName)
            : PreviewScreen(userId: widget.userId, controllerId: widget.controllerId, deviceId: widget.deviceId, serialNumber: widget.serialNumber, toDashboard: widget.toDashboard, fromDealer: widget.fromDealer, programType: widget.programType, conditionsLibraryIsNotEmpty: widget.conditionsLibraryIsNotEmpty,customerId: widget.customerId, groupId: widget.groupId, categoryId: widget.categoryId,modelId: widget.modelId, deviceName: widget.deviceName, categoryName: widget.categoryName,);
      case 6:
        return conditionsLibraryIsNotEmpty
            ? AdditionalDataScreen(
          userId: widget.userId, controllerId: widget.controllerId, deviceId: widget.deviceId,
          serialNumber: widget.serialNumber, toDashboard: widget.toDashboard, fromDealer: widget.fromDealer,
          programType: widget.programType, conditionsLibraryIsNotEmpty: widget.conditionsLibraryIsNotEmpty,
          isIrrigationProgram: isIrrigationProgram, customerId: widget.customerId, groupId: widget.groupId, categoryId: widget.categoryId,modelId: widget.modelId, deviceName: widget.deviceName, categoryName: widget.categoryName)
            : PreviewScreen(userId: widget.userId, controllerId: widget.controllerId, deviceId: widget.deviceId, serialNumber: widget.serialNumber, toDashboard: widget.toDashboard, fromDealer: widget.fromDealer, programType: widget.programType, conditionsLibraryIsNotEmpty: widget.conditionsLibraryIsNotEmpty, customerId: widget.customerId, groupId: widget.groupId, categoryId: widget.categoryId,modelId: widget.modelId, deviceName: widget.deviceName, categoryName: widget.categoryName);
      case 7:
        return conditionsLibraryIsNotEmpty
            ? PreviewScreen(userId: widget.userId, controllerId: widget.controllerId, deviceId: widget.deviceId, serialNumber: widget.serialNumber, toDashboard: widget.toDashboard, fromDealer: widget.fromDealer, programType: widget.programType, conditionsLibraryIsNotEmpty: widget.conditionsLibraryIsNotEmpty,customerId: widget.customerId, groupId: widget.groupId, categoryId: widget.categoryId,modelId: widget.modelId, deviceName: widget.deviceName, categoryName: widget.categoryName)
            : Container();
      default:
        return Container();
    }
  }
}

Widget buildActionButtonColored({required String key, required IconData icon, required String label, required VoidCallback onPressed, required BuildContext context}) {
  return MaterialButton(
    key: Key(key),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25)
    ),
    color: Theme.of(context).primaryColor,
    onPressed: onPressed,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Icon(icon, color: Colors.white,),
    ),
  );
}

Widget buildCustomSideMenuBar(
    {required BuildContext context, required String title, required BoxConstraints constraints, required List<Widget> children, Widget? bottomChild}) {
  return Container(
    // width: constraints
    // .maxWidth * 0.15,
    decoration: BoxDecoration(
        gradient: AppProperties.linearGradientLeading
    ),
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const BackButton(color: Colors.white,),
                    const SizedBox(width: 10,),
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
              ...children
            ],
          ),
          bottomChild ?? Container()
        ],
      ),
    ),
  );
}