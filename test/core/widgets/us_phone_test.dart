import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/widgets/us_phone.dart';

/// Runs [UsPhoneInputFormatter] on an edit from [before] (cursor at its
/// end) to [after], with the cursor at [afterCursor] (default: the end).
TextEditingValue _edit(String before, String after, {int? afterCursor}) =>
    const UsPhoneInputFormatter().formatEditUpdate(
      TextEditingValue(
        text: before,
        selection: TextSelection.collapsed(offset: before.length),
      ),
      TextEditingValue(
        text: after,
        selection: TextSelection.collapsed(offset: afterCursor ?? after.length),
      ),
    );

void main() {
  group('UsPhone.format', () {
    test('masks a full number, with or without country code', () {
      expect(UsPhone.format('7135550142'), '(713) 555-0142');
      expect(UsPhone.format('713-555-0142'), '(713) 555-0142');
      expect(UsPhone.format('+1 713 555 0142'), '(713) 555-0142');
    });

    test('leaves anything else as it was saved', () {
      expect(UsPhone.format(null), '');
      expect(UsPhone.format(''), '');
      expect(UsPhone.format('555-0100'), '555-0100');
      expect(UsPhone.format('+52 55 5555 5555'), '+52 55 5555 5555');
    });
  });

  test('a phone is valid empty or with all 10 digits', () {
    expect(UsPhone.isValid(''), isTrue);
    expect(UsPhone.isValid('(713) 555-0142'), isTrue);
    expect(UsPhone.isValid('(713) 555-01'), isFalse);
  });

  group('typing', () {
    test('fills the mask as digits arrive', () {
      expect(_edit('', '7').text, '(7');
      expect(_edit('(71', '(713').text, '(713');
      expect(_edit('(713', '(7135').text, '(713) 5');
      expect(_edit('(713) 555', '(713) 5550').text, '(713) 555-0');
      expect(_edit('(713) 555-014', '(713) 555-0142').text, '(713) 555-0142');
    });

    test('ignores letters and stops at 10 digits', () {
      expect(_edit('(713', '(713a').text, '(713');
      expect(_edit('(713) 555-0142', '(713) 555-01429').text, '(713) 555-0142');
    });

    test('a pasted number with country code drops the 1', () {
      expect(_edit('', '+1 (713) 555-0142').text, '(713) 555-0142');
    });

    test('backspace over a separator removes the digit before it', () {
      // "(713) 5" → delete the space after ")".
      final value = _edit('(713) 5', '(713)5', afterCursor: 5);
      expect(value.text, '(715');
      expect(value.selection.end, 3);
    });

    test('an edit in the middle keeps the cursor after the same digit', () {
      // Insert 9 after "(71".
      final value = _edit('(713) 555-0142', '(7193) 555-0142', afterCursor: 4);
      expect(value.text, '(719) 355-5014');
      expect(value.selection.end, 4);
    });
  });
}
