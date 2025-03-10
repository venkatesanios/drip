import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:data_table_2/data_table_2.dart';
import 'constant_tableChart/customTimepicker_in_const.dart';
import 'modal_in_constant.dart';

class FertilizerInConstant extends StatefulWidget {
  List<FertilizerSite> fertilizerSite;
  FertilizerInConstant({super.key, required this.fertilizerSite, required List<Channel> channels});

  @override
  State<FertilizerInConstant> createState() => _FertilizerInConstantState();
}

class _FertilizerInConstantState extends State<FertilizerInConstant> {
  late List<TextEditingController> minimalOnTimeControllers;
  late List<TextEditingController> minimalOffTimeControllers;
  late List<TextEditingController> boosterOffDelayControllers;
  late List<List<TextEditingController>> ratioControllers;
  late List<List<TextEditingController>> shortestPulseControllers;
  late List<List<TextEditingController>> nominalFlowControllers;
  late List<List<TextEditingController>> injectorModeControllers;

  List<String> actionOptions = ['Concentration', 'Ec controlled', 'Ph controlled', 'Regular'];

  @override
  void initState() {
    super.initState();
    minimalOnTimeControllers = _initControllers((site) => site.minimalOnTime);
    minimalOffTimeControllers = _initControllers((site) => site.minimalOffTime);
    boosterOffDelayControllers = _initControllers((site) => site.boosterOffDelay);
    ratioControllers = _initNestedControllers((injector) => injector.ratio.toString());
    shortestPulseControllers = _initNestedControllers((injector) => injector.shortestPulse.toString());
    nominalFlowControllers = _initNestedControllers((injector) => injector.nominalFlow.toString());
    injectorModeControllers = _initNestedControllers((injector) => injector.injectorMode.toString());
  }

  List<TextEditingController> _initControllers(String Function(FertilizerSite) getValue) {
    return widget.fertilizerSite.map((site) {
      return TextEditingController(
        text: _formatTime(double.tryParse(getValue(site)) ?? 0),
      );
    }).toList();
  }

  List<List<TextEditingController>> _initNestedControllers(String Function(Channel) getValue) {
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
      body: buildTable(),
    );
  }

  Widget buildTable() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0,left: 20,right: 20),

      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 1600,
        headingRowHeight: 40,
        headingRowColor: WidgetStateProperty.all(Colors.teal.shade300),
        border: TableBorder.all(),
        columns: _buildHeaderColumns(),
        rows: _generateRows(),
      ),
    );
  }

  List<DataColumn2> _buildHeaderColumns() {
    return [
      "Fertilizer Site", "Minimal On Time", "Minimal Off Time", "Booster Off Delay",
      "Injector", "Ratio (I/pulse)", "Shortest Pulse", "Nominal Flow (I/hr)", "Injector Mode"
    ].map((title) => DataColumn2(label: Text(title))).toList();
  }

  List<DataRow> _generateRows() {
    List<DataRow> rows = [];
    for (int i = 0; i < widget.fertilizerSite.length; i++) {
      final site = widget.fertilizerSite[i];
      for (int j = 0; j < site.channel.length; j++) {
        final injector = site.channel[j];
        bool isFirstRow = (j == 0);

        rows.add(DataRow(cells: [
          isFirstRow ? DataCell(Text(site.name)) : const DataCell(SizedBox()),
          isFirstRow ? DataCell(getTimePicker(i, minimalOnTimeControllers[i])) : const DataCell(SizedBox()),
          isFirstRow ? DataCell(getTimePicker(i, minimalOffTimeControllers[i])) : const DataCell(SizedBox()),
          isFirstRow ? DataCell(getTimePicker(i, boosterOffDelayControllers[i])) : const DataCell(SizedBox()),
          DataCell(Text(injector.name)),
          DataCell(editableTableCell(ratioControllers[i][j])),
          DataCell(editableTableCell(shortestPulseControllers[i][j])),
          DataCell(editableTableCell(nominalFlowControllers[i][j])),
          DataCell(getDropdown(i, j, injector.injectorMode.toString())),
        ]));
      }
    }
    return rows;
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
      value: actionOptions.contains(initialValue) ? initialValue : actionOptions.first,
      items: actionOptions.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            widget.fertilizerSite[siteIndex].channel[injectorIndex].injectorMode = value as int;
            injectorModeControllers[siteIndex][injectorIndex].text = value;
          });
        }
      },
    );
  }
}