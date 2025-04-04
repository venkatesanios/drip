import 'dart:async';

import 'package:flutter/cupertino.dart';

class DurationNotifier extends ChangeNotifier {
  ValueNotifier<String> leftDurationOrFlow = ValueNotifier<String>('00:00:00');
  ValueNotifier<String> onDelayLeft = ValueNotifier<String>('00:00:00');

  void updateDuration(String newDuration) {
    leftDurationOrFlow.value = newDuration;
  }

  void updateOnDelayTime(String onDelayTime) {
    onDelayLeft.value = onDelayTime;
  }
}

class DecreaseDurationNotifier extends ChangeNotifier {
  late Duration _duration;
  late Timer _timer;

  DecreaseDurationNotifier(String timeLeft) {
    _duration = _parseTime(timeLeft);
    _startTimer();
  }

  String get onDelayLeft => _formatTime(_duration);

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds > 0) {
        _duration -= const Duration(seconds: 1);
        notifyListeners(); // Notify UI to update
      } else {
        _timer.cancel(); // Stop the timer when time reaches 0
      }
    });
  }

  Duration _parseTime(String time) {
    List<String> parts = time.split(':');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(parts[2]),
    );
  }

  String _formatTime(Duration duration) {
    return "${duration.inHours.toString().padLeft(2, '0')}:"
        "${(duration.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class IncreaseDurationNotifier extends ChangeNotifier {
  late Duration _duration;
  late Timer _timer;

  IncreaseDurationNotifier(String timeCompleted) {
    _duration = _parseTime(timeCompleted);
    _startTimer();
  }

  String get onCompletedDrQ => _formatTime(_duration);

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds > 0) {
        _duration += const Duration(seconds: 1);
        notifyListeners();
      } else {
        _timer.cancel();
      }
    });
  }

  Duration _parseTime(String time) {
    List<String> parts = time.split(':');
    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(parts[2]),
    );
  }

  String _formatTime(Duration duration) {
    return "${duration.inHours.toString().padLeft(2, '0')}:"
        "${(duration.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}