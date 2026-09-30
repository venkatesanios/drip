import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import '../../../../StateManagement/mqtt_payload_provider.dart';
import '../../../../models/customer/site_model.dart';
import '../../../../modules/IrrigationProgram/view/program_library.dart';
import '../../../../providers/user_provider.dart';
import '../../../../repository/repository.dart';
import '../../../../services/communication_service.dart';
import '../../../../services/http_service.dart';
import '../../../../utils/formatters.dart';
import '../../../../utils/helpers/program_code_helper.dart';
import '../../../../utils/my_function.dart';
import '../../../../utils/snack_bar.dart';
import '../../../../view_models/customer/node_list_view_model.dart';
import '../../../../view_models/customer/current_program_view_model.dart'; // adjust path to your actual file
import 'package:oro_drip_irrigation/utils/Theme/agritel_theme.dart';


/// ---------------------------------------------------------------------
/// Design tokens
/// ---------------------------------------------------------------------
class _Tone {
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF7F8FA);
  static const Color surfaceMutedBg = Color(0xFFDAF3BC);
  static const Color border = Color(0xFFE4E6EA);
  static const Color subBorder = Color(0xFFC5C6CA);
  static const Color textPrimary = Color(0xFF1A1D21);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color statusDefault = Color(0xFF9B9D9F);
  static const Color statusRunning = Colors.green;
  static const Color statusRunningBg = Color(0xFFEAF3DE);
  static const Color statusCompleted = Color(0xFF378ADD);
  static const Color statusCompletedBg = Color(0xFFE6F1FB);
  static const Color statusPending = Color(0xFFEF9F27);
  static const Color statusPendingBg = Color(0xFFFAEEDA);
  static const Color statusNotOpen = Color(0xFFD85A30);
  static const Color statusNotOpenBg = Color(0xFFFAECE7);
  static const Color statusNotClosed = Color(0xFFE24B4A);
  static const Color statusNotClosedBg = Color(0xFFFCEBEB);
}

enum ValveDisplayStatus { idle, running, completed, pending, notOpen, notClosed }

class _ValveStatusStyle {
  final Color dot;
  final Color bg;
  final Color fg;
  final String label;
  const _ValveStatusStyle(this.dot, this.bg, this.fg, this.label);
}

_ValveStatusStyle _styleFor(ValveDisplayStatus s) {
  switch (s) {
    case ValveDisplayStatus.running:
      return const _ValveStatusStyle(_Tone.statusRunning, _Tone.statusRunningBg, _Tone.statusRunning, 'Running');
    case ValveDisplayStatus.completed:
      return const _ValveStatusStyle(_Tone.statusCompleted, _Tone.statusCompletedBg, _Tone.statusCompleted, 'Completed');
    case ValveDisplayStatus.pending:
      return const _ValveStatusStyle(_Tone.statusPending, _Tone.statusPendingBg, _Tone.statusPending, 'Pending');
    case ValveDisplayStatus.notOpen:
      return const _ValveStatusStyle(_Tone.statusNotOpen, _Tone.statusNotOpenBg, _Tone.statusNotOpen, 'Not open');
    case ValveDisplayStatus.notClosed:
      return const _ValveStatusStyle(_Tone.statusNotClosed, _Tone.statusNotClosedBg, _Tone.statusNotClosed, 'Not closed');
    case ValveDisplayStatus.idle:
      return const _ValveStatusStyle(_Tone.statusDefault, _Tone.surfaceMuted, _Tone.textSecondary, 'Idle');
  }
}

ValveDisplayStatus _displayStatusFor(int status, int completePercent) {
  if (status == 0 && completePercent == 0) return ValveDisplayStatus.idle;
  if (status == 0 && completePercent == 100) return ValveDisplayStatus.completed;
  if (status == 1) return ValveDisplayStatus.running;
  if (status == 0 && completePercent > 0 && completePercent < 100) return ValveDisplayStatus.pending;
  if (status == 2) return ValveDisplayStatus.notOpen;
  return ValveDisplayStatus.notClosed;
}

/// ---------------------------------------------------------------------
/// Duration lookup — reads CurrentProgramViewModel.currentSchedule and
/// finds the row matching a given valve's sNo (values[0]).
///
/// Schedule row shape (comma-separated), per the existing
/// updateDurationQtyLeft logic:
///   values[0]  -> valve sNo
///   values[4]  -> live countdown, either "HH:MM:SS" (time-based) or a
///                 numeric remaining-quantity string (flow-based), ticked
///                 down once per second by the view model's Timer
///   values[16] -> flow rate (only used internally for the flow countdown)
///   values[17] -> '1' if this row is actively counting down, else
///                 ignored by updateDurationQtyLeft
///
/// Returns null if no schedule row matches this valve (i.e. nothing
/// currently running/scheduled for it).
/// ---------------------------------------------------------------------
class _ValveDuration {
  final bool isTimeBased;
  final String display; // "00:04:32" or "12.50 l" depending on mode
  final bool isActive;
  const _ValveDuration({required this.isTimeBased, required this.display, required this.isActive});
}

