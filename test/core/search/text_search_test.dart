import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/core/search/text_search.dart';

void main() {
  test('an empty query matches everything', () {
    expect(matchesSearch('', ['anything']), isTrue);
    expect(matchesSearch('   ', []), isTrue);
  });

  test('every word must appear, in any field and order', () {
    const fields = ['Office cleaning', 'Negotiation', null];
    expect(matchesSearch('negotiation office', fields), isTrue);
    expect(matchesSearch('office lead', fields), isFalse);
  });

  test('case and Spanish accents are ignored both ways', () {
    expect(matchesSearch('GOMEZ', ['Laura Gómez']), isTrue);
    expect(matchesSearch('negociación', ['Negociacion']), isTrue);
    expect(matchesSearch('ÑANDÚ', ['nandu']), isTrue);
  });
}
