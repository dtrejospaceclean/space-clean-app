/// Money as the API sends it: decimal strings ("2400", "0.12"). Sums are
/// done in whole cents, never in doubles. Pure Dart, so any feature's domain
/// can use it.
library;

/// A decimal string ("0.12", "1440") in whole cents, rounded like the API's
/// two-decimal columns. Unparseable input is 0.
int toCents(String value) {
  final match = RegExp(r'^\s*(\d*)(?:\.(\d*))?\s*$').firstMatch(value);
  if (match == null) return 0;
  final whole = int.tryParse(match.group(1)!.isEmpty ? '0' : match.group(1)!);
  final fraction = (match.group(2) ?? '').padRight(3, '0');
  final cents = int.parse(fraction.substring(0, 2));
  final round = int.parse(fraction[2]) >= 5 ? 1 : 0;
  return (whole ?? 0) * 100 + cents + round;
}

/// Whole cents as a decimal string: 144000 → "1440.00".
String centsToDecimal(int cents) =>
    '${cents ~/ 100}.${(cents % 100).toString().padLeft(2, '0')}';

/// [quantity] × [unitPrice] in cents, to preview a line total while typing
/// (the server computes the real one). Unparseable input counts as 0.
int lineTotalCents(String quantity, String unitPrice) {
  final q = num.tryParse(quantity.trim()) ?? 0;
  final p = num.tryParse(unitPrice.trim()) ?? 0;
  return (q * p * 100).round();
}