_ValveDuration? _durationForValve(List<String> currentSchedule, String nodeSNo) {

  for (final row in currentSchedule) {
    final values = row.split(',');
    if (values.isEmpty) continue;

    // OMS format: values[0] = NodeS_No (valve identifier)
    if (values.length <= 11) continue;

    // Check if this row matches the extracted node SNo
    final scheduleNodeSNo = values[0].trim();
    if (scheduleNodeSNo != nodeSNo) continue;

    //print("Found matching node: $scheduleNodeSNo, values: $values");

    // Check if the program is running (status = 1)
    final programStatus = int.tryParse(values[4].trim()) ?? 0;
    if (programStatus != 1) continue;

    final isTimeBased = values[3].trim() == '1';

    if (isTimeBased) {
      final remTime = values[5].trim();
      if (remTime.isNotEmpty && remTime != '00:00:00') {
        return _ValveDuration(
          isTimeBased: true,
          display: remTime,
          isActive: true,
        );
      }
    } else {
      // Flow-based irrigation
      final remFlow = values[7].trim();
      if (remFlow.isNotEmpty && double.tryParse(remFlow) != null) {
        final flowValue = double.parse(remFlow);
        if (flowValue > 0) {
          return _ValveDuration(
            isTimeBased: false,
            display: '${flowValue.toStringAsFixed(2)} L',
            isActive: true,
          );
        }
      }
    }
  }
  //print("No matching running node found for: $nodeSNo");
  return null;
}

class OmsLine extends StatefulWidget {
  final MasterControllerModel master;
  final int customerId, controllerId, modelId, groupId;
  final String deviceId;

  const OmsLine({
    super.key,
    required this.customerId,
    required this.controllerId,
    required this.modelId,
    required this.deviceId,
    required this.master,
    required this.groupId,
  });

  @override
  State<OmsLine> createState() => _OmsLineState();
}

class _OmsLineState extends State<OmsLine> {
  final Map<int, Set<int>> nodeValveSelections = {};
  final Set<int> expandedNodes = {};
  String searchQuery = '';

  Set<int> fullySelectedNodeIndices(NodeListViewModel vm) {
    return nodeValveSelections.entries
        .where((e) => e.value.isNotEmpty)
        .where((e) => _isNodeFullySelected(vm, e.key, e.value))
        .map((e) => e.key)
        .toSet();
  }

  bool get hasAnyValveSelected {
    return nodeValveSelections.values.any((valves) => valves.isNotEmpty);
  }

  int get selectedValveCount {
    return nodeValveSelections.values.fold(0, (sum, s) => sum + s.length);
  }

  bool _isNodeFullySelected(NodeListViewModel vm, int nodeIndex, Set<int> selectedValveIdx) {
    final node = vm.nodeList[nodeIndex];
    final totalValves = node.rlyStatus.where((rly) {
      final sNo = rly.sNo.toString();
      return sNo.startsWith('13.') || sNo.startsWith('45.');
    }).length;
    return totalValves > 0 && selectedValveIdx.length == totalValves;
  }

  void _onValveSelectionChanged(int nodeIndex, Set<int> selectedValveIdx) {
    setState(() {
      if (selectedValveIdx.isEmpty) {
        nodeValveSelections.remove(nodeIndex);
      } else {
        nodeValveSelections[nodeIndex] = selectedValveIdx;
      }
    });
  }

