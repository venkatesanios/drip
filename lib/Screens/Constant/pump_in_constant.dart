import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'modal_in_constant.dart';

class PumpPage extends StatefulWidget {
  final List<Pump> pump;

  const PumpPage({super.key, required this.pump});

  @override
  State<PumpPage> createState() => _PumpPageState();
}

class _PumpPageState extends State<PumpPage> {
  late List<TextEditingController> pumpStationControllers;
  late List<TextEditingController> controlGemControllers;

  @override
  void initState() {
    super.initState();
    pumpStationControllers =
        List.generate(widget.pump.length, (index) => TextEditingController());
    controlGemControllers =
        List.generate(widget.pump.length, (index) => TextEditingController());
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child:DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 1000,
            headingRowHeight: 40,
            headingRowColor: WidgetStateProperty.all(Colors.teal.shade300),
            border: TableBorder.all(),
            columns: const [
              DataColumn(label: Text("Pump Name")),
              DataColumn(label: Text("Pump Station")),
              DataColumn(label: Text("Control Gem")),
            ],
            rows: List<DataRow>.generate(widget.pump.length, (index) {
              return DataRow(cells: [
                DataCell(Text(widget.pump[index].name)),
                DataCell(Checkbox(
                  value: widget.pump[index].pumpStation,
                  onChanged: (bool? value) {
                    setState(() {
                      widget.pump[index].pumpStation = value ?? false;
                    });
                  },
                )),
                DataCell(Checkbox(
                  value: widget.pump[index].controlGem,
                  onChanged: (bool? value) {
                    setState(() {
                      widget.pump[index].controlGem = value ?? false;
                    });
                  },
                )),
              ]);
            }),
          ),
        ),
      ),
    );
  }
}
