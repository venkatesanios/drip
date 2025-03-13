import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'constant_tableChart/customTimepicker_in_const.dart';
import 'modal_in_constant.dart';

class MainValveInConstant extends StatefulWidget {
  final List<MainValve> mainValves;
  final List<IrrigationLine> irrigationLines;

  const MainValveInConstant(
      {super.key, required this.mainValves, required this.irrigationLines});

  @override
  State<MainValveInConstant> createState() => _MainValveInConstantState();
}

class _MainValveInConstantState extends State<MainValveInConstant> {
  late LinkedScrollControllerGroup _scrollableGroup;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  double defaultSize = 120;
  List<String> actionOptions = ['No delay', 'Open before', 'Open after'];

  @override
  void initState() {
    super.initState();

    // Initialize linked scroll controllers
    _scrollableGroup = LinkedScrollControllerGroup();
    _verticalScroll1 = _scrollableGroup.addAndGet();
    _verticalScroll2 = _scrollableGroup.addAndGet();
    _horizontalScroll1 = ScrollController();
    _horizontalScroll2 = ScrollController();
  }

  @override
  void dispose() {
    _verticalScroll1.dispose();
    _verticalScroll2.dispose();
    _horizontalScroll1.dispose();
    _horizontalScroll2.dispose();
    super.dispose();
  }

  int parseTime(String time) {
    List<String> parts = time.split(":");
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: SizedBox(
            width: MediaQuery
                .sizeOf(context)
                .width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                          decoration: const BoxDecoration(
                              color: Color(0xff96CED5)),
                          padding: const EdgeInsets.only(left: 8),
                          width: defaultSize,
                          height: 50,
                          alignment: Alignment.center,
                          child: const Text(
                            'Main Valve',
                            style: TextStyle(
                                color: Color(0xff30555A), fontSize: 13),
                          )),
                      SingleChildScrollView(
                        controller: _verticalScroll1,
                        child: Column(
                          children: [
                            for (var i = 0; i < widget.mainValves.length; i++)
                              Container(
                                margin: const EdgeInsets.only(bottom: 1),
                                decoration: const BoxDecoration(color: Colors
                                    .white),
                                padding: const EdgeInsets.only(left: 8),
                                width: defaultSize,
                                height: 50,
                                child: Center(
                                  child: Text(
                                    widget.mainValves[i].name,
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                getCell(width: 122, title: 'Mode'),
                                getCell(width: 122, title: 'Delay'),
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
                                scrollDirection: Axis.vertical,
                                controller: _verticalScroll2,
                                child: Column(
                                  children: widget.mainValves.map((mainValve) {
                                    int index = widget.mainValves.indexOf(
                                        mainValve);
                                    return Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 1, right: 1, bottom: 1),
                                          color: Colors.white,
                                          width: 120,
                                          height: 50,
                                          child: getDropdown(
                                              index, "mode", mainValve.mode),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 1, right: 1, bottom: 1),
                                          color: Colors.white,
                                          width: 120,
                                          height: 50,
                                          child: getTimePicker(
                                            index,
                                            "delay",
                                            parseTime(mainValve.delay).toDouble(),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            )
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
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
          textAlign: TextAlign.center, // Center the text within the cell
        ),
      ),
    );
  }

  Widget getValueCell(String value) {
    return Container(
      width: 120,
      height: 50,
      alignment: Alignment.center,
      color: Colors.white,
      child: Text(value),
    );
  }

  Widget getDropdown(int index, String field, String initialValue) {
    return DropdownButtonFormField<String>(
      value: actionOptions.contains(initialValue)
          ? initialValue
          : actionOptions.first,
      items: actionOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            if (field == "mode") {
              widget.mainValves[index].mode = value;
            }
          });
        }
      },
    );
  }

  Widget getTimePicker(int index, String field, double? initialSeconds) {
    return CustomTimePicker(
      index: index,
      initialMinutes: (initialSeconds ?? 0.0) / 60, // Correct conversion
      onTimeSelected: (int hours, int minutes, int seconds) {
        setState(() {
          widget.mainValves[index].delay =
          "${hours.toString().padLeft(2, '0')}:"
              "${minutes.toString().padLeft(2, '0')}:"
              "${seconds.toString().padLeft(2, '0')}";
        });
      },
    );
  }
}