  void _toggleExpanded(int nodeIndex) {
    setState(() {
      if (expandedNodes.contains(nodeIndex)) {
        expandedNodes.remove(nodeIndex);
      } else {
        expandedNodes.add(nodeIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NodeListViewModel(context, Repository(HttpService()), widget.master.nodeList),
      child: nodeListBody(context),
    );
  }

  Widget nodeListBody(BuildContext context) {
    // Consumer3 adds CurrentProgramViewModel so duration data is live
    // alongside node + mqtt state. CurrentProgramViewModel is assumed to
    // already be provided above this widget in the tree, per your setup.
    return Consumer3<NodeListViewModel, MqttPayloadProvider, CurrentProgramViewModel>(
      builder: (context, vm, mqttProvider, programVm, _) {
        final nodeLiveMessage = mqttProvider.nodeLiveMessage;
        final outputOnOffPayload = mqttProvider.outputOnOffPayload;
        final currentSchedule = mqttProvider.currentSchedule;

        // Add a condition to update only when data changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (vm.shouldUpdate(nodeLiveMessage, outputOnOffPayload)) {
            vm.onLivePayloadReceived(
              List.from(nodeLiveMessage),
              List.from(outputOnOffPayload),
              true,
            );
          }
        });

        if (currentSchedule.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            programVm.updateSchedule(currentSchedule, true);
          });
        }

        final filteredIndices = _filteredNodeIndices(vm);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: _buildTopHeader(vm, widget.master, widget.controllerId,
                  widget.deviceId, widget.customerId, widget.groupId),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  color: _Tone.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _Tone.subBorder, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: filteredIndices.length + 1,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: _Tone.border),
                    itemBuilder: (context, i) {
                      if (i == 0) return _buildTableHeaderRow();
                      final nodeIndex = filteredIndices[i - 1];
                      return _buildNodeRow(vm, programVm, nodeIndex);
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<int> _filteredNodeIndices(NodeListViewModel vm) {
    if (searchQuery.trim().isEmpty) {
      return List.generate(vm.nodeList.length, (i) => i);
    }
    final q = searchQuery.toLowerCase();
    final indices = <int>[];
    for (var i = 0; i < vm.nodeList.length; i++) {
      final node = vm.nodeList[i];
      if (node.deviceName.toLowerCase().contains(q) || node.deviceId.toLowerCase().contains(q)) {
        indices.add(i);
      }
    }
    return indices;
  }

  Widget _buildSearchBar() {
    return SearchBar(
      constraints: const BoxConstraints(minHeight: 42),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
      hintText: "Search by Zone, Node ID...",
      hintStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
      textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
      leading: Icon(Icons.search_rounded, color: primary, size: 20),
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.all(Colors.white),
      side: WidgetStateProperty.all(const BorderSide(color: _Tone.border, width: 1)),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      onChanged: (value) => setState(() => searchQuery = value),
    );
  }

  Widget _buildTableHeaderRow() {
    const headerStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _Tone.textSecondary);
    return Container(
      color: _Tone.surfaceMuted,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: const Row(
        children: [
          SizedBox(width: 28),
          SizedBox(width: 42),
          SizedBox(width: 150, child: Text('Node', style: headerStyle)),
          Expanded(flex: 3, child: Text('Zone/Place Name', style: headerStyle)),
          SizedBox(width: 100, child: Text('Battery', style: headerStyle)),
          SizedBox(width: 100, child: Text('Solar', style: headerStyle)),
          Expanded(flex: 3, child: Text('Valves', style: headerStyle)),
          Expanded(flex: 2, child: Text('Running', style: headerStyle)),
          SizedBox(width: 120),
        ],
      ),
    );
  }

