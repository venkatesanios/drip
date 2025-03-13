import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'constant_tableChart/customTimepicker_in_const.dart';
import 'modal_in_constant.dart';

class FertilizerInConstant extends StatefulWidget {
  List<FertilizerSite> fertilizerSite;
   List<Channel>channels;
  FertilizerInConstant(
      {super.key,
      required this.fertilizerSite, required this.channels});

  @override
  State<FertilizerInConstant> createState() => _FertilizerInConstantState();
}

class _FertilizerInConstantState extends State<FertilizerInConstant> {
  late LinkedScrollControllerGroup _scrollGroup;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;

  late List<TextEditingController> minimalOnTimeControllers;
  late List<TextEditingController> minimalOffTimeControllers;
  late List<TextEditingController> boosterOffDelayControllers;
  late List<List<TextEditingController>> ratioControllers;
  late List<List<TextEditingController>> shortestPulseControllers;
  late List<List<TextEditingController>> nominalFlowControllers;
  late List<List<TextEditingController>> injectorModeControllers;
  double defaultSize = 120;

  List<String> actionOptions = [
    'Concentration',
    'Ec controlled',
    'Ph controlled',
    'Regular'
  ];

  @override
  void initState() {
    super.initState();
    _scrollGroup = LinkedScrollControllerGroup();
    _verticalScroll1 = _scrollGroup.addAndGet();
    _verticalScroll2 = _scrollGroup.addAndGet();
    _horizontalScroll1 = ScrollController();
    _horizontalScroll2 = ScrollController();

    minimalOnTimeControllers = _initControllers((site) => site.minimalOnTime);
    minimalOffTimeControllers = _initControllers((site) => site.minimalOffTime);
    boosterOffDelayControllers =
        _initControllers((site) => site.boosterOffDelay);
    ratioControllers =
        _initNestedControllers((injector) => injector.ratio.toString());
    shortestPulseControllers =
        _initNestedControllers((injector) => injector.shortestPulse.toString());
    nominalFlowControllers =
        _initNestedControllers((injector) => injector.nominalFlow.toString());
    injectorModeControllers =
        _initNestedControllers((injector) => injector.injectorMode.toString());
  }

  List<TextEditingController> _initControllers(
      String Function(FertilizerSite) getValue) {
    return widget.fertilizerSite.map((site) {
      return TextEditingController(
        text: _formatTime(double.tryParse(getValue(site)) ?? 0),
      );
    }).toList();
  }

  List<List<TextEditingController>> _initNestedControllers(
      String Function(Channel) getValue) {
    return widget.fertilizerSite.map((site) {
      return site.channel.map((injector) {
        return TextEditingController(text: getValue(injector));
      }).toList();
    }).toList();
  }

