import 'package:flutter/material.dart';

class DatePickerHelper {
  DatePickerHelper._();

  static Future<DateTime?> pick({
    required BuildContext context,
    DateTime? initial,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: firstDate ?? DateTime(now.year - 5),
      lastDate: lastDate ?? DateTime(now.year + 20),
      locale: const Locale('ar'),
    );
  }
}
