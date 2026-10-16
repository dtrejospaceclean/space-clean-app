/// Where a suggested price came from.
enum BillingSource {
  /// The line for the service on the proposal the contract came from.
  proposal,

  /// The service catalog's default price.
  catalog,
}

/// What a job's service suggests for an invoice line: the agreed quantity
/// and price, else the catalog's price. Every field may be null (a one-off
/// job, a scope without a service, a service without a price).
class JobBillingSuggestion {
  const JobBillingSuggestion({
    this.serviceId,
    this.serviceName,
    this.quantity,
    this.unitPrice,
    this.source,
  });

  static const none = JobBillingSuggestion();

  final String? serviceId;
  final String? serviceName;

  /// Decimal strings as the API sends them; null leaves the field alone.
  final String? quantity;
  final String? unitPrice;

  /// Null when there's no price to suggest.
  final BillingSource? source;
}