  String _formatTime(double value) {
    int hours = (value ~/ 60);
    int minutes = (value % 60).toInt();
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Container(
                                  margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),

                                  decoration:
                                      const BoxDecoration(color: Color(0xff96CED5)),
                                  padding: const EdgeInsets.only(left: 8),
                                  width: 150,
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Fertilizer Site",
                                    style: TextStyle(
                                        color: Color(0xff30555A), fontSize: 13),
                                  )),
                              Column(
                                children: [
                                  for (var i = 0;
                                      i < widget.fertilizerSite.length;
                                      i++)
                                    Container(
                                      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey,
                                              width: 1),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 8),
                                      width: 150,
                                      height: 50.5 *
                                          widget.fertilizerSite[i].channel.length,
                                      child: Center(
                                        child: Text(
                                          widget.fertilizerSite[i].name,
                                          style: const TextStyle(
                                              color: Colors.black, fontSize: 13),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(children: [
                                  SizedBox(
                                      width: 1000,
                                      height: 50,
                                      child: SingleChildScrollView(
                                        controller: _horizontalScroll1,
                                        scrollDirection: Axis.horizontal,
                                        child: Row(

                                          mainAxisAlignment: MainAxisAlignment.center,
                                          // Center header cells horizontally
                                          children: [
                                            getCell(
                                                width: 122, title: 'Minimal On Time'),
                                            getCell(
                                                width: 122,
                                                title: 'Minimal Off Time'),
                                            getCell(
                                                width: 122,
                                                title: 'Booster Off Delay'),
                                            getCell(width: 122, title: 'Injector'),
                                            getCell(
                                                width: 122, title: 'Ratio (I/pulse'),
                                            getCell(
                                                width: 122, title: 'Shortest Pulse'),
                                            getCell(
                                                width: 122,
                                                title: 'Nominal Flow (I/hr)'),
                                            getCell(
                                                width: 125, title: 'Injector Mode'),
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                    width: 1000,
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      controller: _verticalScroll2,
                                      child: SingleChildScrollView(
                                        controller: _verticalScroll2,
                                        scrollDirection: Axis.vertical,
                                        child: Column(
                                          children: [
                                            for (var i = 0;
                                                i < widget.fertilizerSite.length;
                                                i++)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.all(1),
                                                    color: Colors.white,
                                                    // Optional if you want a white background
                                                    width: 120,
                                                    height: 50.7 *
                                                        widget.fertilizerSite[i]
                                                            .channel.length,
                                                    // Dynamic height
                                                    alignment: Alignment.center,
                                                    // Ensures content is centered
                                                    child: Center(
                                                      child: getValueCell(
                                                          getTimePicker(
                                                              i,
                                                              minimalOnTimeControllers[
                                                                  i])),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.all(1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50.7 *
                                                        widget.fertilizerSite[i]
                                                            .channel.length,
                                                    alignment: Alignment.center,
                                                    child: Center(
                                                      child: getValueCell(getTimePicker(
                                                          i,
                                                          minimalOffTimeControllers[
                                                              i])),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.all(1),
                                                    color: Colors.white,
                                                    width: 120,
                                                    height: 50.7 *
                                                        widget.fertilizerSite[i]
                                                            .channel.length,
                                                    alignment: Alignment.center,
                                                    child: Center(
                                                      child: getValueCell(getTimePicker(
                                                          i,
                                                          boosterOffDelayControllers[
                                                              i])),
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      for (var j = 0;
                                                          j <
                                                              widget
                                                                  .fertilizerSite[i]
                                                                  .channel
                                                                  .length;
                                                          j++)
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(1),
                                                              color: Colors.white,
                                                              width: 120,
                                                              height: 50,
                                                              child: getValueCell(
                                                                  Text(widget
                                                                      .fertilizerSite[
                                                                          i]
                                                                      .channel[j]
                                                                      .name)),
                                                            ),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(1),
                                                              color: Colors.white,
                                                              width: 120,
                                                              height: 50,
                                                              child: getValueCell(
                                                                  editableTableCell(
                                                                      ratioControllers[
                                                                          i][j])),
                                                            ),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(1),
                                                              color: Colors.white,
                                                              width: 120,
                                                              height: 50,
                                                              child: getValueCell(
                                                                  editableTableCell(
                                                                      shortestPulseControllers[
                                                                          i][j])),
                                                            ),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(1),
                                                              color: Colors.white,
                                                              width: 120,
                                                              height: 50,
                                                              child: getValueCell(
                                                                  editableTableCell(
                                                                      nominalFlowControllers[
                                                                          i][j])),
                                                            ),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(1),
                                                              color: Colors.white,
                                                              width: 129,
                                                              height: 50,
                                                              child: getValueCell(
                                                                getDropdown(
                                                                    i,
                                                                    j,
                                                                    widget
                                                                        .fertilizerSite[
                                                                            i]
                                                                        .channel[j]
                                                                        .injectorMode
                                                                        .toString()),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ]),
                              ))
                        ]),
                  ),
                ),
              ],
            )));
  }

  Widget getCell({required double width, required String title}) {
    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),

      padding: const EdgeInsets.symmetric(vertical: 15),
      width: width,
      height: 50,
      alignment: Alignment.center,
      // Ensures vertical alignment
      color: Colors.white,
      child: Text(
        title,
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget getValueCell(Widget child) {
    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),

      height: 50,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
      ),
      child: child,
    );
  }

  Widget getTimePicker(int index, TextEditingController controller) {
    return CustomTimePicker(
      index: index,
      initialMinutes: double.tryParse(controller.text.split(":")[0])! * 60 +
          double.tryParse(controller.text.split(":")[1])!,
      onTimeSelected: (int hours, int minutes, int seconds) {
        setState(() {
          controller.text = _formatTime((hours * 60 + minutes).toDouble());
        });
      },
    );
  }

  Widget editableTableCell(TextEditingController controller) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(border: InputBorder.none),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }

  Widget getDropdown(int siteIndex, int injectorIndex, String initialValue) {
    return DropdownButtonFormField<String>(
      value: actionOptions.contains(initialValue)
          ? initialValue
          : actionOptions.first,
      items: actionOptions.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            widget.fertilizerSite[siteIndex].channel[injectorIndex]
                .injectorMode = value as int;
            injectorModeControllers[siteIndex][injectorIndex].text = value;
          });
        }
      },
    );
  }
}
