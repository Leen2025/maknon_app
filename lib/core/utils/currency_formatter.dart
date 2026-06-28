import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat('#,##0.##', 'ar');

  static String format(double amount) => _formatter.format(amount);

  /// Plain (non-grouped, Latin-digit) form for editable text fields.
  /// Drops a trailing `.0` so whole numbers show as "10" not "10.0".
  static String plain(double amount) => amount == amount.roundToDouble()
      ? amount.toInt().toString()
      : amount.toString();
}
