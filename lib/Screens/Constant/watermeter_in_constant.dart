import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'modal_in_constant.dart';

class WatermeterInConstant extends StatefulWidget {
  final List<WaterMeter> waterMeter;
  final List<IrrigationLine> irrigationLines;
  final List<Pump> pump;

  const WatermeterInConstant({
    super.key,
    required this.waterMeter,
    required this.irrigationLines,
    required this.pump,
  });

  @override
  State<WatermeterInConstant> createState() => _WatermeterInConstantState();
}

class _WatermeterInConstantState extends State<WatermeterInConstant> {
  late LinkedScrollControllerGroup _scrollControllerGroup;
  late ScrollController _headerScrollController;
  late ScrollController _bodyScrollController;
  late ScrollController _verticalController;
  late ScrollController _horizontalController;
  late List<TextEditingController> ratioControllers;

  @override
  void initState() {
    super.initState();
    _scrollControllerGroup = LinkedScrollControllerGroup();
    _headerScrollController = _scrollControllerGroup.addAndGet();
    _bodyScrollController = _scrollControllerGroup.addAndGet();
    _verticalController = ScrollController();
    _horizontalController = ScrollController();

    // Initialize text controllers for ratio values
    ratioControllers = widget.waterMeter
        .map((meter) => TextEditingController(text: meter.ratio.toString()))
        .toList();
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    _verticalController.dispose();
    _horizontalController.dispose();

    for (var controller in ratioControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.waterMeter.isEmpty
          ? const Center(
        child: Text(
          "No water meter available",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              SizedBox(
                height: 50, // Match header height
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _headerScrollController,
                  child: Row(
                    children: _buildHeaderColumns()
                        .map((title) => _headerCell(title))
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 2), // Spacing

              // Scrollable Table Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _verticalController,
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: 320, // Ensure content is not cropped
                    child: SingleChildScrollView(
                      controller: _bodyScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: _generateRows(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  List<String> _buildHeaderColumns() => ["Water Meters", "Ratio (I/pulse)"];

  Widget _headerCell(String title) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
    width: 160, // Adjusted width for better visibility
    height: 50,
    alignment: Alignment.center,
    color: Colors.teal.shade300,
    child: Text(
      title,
      style: const TextStyle(
          fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );

  Widget _dataCell(Widget child) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
    color: Colors.white,
    width: 160, // Match width with headers
    height: 50,
    alignment: Alignment.center,
    child: child,
  );

  /// Creates an editable text field for ratio values
  Widget _editableTableCell(TextEditingController controller) => Container(
    width: 160, // Match width with headers
    height: 50,
    color: Colors.white,
    alignment: Alignment.center,
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: const InputDecoration(border: InputBorder.none),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
      ],
    ),
  );

  /// Generates dynamic rows for water meter data
  List<Widget> _generateRows() {
    return List.generate(widget.waterMeter.length, (index) {
      WaterMeter meter = widget.waterMeter[index];

      return Row(
        children: [
          _dataCell(Text(meter.name)), // Assuming WaterMeter has a 'name' field
          _editableTableCell(ratioControllers[index]),
        ],
      );
    });
  }
}
