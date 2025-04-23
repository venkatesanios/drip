import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oro_drip_irrigation/Constants/properties.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/model/LineDataModel.dart';
import 'package:oro_drip_irrigation/modules/IrrigationProgram/view/schedule_screen.dart';
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
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: AppProperties.customBoxShadowLiteTheme
                  ),
                  child: Container(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: boxDecoration(color: Colors.white, border: false),
                    height: 55,
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
                            final indexToShow = irrigationProgramProvider.addNew
                                ? irrigationProgramProvider.irrigationLine!.sequence.length-1
                                : irrigationProgramProvider.addNext
                                ? irrigationProgramProvider.currentIndex+1
                                : irrigationProgramProvider.currentIndex;
                            return Material(
                              key: itemKeys[index],
                              child: InkWell(
                                onTap: (){
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
                                child: MediaQuery.of(context).size.width > 600 ?
                                ReorderableDragStartListener(
                                    index: index,
                                    child: buildSequence(context: context, index: index)
                                ) :
                                buildSequence(context: context, index: index),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                        : const Center(child: Text('Select desired sequence')),
                  ),
                ),
              ),
              // const SizedBox(height: 10,),
              Container(
                  margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: (){
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            showDragHandle: true,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context, StateSetter setModalState) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 10),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          for (var index = 0; index < irrigationProgramProvider.irrigationLine!.sequence.length; index++)
                                            Card(
                                              child: buildListTile(
                                                context: context,
                                                padding: const EdgeInsets.all(0),
                                                isNeedBoxShadow: false,
                                                title: irrigationProgramProvider.irrigationLine!.sequence[index]['name'],
                                                subTitle: irrigationProgramProvider.irrigationLine!.sequence[index]['valve']
                                                    .map((e) => e['name'])
                                                    .toList()
                                                    .join(", "),
                                                leading: "${index + 1}",
                                                trailing: IconButton(
                                                  onPressed: () {
                                                    _textEditingController.text = irrigationProgramProvider.irrigationLine!.sequence[index]['name'];
                                                    _textEditingController.selection = TextSelection(
                                                      baseOffset: 0,
                                                      extentOffset: _textEditingController.text.length,
                                                    );
                                                    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) {
                                                        return AlertDialog(
                                                          title: const Text("Edit Sequence name"),
                                                          content: Form(
                                                            key: _formKey,
                                                            child: TextFormField(
                                                              autofocus: true,
                                                              controller: _textEditingController,
                                                              // onChanged: (newValue) => tempSequenceName = newValue,
                                                              inputFormatters: [
                                                                LengthLimitingTextInputFormatter(20),
                                                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s.]'))
                                                              ],
                                                              validator: (value) {
                                                                if (value == null || value.isEmpty) {
                                                                  return "Name cannot be empty";
                                                                } else if (irrigationProgramProvider.irrigationLine!.sequence.any((element) => element.programName == value)) {
                                                                  return "Name already exists";
                                                                } else {
                                                                  setState(() {
                                                                    _textEditingController.text = value;
                                                                  });
                                                                }
                                                                return null;
                                                              },
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () => Navigator.of(ctx).pop(),
                                                              child: const Text("CANCEL", style: TextStyle(color: Colors.red)),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(ctx).pop();
                                                                setModalState(() {
                                                                  irrigationProgramProvider.irrigationLine!.sequence[index]['name'] = _textEditingController.text;
                                                                });
                                                                setState(() {});
                                                              },
                                                              child: const Text("OKAY", style: TextStyle(color: Colors.green)),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  icon: const Icon(Icons.edit),
                                                ),
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
                        },
                        icon: const Icon(Icons.edit_note_rounded, color: Colors.white,),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColorLight)
                        ),
                      ),
                      buildButtonBar(context: context, isAgitatorProgram: agitatorProgram)
                    ],
                  )
              ),
              // const SizedBox(height: 10,),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: MediaQuery.of(context).size.width * 0.012),
                    child: Column(
                      children: [
                        if(irrigationProgramProvider.sampleIrrigationLine!.expand((element) => element.mainValve!).toList().isNotEmpty && irrigationProgram)
                          buildIrrigationLinesList(
                              context: context,
                              dataList: irrigationProgramProvider.mainValves,
                              isGroup: false,
                              isMainValve: true
                          ),
                        if(irrigationProgram)
                          buildIrrigationLinesList(
                              context: context,
                              dataList: irrigationProgramProvider.irrigationLine!.defaultData.group,
                              isGroup: true
                          ),
                        if(irrigationProgramProvider.sampleIrrigationLine!.isNotEmpty && irrigationProgram)
                          buildIrrigationLinesList(
                              context: context,
                              dataList: irrigationProgramProvider.sampleIrrigationLine!,
                              isGroup: false
                          ),
                        if(irrigationProgramProvider.agitators != null && agitatorProgram)
                          buildIrrigationLinesList(
                              context: context,
                              dataList: irrigationProgramProvider.agitators,
                              isGroup: false,
                              isAgitator: true
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50,),
            ],
          );
        }
    )
        : const Center(child: CircularProgressIndicator());
  }

  Widget buildSequence({required BuildContext context,index}) {
    final indexToShow = irrigationProgramProvider.addNew
        ? irrigationProgramProvider.irrigationLine!.sequence.length-1
        : irrigationProgramProvider.addNext
        ? irrigationProgramProvider.currentIndex+1
        : irrigationProgramProvider.currentIndex;
    return Row(
      children: [
        Container(
          decoration: boxDecoration(linearGradient: index == indexToShow ? AppProperties.linearGradientLeading : null),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              irrigationProgramProvider.irrigationLine!.sequence[index]['name'],
              style: TextStyle(fontWeight: FontWeight.bold, color: index == indexToShow ? Colors.white : Colors.black),
            ),
          ),
        ),
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

  BoxDecoration boxDecoration({Color? color, LinearGradient? linearGradient, bool border = true}) {
    return BoxDecoration(
        color: color,
        gradient: linearGradient,
        border: border ? Border.all(width: 0.3, color: Theme.of(context).primaryColor) : const Border(),
        borderRadius: BorderRadius.circular(10)
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
            // print(selectedOption);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
            child: Row(
              children: [
                Icon(Icons.check_box_outline_blank,),
                SizedBox(width: 5,),
                Icon(Icons.arrow_drop_down,)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildActionButton(
      {required BuildContext context, required String key, required IconData icon, required String label, void Function()? onPressed, Color? buttonColor, Color? labelColor}) {
    return MaterialButton(
      key: Key(key),
      onPressed: onPressed,
      color: buttonColor ?? Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
        child: Row(
          children: [
            MediaQuery.of(context).size.width > 900 ? Text(label, style: TextStyle(color: onPressed != null ? labelColor : Colors.grey),) : const Text(""),
            const SizedBox(width: 5,),
            Icon(icon, color: onPressed != null ? labelColor : Colors.grey,),
          ],
        ),
      ),
    );
  }

  Widget buildIrrigationLinesList({required BuildContext context, required dataList, required bool isGroup, bool isMainValve = false, bool isAgitator = false}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: (!isGroup && !isMainValve && !isAgitator) ? dataList.length : 1,
      itemBuilder: (BuildContext context, int lineIndex) {
        try {
          return Column(
            children: [
              buildLineAndValveContainerUpdated(
                  context: context,
                  title: isGroup
                      ? "Valve Groups"
                      : isMainValve
                      ? "Main valves"
                      : isAgitator
                      ? "Agitators"
                      : dataList[lineIndex].irrigationLine.name!,
                  trailing: isGroup
                      ? TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupListScreen(userId: widget.userId, controllerId: widget.controllerId, deviceId: widget.deviceId,)));
                      },
                      child: const Text("Create")
                  )
                      : null,
                  leading: isMainValve ? Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle
                    ),
                    child: Image.asset(
                      'assets/Images/m_valve.png',
                    ),
                  ) : null,
                  children: [
                    if(isMainValve && !isAgitator)
                      ...dataList.map((mainValve) {
                        return buildValveContainer(
                            context: context,
                            item: mainValve,
                            isMainValve: false,
                            isGroup: false,
                            dataList: mainValve,
                            lineIndex: lineIndex
                        );
                      }),
                    if(isGroup && !isMainValve && !isAgitator)
                      ...dataList.map((groupElement) {
                        return buildValveContainer(
                            context: context,
                            item: groupElement,
                            isGroup: true,
                            isMainValve: false,
                            dataList: groupElement.valve,
                            lineIndex: lineIndex);
                      }),
                    if(!isGroup && !isMainValve && !isAgitator)
                      ...(dataList[lineIndex].valve ?? []).map((valveItem) {
                        return buildValveContainer(
                            context: context,
                            item: valveItem,
                            isGroup: false,
                            isMainValve: false,
                            dataList: dataList,
                            lineIndex: lineIndex);
                      }),
                    if(isAgitator)
                      ...dataList.map((agitator) {
                        return buildValveContainer(
                            context: context,
                            item: agitator,
                            isMainValve: false,
                            isGroup: false,
                            dataList: agitator,
                            lineIndex: lineIndex
                        );
                      }),
                  ]
              ),
              const SizedBox(height: 20,),
              // if(lineIndex == dataList.length - 1)
              // const SizedBox(height: 50,)
            ],
          );
        } catch(error, stackTrace) {
          print("Error: $error");
          print("Stack Trace: $stackTrace");
          return const SizedBox();
        }
      },
    );
  }

  Widget buildValveContainer({context, item, isGroup, dataList, lineIndex, bool isMainValve = false}) {
    // print("dataList :: $dataList");
    final sequence = irrigationProgramProvider.irrigationLine!.sequence;
    final indexToShow = irrigationProgramProvider.addNew
        ? irrigationProgramProvider.irrigationLine!.sequence.length-1
        : irrigationProgramProvider.addNext
        ? irrigationProgramProvider.currentIndex+1
        : irrigationProgramProvider.currentIndex;
    return buildListOfContainer(
        context: context,
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
        containerColor: isGroup
            ? (sequence.isNotEmpty && sequence[indexToShow]['selectedGroup'] != null && sequence[indexToShow]['selectedGroup'].any((e) => e == item.id)) ? const Color(0xfffdce7f) : const Color(0xffFFF7E5)
            : !isMainValve
            ? (sequence.isNotEmpty && sequence.any((element) => element['valve'].isNotEmpty) && sequence[indexToShow]['valve'].any((e) => e["sNo"] == item.sNo))
            ? Theme.of(context).primaryColor
            : const Color(0xffE3FFF5)
            : isMainValve
            ? (sequence.isNotEmpty && sequence.any((element) => element['mainValve'].isNotEmpty) && sequence[indexToShow]['mainValve'].any((e) => e["sNo"] == item.sNo))
            ? const Color(0xfffdce7f)
            : const Color(0xffFFF7E5)
            : const Color(0xfffdce7f),
        textColor: !isGroup
            ? !isMainValve
            ? (sequence.isNotEmpty && sequence.any((element) => element['valve'].isNotEmpty) && sequence[indexToShow]['valve'].any((e) => e["sNo"] == item.sNo))
            ? Colors.white
            : null
            : null
            : null,
        itemName: item.name
    );
  }
}

