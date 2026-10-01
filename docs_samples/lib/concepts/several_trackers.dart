import 'package:herald/herald.dart';
import 'package:herald_mixpanel/herald_mixpanel.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

// --8<-- [start:event]
final class const OrderPaid(final String orderId, final double total) extends Event {
  @override
  String get name => 'order_paid';

  @override
  Map<String, AnalyticsValue> get parameters => {
    'order_id': .string(orderId),
    'total': .double(total),
  };
}
// --8<-- [end:event]

// --8<-- [start:tracker]
// Adds the amount to the buyer's profile, which Mixpanel's revenue reports read.
final class const ChargeMixpanelEventTracker(final OrderPaid event, final Mixpanel mixpanel)
    implements MixpanelEventTracker {
  @override
  Future<void> track() async => mixpanel.getPeople().trackCharge(event.total);
}
// --8<-- [end:tracker]

// --8<-- [start:factory]
final class const CheckoutMixpanelEventTrackerFactory(final Mixpanel mixpanel)
    implements MixpanelEventTrackerFactory {
  @override
  Resolution<MixpanelEventTracker> create(Event event) => switch (event) {
    OrderPaid() => .claimed([
      GenericMixpanelEventTracker(event, mixpanel), // 1. the order_paid event, as usual
      ChargeMixpanelEventTracker(event, mixpanel), // 2. a charge on the buyer's profile
    ]),
    _ => .declined(),
  };
}
// --8<-- [end:factory]
