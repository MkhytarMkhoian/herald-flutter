import 'package:facebook_app_events/facebook_app_events.dart';

import '../meta_event_tracker.dart';
import '../meta_purchase_event.dart';
import '../meta_values.dart';

/// Logs a purchase as Meta's `fb_mobile_purchase`. Throws an [ArgumentError] for an amount that
/// isn't a finite number.
final class const PurchaseMetaEventTracker(
  final MetaPurchaseEvent event,
  final FacebookAppEvents appEvents,
) implements MetaEventTracker {
  @override
  Future<void> track() async {
    if (!event.amount.isFinite) {
      throw ArgumentError.value(
        event.amount,
        'amount',
        "Meta purchase '${event.name}' needs a finite amount",
      );
    }
    await appEvents.logPurchase(
      amount: event.amount,
      currency: event.currency,
      parameters: event.parameters.toMetaParameters(),
    );
  }
}
