import 'package:flutter/services.dart';

/// Converts Arabic-Indic (٠-٩) and Persian (۰-۹) digits — plus the Arabic
/// decimal separator (٫) — to ASCII as the user types, so numeric fields
/// parse correctly regardless of the keyboard language.
class ArabicDigitsFormatter extends TextInputFormatter {
  const ArabicDigitsFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = normalizeDigits(newValue.text);
    if (normalized == newValue.text) return newValue;
    // Text length is preserved (1:1 char mapping), so the selection stays valid.
    return newValue.copyWith(text: normalized);
  }
}

/// Maps Arabic-Indic / Persian digits and the Arabic decimal mark to ASCII.
String normalizeDigits(String input) {
  const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    final ai = arabicIndic.indexOf(ch);
    if (ai != -1) {
      buffer.write(ai);
      continue;
    }
    final fa = persian.indexOf(ch);
    if (fa != -1) {
      buffer.write(fa);
      continue;
    }
    // Arabic decimal separator → '.'
    buffer.write(ch == '٫' ? '.' : ch);
  }
  return buffer.toString();
}
