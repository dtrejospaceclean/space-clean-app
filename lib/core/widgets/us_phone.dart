import 'package:flutter/services.dart';

/// United States phone numbers, shown and typed as "(713) 555-0142".
abstract final class UsPhone {
  static const digits = 10;

  /// The digits of [text], without a leading country code 1 on 11 digits.
  static String digitsOf(String text) {
    final d = text.replaceAll(RegExp(r'\D'), '');
    return d.length == digits + 1 && d.startsWith('1') ? d.substring(1) : d;
  }

  /// "(713) 555-0142" for a full US number. Anything else (empty, partial,
  /// international numbers saved before the mask) is returned unchanged, so
  /// nothing is lost.
  static String format(String? text) {
    if (text == null) return '';
    final d = digitsOf(text);
    return d.length == digits ? _mask(d) : text;
  }

  /// Empty or all 10 digits.
  static bool isValid(String text) {
    final d = digitsOf(text);
    return d.isEmpty || d.length == digits;
  }

  /// As much of the mask as [d] (up to 10 digits) fills.
  static String _mask(String d) {
    final b = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i == 0) b.write('(');
      if (i == 3) b.write(') ');
      if (i == 6) b.write('-');
      b.write(d[i]);
    }
    return b.toString();
  }
}

/// Keeps a field in the "(713) 555-0142" mask while typing, pasting and
/// deleting: only digits are kept (at most 10), and the cursor stays after
/// the same digit.
class UsPhoneInputFormatter extends TextInputFormatter {
  const UsPhoneInputFormatter();

  static int _digitsBefore(String text, int offset) => text
      .substring(0, offset.clamp(0, text.length))
      .replaceAll(RegExp(r'\D'), '')
      .length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    var cursor = _digitsBefore(newValue.text, newValue.selection.end);

    // Backspace over ")", " " or "-" removes nothing on its own; take the
    // digit before it instead so the cursor never gets stuck.
    final oldDigits = oldValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits == oldDigits &&
        newValue.text.length < oldValue.text.length &&
        cursor > 0) {
      digits = digits.substring(0, cursor - 1) + digits.substring(cursor);
      cursor--;
    }

    // A pasted "+1 713 555 0142": drop the country code.
    if (digits.length == UsPhone.digits + 1 && digits.startsWith('1')) {
      digits = digits.substring(1);
      if (cursor > 0) cursor--;
    }
    if (digits.length > UsPhone.digits) {
      digits = digits.substring(0, UsPhone.digits);
    }
    cursor = cursor.clamp(0, digits.length);
    final text = UsPhone._mask(digits);

    // Place the cursor right after the same digit in the masked text.
    var offset = 0;
    for (var seen = 0; offset < text.length && seen < cursor; offset++) {
      if (RegExp(r'\d').hasMatch(text[offset])) seen++;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
