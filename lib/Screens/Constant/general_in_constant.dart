import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'ConstantPageProvider/changeNotifier_constantProvider.dart';
import 'constant_tableChart/customTimepicker_in_const.dart';

class GeneralPage extends StatefulWidget {
  const GeneralPage({super.key, required this.generalUpdated});

  final List<Map<String, dynamic>> generalUpdated;

  @override
  _GeneralPageState createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  late List<TextEditingController> _controllers;
  int? selectedIndex;
  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.generalUpdated.length,
          (index) => TextEditingController(
        text: widget.generalUpdated[index]['value'].toString(),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(

      builder: (context, constraints) {
        double cardWidth = 300;
        int cardsPerRow = (constraints.maxWidth / (cardWidth + 20)).floor();

        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      for (var i = 0; i < widget.generalUpdated.length; i++)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = i;
                            });
                          },
                          child: SizedBox(
                            width: cardWidth,
                            child: IntrinsicHeight( // Ensure uniform height for all cards
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white, // Default card color
                                  border: Border.all(
                                    color: selectedIndex == i
                                        ? const Color(0xFF005B8D)
                                        : Colors.white,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: selectedIndex == i
                                          ? Colors.blue.withOpacity(0.5)
                                          : Colors.grey,
                                      blurRadius: 5,
                                      spreadRadius: 3,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(10),
                                child: getWidgetGeneral(
                                    context, widget.generalUpdated[i], i),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (widget.generalUpdated.length % cardsPerRow != 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        cardsPerRow - (widget.generalUpdated.length % cardsPerRow),
                            (index) => SizedBox(width: cardWidth),
                      ),
                    ),

                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
        );

      },
    );
  }

  Widget getWidgetGeneral(BuildContext context, Map<String, dynamic> item, int index) {

    int type = item['widgetTypeId'] ?? 0;
    String name = item['title'] ?? "Unknown";

    switch (type) {
      case 1: // Numeric Input
        return ListTile(
          title: Text(name),
          trailing: SizedBox(
            width: 60,
            child: TextField(
              controller: _controllers[index],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (value) {
                setState(() {
                  widget.generalUpdated[index]['value'] = value.isNotEmpty ? value : '0';
                });
              },
            ),
          ),
        );
      case 2: // Switch Boolean Input
        return ListTile(
          title: Text(name),
          trailing: Switch(
            value: widget.generalUpdated[index]['value'] == true,
            onChanged: (bool newValue) {
              setState(() {
                widget.generalUpdated[index]['value'] = newValue;
              });
            },
          ),
        );



      case 3: // Time Picker
        return ListTile(
          title: Text(name),
          trailing: SizedBox(
            width: 100,
            child: getTimePicker(index),
          ),
        );

      default:
        return const SizedBox();
    }
  }

  Widget getTimePicker(int index) {
    return CustomTimePicker(
      index: index,
      initialMinutes: _parseTime(widget.generalUpdated[index]['value']).toDouble(),
      onTimeSelected: (int hours, int minutes, int seconds) {
        setState(() {
          String timeString = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:00";
          widget.generalUpdated[index]['value'] = timeString;
        });
      },
    );
  }

  int _parseTime(String? timeString) {
    if (timeString == null || !timeString.contains(":")) return 0;
    List<String> parts = timeString.split(":");
    int hours = int.tryParse(parts[0]) ?? 0;
    int minutes = int.tryParse(parts[1]) ?? 0;
    return (hours * 60) + minutes;
  }
}
