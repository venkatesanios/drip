import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_table_2/data_table_2.dart';
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
  late List<TextEditingController> controlCycleControllers;
  late List<TextEditingController> integControllers;
  late List<TextEditingController> deltaControllers;
  late List<TextEditingController> fineTuningControllers;
  late List<TextEditingController> coarseTuningControllers;
  late List<TextEditingController> deadBandControllers;
  late List<TextEditingController> avgFiltSpeedControllers;
  late List<TextEditingController> percentageControllers;

  List<dynamic> combinedList = [];
  late List<String> selectedSensors;

  @override
  void initState() {
    super.initState();

    combinedList = [
      ...widget.ec.map((e) => {'type': 'EC', 'data': e}),
      ...widget.ph.map((p) => {'type': 'PH', 'data': p})
    ];

    controlCycleControllers = _initTimeControllers();
    integControllers = _initTimeControllers();
    deltaControllers = _initNumberControllers();
    fineTuningControllers = _initNumberControllers();
    coarseTuningControllers = _initNumberControllers();
    deadBandControllers = _initNumberControllers();
    avgFiltSpeedControllers = _initNumberControllers();
    percentageControllers = _initNumberControllers();
  }

  List<TextEditingController> _initTimeControllers() =>
      List.generate(combinedList.length, (index) => TextEditingController(text: "00:00"));

  List<TextEditingController> _initNumberControllers() =>
      List.generate(combinedList.length, (index) => TextEditingController(text: "0.0"));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: combinedList.isEmpty
            ? const Center(
          child: Text(
            "No EC/Ph Available",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        )
            : DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 800,
            headingRowHeight: 40,
            headingRowColor: WidgetStateProperty.all(Colors.teal.shade300),
            border: TableBorder.all(),
            columns: _buildHeaderColumns(),
            rows: _generateRows(),
            ),
      ),
    );
  }

  List<DataColumn2> _buildHeaderColumns() => [
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
  ].map((title) => DataColumn2(label: Text(title))).toList();

  List<DataRow> _generateRows() => List.generate(combinedList.length, (index) {
    var data = combinedList[index]['data'];

    return DataRow(cells: [
      DataCell(Text(data.name)),
      DataCell(Checkbox(
        value: data.selected,
        onChanged: (value) {
          setState(() {
            data.selected = value ?? false;
          });
        },
      )),
      DataCell(getTimePicker(index, controlCycleControllers[index])),
      DataCell(editableTableCell(deltaControllers[index])),
      DataCell(editableTableCell(fineTuningControllers[index])),
      DataCell(editableTableCell(coarseTuningControllers[index])),
      DataCell(editableTableCell(deadBandControllers[index])),
      DataCell(getTimePicker(index, integControllers[index])),
      DataCell(getDropdown(index)),
      DataCell(editableTableCell(avgFiltSpeedControllers[index])),
      DataCell(editableTableCell(percentageControllers[index])),
    ]);
  });

  Widget getTimePicker(int index, TextEditingController controller) => CustomTimePicker(
    index: index,
    initialMinutes: 0,
    onTimeSelected: (int hours, int minutes, int seconds) {
      setState(() {
        controller.text = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
      });
    },
  );

  Widget getDropdown(int index) {
    var data = combinedList[index]['data'];
    List<String> dropdownOptions = ["Average"];

    for (int i = 0; i < widget.ec.length; i++) {
      dropdownOptions.add("EC.1.${i + 1}");
    }
    for (int i = 0; i < widget.ph.length; i++) {
      dropdownOptions.add("PH.1.${i + 1}");
    }

    if (!dropdownOptions.contains(data.controlSensor)) {
      data.controlSensor = dropdownOptions.first;
    }

    return DropdownButton<String>(
      value: data.controlSensor,
      items: dropdownOptions.map((sensor) => DropdownMenuItem(value: sensor, child: Text(sensor))).toList(),
      onChanged: (value) {
        setState(() {
          data.controlSensor = value!;
        });
      },
    );
  }

  Widget editableTableCell(TextEditingController controller) => Container(
    width: 100,
    height: 50,
    alignment: Alignment.center,
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(border: InputBorder.none),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
    ),
  );
}
