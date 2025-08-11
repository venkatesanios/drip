import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;


class Formatters {
  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return format.format(amount);
  }


  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
  }

  static String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) {
      return "No feedback received";
    }
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      DateFormat formatter = DateFormat('MMM dd, yyyy hh:mm:ss a');
      return formatter.format(dateTime);
    } catch (e) {
      return "00 00, 0000, 00:00";
    }
  }

  static TextInputFormatter capitalizeFirstLetter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isNotEmpty) {
        return TextEditingValue(
          text: newValue.text[0].toUpperCase() + newValue.text.substring(1),
          selection: newValue.selection,
        );
      }
      return newValue;
    });
  }

  bool isValidTimeFormat(String input) {
    final RegExp timeRegex = RegExp(r'^\d{2}:\d{2}:\d{2}$');
    return timeRegex.hasMatch(input);
  }

  String formatRtcValues(dynamic value1, dynamic value2) {
    if (value1 == 0 && value2 == 0) {
      return '--';
    } else {
      return '${value1.toString()}/${value2.toString()}';
    }
  }

  String formatRelativeTime(String rawDateTime) {
    DateTime dateTime = DateTime.parse(rawDateTime);
    return timeago.format(dateTime);
  }

  static TextInputFormatter upperCaseFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      return TextEditingValue(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
      );
    });
  }

}