  Widget _buildNodeRow(NodeListViewModel vm, CurrentProgramViewModel programVm, int index) {
    final node = vm.nodeList[index];

    final sensors = node.rlyStatus.where((rly) {
      final sNo = rly.sNo.toString();
      return sNo.startsWith('22.') || sNo.startsWith('24.')  || sNo.startsWith('46.');
    }).toList();

    final selectedValves = nodeValveSelections[index] ?? <int>{};

    final valves = node.rlyStatus.where((rly) {
      final sNo = rly.sNo.toString();
      return sNo.startsWith('45.') || sNo.startsWith('13.');
    }).toList();

    valves.sort((a, b) {
      final aSNo = a.sNo.toString();
      final bSNo = b.sNo.toString();
      final aIsFlowControl = aSNo.startsWith('45.');
      final bIsFlowControl = bSNo.startsWith('45.');
      if (aIsFlowControl && !bIsFlowControl) return -1;
      if (!aIsFlowControl && bIsFlowControl) return 1;
      return aSNo.compareTo(bSNo);
    });

    final isNodeFullySelected = selectedValves.length == valves.length && valves.isNotEmpty;
    final isExpanded = expandedNodes.contains(index);


    return Column(
      children: [
        InkWell(
          onTap: () => _toggleExpanded(index),
          child: Container(
            color: isNodeFullySelected ? primary.withValues(alpha: 0.04) : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: const Icon(Icons.chevron_right, size: 18, color: _Tone.textMuted),
                  ),
                ),
                SizedBox(
                  width: 28,
                  child: Checkbox(
                    value: isNodeFullySelected,
                    onChanged: (_) => _toggleNodeSelection(vm, index),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.deviceId,
                        style: const TextStyle(fontSize: 11, color: _Tone.textPrimary, fontFamily: 'monospace'),
                      ),
                      Text(
                        Formatters().formatDateDMY(node.lastFeedbackReceivedTime),
                        style: const TextStyle(fontSize: 10, color: _Tone.textMuted, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    node.deviceName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _Tone.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: _MetricChip(
                    label: '${node.batVolt} V',
                    warn: (double.tryParse(node.batVolt.toString()) ?? 0) <= 10,
                  ),
                ),
                SizedBox(width: 100, child: _MetricChip(label: '${node.sVolt} V',
                    warn: (double.tryParse(node.sVolt.toString()) ?? 0) <= 10)),
                Expanded(flex: 3, child: _ValveDotRow(valves: valves)),
                Expanded(flex: 2, child: _RunningSummary(valves: valves, programVm: programVm, nodeSNo: node.serialNumber,)),
                SizedBox(
                  width: 70,
                  child: OutlinedButton(
                    onPressed: () => _toggleExpanded(index),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: const BorderSide(color: _Tone.subBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Details', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: OutlinedButton(
                    onPressed: () => showEditProductDialog(context, node, widget.customerId),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: const BorderSide(color: _Tone.subBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Edit', style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          child: isExpanded ? _NodeDetailPanel(
            nodeSNo: node.serialNumber,
            sensors: sensors,
            valves: valves,
            selectedValveIdx: selectedValves,
            programVm: programVm,
            onValveTap: (valveIndex) {
              final updated = Set<int>.from(selectedValves);
              if (updated.contains(valveIndex)) {
                updated.remove(valveIndex);
              } else {
                updated.add(valveIndex);
              }
              _onValveSelectionChanged(index, updated);
            },
            sensorWidgetBuilder: sensorWidget,
          ) : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTopHeader(NodeListViewModel vm, MasterControllerModel cMaster,
      int controllerId, String deviceId, int customerId, int groupId) {
    final anyValveSelected = hasAnyValveSelected;
    final totalNodes = vm.nodeList.length;
    final valveCount = selectedValveCount;

    final programList = cMaster.programList ?? [];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _Tone.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Tone.subBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              valveCount > 0
                  ? '$valveCount valve${valveCount == 1 ? '' : 's'} selected · $totalNodes nodes total'
                  : '$totalNodes nodes available',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valveCount > 0 ? _Tone.textPrimary : _Tone.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: SizedBox(width: 250, child: _buildSearchBar()),
          ),
          Row(
            children: [
              _buildActionButton(
                label: 'Open',
                icon: Icons.play_arrow,
                onPressed: anyValveSelected ? () => _onStartAll(vm) : null,
                color: _Tone.statusRunning,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                label: 'Close',
                icon: Icons.stop,
                onPressed: anyValveSelected ? () => _onStopAll(vm) : null,
                color: _Tone.statusNotClosed,
              ),
              const SizedBox(width: 8),

              Builder(
                builder: (buttonContext) {
                  return OutlinedButton.icon(
                    onPressed: () {
                      showPopover(
                        context: buttonContext,
                        bodyBuilder: (context) => Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: programList.length,
                            itemBuilder: (context, index) {

                              final program = programList[index];

                              return ListTile(
                                dense: true,
                                leading: Text('${index+1}'),
                                title: Text(program.programName),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final commService = context.read<CommunicationService>();
                                        try {
                                          final payLoadFinal = jsonEncode({
                                            "8400": {"8401": '${program.serialNumber},0'},
                                          });

                                          await Future.delayed(const Duration(milliseconds: 100));

                                          await commService.sendCommand(
                                            serverMsg: '${program.programName} ${ProgramCodeHelper.getDescription(0)}',
                                            payload: payLoadFinal,
                                          );

                                          if (!mounted) return;
                                          GlobalSnackBar.show(context, 'Program stopped successfully', 200);
                                          Navigator.pop(context);

                                        } catch (e) {
                                          GlobalSnackBar.show(context, 'Error sending command: $e', 500);
                                        }
                                      },
                                      label: const Text(
                                        "Stop",
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.red ,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(color: _Tone.subBorder),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final commService = context.read<CommunicationService>();
                                        try {
                                          final payLoadFinal = jsonEncode({
                                            "8400": {"8401": '${program.serialNumber},1'},
                                          });

                                          await Future.delayed(const Duration(milliseconds: 100));

                                          await commService.sendCommand(
                                            serverMsg: '${program.programName} ${ProgramCodeHelper.getDescription(1)}',
                                            payload: payLoadFinal,
                                          );

                                          if (!mounted) return;
                                          GlobalSnackBar.show(context, 'Program started successfully', 200);
                                          Navigator.pop(context);


                                        } catch (e) {
                                          GlobalSnackBar.show(context, 'Error sending command: $e', 500);
                                        }

                                      },
                                      label: const Text(
                                        "Start",
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.green ,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        side: const BorderSide(color: _Tone.subBorder),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        direction: PopoverDirection.bottom,
                        width: 400,
                        height: (programList.length * 40) + 16,
                        arrowHeight: 10,
                        arrowWidth: 20,
                      );
                    },
                    icon: const Icon(Icons.playlist_play, size: 16, color: Colors.white),
                    label: const Text(
                      'Programs',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: const BorderSide(color: _Tone.subBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );

                },
              ),

              const SizedBox(width: 8),
              _buildActionButton(
                label: 'New program',
                icon: Icons.add,
                onPressed: () {
                  final loggedInUser = context.read<UserProvider>().loggedInUser;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProgramLibraryScreenNew(
                        customerId: customerId,
                        controllerId: controllerId,
                        deviceId: deviceId,
                        userId: loggedInUser.id,
                        groupId: groupId,
                        categoryId: cMaster.categoryId,
                        modelId: cMaster.modelId,
                        deviceName: cMaster.deviceName,
                        categoryName: cMaster.categoryName,
                        callbackFunction: callbackFunction,
                        nodeList: vm.nodeList,
                      ),
                    ),
                  );
                },
                color: primary,
                filled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget sensorWidget(RelayStatus sensor) {
    return Selector<MqttPayloadProvider, String?>(
      selector: (_, provider) => provider.getSensorUpdatedValve(sensor.sNo.toString()),
      builder: (_, status, __) {
        String sensorVal = '0';
        final statusParts = status?.split(',') ?? [];
        if (statusParts.isNotEmpty) sensorVal = statusParts[1];

        final sNo = sensor.sNo?.toString() ?? '';
        String sensorType = sNo.startsWith('24.') ? 'Pressure Sensor' : 'Water Meter';
        String imagePath = sNo.startsWith('24.') ? 'assets/png/pressure_sensor.png' : 'assets/png/water_meter.png';

        return Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: _Tone.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _Tone.subBorder, width: 0.5),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
            ),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset(imagePath, width: 28, height: 28),
                  Positioned(top: 18, right: -8, child: _unitBox(context, sensorVal, sensorType)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                sensor.name.toString(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _Tone.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _unitBox(BuildContext context, String sensorVal, String sensorType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: _Tone.statusPendingBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _Tone.statusPending.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        MyFunction().getUnitByParameter(context, sensorType, sensorVal.toString()) ?? '',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _Tone.statusPending),
      ),
    );
  }

  void callbackFunction(String status) {
    if (status == 'Program created' && mounted) debugPrint(status);
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required Color color,
    bool filled = false,
  }) {
    final enabled = onPressed != null;
    if (filled) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 5,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16, color: enabled ? color : _Tone.textMuted),
      label: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: enabled ? _Tone.textPrimary : _Tone.textMuted),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(color: enabled ? _Tone.subBorder : _Tone.subBorder.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _toggleNodeSelection(NodeListViewModel vm, int nodeIndex) {
    final node = vm.nodeList[nodeIndex];
    final valves = node.rlyStatus.where((rly) {
      final sNo = rly.sNo.toString();
      return sNo.startsWith('13.') || sNo.startsWith('45.');
    }).toList();

    final currentSelection = nodeValveSelections[nodeIndex] ?? <int>{};
    final isFullySelected = currentSelection.length == valves.length && valves.isNotEmpty;

    if (isFullySelected) {
      _onValveSelectionChanged(nodeIndex, <int>{});
    } else {
      _onValveSelectionChanged(nodeIndex, valves.asMap().keys.toSet());
    }
  }

  List<Map<String, dynamic>> _collectSelectedNodeValveIds(NodeListViewModel vm) {
    final List<Map<String, dynamic>> result = [];
    nodeValveSelections.forEach((nodeIndex, valveIdxSet) {
      if (valveIdxSet.isEmpty) return;
      final node = vm.nodeList[nodeIndex];
      final valves = node.rlyStatus.where((rly) => rly.sNo.toString().startsWith('13.')).toList();
      for (final valveIdx in valveIdxSet) {
        if (valveIdx < 0 || valveIdx >= valves.length) continue;
        final valve = valves[valveIdx];
        result.add({'nodeId': node.deviceId, 'valveId': valve.sNo});
      }
    });
    return result;
  }

  Future<void> _onStartAll(NodeListViewModel vm) async {

    final nodeIds = <String>[];
    final nodeNames = <String>[];

    nodeValveSelections.forEach((nodeIndex, valveIdxSet) {
      if (valveIdxSet.isEmpty) return;
      final node = vm.nodeList[nodeIndex];
      nodeIds.add(node.serialNumber.toString());
      nodeNames.add(node.deviceName);
    });

    final nodeIdString = nodeIds.join('_');
    final nodeNameString = nodeNames.join('_');


    final commService = context.read<CommunicationService>();
    try {
      final payLoadFinal = jsonEncode({
        "8300": {"8301": '$nodeIdString,1'},
      });

      await Future.delayed(const Duration(milliseconds: 100));

      await commService.sendCommand(
        serverMsg: '$nodeNameString ${ProgramCodeHelper.getDescription(1)}',
        payload: payLoadFinal,
      );

      if (!mounted) return;
      GlobalSnackBar.show(context, 'Node started successfully', 200);

    } catch (e) {
      GlobalSnackBar.show(context, 'Error sending command: $e', 500);
    }

    /*final targets = _collectSelectedNodeValveIds(vm);
    debugPrint('Start all selected valves: $targets');
    for (final t in targets) {
      debugPrint('Starting nodeId=${t['nodeId']} valveId=${t['valveId']}');
    }*/
  }

  Future<void> _onStopAll(NodeListViewModel vm) async {

    final nodeIds = <String>[];
    final nodeNames = <String>[];

    nodeValveSelections.forEach((nodeIndex, valveIdxSet) {
      if (valveIdxSet.isEmpty) return;
      final node = vm.nodeList[nodeIndex];
      nodeIds.add(node.serialNumber.toString());
      nodeNames.add(node.deviceName);
    });

    final nodeIdString = nodeIds.join('_');
    final nodeNameString = nodeNames.join('_');

    final commService = context.read<CommunicationService>();
    try {
      final payLoadFinal = jsonEncode({
        "8300": {"8301": '$nodeIdString,0'},
      });

      await Future.delayed(const Duration(milliseconds: 100));

      await commService.sendCommand(
        serverMsg: '$nodeNameString ${ProgramCodeHelper.getDescription(0)}',
        payload: payLoadFinal,
      );

      if (!mounted) return;
      GlobalSnackBar.show(context, 'Node stopped successfully', 200);

    } catch (e) {
      GlobalSnackBar.show(context, 'Error sending command: $e', 500);
    }

    /*final targets = _collectSelectedNodeValveIds(vm);
    debugPrint('Stop all selected valves: $targets');
    for (final t in targets) {
      debugPrint('Stopping nodeId=${t['nodeId']} valveId=${t['valveId']}');
    }*/
  }

  void _onApplyProgram(NodeListViewModel vm) {
    final targets = fullySelectedNodeIndices(vm).map((i) => vm.nodeList[i].deviceId).toList();
    debugPrint('Apply program to fully-selected node ids: $targets');
  }

  Future<void> showEditProductDialog(BuildContext context, NodeListModel node, int userId) async {
    final TextEditingController nodeNameController = TextEditingController(text: node.deviceName);
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Node Name'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nodeNameController,
              maxLength: 30,
              decoration: const InputDecoration(hintText: "Enter node name"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Node name cannot be empty';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Map<String, Object> body = {"userId": widget.customerId, "controllerId": widget.controllerId,
                    "nodeControllerId": node.controllerId, "deviceName": nodeNameController.text, "modifyUser": userId};

                  try {
                    var response = await Repository(HttpService()).updateUserNodeDetails(body);
                    if (response.statusCode == 200) {
                      final jsonData = jsonDecode(response.body);
                      if (jsonData["code"] == 200) {
                        setState(() {
                          node.deviceName = nodeNameController.text;
                        });
                        GlobalSnackBar.show(context, 'Node name updated successfully', 200);
                        Navigator.of(context).pop();
                      }
                    }
                  } catch (error) {
                    debugPrint('Error fetching category list: $error');
                  }

                }
              },
            ),
          ],
        );
      },
    );
  }

}

/// ---------------------------------------------------------------------
/// Small metric chip
/// ---------------------------------------------------------------------
class _MetricChip extends StatelessWidget {

  final String label;
  final bool warn;
  const _MetricChip({required this.label, this.warn = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: warn ? _Tone.statusPendingBg : _Tone.surfaceMutedBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: warn ? _Tone.statusPending : _Tone.textSecondary),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Compact dot row used in the collapsed table row
/// ---------------------------------------------------------------------
class _ValveDotRow extends StatelessWidget {
  final List<RelayStatus> valves;
  const _ValveDotRow({required this.valves});

  @override
  Widget build(BuildContext context) {
    return Consumer<MqttPayloadProvider>(
      builder: (_, mqtt, __) {
        final shown = valves.take(8).toList();
        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ...shown.map((v) {
              final status = mqtt.getValveOnOffStatus(double.parse(v.sNo.toString()).toStringAsFixed(3));
              final parts = status?.split(',') ?? [];
              final currentStatus = parts.isNotEmpty ? (int.tryParse(parts[1]) ?? v.status) : v.status;
              final percent = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
              final display = _displayStatusFor(currentStatus, percent);
              final style = _styleFor(display);
              return Tooltip(
                message: '${v.name}: ${style.label}',
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(color: style.dot, borderRadius: BorderRadius.circular(2)),
                ),
              );
            }),
            if (valves.length > 8)
              Text('+${valves.length - 8}', style: const TextStyle(fontSize: 10, color: _Tone.textMuted)),
          ],
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------
/// "Running" summary cell — now shows the soonest-finishing valve's live
/// countdown (HH:MM:SS or remaining quantity) sourced from
/// CurrentProgramViewModel.currentSchedule, instead of a percent proxy.
/// ---------------------------------------------------------------------
class _RunningSummary extends StatelessWidget {
  final int nodeSNo;
  final List<RelayStatus> valves;
  final CurrentProgramViewModel programVm;
  const _RunningSummary({required this.valves, required this.programVm, required this.nodeSNo});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: programVm,
      builder: (_, __) {
        return Consumer<MqttPayloadProvider>(
          builder: (_, mqtt, ___) {
            int runningCount = 0;
            String? soonestDisplay;
            String? currentSequenceNumber;


            for (final v in valves) {
              final status = mqtt.getValveOnOffStatus(double.parse(v.sNo.toString()).toStringAsFixed(3));
              final parts = status?.split(',') ?? [];
              final currentStatus = parts.isNotEmpty ? (int.tryParse(parts[1]) ?? v.status) : v.status;
              final percent = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
              final display = _displayStatusFor(currentStatus, percent);


              if (display == ValveDisplayStatus.running) {
                runningCount++;
                final dur = _durationForValve(programVm.currentSchedule, nodeSNo.toString());
                print("dur:$dur");

                if (dur != null && dur.isActive) {
                  // Keep the first active duration we find as the
                  // headline value; good enough for the summary cell —
                  // the expanded card shows every valve's own duration.
                  soonestDisplay ??= dur.display;
                }

                // Get the sequence number for this valve from the schedule
                final sequenceNum = _getSequenceNumberForValve(programVm.currentSchedule, nodeSNo.toString());
                if (sequenceNum != null) {
                  currentSequenceNumber = sequenceNum;
                }
                print("soonestDisplay:$soonestDisplay");
              }
            }

            if (runningCount == 0) {
              return const Text('—', style: TextStyle(fontSize: 12, color: _Tone.textMuted));
            }


            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(soonestDisplay != null && soonestDisplay.contains(":") ? Icons.timer_outlined : Icons.water_drop_outlined, size: 13, color: _Tone.statusRunning),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        soonestDisplay != null ? '$runningCount active · $soonestDisplay' : '$runningCount active',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _Tone.statusRunning),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Text(
                    currentSequenceNumber != null ? 'Current Seq: $currentSequenceNumber' : 'No sequence',
                    style: const TextStyle(color: Colors.black38, fontSize: 10),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String? _getSequenceNumberForValve(List<String> currentSchedule, String nodeSNo) {
    for (final row in currentSchedule) {
      final values = row.split(',');
      if (values.isEmpty || values.length <= 11) continue;

      final scheduleNodeSNo = values[0].trim();
      if (scheduleNodeSNo != nodeSNo) continue;

      // Check if the program is running (status = 1)
      final programStatus = int.tryParse(values[4].trim()) ?? 0;
      if (programStatus != 1) continue;

      // Get the sequence number at index 1
      if (values.length > 1) {
        final sequenceTot = values[9].trim();
        final currentSequence = values[2].trim();
        if (sequenceTot.isNotEmpty && int.tryParse(sequenceTot) != null) {
          return '$currentSequence/$sequenceTot';
        }
      }
    }
    return null;
  }

}

/// ---------------------------------------------------------------------
/// Expanded node detail panel
/// ---------------------------------------------------------------------
class _NodeDetailPanel extends StatelessWidget {
  final int nodeSNo;
  final List<RelayStatus> sensors;
  final List<RelayStatus> valves;
  final Set<int> selectedValveIdx;
  final CurrentProgramViewModel programVm;
  final void Function(int valveIndex) onValveTap;
  final Widget Function(RelayStatus) sensorWidgetBuilder;

  const _NodeDetailPanel({
    required this.nodeSNo,
    required this.sensors,
    required this.valves,
    required this.selectedValveIdx,
    required this.programVm,
    required this.onValveTap,
    required this.sensorWidgetBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _Tone.surface,
      padding: const EdgeInsets.fromLTRB(48, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sensors.isNotEmpty) ...[
            const Text('Sensors', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _Tone.textMuted)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 8, children: sensors.map(sensorWidgetBuilder).toList()),
            const SizedBox(height: 14),
          ],
          const Text('Valves', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _Tone.textMuted)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: valves.asMap().entries.map((entry) {
              final i = entry.key;
              final valve = entry.value;
              return _ValveDetailCard(
                nodeSNo: nodeSNo,
                valve: valve,
                isSelected: selectedValveIdx.contains(i),
                programVm: programVm,
                onTap: () => onValveTap(i),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Full valve card — now shows a live HH:MM:SS or remaining-quantity
/// countdown (from CurrentProgramViewModel) instead of a percent bar,
/// when a duration row exists for this valve and is active.
/// ---------------------------------------------------------------------
class _ValveDetailCard extends StatelessWidget {
  final int nodeSNo;
  final RelayStatus valve;
  final bool isSelected;
  final CurrentProgramViewModel programVm;
  final VoidCallback onTap;

  const _ValveDetailCard({
    required this.nodeSNo,
    required this.valve,
    required this.isSelected,
    required this.programVm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: programVm,
      builder: (_, __) {
        return Selector<MqttPayloadProvider, String?>(
          selector: (_, provider) => provider.getValveOnOffStatus(
            double.parse(valve.sNo.toString()).toStringAsFixed(3),
          ),
          builder: (_, status, ___) {
            int currentStatus = valve.status;
            int completePercent = 0;

            final statusParts = status?.split(',') ?? [];
            if (statusParts.isNotEmpty) {
              currentStatus = int.tryParse(statusParts[1]) ?? valve.status;
              completePercent = statusParts.length > 2 ? int.parse(statusParts[2]) : 0;
            }

            final display = _displayStatusFor(currentStatus, completePercent);
            final style = _styleFor(display);
            final isFlowControl = valve.sNo.toString().startsWith('45.');
            final duration = _durationForValve(programVm.currentSchedule, nodeSNo.toString());

            return GestureDetector(
              onTap: onTap,
              child: Container(
                width: 178,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _Tone.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? primary : _Tone.subBorder,
                    width: isSelected ? 1.5 : 0.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey.shade100,
                      Colors.grey.shade300,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: isFlowControl ? Image.asset('assets/png/m_flow_control_valve.png',
                        color: style.dot,
                      ):Image.asset(
                        currentStatus == 1 ? 'assets/gif/m_valve_green.gif' : 'assets/png/m_valve_grey.png',
                        color: currentStatus == 1 ? null : style.dot,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 110,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  valve.name.toString(),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _Tone.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: isSelected ? primary : Colors.transparent,
                                  border: Border.all(color: isSelected ? primary : _Tone.border, width: 1),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: isSelected ? const Icon(Icons.check, size: 9, color: Colors.white) : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(style.label, style: TextStyle(fontSize: 10, color: style.fg, fontWeight: FontWeight.w500)),
                          // Duration display — only shown when this valve
                          // has a live schedule row. Time-based shows a
                          // ticking clock; flow-based shows remaining
                          // volume, matching whichever mode the program
                          // used (values[4] format in currentSchedule).
                          /*if (duration != null && duration.isActive && currentStatus == 1) ...[
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  duration.isTimeBased ? Icons.timer_outlined : Icons.water_drop_outlined,
                                  size: 11,
                                  color: _Tone.statusRunning,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  duration.display,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _Tone.statusRunning,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ] else if (display == ValveDisplayStatus.completed) ...[
                            const SizedBox(height: 4),
                            const Text('Finished', style: TextStyle(fontSize: 10, color: _Tone.textMuted)),
                          ],*/
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}