import 'package:intl/intl.dart';

import '../constants/app_strings.dart';

class DateUtilsX {
  DateUtilsX._();

  static String formatArabic(DateTime date) {
    return DateFormat('d MMMM y', 'ar').format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat('d MMM', 'ar').format(date);
  }

  /// Returns the number of full days between today and [target].
  /// Negative if target is in the past.
  static int daysUntil(DateTime target) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final t = DateTime(target.year, target.month, target.day);
    return t.difference(today).inDays;
  }

  /// Human-readable countdown phrase for Arabic UI.
  static String countdownLabel(DateTime target) {
    final diff = daysUntil(target);
    if (diff < 0) return AppStrings.expired;
    if (diff == 0) return AppStrings.today;
    if (diff == 1) return AppStrings.tomorrow;
    if (diff == 2) return 'يومان';
    if (diff <= 10) return '$diff ${AppStrings.days}';
    return '$diff يوم';
  }
}
