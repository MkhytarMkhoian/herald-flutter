import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/widgets.dart';
import 'package:herald/herald.dart';
import 'package:herald_meta/herald_meta.dart';

final class const OrderPaid(final String orderId, final double total) extends Event {
  @override
  String get name => 'order_paid';

  @override
  Map<String, AnalyticsValue> get parameters => {'order_id': .string(orderId)};
}

/// Sends a paid order as Meta's fb_mobile_purchase, and leaves every other event to the next
/// factory.
final class const PurchaseMetaFactory(final FacebookAppEvents appEvents)
    implements MetaEventTrackerFactory {
  @override
  Resolution<MetaEventTracker> create(Event event) => switch (event) {
    OrderPaid() => .claimed([
      PurchaseMetaEventTracker(
        MetaPurchaseEvent(name: event.name, amount: event.total, currency: 'EUR'),
        appEvents,
      ),
    ]),
    _ => const .declined(),
  };
}

HeraldProvider metaProvider(FacebookAppEvents appEvents) {
  final service = MetaAnalyticsService(appEvents);
  final tracker = MetaAnalyticsTrackerService(
    // Nothing at the end, so only the conversions a factory handles are sent.
    eventTrackerFactory: CompositeMetaEventTrackerFactory([PurchaseMetaFactory(appEvents)]),
  );
  return HeraldProvider(
    name: 'meta',
    events: tracker, // no properties: Meta keeps no user attributes
    identity: service,
    lifecycle: service,
    consent: service,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final herald = Herald(providers: [metaProvider(FacebookAppEvents())]);

  await herald.start();
  await herald.setEnabled(true); // the user agreed: Meta starts
  await herald.track(const OrderPaid('order-1', 9.99));
}
