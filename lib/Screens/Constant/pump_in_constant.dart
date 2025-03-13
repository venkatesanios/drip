
import 'package:flutter/material.dart';
import 'modal_in_constant.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

class PumpPage extends StatefulWidget {
  final List<Pump> pump;

  const PumpPage({super.key, required this.pump});

  @override
  State<PumpPage> createState() => _PumpPageState();
}

class _PumpPageState extends State<PumpPage> {
  late List<TextEditingController> pumpStationControllers;
  late List<TextEditingController> controlGemControllers;
  late LinkedScrollControllerGroup _scrollable1;
  late ScrollController _verticalScroll1;
  late ScrollController _verticalScroll2;
  late LinkedScrollControllerGroup _scrollable2;
  late ScrollController _horizontalScroll1;
  late ScrollController _horizontalScroll2;
  double defaultSize = 120;

  @override
  void initState() {
    super.initState();
    pumpStationControllers =
        List.generate(widget.pump.length, (index) => TextEditingController());
    controlGemControllers =
        List.generate(widget.pump.length, (index) => TextEditingController());

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
    for (var controller in pumpStationControllers) {
      controller.dispose();
    }
    for (var controller in controlGemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
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
                      'Pump Name',
                      style: TextStyle(color: Color(0xff30555A), fontSize: 13),
                    ),
                  ),
                  SingleChildScrollView(
                    controller: _verticalScroll1,
                    child: Column(
                      children: [
                        for (var i = 0; i < widget.pump.length; i++)
                          Container(
                            margin: const EdgeInsets.only(bottom: 1),
                            decoration: const BoxDecoration(color: Colors.white),
                            padding: const EdgeInsets.only(left: 8),
                            width: defaultSize,
                            height: 50,
                            alignment: Alignment.center,
                            child: Text(
                              widget.pump[i].name,
                              style: const TextStyle(color: Colors.black, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
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
                    width: 240,
                    height: 50,
                    child: SingleChildScrollView(
                      controller: _horizontalScroll1,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getCell(width: 122, title: 'Pump Station'),
                          getCell(width: 121, title: 'Control Gem'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 240,
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
                              for (var i = 0; i < widget.pump.length; i++)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
                                      color: Colors.white,
                                      width: 120,
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: Checkbox(
                                        value: widget.pump[i].pumpStation,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            widget.pump[i].pumpStation = value ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
                                      color: Colors.white,
                                      width: 120,
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: Checkbox(
                                        value: widget.pump[i].controlGem,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            widget.pump[i].controlGem = value ?? false;
                                          });
                                        },
                                      ),
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
    );
  }


  Widget getCell({required double width, required String title}) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        width: width,
        height: 150,
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
}
