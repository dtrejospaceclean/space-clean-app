import 'package:flutter/material.dart';

import '../../../../core/design/design.dart';
import '../../../../core/l10n/formatting.dart';
import '../../domain/entities/proposal.dart';

/// Money in a row: tabular digits, so amounts line up down a list.
const moneyStyle = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

/// Whether text is large enough (150% and up) that a trailing figure would
/// crowd a row's title; rows then put the figure under it instead.
bool isLargeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(1) >= 1.5;

/// A line item as a row: what it is, the math ("48,000 sq ft × $0.12"),
/// and its total.
class LineItemRow extends StatelessWidget {
  const LineItemRow({
    super.key,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.unit,
    this.detail,
    this.onTap,
  });

  final String description;

  /// Decimal strings ("12000", "0.12", "1440").
  final String quantity;
  final String unitPrice;
  final String lineTotal;

  /// The linked service's unit ("sq ft"), when known.
  final String? unit;

  /// One more thing about it, after the math ("Job: Lobby deep clean").
  final String? detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final large = isLargeText(context);
    final total = context.formatMoney(lineTotal);
    final math =
        '${[context.formatNumber(quantity), ?unit].join(' ')} × '
        '${context.formatMoney(unitPrice)}';
    return ListRow(
      title: description,
      subtitle: [large ? '$math = $total' : math, ?detail].join(' · '),
      trailing: large ? null : Text(total, style: moneyStyle),
      onTap: onTap,
    );
  }
}

/// [LineItemRow] for a line item the API sent.
extension ProposalLineItemRow on ProposalLineItem {
  LineItemRow row({String? unit}) => LineItemRow(
    description: description,
    quantity: quantity,
    unitPrice: unitPrice,
    lineTotal: lineTotal,
    unit: unit,
  );
}
