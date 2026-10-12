export '../../../../core/domain/money.dart';

import '../../../../core/domain/money.dart';

/// Where a negotiation stands in the sales pipeline, in order.
enum ProposalStage {
  lead('lead'),
  walkthrough('walkthrough'),
  pricing('pricing'),
  proposal('proposal'),
  negotiation('negotiation'),
  approved('approved'),

  /// A stage this app doesn't know yet.
  unknown('');

  const ProposalStage(this.wire);

  /// The API's name for it.
  final String wire;

  static ProposalStage fromWire(String? value) => values.firstWhere(
    (s) => s != unknown && s.wire == value,
    orElse: () => unknown,
  );

  /// The stages a proposal can be put in by hand. Approved is reached only
  /// by approving it.
  static const open = [lead, walkthrough, pricing, proposal, negotiation];
}

/// One priced line of a proposal version.
class ProposalLineItem {
  const ProposalLineItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.serviceId,
  });

  final String id;

  /// The catalog service it came from, if any. The description is what the
  /// client reads.
  final String? serviceId;
  final String description;

  /// Decimal strings as the API sends them ("12000", "0.12", "1440"). The
  /// server computes [lineTotal].
  final String quantity;
  final String unitPrice;
  final String lineTotal;
}

/// One version of a negotiation with a client account. Versions of the
/// same negotiation share [groupId]; only the [isCurrent] one can change,
/// and only until it's approved.
class Proposal {
  const Proposal({
    required this.id,
    required this.clientId,
    required this.groupId,
    required this.stage,
    required this.versionNumber,
    required this.isCurrent,
    this.versionNote,
    this.agreedPrice,
    this.validUntil,
    this.preparedByName,
    this.approvedByName,
    this.approvedDate,
    this.createdAt,
    this.lineItems = const [],
  });

  final String id;
  final String clientId;
  final String groupId;
  final ProposalStage stage;
  final int versionNumber;
  final bool isCurrent;

  /// What changed in this version, e.g. "Annual contract discount".
  final String? versionNote;

  /// A decimal string, or null until a price is agreed.
  final String? agreedPrice;

  /// A calendar day (no time).
  final DateTime? validUntil;
  final String? preparedByName;
  final String? approvedByName;
  final DateTime? approvedDate;
  final DateTime? createdAt;
  final List<ProposalLineItem> lineItems;

  bool get isApproved => stage == ProposalStage.approved;

  /// Only the current, unapproved version can be edited, get a new version
  /// or be approved.
  bool get isOpen => isCurrent && !isApproved;

  /// The sum of the line totals as a decimal string ("1440.00").
  String get lineItemsTotal =>
      centsToDecimal(lineItems.fold(0, (sum, i) => sum + toCents(i.lineTotal)));

  /// The agreed price when there is one, otherwise the line items' total.
  String get price => agreedPrice ?? lineItemsTotal;

  /// Whether there's any price to show yet: an agreed one or line items.
  /// A bare lead has none, which isn't the same as costing nothing.
  bool get hasPrice => agreedPrice != null || lineItems.isNotEmpty;
}

/// A line item as typed in the form. Numbers stay as typed ("12000",
/// "0.12").
class LineItemDraft {
  const LineItemDraft({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.serviceId,
  });

  final String? serviceId;
  final String description;
  final String quantity;
  final String unitPrice;
}

/// The editable fields of a proposal version. Empty optional fields clear
/// them on an edit.
class ProposalDraft {
  const ProposalDraft({
    required this.stage,
    this.agreedPrice,
    this.validUntil,
    this.versionNote,
    this.lineItems = const [],
  });

  final ProposalStage stage;

  /// As typed, up to two decimals.
  final String? agreedPrice;
  final DateTime? validUntil;
  final String? versionNote;
  final List<LineItemDraft> lineItems;
}
