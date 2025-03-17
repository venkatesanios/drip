import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'constant_tableChart/customTimepicker_in_const.dart';
import 'modal_in_constant.dart';

class EcPhInConstant extends StatefulWidget {
  final List<EC> ec;
  final List<PH> ph;
  final List<FertilizerSite> fertilizerSite;
  final List<String> controlSensors;

  const EcPhInConstant({
    super.key,
    required this.ec,
    required this.ph,
    required this.fertilizerSite,
    required this.controlSensors,
  });

  @override
  State<EcPhInConstant> createState() => _EcPhInConstantState();
}

class _EcPhInConstantState extends State<EcPhInConstant> {
  late LinkedScrollControllerGroup _scrollControllerGroup;
  late ScrollController _headerScrollController;
  late ScrollController _dataScrollController;
  List<Map<String, TextEditingController>> controllers = [];

  List<dynamic> combinedList = [];

  @override
  void initState() {
    super.initState();

    _scrollControllerGroup = LinkedScrollControllerGroup();
    _headerScrollController = _scrollControllerGroup.addAndGet();
    _dataScrollController = _scrollControllerGroup.addAndGet();

    combinedList = [
      ...widget.ec.map((e) => {'type': 'EC', 'data': e}),
      ...widget.ph.map((p) => {'type': 'PH', 'data': p})
    ];

    initializeControllers();
  }

  void initializeControllers() {
    controllers = combinedList.map((item) {
      var data = item['data']; // Get the object (EC or PH)
      return {
        "delta": TextEditingController(text: data.delta?.toString() ?? ""),
        "fineTuning": TextEditingController(text: data.fineTuning?.toString() ?? ""),
        "coarseTuning": TextEditingController(text: data.coarseTuning?.toString() ?? ""),
        "deadBand": TextEditingController(text: data.deadBand?.toString() ?? ""),
        "avgFiltSpeed": TextEditingController(text: data.avgFiltSpeed?.toString() ?? ""),
        "percentage": TextEditingController(text: data.percentage?.toString() ?? ""),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _headerScrollController,
              child: Row(
                children: _buildHeaderColumns()
                    .map((title) => _headerCell(title))
                    .toList(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _dataScrollController,
                child: Column(
                  children: _generateRows(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String title) => Container(
    margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
    width: 120,
    height: 50,
    alignment: Alignment.center,
    color: Color(0xFFF6F6F6),
    child: Text(
      title,
      style:
      const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
    ),
  );

  List<String> _buildHeaderColumns() => [
    "Site",
    "Selected",
    "Control Cycle",
    "Delta",
    "Fine Tuning",
    "Coarse Tuning",
    "Deadband",
    "Integ",
    "Control Sensor",
    "Avg Filt Speed",
    "Percentage"
  ];

  List<Widget> _generateRows() => List.generate(combinedList.length, (index) {
    var data = combinedList[index]['data'];
    return Row(
      children: [
        _dataCell(Text(data.name)),
        _dataCell(Checkbox(
          value: data.selected,
          onChanged: (value) {
            setState(() {
              data.selected = value ?? false;
            });
          },
        )),
        _dataCell(_getTimePicker(index, "controlCycle", data.controlCycle)),
        _dataCell(_editableTableCell(index,'delta')),
        _dataCell(_editableTableCell(index, 'fineTuning' )),
        _dataCell(_editableTableCell(index, 'coarseTuning')),
        _dataCell(_editableTableCell(index, 'deadBand')),
        _dataCell(_getTimePicker(index, "integ", data.integ)),
        _dataCell(getDropdown(index)),
        _dataCell(_editableTableCell(index, 'avgFiltSpeed')),
    _dataCell(_editableTableCell(index, 'percentage'))
      ],
    );
  });

  Widget _dataCell(Widget child) => Container(
    margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
    color: Colors.white,
    width: 120,
    height: 50,
    alignment: Alignment.center,
    child: child,
  );

  Widget _getTimePicker(int index, String key, String? initialTime) {
    return Container(
      margin: const EdgeInsets.only(left: 1, right: 1, bottom: 1),
      color: Colors.white,
      width: 120,
      height: 50,
      child: CustomTimePicker(
        index: index,
        initialMinutes: _parseTime(initialTime ?? "00:00").toDouble(),
        onTimeSelected: (int hours, int minutes, int seconds) {
          if (index >= 0 && index < combinedList.length) {
            setState(() {
              var item = combinedList[index]['data'];
              if (item is Map<String, dynamic>) {
                item[key] = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
              } else {
                debugPrint("Error: Data at index $index is not a Map but a ${item.runtimeType}!");
              }
            });

          } else {
            debugPrint("Error: Index $index is out of bounds!");
          }
        },
      ),
    );
  }

  Widget _editableTableCell(int index, String key) {
    if (index >= controllers.length || !controllers[index].containsKey(key)) {
      return const Text("Error");
    }
    return TextField(
      controller: controllers[index][key],
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(border: InputBorder.none),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
      onChanged: (newValue) {
        setState(() {
          combinedList[index]['data'][key] = newValue;
          debugPrint("Updated $key at index $index: $newValue");
        });
      },
    );
  }




  int _parseTime(String time) {
    List<String> parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Widget getDropdown(int index) {
    var data = combinedList[index]['data'];
    List<String> dropdownOptions = ["Average"];

    if (combinedList[index]['type'] == 'EC') {
      for (int i = 0; i < widget.ec.length; i++) {
        dropdownOptions.add("EC.1.${i + 1}");
      }
    } else if (combinedList[index]['type'] == 'PH') {
      for (int i = 0; i < widget.ph.length; i++) {
        dropdownOptions.add("PH.1.${i + 1}");
      }
    }

    return DropdownButton<String>(
      value: data.controlSensor,
      items: dropdownOptions
          .map((sensor) => DropdownMenuItem(value: sensor, child: Text(sensor)))
          .toList(),
      onChanged: (value) {
        setState(() {
          data.controlSensor = value!;
        });
      },
    );
  }
}