Widget buildListOfContainer(
    {required context, required void Function() onTap, Color? containerColor, Color? textColor, required String itemName}
    ) {
  return IntrinsicWidth(
    child: InkWell(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: containerColor,
            border: Border.all(color: Theme.of(context).highlightColor, width: 0.5)
        ),
        child: Center(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(itemName, style: TextStyle(color: textColor)),
        )),
      ),
    ),
  );
}

Widget buildLineAndValveContainerUpdated({
  required BuildContext context,
  required String title,
  required List<Widget> children,
  Widget? leading,
  Widget? trailing,
  bool isRowLayout = true,
}) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      boxShadow: AppProperties.customBoxShadowLiteTheme,
    ),
    child: isRowLayout && MediaQuery.of(context).size.width > 800
        ? Row(
      children: [
        buildLeadingTitle(context, title, leading, 40, 22),
        const SizedBox(width: 10),
        const VerticalDivider(),
        const SizedBox(width: 10),
        Expanded(
          flex: 5,
          child: Wrap(spacing: 5, runSpacing: 10, children: children),
        ),
      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            buildLeadingTitle(context, title, leading, 35, 16),
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
  );
}

Widget buildLeadingTitle(BuildContext context, String title, Widget? leading, double size, double fontSize) {
  return Expanded(
    flex: 1,
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

