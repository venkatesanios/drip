import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'constant_tableChart/customTimepicker_in_const.dart';
import 'modal_in_constant.dart';

class IrrigationLineInConstant extends StatefulWidget {
  final List<IrrigationLine> irrigationLines;

  const IrrigationLineInConstant({super.key, required this.irrigationLines});

  @override
  State<IrrigationLineInConstant> createState() => _IrrigationLineInConstantState();
}

class _IrrigationLineInConstantState extends State<IrrigationLineInConstant> {
  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  double defaultSize = 120;

  List<String> actionOptions = ['Ignore', 'Do Next', 'Wait'];

  @override
  void initState() {
    super.initState();

    // Initialize LinkedScrollControllerGroup for synchronized scrolling
    _scrollable1 = LinkedScrollControllerGroup();
    _verticalScroll1 = _scrollable1.addAndGet();
    _verticalScroll2 = _scrollable1.addAndGet();
    _scrollable2 = LinkedScrollControllerGroup();
    _horizontalScroll1 = _scrollable2.addAndGet();
    _horizontalScroll2 = _scrollable2.addAndGet();
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
                      child: const Text(
                        'Irrigation Line',
                        style: TextStyle(color: Color(0xff30555A), fontSize: 13),
                      ),
                    ),
                    SingleChildScrollView(
                      controller: _verticalScroll1,
                      child: Column(
                        children: [
                          for (var i = 0; i < widget.irrigationLines.length; i++)
                            Container(
                              margin: const EdgeInsets.only(bottom: 1),
                              decoration: const BoxDecoration(color: Colors.white),
                              padding: const EdgeInsets.only(left: 8),
                              width: defaultSize,
                              height: 50,
                              child: Center(
                                child: Text(
                                  widget.irrigationLines[i].name,
                                  style: const TextStyle(color: Colors.black, fontSize: 13),
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
                            getCell(width: 122, title: 'Low Flow Delay'),
                            getCell(width: 122, title: 'High Flow Delay'),
                            getCell(width: 122, title: 'Low Flow Action'),
                            getCell(width: 122, title: 'High Flow Action'),
                          ],
                        ),
                      ),
                    ),
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
                              children: [
                                for (var i = 0; i < widget.irrigationLines.length; i++)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,  // Center rows horizontally
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
                                        color: Colors.white,
                                        width: 120,
                                        height: 50,
                                        child: getTimePicker(i, "lowFlowDelay", parseTime(widget.irrigationLines[i].lowFlowDelay).toDouble()),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
                                        color: Colors.white,
                                        width: 120,
                                        height: 50,
                                        child: getTimePicker(i, "highFlowDelay", parseTime(widget.irrigationLines[i].highFlowDelay).toDouble()),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
                                        color: Colors.white,
                                        width: 120,
                                        height: 50,
                                        child: getDropdown(i, "lowFlowAction", widget.irrigationLines[i].lowFlowAction ?? 'Ignore'),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
                                        color: Colors.white,
                                        width: 120,
                                        height: 50,
                                        child: getDropdown(i, "highFlowAction", widget.irrigationLines[i].highFlowAction ?? 'Ignore'),
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
                ),
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

  Widget getTimePicker(int index, String field, double? initialSeconds) {
    return CustomTimePicker(
      index: index,
      initialMinutes: initialSeconds ?? 0.0,
      onTimeSelected: (int hours, int minutes, int seconds) {
        setState(() {
          String newValue = "${hours.toString().padLeft(2, '0')}:"
              "${minutes.toString().padLeft(2, '0')}:"
              "${seconds.toString().padLeft(2, '0')}";

          if (field == "lowFlowDelay") {
            widget.irrigationLines[index].lowFlowDelay = newValue;
          } else if (field == "highFlowDelay") {
            widget.irrigationLines[index].highFlowDelay = newValue;
          }
        });
      },
    );
  }

  Widget getDropdown(int index, String field, String initialValue) {
    return DropdownButtonFormField<String>(
      value: actionOptions.contains(initialValue) ? initialValue : actionOptions.last,
      items: actionOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),  // Make the text bold
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            if (field == "lowFlowAction") {
              widget.irrigationLines[index].lowFlowAction = value;
            } else if (field == "highFlowAction") {
              widget.irrigationLines[index].highFlowAction = value;
            }
          });
        }
      },
      decoration: const InputDecoration(
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none), // Remove the underline
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none), // Remove the underline when focused
      ),
    );
  }
}
