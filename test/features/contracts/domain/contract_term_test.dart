import 'package:flutter_test/flutter_test.dart';
import 'package:sp_cln_app/features/contracts/domain/entities/contract.dart';

Contract _contract(DateTime start, DateTime? end) => Contract(
  id: 'k1',
  clientId: 'c1',
  contractValue: '1800',
  startDate: start,
  expirationDate: end,
  status: ContractStatus.active,
);

void main() {
  test('a term is in years, months or days, the largest whole unit', () {
    expect(
      _contract(DateTime(2026, 1, 15), DateTime(2028, 1, 15)).term,
      const ContractTerm(2, TermUnit.years),
    );
    expect(
      _contract(DateTime(2026, 1, 15), DateTime(2026, 7, 15)).term,
      const ContractTerm(6, TermUnit.months),
    );
    expect(
      _contract(DateTime(2026, 10, 4), DateTime(2026, 10, 5)).term,
      const ContractTerm(1, TermUnit.days),
    );
    // Across the March daylight-saving change, still whole days.
    expect(
      _contract(DateTime(2026, 3, 1), DateTime(2026, 3, 31)).term,
      const ContractTerm(30, TermUnit.days),
    );
  });

  test('no term without an end after the start', () {
    expect(_contract(DateTime(2026, 10, 4), null).term, isNull);
    expect(
      _contract(DateTime(2026, 10, 4), DateTime(2026, 10, 4)).term,
      isNull,
    );
  });
}
