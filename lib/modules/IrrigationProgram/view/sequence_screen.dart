import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/model/LineDataModel.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/schedule_screen.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/widgets/custom_section_title.dart';
import 'package:oro_drip_irrigation/utils/constants.dart';
import 'package:provider/provider.dart';
import '../../../Screens/planning/valve_group_screen.dart';
import '../state_management/irrigation_program_provider.dart';
import '../widgets/custom_animated_switcher.dart';
import '../../SystemDefinitions/widgets/custom_snack_bar.dart';
import 'conditions_screen.dart';
import 'irrigation_program_main.dart';

class SequenceScreen extends StatefulWidget {
  final int userId;
  final int controllerId;
  final int serialNumber;
  final String deviceId;
  const SequenceScreen({super.key, required this.userId, required this.controllerId, required this.serialNumber, required this.deviceId});

  @override
  State<SequenceScreen> createState() => _SequenceScreenState();
}

class _SequenceScreenState extends State<SequenceScreen> {
  final ScrollController _scrollController = ScrollController();
  Map<int, ScrollController> itemScrollControllers = {};
  late IrrigationProgramMainProvider irrigationProgramProvider;
  final TextEditingController _textEditingController = TextEditingController();
  String tempSequenceName = '';

  @override
  void initState() {
    irrigationProgramProvider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    if(mounted) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        irrigationProgramProvider.assigningCurrentIndex(0);
        // print("inside mounted function ${irrigationProgramProvider.addNext}");
        irrigationProgramProvider.addNext = false;
      });
    }
    // print("outside mounted function ${irrigationProgramProvider.addNext}");
    // irrigationProgramProvider.currentIndex = 0;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    irrigationProgramProvider = Provider.of<IrrigationProgramMainProvider>(context);
    final Map<int, GlobalKey> itemKeys = {};
    final irrigationProgram = ((irrigationProgramProvider.programDetails!.programType == "Irrigation Program")
        || (irrigationProgramProvider.selectedProgramType == "Irrigation Program"));
    final agitatorProgram = ((irrigationProgramProvider.programDetails!.programType == "Agitator Program")
        || (irrigationProgramProvider.selectedProgramType == "Agitator Program"));
    return irrigationProgramProvider.sampleIrrigationLine != null ?
    LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: MediaQuery.of(context).size.width >= 700 ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: MediaQuery.of(context).size.width * 0.025,
                ) : const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: boxDecoration(color: Colors.white, border: false),
                height: 60,
                width: double.infinity,
                child: (irrigationProgramProvider.irrigationLine!.sequence.isNotEmpty)
                    ? GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    _scrollController.jumpTo(_scrollController.offset - details.primaryDelta! / 2);
                  },
                  child: Center(
                    child: ReorderableListView.builder(
                      scrollController: irrigationProgramProvider.irrigationLine!.sequence.isNotEmpty ? _scrollController : null,
                      autoScrollerVelocityScalar: 0.5,
                      buildDefaultDragHandles: MediaQuery.of(context).size.width > 600 ? false : true,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      onReorder: (oldIndex, newIndex) {
                        irrigationProgramProvider.reorderSelectedValves(oldIndex, newIndex);
                        // irrigationProgramProvider.assigningCurrentIndex(newIndex);
                      },
                      proxyDecorator: (widget, animation, index) {
                        return Transform.scale(
                          scale: 1.05,
                          child: widget,
                        );
                      },
                      itemCount: irrigationProgramProvider.irrigationLine!.sequence.length,
                      itemBuilder: (context, index) {
                        if (!itemKeys.containsKey(index)) {
                          itemKeys[index] = GlobalKey();
                        }
                        return Material(
                          key: itemKeys[index],
                          color: Colors.transparent,
                          child: MediaQuery.of(context).size.width > 600 ?
                          ReorderableDragStartListener(
                              index: index,
                              child: Padding(
                                padding: EdgeInsets.only(left: index == 0 ? 10 : 0, right: index == irrigationProgramProvider.irrigationLine!.sequence.length - 1 ? 5 : 0),
                                child: buildSequence(context: context, index: index),
                              )
                          ) :
                          Padding(
                            padding: EdgeInsets.only(left: index == 0 ? 10 : 0, right: index == irrigationProgramProvider.irrigationLine!.sequence.length - 1 ? 5 : 0),
                            child: buildSequence(context: context, index: index),
                          ),
                        );
                      },
                    ),
                  ),
                )
                    : const Center(child: Text('Select desired sequence')),
              ),
              // const SizedBox(height: 10,),
              Container(
                  margin: MediaQuery.of(context).size.width >= 700
                      ? EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05)
                      : const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilledButton(
                        onPressed: () => _showEditSequencesSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColorLight,
                          elevation: 2,
                          shadowColor: Theme.of(context).primaryColorLight.withAlpha(30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          minimumSize: const Size(0, 40),
                        ),
                        child:  Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit_note_rounded, size: 20, color: Colors.white,),
                            if (MediaQuery.of(context).size.width > 900) ...[
                              const SizedBox(width: 6),
                              const Flexible(
                                child: Text(
                                  "Edit",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      buildButtonBar(context: context, isAgitatorProgram: agitatorProgram)
                    ],
                  )
              ),
              // const SizedBox(height: 10,),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: _getResponsiveMargin(context),
                    child: Column(
                      children: _buildIrrigationSections(context),
                    ),
                  ),
                ),
              ),
              // const SizedBox(height: 50,),
            ],
          );
        }
    )
        : const Center(child: CircularProgressIndicator());
  }

  void _showEditSequencesSheet(BuildContext context) {
    final provider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      'Edit Sequences',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: provider.irrigationLine!.sequence.length,
                      itemBuilder: (context, index) {
                        final sequence = provider.irrigationLine!.sequence[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Text('${index + 1}'),
                          title: Text(sequence['name']),
                          subtitle: Text(
                            sequence['valve'].map((e) => e['name']).join(', '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            color: Theme.of(context).primaryColor,
                            onPressed: () => _showEditNameDialog(context, index, setModalState),
                          ),
                          onTap: () => _showEditNameDialog(context, index, setModalState),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, int index, StateSetter setModalState) {
    final provider = Provider.of<IrrigationProgramMainProvider>(context, listen: false);
    final sequence = provider.irrigationLine!.sequence;
    final controller = TextEditingController(text: sequence[index]['name'])..selection = TextSelection(
      baseOffset: 0,
      extentOffset: sequence[index]['name'].length,
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Sequence Name'),
        content: Form(
          key: formKey,
          child: TextFormField(
            autofocus: true,
            controller: controller,
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s.]')),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Name cannot be empty';
              if (sequence.any((e) => e['name'] == value && e != sequence[index])) {
                return 'Name already exists';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setModalState(() {
                  sequence[index]['name'] = controller.text;
                });
                Navigator.pop(ctx);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget buildSequence({required BuildContext context,index}) {
    final indexToShow = irrigationProgramProvider.addNew
        ? irrigationProgramProvider.irrigationLine!.sequence.length-1
        : irrigationProgramProvider.addNext
        ? irrigationProgramProvider.currentIndex+1
        : irrigationProgramProvider.currentIndex;
    return Row(
      children: [
        _buildSequenceItems(index, indexToShow),
        CustomAnimatedSwitcher(
            condition: irrigationProgramProvider.selectedOption != irrigationProgramProvider.deleteSelection[2],
            child: Checkbox(
                value: irrigationProgramProvider.irrigationLine!.sequence[index]['selected'] ?? false,
                onChanged: (newValue){
                  irrigationProgramProvider.updateCheckBoxSelection(index: index, newValue: newValue);
                }
            )
        ),
        const SizedBox(width: 5,),
      ],
    );
  }

  Widget _buildSequenceItems(int index, int indexToShow) {
    return buildListOfContainer(
        context: context,
        onTap: () {
          if(irrigationProgramProvider.irrigationLine!.sequence[indexToShow]['valve'].isEmpty){
            showAdaptiveDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: const Text('At least one valve should be selected!', style: TextStyle(color: Colors.red),),
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
          else {
            irrigationProgramProvider.addNext = false;
            irrigationProgramProvider.assigningCurrentIndex(index);
          }
        },
        selected: index == indexToShow,
        darkColor: Theme.of(context).primaryColorLight,
        textColor: index == indexToShow ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        itemName: irrigationProgramProvider.irrigationLine!.sequence[index]['name']
    );
    /*return  Container(
      decoration: boxDecoration(linearGradient: index == indexToShow ? AppProperties.linearGradientLeading : null),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          irrigationProgramProvider.irrigationLine!.sequence[index]['name'],
          style: TextStyle(fontWeight: FontWeight.bold, color: index == indexToShow ? Colors.white : Colors.black),
        ),
      ),
    );*/
  }

  BoxDecoration boxDecoration({Color? color, LinearGradient? linearGradient, bool border = true}) {
    return BoxDecoration(
        color: color,
        gradient: linearGradient,
        border: border ? Border.all(width: 0.3, color: Theme.of(context).primaryColor) : const Border(),
        borderRadius: BorderRadius.circular(15),
      boxShadow: AppProperties.customBoxShadowLiteTheme

    );
  }

  Widget buildButtonBar({required BuildContext context, bool isAgitatorProgram = false}) {
    final sequence = irrigationProgramProvider.irrigationLine!.sequence;
    final indexToShow = irrigationProgramProvider.addNew
        ? irrigationProgramProvider.irrigationLine!.sequence.length-1
        : irrigationProgramProvider.addNext
        ? irrigationProgramProvider.currentIndex+1
        : irrigationProgramProvider.currentIndex;
    // print(indexToShow);
    return ButtonBar(
      alignment: MainAxisAlignment.end,
      layoutBehavior: ButtonBarLayoutBehavior.constrained,
      children: [
        buildActionButton(
            context: context,
            key: 'addNext',
            labelColor: Theme.of(context).primaryColor,
            icon: indexToShow == sequence.length-1 ? Icons.add : Icons.skip_next,
            label: indexToShow == sequence.length-1 ? "Add new" : "Add next",
            onPressed: (){
              if(sequence[indexToShow]['valve'].isEmpty){
                showAdaptiveDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text('At least one valve should be selected!', style: TextStyle(color: Colors.red),),
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
              } else {
                irrigationProgramProvider.updateAddNext(serialNumber: widget.serialNumber, indexToShow: indexToShow);
                irrigationProgramProvider.updateNextButton(indexToShow);
                double itemSize = 60.0;
                double targetOffset = indexToShow * itemSize;
                _scrollController.animateTo(targetOffset, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
              }
            }
        ),
        buildActionButton(
            context: context,
            key:'delete',
            icon:Icons.delete,
            label:"Delete",
            labelColor: Colors.red,
            onPressed: irrigationProgramProvider.irrigationLine!.sequence.any((element) => element['selected'] == true) ?
                (){
              showAdaptiveDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: const Text('Are you sure to erase the sequence?'),
                    actions: [
                      TextButton(
                        child: const Text("CANCEL", style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () {
                          Future.delayed(Duration.zero, () {
                            irrigationProgramProvider.deleteFunction(indexToShow: indexToShow, serialNumber: widget.serialNumber);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(message: 'The sequence is erased!'));
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            } : null
        ),
        buildPopUpMenuButton(
          context: context,
          dataList: irrigationProgramProvider.deleteSelection,
          onSelected: (selected) {
            irrigationProgramProvider.updateDeleteSelection(newOption: selected);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
            child: Row(
              children: [
                Checkbox(
                    value: irrigationProgramProvider.selectedOption == irrigationProgramProvider.deleteSelection[1],
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (selected) {
                      final newValue = selected! ? irrigationProgramProvider.deleteSelection[1] : irrigationProgramProvider.deleteSelection[2];
                      irrigationProgramProvider.updateDeleteSelection(newOption: newValue);
                    }
                ),
                const Icon(Icons.arrow_drop_down,)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildActionButton({
    required BuildContext context,
    required String key,
    required IconData icon,
    required String label,
    void Function()? onPressed,
    Color? buttonColor,
    Color? labelColor,
  }) {
    final isEnabled = onPressed != null;
    final effectiveButtonColor = buttonColor ?? Colors.white;
    final effectiveLabelColor = labelColor ?? Theme.of(context).primaryColor;
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    return AnimatedScale(
      scale: isEnabled ? 1.0 : 0.95,
      duration: const Duration(milliseconds: 150),
      child: ElevatedButton(
        key: Key(key),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveButtonColor,
          foregroundColor: isEnabled ? effectiveLabelColor : Colors.grey.shade50,
          elevation: isEnabled ? 2 : 0,
          shadowColor: effectiveButtonColor.withAlpha(30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isEnabled ? effectiveLabelColor.withAlpha(100) : Colors.grey.withAlpha(10),
              width: 0.8,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          minimumSize: const Size(0, 40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isEnabled ? effectiveLabelColor : Colors.grey),
            if (isWideScreen) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? effectiveLabelColor : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  EdgeInsets _getResponsiveMargin(BuildContext context) {
    return MediaQuery.of(context).size.width >= 700
        ? EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05)
        : const EdgeInsets.symmetric(horizontal: 15);
  }

  List<Widget> _buildIrrigationSections(BuildContext context) {
    final provider = Provider.of<IrrigationProgramMainProvider>(context);
    final isIrrigationProgram = provider.programDetails!.programType == "Irrigation Program" ||
        provider.selectedProgramType == "Irrigation Program";
    final isAgitatorProgram = provider.programDetails!.programType == "Agitator Program" ||
        provider.selectedProgramType == "Agitator Program";
    final sampleIrrigationLine = provider.sampleIrrigationLine;

    final sections = <Widget>[];

    if (isIrrigationProgram && sampleIrrigationLine != null) {
      // Main Valves
      final mainValves = sampleIrrigationLine.expand((e) => e.mainValve ?? []).toList();
      if (mainValves.isNotEmpty) {
        sections.add(_buildIrrigationSection(
          context: context,
          title: 'Main valves',
          items: mainValves,
          isMainValve: true,
          leading: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(color: cardColor, shape: BoxShape.circle),
            child: Image.asset('assets/Images/m_valve.png'),
          ),
        ));
      }

      // Valve Groups
      final groups = provider.irrigationLine?.defaultData.group ?? [];
      if (groups.isNotEmpty) {
        sections.add(_buildIrrigationSection(
          context: context,
          title: 'Valve Groups',
          items: groups,
          isGroup: true,
          trailing: SizedBox(
            height: 30,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupListScreen(
                    userId: widget.userId,
                    controllerId: widget.controllerId,
                    deviceId: widget.deviceId,
                  ),
                ),
              ),
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 0)),
              ),
              child: const Text('Create'),
            ),
          ),
        ));
      }

      // Irrigation Lines
      if (sampleIrrigationLine.isNotEmpty) {
        sections.addAll(sampleIrrigationLine.asMap().entries.map((entry) {
          final index = entry.key;
          final line = entry.value;
          return _buildIrrigationSection(
            context: context,
            title: line.irrigationLine.name ?? 'Unnamed Line',
            items: line.valve ?? [],
            lineIndex: index,
          );
        }));
      }
    }

    // Agitators
    if (isAgitatorProgram && provider.agitators != null) {
      sections.add(_buildIrrigationSection(
        context: context,
        title: 'Agitators',
        items: provider.agitators!,
        isAgitator: true,
      ));
    }

    return sections;
  }

  Widget _buildIrrigationSection({
    required BuildContext context,
    required String title,
    required List<dynamic> items,
    bool isGroup = false,
    bool isMainValve = false,
    bool isAgitator = false,
    int lineIndex = 0,
    Widget? leading,
    Widget? trailing,
  }) {
    return Column(
      children: [
        buildLineAndValveContainerUpdated(
          context: context,
          title: title,
          leading: leading,
          trailing: trailing,
          children: items.map((item) {
            return buildValveContainer(
              context: context,
              item: item,
              isGroup: isGroup,
              isMainValve: isMainValve,
              dataList: isGroup ? item.valve : items,
              lineIndex: lineIndex,
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildIrrigationLinesList({
    required BuildContext context,
    required List<dynamic> dataList,
    required bool isGroup,
    bool isMainValve = false,
    bool isAgitator = false,
  }) {
    return _buildIrrigationSection(
      context: context,
      title: isGroup
          ? 'Valve Groups'
          : isMainValve
          ? 'Main valves'
          : isAgitator
          ? 'Agitators'
          : dataList.isNotEmpty
          ? dataList[0].irrigationLine.name ?? 'Unnamed Line'
          : 'Unknown',
      items: dataList,
      isGroup: isGroup,
      isMainValve: isMainValve,
      isAgitator: isAgitator,
      leading: isMainValve
          ? Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(color: cardColor, shape: BoxShape.circle),
        child: Image.asset('assets/Images/m_valve.png'),
      )
          : null,
      trailing: isGroup
          ? OutlinedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupListScreen(
              userId: widget.userId,
              controllerId: widget.controllerId,
              deviceId: widget.deviceId,
            ),
          ),
        ),
        child: const Text('Create'),
      )
          : null,
    );
  }

  Widget buildValveContainer({context, item, isGroup, dataList, lineIndex, bool isMainValve = false}) {
    final sequence = irrigationProgramProvider.irrigationLine!.sequence;
    final indexToShow = irrigationProgramProvider.addNew
        ? irrigationProgramProvider.irrigationLine!.sequence.length-1
        : irrigationProgramProvider.addNext
        ? irrigationProgramProvider.currentIndex+1
        : irrigationProgramProvider.currentIndex;
    return buildListOfContainer(
        context: context,
        selected: sequence.isEmpty || indexToShow >= sequence.length
            ? false
            : isGroup
            ? sequence[indexToShow]['selectedGroup'] != null &&
            (sequence[indexToShow]['selectedGroup'] as List).any((e) => e == item.id)
            ? true
            : false
            : isMainValve
            ? sequence[indexToShow]['mainValve'] != null &&
            (sequence[indexToShow]['mainValve'] as List).any((e) => e['sNo'] == item.sNo)
            ? true
            : false
            : sequence[indexToShow]['valve'] != null &&
            (sequence[indexToShow]['valve'] as List).any((e) => e['sNo'] == item.sNo)
            ? true
            : false,
        onTap: (){
          if(sequence[indexToShow]['modified'] ?? false) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Warning!"),
                    content: const Text("The fertilizer settings will be erased while adding or removing valve in the existing sequence! \n Are you sure modify the sequence?"),
                    actions: [
                      TextButton(
                          onPressed: (){
                            sequence[indexToShow]['modified'] = true;
                            irrigationProgramProvider.addValvesInSequence(
                                valves: isGroup ? dataList.map((e) => e.toJson()).toList() : [item.toJson()],
                                lineIndex: lineIndex,
                                isMainValve: isMainValve,
                                sequenceIndex: indexToShow,
                                serialNumber: widget.serialNumber == 0 ? irrigationProgramProvider.serialNumberCreation : widget.serialNumber,
                                sNo: sequence.length+1,
                                groupId: item.id
                            );
                          },
                          child: const Text("Yes", style: TextStyle(color: Colors.green),)
                      ),
                      TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: const Text("No", style: TextStyle(color: Colors.red),)
                      ),
                    ],
                  );
                }
            );
          } else {
            if (!sequence[indexToShow].containsKey('selectedGroup')) {
              sequence[indexToShow]['selectedGroup'] = [];
            }
            irrigationProgramProvider.addValvesInSequence(
                valves: isGroup ? dataList.map((e) => e.toJson()).toList() : [item.toJson()],
                lineIndex: lineIndex,
                isMainValve: isMainValve,
                sequenceIndex: indexToShow,
                isGroup: isGroup,
                serialNumber: widget.serialNumber == 0 ? irrigationProgramProvider.serialNumberCreation : widget.serialNumber,
                sNo: sequence.length+1,
                groupId: isGroup ? item.id : ''
            );
          }
        },
        darkColor: (!isGroup && !isMainValve)
            ? Theme.of(context).primaryColorLight.withAlpha(150)
            : const Color(0xfffdce7f),
        textColor: (!isGroup && !isMainValve)
            ? (sequence.isNotEmpty && sequence.any((element) => element['valve'].isNotEmpty) && sequence[indexToShow]['valve'].any((e) => e["sNo"] == item.sNo))
            ? Colors.white
            : null
            : null,
        itemName: item.name,
    );
  }
}

Widget buildListOfContainer({
  required BuildContext context,
  required void Function() onTap,
  required bool selected,
  Color? darkColor,
  Color? lightColor,
  Color? textColor,
  required String itemName,
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 0, horizontal: 10)
}) {

  Color getDarkerColor(Color? color) {
    if (color == null) return Colors.black;
    return Color.fromRGBO(
      (color.red * 0.8).round(),
      (color.green * 0.8).round(),
      (color.blue * 0.8).round(),
      1.0,
    );
  }

  return ChoiceChip(
    label:Row(
      spacing: 4,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selected) Icon(Icons.radio_button_checked, color: textColor ?? getDarkerColor(darkColor), size: 20),
        Text(itemName, style: TextStyle(color: textColor ?? Colors.black)),
      ],
    ),
    selected: selected,
    showCheckmark: false,
    onSelected: (isSelected) => onTap(),
    selectedColor: darkColor,
    backgroundColor: selected ? darkColor : darkColor!.withAlpha(20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: darkColor!, width: 0.8),
    ),
    elevation: 4,
    shadowColor: darkColor.withAlpha(50),
    labelPadding: EdgeInsets.zero,
    padding: padding,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

Widget buildLineAndValveContainerUpdated({
  required BuildContext context,
  required String title,
  required List<Widget> children,
  Widget? leading,
  Widget? trailing,
  bool isRowLayout = true,
  bool isTitle = false
}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.only(
          bottomLeft: const Radius.circular(10),
          bottomRight: const Radius.circular(10),
          topRight: const Radius.circular(10),
          topLeft: (isTitle ? const Radius.circular(0) : const Radius.circular(10))
      ),
      color: Colors.white,
      boxShadow: AppProperties.customBoxShadowLiteTheme,
    ),
    child: isRowLayout && MediaQuery.of(context).size.width > 800
        ? Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          buildLeadingTitle(context, title, leading, 40, 22),
          const SizedBox(width: 10),
          const SizedBox(
            height: 50,
              child: VerticalDivider(color: Colors.grey)
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Wrap(spacing: 5, runSpacing: 10, children: children),
          ),
          if (trailing != null)
            Align(
              alignment: Alignment.centerRight,
              child: trailing,
            ),
        ],
      ),
    )
        : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              buildLeadingTitle(context, title, leading, 30, 16),
              if (trailing != null)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: trailing,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 5, runSpacing: 10, children: children),
        ],
      ),
    ),
  );
}

Widget buildLeadingTitle(BuildContext context, String title, Widget? leading, double size, double fontSize) {
  return Expanded(
    child: Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: leading ?? Image.asset('assets/Images/irrigation_line1.png', color: Theme.of(context).primaryColorDark),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
            maxLines: 2,
          ),
        ),
      ],
    ),
  );
}

