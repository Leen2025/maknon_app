import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat('#,##0.##', 'ar');

  static String format(double amount) => _formatter.format(amount);
}
