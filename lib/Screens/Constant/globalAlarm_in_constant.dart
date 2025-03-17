import 'package:flutter/material.dart';
import 'modal_in_constant.dart';

class GlobalAlarmInConstant extends StatefulWidget {
  final List<Alarm> alarm;

  const GlobalAlarmInConstant({super.key, required this.alarm});

  @override
  State<GlobalAlarmInConstant> createState() => _GlobalAlarmInConstantState();
}

class _GlobalAlarmInConstantState extends State<GlobalAlarmInConstant> {
  late List<bool> switchStates;

  @override
  void initState() {
    super.initState();
    switchStates = List.generate(widget.alarm.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Wrap(
                    runSpacing: 20,
                    spacing: constraints.maxWidth * 0.05,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (var i = 0; i < widget.alarm.length; i++)
                        SizedBox(
                          width: 300,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5)],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: ListTile(
                              title: Text(widget.alarm[i].name),
                              trailing: Switch(
                                value: switchStates[i],
                                onChanged: (value) {
                                  setState(() {
                                    switchStates[i] = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      // Add placeholders for uniform alignment
                      for (var j = 0; j < (3 - (widget.alarm.length % 3)) % 3; j++)
                        SizedBox(width: 300, height: 80),
                    ],
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
}