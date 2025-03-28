import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


class Formatters {
  static String formatCurrency(double amount) {
    final format = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return format.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) {
      return "No feedback received";
    }
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      DateFormat formatter = DateFormat('MMM dd, yyyy hh:mm a');
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

}
