import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final int index;
  final double initialMinutes;
  final Function(int, int, int) onTimeSelected;

  const CustomTimePicker({
    Key? key,
    required this.index,
    required this.initialMinutes,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late Duration selectedDuration;

  @override
  void initState() {
    super.initState();

    int totalSeconds = widget.initialMinutes.toInt();
    totalSeconds =
        totalSeconds.clamp(0, 86399); // Ensure it's within 0 - 23:59:59

    selectedDuration = Duration(seconds: totalSeconds);
  }

  void _showTimePicker() {
    Duration tempDuration = selectedDuration;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          width: 350,
          constraints: BoxConstraints(maxHeight: 350),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: Color(0xFF003F62), // Dark blue background color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                  height: 200,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,  // Background color of the container
                      borderRadius: BorderRadius.circular(200),  // Set radius for all corners
                    ),
                    child: CupertinoTimerPicker(
                      backgroundColor: Colors.transparent,  // Make the background transparent so the container background shows
                      mode: CupertinoTimerPickerMode.hms,
                      initialTimerDuration: tempDuration,
                      onTimerDurationChanged: (Duration newDuration) {
                        tempDuration = newDuration;
                      },
                ),
              )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      selectedDuration = tempDuration; // Confirm selection
                    });
                    widget.onTimeSelected(
                      selectedDuration.inHours,
                      selectedDuration.inMinutes % 60,
                      selectedDuration.inSeconds % 60,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Confirm",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showTimePicker,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "${selectedDuration.inHours.toString().padLeft(2, '0')}:"
              "${(selectedDuration.inMinutes % 60).toString().padLeft(2, '0')}:"
              "${(selectedDuration.inSeconds % 60).toString().padLeft(2, '0')}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}