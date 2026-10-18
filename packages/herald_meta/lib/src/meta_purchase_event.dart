import 'package:herald/herald.dart';

/// A purchase, as Meta's standard `fb_mobile_purchase`, which Meta counts as revenue for ads.
///
/// Your events don't extend it: your Meta factory builds one from your event and sends it with
/// [PurchaseMetaEventTracker].
final class const MetaPurchaseEvent({
  /// Not sent. Only used in failure reports.
  @override required final String name,

  /// The amount paid.
  required final double amount,

  /// An ISO 4217 code, such as `EUR`.
  required final String currency,

  /// Sent with the purchase.
  @override final Map<String, AnalyticsValue> parameters = const {},
}) extends Event {
  @override
  String toString() => 'MetaPurchaseEvent($name, $amount $currency)';
}
