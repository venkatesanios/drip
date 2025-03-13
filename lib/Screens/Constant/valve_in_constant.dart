import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'constant_tableChart/customTimepicker_in_const.dart';
import 'modal_in_constant.dart';

class ValveInConstant extends StatefulWidget {
  const ValveInConstant(
      {super.key, required this.valves, required this.irrigationLines});

  final List<Valve> valves;
  final List<IrrigationLine> irrigationLines;

  @override
  State<ValveInConstant> createState() => _ValveInConstantState();
}

class _ValveInConstantState extends State<ValveInConstant> {
  late LinkedScrollControllerGroup _scrollableGroup;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;

  late List<TextEditingController> nominalFlowControllers;
  late List<double> fillUpDelays;
  double defaultSize = 120;

  @override
  void initState() {
    super.initState();

    // Initialize linked scroll controllers
    _scrollableGroup = LinkedScrollControllerGroup();
    _verticalScroll1 = _scrollableGroup.addAndGet();
    _verticalScroll2 = _scrollableGroup.addAndGet();
    _horizontalScroll1 = ScrollController();
    _horizontalScroll2 = ScrollController();

    nominalFlowControllers = List.generate(widget.valves.length, (index) {
      return TextEditingController(
        text: widget.valves[index].nominalFlow.toString(),
      );
    });

    fillUpDelays = widget.valves
        .map((valve) => parseTime(valve.fillUpDelay))
        .map((seconds) => seconds.toDouble())
        .toList();
  }

  @override
  void dispose() {
    _verticalScroll1.dispose();
    _verticalScroll2.dispose();
    _horizontalScroll1.dispose();
    _horizontalScroll2.dispose();

    for (var controller in nominalFlowControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  int parseTime(String time) {
    List<String> parts = time.split(":");
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  String formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    return "${hours.toString().padLeft(2, '0')}:"
        "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.only(top: 18),
      child: SizedBox(
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
                    decoration: const BoxDecoration(color: Color(0xff96CED5)),
                    padding: const EdgeInsets.only(left: 8),
                    width: defaultSize,
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text('Valve Name',
                        style: TextStyle(color: Color(0xff30555A), fontSize: 13)),
                  ),
                  SingleChildScrollView(
                    controller: _verticalScroll1,
                    child: Column(
                      children: [
                        for (var i = 0; i < widget.valves.length; i++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 1),
                            decoration: const BoxDecoration(color: Colors.white),
                            padding: const EdgeInsets.only(left: 8),
                            width: defaultSize,
                            height: 50,
                            child: Center(
                              child: Text(
                                widget.valves[i].name,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              Column(
              children: [
              SizedBox(
              width: 500,
              height: 50,
              child: SingleChildScrollView(
              controller: _horizontalScroll1,
              scrollDirection: Axis.horizontal,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,  // Center header cells horizontally
              children: [
                getCell(width: 122, title: 'Nominal Flow (I/hr'),
                getCell(width: 122, title: 'Fill Up Delay'),
                      ],
                    ),
                  )),
                SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    controller: _horizontalScroll2,
                    scrollDirection: Axis.horizontal,
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: _verticalScroll2,
                      child: SingleChildScrollView(
                        controller: _verticalScroll2,
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            for (var i = 0; i < widget.valves.length; i++)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Nominal Flow Cell
                                  Container(
                                    margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
                                    color: Colors.white,
                                    width: 120,
                                    height: 50,
                                    child: getValueCell(getTextField(i)), // Corrected to use index
                                  ),
          
                                  // Fill Up Delay Cell
                                  Container(
                                    margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
                                    color: Colors.white,
                                    width: 120,
                                    height: 50,
                                    child: getValueCell(getTimePicker(i)), // Corrected to use index
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              )
                ],
              ),
        ),

        ),
      ),
    );
  }

  Widget getCell({required double width, required String title}) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        width: width,
        height: 50,
        alignment: Alignment.center,
        color: Colors.white,
        child: Text(
          title,
          style: const TextStyle(color: Colors.black),
          textAlign: TextAlign.center,  // Center the text within the cell
        ),
      ),
    );
  }

  Widget getValueCell(Widget child) {
    return Container(
      height: 50,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
      ),
      child: child,
    );
  }

  Widget getTextField(int index) {
    return TextField(
      controller: nominalFlowControllers[index],
      keyboardType:
          const TextInputType.numberWithOptions(signed: false, decimal: false),
      decoration: const InputDecoration(border: OutlineInputBorder()),
      onChanged: (value) {
        setState(() {
          widget.valves[index].nominalFlow = value.isNotEmpty ? value : "0";
        });
      },
    );
  }

  Widget getTimePicker(int index) {
    return CustomTimePicker(
      index: index,
      initialMinutes: fillUpDelays[index] / 60, // Convert seconds to minutes
      onTimeSelected: (int hours, int minutes, int seconds) {
        setState(() {
          int totalSeconds = hours * 3600 + minutes * 60 + seconds;
          fillUpDelays[index] = totalSeconds.toDouble();
          widget.valves[index].fillUpDelay = formatTime(totalSeconds);
        });
      },
    );
  }
}
